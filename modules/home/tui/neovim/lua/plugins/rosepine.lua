return {{
  'rose-pine/neovim',
  name = "rose-pine",
  opts = {
    variant = "main",
    dim_inactive_windows = false,
    extend_background_behind_borders = false,
    enable = {
      terminal = true,
      legacy_highlights = true,
      migrations = true
    },
    styles = {
      bold = true,
      italic = true,
      transparency = true
    }
  },
  priority = 1000,
  init = function()
    vim.cmd.colorscheme 'rose-pine'
    vim.cmd.hi = 'Normal guibg=NONE ctermbg=NONE'
  end
}}
