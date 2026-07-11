---@type LazySpec
return {
  {
    "mason-org/mason.nvim",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
    },
    opts_extend = { "registries" },
    opts = function(_, opts)
      if not opts.registries then opts.registries = {} end
      table.insert(opts.registries, "github:mason-org/mason-registry")
      if not opts.ui then opts.ui = {} end
      opts.ui.icons = vim.g.icons_enabled == false
          and {
            package_installed = "O",
            package_uninstalled = "X",
            package_pending = "0",
          }
        or {
          package_installed = "✓",
          package_uninstalled = "✗",
          package_pending = "⟳",
        }
    end,
    build = ":MasonUpdate",
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsUpdateSync",
      "MasonToolsClean",
    },
    dependencies = {
      "mason-org/mason.nvim",
    },
    opts_extend = { "ensure_installed" },
    opts = {
      run_on_start = true,
      auto_update = false,
      ensure_installed = {
        -- install language servers
        "lua-language-server",

        -- install formatters
        "stylua",

        -- install debuggers
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
      },
      integrations = { ["mason-lspconfig"] = false, ["mason-null-ls"] = false, ["mason-nvim-dap"] = false },
    },
  },
}

