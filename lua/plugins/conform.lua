-- Conform.nvim: formatter configuration
-- See `:h conform` for documentation

---@type LazySpec
return {
  "stevearc/conform.nvim",
  opts = {
    format_on_save = false, -- disable format on save globally
    formatters_by_ft = {
      typescript = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
    },
    formatters = {
      prettierd = {
        -- args = { "--tab-width", "4" },
      },
      prettier = {
        -- args = { "--tab-width", "4" },
      },
    },
  },
}