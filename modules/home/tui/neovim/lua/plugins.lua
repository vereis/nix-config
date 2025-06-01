-- [[ Install `lazy.nvim` plugin manager ]] ------------------------------------------
-- See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
--
-- Run `:Lazy` for a status check, `?` for help, and `:q` to quit.
-- Run `:Lazy update` to update packages
--------------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field

vim.opt.rtp:prepend(lazypath)

-- [[ Configure & Install Plugins ]] -------------------------------------------------
-- See associated configuration in `/lua/plugins/*.lua`
-- Setting `ui` to an empty table lets us use `NerdFont` icons everywhere.
--------------------------------------------------------------------------------------

require('lazy').setup({ { import = 'plugins/' } }, { ui = { } })
