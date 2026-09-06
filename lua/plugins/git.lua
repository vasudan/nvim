if vim.fn.executable "git" ~= 1 then return {} end

local git_commit = function()
  vim.ui.input({ prompt = "Commit message: " }, function(msg)
    if not msg or msg == "" then return end
    local result = vim.fn.systemlist { "git", "commit", "-m", msg }
    if vim.v.shell_error ~= 0 then
      vim.notify("git commit failed:\n" .. table.concat(result, "\n"), vim.log.levels.ERROR)
      return
    end
    vim.notify("git commit:\n" .. table.concat(result, "\n"), vim.log.levels.INFO)
  end)
end

local git_fetch = function()
  local result = vim.fn.systemlist { "git", "fetch" }
  if vim.v.shell_error ~= 0 then
    vim.notify("git fetch failed:\n" .. table.concat(result, "\n"), vim.log.levels.ERROR)
    return
  end
  vim.notify("git fetch:\n" .. table.concat(result, "\n"), vim.log.levels.INFO)
end
local git_pull = function()
  local result = vim.fn.systemlist { "git", "pull" }
  if vim.v.shell_error ~= 0 then
    vim.notify("git pull failed:\n" .. table.concat(result, "\n"), vim.log.levels.ERROR)
    return
  end
  vim.notify("git pull:\n" .. table.concat(result, "\n"), vim.log.levels.INFO)
end

local git_push = function()
  vim.ui.select({ "No", "Yes", "Push + track upstream (-u origin)" }, {
    prompt = "Push changes?",
  }, function(choice)
    if not choice or choice == "No" then return end
    local cmd = choice == "Yes" and { "git", "push" } or { "git", "push", "-u", "origin", "HEAD" }
    local result = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then
      vim.notify("git push failed:\n" .. table.concat(result, "\n"), vim.log.levels.ERROR)
      return
    end
    vim.notify("git push:\n" .. table.concat(result, "\n"), vim.log.levels.INFO)
  end)
end

local git_revert_file = function()
  vim.ui.select({ "No", "Yes" }, {
    prompt = "Revert file? This will discard all changes.",
  }, function(choice)
    if not choice or choice == "No" then return end
    require("diffview.actions").restore_entry()
  end)
end

local git_stash = function()
  vim.ui.input({ prompt = "Stash message (optional): " }, function(msg)
    local cmd = { "git", "stash", "push" }
    if msg and msg:match "%S" then vim.list_extend(cmd, { "-m", msg }) end
    vim.fn.jobstart(cmd, {
      on_exit = function(_, code)
        if code == 0 then
          vim.notify("Stash saved", vim.log.levels.INFO)
        else
          vim.notify("Stash failed", vim.log.levels.ERROR)
        end
      end,
    })
  end)
end

vim.api.nvim_create_user_command("Fetch", git_fetch, { desc = "Git fetch" })
vim.api.nvim_create_user_command("Commit", git_commit, { desc = "Git commit" })
vim.api.nvim_create_user_command("Push", git_push, { desc = "Git push" })
vim.api.nvim_create_user_command("Pull", git_pull, { desc = "Git pull" })
vim.api.nvim_create_user_command("Stash", git_stash, { desc = "Git stash push", nargs = "?" })

