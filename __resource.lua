resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX TabacJob'


client_scripts {
  '@es_extended/locale.lua',
  'locales/fr.lua',
  'config.lua',
  'client/main.lua',
}

server_scripts {
  'config.lua',
  '@es_extended/locale.lua',
  '@mysql-async/lib/MySQL.lua',
  'locales/fr.lua',
  'server/main.lua'
}
