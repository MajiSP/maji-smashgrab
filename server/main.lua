RegisterNetEvent('smashgrab:server:reward', function(vehicleId, coords, modelType)
    local src = source
    
    if not src or src <= 0 then
        return
    end
    
    local policeCount = Bridge.Server.GetPoliceCount()
    if policeCount < Config.Police.RequiredCops then
        TriggerClientEvent('smashgrab:client:notify', src, 'Not enough police online', 'error')
        return
    end
    
    if math.random(100) <= Config.Police.AlertChance then
        local alertCoords = {x = coords.x, y = coords.y, z = coords.z}
        Bridge.Server.PoliceAlert(alertCoords, 'Vehicle break-in reported at GPS coordinates')
    end
    
    local rewards = CalculateRewards(modelType)
    
    if #rewards > 0 then
        for _, reward in pairs(rewards) do
            if reward.item == 'money' then
                Bridge.Server.AddMoney(src, reward.amount, 'cash')
            else
                Bridge.Server.AddItem(src, reward.item, reward.amount)
            end
        end
        
        local rewardText = CreateRewardMessage(rewards)
        TriggerClientEvent('smashgrab:client:notify', src, Config.Notifications.Success .. '\n' .. rewardText, 'success')
        
        LogReward(src, rewards, coords, modelType)
    else
        TriggerClientEvent('smashgrab:client:notify', src, Config.Notifications.Nothing, 'error')
    end
end)

function CalculateRewards(modelType)
    local rewards = {}
    
    if not modelType or not Config.ItemModels[modelType] then
        return rewards
    end
    
    local modelData = Config.ItemModels[modelType]
    
    for _, item in pairs(modelData.items) do
        if math.random(100) <= item.chance then
            local amount = math.random(item.min, item.max)
            
            table.insert(rewards, {
                item = item.item,
                amount = amount
            })
        end
    end
    
    return rewards
end

function CreateRewardMessage(rewards)
    local messages = {}
    
    for _, reward in pairs(rewards) do
        if reward.item == 'money' then
            table.insert(messages, '$' .. reward.amount)
        else
            local itemName = GetItemLabel(reward.item)
            if reward.amount > 1 then
                table.insert(messages, reward.amount .. 'x ' .. itemName)
            else
                table.insert(messages, itemName)
            end
        end
    end
    
    return table.concat(messages, ', ')
end

function GetItemLabel(itemName)
    if Bridge.Framework == 'qb-core' then
        local items = Bridge.Shared.Items
        return items[itemName] and items[itemName].label or itemName
    elseif Bridge.Framework == 'qbox' then
        return itemName:gsub('_', ' '):gsub('^%l', string.upper)
    elseif Bridge.Framework == 'esx' then
        return itemName:gsub('_', ' '):gsub('^%l', string.upper)
    else
        return itemName:gsub('_', ' '):gsub('^%l', string.upper)
    end
end

function LogReward(source, rewards, coords, modelType)
    local playerName = GetPlayerName(source)
    local rewardList = {}
    
    for _, reward in pairs(rewards) do
        table.insert(rewardList, reward.amount .. 'x ' .. reward.item)
    end
    
    local logMessage = string.format(
        '[SmashGrab] Player %s (ID: %d) found %s containing: %s at coords: %.2f, %.2f, %.2f',
        playerName,
        source,
        modelType or 'unknown item',
        table.concat(rewardList, ', '),
        coords.x,
        coords.y,
        coords.z
    )
    
    print(logMessage)
end

RegisterNetEvent('smashgrab:client:notify', function(message, type)
end)

AddEventHandler('playerJoining', function()
end)

RegisterNetEvent('smashgrab:client:notify')
AddEventHandler('smashgrab:client:notify', function(message, type)
    Bridge.Client.Notify(message, type)
end)

CreateThread(function()
    local version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    print('^2[SmashGrab]^0 Version ^3' .. (version or '1.0.0') .. '^0 loaded successfully!')
    print('^2[SmashGrab]^0 Framework: ^3' .. Config.Framework .. '^0')
end)
