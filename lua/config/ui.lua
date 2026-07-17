local M = {}

function M.get_heirline_opts()
  local lib = require "heirline-components.all"
  vim.opt.showtabline = 2 -- always show tabline
  vim.opt.laststatus = 3 -- single global statusline that spans full width across splits
  vim.opt.cmdheight = 0 -- remove command-line when not in use
  vim.opt.foldcolumn = 'auto'
  return {
    tabline = { -- upper most bar
      lib.component.tabline_conditional_padding(),
      lib.component.tabline_buffers(),
      lib.component.fill { hl = { bg = "tabline_bg" } },
      lib.component.tabline_tabpages(),
    },
    winbar = { -- upper bar right below tabline
      init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
      condition = function() return lib.condition.is_active() end,
      {
        lib.component.breadcrumbs(),
        lib.component.fill(),
        require("config.components.filename").filename(),
        require("config.components.debugger_status").debugger_status()
      },
    },
    statuscolumn = { -- UI left column
      init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
      lib.component.foldcolumn(),
      lib.component.numbercolumn(),
      lib.component.signcolumn(),
    } or nil,
    statusline = { -- bottom bar
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
