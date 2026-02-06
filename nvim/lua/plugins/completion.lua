-- ~/.config/nvim/lua/plugins/completion.lua

return {
	"saghen/blink.cmp",
	version = "*", -- recommended; tracks latest release
	dependencies = {
		"rafamadriz/friendly-snippets", -- optional but highly recommended
	},
	opts = {
		-- Core completion behavior
		keymap = {
			accept = "<CR>",
			select_next = { "<Tab>", "<Down>" },
			select_prev = { "<S-Tab>", "<Up>" },
			scroll_docs_up = "<C-b>",
			scroll_docs_down = "<C-f>",
			show = "<C-Space>",
		},

		-- Enable floating documentation window on selection (this is what you want)
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
			update_events = { "TextChanged", "CursorMoved" },
			window = {
				border = "rounded",
				max_width = 80,
				max_height = 15,
			},
		},

		-- Optional: signature / parameter help
		signature = { enabled = true },

		-- Optional: make LSP resolve items when selected (shows docs faster)
		sources = {
			lsp = {
				name = "LSP",
				enabled = true,
				resolve_on_select = true,
			},
		},

		-- Appearance tweaks (optional)
		appearance = {
			use_nvim_cmp_as_default = false,
			nerd_font_variant = "mono",
		},
	},
}
