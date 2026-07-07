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


local git_pull = function()
  local result = vim.fn.systemlist { "git", "pull" }
  if vim.v.shell_error ~= 0 then
    vim.notify("git pull failed:\n" .. table.concat(result, "\n"), vim.log.levels.ERROR)
    return
  end
  vim.notify("git pull:\n" .. table.concat(result, "\n"), vim.log.levels.INFO)
end

local git_push = function()
  if vim.fn.confirm("Push changes?", "&Yes\n&No") == 1 then
    local result = vim.fn.systemlist { "git", "push" }
    if vim.v.shell_error ~= 0 then
      vim.notify("git push failed:\n" .. table.concat(result, "\n"), vim.log.levels.ERROR)
      return
    end
    vim.notify("git push:\n" .. table.concat(result, "\n"), vim.log.levels.INFO)
  end
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

vim.api.nvim_create_user_command("Commit", git_commit, { desc = "Git commit with message prompt" })
vim.api.nvim_create_user_command("Push", git_push, { desc = "Git push with confirmation" })
vim.api.nvim_create_user_command("Pull", git_pull, { desc = "Git pull" })
vim.api.nvim_create_user_command("Stash", git_stash, { desc = "Git stash push", nargs = "?" })
vim.keymap.set("n", "<Leader>gc", git_commit, { desc = "Git commit" })
vim.keymap.set("n", "<Leader>gp", git_push, { desc = "Git push" })
vim.keymap.set("n", "<Leader>gP", git_pull, { desc = "Git pull" })
vim.keymap.set("n", "<Leader>gS", git_push, { desc = "Git stash push" })
