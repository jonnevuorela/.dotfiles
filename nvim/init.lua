-- Keymaps

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Explorer
vim.keymap.set('n', '<C-b>', vim.cmd.Ex, { desc = "[Buffer] Open Ex mode" })
-- Diagnostics
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
-- Save
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })
-- Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<D-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<D-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<D-Left>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<D-Right>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- hjkl for insert mode
vim.keymap.set('i', '<C-h>', '<Left>', { noremap = true })
vim.keymap.set('i', '<C-j>', '<Down>', { noremap = true })
vim.keymap.set('i', '<C-k>', '<Up>', { noremap = true })
vim.keymap.set('', '<C-l>', '<Right>', { noremap = true })
-- Lspsaga
vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>Lspsaga code_action<CR>',
   { desc = 'code [A]ction', noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'K', '<cmd>Lspsaga hover_doc<CR>', { noremap = true, silent = true })
-- Doxygen
vim.api.nvim_set_keymap('n', '<leader>o', '<cmd>Dox<CR>', { desc = 'D[o]xygen', noremap = true, silent = true })
-- Terminal
vim.api.nvim_set_keymap('', '<C-t>', '<cmd>Lspsaga term_toggle<CR>', { noremap = true, silent = true })
vim.keymap.set('t', '<C-t>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Various
-- Editor Behavior
vim.opt.expandtab = true    -- Use spaces instead of tabs
vim.opt.shiftwidth = 3      -- Number of spaces for indentation
vim.opt.tabstop = 3         -- Number of spaces for tab
vim.opt.smartindent = true  -- Smart autoindenting
vim.g.have_nerd_font = true -- Enable nerd font support

-- UI Settings
vim.opt.number = true         -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.opt.mouse = 'a'           -- Enable mouse support
vim.opt.showmode = false      -- Don't show mode in command line
vim.opt.signcolumn = 'yes'    -- Always show signcolumn
vim.opt.cursorline = true     -- Highlight current line
vim.opt.scrolloff = 10        -- Lines of context
vim.opt.splitright = true     -- Vertical splits to the right
vim.opt.splitbelow = true     -- Horizontal splits below

-- Search and Completion
vim.opt.ignorecase = true    -- Ignore case in search
vim.opt.smartcase = true     -- Unless search contains uppercase
vim.opt.inccommand = 'split' -- Preview substitutions

-- Performance
vim.opt.updatetime = 250 -- Faster completion
vim.opt.timeoutlen = 300 -- Faster key sequence completion

-- File Handling
vim.opt.undofile = true -- Persistent undo

-- Whitespace Display
vim.opt.list = true -- Show whitespace
vim.opt.listchars = {
   tab = '│ ', -- Show indent guide
}
-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
   desc = 'Highlight when yanking (copying) text',
   group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
   callback = function()
      vim.highlight.on_yank()
   end,
})

