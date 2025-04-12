return {
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
				automatic_setup = {
					enable = true,
				},
			})

			-- Setup null-ls
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- GO tmpl
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
					"benfowler/telescope-luasnip.nvim",
				},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},

		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			local s = luasnip.snippet
			local t = luasnip.text_node
			local i = luasnip.insert_node

			luasnip.add_snippets("go", {
				s("doc", {
					t({ "/**", " * " }),
					i(1, "description"),
					t({ "", " * @param " }),
					i(2, "param_name"),
					t({ " " }),
					i(3, "param_description"),
					t({ "", " * @return " }),
					i(4, "return_description"),
					t({ "", " */" }),
				}),

				s("//", {
					t("// "),
					i(1, "comment"),
				}),
			})

			luasnip.config.setup({
				history = true,
				updateevents = "TextChanged,TextChangedI",
			})

			vim.tbl_map(function(type)
				require("luasnip.loaders.from_" .. type).lazy_load()
			end, { "vscode", "snipmate", "lua" })

			-- Friendly-snippets - enable standardized comments snippets
			require("luasnip").filetype_extend("go", { "godoc" })
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
}
