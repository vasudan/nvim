-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
  if vim.v.shell_error ~= 0 then
    -- stylua: ignore
    vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
    vim.fn.getchar()
    vim.cmd.quit()
  end
end

vim.opt.rtp:prepend(lazypath)

local sysName = vim.loop.os_uname().sysname
local isWin = sysName:find 'Windows' and true or false
if isWin then
  -- All of these options are required to make powershell work
  vim.opt.shellxquote = ''
  vim.opt.shellquote = ''
  vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command '
	vim.opt.shellpipe = '| Out-File -Encoding UTF8 %s'
	vim.opt.shellredir = '| Out-File -Encoding UTF8 %s'
  if vim.fn.executable("pwsh") == 1 then
    vim.opt.shell = "pwsh" --"pwsh" for 7.x if installed
    vim.opt.shellcmdflag = vim.opt.shellcmdflag + " $PSStyle.OutputRendering = 'PlainText';"
  else
    vim.opt.shell = "powershell" --"powershell" for 5.x
  end
end

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"
