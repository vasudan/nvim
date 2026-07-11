vim.keymap.set("t", "<C-\\><C-\\>", "<C-\\><C-n>", {
  desc = "Exit terminal mode",
})

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>t", "<Nop>", desc = icons["Terminal"] .. "Terminal" },
  },
}, {
  "folke/snacks.nvim",
  ---@type snacks.Config
  keys = {
    {
      "n",
      "<leader>tt",
      function() Snacks.terminal.toggle() end,
      "Toggle terminal",
    },
  },
  opts = {
    terminal = {
      -- your terminal configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
}
