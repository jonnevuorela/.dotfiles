local M = {}

M.path = vim.fn.stdpath("config") .. "/lua/config/user_defaults.lua"

M.schema = {
	animate = true,
	background = "dark",
	colorscheme = "rose-pine-moon",
	conceallevel = 2,
	cursorline = true,
	diagnostics = true,
	diagnostics_inline = true,
	dim = false,
	indent = true,
	inlay_hints = true,
	line_number = true,
	list = true,
	molten_output_show_more = false,
	molten_virt_text_max_lines = 120,
	molten_output_mode = "virt",
	relativenumber = true,
	scroll = true,
	signcolumn = "yes",
	spell = false,
	treesitter = true,
	words = true,
	wrap = false,
	zen = false,
	zoom = false,
}

local function merge_schema(state)
	local merged = {}
	for k, v in pairs(M.schema) do
		merged[k] = v
	end
	for k, v in pairs(state or {}) do
		merged[k] = v
	end
	return merged
end

local function serialize_value(value)
	if type(value) == "string" then
		return string.format("%q", value)
	end
	if type(value) == "boolean" or type(value) == "number" then
		return tostring(value)
	end
	return "nil"
end

function M.save(state, key, value)
	if key ~= nil and key ~= "__all__" then
		state[key] = value
	end
	local keys = {}
	for k in pairs(state) do
		keys[#keys + 1] = k
	end
	table.sort(keys)

	local lines = {
		"local M = {}",
		"",
		"M.state = {",
	}
	for _, k in ipairs(keys) do
		local v = serialize_value(state[k])
		lines[#lines + 1] = string.format("\t%s = %s,", k, v)
	end
	lines[#lines + 1] = "}"
	lines[#lines + 1] = ""
	lines[#lines + 1] = "return M"

	local ok, err = pcall(vim.fn.writefile, lines, M.path)
	if not ok then
		vim.notify("Failed to save user defaults: " .. tostring(err), vim.log.levels.ERROR)
	end
end

function M.refresh_windows(state)
	M.apply_all_windows(state)
end

local function set_win_option(win, name, value)
	pcall(vim.api.nvim_set_option_value, name, value, { scope = "local", win = win })
end

function M.apply_global(state)
	if state.background and state.background ~= vim.o.background then
		vim.o.background = state.background
	end

	if state.spell ~= nil then
		vim.o.spell = state.spell
	end
	if state.wrap ~= nil then
		vim.o.wrap = state.wrap
	end
	if state.relativenumber ~= nil then
		vim.o.relativenumber = state.relativenumber
	end
	if state.line_number ~= nil then
		vim.o.number = state.line_number
	end
	if state.conceallevel ~= nil then
		vim.o.conceallevel = state.conceallevel
	end
	if state.cursorline ~= nil then
		vim.o.cursorline = state.cursorline
	end
	if state.list ~= nil then
		vim.o.list = state.list
	end
	if state.signcolumn ~= nil then
		vim.o.signcolumn = state.signcolumn
	end

	if state.indent ~= nil then
		vim.g.snacks_indent = state.indent
	end
	if state.words ~= nil then
		vim.g.snacks_words = state.words
	end
	if state.dim ~= nil then
		vim.g.snacks_dim = state.dim
	end
	if state.zen ~= nil then
		vim.g.snacks_zen = state.zen
	end
	if state.zoom ~= nil then
		vim.g.snacks_zoom = state.zoom
	end
	if state.scroll ~= nil then
		vim.g.snacks_scroll = state.scroll
	end
	if state.animate ~= nil then
		vim.g.snacks_animate = state.animate
	end

	if state.treesitter ~= nil then
		pcall(function()
			vim.treesitter[state.treesitter and "start" or "stop"]()
		end)
	end
	if state.diagnostics ~= nil then
		vim.diagnostic.enable(state.diagnostics)
	end
	if state.diagnostics_inline ~= nil then
		vim.diagnostic.config({ virtual_text = state.diagnostics_inline })
	end

	if state.molten_output_mode then
		local virt = state.molten_output_mode == "virt"
		vim.g.molten_virt_text_output = virt
		vim.g.molten_auto_open_output = not virt
	end
end

function M.apply_window(state, win)
	if state.spell ~= nil then
		set_win_option(win, "spell", state.spell)
	end
	if state.wrap ~= nil then
		set_win_option(win, "wrap", state.wrap)
	end
	if state.relativenumber ~= nil then
		set_win_option(win, "relativenumber", state.relativenumber)
	end
	if state.line_number ~= nil then
		set_win_option(win, "number", state.line_number)
	end
	if state.conceallevel ~= nil then
		set_win_option(win, "conceallevel", state.conceallevel)
	end
	if state.cursorline ~= nil then
		set_win_option(win, "cursorline", state.cursorline)
	end
	if state.list ~= nil then
		set_win_option(win, "list", state.list)
	end
	if state.signcolumn ~= nil then
		set_win_option(win, "signcolumn", state.signcolumn)
	end
end

function M.apply_all_windows(state)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		M.apply_window(state, win)
	end
end

function M.apply_now(state)
	M.apply_global(state)
	M.apply_all_windows(state)
end

function M.apply(state)
	M.apply_now(state)

	local group = vim.api.nvim_create_augroup("user-defaults", { clear = true })
	vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
		group = group,
		callback = function(ev)
			M.apply_window(state, vim.api.nvim_get_current_win())
		end,
	})

	if state.colorscheme and state.colorscheme ~= "" then
		local function apply_colorscheme()
			pcall(vim.cmd.colorscheme, state.colorscheme)
		end
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "LazyDone",
			callback = apply_colorscheme,
		})
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = group,
			callback = function()
				if vim.g.colors_name ~= state.colorscheme then
					apply_colorscheme()
				end
			end,
		})
		vim.schedule(apply_colorscheme)
	end

	if state.inlay_hints ~= nil then
		vim.api.nvim_create_autocmd("LspAttach", {
			group = group,
			callback = function(ev)
				if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
					vim.lsp.inlay_hint.enable(state.inlay_hints, { bufnr = ev.buf })
				elseif vim.lsp.inlay_hint then
					vim.lsp.inlay_hint(ev.buf, state.inlay_hints)
				end
			end,
		})
	end
end

function M.load()
	local ok, mod = pcall(require, "config.user_defaults")
	local merged = merge_schema(ok and mod.state or {})
	if ok then
		mod.state = merged
	end
	M.save(merged, "__all__", merged)
	return merged
end

function M.ensure()
	return M.load()
end

return M
