return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "mason-org/mason.nvim", opts = {} },
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "j-hui/fidget.nvim", opts = {} },
		"saghen/blink.cmp",
	},
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		-- Give blink's capabilities (snippets, etc.) to EVERY LSP automatically
		vim.lsp.config("*", {
			capabilities = capabilities,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end
				map("<leader>ca", vim.lsp.buf.code_action, "Code [A]ction")
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

				local function client_supports_method(client, method, bufnr)
					return client:supports_method(method, bufnr)
				end

				local client = vim.lsp.get_client_by_id(event.data.client_id)
				if
					client
					and client_supports_method(
						client,
						vim.lsp.protocol.Methods.textDocument_documentHighlight,
						event.buf
					)
				then
					local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.document_highlight,
					})
					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						buffer = event.buf,
						group = highlight_augroup,
						callback = vim.lsp.buf.clear_references,
					})
					vim.api.nvim_create_autocmd("LspDetach", {
						group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
						callback = function(event2)
							vim.lsp.buf.clear_references()
							vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
						end,
					})
				end
			end,
		})

		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = vim.g.have_nerd_font and {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					local diagnostic_message = {
						[vim.diagnostic.severity.ERROR] = diagnostic.message,
						[vim.diagnostic.severity.WARN] = diagnostic.message,
						[vim.diagnostic.severity.INFO] = diagnostic.message,
						[vim.diagnostic.severity.HINT] = diagnostic.message,
					}
					return diagnostic_message[diagnostic.severity]
				end,
			},
		})

		require("mason-tool-installer").setup({ ensure_installed = { "stylua" } })

		require("mason-lspconfig").setup({
			ensure_installed = {},
			automatic_installation = false,
			automatic_enable = true,
		})

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace",
					},
				},
			},
		})

		-- ts_ls: don't use ~ as root when there's no lockfile
		vim.lsp.config("ts_ls", {
			init_options = {
				preferences = {
					includeCompletionsForModuleExports = true,
					includeCompletionsWithClassMemberSnippets = true,
					includeCompletionsWithSnippetText = true,
				},
			},
			settings = {
				javascript = {
					suggest = { completeFunctionCalls = true },
				},
				typescript = {
					suggest = { completeFunctionCalls = true },
				},
			},
			root_dir = function(bufnr, on_dir)
				local root = vim.fs.root(bufnr, { "package.json", "tsconfig.json", "jsconfig.json", "deno.json", ".git" })
				if root then
					on_dir(root)
				else
					on_dir(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h"))
				end
			end,
		})

	-- Auto-create jsconfig/tsconfig with DOM lib for projects that lack one
		local fallback_dir = vim.fn.stdpath("config")
		local js_fallback = fallback_dir .. "/jsconfig.fallback.json"
		local ts_fallback = fallback_dir .. "/tsconfig.fallback.json"
		local function has_deno_dom_lib(root)
			local deno = root .. "/deno.json"
			local f = io.open(deno, "r")
			if not f then
				return false
			end
			local content = f:read("*a")
			f:close()
			return content:find('"dom"') ~= nil
		end
		vim.api.nvim_create_autocmd("BufReadPre", {
			group = vim.api.nvim_create_augroup("js-ts-dombind", { clear = true }),
			pattern = { "*.js", "*.jsx", "*.mjs", "*.cjs", "*.ts", "*.tsx" },
			callback = function()
				local buf = vim.api.nvim_get_current_buf()
				local root = vim.fs.root(buf, { "deno.json", ".git", "package.json" })
				if not root then
					return
				end
				local is_ts = vim.endswith(vim.fn.expand("%:t"), ".ts")
					or vim.endswith(vim.fn.expand("%:t"), ".tsx")
				local target_name = is_ts and "tsconfig.json" or "jsconfig.json"
				local fallback_src = is_ts and ts_fallback or js_fallback
				local target_path = root .. "/" .. target_name
				-- already exists
				if vim.fn.glob(target_path) ~= "" then
					return
				end
				-- other config covers this
				if vim.fn.glob(root .. "/tsconfig.json") ~= ""
					or vim.fn.glob(root .. "/jsconfig.json") ~= "" then
					return
				end
				-- deno with DOM lib already configured
				if has_deno_dom_lib(root) then
					return
				end
			-- copy fallback
			local fr = io.open(fallback_src, "r")
			if fr then
				local content = fr:read("*a")
				fr:close()
				local fw = io.open(target_path, "w")
				if fw then
					fw:write(content)
					fw:close()
					vim.notify("Created " .. target_name .. " with DOM types. Run :LspRestart to activate.", vim.log.levels.INFO)
				-- restart ts_ls so it picks up the new config
				vim.schedule(function()
					pcall(vim.cmd, "LspRestart ts_ls")
				end)
				end
			end
			end,
		})

		vim.lsp.config("wc_ls", {
			init_options = { hostInfo = "neovim" },
			cmd = { "wc-language-server", "--stdio" },
			filetypes = {
				"html",
				"javascriptreact",
				"typescriptreact",
				"astro",
				"svelte",
				"vue",
				"markdown",
				"mdx",
				"javascript",
				"typescript",
				"css",
				"scss",
				"less",
			},
			root_dir = function(bufnr, on_dir)
				local root = vim.fs.root(bufnr, {
					"custom-elements.json",
					"wc.config.js",
					"wc.config.ts",
					"wc.config.mjs",
					"wc.config.cjs",
				})
				if root then
					on_dir(root)
				end
			end,
		})

		-- mason-lspconfig auto-enables everything it knows about;
		-- we only need to explicitly enable servers that need custom config above
		vim.lsp.enable({ "lua_ls", "wc_ls" })
	end,
}
