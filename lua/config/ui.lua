local M = {}

--- Display a zen_mode icon
--- The component library's built in zen_mode targets a different plugin
local function zen_mode(opts)

  local lib = require "heirline-components.all"
  opts = {
    zen_mode = {
      condition = function() return true end,
      padding = { left = 2, right = 2 }
    },
    hl = lib.hl.get_attributes("winbar"),
    on_click = {
      name = "zen_toggle",
      callback = function()
        require("snacks").toggle.zen():toggle()
      end
    },
  }
  return lib.component.builder(lib.utils.setup_providers(opts, { "zen_mode" }))
end

function M.get_heirline_opts()
  local lib = require "heirline-components.all"
  vim.opt.showtabline = 2 -- always show tabline
  vim.opt.laststatus = 3 -- single global statusline that spans full width across splits
  vim.opt.cmdheight = 0 -- remove command-line when not in use
  return {
    tabline = { -- UI upper bar
      lib.component.tabline_conditional_padding(),
      lib.component.tabline_buffers(),
      lib.component.fill { hl = { bg = "tabline_bg" } },
      lib.component.tabline_tabpages(),
    },
    winbar = { -- UI breadcrumbs bar
      init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
      fallthrough = false,
      -- Winbar for terminal, neotree, and aerial.
      {
        condition = function() return not lib.condition.is_active() end,
        {
          lib.component.fill(),
          lib.component.aerial(),
        },
      },
      -- Regular winbar
      {
        lib.component.breadcrumbs(),
        lib.component.fill(),
        zen_mode(),
        lib.component.aerial(),
      },
    },
    statuscolumn = { -- UI left column
      init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
      lib.component.foldcolumn(),
      lib.component.numbercolumn(),
      lib.component.signcolumn(),
    } or nil,
    -- UI statusbar
    statusline = {
      hl = { fg = "fg", bg = "bg" },
      lib.component.mode { mode_text = {} },
      lib.component.file_info(),
      lib.component.git_branch(),
      lib.component.git_diff(),
      lib.component.diagnostics(),
      lib.component.fill(),
      lib.component.cmd_info(),
      lib.component.fill(),
      lib.component.lsp(),
      lib.component.nav(),
    },
  }
end

return M
