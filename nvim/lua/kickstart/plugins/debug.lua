-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('neodev').setup {
      library = { plugins = { 'nvim-dap-ui' }, types = true },
    }

    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'delve',
        'netcoredbg',
      },
    }
    -- Unity
    dap.adapters.vstuc = {
      type = 'executable',
      command = 'dotnet',
      args = { vim.fn.expand '~/.vscode/extensions/visualstudiotoolsforunity.vstuc-1.0.4/bin/UnityDebugAdapter.dll' },
    }

    dap.adapters.coreclr = {
      type = 'executable',
      command = 'netcoredbg',
      args = { '--interpreter=vscode' },
    }

    local function get_unity_process_id()
      local handle = io.popen 'pgrep -f Unity'
      local result = handle:read '*a'
      handle:close()
      local first_pid = result:match '%d+'
      if not first_pid then
        print 'Error: Unity process not found'
        return nil
      end
      return tonumber(first_pid)
    end

    local function get_unity_debug_port()
      local log_file_path = os.getenv 'HOME' .. '/Library/Logs/Unity/Editor.log'
      local file = io.open(log_file_path, 'r')
      if not file then
        print 'Could not open Unity log file.'
        return nil
      end
      local port = nil
      for line in file:lines() do
        local match = line:match 'Using monoOptions .-address=127.0.0.1:(%d+)'
        if match then
          port = match
          break
        end
      end
      file:close()
      return port
    end
    local port = get_unity_debug_port()
    if port then
      print('Unity debugger port: ' .. port)
    else
      print 'Could not extract the port.'
    end

    dap.configurations.cs = {
      {
        type = 'vstuc',
        name = 'Attach to Unity, netcoredbg',
        request = 'attach',
        processId = function()
          return get_unity_process_id()
        end,
        port = function()
          return get_unity_debug_port()
        end,
        host = '127.0.0.1',
        on_attach = function(err)
          if err then
            print('Error attaching to Unity: ' .. err.message)
          else
            print 'Debugger attached'
          end
        end,
      },
    }
    dap.configurations.vstuc = {
      {
        type = 'vstuc',
        name = 'Attach to Unity Editor',
        request = 'attach',
        processId = function()
          return get_unity_process_id()
        end,
        sourceFileMap = {
          [vim.fn.getcwd()] = '${workspaceFolder}',
        },
        on_attach = function(err)
          if err then
            print('Error attaching to Unity Editor: ' .. err.message)
          else
            print 'Successfully attached to Unity Editor'
          end
        end,
      },
    } --]]
    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<leader>1', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<leader>2', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<leader>3', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<leader>4', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>5', dap.restart, { desc = 'Debug: Restart' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })
    vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {} -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<leader>7', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
    require('nvim-dap-virtual-text').setup()
  end,
}
