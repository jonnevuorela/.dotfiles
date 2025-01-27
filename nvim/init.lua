-- Keymaps

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Explorer
vim.keymap.set("n", "<C-b>", vim.cmd.Ex, { desc = "[Buffer] Open Ex mode" })
-- Diagnostics
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
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
-- Lspsaga
vim.api.nvim_set_keymap(
	"n",
	"<leader>ca",
	"<cmd>Lspsaga code_action<CR>",
	{ desc = "code [A]ction", noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>", { noremap = true, silent = true })
-- Doxygen
vim.api.nvim_set_keymap("n", "<leader>o", "<cmd>Dox<CR>", { desc = "D[o]xygen", noremap = true, silent = true })
-- Terminal
vim.api.nvim_set_keymap("", "<C-t>", "<cmd>Lspsaga term_toggle<CR>", { noremap = true, silent = true })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Various

-- Editor Behavior
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 3 -- Number of spaces for indentation
vim.opt.tabstop = 3 -- Number of spaces for tab
vim.opt.smartindent = true -- Smart autoindenting
vim.g.have_nerd_font = true -- Enable nerd font support
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.termguicolors = true -- Enable 24-bit RGB colors
vim.opt.syntax = "on" -- Enable syntax highlighting
vim.opt.hidden = true -- Enable background buffers
vim.opt.hlsearch = true -- Highlight found searches
vim.opt.incsearch = true -- Shows the match while typing

-- Parser settings
vim.opt.runtimepath:append("~/.local/share/nvim/site/pack/packer/start/nvim-treesitter/parser")

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
vim.opt.termguicolors = true

-- Lazy installer
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Plugins setup
require("lazy").setup({
	-- Universal Yank
	{
		"ojroques/vim-oscyank",
		config = function()
			vim.g.oscyank_term = "kitty"
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
	-- Which-Key
	{
		"folke/which-key.nvim",
		dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons" },
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		config = function()
			require("which-key").setup({})
		end,
	},

	-- Harpoon™
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local harpoon = require("harpoon")
			harpoon:setup({})

			-- basic telescope configuration
			local conf = require("telescope.config").values
			local function toggle_telescope(harpoon_files)
				local file_paths = {}
				for _, item in ipairs(harpoon_files.items) do
					table.insert(file_paths, item.value)
				end

				require("telescope.pickers")
					.new({}, {
						prompt_title = "Harpoon™",
						finder = require("telescope.finders").new_table({
							results = file_paths,
						}),
						previewer = conf.file_previewer({}),
						sorter = conf.generic_sorter({}),
					})
					:find()
			end

			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end, { desc = "Add to Harpoon™" })
			vim.keymap.set("n", "<C-e>", function()
				toggle_telescope(harpoon:list())
			end, { desc = "Open Harpoon™ window" })
		end,
	},

	-- LSP and Formatting Setup to buffer
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- LSP Support
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },
			{ "WhoIsSethDaniel/mason-tool-installer.nvim" },
			-- LSP UI Enhancements
			{
				"nvimdev/lspsaga.nvim",
				config = function()
					require("lspsaga").setup({
						ui = {
							code_action = "➣",
							lines = { "┗", "┣", "┃", "━", "┏" },
						},
						lightbulb = {
							virtual_text = false,
						},
					})
				end,
			},
			{ "j-hui/fidget.nvim", opts = {} },
			{ "folke/neodev.nvim", opts = {} },
			-- Formatting
			{ "stevearc/conform.nvim" },
			{ "nvimtools/none-ls.nvim" },
			{ "jay-babu/mason-null-ls.nvim" },
		},
		config = function()
			-- Mason setup
			require("mason").setup()

			-- Configure LSP servers
			local servers = {
				clangd = {},
				pyright = {},
				gopls = {},
				templ = {},
				lua_ls = {
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
								library = {
									[vim.fn.expand("$VIMRUNTIME/lua")] = true,
									[vim.fn.stdpath("config") .. "/lua"] = true,
								},
							},
							diagnostics = { globals = { "vim" } },
						},
					},
				},
			}

			-- Setup capabilities
			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("cmp_nvim_lsp").default_capabilities()
			)

			-- Setup mason-tool-installer
			local ensure_installed = vim.tbl_keys(servers)
			vim.list_extend(ensure_installed, {
				"stylua",
				"prettier",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			-- Setup mason-lspconfig
			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_installation = true,
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})

			-- Setup mason-null-ls
			require("mason-null-ls").setup({
				ensure_installed = {
					"stylua",
					"prettier",
				},
				automatic_installation = true,
				handlers = {
					function(source_name, methods)
						require("mason-null-ls.automatic_setup")(source_name, methods)
					end,
				},
			})

			-- Setup null-ls
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.prettier.with({
						filetypes = { "template", "gotmpl" },
						extra_args = { "--parser", "html" },
					}),
				},
			})

			-- Setup conform.nvim
			local conform = require("conform")
			conform.setup({
				-- Use null-ls formatters first, then fall back to LSP
				formatters_by_ft = {
					lua = { "stylua" },
					-- Let other filetypes be handled by null-ls or LSP
				},
				format_on_save = {
					timeout_ms = 500,
					lsp_fallback = true,
				},
			})

			-- LSP Keymaps
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					vim.keymap.set("n", "<leader>t", function() end, { desc = "[T]ype" })
					map("<leader>td", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
					vim.keymap.set("n", "<leader>d", function() end, { desc = "[D]ocument" })
					map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
					vim.keymap.set("n", "<leader>w", function() end, { desc = "[W]orkspace" })
					map(
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						"[W]orkspace [S]ymbols"
					)
					vim.keymap.set("n", "<leader>r", function() end, { desc = "Lsp [R]ename" })
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					vim.keymap.set("n", "<leader>c", function() end, { desc = "[C]ode" })
					map("<leader>cA", vim.lsp.buf.code_action, "[C]ode [A]ction")
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				end,
			})

			-- Format keymap
			vim.keymap.set({ "n", "v" }, "<leader>mp", function()
				conform.format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 500,
				})
			end, { desc = "Format file or range (in visual mode)" })
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					{
						"rafamadriz/friendly-snippets",
						config = function()
							require("luasnip.loaders.from_vscode").lazy_load()
						end,
					},
				},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },

				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),

					["<C-Space>"] = cmp.mapping.complete({}),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"vim",
					"vimdoc",
					"query",
					"python",
					"cpp",
					"c",
					"rust",
					"go",
					"templ",
					"gotmpl",
				},
				auto_install = true,

				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},

				indent = { enable = true },

				incremental_selection = {
					enable = true,
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
				},
			})
		end,
	},
	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"debugloop/telescope-undo.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					file_sorter = require("telescope.sorters").get_fuzzy_file,
					file_ignore_patterns = { "node_modules", ".git/" },
					generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
					file_previewer = require("telescope.previewers").vim_buffer_cat.new,
					grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
					qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
					prompt_prefix = "❯ ",
					selection_caret = "❯ ",
					path_display = { "truncate" },
				},
				pickers = {
					find_files = {
						theme = "ivy",
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_ivy(),
					},
					fzf = {
						fuzzy = true,
						override_generic_sorter = false,
						override_file_sorter = true,
						case_mode = "smart_case",
					},
					undo = {},
				},
			})

			-- Load extensions
			--
			pcall(telescope.load_extension, "fzy_native")
			pcall(telescope.load_extension, "ui-select")
			pcall(telescope.load_extension, "undo")

			-- Undo tree
			vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = "[U]ndo" })

			-- Search keymaps
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>s", function() end, { desc = "[S]earch" })
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
			vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
			vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			-- Fuzzy find in current buffer
			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			-- Search in open files
			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			-- Search Neovim config files
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},
	-- Set up color schemes
	{
		"rose-pine/neovim",
		name = "rose-pine",
		config = function()
			require("rose-pine").setup({
				disable_background = true,
			})
		end,
	},
})

-- Set the color scheme after initializing the plugins
vim.cmd.colorscheme("rose-pine")
