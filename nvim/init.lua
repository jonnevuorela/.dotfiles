-- Pin Neovim's Python provider to a specific mise-managed Python
-- Dynamic version: uses whatever mise has active when Neovim starts
local python_path = vim.fn.systemlist("mise which python")[1]
if python_path and vim.fn.executable(python_path) == 1 then
	vim.g.python3_host_prog = vim.trim(python_path)
else
	-- Fallback if mise isn't active or command fails
	vim.g.python3_host_prog = "/usr/bin/python3" -- or leave unset
end

-- Keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Explorer
vim.keymap.set("n", "<C-b>", vim.cmd.Ex, { desc = "[Buffer] Open Ex mode" })

-- Save
vim.api.nvim_set_keymap("n", "<C-s>", ":w<CR>", { noremap = true, silent = true })

-- Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<D-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<D-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<D-Left>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<D-Right>", "<C-w><C-l>", { desc = "Move focus to the right window" })

-- hjkl for insert mode
vim.keymap.set("i", "<C-h>", "<Left>", { noremap = true })
vim.keymap.set("i", "<C-j>", "<Down>", { noremap = true })
vim.keymap.set("i", "<C-k>", "<Up>", { noremap = true })
vim.keymap.set("", "<C-l>", "<Right>", { noremap = true })

-- Doxygen
vim.api.nvim_set_keymap(
	"n",
	"<leader>d",
	":lua require('neogen').generate()<CR>",
	{ desc = "Neogen", noremap = true, silent = true }
)

-- Various

-- Editor Behavior
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Number of spaces for indentation
vim.opt.tabstop = 4 -- Number of spaces for tab
vim.opt.smartindent = true -- Smart autoindenting
vim.g.have_nerd_font = true -- Enable nerd font support
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.hidden = true -- Enable background buffers
vim.opt.hlsearch = true -- Highlight found searches
vim.opt.incsearch = true -- Shows the match while typing
vim.opt.syntax = "on" -- Enable syntax highlighting

-- UI Settings
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.signcolumn = "yes" -- Always show signcolumn
vim.opt.cursorline = true -- Highlight current line
vim.opt.scrolloff = 10 -- Lines of context
vim.opt.splitright = true -- Vertical splits to the right
vim.opt.splitbelow = true -- Horizontal splits below

-- Search and Completion
vim.opt.ignorecase = true -- Ignore case in search
vim.opt.smartcase = true -- Unless search contains uppercase
vim.opt.inccommand = "split" -- Preview substitutions

-- Performance
vim.opt.updatetime = 250 -- Faster completion
vim.opt.timeoutlen = 300 -- Faster key sequence completion

-- File Handling
vim.opt.undofile = true -- Persistent undo

-- Whitespace Display
vim.opt.list = true -- Show whitespace
vim.opt.listchars = {
	tab = "│ ", -- Show indent guide
}

-- Autocommands

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
vim.opt.termguicolors = false

-- gotmpl
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("gotmpl_highlight", { clear = true }),
	pattern = "*.tmpl",
	callback = function()
		local filename = vim.fn.expand("%:t")
		local ext = filename:match(".*%.(.-)%.tmpl$")

		-- Add more extension to syntax mappings here if you need to.
		local ext_filetypes = {
			go = "go",
			html = "html",
			md = "markdown",
			yaml = "yaml",
			yml = "yaml",
		}

		if ext and ext_filetypes[ext] then
			-- Set the primary filetype
			vim.bo.filetype = ext_filetypes[ext]

			-- Define embedded Go template syntax
			vim.cmd([[
            syntax include @gotmpl syntax/gotmpl.vim
            syntax region gotmpl start="{{" end="}}" contains=@gotmpl containedin=ALL
            syntax region gotmpl start="{%" end="%}" contains=@gotmpl containedin=ALL
          ]])
		end
	end,
})

