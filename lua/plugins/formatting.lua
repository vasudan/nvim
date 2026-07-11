return {
  "NMAC427/guess-indent.nvim",
  opts = {},
}, {
  "nvimtools/none-ls.nvim",
  main = "null-ls",
  opts = {
    sources = {
      require("null-ls").builtins.formatting.prettier.with {
        extra_args = {
          "--arrow-parens",
          "avoid",
          "--end-of-line",
          "lf",
          "--jsx-single-quote",
          "--print-width",
          "155",
          "--quote-props",
          "consistent",
          "--semi",
          "--single-quote",
          "--tab-width",
          "4",
          "--trailing-comma",
          "es5",
          "--no-use-tabs",
        },
      },
    },
  },
  dependencies = {
    {
      "jay-babu/mason-null-ls.nvim",
      dependencies = { "mason-org/mason.nvim" },
      cmd = { "NullLsInstall", "NullLsUninstall" },
      opts_extend = { "ensure_installed" },
      opts = { ensure_installed = {}, handlers = {} },
    },
  }
}
