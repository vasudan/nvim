
<C-Up> and <C-Down> while in search picker mode selects previous/next search history items

Using format (<Leader>lf) while in visual mode will only format that sections

Exit out of terminal mode with <C-\\\\> or <C-\\><C-n>

Use `?` and `<Leader>?` in a buffer to show commands

Add `<Nop>` as the function to create which-key labels
`vim.keymap.set('n', '<Leader>gm',  "<Nop>", { desc = "Git Commit/Push" })`

To replace all occurences in a file:
1. Search `<Leader>fw`
2. Add results to quickfix list: `<C-q>`
3. Run command: `:cfdo %s/original/replace/gc`
   - Omit `c` to run without confirming each replacement
