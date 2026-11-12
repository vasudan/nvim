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
    enabled = vim.fn.executable "git" == 1,
    keys = {
      { "<leader>g", "<Nop>", desc = icons["Git"] .. " Git" },
      { "<leader>gf", git_fetch, desc = "Git fetch" },
      { "<leader>gc", git_commit, desc = "Git commit" },
      { "<leader>gp", git_push, desc = "Git push" },
      { "<leader>gP", git_pull, desc = "Git pull" },
      { "<leader>gS", git_stash, desc = "Git stash push" },
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      { "<Leader>go", function() require("snacks").gitbrowse() end, desc = "Git browse (open)" },
      { "<Leader>gb", function() require("snacks").picker.git_branches { all = true } end, desc = "Git branches" },
      {
        "<Leader>gl",
        function() require("snacks").picker.git_log { current_file = true, follow = true } end,
        desc = "Git log (current file)",
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
        map("n", "[G", function() gitsigns.nav_hunk "first" end, { desc = "First Git hunk" })
        map("n", "]G", function() gitsigns.nav_hunk "last" end, { desc = "Last Git hunk" })
        map("n", "]g", function() gitsigns.nav_hunk "next" end, { desc = "Next Git hunk" })
        map("n", "[g", function() gitsigns.nav_hunk "prev" end, { desc = "Previous Git hunk" })
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "inside Git hunk" })
      end,
    },
  },
  {
    "dlyongemallo/diffview-plus.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewToggle",
      "DiffviewFileHistory",
      "DiffviewDiffFiles",
      "DiffviewLog",
    },
    keys = {
      { "<leader>gg", "<Cmd>DiffviewOpen<CR>", desc = "Show git status" },
      { "<leader>gv", "<Cmd>DiffviewFileHistory<CR>", desc = "Repo history" },
      { "<leader>gV", "<Cmd>DiffviewFileHistory %<CR>", desc = "Current file history" },
      { "<leader>gv", ":'<,'>DiffviewFileHistory<CR>", desc = "Selection history" },
      {
        "<leader>gr",
        function()
          vim.ui.input({ prompt = "Compare revision (ex. main, HEAD~5, main..HEAD): " }, function(refs)
            if refs and refs:match "%S" then vim.cmd(("DiffviewOpen %s"):format(refs)) end
          end)
        end,
        desc = "Diff: compare revisions",
      },
      {
        "<leader>gR",
        function()
          vim.ui.input({ prompt = "File history range (ex. HEAD~1, main..HEAD): " }, function(range)
            if range and range:match "%S" then vim.cmd(("DiffviewFileHistory --range=%s %%"):format(range)) end
          end)
        end,
        desc = "Diff: file history with range",
      },
      {
        "<leader>g2",
        function()
          local picker = require "snacks.picker"
          local diff = {}

          ---@param state {file1?: string}
          diff.pick = function(state, index)
            picker {
              source = "files",
              prompt = ("File %d of 2: "):format(index),
              actions = {
                confirm = function(p, item) ---@diagnostic disable-line: param-type-mismatch
                  p:close()
                  if not item then return end
                  local rel = item.filename or item.text
                  local path = rel:match "/" and rel or (vim.fs.joinpath(vim.uv.cwd(), rel))
                  if state.file1 then
                    vim.cmd(("tabnew | e %s | diffthis | vsplit %s | diffthis"):format(state.file1, path))
                  else
                    state.file1 = path
                    diff.pick(state, 2)
                  end
                end,
              },
            }
          end
          diff.pick({}, 1)
        end,
        desc = "Diff: Compare 2 files",
      },
    },
    opts = function(_, opts)
      opts.diff_binaries = false
      opts.enhanced_diff_hl = true
      opts.use_icons = true
      opts.show_help_hints = true
      opts.watch_index = true
      opts.view = {
        default = {
          layout = "diff1_inline",
          disable_diagnostics = true, -- Cleaner view
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
      }
      opts.file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 40,
        },
      }
      opts.file_history_panel = {
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
      }
      local actions = require "diffview.actions"
      opts.keymaps = {
        disable_defaults = true,
        view = {
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close diff view" } },

          -- Navigation
          { "n", "]b", actions.select_next_entry, { desc = "Next file" } },
          { "n", "[b", actions.select_prev_entry, { desc = "Previous file" } },
        },
        diff2 = {
          -- Mappings in 2-way diff layouts
          { "n", "?", actions.help { "view", "diff2" }, { desc = "Show help" } },
        },
        diff3 = {
          { "n", "?", actions.help { "view", "diff3" }, { desc = "Show help" } },
          { { "n", "x" }, "2do", actions.diffget "ours", { desc = "Diffget the cursor hunk from OURS" } },
          { { "n", "x" }, "3do", actions.diffget "theirs", { desc = "Diffget the cursor hunk from THEIRS" } },
          -- Conflict resolution
          { "n", "[x",          actions.prev_conflict,                  { desc = "Jump to the previous conflict marker" } },
          { "n", "]x",          actions.next_conflict,                  { desc = "Jump to the next conflict marker" } },
          { "n", "<leader>co",  actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
          { "n", "<leader>ct",  actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
          { "n", "<leader>cb",  actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
          { "n", "<leader>ca",  actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
          { "n", "dx",          actions.conflict_choose("none"),        { desc = "Delete the conflict region" } },
          { "n", "<leader>cO",  actions.conflict_choose_all("ours"),    { desc = "Choose the OURS version of a conflict for the whole file" } },
          { "n", "<leader>cT",  actions.conflict_choose_all("theirs"),  { desc = "Choose the THEIRS version of a conflict for the whole file" } },
          { "n", "<leader>cB",  actions.conflict_choose_all("base"),    { desc = "Choose the BASE version of a conflict for the whole file" } },
          { "n", "<leader>cA",  actions.conflict_choose_all("all"),     { desc = "Choose all the versions of a conflict for the whole file" } },
          { "n", "dX",          actions.conflict_choose_all("none"),    { desc = "Delete the conflict region for the whole file" } },
          { "n", "<leader>cso", actions.conflict_choose_side("ours"),   { desc = "Replace the MERGED buffer with the entire OURS side" } },
          { "n", "<leader>cst", actions.conflict_choose_side("theirs"), { desc = "Replace the MERGED buffer with the entire THEIRS side" } },
          { "n", "<leader>csb", actions.conflict_choose_side("base"),   { desc = "Replace the MERGED buffer with the entire BASE side" } },
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
          { "n", "r", git_revert_file, { desc = "Revert file" } },
        },
        file_history_panel = {
          { "n", "?", function() require("diffview.actions").help "file_history_panel" end, { desc = "Show help" } },
          { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close" } },
          { "n", "<cr>", function() require("diffview.actions").select_entry() end, { desc = "Open diff" } },
          { "n", "o", function() require("diffview.actions").goto_file_edit() end, { desc = "Go to file" } },
          { "n", "y", function() require("diffview.actions").copy_hash() end, { desc = "Copy commit hash" } },
          { "n", "L", function() require("diffview.actions").open_commit_log() end, { desc = "Show commit details" } },
        },
      }
    end,
  },
}
