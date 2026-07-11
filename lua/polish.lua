-- Map <C-\><C-\> to exit terminal as well as the default (<C-\><C-n>)
-- ToggleTerm has this keymap as well
vim.keymap.set("t", "<C-\\><C-\\>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

