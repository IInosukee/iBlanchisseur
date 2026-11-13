fx_version 'cerulean'
game 'gta5'
lua54 'yes'

shared_scripts {
    'Config.lua',
}

server_scripts {
    'server.lua',
}

client_scripts {
    'src/client/RMenu.lua',
    'src/client/menu/RageUI.lua',
    'src/client/menu/Menu.lua',
    'src/client/menu/MenuController.lua',
    'src/client/components/*.lua',
    'src/client/menu/elements/*.lua',
    'src/client/menu/items/*.lua',
    'src/client/menu/panels/*.lua',
    'src/client/menu/windows/*.lua',
    'client.lua',
}
