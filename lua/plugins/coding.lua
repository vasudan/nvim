return {
  "saghen/blink.cmp",
  dependencies = {
    "saghen/blink.lib",
  },
  build = function()
    -- build the fuzzy matcher, optionally add a timeout to `pwait(timeout_ms)`
    -- you can use `gb` in `:Lazy` to rebuild the plugin as needed
    require("blink.cmp").build():pwait()
  end,

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = "none",
      ["<C-x>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<CR>"] = { "select_and_accept" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
      ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
    },

    -- show the documentation popup automatically
    completion = { documentation = { auto_show = true } },

    -- list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = { default = { "lsp", "path", "snippets", "buffer" } },

    -- Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"`
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "rust" },
  },
}, {
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
}, {
  "windwp/nvim-ts-autotag",
  event = "InsertEnter",
  opts = {
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = false,
    },
  },
}, {
  "nvim-treesitter/nvim-treesitter",
  dependencies = { "neovim-treesitter/treesitter-parser-registry" },
  lazy = false,
  build = ":TSUpdate",
}, {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    indent = {
      indent = { char = "▏" },
      scope = { char = "▏" },
      filter = function(bufnr) return vim.g.snacks_indent ~= false and vim.b[bufnr].snacks_indent ~= false end,
      animate = { enabled = false },
    }
  }
}
