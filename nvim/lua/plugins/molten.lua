-- Molten.nvim: Modern REPL + notebook-style execution with virtual text and inline images
-- VSCode-like notebook experience optimized for Ghostty terminal
-- Setup memo (Feb 2026) – see end of file for troubleshooting history

return {
	-- Core Molten plugin
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		dependencies = { "3rd/image.nvim" },
		lazy = false,
		priority = 1000,
		build = ":UpdateRemotePlugins",

		init = function()
			-- Output window configuration (VSCode-like)
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = true
			vim.g.molten_output_show_more = true
			vim.g.molten_output_win_style = "minimal"
			vim.g.molten_output_win_border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
			vim.g.molten_output_win_cover_gutter = false

			-- Virtual text configuration
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = false
			vim.g.molten_virt_text_max_lines = 12
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_lines_off_screen = 1

			-- Image rendering (critical for Ghostty)
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_auto_image_popup = true

			-- Cell detection & highlighting (VSCode-style)
			vim.g.molten_auto_detect_cells = true
			vim.g.molten_cell_delimiter = "# %%"
			vim.g.molten_auto_init_behavior = "init"

			-- Enter output behavior
			vim.g.molten_enter_output_behavior = "open_and_enter"

			-- Tick rate for output updates
			vim.g.molten_tick_rate = 150

			-- Copy output behavior
			vim.g.molten_copy_output = true

			-- Save path for session persistence
			vim.g.molten_save_path = vim.fn.stdpath("data") .. "/molten"
		end,

		config = function()
			local opts = { noremap = true, silent = true }
			local map = vim.keymap.set

			-- Helper function to evaluate cell (uses operator with 'ip' motion)
			local function eval_cell()
				local cursor = vim.api.nvim_win_get_cursor(0)
				vim.cmd("normal! vip")
				vim.cmd("MoltenEvaluateVisual")
				vim.api.nvim_win_set_cursor(0, cursor)
			end

			-- Helper function to evaluate and move to next cell
			local function eval_cell_and_move()
				eval_cell()
				vim.schedule(function()
					vim.cmd("MoltenNext")
				end)
			end

			-- Global keybindings
			map("n", "<leader>mi", function()
				vim.cmd("MoltenInit python3")
			end, { noremap = true, silent = true, desc = "Initialize Molten (Python 3)" })

			map("n", "<leader>mI", function()
				vim.cmd("MoltenInit")
			end, { noremap = true, silent = true, desc = "Initialize Molten (choose kernel)" })

			map("n", "<leader>md", function()
				vim.cmd("MoltenDeinit")
			end, { noremap = true, silent = true, desc = "Stop Molten kernel" })

			map("n", "<leader>mf", function()
				vim.cmd("MoltenInfo")
			end, { noremap = true, silent = true, desc = "Show Molten kernel info" })

			-- Quick notebook creation
			map("n", "<leader>mN", ":NewNotebookHere ", { noremap = true, desc = "New notebook in current dir" })

			-- Buffer-local evaluation & navigation (VSCode-style)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python", "ipynb" },
				callback = function(ev)
					local buf = ev.buf
					local buf_opts = { buffer = buf, noremap = true, silent = true }

					-- Primary cell execution (like VSCode Shift+Enter)
					map("n", "<S-CR>", eval_cell, vim.tbl_extend("force", buf_opts, { desc = "Run cell" }))
					map("n", "<CR>", eval_cell, vim.tbl_extend("force", buf_opts, { desc = "Run cell" }))

					-- Visual mode evaluation
					map(
						"v",
						"<S-CR>",
						":<C-u>MoltenEvaluateVisual<CR>gv",
						vim.tbl_extend("force", buf_opts, { desc = "Run selection" })
					)
					map(
						"v",
						"<CR>",
						":<C-u>MoltenEvaluateVisual<CR>gv",
						vim.tbl_extend("force", buf_opts, { desc = "Run selection" })
					)

					-- Run and move (like VSCode Ctrl+Enter behavior)
					map(
						"n",
						"<C-CR>",
						eval_cell_and_move,
						vim.tbl_extend("force", buf_opts, { desc = "Run cell and go to next" })
					)

					-- Re-run cell
					map("n", "<leader>rr", function()
						vim.cmd("MoltenReevaluateCell")
					end, vim.tbl_extend("force", buf_opts, { desc = "Re-run cell" }))

					-- Evaluate line
					map("n", "<leader>ml", function()
						vim.cmd("MoltenEvaluateLine")
					end, vim.tbl_extend("force", buf_opts, { desc = "Run current line" }))

					-- Evaluate operator (for custom motions)
					map("n", "<leader>me", function()
						vim.cmd("MoltenEvaluateOperator")
					end, vim.tbl_extend("force", buf_opts, { desc = "Evaluate with motion" }))

					-- Cell navigation (VSCode-like)
					map("n", "<leader>mn", function()
						vim.cmd("MoltenNext")
					end, vim.tbl_extend("force", buf_opts, { desc = "Next cell" }))

					map("n", "<leader>mp", function()
						vim.cmd("MoltenPrev")
					end, vim.tbl_extend("force", buf_opts, { desc = "Previous cell" }))

					map("n", "]c", function()
						vim.cmd("MoltenNext")
					end, vim.tbl_extend("force", buf_opts, { desc = "Next cell" }))

					map("n", "[c", function()
						vim.cmd("MoltenPrev")
					end, vim.tbl_extend("force", buf_opts, { desc = "Previous cell" }))

					-- Output management
					map("n", "<leader>mo", function()
						vim.cmd("noautocmd MoltenEnterOutput")
					end, vim.tbl_extend("force", buf_opts, { desc = "Show/enter output" }))

					map("n", "<leader>mh", function()
						vim.cmd("MoltenHideOutput")
					end, vim.tbl_extend("force", buf_opts, { desc = "Hide output" }))

					map("n", "<leader>mx", function()
						vim.cmd("MoltenDelete")
					end, vim.tbl_extend("force", buf_opts, { desc = "Delete cell output" }))

					-- Interrupt kernel
					map("n", "<leader>mq", function()
						vim.cmd("MoltenInterrupt")
					end, vim.tbl_extend("force", buf_opts, { desc = "Interrupt kernel" }))

					-- Session management
					map("n", "<leader>ms", function()
						vim.cmd("MoltenSave")
					end, vim.tbl_extend("force", buf_opts, { desc = "Save Molten session" }))

					map("n", "<leader>mL", function()
						vim.cmd("MoltenLoad")
					end, vim.tbl_extend("force", buf_opts, { desc = "Load Molten session" }))

					--[[ Export to notebook
					map("n", "<leader>mN", function()
						vim.cmd("ToNotebook")
					end, vim.tbl_extend("force", buf_opts, { desc = "Export to .ipynb" }))
                    ]]
					--

					-- Import from jupyter
					map("n", "<leader>mM", function()
						vim.cmd("MoltenImportOutput")
					end, vim.tbl_extend("force", buf_opts, { desc = "Import output from Jupyter" }))

					-- Add Jupytext header
					map("n", "<leader>mH", function()
						vim.cmd("AddJupytextHeader")
					end, vim.tbl_extend("force", buf_opts, { desc = "Add Jupytext header" }))
				end,
			})

			-- Add Jupytext header (VSCode-compatible format)
			vim.api.nvim_create_user_command("AddJupytextHeader", function()
				if vim.bo.filetype ~= "python" then
					vim.notify("Can only add Jupytext header to Python files", vim.log.levels.WARN)
					return
				end

				local ext = vim.fn.expand("%:e")
				if ext == "" then
					vim.notify("Please save the file first", vim.log.levels.WARN)
					return
				end

				local header = {
					"# ---",
					"# jupyter:",
					"#   jupytext:",
					"#     text_representation:",
					"#       extension: .py",
					"#       format_name: percent",
					"#       format_version: '1.3'",
					"#       jupytext_version: 1.19.1",
					"#   kernelspec:",
					"#     display_name: Python 3 (ipykernel)",
					"#     language: python",
					"#     name: python3",
					"# ---",
					"",
				}

				-- Check if header already exists
				local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
				if first_line and first_line:match("^# %-%-%-") then
					vim.notify("Jupytext header already exists", vim.log.levels.INFO)
					return
				end

				vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
				vim.notify("Added Jupytext header", vim.log.levels.INFO)
			end, { desc = "Add VSCode-compatible Jupytext header to Python file" })

			-- Convert current Python buffer to .ipynb
			vim.api.nvim_create_user_command("ToNotebook", function()
				local bufname = vim.fn.expand("%:p")
				if bufname == "" or vim.bo.filetype ~= "python" then
					vim.notify("Not a Python file or no file loaded", vim.log.levels.WARN)
					return
				end

				if vim.bo.modified then
					vim.notify("Please save the file first (:w)", vim.log.levels.WARN)
					return
				end

				local notebook_name = vim.fn.expand("%:r") .. ".ipynb"

				if vim.fn.filereadable(notebook_name) == 1 then
					local choice = vim.fn.input("File '" .. notebook_name .. "' exists. Overwrite? [y/N]: ")
					if choice:lower() ~= "y" then
						vim.notify("Conversion cancelled", vim.log.levels.INFO)
						return
					end
				end

				local cmd = string.format(
					"jupytext --to=ipynb --output=%s %s",
					vim.fn.shellescape(notebook_name),
					vim.fn.shellescape(bufname)
				)
				local result = vim.fn.system(cmd)

				if vim.v.shell_error == 0 then
					vim.notify("Successfully converted to " .. notebook_name, vim.log.levels.INFO)
					vim.ui.select({ "Yes", "No" }, {
						prompt = "Open the notebook file?",
					}, function(choice)
						if choice == "Yes" then
							vim.cmd("edit " .. vim.fn.fnameescape(notebook_name))
						end
					end)
				else
					vim.notify("Conversion failed:\n" .. result, vim.log.levels.ERROR)
				end
			end, { desc = "Convert current Python file to .ipynb using jupytext", nargs = 0 })

			-- Create new notebook file with template
			vim.api.nvim_create_user_command("NewNotebook", function(opts)
				local filename = opts.args
				if filename == "" then
					filename = vim.fn.input("Notebook name (without extension): ")
					if filename == "" then
						vim.notify("Cancelled", vim.log.levels.INFO)
						return
					end
				end

				if not filename:match("%.py$") then
					filename = filename .. ".py"
				end

				if vim.fn.filereadable(filename) == 1 then
					vim.notify("File already exists: " .. filename, vim.log.levels.WARN)
					return
				end

				vim.cmd("edit " .. vim.fn.fnameescape(filename))
				vim.cmd("AddJupytextHeader")

				vim.api.nvim_buf_set_lines(0, -1, -1, false, {
					"# %%",
					"print('Hello, Jupyter!')",
					"",
					"# %%",
					"",
				})

				vim.cmd("write")
				vim.notify("Created notebook: " .. filename, vim.log.levels.INFO)
			end, { desc = "Create new notebook file with Jupytext header", nargs = "?" })

			-- Create new notebook in current directory (for file explorers)
			vim.api.nvim_create_user_command("NewNotebookHere", function(opts)
				local filename = opts.args
				if filename == "" then
					filename = vim.fn.input("Notebook name (without extension): ")
					if filename == "" then
						vim.notify("Cancelled", vim.log.levels.INFO)
						return
					end
				end

				local current_dir = vim.fn.getcwd()
				if not filename:match("%.py$") then
					filename = filename .. ".ipynb"
				end

				local full_path = current_dir .. "/" .. filename

				if vim.fn.filereadable(full_path) == 1 then
					vim.notify("File already exists: " .. filename, vim.log.levels.WARN)
					return
				end

				vim.cmd("edit " .. vim.fn.fnameescape(full_path))

				local header = {
					"# ---",
					"# jupyter:",
					"#   jupytext:",
					"#     text_representation:",
					"#       extension: .py",
					"#       format_name: percent",
					"#       format_version: '1.3'",
					"#       jupytext_version: 1.19.1",
					"#   kernelspec:",
					"#     display_name: Python 3 (ipykernel)",
					"#     language: python",
					"#     name: python3",
					"# ---",
					"",
					"# %%",
					"print('Hello, Jupyter!')",
					"",
					"# %%",
					"",
				}

				vim.api.nvim_buf_set_lines(0, 0, -1, false, header)
				vim.cmd("write")
				vim.notify("Created notebook: " .. filename, vim.log.levels.INFO)
			end, { desc = "Create new notebook in current directory", nargs = "?" })

			-- File explorer integrations
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "oil",
				callback = function(ev)
					vim.keymap.set("n", "<leader>nn", function()
						local oil = require("oil")
						local dir = oil.get_current_dir()
						if dir then
							vim.fn.chdir(dir)
						end
						vim.cmd("NewNotebookHere")
					end, { buffer = ev.buf, desc = "New notebook here" })
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "neo-tree",
				callback = function(ev)
					vim.keymap.set("n", "<leader>nn", function()
						local state = require("neo-tree.sources.manager").get_state("filesystem")
						if state and state.path then
							vim.fn.chdir(state.path)
						end
						vim.cmd("NewNotebookHere")
					end, { buffer = ev.buf, desc = "New notebook here" })
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "NvimTree",
				callback = function(ev)
					vim.keymap.set("n", "<leader>nn", function()
						local api = require("nvim-tree.api")
						local node = api.tree.get_node_under_cursor()
						if node then
							local dir = node.type == "directory" and node.absolute_path
								or vim.fn.fnamemodify(node.absolute_path, ":h")
							vim.fn.chdir(dir)
						end
						vim.cmd("NewNotebookHere")
					end, { buffer = ev.buf, desc = "New notebook here" })
				end,
			})

			-- Auto-init Molten on .ipynb files
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
				pattern = "*.ipynb",
				callback = function(ev)
					local buf = ev.buf
					if vim.b[buf].molten_auto_init_attempted then
						return
					end
					vim.b[buf].molten_auto_init_attempted = true
					vim.schedule(function()
						local ok, _ = pcall(vim.api.nvim_buf_get_var, buf, "molten_initialized")
						if ok then
							return
						end

						vim.defer_fn(function()
							if vim.fn.exists(":MoltenInit") == 2 then
								pcall(vim.cmd, "MoltenInit python3")
							end
						end, 200)
					end)
				end,
				desc = "Auto-initialize Molten once on .ipynb files",
			})

			-- Auto-add Jupytext header to new Python files (optional)
			vim.api.nvim_create_autocmd("BufNewFile", {
				pattern = "*.py",
				callback = function()
					vim.defer_fn(function()
						local choice = vim.fn.input("Add Jupytext header for notebook? [y/N]: ")
						if choice:lower() == "y" then
							vim.cmd("AddJupytextHeader")
							vim.api.nvim_buf_set_lines(0, -1, -1, false, {
								"# %%",
								"",
							})
						end
					end, 100)
				end,
				desc = "Prompt to add Jupytext header to new Python files",
			})

			-- Cell highlighting (VSCode-style visual indicator)
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python", "ipynb" },
				callback = function()
					vim.cmd([[
						syntax match MoltenCell /^# %%.*$/
						highlight MoltenCell guifg=#569CD6 guibg=#1E1E1E gui=bold
						highlight MoltenOutputWin guibg=#1E1E1E
						highlight MoltenOutputBorder guifg=#3E3E42
						highlight MoltenVirtualText guifg=#858585 gui=italic
					]])
				end,
			})

			-- Status line component
			_G.molten_status = function()
				local buf = vim.api.nvim_get_current_buf()
				local ok, kernel = pcall(vim.api.nvim_buf_get_var, buf, "molten_kernel_id")
				if ok and kernel ~= nil then
					return "🐍 " .. kernel
				end
				return ""
			end

			-- Diagnostic command
			vim.api.nvim_create_user_command("MoltenDiagnose", function()
				local lines = {}
				table.insert(lines, "=== Molten Diagnostics ===\n")

				local commands = {
					"MoltenInit",
					"MoltenEvaluateVisual",
					"MoltenEvaluateLine",
					"MoltenEvaluateOperator",
					"MoltenReevaluateCell",
					"MoltenNext",
					"MoltenPrev",
				}
				table.insert(lines, "\nCommand availability:")
				for _, cmd in ipairs(commands) do
					local exists = vim.fn.exists(":" .. cmd) == 2
					table.insert(lines, string.format("  %s: %s", cmd, exists and "✓" or "✗"))
				end

				table.insert(lines, "\nPython host:")
				table.insert(lines, "  " .. (vim.g.python3_host_prog or "not set"))

				local buf = vim.api.nvim_get_current_buf()
				local ok, kernel = pcall(vim.api.nvim_buf_get_var, buf, "molten_kernel_id")
				table.insert(lines, "\nCurrent buffer kernel:")
				table.insert(lines, "  " .. (ok and kernel or "none"))

				table.insert(lines, "\nNote: MoltenEvaluateCell doesn't exist in this version.")
				table.insert(lines, "Using MoltenEvaluateVisual with 'ip' motion instead.")

				vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
			end, { desc = "Diagnose Molten setup" })
		end,
	},

	-- Image backend optimized for Ghostty
	{
		"3rd/image.nvim",
		lazy = true,
		opts = {
			backend = "kitty",
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki", "ipynb" },
				},
			},
			max_height_window_percentage = 50,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			editor_only_render_when_focused = false,
			tmux_show_only_in_active_window = true,
			hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
		},
		rocks = { hererocks = true, enabled = true },
		build = false,
	},

	-- Jupytext.vim for .ipynb ↔ .py conversion
	{
		"goerz/jupytext.vim",
		lazy = false,
		init = function()
			vim.g.jupytext_fmt = "py:percent"
			vim.g.jupytext_filetype_map = { ipynb = "python" }
			vim.g.jupytext_print_debug_msgs = 0
			vim.g.jupytext_enable = 1
		end,
	},
}

