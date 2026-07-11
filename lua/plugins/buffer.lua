local icons = require "icons"
local buffer = require "config.buffer"

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>b", "<Nop>", desc = icons["Tab"] .. " Buffers" },
    },
  },
  {
    "rebelot/heirline.nvim",
    event = "BufEnter",
    keys = {
      {
        "<Leader>bb",
        function()
          buffer.buffer_picker(function(bufnr) vim.api.nvim_win_set_buf(0, bufnr) end)
        end,
        "Select buffer from tabline",
      },
      {
        "<Leader>bd",
        function()
          buffer.buffer_picker(function(bufnr) buffer.close(bufnr) end)
        end,
        "Close buffer from tabline",
      },
      { "<leader>c", function() require("snacks").bufdelete() end, desc = "Close buffer" },
      { "<leader>bl", function() buffer.close_left() end, desc = "Close all buffers to the left" },
      { "<leader>br", function() buffer.close_right() end, desc = "Close all buffers to the right" },
      { "<leader>bC", function() buffer.close_all() end, desc = "Close all buffers" },
      { "<leader>bo", function() buffer.close_all(true) end, desc = "Close all buffers except current" },
    },
  },
  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      { "<C-Up>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
      { "<C-Down>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
      { "<C-Left>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
      { "<C-Right>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
      { "<Bar>", "<cmd>vsplit<cr>", desc = "Split vertically" },
      { "<Bslash>", "<cmd>split<cr>", desc = "Split horizontally" },
    }

  }
}
