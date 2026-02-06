-- Plugin spec for folke/snacks.nvim (for lazy.nvim)
-- Drop this file in: ~/.config/nvim/lua/plugins/snacks.lua

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false, -- load at startup; set true + event/ft if you prefer lazy-loading
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = { enabled = false },
		indent = { enabled = true },
		input = { enabled = true },
		image = { enabled = true },
		notifier = { enabled = true, timeout = 3000 },
		picker = { enabled = true, layout = "telescope" },
		quickfile = { enabled = true },
		scope = { enabled = true },
		scroll = { enabled = false },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		styles = { notification = {} },
		explorer = {
			enabled = true,
			replace_netrw = true, -- (default anyway) makes :Explore / :Sex use Snacks instead of netrw
			-- hidden = false,       -- show dotfiles by default? (or toggle with . key)
			-- layout = { ... },     -- window size/position if you want
		},
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
		{
			"<leader>uC",
			function()
				require("snacks").picker.colorschemes()
			end,
			desc = "Colorschemes",
		},

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
				s.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
				s.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
				s.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
				s.toggle.diagnostics():map("<leader>ud")
				s.toggle.line_number():map("<leader>ul")
				s.toggle
					.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
					:map("<leader>uc")
				s.toggle.treesitter():map("<leader>uT")
				s.toggle
					.option("background", { off = "light", on = "dark", name = "Dark Background" })
					:map("<leader>ub")
				s.toggle.inlay_hints():map("<leader>uh")
				s.toggle.indent():map("<leader>ug")
				s.toggle.dim():map("<leader>uD")
			end,
		})
	end,

	-- config: call setup with opts passed by lazy.nvim
	config = function(_, opts)
		require("snacks").setup(opts)
	end,
}
