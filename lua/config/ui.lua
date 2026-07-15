local M = {}

--- Truncate a file path by replacing middle components with "…" when too long.
--- Modeled after snacks.nvim's `M.truncpath`.
--- @param path string The full file path
--- @param max_len number Maximum display width before truncation (default: 60)
--- @return string
function M.truncate_path(path, max_len)
  max_len = max_len or 60
  if vim.api.nvim_strwidth(path) <= max_len then
    return path
  end

  local parts = vim.split(path, "/")
  if #parts < 2 then
    return path
  end

  local tail = table.remove(parts)        -- filename
  local head = table.remove(parts, 1)      -- first segment
  if head == "~" and #parts > 0 then
    head = "~/" .. table.remove(parts, 1)  -- "~/" + next segment
  end

  local head_w = vim.api.nvim_strwidth(head)
  local tail_w = vim.api.nvim_strwidth(tail)
  local width = head_w + tail_w + 3 -- 3 for "/…"

  if width > max_len then
    -- Head + tail alone exceeds limit; truncate the tail
    return head .. "/…/" .. vim.fn.strcharpart(tail, tail_w - (max_len - head_w - 3), max_len - head_w - 3)
  end

  -- Fill middle directories from the back until we run out of room
  while width < max_len and #parts > 0 do
    local part = table.remove(parts) .. "/"
    local w = vim.api.nvim_strwidth(part)
    if width + w > max_len then
      break
    end
    tail = part .. tail
    width = width + w
  end

  return head .. "/…/" .. tail
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
      condition = function() return lib.condition.is_active() end,
      {
        lib.component.breadcrumbs(),
        lib.component.fill(),
        { provider = lib.provider.file_icon(), },
        {
          provider = function()
            local path = vim.api.nvim_buf_get_name(0)
            if path == "" then return "[No Name]" end
            local max_len = math.floor(vim.api.nvim_win_get_width(0) / 2)
            return M.truncate_path(vim.fn.fnamemodify(path, ":~"), max_len)
          end,
          hl = { fg = "winbar_fg" },
        },
        {
          -- DAP debug status indicator
          condition = function()
            local ok, dap = pcall(require, "dap")
            return ok and dap.session() ~= nil
          end,
          provider = function()
            local dap = require("dap")
            local status = dap.status()
            local icons = require("icons")
            if status == "stopped" then
              return icons["DapStopped"] .. " "
            else
              return icons["Debugger"] .. " "
            end
          end,
          hl = function()
            local dap = require("dap")
            if dap.status() == "stopped" then
              return { fg = "DiagnosticWarn" }
            else
              return { fg = "DiagnosticInfo" }
            end
          end,
        },
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
