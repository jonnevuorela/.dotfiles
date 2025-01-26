-- debug.lua
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
    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<leader>D', function() end, { desc = 'Debug' })
    vim.keymap.set('n', '<leader>D1', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<leader>D2', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<leader>D3', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<leader>D4', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>D5', dap.restart, { desc = 'Debug: Restart' })
    vim.keymap.set('n', '<leader>Db', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>DB', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })
    vim.fn.sign_define('DapBreakpoint', { text = '🛑', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {} -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<leader>D7', dapui.toggle, { desc = 'Debug: See last session result.' })

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
