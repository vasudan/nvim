local icons = require "icons"
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,winsize,winpos,terminal,localoptions"

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>s", "<Nop>", desc = icons["Session"] .. " Session" },
    },
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    keys = {
      { "<leader>sl", "<cmd>AutoSession search<CR>", desc = "Load session" },
      { "<leader>ss", "<cmd>AutoSession save<CR>", desc = "Save session" },
    },
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Downloads", "/" },
      bypass_save_filetypes = { "alpha", "dashboard", "snacks_dashboard" },
      auto_restore_last_session = true,
      cwd_change_handling = true,
      legacy_cmds = false,
      ---@type SessionLens
      session_lens = {
        picker = "snacks",
        previewer = "summary",

        ---@type SessionLensMappings
        mappings = {
          -- Mode can be a string or a table, e.g. {"i", "n"} for both insert and normal mode
          delete_session = { { "n", "i" }, "<C-d>" }, -- mode and key for deleting a session from the picker
          alternate_session = { { "n", "i" }, "<C-s>" }, -- mode and key for swapping to alternate session from the picker
          copy_session = { { "n", "i" }, "<C-y>" }, -- mode and key for copying a session from the picker
        },
      },
    },
  },
}