local icons = require "icons"
vim.api.nvim_set_hl(0, "SnacksPickerGitStatusUntracked", { link = "Added" }) -- easier to see added files

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>g", "<Nop>", desc = icons["Git"] .. " Git" },
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      { "<Leader>go", function() require("snacks").gitbrowse() end, desc = "Git browse (open)" },
      { "<Leader>gb", function() require("snacks").picker.git_branches() end, desc = "Git branches" },
      {
        "<Leader>gl",
        function() require("snacks").picker.git_log { current_file = true, follow = true } end,
        "Git log (current file)",
      },
      { "<Leader>gL", function() require("snacks").picker.git_log() end, desc = "Git log (repository)" },
      { "<Leader>gs", function() require("snacks").picker.git_stash() end, desc = "Git stash" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    enabled = vim.fn.executable "git" == 1,
    opts = {
      signs = {
        add = { text = icons["GitSign"] },
        change = { text = icons["GitSign"] },
        delete = { text = icons["GitSign"] },
        topdelete = { text = icons["GitSign"] },
        changedelete = { text = icons["GitSign"] },
        untracked = { text = icons["GitSign"] },
      },
      signs_staged = {
        add = { text = icons["GitSign"] },
        change = { text = icons["GitSign"] },
        delete = { text = icons["GitSign"] },
        topdelete = { text = icons["GitSign"] },
        changedelete = { text = icons["GitSign"] },
        untracked = { text = icons["GitSign"] },
      },
      on_attach = function(bufnr)
        local gitsigns = require "gitsigns"
        local function map(mode, l, r, keys)
          keys = keys or {}
          keys.buffer = bufnr
          vim.keymap.set(mode, l, r, keys)
        end
        local prefix = "<Leader>g"
        map(
          "n",
          prefix .. "a",
          function() gitsigns.blame_line { full = true } end,
          { desc = "View Git blame (annotate)" }
        )
        map("n", prefix .. "f", git_fetch, { desc = "Git fetch" })
        map("n", prefix .. "c", git_commit, { desc = "Git commit" })
        map("n", prefix .. "p", git_push, { desc = "Git push" })
        map("n", prefix .. "P", git_pull, { desc = "Git pull" })
        map("n", prefix .. "S", git_stash, { desc = "Git stash push" })
        -- maps.n[prefix .. "p"] = { function() gitsigns.preview_hunk_inline() end, desc = "Preview Git hunk" }
        -- maps.n[prefix .. "r"] = { function() gitsigns.reset_hunk() end, desc = "Reset Git hunk" }
        -- maps.v[prefix .. "r"] = {
        --   function() gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        --   desc = "Reset Git hunk",
        -- }
        -- maps.n[prefix .. "R"] = { function() gitsigns.reset_buffer() end, desc = "Reset Git buffer" }
        -- maps.n[prefix .. "s"] = { function() gitsigns.stage_hunk() end, desc = "Stage/Unstage Git hunk" }
        -- maps.v[prefix .. "s"] = {
        --   function() gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
        --   desc = "Stage Git hunk",
        -- }
        -- maps.n[prefix .. "S"] = { function() gitsigns.stage_buffer() end, desc = "Stage Git buffer" }
        -- maps.n[prefix .. "d"] = { function() gitsigns.diffthis() end, desc = "View Git diff" }

        map("n", "[G", function() gitsigns.nav_hunk "first" end, { desc = "First Git hunk" })
        map("n", "]G", function() gitsigns.nav_hunk "last" end, { desc = "Last Git hunk" })
        map("n", "]g", function() gitsigns.nav_hunk "next" end, { desc = "Next Git hunk" })
        map("n", "[g", function() gitsigns.nav_hunk "prev" end, { desc = "Previous Git hunk" })
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "inside Git hunk" })
      end,
    },
  },
  {
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
      use_icons = false,
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
          layout = "diff3_mixed", -- diff3_horizontal | diff3_vertical | diff3_mixed | diff4_mixed
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
      keymaps = {
        disable_defaults = true,
        view = {
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" } },

          -- Navigation
          { "n", "]b", function() require("diffview.actions").select_next_entry() end, { desc = "Next file" } },
          { "n", "[b", function() require("diffview.actions").select_prev_entry() end, { desc = "Previous file" } },

          -- Conflict resolution
          { "n", "[x", function() require("diffview.actions").prev_conflict() end, { desc = "In the merge-tool: jump to the previous conflict" } },
          { "n", "]x", function() require("diffview.actions").next_conflict() end, { desc = "In the merge-tool: jump to the next conflict" } },
          { "n", "<leader>co", function() require("diffview.actions").conflict_choose "ours" end, { desc = "Choose the OURS version of a conflict" } },
          { "n", "<leader>ct", function() require("diffview.actions").conflict_choose "theirs" end, { desc = "Choose the THEIRS version of a conflict" } },
          { "n", "<leader>cb", function() require("diffview.actions").conflict_choose "base" end, { desc = "Choose the BASE version of a conflict" } },
          { "n", "<leader>ca", function() require("diffview.actions").conflict_choose "all" end, { desc = "Choose all the versions of a conflict" } },
          { "n", "<leader>cO", function() require("diffview.actions").conflict_choose_all "ours" end, { desc = "Choose the OURS version of a conflict for the whole file" } },
          { "n", "<leader>cT", function() require("diffview.actions").conflict_choose_all "theirs" end, { desc = "Choose the THEIRS version of a conflict for the whole file" } },
          { "n", "<leader>cB", function() require("diffview.actions").conflict_choose_all "base" end, { desc = "Choose the BASE version of a conflict for the whole file" } },
          { "n", "<leader>cA", function() require("diffview.actions").conflict_choose_all "all" end, { desc = "Choose all the versions of a conflict for the whole file" } },
        },
        diff2 = {
          -- Mappings in 2-way diff layouts
          { "n", "?", function() require("diffview.actions").help { "view", "diff2" } end, { desc = "Show help" } },
        },
        diff3 = {
          { "n", "?", function() require("diffview.actions").help { "view", "diff3" } end, { desc = "Show help" } },
          -- Conflict resolution in 3-way diff
          { { "n", "x" }, "2do", function() require("diffview.actions").diffget("ours") end, { desc = "Get from OURS" } },
          { { "n", "x" }, "3do", function() require("diffview.actions").diffget("theirs") end, { desc = "Get from THEIRS" } },
        },
        file_panel = {
          { "n", "?", function() require("diffview.actions").help "file_panel" end, { desc = "Show help" } },
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" } },
          { "n", "<cr>", function() require("diffview.actions").select_entry() end, { desc = "Open diff" } },
          { "n", "o", function() require("diffview.actions").goto_file_edit() end, { desc = "Go to file" } },
          { "n", "f", "<Cmd>Fetch<CR>", { desc = "Git fetch" } },
          { "n", "c", "<Cmd>Commit<CR>", { desc = "Git commit" } },
          { "n", "p", "<Cmd>Push<CR>", { desc = "Git push" } },
          { "n", "P", "<Cmd>Pull<CR>", { desc = "Git pull" } },
          { "n", "R", function() require("diffview.actions").refresh_files() end, { desc = "Refresh" } },
          { "n", "<tab>", function() require("diffview.actions").toggle_stage_entry() end, { desc = "Stage/unstage" } },
          { "n", "S", function() require("diffview.actions").stage_all() end, { desc = "Stage all" } },
          { "n", "U", function() require("diffview.actions").unstage_all() end, { desc = "Unstage all" } },
          { "n", "X", git_revert_file, { desc = "Revert file" } },
        },
        file_history_panel = {
          { "n", "?", function() require("diffview.actions").help "file_history_panel" end, { desc = "Show help" } },
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close" } },
          { "n", "<cr>", function() require("diffview.actions").select_entry() end, { desc = "Open diff" } },
          { "n", "o", function() require("diffview.actions").goto_file_edit() end, { desc = "Go to file" } },
          { "n", "y", function() require("diffview.actions").copy_hash() end, { desc = "Copy commit hash" } },
          { "n", "L", function() require("diffview.actions").open_commit_log() end, { desc = "Show commit details" } },
        },
      },
    },
  },
}
