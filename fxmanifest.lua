name "Jim-Trains"
author "Jimathy"
version "1.5"
description 'Train Script'
fx_version "cerulean"
game "gta5"
lua54 'yes'
use_experimental_fxv2_oal 'yes'

server_script '@oxmysql/lib/MySQL.lua'

shared_scripts {
	'locales/*.lua',
	'config.lua',

    --Jim Bridge - https://github.com/jimathy/jim-bridge
    '@jim_bridge/starter.lua',

	'shared/*.lua',
}
client_scripts {
    'client/*.lua'
}

server_scripts {
    'server.lua'
}

dependency 'jim_bridge'