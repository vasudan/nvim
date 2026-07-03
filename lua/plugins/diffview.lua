---@type LazySpec
return {
  "sindrets/diffview.nvim",
  keys = {
    -- Git status / changed files view
    { "<leader>gg", "<Cmd>DiffviewOpen<CR>", desc = "Show git status" },
    -- File history views
    { "<leader>gv", "<Cmd>DiffviewFileHistory<CR>", desc = "Repo history" },
    { "<leader>gV", "<Cmd>DiffviewFileHistory %<CR>", desc = "Current file history" },
    -- Visual mode: history of selected lines
    { "<leader>gv", ":'<,'>DiffviewFileHistory<CR>", desc = "Selection history", mode = "v" },
    -- Compare with revisions
    {
      "<leader>gr",
      function()
        vim.ui.input({ prompt = "Compare revision (ex. main, HEAD~5, main..HEAD): " }, function(refs)
          if refs and refs:match "%S" then vim.cmd(("DiffviewOpen %s"):format(refs)) end
        end)
      end,
      desc = "Diff: compare revisions",
    },
    -- File history with range
    {
      "<leader>gR",
      function()
        vim.ui.input({ prompt = "File history range (ex. HEAD~1, main..HEAD): " }, function(range)
          if range and range:match "%S" then vim.cmd(("DiffviewFileHistory --range=%s %%"):format(range)) end
        end)
      end,
      desc = "Diff: file history with range",
    },
    -- Compare two arbitrary files
    {
      "<leader>g2",
      function()
        vim.ui.input({ prompt = "First file: " }, function(file1)
          if not file1 or not file1:match "%S" then return end
          vim.ui.input({ prompt = "Second file: " }, function(file2)
            if file2 and file2:match "%S" then
              vim.cmd(("tabnew | e %s | diffthis | vsplit %s | diffthis"):format(file1, file2))
            end
          end)
        end)
      end,
      desc = "Diff: Compare 2 files",
    },
  },
  opts = {
    diff_binaries = false,
    enhanced_diff_hl = true, -- Better diff highlighting
    use_icons = true,
    show_help_hints = true,
    watch_index = true,
    icons = {
      folder_closed = "",
      folder_open = "",
    },
    signs = {
      fold_closed = "",
      fold_open = "",
      done = "✓",
    },
    view = {
      default = {
        layout = "diff2_horizontal",
        disable_diagnostics = true, -- Cleaner view
        winbar_info = true,
      },
      merge_tool = {
        layout = "diff3_horizontal", -- diff3_horizontal | diff3_vertical | diff3_mixed | diff4_mixed
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        layout = "diff2_horizontal",
        disable_diagnostics = true,
        winbar_info = true,
      },
    },
    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 40,
      },
    },
    file_history_panel = {
      log_options = {
        git = {
          single_file = {
            diff_merges = "combined",
          },
          multi_file = {
            diff_merges = "first-parent",
          },
        },
      },
      win_config = {
        position = "bottom",
        height = 15,
      },
    },
  },
  config = function(_, opts)
    local actions = require "diffview.actions"

    opts.keymaps = {
      disable_defaults = true,
      view = {
        { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" } },

        -- Navigation
        { "n", "]b", actions.select_next_entry, { desc = "Next file" } },
        { "n", "[b", actions.select_prev_entry, { desc = "Previous file" } },

        -- Conflict resolution
        { "n", "[x", actions.prev_conflict,                  { desc = "In the merge-tool: jump to the previous conflict" } },
        { "n", "]x", actions.next_conflict,                  { desc = "In the merge-tool: jump to the next conflict" } },
        { "n", "<leader>co", actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
        { "n", "<leader>ct", actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
        { "n", "<leader>cb", actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
        { "n", "<leader>ca", actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
        { "n", "<leader>cO", actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
        { "n", "<leader>cT", actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
        { "n", "<leader>cB", actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
        { "n", "<leader>cA", actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
      },
      diff2 = {
        -- Mappings in 2-way diff layouts
        { "n", "?", actions.help { "view", "diff2" }, { desc = "Show help" } },
      },
      diff3 = {
        { "n", "?", actions.help { "view", "diff3" }, { desc = "Show help" } },
        -- Conflict resolution in 3-way diff
        { { "n", "x" }, "2do", actions.diffget "ours", { desc = "Get from OURS" } },
        { { "n", "x" }, "3do", actions.diffget "theirs", { desc = "Get from THEIRS" } },
      },
      file_panel = {
        { "n", "?", actions.help "file_panel", { desc = "Show help" } },
        { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" } },
        { "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
        { "n", "o", actions.goto_file_edit, { desc = "Go to file" } },
        { "n", "R", actions.refresh_files, { desc = "Refresh" } },
        { "n", "<tab>", actions.toggle_stage_entry, { desc = "Stage/unstage" } },
        { "n", "S", actions.stage_all, { desc = "Stage all" } },
        { "n", "U", actions.unstage_all, { desc = "Unstage all" } },
      },
      file_history_panel = {
        { "n", "?", actions.help "file_history_panel", { desc = "Show help" } },
        { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close" } },
        { "n", "<cr>", actions.select_entry, { desc = "Open diff" } },
        { "n", "o", actions.goto_file_edit, { desc = "Go to file" } },
        { "n", "y", actions.copy_hash, { desc = "Copy commit hash" } },
        { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
      },
    }

    require("diffview").setup(opts)
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = {
        mappings = {
          -- disable astrocore defaults
          n = {
            ["<Leader>gt"] = false,
            ["<Leader>gT"] = false,
            ["<Leader>gg"] = false,
            ["<Leader>tl"] = false,
            ["<Leader>gd"] = false,
          },
        },
      },
    },
  },
}