--[[
Molten.nvim Setup Memo – February 2026
(Neovim + mise Python 3.12 + CachyOS/Arch + Ghostty)

=== COMPLETE SETUP FROM SCRATCH ===

1. System Dependencies (Arch/CachyOS):
   sudo pacman -S xclip wl-clipboard imagemagick

2. Python Environment Setup:
   mise use python@3.12
   vim.g.python3_host_prog = '/home/jonne/.local/share/mise/installs/python/3.12.12/bin/python'

3. Python Packages (run in one go):
   mise exec python@3.12 -- pip install --user pynvim jupyter_client ipykernel jupytext pyperclip pillow cairosvg plotly kaleido pnglatex matplotlib numpy pandas seaborn

4. Kernel Registration:
   mise exec python@3.12 -- python -m ipykernel install --user --name python3 --display-name "Python 3.12 (mise)"

5. Jupyter Runtime Directory:
   mkdir -p ~/.local/share/jupyter/runtime && chmod 700 ~/.local/share/jupyter/runtime

6. Neovim Plugin Setup:
   - Add molten.lua to ~/.config/nvim/lua/plugins/
   - :Lazy sync
   - :UpdateRemotePlugins
   - Restart Neovim

7. Verification:
   :checkhealth provider.python
   jupyter kernelspec list
   :MoltenDiagnose

=== TROUBLESHOOTING ===

Multiple kernels attached → :MoltenDeinit before :MoltenInit
Commands not found → :UpdateRemotePlugins + restart Neovim
ModuleNotFoundError → mise exec python@3.12 -- pip install --user <module>
Images not rendering → Check Ghostty supports Kitty graphics protocol
Kernel won't start → rm -rf ~/.local/share/jupyter/runtime/* && restart

=== KEY BINDINGS ===

<CR> / <S-CR>    → Run cell          | <leader>mi → Init kernel
<C-CR>           → Run + next cell   | <leader>md → Stop kernel
]c / [c          → Next/prev cell    | <leader>mf → Kernel info
<leader>ml       → Run line          | <leader>mH → Add Jupytext header
<leader>mo       → Show output       | <leader>mN → Export to .ipynb
<leader>mh       → Hide output       | <leader>nn → New notebook here
<leader>mx       → Delete output     | :NewNotebook <name> → Create new
<leader>mq       → Interrupt kernel  | :ToNotebook → Convert to .ipynb
<leader>rr       → Re-run cell       | :MoltenDiagnose → Check setup

=== NOTES ===

MoltenEvaluateCell doesn't exist in v1.0.0 - using MoltenEvaluateVisual with 'ip' motion
Jupytext header format identical to VSCode for full compatibility
Auto-init on .ipynb files, manual init on .py files with :MoltenInit python3
Ghostty uses Kitty graphics protocol for inline image rendering
molten_copy_output requires pyperclip - set to false if not installed
Always :MoltenDeinit before re-initializing to avoid multiple kernel conflicts
<leader>nn works in oil.nvim, neo-tree, nvim-tree, and normal buffers

Verified working: Feb 06, 2026
--]]
