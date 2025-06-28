fx_version 'cerulean'
game 'gta5'

author 'Maji'
description 'Smash and Grab - Vehicle item stealing system'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'bridge/init.lua',
    'bridge/client.lua',
    'client/*.lua'
}

server_scripts {
    'bridge/init.lua',
    'bridge/server.lua',
    'server/*.lua'
}

dependencies {
    'ox_target',
    'ox_lib'
}

lua54 'yes'
