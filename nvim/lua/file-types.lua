-- add custom extensions here for custom file extension highlighting
vim.filetype.add({
	extension = {
		neon = "yaml",
		sqlfluff = "ini",
		conf = "ini",
	},
	pattern = {
		["%.env$"] = "sh",        -- matches exactly .env
		["%.env%..*"] = "sh",      -- matches .env.test, .env.local, etc.
		["%.env_.*"] = "sh",       -- matches .env_test, .env_tesdf, etc.
	},
})
