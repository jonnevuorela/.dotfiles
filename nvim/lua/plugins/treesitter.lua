return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		ensure_installed = "all",
		auto_install = true,
		highlight = { enable = true },
		indent = { enable = true },
		ignore_install = { "ipkg" },
	},
	config = function(_, opts)
		-- safe require: if the plugin isn't installed yet this won't error and will let startup continue
		local ok, configs = pcall(require, "nvim-treesitter.configs")
		if not ok or not configs then
			vim.notify("nvim-treesitter not installed yet, skipping setup", vim.log.levels.WARN)
			return
		end
		configs.setup(opts)

		-- prefer git for parser installs if available (won't error if module missing)
		local ok2, install = pcall(require, "nvim-treesitter.install")
		if ok2 and install then
			install.prefer_git = true
		end
	end,
}
