local M = {}

local icons = require("icons")
function M.debugger_status()
  return {
    -- DAP debug status indicator
    condition = function()
        local session = require("dap").session()
        return session ~= nil
    end,
    provider = function()

      return icons["Debugger"] .. require("dap").status()
    end,
    hl = "Debug"
  }
end

return M
