-- Map <C-\><C-\> to exit terminal as well as the default (<C-\><C-n>)
-- ToggleTerm has this keymap as well
vim.keymap.set("t", "<C-\\><C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Global indentation defaults: 4 spaces
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

