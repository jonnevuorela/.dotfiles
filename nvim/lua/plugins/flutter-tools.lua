-- lua/plugins/flutter-tools.lua
local M = {}

local function default_on_attach(client, bufnr)
	local wk = vim.keymap
	wk.set("n", "<leader>mr", "<cmd>FlutterRun<cr>", { buffer = bufnr, desc = "Flutter Run" })
	wk.set("n", "<leader>ms", "<cmd>FlutterRestart<cr>", { buffer = bufnr, desc = "Flutter Restart" })
end

local function default_capabilities()
	local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
	if ok and cmp_nvim_lsp and cmp_nvim_lsp.default_capabilities then
		return cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())
	end
	return vim.lsp.protocol.make_client_capabilities()
end

M = {
	"nvim-flutter/flutter-tools.nvim",
	lazy = true,
	ft = { "dart" },
	cmd = { "FlutterRun", "FlutterRestart", "FlutterDevices" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"stevearc/dressing.nvim",
	},
	config = function()
		require("flutter-tools").setup({
			ui = { border = "rounded", notification_style = "native" },
			decorations = { statusline = { app_version = false, device = false, project_config = false } },
			debugger = { enabled = false, exception_breakpoints = {}, evaluate_to_string_in_debug_views = true },
			flutter_lookup_cmd = nil,
			root_patterns = { ".git", "pubspec.yaml" },
			fvm = false,
			widget_guides = { enabled = false },
			closing_tags = { highlight = "ErrorMsg", prefix = ">", priority = 10, enabled = true },
			dev_log = {
				enabled = true,
				filter = nil,
				notify_errors = false,
				open_cmd = "15split",
				focus_on_open = true,
			},
			dev_tools = { autostart = false, auto_open_browser = false },
			outline = { open_cmd = "30vnew", auto_open = false },
			lsp = {
				color = {
					enabled = false,
					background = false,
					background_color = nil,
					foreground = false,
					virtual_text = true,
					virtual_text_str = "■",
				},
				on_attach = default_on_attach,
				capabilities = default_capabilities(),
				settings = {
					showTodos = true,
					completeFunctionCalls = true,
					analysisExcludedFolders = { "<path-to-flutter-sdk-packages>" },
					renameFilesWithClasses = "prompt",
					enableSnippets = true,
					updateImportsOnRename = true,
				},
			},
		})
	end,
}

return M
