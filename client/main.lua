local vehiclesWithItems = {}
local searchedVehicles = {}
local spawnedModels = {}
local processedVehicles = {}
local protectedVehicles = {}

CreateThread(function()
    Wait(5000)
    
    if GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:notify({
            title = 'Smash & Grab',
            description = 'Script loaded successfully!',
            type = 'success',
            duration = 3000
        })
    end
    
    CleanupLeftoverZones()
    Wait(2000)
    SpawnVehicleItems()
    VehicleCleanupSystem()
end)

function CleanupLeftoverZones()
    if GetResourceState('ox_target') == 'started' then
        for i = 1, 500 do
            for j = 1, 4 do
                local patterns = {
                    'smash_grab_' .. i .. '_driver_door',
                    'smash_grab_' .. i .. '_passenger_door', 
                    'smash_grab_' .. i .. '_rear_left_door',
                    'smash_grab_' .. i .. '_rear_right_door'
                }
                
                for _, pattern in pairs(patterns) do
                    pcall(function()
                        exports.ox_target:removeZone(pattern)
                    end)
                end
            end
        end
    end
end

function GetAvailableSeats(vehicle)
    local seats = {}
    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
    
    table.insert(seats, -1)
    
    if maxSeats >= 1 then
        table.insert(seats, 0)
    end
    
    if maxSeats >= 3 then
        table.insert(seats, 1)
        if maxSeats >= 4 then
            table.insert(seats, 2)
        end
    end
    
    return seats
end

function IsPlayerOwnedVehicle(vehicle)
    if not Config.VehicleItems.OnlyPedVehicles then
        return false
    end
    
    local driver = GetPedInVehicleSeat(vehicle, -1)
    if driver and driver ~= 0 then
        if IsPedAPlayer(driver) then
            return true
        end
        if DoesEntityExist(driver) and not IsPedDeadOrDying(driver, true) then
            return true
        end
    end
    
    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
    for seat = 0, maxSeats do
        local passenger = GetPedInVehicleSeat(vehicle, seat)
        if passenger and passenger ~= 0 then
            if IsPedAPlayer(passenger) then
                return true
            end
            if DoesEntityExist(passenger) and not IsPedDeadOrDying(passenger, true) then
                return true
            end
        end
    end
    
    local vehicleCoords = GetEntityCoords(vehicle)
    local players = GetActivePlayers()
    
    for _, player in pairs(players) do
        local playerPed = GetPlayerPed(player)
        if playerPed and playerPed ~= PlayerPedId() then
            local playerCoords = GetEntityCoords(playerPed)
            if #(vehicleCoords - playerCoords) < 5.0 then
                local playerVehicle = GetVehiclePedIsIn(playerPed, true)
                if playerVehicle == vehicle then
                    return true
                end
            end
        end
    end
    
    local lockStatus = GetVehicleDoorLockStatus(vehicle)
    if lockStatus == 4 then
        return true
    end
    
    return false
end

function GetCurrentZone(coords)
    return GetNameOfZone(coords.x, coords.y, coords.z)
end

function CalculateSpawnChance(vehicle, coords)
    local baseChance = Config.VehicleItems.BaseSpawnChance
    local vehicleModel = GetEntityModel(vehicle)
    local modelName = GetDisplayNameFromVehicleModel(vehicleModel):lower()
    
    local vehicleMultiplier = Config.VehicleSpawnChances[modelName] or 1.0
    local finalChance = baseChance * vehicleMultiplier
    
    return math.min(finalChance, 100)
end

