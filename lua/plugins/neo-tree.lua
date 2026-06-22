---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    -- Ensure window.mappings table exists
    opts.window = opts.window or {}
    opts.window.mappings = opts.window.mappings or {}
    -- Map F2 to neo-tree's built-in rename command
    opts.window.mappings["<F2>"] = "rename"
  end,
}