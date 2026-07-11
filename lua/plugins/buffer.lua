local icons = require "icons"
local buffer = require "config.buffer"

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>b", "<Nop>", desc = icons["Tab"] .. "Buffers" },
  },
}, {
  "rebelot/heirline.nvim",
  event = "BufEnter",
  keys = {
    {
      "n",
      "<Leader>bb",
      function()
        buffer.buffer_picker(function(bufnr) vim.api.nvim_win_set_buf(0, bufnr) end)
      end,
      "Select buffer from tabline",
    },
    {
      "n",
      "<Leader>bd",
      function()
        buffer.buffer_picker(function(bufnr) buffer.close(bufnr) end)
      end,
      "Close buffer from tabline",
    },
    { "n", "<leader>c", function() Snacks.bufdelete() end, "Close buffer" },
    { "n", "<leader>bl", function() buffer.close_left() end, "Close all buffers to the left" },
    { "n", "<leader>br", function() buffer.close_right() end, "Close all buffers to the right" },
    { "n", "<leader>bC", function() buffer.close_all() end, "Close all buffers" },
    { "n", "<leader>bo", function() buffer.close_all(true) end, "Close all buffers except current" },
  },
}
