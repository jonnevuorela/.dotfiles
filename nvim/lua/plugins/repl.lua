-- Quarto Stack: Complete notebook experience for Neovim
-- quarto-nvim + molten-nvim + otter.nvim + jupytext.nvim + image.nvim
-- Optimized for Ghostty/Kitty + CachyOS/Arch + mise Python

return {
	-- ============================================
	-- CORE: quarto-nvim (orchestrates everything)
	-- ============================================
	{
		"quarto-dev/quarto-nvim",
		ft = { "quarto", "markdown" },
		dependencies = {
			"jmbuhr/otter.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			debug = false,
			closePreviewOnExit = true,
			lspFeatures = {
				enabled = true,
				chunks = "curly",
				languages = { "python", "r", "julia", "bash", "lua" },
				diagnostics = {
					enabled = true,
					triggers = { "BufWritePost" },
				},
				completion = {
					enabled = true,
				},
			},
			codeRunner = {
				enabled = true,
				default_method = "molten",
				ft_runners = {},
				never_run = { "yaml" },
			},
		},
		config = function(_, opts)
			local quarto = require("quarto")
			quarto.setup(opts)

			-- Quarto preview keymaps
			vim.keymap.set("n", "<leader>Rq", quarto.quartoPreview, { desc = "Quarto preview", silent = true })
			vim.keymap.set(
				"n",
				"<leader>RQ",
				quarto.quartoClosePreview,
				{ desc = "Quarto close preview", silent = true }
			)

			-- Code runner keymaps (quarto.runner delegates to molten)
			local runner = require("quarto.runner")
			vim.keymap.set("n", "<leader>Rr", runner.run_cell, { desc = "Run cell", silent = true })
			vim.keymap.set("n", "<leader>Ra", runner.run_above, { desc = "Run cell and above", silent = true })
			vim.keymap.set("n", "<leader>Rb", runner.run_below, { desc = "Run cell and below", silent = true })
			vim.keymap.set("n", "<leader>RA", runner.run_all, { desc = "Run all cells", silent = true })
			vim.keymap.set("n", "<leader>Rl", runner.run_line, { desc = "Run line", silent = true })
			vim.keymap.set("v", "<leader>Rv", runner.run_range, { desc = "Run visual range", silent = true })
		end,
	},

	-- ============================================
	-- LSP FOR EMBEDDED CODE: otter.nvim
	-- ============================================
	{
		"jmbuhr/otter.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			lsp = {
				diagnostic_update_events = { "BufWritePost" },
				root_dir = function(_, bufnr)
					return vim.fs.root(bufnr or 0, {
						".git",
						"_quarto.yml",
						"package.json",
					}) or vim.fn.getcwd(0)
				end,
			},
			buffers = {
				set_filetype = true,
				write_to_disk = false,
			},
			handle_leading_whitespace = true,
		},
	},

	-- ============================================
	-- CODE RUNNER: molten-nvim (Jupyter kernel)
	-- ============================================
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		lazy = false,
		init = function()
