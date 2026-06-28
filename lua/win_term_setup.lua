
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
