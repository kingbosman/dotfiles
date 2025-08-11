return {
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters.sqlfluff = {
				cmd = "sqlfluff",
				stdin = false,
				args = {
					"lint",
					"--dialect",
					"mysql", -- or change to postgres, ansi, etc.
					"--format",
					"json",
					function()
						return vim.api.nvim_buf_get_name(0)
					end,
				},
				parser = function(output, _)
					local diagnostics = {}
					local ok, decoded = pcall(vim.json.decode, output)
					if not ok or type(decoded) ~= "table" then
						return diagnostics
					end

					for _, file in ipairs(decoded) do
						for _, violation in ipairs(file.violations or {}) do
							local lnum = tonumber(violation.start_line_no) or 1
							local col = tonumber(violation.start_line_pos) or 1
							local end_lnum = tonumber(violation.end_line_no) or lnum
							local end_col = tonumber(violation.end_line_pos) or col

							table.insert(diagnostics, {
								lnum = lnum - 1, -- Neovim is 0-based
								col = col - 1,
								end_lnum = end_lnum - 1,
								end_col = end_col,
								severity = vim.diagnostic.severity.WARN,
								source = "sqlfluff",
								message = string.format(
									"[%s] %s",
									violation.code or "SQL",
									violation.description or ""
								),
							})
						end
					end

					return diagnostics
				end,
			}

			lint.linters_by_ft = {
				sql = { "sqlfluff" },
			}

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave", "BufEnter" }, {
				group = lint_augroup,
				callback = function()
					if vim.opt_local.modifiable:get() then
						lint.try_lint()
					end
				end,
			})

			vim.api.nvim_create_user_command("LspLint", function()
				lint.try_lint()
			end, { desc = "Trigger Lint" })
		end,
	},
}