-- Ensure `lazy.nvim` is installed
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
      'ojroques/vim-oscyank',
      config = function()
         vim.g.oscyank_term = 'default' -- or 'kitty' or 'tmux'
      end
   },
   -- Indent lines
   {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl", -- New requirement for v3
      opts = {},
      config = function()
         require("ibl").setup({
            indent = {
               char = "│", -- You can change this character to any other
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

         -- Set specific highlight colors (optional)
         local hooks = require("ibl.hooks")
         hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3c3836" })
         end)
      end,
   },
   -- Which-Key
   {
      "folke/which-key.nvim",
      dependencies = { "echasnovski/mini.icons", "nvim-tree/nvim-web-devicons", },
      event = "VeryLazy",
      init = function()
         vim.o.timeout = true
         vim.o.timeoutlen = 300
      end,
      config = function()
         require("which-key").setup({
            -- your existing configuration can go here
         })
      end
   },
   -- Mason and LSP
   {
      "williamboman/mason.nvim",
      dependencies = {
         "williamboman/mason-lspconfig.nvim",
         "neovim/nvim-lspconfig",
         "stevearc/conform.nvim", -- Add conform.nvim as a dependency
         {
            'nvimdev/lspsaga.nvim',
            config = function()
               require('lspsaga').setup {
                  ui = {
                     code_action = '➣',
                     lines = { '┗', '┣', '┃', '━', '┏' },
                  },
                  lightbulb = {
                     virtual_text = false,
                  },
               }
            end,
            dependencies = {
               'nvim-treesitter/nvim-treesitter',
               'nvim-tree/nvim-web-devicons',
            },
         },
      },
      config = function()
         -- Mason setup
         require("mason").setup()
         require("mason-lspconfig").setup({
            ensure_installed = { "lua_ls" },
            automatic_installation = true,
         })

         -- Setup conform.nvim to use Mason-installed formatters
         require("conform").setup({
            -- Let conform.nvim auto-detect formatters
            formatters_by_ft = {},
            -- Log setup info
            notify_on_error = true,
            log_level = vim.log.levels.INFO,
            metadata = {
               setup_time = "2025-01-26 12:52:23",
               user = "jonnevuorela"
            }
         })

         -- Format and save keybinding
         vim.keymap.set('n', '<C-s>', function()
            require("conform").format({
               async = false,
               lsp_fallback = true,
               callback = function(err)
                  if err then
                     vim.notify("Format failed: " .. err, vim.log.levels.WARN)
                  else
                     vim.cmd('write')
                  end
               end
            })
         end, { desc = "Format and Save" })

         local lspconfig = require("lspconfig")
         local capabilities = require('cmp_nvim_lsp').default_capabilities()

         -- LSP configurations
         lspconfig.lua_ls.setup {
            capabilities = capabilities,
            settings = {
               Lua = {
                  runtime = { version = 'LuaJIT' },
                  diagnostics = { globals = { 'vim' } },
                  workspace = {
                     library = vim.api.nvim_get_runtime_file("", true),
                     checkThirdParty = false,
                  },
                  telemetry = { enable = false },
               },
            },
         }

         -- LSP Attach configuration
         vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
            callback = function(event)
               local map = function(keys, func, desc)
                  vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
               end

               -- Keybindings
               map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
               map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
               map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

               vim.keymap.set('n', '<leader>t', function() end, { desc = '[T]ype' })
               map('<leader>td', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

               vim.keymap.set('n', '<leader>d', function() end, { desc = '[D]ocument' })
               map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

               vim.keymap.set('n', '<leader>w', function() end, { desc = '[W]orkspace' })
               map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

               vim.keymap.set('n', '<leader>r', function() end, { desc = 'Lsp [R]ename' })
               map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

               vim.keymap.set('n', '<leader>c', function() end, { desc = '[C]ode' })
               map('<leader>cA', vim.lsp.buf.code_action, '[C]ode [A]ction')

               map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

               -- Document highlight configuration
               local client = vim.lsp.get_client_by_id(event.data.client_id)
               if client and client.server_capabilities.documentHighlightProvider then
                  local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })

                  vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                     buffer = event.buf,
                     group = highlight_augroup,
                     callback = vim.lsp.buf.document_highlight,
                  })

                  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                     buffer = event.buf,
                     group = highlight_augroup,
                     callback = vim.lsp.buf.clear_references,
                  })

                  vim.api.nvim_create_autocmd('LspDetach', {
                     group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
                     callback = function(event2)
                        vim.lsp.buf.clear_references()
                        vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
                     end,
                  })
               end

               -- Inlay hints
               if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                  map('<leader>H', function()
                     vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                  end, 'Toggle Inlay [H]ints')
               end
            end,
         })
      end,
   },

   -- Completion
   {
      "hrsh7th/nvim-cmp",
      dependencies = {
         "hrsh7th/cmp-nvim-lsp",
         "hrsh7th/cmp-buffer",
         "hrsh7th/cmp-path",
         "L3MON4D3/LuaSnip",
         "saadparwaiz1/cmp_luasnip",
      },
      config = function()
         local cmp = require('cmp')
         cmp.setup({
            snippet = {
               expand = function(args)
                  require('luasnip').lsp_expand(args.body)
               end,
            },
            mapping = cmp.mapping.preset.insert({
               ['<C-b>'] = cmp.mapping.scroll_docs(-4),
               ['<C-f>'] = cmp.mapping.scroll_docs(4),
               ['<C-Space>'] = cmp.mapping.complete(),
               ['<C-e>'] = cmp.mapping.abort(),
               ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
               { name = 'nvim_lsp' },
               { name = 'luasnip' },
            }, {
               { name = 'buffer' },
            })
         })
      end,
   },

   -- Telescope
   {
      "nvim-telescope/telescope.nvim",
      event = 'VimEnter',
      branch = "0.1.x",
      dependencies = {
         'nvim-lua/plenary.nvim',
         'debugloop/telescope-undo.nvim',
         {
            'nvim-telescope/telescope-fzf-native.nvim',
            build = 'make',
            cond = function()
               return vim.fn.executable 'make' == 1
            end,
         },
         { 'nvim-telescope/telescope-ui-select.nvim' },
         { 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
      },
      config = function()
         local telescope = require("telescope")
         local actions = require("telescope.actions")

         telescope.setup({
            defaults = {
               file_sorter = require('telescope.sorters').get_fuzzy_file,
               file_ignore_patterns = { "node_modules", ".git/" },
               generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
               file_previewer = require('telescope.previewers').vim_buffer_cat.new,
               grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
               qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
               prompt_prefix = "❯ ",
               selection_caret = "❯ ",
               mappings = {
                  i = {
                     ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                  },
               },
               path_display = { "truncate" }
            },
            pickers = {
               find_files = {
                  theme = 'dropdown',
               }
            },
            extensions = {
               ['ui-select'] = {
                  require('telescope.themes').get_dropdown(),
               },
               fzf = {
                  fuzzy = true,
                  override_generic_sorter = false,
                  override_file_sorter = true,
                  case_mode = 'smart_case',
               },
               undo = {}
            }
         })

         -- Load extensions
         pcall(telescope.load_extension, 'ui-select')
         pcall(telescope.load_extension, 'undo')

         -- Undo tree
         vim.keymap.set('n', '<leader>u', '<cmd>Telescope undo<cr>', { desc = '[U]ndo' })

         -- Search keymaps
         local builtin = require 'telescope.builtin'
         vim.keymap.set('n', '<leader>s', function() end, { desc = '[S]earch' })
         vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
         vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
         vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
         vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
         vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
         vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
         vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
         vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
         vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
         vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

         -- Git keymaps
         vim.keymap.set('n', '<leader>g', function() end, { desc = '[G]it' })
         vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = '[G]it [S]tatus' })
         vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = '[G]it [C]ommits' })
         vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = '[G]it [B]ranches' })
         vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = '[G]it [F]iles' })
         vim.keymap.set('n', '<leader>gj', builtin.git_stash, { desc = '[G]it] [J]emma' })
         vim.keymap.set('n', '<leader>gb', builtin.git_bcommits, { desc = '[G]it [B]commit' })

         -- Fuzzy find in current buffer
         vim.keymap.set('n', '<leader>/', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
               winblend = 2,
               previewer = false,
            })
         end, { desc = '[/] Fuzzily search in current buffer' })

         -- Search in open files
         vim.keymap.set('n', '<leader>s/', function()
            builtin.live_grep {
               grep_open_files = true,
               prompt_title = 'Live Grep in Open Files',
            }
         end, { desc = '[S]earch [/] in Open Files' })

         -- Search Neovim config files
         vim.keymap.set('n', '<leader>sn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
         end, { desc = '[S]earch [N]eovim files' })
      end
   },
   -- Set up color schemes
   {
      "rose-pine/neovim",
      name = "rose-pine",
      config = function()
         require("rose-pine").setup({ disable_background = true })
      end,
   },
})

-- Set the color scheme after initializing the plugins
vim.cmd.colorscheme("rose-pine")
