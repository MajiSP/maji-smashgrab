if not IsDuplicityVersion() then return end

if not Bridge then Bridge = {} end
Bridge.Server = {}

function Bridge.Server.GetPlayer(source)
    if Bridge.Framework == 'qb-core' then
        return Bridge.Functions.GetPlayer(source)
    elseif Bridge.Framework == 'qbox' then
        return Bridge.QBX:GetPlayer(source)
    elseif Bridge.Framework == 'esx' then
        return Bridge.GetPlayerFromId(source)
    elseif Bridge.Framework == 'ox' then
        return exports.ox_core:GetPlayer(source)
    else
        return nil
    end
end

function Bridge.Server.AddItem(source, item, count, metadata)
    count = count or 1
    metadata = metadata or {}
    
    if Bridge.Framework == 'qb-core' then
        local Player = Bridge.Server.GetPlayer(source)
        if Player then
            return Player.Functions.AddItem(item, count, nil, metadata)
        end
    elseif Bridge.Framework == 'qbox' then
        return exports.ox_inventory:AddItem(source, item, count, metadata)
    elseif Bridge.Framework == 'esx' then
        local xPlayer = Bridge.Server.GetPlayer(source)
        if xPlayer then
            if item == 'money' then
                xPlayer.addMoney(count)
                return true
            else
                xPlayer.addInventoryItem(item, count)
                return true
            end
        end
    elseif Bridge.Framework == 'ox' then
        return exports.ox_inventory:AddItem(source, item, count, metadata)
    else
        return false
    end
    return false
end

function Bridge.Server.AddMoney(source, amount, type)
    type = type or 'cash'
    
    if Bridge.Framework == 'qb-core' then
        local Player = Bridge.Server.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney(type, amount)
            return true
        end
    elseif Bridge.Framework == 'qbox' then
        local Player = Bridge.Server.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney(type, amount)
            return true
        end
    elseif Bridge.Framework == 'esx' then
        local xPlayer = Bridge.Server.GetPlayer(source)
        if xPlayer then
            xPlayer.addMoney(amount)
            return true
        end
    elseif Bridge.Framework == 'ox' then
        local Player = Bridge.Server.GetPlayer(source)
        if Player then
            exports.ox_inventory:AddItem(source, 'money', amount)
            return true
        end
    end
    return false
end

function Bridge.Server.GetPoliceCount()
    local count = 0
    local players = GetPlayers()
    
    for _, playerId in pairs(players) do
        local Player = Bridge.Server.GetPlayer(tonumber(playerId))
        if Player then
            local job = ''
            
            if Bridge.Framework == 'qb-core' or Bridge.Framework == 'qbox' then
                job = Player.PlayerData.job.name
            elseif Bridge.Framework == 'esx' then
                job = Player.job.name
            elseif Bridge.Framework == 'ox' then
                job = Player.job or ''
            end
            
            for _, policeJob in pairs(Config.Police.JobNames) do
                if job == policeJob then
                    count = count + 1
                    break
                end
            end
        end
    end
    
    return count
end

function Bridge.Server.PoliceAlert(coords, message)
    if Config.Dispatch.Enable then
        SendDispatchAlert(coords, message)
    else
        local players = GetPlayers()
        
        for _, playerId in pairs(players) do
            local Player = Bridge.Server.GetPlayer(tonumber(playerId))
            if Player then
                local job = ''
                
                if Bridge.Framework == 'qb-core' or Bridge.Framework == 'qbox' then
                    job = Player.PlayerData.job.name
                elseif Bridge.Framework == 'esx' then
                    job = Player.job.name
                elseif Bridge.Framework == 'ox' then
                    job = Player.job or ''
                end
                
                for _, policeJob in pairs(Config.Police.JobNames) do
                    if job == policeJob then
                        TriggerClientEvent('smashgrab:client:policeAlert', tonumber(playerId), coords, message)
                        break
                    end
                end
            end
        end
    end
end

function DetectDispatchSystem()
    local systems = {
        'ps-dispatch',
        'cd_dispatch', 
        'core_dispatch',
        'linden_outlawalert',
        'rcore_dispatch',
        'qs-dispatch'
    }
    
    for _, system in pairs(systems) do
        if GetResourceState(system) == 'started' then
            return system
        end
    end
    
    return 'none'
end

