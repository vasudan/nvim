vim.api.nvim_create_user_command(
  "Keymap",
  function() require("snacks").picker.keymaps() end,
  { desc = "Open keymap picker" }
)

local icons = require("icons")
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>f", "<Nop>", desc = icons["Search"] .. " Find" },
    },
  },
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    keys = {
      { "<Leader>f<CR>", function() require("snacks").picker.resume() end, desc = "Resume previous search" },
      { "<Leader>f'", function() require("snacks").picker.marks() end, desc = "Find marks" },
      { "<Leader>fl", function() require("snacks").picker.lines() end, desc = "Find lines" },
      { "<Leader>fb", function() require("snacks").picker.buffers() end, desc = "Find buffers" },
      { "<Leader>fc", function() require("snacks").picker.grep_word() end, desc = "Find word under cursor" },
      { "<Leader>fC", function() require("snacks").picker.commands() end, desc = "Find commands" },
      {
        "<Leader>ff",
        function()
          require("snacks").picker.files {
            hidden = vim.tbl_get((vim.uv or vim.loop).fs_stat ".git" or {}, "type") == "directory",
          }
        end,
        desc = "Find files",
      },
      { "<Leader>fF", function() require("snacks").picker.files { hidden = true, ignored = true } end, desc = "Find all files" },
      { "<Leader>fg", function() require("snacks").picker.git_files() end, desc = "Find git files" },
      { "<Leader>fh", function() require("snacks").picker.help() end, desc = "Find help" },
      { "<Leader>fk", function() require("snacks").picker.keymaps() end, desc = "Find keymaps" },
      { "<Leader>fm", function() require("snacks").picker.man() end, desc = "Find man" },
      { "<Leader>fn", function() require("snacks").picker.notifications() end, desc = "Find notifications" },
      { "<Leader>fo", function() require("snacks").picker.recent() end, desc = "Find old files" },
      {
        "<Leader>fO",
        function() require("snacks").picker.recent { filter = { cwd = true } } end,
        desc = "Find old files (cwd)",
      },
      { "<Leader>fp", function() require("snacks").picker.projects() end, desc = "Find projects" },
      { "<Leader>fr", function() require("snacks").picker.registers() end, desc = "Find registers" },
      { "<Leader>fs", function() require("snacks").picker.smart() end, desc = "Find buffers/recent/files" },
      { "<Leader>fw", function() require("snacks").picker.grep() end, desc = "Find words" },
      {
        "<Leader>fW",
        function() require("snacks").picker.grep { hidden = true, ignored = true } end,
        desc = "Find words in all files",
      },
      { "<Leader>fu", function() require("snacks").picker.undo() end, desc = "Find undo history" },
    },
    opts = {
      picker = {
        win = {
          input = {
            keys = {
              ["<C-h>"] = { "focus_list", mode = { "i", "n" } },
              ["<C-l>"] = { "focus_preview", mode = { "i", "n" } },
            },
          },
          list = {
            keys = {
              ["<C-h>"] = "focus_input",
              ["<C-l>"] = "focus_preview",
            },
          },
          preview = {
            keys = {
              ["<C-h>"] = "focus_list",
              ["<C-l>"] = "focus_input",
            },
          },
        },
      },
    },
  }
}
