local icons = require "icons"

vim.keymap.set("t", "<C-\\><C-\\>", "<C-\\><C-n>", {
  desc = "Exit terminal mode",
})

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>t", "<Nop>", desc = icons["Terminal"] .. " Terminal" },
    },
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    keys = {
      {
        "<leader>tt",
        function() Snacks.terminal.toggle() end,
        desc = "Toggle terminal",
      },
    },
    opts = {
      terminal = {

      },
    },
  },
}
