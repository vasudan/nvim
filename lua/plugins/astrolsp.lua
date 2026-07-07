--if true then return {} end -- REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    -- Configuration table of features provided by AstroLSP
    features = {
      codelens = true, -- enable/disable codelens refresh on start
      inlay_hints = false, -- enable/disable inlay hints on start
      semantic_tokens = true, -- enable/disable semantic token highlighting
    },
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = false, -- enable or disable format on save globally
      },
      timeout_ms = 1000, -- default format timeout
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
    -- customize language server configuration passed to `vim.lsp.config`
    -- client specific configuration can also go in `lsp/` in your configuration root (see `:h lsp-config`)
    config = {
      -- ["*"] = { capabilities = {} }, -- modify default LSP client settings such as capabilities
    },
    -- customize how language servers are attached
    handlers = {
      -- a function with the key `*` modifies the default handler, functions takes the server name as the parameter
      -- ["*"] = function(server) vim.lsp.enable(server) end

      -- the key is the server that is being setup with `vim.lsp.config`
      -- rust_analyzer = false, -- setting a handler to false will disable the set up of that language server
    },
    -- Configure buffer local auto commands to add when attaching a language server
    autocmds = {
      -- first key is the `augroup` to add the auto commands to (:h augroup)
      lsp_codelens_refresh = {
        -- Optional condition to create/delete auto command group
        -- can either be a string of a client capability or a function of `fun(client, bufnr): boolean`
        -- condition will be resolved for each client on each execution and if it ever fails for all clients,
        -- the auto commands will be deleted for that buffer
        cond = "textDocument/codeLens",
        -- cond = function(client, bufnr) return client.name == "lua_ls" end,
        -- list of auto commands to set
        {
          -- events to trigger
          event = { "InsertLeave", "BufEnter" },
          -- the rest of the autocmd options (:h nvim_create_autocmd)
          desc = "Refresh codelens (buffer)",
          callback = function(args)
            if require("astrolsp").config.features.codelens then vim.lsp.codelens.enable(true, { bufnr = args.buf }) end
          end,
        },
      },
    },
    -- mappings to be set up on attaching of a language server
    mappings = {
      n = {
        ["gK"] = {
          function() vim.lsp.buf.signature_help() end,
          desc = "Signature help",
          cond = "textDocument/signatureHelp",
        },
        ["<Leader>li"] = { function() vim.lsp.buf.implementation() end, desc = "Show implementations" },
        ["<Leader>lt"] = { function() vim.lsp.buf.type_definition() end, desc = "Show type definition" },

        -- use NullLsInfo
        ["<Leader>lI"] = false,

        ["<Leader>lr"] = {
          function() vim.lsp.buf.references() end,
          desc = "Search references",
          cond = "textDocument/references",
        },

        ["<Leader>ln"] = {
          function() vim.lsp.buf.rename() end,
          desc = "Rename current symbol",
          cond = "textDocument/rename",
        },
      },
    },
  },
  specs = {
    {
      "jay-babu/mason-null-ls.nvim",
      opts = {
        handlers = {
          prettier = function()
            require("null-ls").register(require("null-ls").builtins.formatting.prettier.with {
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
            })
          end,
        },
      },
    },
  },
}