-- Lazy installer
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require("lazy").setup({

	-- Universal Yank
	{
		"ojroques/vim-oscyank",
		config = function()
			vim.g.oscyank_term = "ghostty"
			vim.g.oscyank_autocopy = 1
		end,
	},

	-- Indent lines
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
		config = function()
			require("ibl").setup({
				indent = {
					char = "│",
					tab_char = "│",
				},
				scope = { enabled = false },
				exclude = {
					filetypes = {
						"help",
						"dashboard",
						"lazy",
						"mason",
						"notify",
						"toggleterm",
						"lazyterm",
					},
				},
			})

			local hooks = require("ibl.hooks")

			hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
				-- vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3c3836" })
			end)
		end,
	},

	--	-- kage
	--	"sedyh/ebitengine-kage-vim",
	--	"jayli/vim-easycomplete",
	--	"SirVer/ultisnips",
	-- "RaafatTurki/hex.nvim",

	require("plugins.flutter-tools"),
	require("plugins.molten"),

	{
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
	},

	{
		"olexsmir/gopher.nvim",
		ft = "go",
		config = function(_, opts)
			require("gopher").setup(opts)
		end,
		build = function() end,
	},

	-- folke
	{
		"folke/which-key.nvim",
		dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons" },
		event = "VimEnter",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function()
			require("which-key").setup({})
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	require("plugins.snacks"),

	-- Autopair
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- LSP Plugins
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			{ "j-hui/fidget.nvim", opts = {} },

			"saghen/blink.cmp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("ca", vim.lsp.buf.code_action, "Code [A]ction")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

					---@param client vim.lsp.Client
					---@param method vim.lsp.protocol.Method
					---@param bufnr? integer
					---@return boolean
					local function client_supports_method(client, method, bufnr)
						if vim.fn.has("nvim-0.11") == 1 then
							return client:supports_method(method, bufnr)
						else
							return client.supports_method(method, { bufnr = bufnr })
						end
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

			local capabilities = require("blink.cmp").get_lsp_capabilities()

			local servers = {
				-- clangd = {},
				-- gopls = {},
				-- pyright = {},
				-- rust_analyzer = {},
				--
				-- Some languages (like typescript) have entire language plugins that can be useful:
				--    https://github.com/pmizio/typescript-tools.nvim
				--
				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},
				--

				lua_ls = {
					-- cmd = { ... },
					-- filetypes = { ... },
					-- capabilities = {},
					settings = {
						Lua = {
							completion = {
								callSnippet = "Replace",
							},
							-- diagnostics = { disable = { 'missing-fields' } },
						},
					},
				},
			}

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- Used to format Lua code
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>F",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				cs = { "csharpier" },
				go = { "goimports" },
				javascript = { lsp_format = "fallback" },
				-- python = { "isort", "black" },
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{ -- Autocompletion
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			-- Snippet Engine
			{
				"L3MON4D3/LuaSnip",
				build = vim.fn.has("win32") ~= 0 and "make install_jsregexp" or nil,
				dependencies = {
					"rafamadriz/friendly-snippets",
					"benfowler/telescope-luasnip.nvim",
				},
				config = function(_, opts)
					if opts then
						require("luasnip").config.setup(opts)
					end
					vim.tbl_map(function(type)
						require("luasnip.loaders.from_" .. type).lazy_load()
					end, { "vscode", "snipmate", "lua" })
					-- friendly-snippets - enable standardized comments snippets
					require("luasnip").filetype_extend("typescript", { "tsdoc" })
					require("luasnip").filetype_extend("javascript", { "jsdoc" })
					require("luasnip").filetype_extend("lua", { "luadoc" })
					require("luasnip").filetype_extend("python", { "pydoc" })
					require("luasnip").filetype_extend("rust", { "rustdoc" })
					require("luasnip").filetype_extend("cs", { "csharpdoc" })
					require("luasnip").filetype_extend("java", { "javadoc" })
					require("luasnip").filetype_extend("c", { "cdoc" })
					require("luasnip").filetype_extend("cpp", { "cppdoc" })
					require("luasnip").filetype_extend("php", { "phpdoc" })
					require("luasnip").filetype_extend("kotlin", { "kdoc" })
					require("luasnip").filetype_extend("ruby", { "rdoc" })
					require("luasnip").filetype_extend("sh", { "shelldoc" })
				end,
			},
			"folke/lazydev.nvim",
		},
		--- @module 'blink.cmp'
		--- @type blink.cmp.Config
		opts = {
			keymap = {
				preset = "enter",
			},

			appearance = {
				nerd_font_variant = "mono",
			},

			completion = {
				accept = { auto_brackets = { enabled = true } },
				documentation = { auto_show = false, auto_show_delay_ms = 500 },
				menu = {
					auto_show = true,
					-- nvim-cmp style menu
					draw = {
						columns = {
							{ "label", "label_description", gap = 1 },
							{ "kind" },
							{ "source_name" },
						},
						treesitter = {
							enable = true,
						},
					},
				},
				ghost_text = { enabled = true },
			},

			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},

			snippets = { preset = "luasnip", enabled = true },

			fuzzy = { implementation = "lua" },

			signature = { enabled = true },
		},
	},

	-- Treesitter
	require("plugins.treesitter"),
	--	{
	--		"nvim-treesitter/nvim-treesitter",
	--		branch = "main",
	--		lazy = false,
	--		build = ":TSUpdate",
	--		main = "nvim-treesitter.configs",
	--		opts = {
	--			ensure_installed = "all",
	--			auto_install = true,
	--			highlight = { enable = true },
	--			indent = { enable = true },
	--			ignore_install = { "ipkg" },
	--		},
	--		config = function(_, opts)
	--			-- safe require: if the plugin isn't installed yet this won't error and will let startup continue
	--			local ok, configs = pcall(require, "nvim-treesitter.configs")
	--			if not ok or not configs then
	--				vim.notify("nvim-treesitter not installed yet, skipping setup", vim.log.levels.WARN)
	--				return
	--			end
	--			configs.setup(opts)
	--
	--			-- prefer git for parser installs if available (won't error if module missing)
	--			local ok2, install = pcall(require, "nvim-treesitter.install")
	--			if ok2 and install then
	--				install.prefer_git = true
	--			end
	--		end,
	--	},

	-- Color schemes
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
					-- Override the builtin palette per variant
					moon = {
						base = "#18191a",
					},
				},
			})
		end,
	},
})

-- Set the color scheme after initializing the plugins
vim.cmd.colorscheme("rose-pine-moon")

-- Unreal
--    require("plugins.unreal").setup({
--        engine_path = vim.fn.has("win32") == 1 and "C:\\Users\\jovuorel\\UnrealEngine"
--            or os.getenv("HOME") .. "/repos/unrealengine",
--        format_on_save = false,
--    })
