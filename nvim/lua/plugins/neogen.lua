return {
	"danymat/neogen",
	dependencies = "nvim-treesitter/nvim-treesitter",
	opts = {
		enabled = true,
		languages = {
			cs = {
				template = {
					annotation_convention = "xmldoc",
				},
			},
		},
		snippet_engine = "luasnip",
	},
	keys = {
		{
			"<leader>nc",
			function()
				require("neogen").generate({ type = "class" })
			end,
			desc = "Generate class annotation",
		},
		{
			"<leader>nf",
			function()
				require("neogen").generate({ type = "func" })
			end,
			desc = "Generate function annotation",
		},
		{
			"<leader>nt",
			function()
				require("neogen").generate({ type = "type" })
			end,
			desc = "Generate type annotation",
		},
		{
			"<leader>nF",
			function()
				require("neogen").generate({ type = "file" })
			end,
			desc = "Generate file annotation",
		},
	},
}
