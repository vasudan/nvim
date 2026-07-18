local icons = require "icons"

vim.lsp.codelens.enable(true)
vim.diagnostic.config {
  update_in_insert = false, -- less visual noise while typing
  underline = true,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons["DiagnosticError"],
      [vim.diagnostic.severity.HINT] = icons["DiagnosticHint"],
      [vim.diagnostic.severity.WARN] = icons["DiagnosticWarn"],
      [vim.diagnostic.severity.INFO] = icons["DiagnosticInfo"],
    },
  },
  float = {
    source = "if_many",
    header = "",
    prefix = "",
  },
  virtual_text = true,
}

vim.api.nvim_create_user_command(
  "LspInformation",
  function() vim.cmd.checkhealth "vim.lsp" end,
  { desc = "LSP Information" }
)

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("starter-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc) vim.keymap.set("n", keys, func, { buffer = event.buf, desc = desc }) end

    local function diagnostic_jump(dir, severity)
      local jump_opts = {}
      if type(severity) == "string" then jump_opts.severity = vim.diagnostic.severity[severity] end
      return function()
        jump_opts.count = dir and vim.v.count1 or -vim.v.count1
        vim.diagnostic.jump(jump_opts)
      end
    end
    map("[e", diagnostic_jump(false, "ERROR"), "Previous error")
    map("]e", diagnostic_jump(true, "ERROR"), "Next error")
    map("[w", diagnostic_jump(false, "WARN"), "Previous warning")
    map("]w", diagnostic_jump(true, "ERROR"), "Next error")

    map("gh", function() vim.diagnostic.open_float { scope = "cursor" } end, "Hover diagnostics")
    map("gd", vim.lsp.buf.definition, "Goto definition")
    map("<leader>ld", vim.lsp.buf.definition, "Goto definition")
    map("<leader>lr", vim.lsp.buf.references, "Goto references")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("gK", vim.lsp.buf.signature_help, "Signature help")
    map("<leader>ln", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>la", vim.lsp.buf.code_action, "Code actions")
    map(
      "<leader>lA",
      function() vim.lsp.buf.code_action { context = { only = { "source" }, diagnostics = {} } } end,
      "Code actions for file"
    )

    map("<leader>li", vim.lsp.buf.implementation, "Show implementations")
    map("<leader>lt", vim.lsp.buf.type_definition, "Show type definition")
    map("<leader>lr", vim.lsp.buf.references, "Search references")
    map("<leader>lc", vim.lsp.codelens.run, "Run codelens action")

    vim.keymap.set("n", "<Leader>/", "gcc", { remap = true, buffer = event.buf, desc = "Toggle comment line" })
    vim.keymap.set("x", "<Leader>/", "gc", { remap = true, buffer = event.buf, desc = "Toggle comment" })
  end,
})

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>l", "<Nop>", desc = icons["ActiveLSP"] .. " Language Tools" },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts_extend = { "library" },
    opts = {
      library = {
        { path = "lazy.nvim", words = { "LazySpec" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "blink.cmp", words = { "blink" } },
        { path = "lazydev.nvim", words = { "LazyDev" } },
        { path = "render-markdown.nvim", words = { "RenderMarkdown" } },
        { path = "which-key.nvim", words = { "WhichKey" } },
        { path = "auto-session", words = { "AutoSession" } },
      },
    },
    specs = {
      {
        "saghen/blink.cmp",
        optional = true,
        opts = {
          sources = {
            default = { "lazydev" },
            providers = {
              lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
            },
          },
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim", -- install LSPs via Mason
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    cmd = { "LspInstall", "LspUninstall" },
    opts_extend = { "ensure_installed" },
    opts = {
      automatic_enable = true, -- start the correct LSP when loading a filetype
      ensure_installed = {},
    },
  },
  {
    "stevearc/aerial.nvim", -- used for breadcrumb in winbar
    opts = {},
  },
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>ls", function() require("snacks").picker.lsp_symbols() end, desc = "LSP Symbols" },
      { "<leader>lS", function() require("snacks").picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
      { "<leader>lD", function() require("snacks").picker.diagnostics() end, desc = "Search diagnostics" },
    },
    ---@type snacks.Config
    opts = {
      words = {
        enabled = true,
      },
      indent = {
        indent = { char = "▏" },
        scope = { char = "▏" },
        filter = function(bufnr) return vim.g.snacks_indent ~= false and vim.b[bufnr].snacks_indent ~= false end,
        animate = { enabled = false },
      },
    },
  },
  {
    "saghen/blink.cmp", -- code completion
    dependencies = {
      "saghen/blink.lib",
    },
    ---@diagnostic disable-next-line: undefined-field (blink.cmp is missing an annotation for pwait, but its there)
    build = function() require("blink.cmp").build():pwait() end,

    ---@module 'blink.cmp'
    ---@param opts blink.cmp.Config
    opts = function(_, opts)
      -- Merge blink.cmp capabilities into all LSP server configs.
      -- Without this, blink.cmp can't read completion, signature-help, or
      -- snippet results from the LSP server.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities()),
      })
      -- See :h blink-cmp-config-keymap for defining your own keymap
      opts.keymap = {
        preset = "none",
        ["<C-x>"] = { "show", "show_documentation", "hide_documentation", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-y>"] = { "select_and_accept", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
      }

      -- show the documentation popup automatically
      opts.completion = { documentation = { auto_show = true } }

      -- list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      opts.sources = { default = { "lsp", "path", "snippets", "buffer" } }

      -- Rust fuzzy matcher for typo resistance and significantly better performance
      -- You may use a lua implementation instead by using `implementation = "lua"`
      -- See the fuzzy documentation for more information
      opts.fuzzy = { implementation = "rust" }
    end,
  },
  {
    "neovim-treesitter/nvim-treesitter",
    dependencies = { "neovim-treesitter/treesitter-parser-registry" },
    lazy = false,
    build = ":TSUpdate",
    config = function(_)
      require("config.treesitter").setup()
    end
  },
}
