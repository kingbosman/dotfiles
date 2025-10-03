-- lazy.nvim configuration
return {
	"nvimdev/indentmini.nvim",
	config = function()
		vim.cmd.highlight("IndentLine guifg=#565147")
		vim.cmd.highlight("IndentLineCurrent guifg=#d3c6aa")

		require("indentmini").setup({
			char = "▏", -- Ensure this is a non-empty character
		})
	end,
}