function SelectItemModel()
    local availableModels = {}
    
    for modelType, modelData in pairs(Config.ItemModels) do
        local weight = modelData.spawnChance
        
        for i = 1, math.floor(weight) do
            table.insert(availableModels, modelType)
        end
    end
    
    if #availableModels > 0 then
        return availableModels[math.random(#availableModels)]
    end
    
    for modelType, _ in pairs(Config.ItemModels) do
        return modelType
    end
    
    return nil
end

function SpawnVehicleItems()
    CreateThread(function()
        local debugCount = 0
        while true do
            local playerCoords = GetEntityCoords(PlayerPedId())
            local vehicles = GetGamePool('CVehicle')
            
            debugCount = debugCount + 1
            
            for _, vehicle in pairs(vehicles) do
                local vehicleCoords = GetEntityCoords(vehicle)
                local distance = #(playerCoords - vehicleCoords)
                
                if distance <= Config.VehicleItems.CheckDistance then
                    local vehicleId = vehicle
                    
                    if not processedVehicles[vehicleId] and not searchedVehicles[vehicleId] then
                        local isPlayerOwned = IsPlayerOwnedVehicle(vehicle)
                        

                        
                        if not isPlayerOwned then
                            local vehicleSpeed = GetEntitySpeed(vehicle)
                            local engineRunning = GetIsVehicleEngineRunning(vehicle)
                            

                            
                            if vehicleSpeed < 2.0 then
                                local spawnChance = CalculateSpawnChance(vehicle, vehicleCoords)
                                

                                
                                if math.random(1, 100) <= spawnChance then
                            local selectedModel = SelectItemModel()
                            
                            if selectedModel then
                                local seats = GetAvailableSeats(vehicle)
                                
                                if #seats == 0 then
                                    processedVehicles[vehicleId] = true
                                    return
                                end
                                
                                local randomSeat = seats[math.random(#seats)]
                                
                                vehiclesWithItems[vehicleId] = {
                                    entity = vehicle,
                                    seat = randomSeat,
                                    coords = vehicleCoords,
                                    modelType = selectedModel,
                                    modelData = Config.ItemModels[selectedModel]
                                }
                                
                                processedVehicles[vehicleId] = true
                                
                                SetEntityAsMissionEntity(vehicle, true, true)
                                SetVehicleHasBeenOwnedByPlayer(vehicle, false)
                                protectedVehicles[vehicleId] = true
                                
                                if not spawnedModels[vehicleId] then
                                    spawnedModels[vehicleId] = {}
                                end
                                
                                SpawnItemModel(vehicle, selectedModel, randomSeat)
                                
                                AddVehicleTarget(vehicle, vehicleId)
                            end
                                else
                                    processedVehicles[vehicleId] = true
                                end
                            end
                        else
                            processedVehicles[vehicleId] = true
                        end
                    end
                end
            end
            Wait(5000)
        end
    end)
end

function SpawnItemModel(vehicle, modelType, seat)
    if not DoesEntityExist(vehicle) then 
        return 
    end
    
    local vehicleId = vehicle
    local modelData = Config.ItemModels[modelType]
    if not modelData then 
        return 
    end
    
    if not spawnedModels[vehicleId] then
        spawnedModels[vehicleId] = {}
    end
    
    local boneIndex = GetSeatBoneIndex(seat)
    local bone = GetEntityBoneIndexByName(vehicle, boneIndex)
    
    if bone == -1 then
        local alternativeBones = {
            "seat_dside_f", "seat_pside_f", "seat_dside_r", "seat_pside_r",
            "chassis", "chassis_dummy", "engine", "boot"
        }
        
        for _, altBone in pairs(alternativeBones) do
            bone = GetEntityBoneIndexByName(vehicle, altBone)
            if bone ~= -1 then
                break
            end
        end
        
        if bone == -1 then
            bone = 0
        end
    end
    
    local modelHash = GetHashKey(modelData.model)
    RequestModel(modelHash)
    
    CreateThread(function()
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 30 do
            Wait(100)
            timeout = timeout + 1
        end
        
        if not HasModelLoaded(modelHash) then
            table.insert(spawnedModels[vehicleId], "placeholder_" .. modelType)
            SetModelAsNoLongerNeeded(modelHash)
            return
        end
        
        if not DoesEntityExist(vehicle) then 
            SetModelAsNoLongerNeeded(modelHash)
            return 
        end
        
        local spawnCoords
        if bone ~= 0 then
            spawnCoords = GetWorldPositionOfEntityBone(vehicle, bone)
        else
            spawnCoords = GetEntityCoords(vehicle)
            spawnCoords = vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z + 0.3)
        end
        
        local prop = CreateObject(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false)
        
        if DoesEntityExist(prop) then
            SetEntityAsMissionEntity(prop, true, true)
            SetEntityCollision(prop, false, false)
            FreezeEntityPosition(prop, true)
            SetEntityInvincible(prop, true)
            SetEntityCanBeDamaged(prop, false)
            
            if bone ~= 0 then
                AttachEntityToEntity(prop, vehicle, bone, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            else
                local seatOffsets = {
                    [-1] = {x = -0.4, y = 0.2, z = 0.3},
                    [0] = {x = 0.4, y = 0.2, z = 0.3},
                    [1] = {x = -0.4, y = -0.7, z = 0.3},
                    [2] = {x = 0.4, y = -0.7, z = 0.3}
                }
                local offset = seatOffsets[seat] or seatOffsets[-1]
                AttachEntityToEntity(prop, vehicle, 0, offset.x, offset.y, offset.z, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
            end
            
            table.insert(spawnedModels[vehicleId], prop)
        else
            table.insert(spawnedModels[vehicleId], "placeholder_" .. modelType)
        end
        
        SetModelAsNoLongerNeeded(modelHash)
    end)
end

function GetSeatOffsetsForVehicleClass(vehicleClass, seat)
    local classOffsets = {
        [6] = {
            [-1] = {x = -0.45, y = 0.15, z = 0.25},
        [0] = {x = 0.45, y = 0.15, z = 0.25},
        [1] = {x = -0.45, y = -0.6, z = 0.25},
        [2] = {x = 0.45, y = -0.6, z = 0.25}
        },
        [2] = {
            [-1] = {x = -0.5, y = 0.3, z = 0.4},
            [0] = {x = 0.5, y = 0.3, z = 0.4},
        [1] = {x = -0.5, y = -0.9, z = 0.4},
        [2] = {x = 0.5, y = -0.9, z = 0.4}
        },
        -- Sedans (class 1)
        [1] = {
            [-1] = {x = -0.45, y = 0.2, z = 0.3},  -- Driver
            [0] = {x = 0.45, y = 0.2, z = 0.3},    -- Passenger
            [1] = {x = -0.45, y = -0.8, z = 0.3},  -- Rear left
            [2] = {x = 0.45, y = -0.8, z = 0.3}    -- Rear right
        },
        -- Vans (class 12)
        [12] = {
            [-1] = {x = -0.5, y = 0.8, z = 0.4},   -- Driver (cab forward)
            [0] = {x = 0.5, y = 0.8, z = 0.4},     -- Passenger
            [1] = {x = -0.5, y = -0.5, z = 0.4},   -- Rear left
            [2] = {x = 0.5, y = -0.5, z = 0.4}     -- Rear right
        }
    }
    
    -- Default offsets for unknown vehicle classes
    local defaultOffsets = {
        [-1] = {x = -0.45, y = 0.2, z = 0.3},  -- Driver
        [0] = {x = 0.45, y = 0.2, z = 0.3},    -- Passenger
        [1] = {x = -0.45, y = -0.7, z = 0.3},  -- Rear left
        [2] = {x = 0.45, y = -0.7, z = 0.3}    -- Rear right
    }
    
    local offsets = classOffsets[vehicleClass] or defaultOffsets
    return offsets[seat] or offsets[-1] -- Default to driver if seat not found
end

function CreateStaticProp(modelName, x, y, z, heading, vehicleId, modelType)
    local modelHash = GetHashKey(modelName)
    RequestModel(modelHash)
    
    CreateThread(function()
        local timeout = 0
        while not HasModelLoaded(modelHash) and timeout < 30 do
            Wait(100)
            timeout = timeout + 1
        end
        
        if not HasModelLoaded(modelHash) then
            print("^1[SmashGrab Error]^0 Failed to load model: " .. modelName)
            table.insert(spawnedModels[vehicleId], "placeholder_" .. modelType)
            SetModelAsNoLongerNeeded(modelHash)
            return
        end
        
        local prop = CreateObject(modelHash, x, y, z, false, false, false)
        
        if DoesEntityExist(prop) then
            
            SetEntityAsMissionEntity(prop, true, true)
            SetEntityCollision(prop, false, false)
            FreezeEntityPosition(prop, true)
            SetEntityInvincible(prop, true)
            SetEntityCanBeDamaged(prop, false)
            SetEntityHeading(prop, heading + math.random(-15, 15))
            
            table.insert(spawnedModels[vehicleId], prop)
        else
            print("^1[SmashGrab Error]^0 Failed to create prop object")
            table.insert(spawnedModels[vehicleId], "placeholder_" .. modelType)
        end
        
        SetModelAsNoLongerNeeded(modelHash)
    end)
end

function GetSeatBoneIndex(seat)
    if seat == -1 then -- Driver seat
        return "seat_dside_f"
    elseif seat == 0 then -- Passenger seat
        return "seat_pside_f"
    elseif seat == 1 then -- Rear left
        return "seat_dside_r"
    elseif seat == 2 then -- Rear right
        return "seat_pside_r"
    else
        return "seat_dside_f" -- Default to driver
    end
end

function AddVehicleTarget(vehicle, vehicleId)
    local vehicleData = vehiclesWithItems[vehicleId]
    if not vehicleData then return end
    
    local seat = vehicleData.seat
    local targetOptions = GetTargetOptionsForSeat(seat, vehicle, vehicleId)
    
    if GetResourceState('ox_target') == 'started' then
        local doorPositions = GetDoorTargetPositions(vehicle, seat)
        
        for _, doorPos in pairs(doorPositions) do
            local zoneName = 'smash_grab_' .. vehicleId .. '_' .. doorPos.name
            
            local zoneId = exports.ox_target:addSphereZone({
                coords = doorPos.coords,
                radius = 1.0,
                options = {
                    {
                        name = zoneName,
                        icon = Config.Target.Icon,
                        label = targetOptions.label,
                        onSelect = function()
                            SmashAndGrab(vehicle, vehicleId)
                        end,
                        canInteract = function()
                            return vehiclesWithItems[vehicleId] and vehiclesWithItems[vehicleId] ~= false and DoesEntityExist(vehicle)
                        end
                    }
                }
            })
                        
            if not spawnedModels[vehicleId] then
                spawnedModels[vehicleId] = {}
            end
            table.insert(spawnedModels[vehicleId], {type = "zone", name = zoneName, id = zoneId})
        end
    elseif GetResourceState('qb-target') == 'started' then
        exports['qb-target']:AddTargetEntity(vehicle, {
            options = {
                {
                    type = 'client',
                    action = function()
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local doorPositions = GetDoorTargetPositions(vehicle, seat)
                        local nearCorrectDoor = false
                        
                        for _, doorPos in pairs(doorPositions) do
                            if #(playerCoords - doorPos.coords) <= 2.0 then
                                nearCorrectDoor = true
                                break
                            end
                        end
                        
                        if nearCorrectDoor then
                            SmashAndGrab(vehicle, vehicleId)
                        else
                            FallbackNotify("You need to be near the " .. Config.VehicleSeats[seat] .. " door", 'error')
                        end
                    end,
                    icon = Config.Target.Icon,
                    label = targetOptions.label,
                    canInteract = function()
                        return vehiclesWithItems[vehicleId] and vehiclesWithItems[vehicleId] ~= false
                    end
                }
            },
            distance = Config.Target.Distance
        })
    end
end

function GetDoorTargetPositions(vehicle, seat)
    local positions = {}
    local vehicleCoords = GetEntityCoords(vehicle)
    local vehicleHeading = GetEntityHeading(vehicle)
    
    local rad = math.rad(vehicleHeading)
    local cos = math.cos(rad)
    local sin = math.sin(rad)
    
    if seat == -1 then -- Driver seat
        local offsetX = -1.2 * cos - 0.5 * sin
        local offsetY = -1.2 * sin + 0.5 * cos
        table.insert(positions, {
            coords = vector3(vehicleCoords.x + offsetX, vehicleCoords.y + offsetY, vehicleCoords.z),
            name = "driver_door"
        })
    elseif seat == 0 then -- Passenger seat
        local offsetX = 1.2 * cos - 0.5 * sin
        local offsetY = 1.2 * sin + 0.5 * cos
        table.insert(positions, {
            coords = vector3(vehicleCoords.x + offsetX, vehicleCoords.y + offsetY, vehicleCoords.z),
            name = "passenger_door"
        })
    elseif seat == 1 then -- Rear left
        local offsetX = -1.2 * cos + 1.0 * sin
        local offsetY = -1.2 * sin - 1.0 * cos
        table.insert(positions, {
            coords = vector3(vehicleCoords.x + offsetX, vehicleCoords.y + offsetY, vehicleCoords.z),
            name = "rear_left_door"
        })
    elseif seat == 2 then -- Rear right
        local offsetX = 1.2 * cos + 1.0 * sin
        local offsetY = 1.2 * sin - 1.0 * cos
        table.insert(positions, {
            coords = vector3(vehicleCoords.x + offsetX, vehicleCoords.y + offsetY, vehicleCoords.z),
            name = "rear_right_door"
        })
    end
    
    return positions
end

function GetTargetOptionsForSeat(seat, vehicle, vehicleId)
    local seatName = Config.VehicleSeats[seat] or "Unknown Seat"
    local label = "Smash " .. seatName .. " Window"
    
    return {
        label = label,
        seat = seat
    }
end

function FallbackNotify(message, type)
    local notified = false
    
    if GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:notify({
            title = 'Smash & Grab',
            description = message,
            type = type or 'info',
            duration = 5000
        })
        notified = true
    end
    
    if not notified and Bridge and Bridge.Client and Bridge.Client.Notify then
        Bridge.Client.Notify(message, type)
        notified = true
    end
    
    if not notified then
        print("^3[SmashGrab]^0 " .. message)
    end
end

function SmashAndGrab(vehicle, vehicleId)
    local playerPed = PlayerPedId()
    local vehicleData = vehiclesWithItems[vehicleId]
    
    if not vehicleData or vehicleData == false then
        FallbackNotify(Config.Notifications.Nothing, 'error')
        return
    end
    
    if searchedVehicles[vehicleId] then
        FallbackNotify(Config.Notifications.AlreadySearched, 'error')
        return
    end
    
    local playerCoords = GetEntityCoords(playerPed)
    local vehicleCoords = GetEntityCoords(vehicle)
    
    if #(playerCoords - vehicleCoords) > Config.Target.Distance then
        FallbackNotify(Config.Notifications.TooFar, 'error')
        return
    end
    
    local seat = vehicleData.seat
    local windowIndex = 0
    
    if seat == -1 then -- Driver
        windowIndex = 0
    elseif seat == 0 then -- Passenger
        windowIndex = 1
    elseif seat == 1 then -- Rear left
        windowIndex = 2
    elseif seat == 2 then -- Rear right
        windowIndex = 3
    end
    
    SmashVehicleWindow(vehicle, windowIndex)
    
    local progressData = {
        duration = Config.ProgressBar.Duration,
        label = Config.ProgressBar.Label,
        useWhileDead = Config.ProgressBar.useWhileDead,
        canCancel = Config.ProgressBar.canCancel,
        disable = Config.ProgressBar.disable,
        anim = Config.ProgressBar.anim
    }
    
    if progressData.anim and progressData.anim.dict and progressData.anim.clip then
        RequestAnimDict(progressData.anim.dict)
        while not HasAnimDictLoaded(progressData.anim.dict) do
            Wait(10)
        end
        TaskPlayAnim(playerPed, progressData.anim.dict, progressData.anim.clip, 8.0, -8.0, -1, 1, 0, false, false, false)
    end
    
    if GetResourceState('ox_lib') == 'started' then
        local success = exports.ox_lib:progressBar({
            duration = progressData.duration,
            label = progressData.label,
            useWhileDead = progressData.useWhileDead or false,
            canCancel = progressData.canCancel or true,
            disable = progressData.disable or {},
            anim = progressData.anim,
        })
        
        ClearPedTasks(playerPed)
        
        if success then
            local newPlayerCoords = GetEntityCoords(playerPed)
            local newVehicleCoords = GetEntityCoords(vehicle)
            
            if #(newPlayerCoords - newVehicleCoords) > Config.Target.Distance then
                FallbackNotify(Config.Notifications.TooFar, 'error')
                return
            end
            
            searchedVehicles[vehicleId] = true
            vehiclesWithItems[vehicleId] = false
            
            RemoveVehicleTarget(vehicle, vehicleId)
            
            RemoveSpawnedModels(vehicleId)
            
            TriggerServerEvent('smashgrab:server:reward', vehicleId, vehicleCoords, vehicleData.modelType)
            
        else
            FallbackNotify(Config.Notifications.Cancelled, 'error')
        end
    elseif Bridge and Bridge.Client and Bridge.Client.ProgressBar then
        Bridge.Client.ProgressBar(progressData, function(success)
            ClearPedTasks(playerPed)
            
            if success then
                local newPlayerCoords = GetEntityCoords(playerPed)
                local newVehicleCoords = GetEntityCoords(vehicle)
                
                if #(newPlayerCoords - newVehicleCoords) > Config.Target.Distance then
                    FallbackNotify(Config.Notifications.TooFar, 'error')
                    return
                end
                
                searchedVehicles[vehicleId] = true
                vehiclesWithItems[vehicleId] = false
                
                RemoveVehicleTarget(vehicle, vehicleId)
                RemoveSpawnedModels(vehicleId)
            
            CleanupVehicleProtection(vehicleId)
                
                TriggerServerEvent('smashgrab:server:reward', vehicleId, vehicleCoords, vehicleData.modelType)
                
            else
                FallbackNotify(Config.Notifications.Cancelled, 'error')
            end
        end)
    else
        Wait(progressData.duration)
        ClearPedTasks(playerPed)
        
        searchedVehicles[vehicleId] = true
        vehiclesWithItems[vehicleId] = false
        
        RemoveVehicleTarget(vehicle, vehicleId)
        RemoveSpawnedModels(vehicleId)
        
        TriggerServerEvent('smashgrab:server:reward', vehicleId, vehicleCoords, vehicleData.modelType)
        
    end
end

function RemoveSpawnedModels(vehicleId)
    if spawnedModels[vehicleId] then
        for _, item in pairs(spawnedModels[vehicleId]) do
            if type(item) == "string" then
            elseif type(item) == "table" and item.type == "zone" then
                if GetResourceState('ox_target') == 'started' then
                    if item.id then
                        exports.ox_target:removeZone(item.id)
                    else
                        exports.ox_target:removeZone(item.name)
                    end
                end
            elseif DoesEntityExist(item) then
                DeleteEntity(item)
            end
        end
        spawnedModels[vehicleId] = nil
    end
end

function RemoveVehicleTarget(vehicle, vehicleId)
    if GetResourceState('qb-target') == 'started' then
        exports['qb-target']:RemoveTargetEntity(vehicle)
    end
end

RegisterNetEvent('smashgrab:client:notify', function(message, type)
    FallbackNotify(message, type)
end)

RegisterNetEvent('smashgrab:client:policeAlert', function(coords, message)
    FallbackNotify('🚨 ' .. (message or 'Vehicle break-in reported'), 'error')
    
    if coords then
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 161)
        SetBlipScale(blip, 1.0)
        SetBlipColour(blip, 1)
        SetBlipAsShortRange(blip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Vehicle Break-in')
        EndTextCommandSetBlipName(blip)
        
        SetTimeout(300000, function()
            RemoveBlip(blip)
        end)
    end
end)

function CleanupVehicleProtection(vehicleId)
    if protectedVehicles[vehicleId] then
        local vehicles = GetGamePool('CVehicle')
        for _, vehicle in pairs(vehicles) do
            if vehicle == vehicleId and DoesEntityExist(vehicle) then
                SetEntityAsMissionEntity(vehicle, false, true)
                SetEntityAsNoLongerNeeded(vehicle)
                break
            end
        end
        protectedVehicles[vehicleId] = nil
    end
end

function VehicleCleanupSystem()
    CreateThread(function()
        while true do
            Wait(30000)
            
            local playerCoords = GetEntityCoords(PlayerPedId())
            local vehiclesToCleanup = {}
            
            for vehicleId, _ in pairs(protectedVehicles) do
                local vehicle = vehicleId
                if DoesEntityExist(vehicle) then
                    local vehicleCoords = GetEntityCoords(vehicle)
                    local distance = #(playerCoords - vehicleCoords)
                    
                    local playersNearby = false
                    local players = GetActivePlayers()
                    
                    for _, player in pairs(players) do
                        local playerPed = GetPlayerPed(player)
                        if playerPed and DoesEntityExist(playerPed) then
                            local otherPlayerCoords = GetEntityCoords(playerPed)
                            if #(vehicleCoords - otherPlayerCoords) <= Config.VehicleItems.CleanupDistance then
                                playersNearby = true
                                break
                            end
                        end
                    end
                    
                    if not playersNearby then
                        table.insert(vehiclesToCleanup, vehicleId)
                    end
                else
                    table.insert(vehiclesToCleanup, vehicleId)
                end
            end
            
            for _, vehicleId in pairs(vehiclesToCleanup) do
                if DoesEntityExist(vehicleId) then
                    SetEntityAsNoLongerNeeded(vehicleId)
                end
                CleanupVehicleProtection(vehicleId)
            end
        end
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for vehicleId, _ in pairs(spawnedModels) do
            RemoveSpawnedModels(vehicleId)
        end
        
        for vehicleId, _ in pairs(protectedVehicles) do
            if DoesEntityExist(vehicleId) then
                SetEntityAsNoLongerNeeded(vehicleId)
            end
            CleanupVehicleProtection(vehicleId)
        end
        
        local vehicles = GetGamePool('CVehicle')
        for _, vehicle in pairs(vehicles) do
            SetEntityAsNoLongerNeeded(vehicle)
            RemoveVehicleTarget(vehicle, vehicle)
        end
    end
end)
