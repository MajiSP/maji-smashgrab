if IsDuplicityVersion() then return end

if not Bridge then Bridge = {} end
Bridge.Client = {}

function Bridge.Client.GetPlayerData()
    if Bridge.Framework == 'qb-core' then
        return Bridge.Functions.GetPlayerData()
    elseif Bridge.Framework == 'qbox' then
        return Bridge.QBX:GetPlayerData()
    elseif Bridge.Framework == 'esx' then
        return Bridge.GetPlayerData()
    elseif Bridge.Framework == 'ox' then
        return exports.ox_core:GetPlayer()
    else
        return {}
    end
end

function Bridge.Client.Notify(message, type, duration)
    type = type or 'info'
    duration = duration or 5000
    
    if Bridge.Framework == 'qb-core' then
        Bridge.Functions.Notify(message, type, duration)
    elseif Bridge.Framework == 'qbox' then
        Bridge.QBX:Notify(message, type, duration)
    elseif Bridge.Framework == 'esx' then
        Bridge.ShowNotification(message)
    elseif Bridge.Framework == 'ox' then
        exports.ox_lib:notify({
            title = 'Smash & Grab',
            description = message,
            type = type,
            duration = duration
        })
    else
        if GetResourceState('ox_lib') == 'started' then
            exports.ox_lib:notify({
                title = 'Smash & Grab',
                description = message,
                type = type,
                duration = duration
            })
        else
            print(message)
        end
    end
end

function Bridge.Client.ProgressBar(data, cb)
    if Bridge.Framework == 'qb-core' then
        exports['progressbar']:Progress({
            name = data.name or 'smash_grab',
            duration = data.duration,
            label = data.label,
            useWhileDead = data.useWhileDead or false,
            canCancel = data.canCancel or true,
            controlDisables = data.disable or {},
            animation = data.anim,
        }, function(cancelled)
            cb(not cancelled)
        end)
    elseif Bridge.Framework == 'qbox' then
        if exports.ox_lib then
            if exports.ox_lib:progressBar({
                duration = data.duration,
                label = data.label,
                useWhileDead = data.useWhileDead or false,
                canCancel = data.canCancel or true,
                disable = data.disable or {},
                anim = data.anim,
            }) then
                cb(true)
            else
                cb(false)
            end
        end
    elseif Bridge.Framework == 'esx' then
        if GetResourceState('esx_progressbar') == 'started' then
            exports.esx_progressbar:Progressbar(data.label, data.duration, {
                FreezePlayer = true,
                animation = data.anim,
                onFinish = function()
                    cb(true)
                end,
                onCancel = function()
                    cb(false)
                end
            })
        elseif GetResourceState('ox_lib') == 'started' then
            if exports.ox_lib:progressBar({
                duration = data.duration,
                label = data.label,
                useWhileDead = data.useWhileDead or false,
                canCancel = data.canCancel or true,
                disable = data.disable or {},
                anim = data.anim,
            }) then
                cb(true)
            else
                cb(false)
            end
        end
    else
        if GetResourceState('ox_lib') == 'started' then
            if exports.ox_lib:progressBar({
                duration = data.duration,
                label = data.label,
                useWhileDead = data.useWhileDead or false,
                canCancel = data.canCancel or true,
                disable = data.disable or {},
                anim = data.anim,
            }) then
                cb(true)
            else
                cb(false)
            end
        else
            Wait(data.duration)
            cb(true)
        end
    end
end

function Bridge.Client.GetPlayerJob()
    local playerData = Bridge.Client.GetPlayerData()
    
    if Bridge.Framework == 'qb-core' or Bridge.Framework == 'qbox' then
        return playerData.job and playerData.job.name or 'unemployed'
    elseif Bridge.Framework == 'esx' then
        return playerData.job and playerData.job.name or 'unemployed'
    elseif Bridge.Framework == 'ox' then
        return playerData.job or 'unemployed'
    else
        return 'unemployed'
    end
end
