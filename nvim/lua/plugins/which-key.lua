return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons" },
	opts = {
		win = {
			height = { min = 8, max = 40 },
		},
		layout = {
			width = { min = 24, max = 80 },
		},
	},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)

		-- Use modern wk.add() API instead of deprecated wk.register()
		wk.add({
			{ "<leader>c", group = "Code" },
			{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code [A]ction", mode = "n" },
		})
	end,
}
