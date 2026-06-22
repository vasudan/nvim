---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  opts = function(_, opts)
    -- Preserve the original on_create if it exists
    local orig_on_create = opts.on_create
    opts.on_create = function(t)
      -- Call the original on_create first (from AstroNvim)
      if orig_on_create then
        orig_on_create(t)
      end

      -- Map <Esc> in terminal mode to exit terminal mode (return to normal mode)
      -- This uses <C-\><C-n> which is the standard Neovim way to exit terminal mode
      vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {
        buffer = t.bufnr,
        desc = "Exit terminal mode",
      })
    end
  end,
}