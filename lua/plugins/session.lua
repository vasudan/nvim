
local icons = require("icons")
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>S", "<Nop>", desc = icons["Session"] .. " Session" },
  },
}

