fx_version 'adamant'

games { 'gta5' }

client_scripts {
	'client/cl_*.lua',
}

server_scripts {
	'server/sv_*.js',
	'server/sv_*.lua',
	'server/classes/*.lua',
}

shared_scripts {
	'config.lua',
}

files {
	'html/assets/*.js', 
	'html/assets/*.css', 
	'html/assets/*.eot', 
	'html/assets/*.ttf', 
	'html/assets/*.woff', 
	'html/assets/*.woff2', 
	'html/index.html'
}

ui_page "html/index.html"

lua54 'yes' 
