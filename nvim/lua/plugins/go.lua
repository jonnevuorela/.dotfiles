M = {
	"ray-x/go.nvim",
	dependencies = { -- optional packages
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		-- { "nvim-treesitter/nvim-treesitter", branch = 'main' } -- optional for master version
	},
	opts = {
		-- lsp_keymaps = false,
		-- other options
	},
	event = { "CmdlineEnter" },
	ft = { "go", "gomod" },
	build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}

return M
