vim.diagnostic.config {
  update_in_insert = false, -- less visual noise while typing
  severity_sort = true,
  float = {
    border = "rounded",
    source = "if_many",
  },
  virtual_text = true,
  jump = {
    on_jump = function(_, bufnr) vim.diagnostic.open_float { bufnr = bufnr, scope = "cursor", focus = false } end,
  },
}

vim.api.nvim_create_user_command(
  "LspInformation",
  function() vim.cmd.checkhealth "vim.lsp" end,
  { desc = "LSP Information" }
)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("starter-lsp-attach", { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

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

    map("gd", vim.lsp.buf.definition, "Goto definition")
    map("<leader>ld", vim.lsp.buf.definition, "Goto definition")
    map("<leader>lr", vim.lsp.buf.references, "Goto references")
    map("K", vim.lsp.buf.hover, "Hover documentation")
    map("gK", vim.lsp.buf.signature_help, "Signature help")
    map("<leader>ln", vim.lsp.buf.rename, "Rename Symbol")
    map("<leader>la", vim.lsp.buf.code_action, "Code Action")

    map("<leader>li", vim.lsp.buf.implementation, "Show implementations")
    map("<leader>li", vim.lsp.buf.type_definition, "Show type definition")
    map("<leader>lr", vim.lsp.buf.references, "Search references")

    map("<leader>lD", function() require("snacks").picker.diagnostics() end, "Search diagnostics")

    -- Highlight references on cursor hold
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.server_capabilities.documentHighlightProvider then
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

-- Merge blink.cmp capabilities into all LSP server configs.
-- Without this, blink.cmp can't read completion, signature-help, or
-- snippet results from the LSP server.
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities()),
})

local icons = require "icons"
return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>l", "<Nop>", desc = icons["ActiveLSP"] .. "Language Tools" },
  },
}, {
  "neovim/nvim-lspconfig",
  opts = {},
}, {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    words = {
      enabled = true,
    },
  },
}, {
  "stevearc/aerial.nvim",
  keys = {
    {
      "n",
      "<Leader>ls",
      function()
        local aerial_avail, aerial = pcall(require, "aerial")
        if aerial_avail and aerial.snacks_picker then
          aerial.snacks_picker()
        else
          require("snacks").picker.lsp_symbols()
        end
      end,
      "Search symbols",
    },
    { "n", "<Leader>lS", function() require("aerial").toggle() end, "Symbols outline" },
  },
  opts = {},
}
