local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

-- Path separator based on OS
local sep = is_windows and '\\' or '/'

-- Default configuration with OS-specific paths
local default_opts = {
    engine_path = is_windows 
        and "C:\\Users\\jonnevuorela\\UnrealEngine"
        or os.getenv("HOME") .. "/UnrealEngine",
    format_on_save = true,
    auto_copy_compile_commands = true,
    format_patterns = { "*.cpp", "*.h", "*.hpp" },
    exclude_patterns = { "Intermediate", "Binaries", "ThirdParty" },
}

-- Module table
local M = {}

-- Store instance configuration
local config = {}

-- Path handling utilities
local function join_paths(...)
    local args = {...}
    return table.concat(args, sep)
end

-- Command execution wrapper
local function execute_command(cmd)
    if is_windows then
        return "!powershell -Command \"" .. cmd .. "\""
    else
        return "!" .. cmd
    end
end

-- Initialize the module with user options
function M.setup(opts)
    config = vim.tbl_deep_extend("force", default_opts, opts or {})
    M.create_keymaps()
    
    if config.format_on_save then
        M.setup_format_on_save()
    end
end

function M.get_project_root()
    return vim.loop.cwd()
end

function M.get_uproject()
    local project_root = M.get_project_root()
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
            return join_paths(project_root, name)
        end
    end
    return nil
end

function M.get_project_name()
    local uproject = M.get_uproject()
    if not uproject then
        return nil
    end
    return uproject:match("([^" .. sep .. "]+)%.uproject$")
end

-- UBT path based on OS
local function get_ubt_path()
    if is_windows then
        return join_paths("Engine", "Binaries", "DotNET", "UnrealBuildTool", "UnrealBuildTool.exe")
    else
        return join_paths("Engine", "Build", "BatchFiles", "Linux", "RunMono.sh") ..
               " " .. join_paths("Engine", "Binaries", "DotNET", "UnrealBuildTool", "UnrealBuildTool.dll")
    end
end

function M.unreal_build_cmd()
    local uproject = M.get_uproject()
    local project_name = M.get_project_name()
    if not uproject or not project_name then
        vim.notify("No .uproject found in project root!", vim.log.levels.ERROR)
        return ""
    end
    
    local platform = is_windows and "Win64" or "Linux"
    local ubt = join_paths(config.engine_path, get_ubt_path())
    
    local cmd = string.format(
        [[%s -Project="%s" -Target="%sEditor" %s Development]],
        ubt,
        uproject,
        project_name,
        platform
    )
    
    return execute_command(cmd)
end

function M.unreal_generate_cmd()
    local uproject = M.get_uproject()
    local project_name = M.get_project_name()
    if not uproject or not project_name then
        vim.notify("No .uproject found in project root!", vim.log.levels.ERROR)
        return ""
    end
    
    local platform = is_windows and "Win64" or "Linux"
    local ubt = join_paths(config.engine_path, get_ubt_path())
    
    local cmd = string.format(
        [[%s -Mode=GenerateClangDatabase -Project="%s" -Target="%sEditor" %s Development]],
        ubt,
        uproject,
        project_name,
        platform
    )
    
    return execute_command(cmd)
end

function M.format_current_buffer()
    local clang_format_path = join_paths(
        config.engine_path,
        "Engine",
        "Source",
        "Programs",
        "Unsync",
        ".clang-format"
    )
    
    local f = io.open(clang_format_path, "r")
    if not f then
        vim.notify("Could not find UE .clang-format file!", vim.log.levels.ERROR)
        return
    end
    f:close()

    local current_file = vim.fn.expand("%:p")
    
    local should_format = false
    for _, pattern in ipairs(config.format_patterns) do
        if current_file:match(pattern:gsub("*", ".*")) then
            should_format = true
            break
        end
    end

    if not should_format then
        vim.notify("File type not configured for formatting!", vim.log.levels.WARN)
        return
    end

    local format_cmd
    if is_windows then
        format_cmd = string.format(
            [[clang-format -style=file:"%s" -i "%s"]],
            clang_format_path,
            current_file
        )
    else
        format_cmd = string.format(
            [[clang-format -style=file:'%s' -i '%s']],
            clang_format_path,
            current_file
        )
    end
    
    vim.cmd(execute_command(format_cmd))
    vim.cmd("e!")
    vim.notify("Formatted using UE style", vim.log.levels.INFO)
end

function M.format_project()
    local clang_format_path = join_paths(
        config.engine_path,
        "Engine",
        "Source",
        "Programs",
        "Unsync",
        ".clang-format"
    )
    
    local f = io.open(clang_format_path, "r")
    if not f then
        vim.notify("Could not find UE .clang-format file!", vim.log.levels.ERROR)
        return
    end
    f:close()

    local exclude_pattern = table.concat(config.exclude_patterns, "|")
    local include_patterns = table.concat(
        vim.tbl_map(function(pattern)
            return pattern:gsub("*", "")
        end, config.format_patterns),
        ","
    )

    local cmd
    if is_windows then
        cmd = string.format(
            [[Get-ChildItem -Path . -Recurse -Include %s | ]] ..
            [[Where-Object { $_.FullName -notmatch '(%s)' } | ]] ..
            [[ForEach-Object { clang-format -style=file:'%s' -i $_.FullName }]],
            include_patterns,
            exclude_pattern,
            clang_format_path
        )
    else
        cmd = string.format(
            [[find . -type f \( -name "*.cpp" -o -name "*.h" -o -name "*.hpp" \) ]] ..
            [[-not -path "*Intermediate*" -not -path "*Binaries*" -not -path "*ThirdParty*" ]] ..
            [[-exec clang-format -style=file:'%s' -i {} +]],
            clang_format_path
        )
    end
    
    vim.cmd(execute_command(cmd))
    vim.cmd("e!")
    vim.notify("Formatted all project files using UE style", vim.log.levels.INFO)
end

function M.copy_compile_commands()
    if not config.auto_copy_compile_commands then
        return
    end
    
    local src = join_paths(config.engine_path, "compile_commands.json")
    local dst = join_paths(M.get_project_root(), "compile_commands.json")
    
    local cmd
    if is_windows then
        cmd = string.format([[Copy-Item -Path '%s' -Destination '%s' -Force]], src, dst)
    else
        cmd = string.format([[cp '%s' '%s']], src, dst)
    end
    
    print("Copying from:", src)
    print("Copying to:", dst)
    vim.cmd(execute_command(cmd))
end

function M.create_keymaps()
    vim.keymap.set("n", "<leader>ub", function()
        local cmd = M.unreal_build_cmd()
        if cmd ~= "" then
            vim.cmd(cmd)
        end
    end, { desc = "Unreal Engine Build" })

    vim.keymap.set("n", "<leader>ug", function()
        local cmd = M.unreal_generate_cmd()
        if cmd ~= "" then
            vim.cmd(cmd)
            M.copy_compile_commands()
        end
    end, { desc = "Unreal Engine Generate LSP" })

    vim.keymap.set("n", "<leader>uf", function()
        M.format_current_buffer()
    end, { desc = "Format current file with UE style" })

    vim.keymap.set("n", "<leader>uF", function()
        M.format_project()
    end, { desc = "Format project with UE style" })
end

function M.setup_format_on_save()
    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = config.format_patterns,
        callback = function()
            if M.get_uproject() then
                M.format_current_buffer()
            end
        end,
    })
end

return M
