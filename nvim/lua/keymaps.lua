vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

--  Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Keep cursor in place when yanking
vim.keymap.set("v", "y", "myy`y")

-- Don't copy new when pasted over words
vim.keymap.set("v", "p", '"_dP')

-- Select all
vim.keymap.set("n", "<C-a>", "ggVG")

-- easy insert end of line character in insert mode
vim.keymap.set("i", ";;", "<Esc>A;")
vim.keymap.set("i", ",,", "<Esc>A,")

--open current file is designed program
vim.keymap.set("n", "<Leader>x", ":!xdg-open %<CR><CR>")

-- Move lines up and down.
vim.keymap.set("i", "<C-A-j>", "<Esc>:move .+1<CR>==gi")
vim.keymap.set("i", "<C-A-k>", "<Esc>:move .-2<CR>==gi")
vim.keymap.set("n", "<C-A-j>", ":move .+1<CR>==")
vim.keymap.set("n", "<C-A-k>", ":move .-2<CR>==")
vim.keymap.set("v", "<C-A-j>", ":move '>+1<CR>gv=gv")
vim.keymap.set("v", "<C-A-k>", ":move '<-2<CR>gv=gv")

-- [[ Basic Autocommands ]]

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
