local M = {}

function M.setup()
  -- Make references when hovering over a variable more pronounced
  -- The default colorscheme values are often too dim to notice
  local palette = require("astrotheme.palettes.astromars")
  local ref_bg = palette.ui.none_text
  vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#392d30" })
end

return M
