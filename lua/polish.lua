
-- Use gb
vim.keymap.del("n", "]b")

-- Global indentation defaults: 4 spaces
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Shift + cursor keys in insert mode begin selection 
vim.opt.keymodel:append("startsel,stopsel")
vim.opt.selectmode:append("key")
