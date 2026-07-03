
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec", "disable.ft", "disable.bt" },
  opts = function(_, opts)
    if not opts.icons then opts.icons = {} end
    opts.icons.group = ""
    opts.icons.rules = false
    opts.icons.separator = "-"
  end,
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps",
    },
  },
}