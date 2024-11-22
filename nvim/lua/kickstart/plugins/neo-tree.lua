return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  cmd = 'Neotree',
  keys = {
    { '\\', ':Neotree reveal<CR>', { desc = 'NeoTree reveal' } },
  },
  opts = {
    event_handlers = {

      {
        event = 'file_opened',
        handler = function()
          -- auto close
          -- vimc.cmd("Neotree close")
          -- OR
          require('neo-tree.command').execute { action = 'close' }
        end,
      },
    },
    close_if_last_window = true,
    filesystem = {
      window = {
        position = 'right',
        width = 20,
        mappings = {
          ['<cr>'] = 'open',
          ['q'] = 'close_window',
        },
      },
    },
  },
}
