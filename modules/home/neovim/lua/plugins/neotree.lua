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
    { '\\', ':Neotree right reveal<CR>', desc = 'NeoTree right reveal' },
  },
  opts = {
    close_if_last_window = true,
    indent = {
      with_markers = true,
      indent_marker = "x",
      last_indent_marker = "x",
    },
    filesystem = {
      window = {
        mappings = {
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
