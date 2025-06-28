Bridge = {}

local function DetectFramework()
    if GetResourceState('qbx_core') == 'started' or GetResourceState('qbox') == 'started' then
        return 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb-core'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    elseif GetResourceState('ox_core') == 'started' then
        return 'ox'
    else
        return 'standalone'
    end
end

if Config.Framework == 'auto' then
    Config.Framework = DetectFramework()
end

print('^2[SmashGrab]^0 Detected framework: ^3' .. Config.Framework .. '^0')

if Config.Framework == 'qb-core' then
    local QBCore = exports['qb-core']:GetCoreObject()
    Bridge = QBCore
    Bridge.Framework = 'qb-core'
elseif Config.Framework == 'qbox' then
    Bridge = {}
    Bridge.QBX = exports.qbx_core
    Bridge.Framework = 'qbox'
elseif Config.Framework == 'esx' then
    local ESX = exports['es_extended']:getSharedObject()
    Bridge = ESX
    Bridge.Framework = 'esx'
elseif Config.Framework == 'ox' then
    Bridge = {}
    Bridge.Framework = 'ox'
else
    Bridge = {}
    Bridge.Framework = 'standalone'
end
