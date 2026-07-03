-- Map <C-\><C-\> to exit terminal as well as the default (<C-\><C-n>)
-- ToggleTerm has this keymap as well
vim.keymap.set("t", "<C-\\><C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Global indentation defaults: 4 spaces
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Use system clipboard by default
vim.opt.clipboard = 'unnamedplus' 

-- Remap 'c', 'C', 'd', 'D', 'x' and 'X' to so that yanked text is only added to the clipboard
vim.keymap.set({ 'n', 'v' }, 'c', '"cc')
vim.keymap.set({ 'n', 'v' }, 'C', '"cC')
vim.keymap.set({ 'n', 'v' }, 'd', '"dd')
vim.keymap.set({ 'n', 'v' }, 'D', '"dD')
vim.keymap.set({ 'n', 'v' }, 'x', '"xx')
vim.keymap.set({ 'n', 'v' }, 'X', '"xX')
