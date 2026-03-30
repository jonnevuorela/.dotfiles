-- lua/plugins/vue.lua
-- Vue.js support using vtsls + @vue/typescript-plugin

local M = {}

local function get_vue_plugin_path()
	local vue_language_server_path = vim.fn.stdpath("data")
		.. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
	return vue_language_server_path
end

M.vtsls_config = {
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
	settings = {
		vtsls = {
			tsserver = {
				globalPlugins = {
					{
						name = "@vue/typescript-plugin",
						location = get_vue_plugin_path(),
						languages = { "vue" },
						configNamespace = "typescript",
					},
				},
			},
		},
	},
}

return M