return {
  {
    "NMAC427/guess-indent.nvim",
    opts = {},
  },
  {
    "nvimtools/none-ls.nvim",
    main = "null-ls",
    opts = function(_, opts)
      opts.sources = {
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
      }
    end,
    dependencies = {
      {
        "jay-babu/mason-null-ls.nvim",
        dependencies = { "mason-org/mason.nvim" },
        cmd = { "NullLsInstall", "NullLsUninstall" },
        opts_extend = { "ensure_installed" },
        opts = { ensure_installed = {}, handlers = {} },
      },
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    keys = {
      { "n", "<leader>ua", function() require("astrocore.toggles").autopairs() end, "Toggle autopairs" },
    },
    opts_extend = { "disable_filetype" },
    opts = {
      disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input" },
      check_ts = true,
      ts_config = { java = false },
    },
  },
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = false,
      },
    },
  },
}
