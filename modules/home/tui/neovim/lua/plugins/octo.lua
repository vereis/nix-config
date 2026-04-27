return {
  'pwntester/octo.nvim',
  cmd = 'Octo',
  keys = {
    { '<leader>oi', '<cmd>Octo issue list<cr>', desc = 'Octo issues' },
    { '<leader>op', '<cmd>Octo pr list<cr>', desc = 'Octo pull requests' },
    { '<leader>or', '<cmd>Octo review start<cr>', desc = 'Octo start review' },
    { '<leader>oR', '<cmd>Octo review resume<cr>', desc = 'Octo resume review' },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons',
  },
  opts = {
    enable_builtin = true,
    mappings = {
      pull_request = {
        list_changed_files = { lhs = '<leader>of', desc = 'list changed files' },
        open_in_browser = { lhs = '<leader>ob', desc = 'open PR in browser' },
      },
      review_diff = {
        add_review_comment = { lhs = '<leader>oc', desc = 'add review comment', mode = { 'n', 'x' } },
        add_review_suggestion = { lhs = '<leader>os', desc = 'add review suggestion', mode = { 'n', 'x' } },
        focus_files = { lhs = '<leader>of', desc = 'focus changed files' },
        submit_review = { lhs = '<leader>oS', desc = 'submit review' },
        discard_review = { lhs = '<leader>od', desc = 'discard review' },
      },
      review_thread = {
        add_comment = { lhs = '<leader>oc', desc = 'add comment' },
        add_suggestion = { lhs = '<leader>os', desc = 'add suggestion' },
      },
    },
    picker = 'telescope',
  },
}
