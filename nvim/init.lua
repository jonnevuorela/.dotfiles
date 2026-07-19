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

local defaults = require("config.defaults")
local user_defaults = { state = defaults.ensure() }
defaults.apply(user_defaults.state)

-- Explorer
vim.keymap.set("n", "<C-b>", vim.cmd.Ex, { desc = "[Buffer] Open Ex mode" })

-- Save
vim.keymap.set("n", "<C-s>", ":w<CR>", { noremap = true, silent = true, desc = "Save buffer" })

-- Use CTRL+Arrow to switch between windows
vim.keymap.set("n", "<C-Left>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-Right>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-Up>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-Down>", "<C-w><C-j>", { desc = "Move focus to the lower window" })

-- hjkl for insert mode
vim.keymap.set("i", "<C-h>", "<Left>", { noremap = true, desc = "Move cursor left" })
vim.keymap.set("i", "<C-j>", "<Down>", { noremap = true, desc = "Move cursor down" })
vim.keymap.set("i", "<C-k>", "<Up>", { noremap = true, desc = "Move cursor up" })
vim.keymap.set("", "<C-l>", "<Right>", { noremap = true, desc = "Move cursor right" })

-- Diagnostics
do
	vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostics float" })
	vim.keymap.set("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Diagnostics quickfix" })
	vim.keymap.set("n", "<leader>l", vim.diagnostic.setloclist, { desc = "Diagnostics loclist" })
end

-- Doxygen
vim.keymap.set("n", "<leader>d", function()
	require("neogen").generate()
end, { desc = "Neogen" })

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
-- vim.opt.syntax = "on" -- treesitter handles highlighting

-- UI Settings
-- window-local defaults handled by config.defaults
vim.opt.mouse = "a" -- Enable mouse support
-- window-local defaults handled by config.defaults
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
-- window-local defaults handled by config.defaults
vim.opt.listchars = {
	tab = "│ ", -- Show indent guide
}

-- Autocommands

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
vim.opt.termguicolors = true

-- background default handled by config.defaults

-- gotmpl: set filetype so treesitter injections work natively
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("gotmpl_filetype", { clear = true }),
	pattern = "*.tmpl",
	callback = function()
		local ext_filetypes = {
			go = "go",
			html = "html",
			md = "markdown",
			yaml = "yaml",
			yml = "yaml",
		}
		local filename = vim.fn.expand("%:t")
		local ext = filename:match(".*%.(.-)%.tmpl$")
		if ext and ext_filetypes[ext] then
			vim.bo.filetype = ext_filetypes[ext]
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
	require("plugins.oscyank"),
	require("plugins.indent-blankline"),
	require("plugins.csvview"),
	require("plugins.neogen"),
	require("plugins.go"),
	require("plugins.which-key"),
	require("plugins.todo-comments"),
	require("plugins.lazydev"),

	require("plugins.snacks"),
	require("plugins.99"),
	require("plugins.autopairs"),
	require("plugins.lsp"),
	require("plugins.formatting"),
	require("plugins.blink-cmp"),
	require("plugins.treesitter"),
	require("plugins.colorschemes"),
})

-- colorscheme default handled by config.defaults

-- Unreal
--    require("plugins.unreal").setup({
--        engine_path = vim.fn.has("win32") == 1 and "C:\\Users\\jovuorel\\UnrealEngine"
--            or os.getenv("HOME") .. "/repos/unrealengine",
--        format_on_save = false,
--    })
