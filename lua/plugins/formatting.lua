
vim.api.nvim_create_user_command(
  "Format",
  function() vim.lsp.buf.format() end,
  { desc = "Format buffer" }
)

vim.keymap.set("n", "<leader>lf", function() vim.lsp.buf.format() end, { desc = "Format buffer" })

return {
  {
    "NMAC427/guess-indent.nvim",
    opts = {},
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "jay-babu/mason-null-ls.nvim",
        dependencies = { "mason-org/mason.nvim" },
        cmd = { "NullLsInstall", "NullLsUninstall" },
        opts_extend = { "ensure_installed" },
        opts = { ensure_installed = {}, handlers = {} },
      },
    },
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
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    keys = {
      { "<leader>ua", function() require("astrocore.toggles").autopairs() end, desc = "Toggle autopairs" },
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
