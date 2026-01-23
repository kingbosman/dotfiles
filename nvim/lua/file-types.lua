vim.filetype.add({
	extension = {
		neon = "yaml",
		sqlfluff = "ini",
		conf = "ini",
	},
	-- Use 'filename' for exact matches
	filename = {
		[".zshrc"] = "sh",
		[".bashrc"] = "sh",
		[".env"] = "sh",
	},
	-- Use 'pattern' for things with suffixes or wildcards
	pattern = {
		["%.env%..*"] = "sh",
		["%.env_.*"] = "sh",
		["%.bashrc.*"] = "sh",
		["%.zshrc.*"] = "sh",
	},
})
