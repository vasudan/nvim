-- Loader (faster startup)
vim.loader.enable()

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- If icons look broken or missing, install a Nerd Font: https://www.nerdfonts.com/
vim.g.icons_enabled = true

-- Options
vim.opt.number = true -- line numbers
vim.opt.mouse = "a" -- allow mouse
vim.opt.clipboard = "" -- unnamedplus -- sync with system clipboard
vim.opt.ignorecase = true -- case-insensitive search...
vim.opt.smartcase = true -- ...unless you type capitals
vim.opt.termguicolors = true -- 24-bit color support
vim.opt.expandtab = true -- spaces instead of tabs
vim.opt.shiftwidth = 4 -- default indent when using >>
vim.opt.tabstop = 4 -- default indent when using <Tab>
vim.opt.signcolumn = "yes" -- always show gutter
vim.opt.splitright = true -- vertical splits go right
vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.cursorline = true -- highlight current line
vim.opt.scrolloff = 4 -- keep some context around cursor
vim.opt.confirm = true -- dialog on unsaved changes instead of error
vim.opt.inccommand = "split" -- live preview of :s substitutions
vim.opt.updatetime = 250 -- faster LSP diagnostics
vim.opt.timeoutlen = 300 -- faster which-key popup
vim.opt.showmode = false -- already shown in the statusline
vim.opt.breakindent = true -- wrapped lines keep their indentation
vim.opt.wrap = false -- no line wrapping in code

-- Persistent undo history — files accumulate in ~/.local/state/nvim/undo/
-- Clean up periodically:  rm -rf ~/.local/state/nvim/undo/
vim.opt.undofile = true
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.list = true -- show invisible characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Yank highlight — flash yanked text briefly ─────────────────────────────
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Flash yanked text",
	group = vim.api.nvim_create_augroup("starter-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- File
vim.keymap.set("n", "<leader>w", "<cmd>write<CR>", { desc = "Write" })
vim.keymap.set("n", "<leader>q", "<cmd>close<CR>", { desc = "Quit buffer" })

-- Clear search highlights with Escape
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Split navigation — Ctrl + hjkl to move between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Focus left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Focus right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Focus lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Focus upper window" })

-- keep selection in visual mode after indent
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

require "win_term_setup" -- This needs to be called before lazy_setup so toggle-term uses the right shell.
require "lazy_setup"
require "git"
require "polish"
