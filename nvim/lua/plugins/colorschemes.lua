return {
	{
		"vague2k/vague.nvim",
		config = function()
			require("vague").setup({})
		end,
	},
	{
		"rose-pine/neovim",
		config = function()
			require("rose-pine").setup({
				{
					Normal = { bg = "#061111" },
					NormalNC = { bg = "#061111" },
				},
				transparency = true,
				palette = {
					moon = {
						base = "#18191a",
					},
				},
			})
		end,
	},
	{ "nyoom-engineering/oxocarbon.nvim" },
	{ "EdenEast/nightfox.nvim" },
	{ "armannikoyan/rusty" },
	{ "ydkulks/cursor-dark.nvim" },
	{ "ryross/ryderbeans" },
	{ "dbb/vim-gummybears-colorscheme" },
}
