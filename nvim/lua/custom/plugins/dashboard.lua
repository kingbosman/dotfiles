return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	config = function()
		-- Set up custom highlight group for orange color
		vim.api.nvim_set_hl(0, "DashboardOrange", { fg = "#ff8800" })

		-- Tough guy quotes
		local quotes = {
			{ "I'm tired of these motherf***ing bugs in this motherf***ing code!", "Samuel L. Jackson Energy" },
			{ "Say 'compile error' again. I dare you.", "Pulp Fiction" },
			{ "The first rule of programming is: You do not talk about production.", "Fight Club" },
			{ "Yeah buddy! Light weight!", "Ronnie Coleman" },
			{ "I'll be back... after this merge.", "Terminator" },
			{ "You either die a hero or live long enough to become the senior dev.", "The Dark Knight" },
			{ "I'm gonna make him an offer he can't refuse.", "The Godfather" },
			{ "Go ahead, make my day.", "Dirty Harry" },
			{ "Yippee-ki-yay, motherf***er!", "Die Hard" },
			{ "You want the truth? You can't handle the truth!", "A Few Good Men" },
			{ "I'll do it. For money.", "The Professional" },
			{ "That's what I do. I drink and I know things.", "Tyrion Lannister" },
		}

		-- Get random quote
		math.randomseed(os.time())
		local quote = quotes[math.random(#quotes)]

		-- Truncate text to fit width
		local function truncate(text, max_width)
			if #text <= max_width then
				return text
			end
			return text:sub(1, max_width - 3) .. "..."
		end

		-- Get stats
		local function get_stats()
			local stats = {}

			-- Date and time
			local datetime = os.date("%A, %B %d, %Y  •  %H:%M")
			table.insert(stats, datetime)
			table.insert(stats, "")

			-- Neovim version
			local version = vim.version()
			table.insert(stats, string.format("Neovim v%d.%d.%d", version.major, version.minor, version.patch))

			-- Git branch (if in a git repo)
			local git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
			if git_branch ~= "" then
				table.insert(stats, string.format("Branch: %s", git_branch))
			end

			-- Plugin count
			local lazy_ok, lazy = pcall(require, "lazy")
			if lazy_ok then
				local plugins = lazy.plugins()
				table.insert(stats, string.format("Plugins: %d loaded", #plugins))
			end

			return stats
		end

		-- Build dashboard content
		local function get_dashboard_config()
			local height = vim.fn.winheight(0)
			local width = vim.fn.winwidth(0)

			-- Minimal zen header (footer line width)
			local footer_line_width = 41

			-- ASCII art for KB
			local ascii_art = {
				" ██  ██     ██████  ",
				" ██ ██      ██   ██ ",
				" ████       ██████  ",
				" ██ ██      ██   ██ ",
				" ██  ██     ██████  ",
			}

			-- Calculate centering for ASCII art
			local ascii_width = vim.fn.strdisplaywidth(ascii_art[1])
			local total_width = footer_line_width + 8
			local ascii_padding_left = math.floor((total_width - ascii_width) / 2)

			local header_art = {
				"",
				"",
			}

			-- Add ASCII art lines centered
			for _, line in ipairs(ascii_art) do
				table.insert(header_art, string.rep(" ", ascii_padding_left) .. line)
			end

			table.insert(header_art, "        " .. string.rep("─", footer_line_width))
			table.insert(header_art, "")

			-- Build header (title box at top)
			local header = {}

			-- Top margin (small)
			local top_margin = math.max(1, math.floor(height * 0.05))
			for i = 1, top_margin do
				table.insert(header, "")
			end

			-- Add header art
			for _, line in ipairs(header_art) do
				table.insert(header, line)
			end

			-- Get stats for calculation
			local stats = get_stats()

			-- Find the longest stat line
			local max_width = 0
			for _, stat in ipairs(stats) do
				if stat ~= "" then
					local stat_width = vim.fn.strdisplaywidth(stat)
					if stat_width > max_width then
						max_width = stat_width
					end
				end
			end

			-- Calculate vertical spacing to center stats
			local header_art_height = #header_art
			local stats_height = #stats
			local footer_height = 5 -- quote + author + 2 spacing + separator
			local content_height = header_art_height + stats_height + footer_height
			local available_space = height - content_height
			local stats_top_margin = math.max(2, math.floor(available_space / 2))
			local stats_bottom_margin = math.max(2, available_space - stats_top_margin)

			-- Add top margin before stats
			for i = 1, stats_top_margin do
				table.insert(header, "")
			end

			-- Center the block based on longest line (match footer line width)
			local block_padding = math.floor((footer_line_width - max_width) / 2)

			-- Add stats
			for _, stat in ipairs(stats) do
				if stat == "" then
					table.insert(header, "")
				else
					table.insert(header, "        " .. string.rep(" ", block_padding) .. stat)
				end
			end

			-- Add bottom margin after stats
			for i = 1, stats_bottom_margin do
				table.insert(header, "")
			end

			-- Empty center (no shortcuts)
			local center = {}

			-- Quote section (no box) - match footer line width
			local quote_max_width = footer_line_width

			-- Prepare quote text with truncation
			local quote_text = '"' .. truncate(quote[1], quote_max_width) .. '"'
			local author_text = "- " .. truncate(quote[2], quote_max_width) -- Use simple dash

			-- Center each line within the width
			local quote_display_width = vim.fn.strdisplaywidth(quote_text)
			local author_display_width = vim.fn.strdisplaywidth(author_text)

			local quote_padding = math.floor((quote_max_width - quote_display_width) / 2)
			local author_padding = math.floor((quote_max_width - author_display_width) / 2)

			local quote_line = "        " .. string.rep(" ", quote_padding) .. quote_text
			local author_line = "        " .. string.rep(" ", author_padding) .. author_text

			-- Footer content (quote at the bottom)
			local footer_content = {
				"",
				quote_line,
				author_line,
				"",
				"        " .. string.rep("─", footer_line_width),
			}

			-- Calculate remaining space to push footer to bottom
			local content_height = #header + #footer_content
			local bottom_padding = math.max(0, height - content_height - 1)

			local footer = {}
			for i = 1, bottom_padding do
				table.insert(footer, "")
			end
			for _, line in ipairs(footer_content) do
				table.insert(footer, line)
			end

			return header, footer, center
		end

		local header, footer, center = get_dashboard_config()

		require("dashboard").setup({
			theme = "doom",
			config = {
				header = header,
				center = center,
				footer = footer,
			},
			hide = {
				statusline = true,
				tabline = true,
				winbar = true,
			},
		})

		-- Apply orange color to title and footer
		vim.api.nvim_create_autocmd("FileType", {
			pattern = "dashboard",
			callback = function()
				-- Match ASCII art blocks and separator lines
				vim.fn.matchadd("DashboardOrange", "██")
				vim.fn.matchadd("DashboardOrange", "^\\s*─\\+$")
			end,
		})
	end,
	dependencies = { { "nvim-tree/nvim-web-devicons" } },
}
