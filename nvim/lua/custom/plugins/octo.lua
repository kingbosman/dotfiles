return {
	"pwntester/octo.nvim",
	cmd = "Octo",
	opts = {
		picker = "telescope",
		enable_builtin = true,
	},
	keys = {
		{
			"<leader>oi",
			"<CMD>Octo issue list<CR>",
			desc = "List GitHub Issues",
		},
		{
			"<leader>op",
			"<CMD>Octo pr list<CR>",
			desc = "List GitHub PullRequests",
		},
		{
			"<leader>od",
			"<CMD>Octo discussion list<CR>",
			desc = "List GitHub Discussions",
		},
		{
			"<leader>on",
			"<CMD>Octo notification list<CR>",
			desc = "List GitHub Notifications",
		},
		{
			"<leader>os",
			function()
				require("octo.utils").create_base_search_command { include_current_repo = true }
			end,
			desc = "Search GitHub",
		},
		{
			"<leader>ors",
			"<CMD>Octo review start<CR>",
			desc = "Start Review",
		},
		{
			"<leader>orr",
			"<CMD>Octo review resume<CR>",
			desc = "Resume Review",
		},
		{
			"<leader>oru",
			"<CMD>Octo review submit<CR>",
			desc = "Submit Review",
		},
		{
			"<leader>orc",
			"<CMD>Octo review close<CR>",
			desc = "Close Review",
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
		"nvim-tree/nvim-web-devicons",
	},
}
