-- nvim-treesitter, `main` branch (the 1.0 rewrite). The old `master` branch is
-- archived and explicitly unsupported on nvim 0.12.
--
-- The rewrite has no module system: the plugin only installs parsers + queries.
-- Highlighting comes from nvim itself (`vim.treesitter.start`), indenting from
-- the plugin's `indentexpr()`, and there is no `auto_install` — the FileType
-- autocmd below does that.
--
-- Requires: nvim >= 0.12, plus `tree-sitter` (CLI >= 0.26.1), `curl` and `tar`
-- on $PATH. Parsers install into `stdpath('data')/site`, already on runtimepath.

-- Installed up front; everything else is installed on demand per filetype.
local ensure_installed = {
	"go",
	"php",
	"sql",
	"python",
	"javascript",
	"html",
	"css",
	-- markdown floats (LSP hover via `K`) render through treesitter
	"markdown",
	"markdown_inline",
}

-- treesitter indentation is upstream-experimental; ruby stays excluded as before
local no_indent = { ruby = true }

local function ts_attach(buf, lang)
	if not vim.api.nvim_buf_is_valid(buf) or not pcall(vim.treesitter.start, buf, lang) then
		return
	end
	if not no_indent[lang] then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false, -- the rewrite does not support lazy-loading
		build = ":TSUpdate",
		-- Degrade to "no treesitter" instead of erroring out on an older nvim.
		cond = vim.fn.has("nvim-0.12") == 1,
		config = function()
			local ts = require("nvim-treesitter")
			ts.install(ensure_installed)

			local installed = {}
			for _, lang in ipairs(ts.get_installed("parsers")) do
				installed[lang] = true
			end

			local available
			local function is_available(lang)
				if not available then
					available = {}
					for _, l in ipairs(ts.get_available()) do
						available[l] = true
					end
				end
				return available[lang] == true
			end

			vim.api.nvim_create_autocmd("FileType", {
				desc = "Start treesitter, installing the parser on demand",
				callback = function(ev)
					local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
					if installed[lang] then
						ts_attach(ev.buf, lang)
					elseif is_available(lang) then
						installed[lang] = true -- claim it so repeat events don't queue installs
						ts.install(lang):await(function(err)
							if err then
								installed[lang] = nil
								return
							end
							vim.schedule(function()
								ts_attach(ev.buf, lang)
							end)
						end)
					end
				end,
			})
		end,
	},
}
