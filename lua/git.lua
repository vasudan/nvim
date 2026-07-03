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

vim.api.nvim_create_user_command("Commit", git_commit, { desc = "Git commit with message prompt" })
vim.api.nvim_create_user_command("Push", git_push, { desc = "Git push with confirmation" })
vim.keymap.set('n', "<Leader>gmc", git_commit, { desc = "Git commit" })
vim.keymap.set('n', "<Leader>gmp", git_push, { desc = "Git push" })
vim.keymap.set('n', '<Leader>gm',  "<Nop>", { desc = "Git Commit/Push" }) 
