-- Disable some of the astronvim default plugins

---@type LazySpec
return {
  { "max397574/better-escape.nvim", enabled = false },
  { "folke/todo-comments.nvim", enabled = false },
  { "L3MON4D3/LuaSnip", enabled = false },
  { "nvim-neo-tree/neo-tree.nvim", enabled = false }
}
