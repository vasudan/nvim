local icons = require "icons"

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>d", "<Nop>", desc = icons["Debugger"] .. " Debugger" },
    },
  },
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debugger: Start" },
      { "<F17>", function() require("dap").terminate() end, desc = "Debugger: Stop" }, -- Shift+F5
      {
        "<F21>", -- Shift+F9
        function()
          vim.ui.input({ prompt = "Condition: " }, function(condition)
            if condition then require("dap").set_breakpoint(condition) end
          end)
        end,
        "Debugger: Conditional Breakpoint",
      },
      { "<F29>", function() require("dap").restart_frame() end, desc = "Debugger: Restart" }, -- Control+F5
      { "<F6>", function() require("dap").pause() end, desc = "Debugger: Pause" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Debugger: Toggle Breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "Debugger: Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Debugger: Step Into" },
      { "<F23>", function() require("dap").step_out() end, desc = "Debugger: Step Out" }, -- Shift+F11
      { "<Leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint (F9)" },
      { "<Leader>dB", function() require("dap").clear_breakpoints() end, desc = "Clear Breakpoints" },
      { "<Leader>dc", function() require("dap").continue() end, desc = "Start/Continue (F5)" },
      {
        "<Leader>dC",
        function()
          vim.ui.input({ prompt = "Condition: " }, function(condition)
            if condition then require("dap").set_breakpoint(condition) end
          end)
        end,
        desc = "Conditional Breakpoint (S-F9)",
      },
      { "<Leader>di", function() require("dap").step_into() end, desc = "Step Into (F11)" },
      { "<Leader>do", function() require("dap").step_over() end, desc = "Step Over (F10)" },
      { "<Leader>dO", function() require("dap").step_out() end, desc = "Step Out (S-F11)" },
      { "<Leader>dq", function() require("dap").close() end, desc = "Close Session" },
      { "<Leader>dQ", function() require("dap").terminate() end, desc = "Terminate Session (S-F5)" },
      { "<Leader>dp", function() require("dap").pause() end, desc = "Pause (F6)" },
      { "<Leader>dr", function() require("dap").restart_frame() end, desc = "Restart (C-F5)" },
      { "<Leader>dR", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<Leader>ds", function() require("dap").run_to_cursor() end, desc = "Run To Cursor" },
    },
    config = function()
      local dap = require "dap"

      vim.fn.sign_define("DapBreakpoint", { text = icons["DapBreakpoint"], texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointCondition", { text = icons["DapBreakpointCondition"], texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapBreakpointRejected", { text = icons["DapBreakpointRejected"], texthl = "DiagnosticError", linehl = "", numhl = "" })
      vim.fn.sign_define("DapLogPoint", { text = icons["DapLogPoint"], texthl = "DiagnosticInfo", linehl = "", numhl = "" })
      vim.fn.sign_define("DapStopped", { text = icons["DapStopped"], texthl = "DiagnosticWarn", linehl = "", numhl = "" })

      dap.listeners.on_config["rust-build"] = function(config)
        -- automatically run build when starting a rust project
        if config.request == "launch" and vim.fn.findfile("Cargo.toml", ".;") ~= "" then
          vim.notify("Building Rust project with cargo...", vim.log.levels.INFO)
          local co = coroutine.running()
          vim.fn.jobstart({ "cargo", "build" }, {
            on_exit = function(_, exit_code)
              if exit_code == 0 then
                vim.notify("cargo build succeeded", vim.log.levels.INFO)
                coroutine.resume(co, config)
              else
                vim.notify("cargo build failed! Debug session aborted.", vim.log.levels.ERROR)
                coroutine.resume(co, require("dap").ABORT)
              end
            end,
          })
          return coroutine.yield()
        end
        return config
      end
    end,
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "nvim-dap", "mason-org/mason.nvim" },
        cmd = { "DapInstall", "DapUninstall" },
        opts_extend = { "ensure_installed" },
        opts = { ensure_installed = {}, handlers = {} },
      },
      {
        "igorlfs/nvim-dap-view",
        lazy = true,
        keys = {
          { "<Leader>du", function() require("dap-view").toggle() end, desc = "Toggle Debugger UI" },
          { "<Leader>dh", function() require("dap-view").hover() end, desc = "Debugger Hover" },
          { "<Leader>dw", "<Cmd>DapViewWatch<CR>", desc = "Add to Watches" },
          { "<Leader>dw", "<Cmd>DapViewWatch<CR>", desc = "Add to Watches", mode = "v" },
        },
        ---@type dapview.Config
        opts = {},
      },
      {
        "rcarriga/cmp-dap",
        lazy = true,
        specs = {
          {
            "saghen/blink.cmp",
            optional = true,
            specs = { "saghen/blink.compat", lazy = true, opts = {} },
            opts = {
              sources = {
                providers = {
                  dap = {
                    name = "dap",
                    module = "blink.compat.source",
                    score_offset = 100,
                  },
                },
              },
            },
          },
        },
      },
    },
  }
}
