local M = {}

local installed = {}
function M.installed(update)
  if update then
    local treesitter_avail, treesitter = pcall(require, "nvim-treesitter")
    if treesitter_avail then
      installed = {}
      for _, lang in ipairs(treesitter.get_installed "parsers") do
        installed[lang] = true
      end
    end
  end
  return installed
end

function M.has_parser()
  local filetype_num = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[filetype_num].filetype
  local lang = vim.treesitter.language.get_lang(filetype --[[ @as string ]])
  if not lang or not M.installed()[lang] then return false end
  return true
end

function M.setup()
  if not M.has_parser() then return end
  vim.treesitter.start() -- highlighting
  vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- folds
  vim.wo.foldmethod = "expr" --folds
  vim.wo.foldlevel = 99 -- start with all folds open
  -- commenting out because indets are broken with some languages, like C#
  -- autoindent and guess-indent should cover this
  -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

return M

