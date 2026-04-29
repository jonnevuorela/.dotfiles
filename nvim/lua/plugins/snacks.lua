-- Plugin spec for folke/snacks.nvim (for lazy.nvim)
-- Drop this file in: ~/.config/nvim/lua/plugins/snacks.lua

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false, -- load at startup; set true + event/ft if you prefer lazy-loading
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = false },
		explorer = { enabled = false },
		indent = { enabled = true },
		input = { enabled = true },
		image = { enabled = true },
		notifier = { enabled = true, timeout = 3000 },
		picker = { enabled = true },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = true },
		dim = { enabled = true },
		zen = { enabled = true },
		animate = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		styles = { notification = {} },
	},

	-- key mappings: call require("snacks") inside functions to avoid global timing issues
	keys = {
		{
			"<leader>sf",
			function()
				require("snacks").picker.smart()
			end,
			desc = "Smart Find Files",
		},
		{
			"<leader><leader>",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>/",
			function()
				require("snacks").picker.grep_buffers({ layout = "dropdown" })
			end,
			desc = "Grep Current File",
		},
		{
			"<leader>:",
			function()
				require("snacks").picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>N",
			function()
				require("snacks").picker.notifications()
			end,
			desc = "Notification History",
		},

		{
			"<leader>fb",
			function()
				require("snacks").picker.buffers()
			end,
			desc = "Buffers",
		},
		{
			"<leader>fn",
			function()
				require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "Find Config File",
		},
		{
			"<leader>ff",
			function()
				require("snacks").picker.files()
			end,
			desc = "Find Files",
		},
		{
			"<leader>,",
			function()
				require("snacks").picker.files()
			end,
			desc = "Search Files",
		},

		{
			"<leader>fg",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>fp",
			function()
				require("snacks").picker.projects()
			end,
			desc = "Projects",
		},
		{
			"<leader>fr",
			function()
				require("snacks").picker.recent()
			end,
			desc = "Recent",
		},

		{
			"<leader>sb",
			function()
				require("snacks").picker.lines()
			end,
			desc = "Buffer Lines",
		},
		{
			"<leader>sB",
			function()
				require("snacks").picker.grep_buffers()
			end,
			desc = "Grep Open Buffers",
		},
		{
			"<leader>sg",
			function()
				require("snacks").picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>sw",
			function()
				require("snacks").picker.grep_word()
			end,
			mode = { "n", "x" },
			desc = "Grep Word/Selection",
		},

		{
			'<leader>s"',
			function()
				require("snacks").picker.registers()
			end,
			desc = "Registers",
		},
		{
			"<leader>s/",
			function()
				require("snacks").picker.search_history()
			end,
			desc = "Search History",
		},
		{
			"<leader>sa",
			function()
				require("snacks").picker.autocmds()
			end,
			desc = "Autocmds",
		},
		{
			"<leader>sc",
			function()
				require("snacks").picker.command_history()
			end,
			desc = "Command History",
		},
		{
			"<leader>sC",
			function()
				require("snacks").picker.commands()
			end,
			desc = "Commands",
		},
		{
			"<leader>sd",
			function()
				require("snacks").picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>sD",
			function()
				require("snacks").picker.diagnostics_buffer()
			end,
			desc = "Buffer Diagnostics",
		},

		{
			"<leader>sh",
			function()
				require("snacks").picker.help()
			end,
			desc = "Help Pages",
		},
		{
			"<leader>sH",
			function()
				require("snacks").picker.highlights()
			end,
			desc = "Highlights",
		},
		{
			"<leader>si",
			function()
				require("snacks").picker.icons()
			end,
			desc = "Icons",
		},
		{
			"<leader>sj",
			function()
				require("snacks").picker.jumps()
			end,
			desc = "Jumps",
		},
		{
			"<leader>sk",
			function()
				require("snacks").picker.keymaps()
			end,
			desc = "Keymaps",
		},
		{
			"<leader>sl",
			function()
				require("snacks").picker.loclist()
			end,
			desc = "Location List",
		},
		{
			"<leader>sm",
			function()
				require("snacks").picker.marks()
			end,
			desc = "Marks",
		},
		{
			"<leader>sM",
			function()
				require("snacks").picker.man()
			end,
			desc = "Man Pages",
		},

		{
			"<leader>sp",
			function()
				require("snacks").picker.lazy()
			end,
			desc = "Search for Plugin Spec",
		},
		{
			"<leader>sq",
			function()
				require("snacks").picker.qflist()
			end,
			desc = "Quickfix List",
		},
		{
			"<leader>sR",
			function()
				require("snacks").picker.resume()
			end,
			desc = "Resume",
		},
		{
			"<leader>su",
			function()
				require("snacks").picker.undo()
			end,
			desc = "Undo History",
		},
		-- Colorscheme picker moved to persistent toggle mapping in init

		-- LSP-ish helpers via Snacks
		{
			"gd",
			function()
				require("snacks").picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"gD",
			function()
				require("snacks").picker.lsp_declarations()
			end,
			desc = "Goto Declaration",
		},
		{
			"gr",
			function()
				require("snacks").picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"gI",
			function()
				require("snacks").picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				require("snacks").picker.lsp_type_definitions()
			end,
			desc = "Goto Type Def",
		},
		{
			"gai",
			function()
				require("snacks").picker.lsp_incoming_calls()
			end,
			desc = "LSP Incoming Calls",
		},
		{
			"gao",
			function()
				require("snacks").picker.lsp_outgoing_calls()
			end,
			desc = "LSP Outgoing Calls",
		},
		{
			"<leader>ss",
			function()
				require("snacks").picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader>sS",
			function()
				require("snacks").picker.lsp_workspace_symbols()
			end,
			desc = "LSP Workspace Symbols",
		},

		-- Other helpers
		{
			"<leader>z",
			function()
				require("snacks").zen()
			end,
			desc = "Toggle Zen Mode",
		},
		{
			"<leader>Z",
			function()
				require("snacks").zen.zoom()
			end,
			desc = "Zoom Zen",
		},
		{
			"<leader>.",
			function()
				require("snacks").scratch()
			end,
			desc = "Toggle Scratch Buffer",
		},
		{
			"<leader>S",
			function()
				require("snacks").scratch.select()
			end,
			desc = "Select Scratch Buffer",
		},
		{
			"<leader>n",
			function()
				require("snacks").notifier.show_history()
			end,
			desc = "Notification History",
		},
		{
			"<leader>un",
			function()
				require("snacks").notifier.hide()
			end,
			desc = "Dismiss Notifications",
		},
		{
			"<c-/>",
			function()
				require("snacks").terminal()
			end,
			desc = "Toggle Terminal",
		},
		{
			"<c-_>",
			function()
				require("snacks").terminal()
			end,
			desc = "which_key_ignore",
		},

		{
			"]]",
			function()
				require("snacks").words.jump(vim.v.count1)
			end,
			mode = { "n", "t" },
			desc = "Next Reference",
		},
		{
			"[[",
			function()
				require("snacks").words.jump(-vim.v.count1)
			end,
			mode = { "n", "t" },
			desc = "Prev Reference",
		},
	},

	-- init: schedule runtime require inside VeryLazy user event so plugin-internal toggles are mapped after startup
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "VeryLazy",
			callback = function()
				local s = require("snacks")
				local defaults_io = require("config.defaults")
				local defaults = { state = defaults_io.ensure() }

				-- runtime debug helpers
				_G.dd = function(...)
					s.debug.inspect(...)
				end
				_G.bt = function()
					s.debug.backtrace()
				end

				if vim.fn.has("nvim-0.11") == 1 then
					vim._print = function(_, ...)
						dd(...)
					end
				else
					vim.print = _G.dd
				end

				-- toggles mapped at runtime
				s.toggle
					.option("spell", { name = "Spelling", global = true })
					:map("<leader>us", { desc = "Toggle Spelling (persist)" })
				s.toggle
					.option("wrap", { name = "Wrap", global = true })
					:map("<leader>uw", { desc = "Toggle Wrap (persist)" })
				vim.keymap.set("n", "<leader>uL", function()
					local next_state = not defaults.state.relativenumber
					defaults.state.relativenumber = next_state
					vim.opt.relativenumber = next_state
					defaults_io.save(defaults.state, "relativenumber", next_state)
					defaults_io.refresh_windows(defaults.state)
				end, { desc = "Toggle Relative Number (persist)" })
				s.toggle.diagnostics():map("<leader>uE", { desc = "Toggle Diagnostics (persist)" })
				vim.keymap.set("n", "<leader>ul", function()
					local next_state = not defaults.state.line_number
					defaults.state.line_number = next_state
					vim.opt.number = next_state
					defaults_io.save(defaults.state, "line_number", next_state)
					defaults_io.refresh_windows(defaults.state)
				end, { desc = "Toggle Line Numbers (persist)" })
				local conceal_on = defaults.state.conceallevel or (vim.o.conceallevel > 0 and vim.o.conceallevel or 2)
				s.toggle
					.option("conceallevel", { off = 0, on = conceal_on, global = true })
					:map("<leader>uo", { desc = "Toggle Conceal (persist)" })
				s.toggle.treesitter():map("<leader>uT", { desc = "Toggle Treesitter (persist)" })
				s.toggle
					.option("background", { off = "light", on = "dark", name = "Dark Background", global = true })
					:map("<leader>ub", { desc = "Toggle Background (persist)" })
				s.toggle.inlay_hints():map("<leader>uh", { desc = "Toggle Inlay Hints (persist)" })
				s.toggle.indent():map("<leader>ug", { desc = "Toggle Indent Guides (persist)" })
				s.toggle.dim():map("<leader>uD", { desc = "Toggle Dim (persist)" })

				s.toggle.words():map("<leader>uM", { desc = "Toggle Words (persist)" })
				s.toggle.zen():map("<leader>uz", { desc = "Toggle Zen (persist)" })
				s.toggle.zoom():map("<leader>uZ", { desc = "Toggle Zoom (persist)" })
				s.toggle.scroll():map("<leader>uS", { desc = "Toggle Smooth Scroll (persist)" })
				s.toggle.animate():map("<leader>uA", { desc = "Toggle Animations (persist)" })
				s.toggle
					.option("cursorline", { name = "Cursorline", global = true })
					:map("<leader>uc", { desc = "Toggle Cursorline (persist)" })
				s.toggle
					.option("list", { name = "Whitespace", global = true })
					:map("<leader>uW", { desc = "Toggle Whitespace (persist)" })
				s.toggle
					.option("signcolumn", { off = "no", on = "yes", name = "Signcolumn", global = true })
					:map("<leader>uI", { desc = "Toggle Signcolumn (persist)" })

				vim.keymap.set("n", "<leader>uC", function()
					require("snacks").picker.colorschemes({
						confirm = function(picker, item)
							picker:close()
							if item then
								picker.preview.state.colorscheme = nil
								vim.schedule(function()
									vim.cmd("colorscheme " .. item.text)
									defaults.state.colorscheme = item.text
									defaults_io.save(defaults.state, "colorscheme", item.text)
								end)
							end
						end,
					})
				end, { desc = "Colorschemes (persist)" })

				local function apply_snacks_state()
					if defaults.state.animate ~= nil then
						vim.g.snacks_animate = defaults.state.animate
					end
					if defaults.state.scroll ~= nil then
						if defaults.state.scroll then
							s.scroll.enable()
						else
							s.scroll.disable()
						end
					end
					if defaults.state.dim ~= nil then
						if defaults.state.dim then
							s.dim.enable()
						else
							s.dim.disable()
						end
					end
					if defaults.state.indent ~= nil then
						if defaults.state.indent then
							s.indent.enable()
						else
							s.indent.disable()
						end
					end
					if defaults.state.words ~= nil then
						if defaults.state.words then
							s.words.enable()
						else
							s.words.disable()
						end
					end
				end

				local function persist_toggle(id, key)
					local toggle = s.toggle.get(id)
					if toggle then
						local original_set = toggle.set
						toggle.set = function(state)
							original_set(state)
							defaults_io.save(defaults.state, key, state)
							defaults_io.refresh_windows(defaults.state)
							apply_snacks_state()
						end
					end
				end

				local function persist_toggle_value(id, key, mapper)
					local toggle = s.toggle.get(id)
					if toggle then
						local original_set = toggle.set
						toggle.set = function(state)
							original_set(state)
							defaults_io.save(defaults.state, key, mapper(state))
							defaults_io.refresh_windows(defaults.state)
							apply_snacks_state()
						end
					end
				end

				persist_toggle("spell", "spell")
				persist_toggle("wrap", "wrap")
				persist_toggle("diagnostics", "diagnostics")
				persist_toggle_value("conceallevel", "conceallevel", function(state)
					return state and conceal_on or 0
				end)
				persist_toggle("treesitter", "treesitter")
				persist_toggle_value("background", "background", function(state)
					return state and "dark" or "light"
				end)
				local function persist_inlay_hints()
					local toggle = s.toggle.get("inlay_hints")
					if toggle then
						local original_set = toggle.set
						toggle.set = function(state)
							original_set(state)
							defaults_io.save(defaults.state, "inlay_hints", state)
						end
					end
				end
				persist_inlay_hints()
				persist_toggle("indent", "indent")
				persist_toggle("dim", "dim")
				persist_toggle("words", "words")
				persist_toggle("zen", "zen")
				persist_toggle("zoom", "zoom")
				persist_toggle("scroll", "scroll")
				persist_toggle("animate", "animate")
				persist_toggle("cursorline", "cursorline")
				persist_toggle("list", "list")
				persist_toggle_value("signcolumn", "signcolumn", function(state)
					return state and "yes" or "no"
				end)

				vim.keymap.set("n", "<leader>ud", function()
					local next_state = not vim.diagnostic.config().virtual_text
					vim.diagnostic.config({ virtual_text = next_state })
					defaults_io.save(defaults.state, "diagnostics_inline", next_state)
				end, { desc = "Toggle Diagnostics Inline (persist)" })

				apply_snacks_state()

				pcall(function()
					require("which-key").add({
						{ "<leader>u", group = "User config" },
					})
				end)
			end,
		})
	end,

	-- config: call setup with opts passed by lazy.nvim
	config = function(_, opts)
		require("snacks").setup(opts)
	end,
}
