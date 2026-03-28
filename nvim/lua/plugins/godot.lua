-- Godot project root detection + Neovim server pipe for external editor
local function find_godot_project_root()
	local cwd = vim.fn.getcwd()
	local search_paths = { "", "/.." }
	for _, relative_path in ipairs(search_paths) do
		local project_file = cwd .. relative_path .. "/project.godot"
		if vim.uv.fs_stat(project_file) then
			return cwd .. relative_path
		end
	end
	return nil
end

local function is_server_running(project_path)
	local server_pipe = project_path .. "/server.pipe"
	return vim.uv.fs_stat(server_pipe) ~= nil
end

local function start_godot_server_if_needed()
	local godot_project_path = find_godot_project_root()
	if godot_project_path and not is_server_running(godot_project_path) then
		vim.fn.serverstart(godot_project_path .. "/server.pipe")
	end
end

start_godot_server_if_needed()

return {
	{ "habamax/vim-godot" },
	{ "skywind3000/asyncrun.vim" },
	{
		"teatek/gdscript-extended-lsp.nvim",
		ft = { "gdscript", "gd" },
		opts = { view_type = "floating", picker = "snacks" },
	},
	{
		"folke/snacks.nvim",
		opts = {
			picker = {
				sources = {
					explorer = {
						hidden = true,
						ignored = false,
						exclude = { "*.uid", "server.pipe" },
					},
				},
			},
		},
	},

	-- Automatic LSP start when a gdscript buffer is opened (like your manual command)
	{
		"neovim/nvim-lspconfig",
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "gdscript",
				callback = function(ev)
					local bufnr = ev.buf
					local fname = vim.api.nvim_buf_get_name(bufnr)

					local root_file = vim.fs.find({ "project.godot" }, { upward = true, path = fname })[1]
					if not root_file then
						vim.notify("No project.godot found upward — LSP not started", vim.log.levels.WARN)
						return
					end

					local root_dir = vim.fs.dirname(root_file)

					vim.lsp.start({
						name = "gdscript",
						cmd = { "nc", "127.0.0.1", "6005" },
						-- cmd = vim.lsp.rpc.connect("127.0.0.1", 6005),           -- alternative
						-- cmd = vim.lsp.rpc.connect(root_dir .. "/godot.pipe"),   -- pipe transport if enabled in Godot

						root_dir = root_dir,
						capabilities = capabilities,

						on_attach = function(client, bufnr)
							-- Prevent ECONNRESET by skipping problematic notifications
							local original_notify = client.notify
							client.notify = function(method, params)
								if
									method == vim.lsp.protocol.Methods.textDocument_didClose
									or method == vim.lsp.protocol.Methods.textDocument_didOpen
								then
									return
								end
								original_notify(method, params)
							end

							-- Keymaps
							local map = function(keys, func, desc)
								vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
							end
							map("ca", vim.lsp.buf.code_action, "Code Action")
							map("rn", vim.lsp.buf.rename, "Rename")

							-- Document highlight
							if client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
								local aug = vim.api.nvim_create_augroup("lsp-highlight-" .. bufnr, { clear = true })
								vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
									buffer = bufnr,
									group = aug,
									callback = vim.lsp.buf.document_highlight,
								})
								vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
									buffer = bufnr,
									group = aug,
									callback = vim.lsp.buf.clear_references,
								})
							end

							vim.notify("GDScript LSP attached via autocmd to buffer " .. bufnr, vim.log.levels.INFO)
						end,

						-- Optional: more verbose logging during startup
						on_init = function(client)
							vim.notify("LSP client init started", vim.log.levels.DEBUG)
						end,
						on_exit = function(code, signal)
							vim.notify(
								"LSP client exited — code: " .. code .. ", signal: " .. (signal or "none"),
								vim.log.levels.WARN
							)
						end,
					})
				end,
				desc = "Start GDScript LSP automatically on filetype",
			})
		end,
	},
}
