vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync Clipboard between OS and neovim
vim.schedule(function()
	if os.getenv("WAYLAND_DISPLAY") then
		vim.g.clipboard = {
			name = "wayland",
			copy = {
				["+"] = { "wl-copy", "--type", "text/plain" },
				["*"] = { "wl-copy", "--type", "text/plain", "--primary" },
			},
			paste = {
				["+"] = { "wl-paste", "--no-newline" },
				["*"] = { "wl-paste", "--no-newline", "--primary" },
			},
			cache_enabled = 0,
		}
		vim.opt.clipboard = "unnamedplus"
	else
		vim.opt.clipboard = "unnamedplus"
	end
end)

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.fillchars:append({ eob = " " })

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 15

vim.opt.confirm = true
vim.opt.title = true
vim.opt.wildmode = "longest:full,full"
vim.opt.spell = true

vim.opt.backup = true
vim.opt.backupdir:remove(".")

vim.opt.colorcolumn = "80,120"
