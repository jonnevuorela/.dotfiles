local engine_path = "C:\\Users\\jovuorel\\UnrealEngine"

local project_root = vim.loop.cwd()

local function get_uproject()
	local scan = vim.loop.fs_scandir(project_root)
	if not scan then
		return nil
	end
	while true do
		local name, t = vim.loop.fs_scandir_next(scan)
		if not name then
			break
		end
		if name:match("%.uproject$") then
			return project_root .. "\\" .. name
		end
	end
	return nil
end

-- Build command
local function unreal_build_cmd()
	local uproject = get_uproject()
	if not uproject then
		vim.notify("No .uproject found in project root!", vim.log.levels.ERROR)
		return ""
	end
	return string.format(
		[[%s\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe -Project="%s" -Target="BlankEditor" Win64 Development]],
		engine_path,
		uproject
	)
end

-- Generate compile_commands.json command
local function unreal_generate_cmd()
	local uproject = get_uproject()
	if not uproject then
		vim.notify("No .uproject found in project root!", vim.log.levels.ERROR)
		return ""
	end
	return string.format(
		[[%s\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe -Mode=GenerateClangDatabase -Project="%s" -Target="BlankEditor" Win64 Development]],
		engine_path,
		uproject
	)
end

-- copy compile_commands.json to project root (for clangd & LSP (might be windows specific problem))
local function copy_compile_commands()
	local src = engine_path .. "\\compile_commands.json"
	local dst = project_root .. "\\compile_commands.json"
	print("Copying from:", src)
	print("Copying to:", dst)
	vim.cmd(string.format("!powershell -Command \"Copy-Item -Path '%s' -Destination '%s' -Force\"", src, dst))
end

vim.keymap.set("n", "<leader>ub", function()
	local cmd = unreal_build_cmd()
	if cmd ~= "" then
		vim.cmd("!" .. cmd)
	end
end, { desc = "Unreal Engine Build" })

vim.keymap.set("n", "<leader>ug", function()
	local cmd = unreal_generate_cmd()
	if cmd ~= "" then
		vim.cmd("!" .. cmd)
		copy_compile_commands()
	end
end, { desc = "Unreal Engine Generate LSP" })
