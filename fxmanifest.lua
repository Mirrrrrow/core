--[[ FX Information ]]--
fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

--[[ Resource Information ]]--
name         'core'
version      '0.0.0'
description  'Core Resource for San Andreas V'
license      'GNU General Public License v3.0'
author       'mirow'
repository   'https://github.com/Mirrrrrow/core'

--[[ Manifest ]]--
dependencies {
	'/server:6683',
	'/onesync',
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'oxmysql',
    'es_extended'
}

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_script 'init.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'init.lua'
}

files {
    'init.lua',
    'client.lua',
    'modules/**/client.lua',
    'modules/**/shared.lua',
    'data/*.lua',
    'locales/*.json'
}