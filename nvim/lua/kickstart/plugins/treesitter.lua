-- nvim-treesitter `master` branch is archived and incompatible with nvim 0.12:
-- its text-extracting directives read `match[id]` as a single TSNode, but in
-- 0.12 that value is a list of nodes (TSNode[]), so `node:range()` is nil and
-- highlighting crashes — most visibly on LSP hover floats (markdown) via `K`.
--
-- We disable nvim-treesitter's own highlight module, use nvim's native
-- highlighter, and re-register the three broken directives in a list-aware way.

local function patch_directives()
	local query = require("vim.treesitter.query")
	-- ensure nvim-treesitter registered its (broken) versions first
	pcall(require, "nvim-treesitter.query_predicates")

	local opts = { force = true, all = false }

	-- match[id] is TSNode[] on nvim 0.12; old code expected a single TSNode.
	local function node_of(match, id)
		local n = match[id]
		if type(n) == "table" then
			return n[#n]
		end
		return n
	end

	local html_script_type_languages = {
		["importmap"] = "json",
		["module"] = "javascript",
		["application/ecmascript"] = "javascript",
		["text/ecmascript"] = "javascript",
	}

	local injection_aliases = {
		ex = "elixir",
		pl = "perl",
		sh = "bash",
		uxn = "uxntal",
		ts = "typescript",
	}

	local function parser_from_info_string(alias)
		local match = vim.filetype.match({ filename = "a." .. alias })
		return match or injection_aliases[alias] or alias
	end

	query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
		local node = node_of(match, pred[2])
		if not node then
			return
		end
		local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
		local configured = html_script_type_languages[type_attr_value]
		if configured then
			metadata["injection.language"] = configured
		else
			local parts = vim.split(type_attr_value, "/", {})
			metadata["injection.language"] = parts[#parts]
		end
	end, opts)

	query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
		local node = node_of(match, pred[2])
		if not node then
			return
		end
		local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
		metadata["injection.language"] = parser_from_info_string(injection_alias)
	end, opts)

	query.add_directive("downcase!", function(match, _, _, pred, metadata)
		local id = pred[2]
		local node = node_of(match, id)
		if not node then
			return
		end
		local text = vim.treesitter.get_node_text(node, 0, { metadata = metadata[id] }) or ""
		if not metadata[id] then
			metadata[id] = {}
		end
		metadata[id].text = string.lower(text)
	end, opts)
end

-- Start native treesitter highlighting on normal file buffers.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(ev)
		pcall(vim.treesitter.start, ev.buf)
	end,
})

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = { "go", "php", "sql", "python", "javascript", "html", "css" },
			auto_install = true,
			highlight = { enable = false },
			indent = { enable = true, disable = { "ruby" } },
		},
		config = function(_, opts)
			require("nvim-treesitter.configs").setup(opts)
			patch_directives()
		end,
	},
}
