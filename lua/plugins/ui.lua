local icons = require "icons"
local buffer = require "config.buffer"

vim.api.nvim_create_user_command("Home", function()
  if vim.bo.filetype == "snacks_dashboard" then
    buffer.close()
  else
    require("snacks").dashboard()
  end
end, { desc = "Toggle the Home dashboard" })

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>u", "<Nop>", desc = icons["Window"] .. " UI/UX" },
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>uw", function() vim.wo.wrap = not vim.wo.wrap end, desc = "Toggle wrap mode" },
      { "<leader>uz", function() require("snacks").toggle.zen():toggle() end, desc = "Toggle zen mode" },
    },
    opts = {
      input = {
        enabled = true,
      },
      dashboard = {
        preset = {
          keys = {
            { key = "n", action = "<Leader>n", icon = icons["FileNew"], desc = "New File  " },
            { key = "f", action = "<Leader>ff", icon = icons["Search"], desc = "Find File  " },
            { key = "w", action = "<Leader>fw", icon = icons["WordFile"], desc = "Find Word  " },
            { key = "'", action = "<Leader>f'", icon = icons["Bookmarks"], desc = "Bookmarks  " },
            { key = "o", action = "<Leader>sl", icon = icons["DefaultFile"], desc = "Open Session  " },
          },
          header = "",
        },
        sections = {
          { section = "header", padding = 5 },
          { section = "keys", gap = 1, padding = 3 },
          { section = "startup" },
        },
      },
      notifier = {
        timeout = 5000, -- 5 seconds 
        icons = {
          debug = icons["Debugger"],
          error = icons["DiagnosticError"],
          info = icons["DiagnosticInfo"],
          trace = icons["DiagnosticHint"],
          warn = icons["DiagnosticWarn"],
        },
      },
      picker = {
        ui_select = true,
      },
      ---@class snacks.zen.Config
      zen = {
        toggles = {},
        show = {
          tabline = true,
          statusline = true,
        },
        win = {
          width = 0.95,
          height = 0.95,
          backdrop = {
            transparent = false,
            win = { wo = { winhighlight = "Normal:Normal" } },
          },
        },
      },
    },
  },
  {
    "rebelot/heirline.nvim",
    event = "BufEnter",
    dependencies = { "zeioth/heirline-components.nvim" },
    opts = function(_, opts)
      local ui = require "config.ui"
      opts = ui.get_heirline_opts()
      return opts
    end,
    config = function(_, opts)
      local heirline = require "heirline"
      local heirline_components = require "heirline-components.all"

      heirline_components.init.subscribe_to_events()
      heirline.load_colors(heirline_components.hl.get_colors())
      heirline.setup(opts)
    end,
  },
  {
    "AstroNvim/astrotheme",
    lazy = false,
    priority = 1000,
    opts = {
      palette = "astromars",
    },
    config = function(_, opts)
      require("astrotheme").setup(opts)
      vim.cmd.colorscheme "astromars"
      require("config.theme").setup()
    end,
  },
}
