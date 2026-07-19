return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.config").setup({})
	end,
}

-- Run :TSInstall all once to install all parsers+queries.
-- Thereafter :TSUpdate (build step) keeps them updated.