-- Image provider
			vim.g.molten_image_provider = "image.nvim"

			-- Enhanced image handling
			vim.g.molten_image_location = "both"
			vim.g.molten_auto_image_popup = false
			vim.g.molten_output_show_exec_time = true

			-- Auto-show configuration
			vim.g.molten_auto_open_output = true
			vim.g.molten_enter_output_behavior = "open_then_enter"
			vim.g.molten_copy_output = true

			-- Scrollability fixes
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true
			vim.g.molten_virt_text_max_lines = 20
			vim.g.molten_output_virt_lines = true
			vim.g.molten_cover_empty_lines = false

			-- Performance optimization
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_tick_rate = 500

			-- Cell detection (VSCode-compatible percent format)
			vim.g.molten_auto_detect_cells = true

			-- Border style
			vim.g.molten_output_win_border = { "", "━", "", "" }
			vim.g.molten_use_border_highlights = true

			-- Session persistence
			vim.g.molten_save_path = vim.fn.stdpath("data") .. "/molten"
		end,
		config = function()
			local map = vim.keymap.set

			-- Kernel management
			local function choose_kernel()
				local kernels = vim.fn.MoltenAvailableKernels()
				if vim.tbl_isempty(kernels) then
					return nil
				end
				local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
				local kernel_name = nil

				if venv then
					kernel_name = string.match(venv, "/.+/(.+)")
					-- Skip generic .venv names, use parent dir or fallback
					if kernel_name == ".venv" or kernel_name == "venv" then
						kernel_name = string.match(venv, "/([^/]+)/%.?venv$")
					end
					if kernel_name and not vim.tbl_contains(kernels, kernel_name) then
						kernel_name = nil
					end
				end

				if not kernel_name and vim.tbl_contains(kernels, "python3") then
					kernel_name = "python3"
				end

				return kernel_name
			end

			map("n", "<leader>Ri", function()
				local kernel_name = choose_kernel()
				if kernel_name then
					vim.cmd("MoltenInit " .. kernel_name)
					return
				end
				vim.cmd("MoltenInit")
			end, { desc = "Molten init (auto-detect)", silent = true })

			map("n", "<leader>RI", ":MoltenInit<CR>", { desc = "Molten init (choose)", silent = true })
			map("n", "<leader>Rd", ":MoltenDeinit<CR>", { desc = "Molten deinit", silent = true })
			map("n", "<leader>Rs", ":MoltenRestart!<CR>", { desc = "Molten restart", silent = true })
			map("n", "<leader>Rx", ":MoltenInterrupt<CR>", { desc = "Molten interrupt", silent = true })
			map("n", "<leader>Rf", ":MoltenInfo<CR>", { desc = "Molten info", silent = true })

			-- Direct molten evaluation (fallback when not in quarto/markdown)
			map("n", "<leader>Re", ":MoltenEvaluateOperator<CR>", { desc = "Molten evaluate operator", silent = true })
			map("n", "<leader>Rr", ":MoltenEvaluateCell<CR>", { desc = "Molten evaluate cell", silent = true })
			map("n", "<leader>RR", ":MoltenReevaluateCell<CR>", { desc = "Molten re-evaluate cell", silent = true })
			map(
				"v",
				"<leader>Rv",
				":<C-u>MoltenEvaluateVisual<CR>gv",
				{ desc = "Molten evaluate visual", silent = true }
			)

			-- ============================================
			-- VIEW MODES (default vs highlight)
			-- ============================================
			local molten_view = {}
			vim.g.molten_view_mode = "default"

			local STYLES = {
				default = {
					virt_text_output = true,
					virt_lines_off_by_1 = true,
					auto_open_output = false,
					image_location = "both",
					border_hl = "MoltenCellBorder",
				},
				highlight = {
					virt_text_output = true,
					virt_lines_off_by_1 = true,
					auto_open_output = false,
					image_location = "both",
					border_hl = "MoltenCellBorderJukit",
				},
			}

			local function set_border_highlights()
				local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
				local line_nr = vim.api.nvim_get_hl(0, { name = "LineNr" })
				local comment = vim.api.nvim_get_hl(0, { name = "Comment" })
				local statement = vim.api.nvim_get_hl(0, { name = "Statement" })
				local gray = line_nr.fg or comment.fg or normal.fg
				vim.api.nvim_set_hl(0, "MoltenCellBorder", {
					fg = gray,
					bold = true,
					cterm = { bold = true },
					ctermfg = "NONE",
				})
				vim.api.nvim_set_hl(0, "MoltenCellBorderJukit", {
					fg = statement.fg or gray,
					bold = true,
					cterm = { bold = true },
					ctermfg = "NONE",
				})
				vim.api.nvim_set_hl(0, "MoltenOutputWin", {
					fg = normal.fg,
					ctermfg = "NONE",
				})
				vim.api.nvim_set_hl(0, "MoltenOutputWinNC", {
					fg = normal.fg,
					ctermfg = "NONE",
				})
				vim.api.nvim_set_hl(0, "MoltenOutputBorder", {
					fg = gray,
					ctermfg = "NONE",
				})
				vim.api.nvim_set_hl(0, "MoltenOutputFooter", {
					fg = statement.fg or normal.fg,
					ctermfg = "NONE",
				})
			end

			local function apply_view(mode)
				local config = STYLES[mode]
				if not config then
					return
				end
				pcall(vim.fn.MoltenUpdateOption, "virt_text_output", config.virt_text_output)
				pcall(vim.fn.MoltenUpdateOption, "virt_lines_off_by_1", config.virt_lines_off_by_1)
				pcall(vim.fn.MoltenUpdateOption, "auto_open_output", config.auto_open_output)
				pcall(vim.fn.MoltenUpdateOption, "image_location", config.image_location)
				vim.g.molten_cell_border_hl = config.border_hl
			end

			function molten_view.toggle()
				vim.g.molten_view_mode = (vim.g.molten_view_mode == "highlight") and "default" or "highlight"
				apply_view(vim.g.molten_view_mode)
				set_border_highlights()
				vim.notify("View: " .. vim.g.molten_view_mode, vim.log.levels.INFO)
			end

			local function is_molten_initialized()
				local ok, status = pcall(function()
					return require("molten.status").initialized()
				end)
				return ok and status == "Molten"
			end


			set_border_highlights()
			apply_view(vim.g.molten_view_mode)

			-- ============================================
			-- OUTPUT MANAGEMENT
			-- ============================================
			map("n", "<leader>Rv", molten_view.toggle, { desc = "Toggle view (default/highlight)", silent = true })
			map("n", "<leader>Ro", ":noautocmd MoltenEnterOutput<CR>", { desc = "Enter output window", silent = true })
			map("n", "<leader>Rh", ":MoltenHideOutput<CR>", { desc = "Hide output", silent = true })
			map("n", "<leader>RI", ":MoltenImagePopup<CR>", { desc = "Image popup", silent = true })

			-- Cell navigation
			map("n", "]c", ":MoltenNext<CR>", { desc = "Next cell", silent = true })
			map("n", "[c", ":MoltenPrev<CR>", { desc = "Previous cell", silent = true })

			-- Session management
			map("n", "<leader>RS", ":MoltenSave<CR>", { desc = "Molten save session", silent = true })
			map("n", "<leader>RL", ":MoltenLoad<CR>", { desc = "Molten load session", silent = true })

			-- Run cell
			map("n", "<leader><CR>", function()
				local function run_cell()
					vim.cmd("MoltenReevaluateCell")
				end

				if not is_molten_initialized() then
					vim.cmd("MoltenInit")
					local ok = vim.fn.wait(2000, function()
						return is_molten_initialized()
					end, 100)
					if ok == 1 then
						run_cell()
					else
						vim.notify("Molten not initialized", vim.log.levels.WARN)
					end
					return
				end

				run_cell()
			end, { desc = "Run cell", silent = true })

			-- ============================================
			-- AUTO KERNEL INIT FOR .ipynb FILES
			-- ============================================
			local function init_molten_for_ipynb(e)
				vim.schedule(function()
					local kernels = vim.fn.MoltenAvailableKernels()
					if vim.tbl_isempty(kernels) then
						return
					end

					local kernel_name = nil

					-- Try to get kernel from notebook metadata
					local ok, content = pcall(function()
						local f = io.open(e.file, "r")
						if f then
							local data = f:read("*a")
							f:close()
							return vim.json.decode(data)
						end
					end)

					if ok and content and content.metadata and content.metadata.kernelspec then
						kernel_name = content.metadata.kernelspec.name
					end

					-- Fallback to venv name
					if not kernel_name or not vim.tbl_contains(kernels, kernel_name) then
						local venv = os.getenv("VIRTUAL_ENV") or os.getenv("CONDA_PREFIX")
						if venv then
							kernel_name = string.match(venv, "/.+/(.+)")
						end
					end

					-- Final fallback
					if not kernel_name or not vim.tbl_contains(kernels, kernel_name) then
						kernel_name = "python3"
					end

					if vim.tbl_contains(kernels, kernel_name) then
						vim.cmd(("MoltenInit %s"):format(kernel_name))
					end

					-- Import existing outputs
					pcall(vim.cmd, "MoltenImportOutput")
				end)
			end

			vim.api.nvim_create_autocmd("BufAdd", {
				pattern = { "*.ipynb" },
				callback = init_molten_for_ipynb,
			})

			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = { "*.ipynb" },
				callback = function(e)
					if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
						init_molten_for_ipynb(e)
					end
				end,
			})

			-- Auto-export outputs when saving notebooks
			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = { "*.ipynb" },
				callback = function()
					local ok, status = pcall(function()
						return require("molten.status").initialized()
					end)
					if ok and status == "Molten" then
						pcall(vim.cmd, "MoltenExportOutput!")
					end
				end,
			})



			-- ============================================
			-- DIFFERENT SETTINGS FOR DIFFERENT FILETYPES
			-- ============================================
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*.py",
				callback = function(e)
					if string.match(e.file, ".otter.") then
						return
					end
					local ok, status = pcall(function()
						return require("molten.status").initialized()
					end)
					if ok and status == "Molten" then
						vim.fn.MoltenUpdateOption("virt_lines_off_by_1", false)
						vim.fn.MoltenUpdateOption("virt_text_output", false)
					else
						vim.g.molten_virt_lines_off_by_1 = false
						vim.g.molten_virt_text_output = false
					end
				end,
			})

			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = { "*.qmd", "*.md", "*.ipynb" },
				callback = function(e)
					if string.match(e.file, ".otter.") then
						return
					end
					local ok, status = pcall(function()
						return require("molten.status").initialized()
					end)
					if ok and status == "Molten" then
						vim.fn.MoltenUpdateOption("virt_lines_off_by_1", true)
						vim.fn.MoltenUpdateOption("virt_text_output", true)
					else
						vim.g.molten_virt_lines_off_by_1 = true
						vim.g.molten_virt_text_output = true
					end
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					local ok, quarto = pcall(require, "quarto")
					if ok then
						quarto.activate()
					end
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
					vim.opt_local.conceallevel = 2
				end,
			})

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "quarto",
				callback = function()
					vim.opt_local.wrap = true
					vim.opt_local.linebreak = true
					vim.opt_local.conceallevel = 2
				end,
			})

			-- ============================================
			-- CELL HIGHLIGHTING
			-- ============================================
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python", "ipynb" },
				callback = function(ev)
					local ns = vim.api.nvim_create_namespace("molten_cell_border")
					local function clear_ns()
						vim.api.nvim_buf_clear_namespace(ev.buf, ns, 0, -1)
					end
					local function draw_borders()
						clear_ns()
						local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
						local wins = vim.fn.win_findbuf(ev.buf)
						local win_width = 80
						if wins and #wins > 0 then
							win_width = vim.api.nvim_win_get_width(wins[1])
						end
						local cell_starts = {}
						for i, line in ipairs(lines) do
							if line:match("^# %%") then
								table.insert(cell_starts, i)
							end
						end
						if #cell_starts == 0 then
							return
						end
						local last_line = #lines
						local width = math.max(1, win_width - 2)
						local border = vim.g.molten_cell_border_char or "━"
						for idx, start_line in ipairs(cell_starts) do
							local next_marker = cell_starts[idx + 1]
							local top = "┏" .. string.rep(border, width) .. "┓"
							local bottom = "┗" .. string.rep(border, width) .. "┛"
							vim.api.nvim_buf_set_extmark(ev.buf, ns, start_line - 1, 0, {
								virt_lines = { { { top, vim.g.molten_cell_border_hl or "MoltenCellBorder" } } },
								virt_lines_above = true,
							})
							if next_marker then
								vim.api.nvim_buf_set_extmark(ev.buf, ns, next_marker - 1, 0, {
									virt_lines = { { { bottom, vim.g.molten_cell_border_hl or "MoltenCellBorder" } } },
									virt_lines_above = true,
								})
							else
								vim.api.nvim_buf_set_extmark(ev.buf, ns, last_line - 1, 0, {
									virt_lines = { { { bottom, vim.g.molten_cell_border_hl or "MoltenCellBorder" } } },
									virt_lines_above = false,
								})
							end
						end
					end
					draw_borders()
					vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost", "VimResized", "WinResized", "ColorScheme" }, {
						buffer = ev.buf,
						callback = function()
							set_border_highlights()
							draw_borders()
						end,
					})
				end,
			})

			vim.api.nvim_create_autocmd("BufWritePost", {
				pattern = "*.ipynb",
				callback = function()
					if not is_molten_initialized() then
						return
					end
					local kernel_name = choose_kernel()
					pcall(vim.cmd, "silent! MoltenDeinit")
					if kernel_name then
						pcall(vim.cmd, "silent! MoltenInit " .. kernel_name)
					else
						pcall(vim.cmd, "silent! MoltenInit")
					end
				end,
			})

			-- ============================================
			-- NOTEBOOK CREATION COMMANDS
			-- ============================================

			-- Add Jupytext header (VSCode-compatible percent format)
			vim.api.nvim_create_user_command("AddJupytextHeader", function()
				if vim.bo.filetype ~= "python" then
					vim.notify("Can only add Jupytext header to Python files", vim.log.levels.WARN)
					return
				end
				local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
				if first_line and first_line:match("^# %-%-%-") then
					vim.notify("Jupytext header already exists", vim.log.levels.INFO)
					return
				end
				-- Proper YAML indentation for VSCode compatibility
				local header = {
					"# ---",
					"# jupyter:",
					"#   jupytext:",
					"#     text_representation:",
					"#       extension: .py",
					"#       format_name: percent",
					"#       format_version: '1.3'",
					"#       jupytext_version: 1.16.1",
					"#   kernelspec:",
					"#     display_name: Python 3 (ipykernel)",
					"#     language: python",
					"#     name: python3",
					"# ---",
					"",
				}
				vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
				vim.notify("Added Jupytext header", vim.log.levels.INFO)
			end, { desc = "Add VSCode-compatible Jupytext header" })

			-- Convert .py to .ipynb
			vim.api.nvim_create_user_command("ToNotebook", function()
				local bufname = vim.fn.expand("%:p")
				if bufname == "" or vim.bo.filetype ~= "python" then
					vim.notify("Not a Python file", vim.log.levels.WARN)
					return
				end
				if vim.bo.modified then
					vim.notify("Save file first (:w)", vim.log.levels.WARN)
					return
				end
				local notebook_name = vim.fn.expand("%:r") .. ".ipynb"
				if vim.fn.filereadable(notebook_name) == 1 then
					local choice = vim.fn.input("'" .. notebook_name .. "' exists. Overwrite? [y/N]: ")
					if choice:lower() ~= "y" then
						vim.notify("Cancelled", vim.log.levels.INFO)
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
					vim.notify("Converted to " .. notebook_name, vim.log.levels.INFO)
					vim.ui.select({ "Yes", "No" }, { prompt = "Open notebook?" }, function(choice)
						if choice == "Yes" then
							vim.cmd("edit " .. vim.fn.fnameescape(notebook_name))
						end
					end)
				else
					vim.notify("Conversion failed:\n" .. result, vim.log.levels.ERROR)
				end
			end, { desc = "Convert .py to .ipynb" })

			local function write_ipynb(path)
				local notebook = {
					cells = {
						{
							cell_type = "code",
							execution_count = vim.NIL,
							metadata = vim.empty_dict(),
							outputs = {},
							source = { "print('Hello, Jupyter!')\n" },
						},
					},
					metadata = {
						kernelspec = {
							display_name = "Python 3 (ipykernel)",
							language = "python",
							name = "python3",
						},
						language_info = {
							name = "python",
						},
					},
					nbformat = 4,
					nbformat_minor = 5,
				}
				local json = vim.json.encode(notebook)
				local f = io.open(path, "w")
				if not f then
					return false
				end
				f:write(json)
				f:close()
				return true
			end

			-- New notebook in current directory (ipynb)
			vim.api.nvim_create_user_command("NewNotebook", function(opts)
				local filename = opts.args
				if filename == "" then
					filename = vim.fn.input("Notebook name (without extension): ")
					if filename == "" then
						vim.notify("Cancelled", vim.log.levels.INFO)
						return
					end
				end
				if not filename:match("%.ipynb$") then
					filename = filename .. ".ipynb"
				end
				local current_dir = vim.fn.getcwd()
				local full_path = current_dir .. "/" .. filename
				if vim.fn.filereadable(full_path) == 1 then
					vim.notify("File exists: " .. filename, vim.log.levels.WARN)
					return
				end
				local ok = write_ipynb(full_path)
				if not ok then
					vim.notify("Failed to create notebook", vim.log.levels.ERROR)
					return
				end
				vim.cmd("edit " .. vim.fn.fnameescape(full_path))
				vim.notify("Created: " .. filename, vim.log.levels.INFO)
			end, { desc = "Create new notebook", nargs = "?" })

			-- New percent-format .py notebook
			vim.api.nvim_create_user_command("NewNotebookPy", function(opts)
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
				local current_dir = vim.fn.getcwd()
				local full_path = current_dir .. "/" .. filename
				if vim.fn.filereadable(full_path) == 1 then
					vim.notify("File exists: " .. filename, vim.log.levels.WARN)
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
					"#       jupytext_version: 1.16.1",
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
				vim.notify("Created: " .. filename, vim.log.levels.INFO)
			end, { desc = "Create new .py notebook", nargs = "?" })

			-- Keymaps for notebook creation
			map("n", "<leader>RN", ":NewNotebook<CR>", { desc = "New notebook (.ipynb)", silent = true })
			map("n", "<leader>Rn", ":NewNotebook ", { desc = "New notebook (.ipynb name)" })
			map("n", "<leader>Rp", ":NewNotebookPy<CR>", { desc = "New notebook (.py)", silent = true })
			map("n", "<leader>RH", ":AddJupytextHeader<CR>", { desc = "Add Jupytext header", silent = true })
			map("n", "<leader>RC", ":ToNotebook<CR>", { desc = "Convert to .ipynb", silent = true })

			-- Oil.nvim integration
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "oil",
				callback = function(ev)
					vim.keymap.set("n", "<leader>Rn", function()
						local ok, oil = pcall(require, "oil")
						if ok then
							local dir = oil.get_current_dir()
							if dir then
								vim.fn.chdir(dir)
							end
						end
						vim.cmd("NewNotebook")
					end, { buffer = ev.buf, desc = "New notebook here" })
				end,
			})

			-- ============================================
			-- STATUS LINE COMPONENT
			-- ============================================
			_G.molten_status = function()
				local ok, status = pcall(function()
					return require("molten.status")
				end)
				if ok and status.initialized() == "Molten" then
					return " " .. status.kernels()
				end
				return ""
			end
		end,
	},

	-- ============================================
	-- IMAGE RENDERING: image.nvim
	-- ============================================
	{
		"3rd/image.nvim",
		lazy = true,
		opts = {
			backend = "kitty",
			processor = "magick_cli",
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki", "quarto", "ipynb" },
				},
			},
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true,
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
	},

	-- ============================================
	-- NOTEBOOK CONVERSION: jupytext.nvim
	-- ============================================
	{
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		opts = {
			style = "percent",
			output_extension = "auto",
			force_ft = "python",
		},
	},
}

