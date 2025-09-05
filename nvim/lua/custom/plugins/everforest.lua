return {
	{
		"sainnhe/everforest",
		priority = 1000, -- Load before other start plugins
		config = function()
			-- Theme-specific settings
			vim.g.everforest_background = "hard" -- soft, medium, hard
			vim.g.everforest_enable_italic = true
			vim.g.everforest_disable_italic_comment = false
			vim.g.everforest_ui_contrast = "high" -- low, normal, high
			vim.g.everforest_transparent_background = 0 -- 1 for transparent

			-- Load the colorscheme
			vim.cmd.colorscheme("everforest")
		end,
	},
}
