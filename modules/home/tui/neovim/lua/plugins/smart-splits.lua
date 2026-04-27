return {
  'mrjones2014/smart-splits.nvim',
  keys = {
    { '<A-h>', function() require('smart-splits').move_cursor_left() end, desc = 'Move left' },
    { '<A-Left>', function() require('smart-splits').move_cursor_left() end, desc = 'Move left' },
    { '<A-j>', function() require('smart-splits').move_cursor_down() end, desc = 'Move down' },
    { '<A-Down>', function() require('smart-splits').move_cursor_down() end, desc = 'Move down' },
    { '<A-k>', function() require('smart-splits').move_cursor_up() end, desc = 'Move up' },
    { '<A-Up>', function() require('smart-splits').move_cursor_up() end, desc = 'Move up' },
    { '<A-l>', function() require('smart-splits').move_cursor_right() end, desc = 'Move right' },
    { '<A-Right>', function() require('smart-splits').move_cursor_right() end, desc = 'Move right' },
  },
  opts = {
    at_edge = 'wrap',
    multiplexer_integration = 'zellij',
  },
}
