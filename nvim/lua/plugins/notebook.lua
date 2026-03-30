return {
	{
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		opts = {
			style = "percent",
			output_extension = "py",
			force_ft = "python",
		},
		config = function(_, opts)
			require("jupytext").setup(opts)
		end,
	},

	{
		"benlubas/molten-nvim",
		build = ":UpdateRemotePlugins",
		lazy = false,
		dependencies = {
			{
				"3rd/image.nvim",
				opts = {
					backend = "kitty",
					integrations = { markdown = { enabled = false } },
					max_height_window_percentage = 50,
					kitty_method = "normal",
					window_overlap_clear_enabled = false,
				},
				config = function(_, opts)
					require("image").setup(opts)

					-- Patch image.nvim to suppress E966 (invalid line number) and EPIPE errors
					local ok, renderer = pcall(require, "image/renderer")
					if ok and renderer and renderer.render then
						local orig_render = renderer.render
						_G._image_screenpos_orig = vim.fn.screenpos
						renderer.render = function(image)
							local tmp = vim.fn.screenpos
							vim.fn.screenpos = function(win, line, col)
								local ok_sp, pos = pcall(tmp, win, line, col)
								if not ok_sp then
									return { row = 0, col = 0, winrow = 0, wincol = 0 }
								end
								return pos
							end
							local result = orig_render(image)
							vim.fn.screenpos = tmp
							return result
						end
					end

					local ok2, helpers = pcall(require, "image/backends/kitty/helpers")
					if ok2 and helpers and helpers.write then
						local orig_write = helpers.write
						helpers.write = function(data, tty, escape)
							pcall(orig_write, data, tty, escape)
						end
					end
				end,
			},
		},
		config = function()
			local uv = vim.uv or vim.loop

			-- -------------------------
			-- small helpers
			-- -------------------------
			local function path_exists(p)
				return p and uv.fs_stat(p) ~= nil
			end
			local function join(...)
				return table.concat({ ... }, "/")
			end
			local function dirname(p)
				return vim.fn.fnamemodify(p, ":h")
			end
			local function is_exec(p)
				return p and vim.fn.executable(p) == 1
			end
			local function cwd()
				return vim.fn.getcwd()
			end
			local function cmd_exists(cmd)
				return vim.fn.exists(":" .. cmd) == 2
			end
			local function fn_exists(fn)
				return vim.fn.exists("*" .. fn) == 1
			end
			local function notify(msg, lvl, opts)
				vim.notify(msg, lvl or vim.log.levels.INFO, opts)
			end

			local function find_up(start, names)
				local dir = start
				while dir and dir ~= "" do
					for _, n in ipairs(names) do
						local c = join(dir, n)
						if path_exists(c) then
							return c
						end
					end
					local parent = dirname(dir)
					if parent == dir then
						break
					end
					dir = parent
				end
				return nil
			end

			-- -------------------------
			-- python/kernel helpers
			-- -------------------------
			local function project_venv_python()
				local venv_dir = find_up(cwd(), { ".venv" })
				if venv_dir then
					local py = join(venv_dir, "bin", "python")
					if is_exec(py) then
						return py
					end
				end
				return nil
			end

			local function detect_python()
				local venv = os.getenv("VIRTUAL_ENV")
				if venv then
					local py = join(venv, "bin", "python")
					if is_exec(py) then
						return py, "VIRTUAL_ENV"
					end
				end

				local conda = os.getenv("CONDA_PREFIX")
				if conda then
					local py = join(conda, "bin", "python")
					if is_exec(py) then
						return py, "CONDA_PREFIX"
					end
				end

				local local_py = project_venv_python()
				if local_py then
					return local_py, ".venv"
				end

				if vim.fn.executable("mise") == 1 then
					local out = vim.fn.systemlist({ "mise", "which", "python" })
					if vim.v.shell_error == 0 and out[1] and is_exec(out[1]) then
						return out[1], "mise"
					end
				end

				if vim.fn.executable("python3") == 1 then
					return vim.fn.exepath("python3"), "system-python3"
				end
				if vim.fn.executable("python") == 1 then
					return vim.fn.exepath("python"), "system-python"
				end
				return nil, "none"
			end

			local function kernel_name(py)
				if not py then
					return "n/a"
				end
				return "py_" .. py:gsub("[^%w]+", "_")
			end

			local function py_has_module(py, module)
				if not py or not is_exec(py) then
					return false
				end
				vim.fn.system({ py, "-c", ("import %s"):format(module) })
				return vim.v.shell_error == 0
			end

			local function ensure_ipykernel(py)
				if py_has_module(py, "ipykernel") then
					return true
				end
				vim.fn.system({ py, "-m", "pip", "install", "-U", "ipykernel" })
				return vim.v.shell_error == 0
			end

			local function ensure_kernel(py)
				local name = kernel_name(py)
				vim.fn.system({
					py,
					"-m",
					"ipykernel",
					"install",
					"--user",
					"--name",
					name,
					"--display-name",
					("Python (%s)"):format(name),
				})
				if vim.v.shell_error ~= 0 then
					return nil
				end
				return name
			end

			local function molten_is_kernel_idle()
				if not vim.b._nb_kernel_ready then
					return true
				end
				if vim.fn.exists("*MoltenRunningKernels") ~= 1 then
					return true
				end
				local ok, kernels = pcall(vim.fn.MoltenRunningKernels, true)
				if not ok or not kernels or #kernels == 0 then
					return true
				end
				return false
			end

			local function normalize_cell_content(content)
				if type(content) == "table" then
					content = table.concat(content, "\n")
				end
				content = content:gsub("\r\n", "\n"):gsub("\r", "\n")
				local lines = {}
				for line in content:gmatch("[^\n]*") do
					if line:match "^%s*#%s*%%%%" then
					elseif not line:match "^%s*$" and not line:match "^%s*#"then
						table.insert(lines, line)
					end
				end
				return table.concat(lines, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
			end

			local function ensure_notebook_metadata(nb)
				if not nb.metadata then
					nb.metadata = {}
				end
				if not nb.metadata.kernelspec then
					nb.metadata.kernelspec = {
						display_name = "Python 3",
						language = "python",
						name = "python3",
					}
				end
				nb.metadata.language_info = nil
				nb.nbformat = 4
				nb.nbformat_minor = 5
				return nb
			end

			local function write_ipynb(nb, filepath)
				local encoded = vim.json.encode(nb)
				local python_cmd = string.format(
					"import json; import sys; json.dump(json.load(sys.stdin), sys.stdout, indent=1, ensure_ascii=False, separators=(',', ': '))"
				)
				local formatted = vim.fn.system(string.format("python3 -c '%s'", python_cmd), encoded)
				if vim.v.shell_error == 0 and formatted and #formatted > 0 then
					vim.fn.writefile(vim.split(formatted, "\n"), filepath)
				else
					vim.fn.writefile({ encoded }, filepath)
				end
			end

			local function ensure_ipynb_metadata_file(filepath)
				if vim.fn.filereadable(filepath) == 0 then
					return false
				end
				local content = table.concat(vim.fn.readfile(filepath), "\n")
				local ok, nb = pcall(vim.json.decode, content)
				if not ok or not nb then
					return false
				end
				ensure_notebook_metadata(nb)
				write_ipynb(nb, filepath)
				return true
			end

			local function sync_outputs_to_ipynb(bufnr)
				local ipynb_path = vim.b[bufnr].ipynb_source
				if not ipynb_path or ipynb_path == "" then
					return false
				end

				if vim.fn.filereadable(ipynb_path) == 0 then
					notify("Notebook file not found: " .. ipynb_path, vim.log.levels.WARN)
					return false
				end

				local temp_json = vim.fn.tempname() .. ".json"
				vim.cmd("MoltenSave " .. vim.fn.fnameescape(temp_json))

				if vim.fn.filereadable(temp_json) == 0 then
					notify("Failed to save Molten state", vim.log.levels.WARN)
					return false
				end

				local ok, molten_data = pcall(vim.json.decode, table.concat(vim.fn.readfile(temp_json), "\n"))
				vim.fn.delete(temp_json)

				if not ok or not molten_data then
					notify("Failed to parse Molten state", vim.log.levels.WARN)
					return false
				end

				local nb_content = vim.fn.readfile(ipynb_path)
				local ok2, nb = pcall(vim.json.decode, table.concat(nb_content, "\n"))
				if not ok2 or not nb then
					notify("Failed to parse notebook: " .. ipynb_path, vim.log.levels.WARN)
					return false
				end

				if not nb.cells or #nb.cells == 0 then
					notify("Notebook has no cells", vim.log.levels.WARN)
					return false
				end

				local molten_cells = {}
				if molten_data.cells then
					for _, cell_data in ipairs(molten_data.cells) do
						if cell_data.chunks and #cell_data.chunks > 0 then
							table.insert(molten_cells, cell_data)
						end
					end
				end

				if #molten_cells == 0 then
					return true
				end

				local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
				local buf_line_count = #buf_lines

				local function get_line_range(span)
					if not span or not span.begin or not span["end"] then
						return nil, nil
					end
					local start_line = span.begin.lineno
					local end_line = span["end"].lineno
					if start_line == nil or end_line == nil then
						return nil, nil
					end
					start_line = start_line + 1
					end_line = end_line + 1
					if start_line < 1 or end_line < 1 then
						return nil, nil
					end
					if start_line > buf_line_count or end_line > buf_line_count then
						return nil, nil
					end
					if start_line > end_line then
						return nil, nil
					end
					return start_line, end_line
				end

				local function get_cell_code(start_line, end_line)
					if not start_line or not end_line then
						return nil
					end
					local code_lines = {}
					for i = start_line, end_line do
						if buf_lines[i] and buf_lines[i] ~= "" then
							table.insert(code_lines, buf_lines[i])
						end
					end
					if #code_lines == 0 then
						return nil
					end
					return table.concat(code_lines, "\n")
				end

				for _, molten_cell in ipairs(molten_cells) do
					local start_line, end_line = get_line_range(molten_cell.span)
					if start_line and end_line then
						local molten_code = get_cell_code(start_line, end_line)
						if molten_code and molten_code ~= "" then
							molten_cell.code = normalize_cell_content(molten_code)
						end
					end
				end

				local nb_code_cells = {}
				for i, cell in ipairs(nb.cells) do
					if cell.cell_type == "code" then
						local cell_code = normalize_cell_content(cell.source or "")
						table.insert(nb_code_cells, { index = i, code = cell_code })
					end
				end

				local matched = 0
				for _, molten_cell in ipairs(molten_cells) do
					if molten_cell.code then
						for _, nb_cell_info in ipairs(nb_code_cells) do
							if nb_cell_info.code == molten_cell.code then
								local nb_cell = nb.cells[nb_cell_info.index]
								local outputs = {}
								for _, chunk in ipairs(molten_cell.chunks) do
local output = {
									output_type = molten_cell.execution_count and "execute_result" or "display_data",
									data = chunk.data,
									metadata = chunk.metadata or {},
								}
									if molten_cell.execution_count then
										output.execution_count = molten_cell.execution_count
									end
									table.insert(outputs, output)
								end
								nb_cell.outputs = outputs
								if molten_cell.execution_count then
									nb_cell.execution_count = molten_cell.execution_count
								end
								matched = matched + 1
								break
							end
						end
					end
				end

				if matched == 0 and #molten_cells > 0 then
					local valid_cells = 0
					for _, mc in ipairs(molten_cells) do
						if mc.code and mc.code ~= "" then
							valid_cells = valid_cells + 1
						end
					end
					if valid_cells == 0 then
						notify("No valid cells to sync (spans outside buffer bounds)", vim.log.levels.WARN)
					else
						notify("No matching cells found for " .. valid_cells .. " outputs", vim.log.levels.WARN)
					end
				end

				if matched > 0 then
					ensure_notebook_metadata(nb)
					write_ipynb(nb, ipynb_path)
				end

				return true
			end

			local function molten_export_on_done(bufnr, start_time, timeout_ms)
				local now = vim.uv or vim.loop
				local elapsed = (now.hrtime() - start_time) / 1e6
				if elapsed > (timeout_ms or 30000) then
					return
				end
				if molten_is_kernel_idle() then
					sync_outputs_to_ipynb(bufnr)
				else
					vim.defer_fn(function()
						molten_export_on_done(bufnr, start_time, timeout_ms)
					end, 100)
				end
			end

			local function molten_import_outputs(bufnr)
				local ipynb_path = vim.b[bufnr].ipynb_source
				if not ipynb_path or ipynb_path == "" then
					return false
				end
				if vim.fn.exists(":MoltenImportOutput") ~= 2 then
					return false
				end
				if not vim.b[bufnr]._nb_kernel_ready then
					return false
				end
				local ok = pcall(vim.cmd, "MoltenImportOutput " .. vim.fn.fnameescape(ipynb_path))
				return ok
			end

			local function molten_init_auto()
				local py, src = detect_python()
				if not py then
					notify("No python found for kernel", vim.log.levels.ERROR)
					return false
				end
				if not ensure_ipykernel(py) then
					notify("Failed installing ipykernel in " .. py, vim.log.levels.ERROR)
					return false
				end
				local k = ensure_kernel(py)
				if not k then
					notify("Failed registering kernel " .. kernel_name(py), vim.log.levels.ERROR)
					return false
				end
				if not cmd_exists("MoltenInit") then
					notify("MoltenInit missing. Run :UpdateRemotePlugins and restart.", vim.log.levels.ERROR)
					return false
				end

				vim.cmd("MoltenInit " .. k)
				vim.b._nb_kernel_ready = true
				vim.b._nb_kernel_name = k
				notify(("Molten initialized: %s [%s]"):format(k, src))

				return true
			end

			-- -------------------------
			-- cell detection
			-- -------------------------
			local function is_cell_delim(line)
				return line and line:match("^%s*#%s*%%%%") ~= nil
			end

			local function get_lines_1based(bufnr)
				local total = vim.api.nvim_buf_line_count(bufnr)
				local z = vim.api.nvim_buf_get_lines(bufnr, 0, total, false)
				local out = {}
				for i = 1, total do
					out[i] = z[i]
				end
				return out, total
			end

			local function trim_blank(lines, s, e)
				while s <= e and (lines[s] or ""):match("^%s*$") do
					s = s + 1
				end
				while e >= s and (lines[e] or ""):match("^%s*$") do
					e = e - 1
				end
				if s > e then
					return nil, nil
				end
				return s, e
			end

			local function current_cell_range(bufnr, row1)
				local lines, total = get_lines_1based(bufnr)
				if total == 0 then
					return nil, nil
				end

				local row = math.max(1, math.min(row1, total))
				local up, down

				for i = row, 1, -1 do
					if is_cell_delim(lines[i]) then
						up = i
						break
					end
				end
				for i = row + 1, total do
					if is_cell_delim(lines[i]) then
						down = i
						break
					end
				end

				local s = up and (up + 1) or 1
				local e = down and (down - 1) or total
				return trim_blank(lines, s, e)
			end

			-- -------------------------
			-- robust run without visual-mode artifacts ("c>")
			-- -------------------------
			local function ensure_kernel_ready_once()
				if vim.b._nb_kernel_ready then
					return true
				end
				return molten_init_auto()
			end

			local function eval_range_via_function(s, e)
				local ok = pcall(vim.fn.MoltenEvaluateRange, "%k", s, e, 1, vim.v.maxcol)
				return ok
			end

			local function eval_range_via_visual_clean(s, e)
				if not cmd_exists("MoltenEvaluateVisual") then
					return false
				end

				local function keys(k)
					return vim.api.nvim_replace_termcodes(k, true, false, true)
				end

				vim.api.nvim_feedkeys(keys("<Esc>"), "nx", false)

				vim.api.nvim_win_set_cursor(0, { s, 0 })
				vim.api.nvim_feedkeys(keys("V"), "nx", false)
				vim.api.nvim_win_set_cursor(0, { e, 0 })

				vim.cmd("MoltenEvaluateVisual")
				return true
			end

			local function molten_eval_range(s, e)
				if not s or not e then
					notify("No executable region found", vim.log.levels.WARN)
					return false
				end
				if not ensure_kernel_ready_once() then
					return false
				end

				local ok = eval_range_via_function(s, e) or eval_range_via_visual_clean(s, e)

				if not ok then
					notify("No compatible Molten range evaluation method found.", vim.log.levels.ERROR)
					return false
				end

				if vim.b.ipynb_source then
					local now = vim.uv or vim.loop
					molten_export_on_done(vim.api.nvim_get_current_buf(), now.hrtime(), 30000)
				end

				return true
			end

			local function run_current_cell()
				local bufnr = vim.api.nvim_get_current_buf()
				local row = vim.api.nvim_win_get_cursor(0)[1]
				local s, e = current_cell_range(bufnr, row)
				molten_eval_range(s, e)
			end

			local function run_top_to_current_cell()
				local bufnr = vim.api.nvim_get_current_buf()
				local row = vim.api.nvim_win_get_cursor(0)[1]
				local _, e = current_cell_range(bufnr, row)
				if not e then
					notify("No executable range found", vim.log.levels.WARN)
					return
				end
				molten_eval_range(1, e)
			end

			-- -------------------------
			-- notebook tooling commands
			-- -------------------------
			local function notebook_bootstrap(opts)
				local force = opts and opts.bang or false
				local project_dir = cwd()
				local venv_dir = join(project_dir, ".venv")
				local venv_py = join(venv_dir, "bin", "python")

				if not is_exec(venv_py) then
					local base_py = vim.fn.executable("python3") == 1 and vim.fn.exepath("python3")
						or (vim.fn.executable("python") == 1 and vim.fn.exepath("python"))
					if not base_py then
						notify("No python/python3 found to create .venv", vim.log.levels.ERROR)
						return
					end
					notify("Creating .venv ...")
					vim.fn.system({ base_py, "-m", "venv", venv_dir })
					if vim.v.shell_error ~= 0 or not is_exec(venv_py) then
						notify("Failed to create .venv", vim.log.levels.ERROR)
						return
					end
				end

				vim.fn.system({ venv_py, "-m", "pip", "install", "-U", "pip" })

				local req = join(project_dir, "requirements.txt")
				if path_exists(req) then
					notify("Installing requirements.txt ...")
					vim.fn.system({ venv_py, "-m", "pip", "install", "-r", req })
					if vim.v.shell_error ~= 0 then
						notify("requirements install failed", vim.log.levels.WARN)
					end
				else
					notify("No requirements.txt found (skipping)")
				end

				local args = { venv_py, "-m", "pip", "install" }
				if force then
					table.insert(args, "-U")
				end
				vim.list_extend(args, { "jupytext", "pynvim", "jupyter-client", "ipykernel" })
				vim.fn.system(args)

				if vim.v.shell_error ~= 0 then
					notify("Notebook tooling install failed", vim.log.levels.ERROR)
					return
				end
				notify("Notebook bootstrap done (.venv ready)")
			end

			local function notebook_doctor()
				local py, src = detect_python()
				local lines = {
					"=== NotebookDoctor ===",
					"cwd: " .. cwd(),
					"python source: " .. (src or "none"),
					"python path: " .. (py or "none"),
					"kernel name: " .. kernel_name(py),
					"",
					"executables:",
					("  jupytext: %s"):format(vim.fn.executable("jupytext") == 1 and "ok" or "missing"),
					("  python3 : %s"):format(vim.fn.executable("python3") == 1 and "ok" or "missing"),
					("  mise    : %s"):format(vim.fn.executable("mise") == 1 and "ok" or "missing"),
					"",
					"python modules:",
					("  ipykernel     : %s"):format(py_has_module(py, "ipykernel") and "ok" or "missing"),
					("  jupyter_client: %s"):format(py_has_module(py, "jupyter_client") and "ok" or "missing"),
					("  pynvim        : %s"):format(py_has_module(py, "pynvim") and "ok" or "missing"),
					("  jupytext      : %s"):format(py_has_module(py, "jupytext") and "ok" or "missing"),
					"",
					"molten:",
					("  :MoltenInit           : %s"):format(cmd_exists("MoltenInit") and "ok" or "missing"),
					("  :MoltenEvaluateVisual : %s"):format(cmd_exists("MoltenEvaluateVisual") and "ok" or "missing"),
					("  *MoltenEvaluateRange  : %s"):format(
						fn_exists("MoltenEvaluateRange") == 1 and "ok" or "missing"
					),
					("  b:_nb_kernel_ready    : %s"):format(vim.b._nb_kernel_ready and "true" or "false"),
					("  b:_nb_kernel_name     : %s"):format(vim.b._nb_kernel_name or "n/a"),
					"",
					"quick fixes:",
					"  - Run :UpdateRemotePlugins then restart nvim if Molten commands/functions are missing",
					"  - Run <leader>Ri to init kernel once per session/buffer",
					"  - Ensure your file uses # %% delimiters",
				}
				notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "NotebookDoctor" })
			end

			local function ensure_ipynb_name(arg)
				local name = (arg and arg ~= "") and arg or nil
				if not name then
					return nil
				end
				if not name:match("%.ipynb$") then
					name = name .. ".ipynb"
				end
				return vim.fn.fnamemodify(name, ":p")
			end

			local function notebook_gen(opts)
				local target = ensure_ipynb_name(opts.args)
				if not target then
					notify("Usage: :NotebookGen <name|path.ipynb>", vim.log.levels.ERROR)
					return
				end

				if path_exists(target) then
					notify("File exists: " .. target, vim.log.levels.WARN)
					vim.cmd("edit " .. vim.fn.fnameescape(target))
					return
				end

				local nb = {
					cells = {},
					metadata = {
						kernelspec = {
							display_name = "Python 3",
							language = "python",
							name = "python3",
						},
					},
					nbformat = 4,
					nbformat_minor = 5,
				}
				ensure_notebook_metadata(nb)
				write_ipynb(nb, target)
				notify("Created " .. target)
				vim.cmd("edit " .. vim.fn.fnameescape(target))
			end

			local function sync_current_to_ipynb()
				local buf = vim.api.nvim_get_current_buf()
				local name = vim.api.nvim_buf_get_name(buf)
				if name == "" then
					notify("Save buffer first", vim.log.levels.WARN)
					return
				end

				local target = name:match("%.ipynb$") and name or (name:gsub("%.[^%.]+$", "") .. ".ipynb")
				local tmp = vim.fn.tempname() .. ".py"
				local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				vim.fn.writefile(lines, tmp)

				vim.fn.system({ "jupytext", "--to", "ipynb", "--output", target, tmp })
				vim.fn.delete(tmp)

				if vim.v.shell_error ~= 0 then
					notify("NotebookSync failed. Is jupytext installed?", vim.log.levels.ERROR)
					return
				end

				ensure_ipynb_metadata_file(target)
				notify("Synced -> " .. target)
			end

			-- -------------------------
			-- ipynb read/write
			-- -------------------------
			vim.api.nvim_create_autocmd("BufReadCmd", {
				pattern = "*.ipynb",
				callback = function(args)
					local out = vim.fn.systemlist({ "jupytext", "--to", "py:percent", "--output", "-", args.file })
					if vim.v.shell_error ~= 0 or not out or #out == 0 then
						local raw = vim.fn.readfile(args.file)
						vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, raw)
						vim.bo[args.buf].filetype = "json"
						vim.bo[args.buf].modified = false
						notify(
							"jupytext failed; opened raw json. Run :NotebookDoctor / :NotebookBootstrap",
							vim.log.levels.WARN
						)
						return
					end
					vim.api.nvim_buf_set_lines(args.buf, 0, -1, false, out)
					vim.bo[args.buf].filetype = "python"
					vim.bo[args.buf].modified = false
					vim.b[args.buf].ipynb_source = args.file

					if vim.b[args.buf]._nb_kernel_ready then
						vim.defer_fn(function()
							molten_import_outputs(args.buf)
						end, 200)
					end
				end,
			})

			vim.api.nvim_create_autocmd("BufWriteCmd", {
				pattern = "*.ipynb",
				callback = function(args)
					if vim.bo[args.buf].filetype == "json" then
						local raw = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
						vim.fn.writefile(raw, args.file)
						vim.bo[args.buf].modified = false
						notify("Wrote raw json ipynb: " .. args.file)
						return
					end

					local lines = vim.api.nvim_buf_get_lines(args.buf, 0, -1, false)
					local tmp = vim.fn.tempname() .. ".py"
					vim.fn.writefile(lines, tmp)

					local target = vim.b[args.buf].ipynb_source or args.file
					vim.fn.system({ "jupytext", "--to", "ipynb", "--update", "--output", target, tmp })
					vim.fn.delete(tmp)

					if vim.v.shell_error ~= 0 then
						notify("Failed writing ipynb via jupytext", vim.log.levels.ERROR)
						return
					end

					ensure_ipynb_metadata_file(target)

					if vim.b[args.buf].ipynb_source and vim.b[args.buf]._nb_kernel_ready then
						sync_outputs_to_ipynb(args.buf)
					end

					vim.bo[args.buf].modified = false
					notify("Synced -> " .. target)
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "MoltenKernelReady",
				callback = function()
					local bufnr = vim.api.nvim_get_current_buf()
					if vim.b[bufnr].ipynb_source then
						molten_import_outputs(bufnr)
					end
				end,
			})

			-- -------------------------
			-- molten + lsp config
			-- -------------------------
			vim.g.molten_auto_open_output = false
			vim.g.molten_wrap_output = false
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true
			vim.g.molten_output_win_max_height = 120
			vim.g.molten_output_win_max_width = 120
			vim.g.molten_virt_text_max_lines = 120
			vim.g.molten_output_show_more = false
			vim.g.molten_image_provider = "image.nvim"

			local defaults_io = require("config.defaults")
			local defaults = { state = defaults_io.ensure() }

			local function molten_set_output_mode(mode)
				local virt = mode == "virt"
				vim.g.molten_virt_text_output = virt
				vim.g.molten_auto_open_output = not virt
				if vim.fn.exists("*MoltenUpdateOption") == 1 then
					vim.fn.MoltenUpdateOption("virt_text_output", virt)
					vim.fn.MoltenUpdateOption("auto_open_output", not virt)
				end
				if not virt and vim.fn.exists(":MoltenEnterOutput") == 2 then
					pcall(vim.cmd, "MoltenEnterOutput")
				end
			end

			if defaults.state.molten_output_mode then
				molten_set_output_mode(defaults.state.molten_output_mode)
			end

			local function molten_toggle_output_mode()
				local next_mode = vim.g.molten_virt_text_output and "window" or "virt"
				molten_set_output_mode(next_mode)
				defaults.state.molten_output_mode = next_mode
				defaults_io.save(defaults.state, "molten_output_mode", next_mode)
				notify("Molten output: " .. next_mode)
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python" },
				callback = function(ev)
					vim.b[ev.buf].molten_cell_delimiter = "# %%"

					-- cell delimiter bar visualization
					vim.api.nvim_set_hl(0, "NotebookCellDelimiter", { bg = "#404040", fg = "#808080" })
					local ns = vim.api.nvim_create_namespace("notebook_cell_delim")
					local function update_delim_hl(bufnr)
						vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
						local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
						for i, line in ipairs(lines) do
							if line:match("^%s*#%s*%%%%") then
								vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
									line_hl_group = "NotebookCellDelimiter",
								})
							end
						end
					end
					update_delim_hl(ev.buf)
					vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "TextChangedI" }, {
						buffer = ev.buf,
						callback = function()
							update_delim_hl(ev.buf)
						end,
					})

					local has_py_lsp = false
					for _, c in ipairs(vim.lsp.get_clients({ bufnr = ev.buf })) do
						if c.name == "pyright" or c.name == "basedpyright" or c.name == "pylsp" then
							has_py_lsp = true
							break
						end
					end

					if not has_py_lsp then
						pcall(function()
							vim.lsp.enable("pyright")
						end)
						pcall(function()
							vim.lsp.enable("basedpyright")
						end)
					end
				end,
			})

			-- -------------------------
			-- commands
			-- -------------------------
			vim.api.nvim_create_user_command("NotebookBootstrap", notebook_bootstrap, {
				bang = true,
				desc = "Create .venv, install requirements + notebook deps (! = force -U)",
			})

			vim.api.nvim_create_user_command("NotebookDoctor", notebook_doctor, {
				desc = "Show notebook env/kernel/lsp diagnostics",
			})

			vim.api.nvim_create_user_command("NotebookGen", notebook_gen, {
				nargs = 1,
				complete = "file",
				desc = "Create new ipynb: :NotebookGen <name|path.ipynb>",
			})

			vim.api.nvim_create_user_command("NotebookSync", sync_current_to_ipynb, {
				desc = "Convert current buffer to ipynb via jupytext",
			})

			vim.api.nvim_create_user_command("NotebookSyncOutputs", function()
				sync_outputs_to_ipynb(vim.api.nvim_get_current_buf())
			end, {
				desc = "Sync Molten outputs to ipynb file",
			})

			-- -------------------------
			-- keymaps
			-- -------------------------
			local map = vim.keymap.set
			local o = { noremap = true, silent = true }

			map(
				"n",
				"<leader>Rb",
				"<cmd>NotebookBootstrap<CR>",
				vim.tbl_extend("force", o, { desc = "Bootstrap notebook env" })
			)
			map("n", "<leader>RD", "<cmd>NotebookDoctor<CR>", vim.tbl_extend("force", o, { desc = "Notebook doctor" }))

			map("n", "<leader>Rg", function()
				vim.ui.input({ prompt = "Notebook name (.ipynb optional): " }, function(input)
					if not input or input == "" then
						notify("Notebook creation cancelled")
						return
					end
					vim.cmd("NotebookGen " .. vim.fn.fnameescape(input))
				end)
			end, vim.tbl_extend("force", o, { desc = "Generate ipynb (prompt)" }))

			map(
				"n",
				"<leader>Rs",
				"<cmd>NotebookSync<CR>",
				vim.tbl_extend("force", o, { desc = "Sync current -> ipynb" })
			)

			map("n", "<leader>Ri", function()
				vim.b._nb_kernel_ready = nil
				vim.b._nb_kernel_name = nil
				molten_init_auto()
			end, vim.tbl_extend("force", o, { desc = "REPL init (auto kernel)" }))

			map("n", "<leader>Rr", function()
				vim.b._nb_kernel_ready = nil
				vim.cmd("MoltenRestart")
			end, vim.tbl_extend("force", o, { desc = "REPL restart" }))

			map("n", "<leader>Rx", "<cmd>MoltenInterrupt<CR>", vim.tbl_extend("force", o, { desc = "REPL interrupt" }))

			map("n", "<leader>Rq", function()
				vim.b._nb_kernel_ready = nil
				vim.b._nb_kernel_name = nil
				vim.cmd("MoltenDeinit")
			end, vim.tbl_extend("force", o, { desc = "REPL quit" }))

			map(
				"n",
				"<leader>Ro",
				molten_toggle_output_mode,
				vim.tbl_extend("force", o, { desc = "Toggle Molten output (virt/window)" })
			)

			map("n", "<leader><CR>", run_current_cell, vim.tbl_extend("force", o, { desc = "Run current cell" }))
			map(
				"n",
				"<leader>R<CR>",
				run_top_to_current_cell,
				vim.tbl_extend("force", o, { desc = "Run top -> current cell" })
			)
			map("n", "<leader>Rc", run_current_cell, vim.tbl_extend("force", o, { desc = "Run current cell" }))
		end,
	},
}