--[[
=== Quarto Stack Dependencies ===

1. System Packages (Arch/CachyOS)
   sudo pacman -S --needed python ipython imagemagick xclip wl-clipboard

   # Quarto CLI (optional, for preview features)
   yay -S quarto-cli-bin

2. Python Packages (mise global or dedicated venv)

   # Option A: mise global
   mise use python@3.12
   mise exec python@3.12 -- pip install --user --upgrade \
     pynvim jupyter_client ipykernel jupytext nbformat \
     pyperclip pillow cairosvg plotly kaleido pnglatex \
     matplotlib numpy pandas seaborn

   # Option B: Dedicated neovim venv (recommended)
   mkdir -p ~/.virtualenvs
   python -m venv ~/.virtualenvs/neovim
   source ~/.virtualenvs/neovim/bin/activate
   pip install pynvim jupyter_client ipykernel jupytext nbformat \
     pyperclip pillow cairosvg plotly kaleido pnglatex

3. Kernel Registration (for each project venv)

   # Activate your project venv first, then:
   pip install ipykernel
   python -m ipykernel install --user --name my_project_name --display-name "My Project"

   # Or register mise Python:
   mise exec python@3.12 -- python -m ipykernel install --user \
     --name python3 --display-name "Python 3.12 (mise)"

4. Jupyter Runtime Permissions
   mkdir -p ~/.local/share/jupyter/runtime
   chmod 700 ~/.local/share/jupyter/runtime

5. List Available Kernels
   jupyter kernelspec list

6. Neovim Steps
   :Lazy sync
   :UpdateRemotePlugins
   Restart Neovim

7. Verification
   :checkhealth provider
   :MoltenInfo
   jupyter kernelspec list

=== Keymap Summary (<leader>R prefix) ===

Kernel Management:
- <leader>Ri    Init kernel (auto-detect venv)
- <leader>RI    Init kernel (manual selection)
- <leader>Rd    Deinit kernel
- <leader>Rs    Restart kernel
- <leader>Rx    Interrupt execution
- <leader>Rf    Kernel info

Code Execution:
- <leader>Rr    Run current cell
- <leader>Ra    Run cell + all above
- <leader>Rb    Run cell + all below
- <leader>RA    Run all cells
- <leader>Rl    Run current line
- <leader>Rv    Run visual selection (visual mode)
- <leader>Re    Evaluate operator (motion)

Output Management:
- <leader>Ro    Enter output window
- <leader>Rh    Hide output
- <leader>Rp    Image popup

Session Management:
- <leader>RS    Save session
- <leader>RL    Load session

Cell Navigation:
- ]c / [c       Next/previous cell

Notebook Creation:
- <leader>RN    New notebook in current dir
- <leader>Rn    New notebook (prompt name)
- <leader>RH    Add Jupytext header
- <leader>Rt    Convert .py to .ipynb

Quarto (markdown/qmd files):
- <leader>Rq    Quarto preview
- <leader>RQ    Close preview
]]
