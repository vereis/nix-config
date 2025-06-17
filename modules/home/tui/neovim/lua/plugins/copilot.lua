return {
  {
    'zbirenbaum/copilot.lua',
    event = 'VimEnter',
    config = function()
      require('copilot').setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<C-]>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-[>",
          },
        },
        panel = { enabled = false },
        filetypes = {
          ['*'] = true,  -- Enable in all filetypes
        },
      })
    end
  }
}
