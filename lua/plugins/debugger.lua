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
      { "n", "<F5>", function() require("dap").continue() end, "Debugger: Start" },
      { "n", "<F17>", function() require("dap").terminate() end, "Debugger: Stop" }, -- Shift+F5
      {
        "n",
        "<F21>", -- Shift+F9
        function()
          vim.ui.input({ prompt = "Condition: " }, function(condition)
            if condition then require("dap").set_breakpoint(condition) end
          end)
        end,
        "Debugger: Conditional Breakpoint",
      },
      { "n", "<F29>", function() require("dap").restart_frame() end, "Debugger: Restart" }, -- Control+F5
      { "n", "<F6>", function() require("dap").pause() end, "Debugger: Pause" },
      { "n", "<F9>", function() require("dap").toggle_breakpoint() end, "Debugger: Toggle Breakpoint" },
      { "n", "<F10>", function() require("dap").step_over() end, "Debugger: Step Over" },
      { "n", "<F11>", function() require("dap").step_into() end, "Debugger: Step Into" },
      { "n", "<F23>", function() require("dap").step_out() end, "Debugger: Step Out" }, -- Shift+F11
      { "n", "<Leader>db", function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint (F9)" },
      { "n", "<Leader>dB", function() require("dap").clear_breakpoints() end, "Clear Breakpoints" },
      { "n", "<Leader>dc", function() require("dap").continue() end, "Start/Continue (F5)" },
      {
        "n",
        "<Leader>dC",
        function()
          vim.ui.input({ prompt = "Condition: " }, function(condition)
            if condition then require("dap").set_breakpoint(condition) end
          end)
        end,
        "Conditional Breakpoint (S-F9)",
      },
      { "n", "<Leader>di", function() require("dap").step_into() end, "Step Into (F11)" },
      { "n", "<Leader>do", function() require("dap").step_over() end, "Step Over (F10)" },
      { "n", "<Leader>dO", function() require("dap").step_out() end, "Step Out (S-F11)" },
      { "n", "<Leader>dq", function() require("dap").close() end, "Close Session" },
      { "n", "<Leader>dQ", function() require("dap").terminate() end, "Terminate Session (S-F5)" },
      { "n", "<Leader>dp", function() require("dap").pause() end, "Pause (F6)" },
      { "n", "<Leader>dr", function() require("dap").restart_frame() end, "Restart (C-F5)" },
      { "n", "<Leader>dR", function() require("dap").repl.toggle() end, "Toggle REPL" },
      { "n", "<Leader>ds", function() require("dap").run_to_cursor() end, "Run To Cursor" },
    },
    opts = function()
      local dap = require "dap"
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
          { "n", "<Leader>du", function() require("dap-view").toggle() end, "Toggle Debugger UI" },
          { "n", "<Leader>dh", function() require("dap-view").hover() end, "Debugger Hover" },
          { { "n", "v" }, "<Leader>dw", "<Cmd>DapViewWatch<CR>", "Add to Watches" },
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
