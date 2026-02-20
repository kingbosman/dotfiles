return {
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			signs = false,
			search = {
				command = "rg",
				args = {
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--glob=!node_modules",
					"--glob=!dist",
					"--glob=!public",
					"--glob=!resources",
					"--glob=!build",
					"--glob=!*.min.js",
				},
			},
		},
	},
}
