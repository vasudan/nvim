return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      ["<C-Space>"] = false, -- disable the for showing autocomplete
      ["<C-x>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
    },
  },
}
