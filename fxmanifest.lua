fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Dein Name'
description 'Verbessertes Waffen-Feedback und Hitbox-Skript'
version '1.0.0'

shared_script 'config.lua'
shared_script '@ox_lib/init.lua'

client_scripts {
    'client.lua'
}

server_scripts {
    '@es_extended/locale.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_inventory'
}
