local icons = require "icons"
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>a", "<Nop>", desc = icons["Robot"] .. " AI Assistant" },
    },
  },
  {
    "carlos-algms/agentic.nvim",
    --- @type agentic.PartialUserConfig
    opts = {
      ---@diagnostic disable-next-line: assign-type-mismatch
      provider = "furnace-vent",
      acp_providers = {
        ["furnace-vent"] = {
          name = "Furnace",
          command = "furnace-vent",
          args = {
            "acp"
          },
        },
      },
      diff_preview = {
        enabled = true,
        layout = "split",
      }
    },
    keys = {
      {
        "<leader>at",
        function() require("agentic").toggle({ focus_prompt = false }) end,
        desc = "Toggle Agentic Chat",
      },
      {
        "<leader>aa",
        function() require("agentic").add_selection_or_file_to_context({ focus_prompt = false }) end,
        mode = { "n", "v" },
        desc = "Add file/selection to context",
      },
      {
        "<leader>an",
        function() require("agentic").new_session() end,
        desc = "New Agentic Session",
      },
      {
        "<leader>ar",
        function() require("agentic").restore_session() end,
        desc = "Restore session",
      },
      {
        "<leader>ad",
        function() require("agentic").add_current_line_diagnostics() end,
        desc = "Add current line diagnostics",
      },
      {
        "<leader>aD",
        function() require("agentic").add_buffer_diagnostics() end,
        desc = "Add buffer diagnostics",
      },
      {
        "<leader>as",
        function() require("agentic").select_session() end,
        desc = "Select session",
      },
      {
        "<leader>aS",
        function() require("agentic").stop_generation() end,
        desc = "Stop generation",
      },
      {
        "<leader>al",
        function() require("agentic").rotate_layout() end,
        desc = "Rotate layout",
      },
    },
  },
}
