-- lua/plugins/vue.lua
-- Stable Vue.js support using ONLY vtsls + @vue/typescript-plugin
-- (Eliminates the vue_ls race condition and "Could not find ..." error)
-- Recommended as of February 2026 (Volar 3.x + nvim-lspconfig)

local M = {}

local function get_vue_language_server_path()
	-- Primary: standard Mason location
	local std_path = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
	if vim.fn.isdirectory(std_path) == 1 then
		return std_path
	end

	-- Fallback: dynamic registry
	local ok, registry = pcall(require, "mason-registry")
	if ok then
		local pkg = registry.get_package("vue-language-server")
		if pkg and pkg:is_installed() then
			return pkg:get_install_path() .. "/node_modules/@vue/language-server"
		end
	end

	return std_path
end

local vue_language_server_path = get_vue_language_server_path()

local tsserver_filetypes = {
	"typescript",
	"javascript",
	"javascriptreact",
	"typescriptreact",
	"vue",
}

local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "vue" },
	configNamespace = "typescript",
}

M.vtsls = {
	filetypes = tsserver_filetypes,
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = { vue_plugin },
			},
		},
	},
}

return M
