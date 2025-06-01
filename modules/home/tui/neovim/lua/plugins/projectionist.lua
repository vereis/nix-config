-- NOTE: Umbrella apps for Elixir require `ex_projections` to be run on the repo first.
return {
  { 'tpope/vim-projectionist', event = 'VimEnter' },
  { 'c-brenn/fuzzy-projectionist.vim', event = 'VimEnter' },
  { 'andyl/vim-projectionist-elixir', event = 'VimEnter', config = function()
    vim.keymap.set("n", "<leader>a", ":<cmd>A<cr><cr>", { desc = '[A]lternate File' })
  end }
}
