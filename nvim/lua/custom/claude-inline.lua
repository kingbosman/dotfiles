-- Inline Claude Code as an async filter over the current visual selection.
--
-- Visual mode + <leader>ai:
--   * comment selected -> prompt prefilled with "implement this"
--   * code selected    -> prompt prefilled with "refactor this"
--
-- Runs `claude -p` in a fresh session (no conversation state is kept), so the
-- only project context is CLAUDE.md, discovered upwards from the file's own
-- directory rather than from nvim's cwd.

local M = {}

local ns = vim.api.nvim_create_namespace("claude_inline")

-- Region highlight for the range being worked on. `default = true` so a
-- colorscheme or a later override wins over this.
vim.api.nvim_set_hl(0, "ClaudeInlineRunning", { link = "Visual", default = true })

-- bufnr -> { handle = vim.SystemObj }
local running = {}

local BASE_RULES = table.concat({
	"You are an inline code-editing utility embedded in a text editor.",
	"The text on stdin is a region the user selected in a buffer.",
	"Apply the user's instruction to that region.",
	"Output ONLY the raw replacement text for the region.",
	"CRITICAL: never wrap the output in markdown fences (no ```),",
	"never add commentary, explanations, or an introductory sentence.",
	"Preserve the original indentation style (tabs vs spaces) and depth,",
	"since the output is written straight back into the buffer.",
}, " ")

local IMPLEMENT_RULES = table.concat({
	"The selected region is a comment describing intent that has not been written yet.",
	"Keep the comment lines verbatim in your output, then write the implementation",
	"directly below them at the same indentation level.",
}, " ")

-- Last resort when there is neither a parser nor a commentstring.
local GENERIC_PREFIXES = { "//", "#", "--", ";", "/*", "*", "<!--", '"""', "%" }

--- Root node of the buffer's tree, or nil when there is no parser.
--- Deliberately uses the explicit parser API: vim.treesitter.get_node() only
--- resolves once the buffer is attached in a window.
local function tree_root(bufnr)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		return nil
	end
	local ok_parse, trees = pcall(parser.parse, parser, true)
	if not ok_parse or not trees or not trees[1] then
		return nil
	end
	return trees[1]:root()
end

--- Is this line a comment? Returns nil for blank lines (no opinion).
---@param bufnr integer
---@param lnum integer 0-indexed
---@param root TSNode|nil
---@return boolean|nil
local function is_comment_line(bufnr, lnum, root)
	local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1]
	if not line or line:match("^%s*$") then
		return nil
	end

	local col = #line:match("^%s*")
	if root then
		local node = root:named_descendant_for_range(lnum, col, lnum, col)
		while node do
			if node:type():find("comment") then
				return true
			end
			node = node:parent()
		end
		return false
	end

	local trimmed = vim.trim(line)
	local prefix = (vim.bo[bufnr].commentstring or ""):match("^(.-)%s*%%s")
	if prefix and prefix ~= "" then
		return vim.startswith(trimmed, vim.trim(prefix))
	end

	for _, generic in ipairs(GENERIC_PREFIXES) do
		if vim.startswith(trimmed, generic) then
			return true
		end
	end
	return false
end

--- A selection counts as a comment only if every non-blank line is one.
local function selection_is_comment(bufnr, line1, line2)
	local root = tree_root(bufnr)
	local saw_content = false
	for lnum = line1 - 1, line2 - 1 do
		local comment = is_comment_line(bufnr, lnum, root)
		if comment == false then
			return false
		elseif comment == true then
			saw_content = true
		end
	end
	return saw_content
end

--- Drop markdown fences and surrounding blank lines the model may still emit.
local function strip_fences(lines)
	while #lines > 0 and lines[1]:match("^%s*$") do
		table.remove(lines, 1)
	end
	while #lines > 0 and lines[#lines]:match("^%s*$") do
		table.remove(lines)
	end
	if #lines >= 2 and lines[1]:match("^%s*```") and lines[#lines]:match("^%s*```%s*$") then
		table.remove(lines, 1)
		table.remove(lines)
	end
	return lines
end

