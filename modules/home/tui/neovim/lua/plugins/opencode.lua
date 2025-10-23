return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      input = {},
      picker = {},
    },
  },
  {
    'NickvanDyke/opencode.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'folke/snacks.nvim',
    },
    config = function()
      vim.o.autoread = true

      vim.keymap.set({ "n", "x" }, "<leader>oa", function()
        require("opencode").ask("@this: ", { submit = true })
      end, { desc = "Ask about this" })

      vim.keymap.set({ "n", "x" }, "<leader>os", function()
        require("opencode").select()
      end, { desc = "Select prompt" })

      vim.keymap.set({ "n", "x" }, "<leader>o+", function()
        require("opencode").prompt("@this")
      end, { desc = "Add this" })

      vim.keymap.set("n", "<leader>ot", function()
        require("opencode").toggle()
      end, { desc = "Toggle embedded" })

      vim.keymap.set("n", "<leader>oc", function()
        require("opencode").command()
      end, { desc = "Select command" })

      vim.keymap.set("n", "<leader>on", function()
        require("opencode").command("session_new")
      end, { desc = "New session" })

      vim.keymap.set("n", "<leader>oi", function()
        require("opencode").command("session_interrupt")
      end, { desc = "Interrupt session" })
    end,
  },
}
