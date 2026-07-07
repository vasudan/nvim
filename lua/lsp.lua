
vim.api.nvim_create_user_command("LspInformation", function() vim.cmd.checkhealth "vim.lsp" end, { desc = "LSP Information" })
