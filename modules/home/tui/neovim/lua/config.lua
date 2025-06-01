----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--                                       oo                                       oo              --
--                                                                                                --
--   dP   .dP .d8888b. 88d888b. .d8888b. dP .d8888b.            88d888b. dP   .dP dP 88d8b.d8b.   --
--   88   d8' 88ooood8 88'  `88 88ooood8 88 Y8ooooo.            88'  `88 88   d8' 88 88'`88'`88   --
--   88 .88'  88.  ... 88       88.  ... 88       88    dPdP    88    88 88 .88'  88 88  88  88   --
--   8888P'   `88888P' dP       `88888P' dP `88888P'     88     dP    dP 8888P'   dP dP  dP  dP   --
--                                                                                                --
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Visual and Display Settings
vim.opt.termguicolors = true         -- Enable true color support
vim.opt.number = true                -- Display line numbers
vim.opt.relativenumber = true        -- Display relative line numbers
vim.opt.cursorline = true            -- Highlight the current line
vim.opt.signcolumn = "yes"           -- Always show the sign column (for diagnostics, etc.)
vim.opt.showmatch = true             -- Briefly jump to matching bracket
vim.opt.breakindent = true           -- Enable break indent for wrapped lines

-- File Handling
vim.opt.undofile = true              -- Enable persistent undo
vim.opt.swapfile = false             -- Disable swapfile creation
vim.opt.backup = false               -- Disable backup file creation

-- Search Settings
vim.opt.ignorecase = true            -- Ignore case in search patterns
vim.opt.smartcase = true             -- Override ignorecase if search pattern contains uppercase
vim.opt.incsearch = true             -- Show search matches as you type
vim.opt.hlsearch = true              -- Highlight all matches of the search pattern
vim.opt.ignorecase = true            -- Ignore case in search patterns
vim.opt.smartcase = true             -- Override ignorecase if search pattern contains uppercase

-- Performance and Timings
vim.opt.updatetime = 250             -- Reduce the time for triggering CursorHold event
vim.opt.timeoutlen = 300             -- Time to wait for a mapped sequence to complete
vim.opt.lazyredraw = true            -- Redraw only when necessary to improve performance

-- Command Line
vim.opt.inccommand = "split"         -- Show the effects of a command incrementally in a split window

-- Tabs and Indentation
vim.opt.tabstop = 2                  -- Number of spaces that a tab counts for
vim.opt.shiftwidth = 2               -- Number of spaces to use for auto-indent
vim.opt.softtabstop = 2              -- Number of spaces a tab counts for while editing
vim.opt.expandtab = true             -- Convert tabs to spaces

-- Miscellaneous
vim.opt.hidden = true                -- Allow switching buffers without saving
vim.opt.mousescroll = "ver:3,hor:1"  -- Fine-tune mouse scroll behavior
vim.opt.list = true                  -- See `:help 'list' and :help 'listchars'`, but makes whitespace visible in editor.
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Ensure transparent backgrounds render
vim.cmd("au ColorScheme * hi Normal ctermbg=none guibg=none")

-- Attach to system clipboard when `UiEnter` for latency reasons
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Load other config files
require "keymaps"
require "plugins"
