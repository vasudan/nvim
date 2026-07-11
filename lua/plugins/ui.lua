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
      dashboard = {
        preset = {
          keys = {
            { key = "n", action = "<Leader>n", icon = icons["FileNew"], desc = "New File  " },
            { key = "f", action = "<Leader>ff", icon = icons["Search"], desc = "Find File  " },
            { key = "w", action = "<Leader>fw", icon = icons["WordFile"], desc = "Find Word  " },
            { key = "'", action = "<Leader>f'", icon = icons["Bookmarks"], desc = "Bookmarks  " },
            { key = "o", action = "<Leader>Sf", icon = icons["DefaultFile"], desc = "Open Session  " },
            { key = "s", action = "<Leader>Sl", icon = icons["Refresh"], desc = "Last Session  " },
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
      zen = {
        toggles = { dim = false, diagnostics = false, inlay_hints = false },
        on_open = function(win)
          -- disable snacks indent
          vim.b[win.buf].snacks_indent_old = vim.b[win.buf].snacks_indent
          vim.b[win.buf].snacks_indent = false
        end,
        on_close = function(win)
          -- restore snacks indent setting
          vim.b[win.buf].snacks_indent = vim.b[win.buf].snacks_indent_old
        end,
        win = {
          width = function() return math.floor(vim.o.columns * 0.85) end,
          height = 0.9,
          backdrop = {
            transparent = false,
            win = { wo = { winhighlight = "Normal:Normal" } },
          },
          wo = {
            number = false,
            relativenumber = false,
            signcolumn = "no",
            foldcolumn = "0",
            winbar = "",
            list = false,
            showbreak = "NONE",
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
      vim.cmd.colorscheme("astromars")
    end,
  }
}