function SendDispatchAlert(coords, message)
    local dispatchSystem = Config.Dispatch.System
    
    if dispatchSystem == 'auto' then
        dispatchSystem = DetectDispatchSystem()
    end
    
    local alertData = {
        coords = coords,
        message = Config.Dispatch.AlertMessage,
        code = Config.Dispatch.AlertCode,
        sprite = Config.Dispatch.BlipSettings.sprite,
        color = Config.Dispatch.BlipSettings.color,
        scale = Config.Dispatch.BlipSettings.scale,
        time = Config.Dispatch.BlipSettings.time
    }
    
    if dispatchSystem == 'ps-dispatch' then
        exports['ps-dispatch']:VehicleTheft(alertData)
    elseif dispatchSystem == 'cd_dispatch' then
        TriggerEvent('cd_dispatch:AddNotification', {
            job_table = Config.Police.JobNames,
            coords = coords,
            title = Config.Dispatch.AlertCode .. ' - Vehicle Break-in',
            message = Config.Dispatch.AlertMessage,
            flash = 0,
            unique_id = math.random(1000000, 9999999),
            blip = {
                sprite = Config.Dispatch.BlipSettings.sprite,
                scale = Config.Dispatch.BlipSettings.scale,
                colour = Config.Dispatch.BlipSettings.color,
                flashes = false,
                text = "Vehicle Break-in",
                time = (Config.Dispatch.BlipSettings.time / 1000),
            }
        })
    elseif dispatchSystem == 'core_dispatch' then
        exports['core_dispatch']:addCall(Config.Dispatch.AlertCode, Config.Dispatch.AlertMessage, {
            {icon = "fas fa-car", info = "Vehicle Break-in"}
        }, {coords[1], coords[2], coords[3]}, Config.Police.JobNames[1], 5000, Config.Dispatch.BlipSettings.sprite, Config.Dispatch.BlipSettings.color)
    elseif dispatchSystem == 'linden_outlawalert' then
        local data = exports['linden_outlawalert']:outlawNotify({
            displayCode = Config.Dispatch.AlertCode,
            description = Config.Dispatch.AlertMessage,
            isImportant = 0,
            recipientList = Config.Police.JobNames,
            length = 10000,
            infoM = 'fa-car',
            info = 'Vehicle Break-in'
        })
        local callId = data.callId
        exports['linden_outlawalert']:outlawBlip({
            callId = callId,
            recipientList = Config.Police.JobNames,
            location = coords,
            blipSettings = {
                sprite = Config.Dispatch.BlipSettings.sprite,
                color = Config.Dispatch.BlipSettings.color,
                scale = Config.Dispatch.BlipSettings.scale,
                text = 'Vehicle Break-in'
            }
        })
    elseif dispatchSystem == 'rcore_dispatch' then
        TriggerEvent('rcore_dispatch:server:sendAlert', {
            code = Config.Dispatch.AlertCode,
            default_priority = 'medium',
            coords = coords,
            job = Config.Police.JobNames,
            text = Config.Dispatch.AlertMessage,
            type = 'alerts',
            blip_time = Config.Dispatch.BlipSettings.time,
            blip = {
                sprite = Config.Dispatch.BlipSettings.sprite,
                colour = Config.Dispatch.BlipSettings.color,
                scale = Config.Dispatch.BlipSettings.scale
            }
        })
    elseif dispatchSystem == 'qs-dispatch' then
        exports['qs-dispatch']:VehicleTheft(coords, Config.Dispatch.AlertMessage)
    else
        -- Fallback to basic system
        print('^3[SmashGrab]^0 No dispatch system detected, using fallback alerts')
        local players = GetPlayers()
        
        for _, playerId in pairs(players) do
            local Player = Bridge.Server.GetPlayer(tonumber(playerId))
            if Player then
                local job = ''
                
                if Bridge.Framework == 'qb-core' or Bridge.Framework == 'qbox' then
                    job = Player.PlayerData.job.name
                elseif Bridge.Framework == 'esx' then
                    job = Player.job.name
                elseif Bridge.Framework == 'ox' then
                    job = Player.job or ''
                end
                
                for _, policeJob in pairs(Config.Police.JobNames) do
                    if job == policeJob then
                        TriggerClientEvent('smashgrab:client:policeAlert', tonumber(playerId), coords, message)
                        break
                    end
                end
            end
        end
    end
end