local function clear_marks(bufnr)
	if vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	end
end

--- Shade the region so it reads as "hands off until this returns".
local function mark_region(bufnr, line1, line2)
	-- Rows are 0-indexed, so end_row = line2 only exists when the selection
	-- stops short of the last line; otherwise clamp to the final line's end.
	local end_row, end_col = line2, 0
	if line2 >= vim.api.nvim_buf_line_count(bufnr) then
		end_row = line2 - 1
		end_col = #(vim.api.nvim_buf_get_lines(bufnr, end_row, end_row + 1, false)[1] or "")
	end
	vim.api.nvim_buf_set_extmark(bufnr, ns, line1 - 1, 0, {
		end_row = end_row,
		end_col = end_col,
		hl_group = "ClaudeInlineRunning",
		hl_eol = true,
	})
end

local function clear_progress(bufnr)
	local job = running[bufnr]
	running[bufnr] = nil
	if job then
		clear_marks(bufnr)
	end
	return job
end

--- Multi-line floating prompt, centered on the editor like FloatermToggle.
--- on_confirm(nil) on cancel, mirroring vim.ui.input's contract.
---@param opts { title: string, default: string }
local function input_float(opts, on_confirm)
	local prompt_buf = vim.api.nvim_create_buf(false, true)
	vim.bo[prompt_buf].bufhidden = "wipe"
	vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { opts.default })

	local win = vim.api.nvim_get_current_win()

	-- Centered on the editor rather than anchored to the region: the box is big
	-- enough now that anchoring put it half off-screen. Deliberately smaller than
	-- floaterm's 0.8 — wide enough for a paragraph, not a whole second editor.
	local width = math.min(math.max(64, math.floor(vim.o.columns * 0.6)), math.max(20, vim.o.columns - 8))
	local height = math.min(8, math.max(3, vim.o.lines - 8))
	local row = math.max(0, math.floor((vim.o.lines - height) / 2) - 2)
	local col = math.max(0, math.floor((vim.o.columns - width) / 2))

	local prompt_win = vim.api.nvim_open_win(prompt_buf, true, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " " .. opts.title .. " ",
		title_pos = "center",
		footer = " <C-s> send  ·  <CR> newline  ·  <C-c> cancel ",
		footer_pos = "center",
	})
	-- Soft-wrap so a long instruction stays visible instead of scrolling sideways.
	vim.wo[prompt_win].wrap = true
	vim.wo[prompt_win].linebreak = true
	vim.wo[prompt_win].winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder"

	local finished = false
	local function finish(text)
		if finished then
			return
		end
		finished = true
		if vim.api.nvim_win_is_valid(prompt_win) then
			vim.api.nvim_win_close(prompt_win, true)
		end
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_current_win(win)
		end
		on_confirm(text)
	end

	local function submit()
		local lines = vim.api.nvim_buf_get_lines(prompt_buf, 0, -1, false)
		-- Keep the line structure: paragraphs and bullet lists survive into the prompt.
		finish(vim.trim(table.concat(lines, "\n")))
	end

	local map = function(modes, lhs, fn)
		vim.keymap.set(modes, lhs, fn, { buffer = prompt_buf, nowait = true })
	end
	-- <CR> has to stay a newline now the box is multi-line, so send moves to <C-s>.
	map({ "i", "n" }, "<C-s>", function()
		vim.cmd("stopinsert")
		submit()
	end)
	map("n", "<CR>", submit)
	map({ "i", "n" }, "<C-c>", function()
		vim.cmd("stopinsert")
		finish(nil)
	end)
	map("n", "<Esc>", function()
		finish(nil)
	end)
	map("n", "q", function()
		finish(nil)
	end)

	-- Clicking or jumping away is a cancel, not a silent orphan window.
	vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
		buffer = prompt_buf,
		once = true,
		callback = function()
			vim.schedule(function()
				finish(nil)
			end)
		end,
	})

	-- Open ready to type, cursor after the prefilled text.
	vim.api.nvim_win_set_cursor(prompt_win, { 1, #opts.default })
	vim.cmd("startinsert!")
end

local function run(bufnr, line1, line2, instruction, is_comment)
	local lines = vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
	local system_prompt = is_comment and (BASE_RULES .. " " .. IMPLEMENT_RULES) or BASE_RULES

	local path = vim.api.nvim_buf_get_name(bufnr)
	local cwd = (path ~= "" and vim.uv.fs_stat(path)) and vim.fs.dirname(path) or vim.uv.cwd()

	local prompt = instruction
	if path ~= "" then
		prompt = prompt .. "\n\n(The region comes from " .. vim.fn.fnamemodify(path, ":t") .. ".)"
	end

	-- Anything written between now and the response would land in the wrong
	-- place, so refuse to write back if the buffer moved on.
	local tick = vim.api.nvim_buf_get_changedtick(bufnr)

	vim.api.nvim_buf_set_extmark(bufnr, ns, line1 - 1, 0, {
		virt_text = { { "  claude…", "Comment" } },
		virt_text_pos = "eol",
	})

	local handle = vim.system({
		"claude",
		"-p",
		prompt,
		"--append-system-prompt",
		system_prompt,
		-- Read-only tools: enough to pull its own context, never to edit files.
		"--allowedTools",
		"Read,Grep,Glob",
	}, {
		cwd = cwd,
		stdin = table.concat(lines, "\n") .. "\n",
		text = true,
	}, function(result)
		vim.schedule(function()
			local job = clear_progress(bufnr)
			if not job then
				return -- cancelled
			end

			if not vim.api.nvim_buf_is_valid(bufnr) then
				return
			end

			if result.code ~= 0 then
				local err = vim.trim(result.stderr or "")
				vim.notify(
					"claude exited with " .. result.code .. (err ~= "" and (": " .. err) or ""),
					vim.log.levels.ERROR
				)
				return
			end

			local out = strip_fences(vim.split(vim.trim(result.stdout or ""), "\n", { plain = true }))
			if #out == 0 or (#out == 1 and out[1] == "") then
				vim.notify("claude returned nothing, buffer left untouched", vim.log.levels.WARN)
				return
			end

			if vim.api.nvim_buf_get_changedtick(bufnr) ~= tick then
				vim.notify("buffer changed while claude was running, discarding result", vim.log.levels.WARN)
				return
			end

			if line2 > vim.api.nvim_buf_line_count(bufnr) then
				vim.notify("selection no longer exists, discarding result", vim.log.levels.WARN)
				return
			end

			vim.api.nvim_buf_set_lines(bufnr, line1 - 1, line2, false, out)
		end)
	end)

	running[bufnr] = { handle = handle }
end

function M.pipe(opts)
	local bufnr = vim.api.nvim_get_current_buf()
	if running[bufnr] then
		vim.notify("claude is already running for this buffer", vim.log.levels.WARN)
		return
	end

	local line1, line2 = opts.line1, opts.line2
	local is_comment = selection_is_comment(bufnr, line1, line2)

	-- Show the region straight away: the visual selection is already gone by
	-- the time the command runs, so this is what you are about to hand over.
	mark_region(bufnr, line1, line2)

	input_float({
		title = is_comment and "Claude · implement" or "Claude · refactor",
		default = is_comment and "implement this" or "refactor this",
	}, function(input)
		if not input or input == "" then
			clear_marks(bufnr)
			return
		end
		run(bufnr, line1, line2, input, is_comment)
	end)
end

function M.cancel()
	local bufnr = vim.api.nvim_get_current_buf()
	local job = clear_progress(bufnr)
	if not job then
		vim.notify("no claude job running for this buffer", vim.log.levels.INFO)
		return
	end
	job.handle:kill("sigterm")
	vim.notify("claude cancelled", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("ClaudeInline", M.pipe, {
	range = true,
	desc = "Pipe the selected range through claude -p",
})

vim.api.nvim_create_user_command("ClaudeInlineCancel", M.cancel, {
	desc = "Cancel the running claude job for this buffer",
})

vim.keymap.set("x", "<leader>ai", ":ClaudeInline<CR>", {
	desc = "[A]I [i]nline edit selection with Claude",
})

return M
