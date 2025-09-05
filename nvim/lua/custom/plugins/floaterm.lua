return {
	"voldikss/vim-floaterm",

	config = function()
		vim.g.floaterm_width = 0.8

		vim.g.floaterm_height = 0.8

		vim.keymap.set("n", "<F1>", ":FloatermToggle<CR>")

		vim.keymap.set("t", "<F1>", "<C-\\><C-n>:FloatermToggle<CR>")

		vim.cmd([[
 

      highlight link Floaterm CursorLine
 

      highlight link FloatermBorder CursorLineBg
 

    ]])
	end,
}
