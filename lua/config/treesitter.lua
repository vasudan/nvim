local M = {}

local installed = {}
function M.get_installed(update)
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
  if not lang or not M.get_installed()[lang] then return false end
  return true
end

function M.setup_treesitter()
  if not M.has_parser() then return end
  vim.treesitter.start() -- highlighting
  vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- folds
  vim.wo.foldmethod = "expr" --folds
  vim.wo.foldlevel = 99 -- start with all folds open
  -- commenting out because indets are broken with some languages, like C#
  -- autoindent and guess-indent should cover this
  -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

function M.setup()
      -- get the installed TS parsers
      M.get_installed(true)

      vim.api.nvim_create_autocmd("FileType", {
        desc = "Load treesitter for a file",
        group = vim.api.nvim_create_augroup("setup-treesitter-for-file", { clear = true }),
        callback = function()
          M.setup_treesitter()
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        desc = "Cache the installed treesitter parsers after installing a new one",
        pattern = "TSInstall",
        group = vim.api.nvim_create_augroup("get-installed-ts", { clear = true }),
        callback = function()
          -- Update list of installs after installing a new TS parser
          M.get_installed(true)
        end,
      })
end

return M

