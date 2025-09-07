fx_version 'cerulean'
game 'gta5'
author 'tommy'
description 'Emergency Alert System'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/alert.mp3'
}

shared_script 'config.lua'

client_scripts {
    '@ox_lib/init.lua',
    'client.lua'
}

server_scripts {
    '@ox_lib/init.lua',
    'server.lua'
}

lua54 'yes'
dependency 'ox_lib'
