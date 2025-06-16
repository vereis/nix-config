return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      require("mini.starter").setup()
      require("mini.cursorword").setup()
      require("mini.tabline").setup()
      require("mini.statusline").setup()
      require("mini.bufremove").setup()
      require("mini.trailspace").setup() -- trim/show trailing spaces

      -- Trim trailing spaces on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        desc = "Trim trailing spaces on save",
        callback = function()
          -- Trim trailing whitespace
          require("mini.trailspace").trim();
          require("mini.trailspace").trim_last_lines();

          -- Trim windows CRLFs
          local save_cursor = vim.fn.getpos(".")
          pcall(function() vim.cmd [[%s/\r//]] end)
          vim.fn.setpos(".", save_cursor)
        end
      })
    end,
  },
}
