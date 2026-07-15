local toggle_explorer = function()
  local explorer_pickers = Snacks.picker.get { source = "explorer", tab = true }
  for _, v in pairs(explorer_pickers) do
    if v:is_focused() then
      v:close()
    else
      Snacks.explorer.reveal()
      v:focus()
    end
  end
  if #explorer_pickers == 0 then Snacks.explorer.reveal() end
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>e", toggle_explorer, desc = "Toggle Explorer" },
    },
    ---@type snacks.Config
    opts = {
      explorer = {
        replace_netrw = true,
        trash = true,
      },
      picker = {
        sources = {
          ---@class snacks.picker.explorer.Config: snacks.picker.files.Config|{}
          explorer = {
            follow_file = false,
            hidden = true, -- shows hidden files
            win = {
              list = {
                keys = {
                  ["<BS>"] = { "explorer_up", desc = "Go to parent directory" },
                  ["l"] = { "confirm", desc = "Open file or expand directory" },
                  ["h"] = { "explorer_close", desc = "Collapse directory" },
                  ["a"] = { "explorer_add", desc = "Add new file/directory" },
                  ["d"] = { "explorer_del", desc = "Delete file/directory" },
                  ["r"] = { "explorer_rename", desc = "Rename file/directory" },
                  ["c"] = { "explorer_copy", desc = "Copy file/directory" },
                  ["m"] = { "explorer_move", desc = "Move file/directory" },
                  ["o"] = { "explorer_open", desc = "Open with system application" },
                  ["P"] = { "toggle_preview", desc = "Toggle preview pane" },
                  ["y"] = { "explorer_yank", desc = "Yank file/directory", mode = { "n", "x" } },
                  ["Y"] = { "copy_path", desc = "Copy filepath to clipboard" },
                  ["p"] = { "explorer_paste", desc = "Paste file/directory" },
                  ["u"] = { "explorer_update", desc = "Refresh explorer" },
                  ["<c-c>"] = { "tcd", desc = "Set working directory to current" },
                  ["<c-t>"] = { "open_terminal", desc = "Open a terminal in the directory" },
                  ["fw"] = { "picker_grep", desc = "Live grep in directory" },
                  ["."] = { "explorer_focus", desc = "Focus current file in explorer" },
                  ["I"] = { "toggle_ignored", desc = "Toggle ignored files" },
                  ["H"] = { "toggle_hidden", desc = "Toggle hidden files" },
                  ["Z"] = { "explorer_close_all", desc = "Collapse all directories" },

                  -- By default these controls will focus the preview. In this case, I want to select the file buffer
                  ["<C-h>"] = false,
                  ["<C-l>"] = false,

                  -- All these keymaps are handled by other pickers
                  ["<leader>/"] = false,
                  ["]g"] = false,
                  ["[g"] = false,
                  ["]d"] = false,
                  ["[d"] = false,
                  ["]w"] = false,
                  ["[w"] = false,
                  ["]e"] = false,
                  ["[e"] = false,
                },
              },
            },
            actions = {
              open_terminal = function(_, item)
                local dir
                if item.file then
                  if vim.fn.isdirectory(item.file) == 1 then
                    dir = item.file
                  else
                    dir = vim.fn.fnamemodify(item.file, ":h")
                  end
                end
                Snacks.terminal.open(nil, dir and { cwd = dir } or nil)
              end,
              copy_path = function(_, item)
                local modify = vim.fn.fnamemodify
                local filepath = item.file
                local filename = modify(filepath, ":t")
                local values = {
                  filepath,
                  modify(filepath, ":."),
                  modify(filepath, ":~"),
                  filename,
                  modify(filename, ":r"),
                  modify(filename, ":e"),
                }
                local items = {
                  "Absolute path: " .. values[1],
                  "Path relative to CWD: " .. values[2],
                  "Path relative to HOME: " .. values[3],
                  "Filename: " .. values[4],
                }
                if vim.fn.isdirectory(filepath) == 0 then
                  vim.list_extend(items, {
                    "Filename without extension: " .. values[5],
                    "Extension of the filename: " .. values[6],
                  })
                end
                vim.ui.select(items, { prompt = "Choose to copy to clipboard:" }, function(choice, i)
                  if not choice then
                    vim.notify "Selection cancelled"
                    return
                  end
                  if not i then
                    vim.notify "Invalid selection"
                    return
                  end
                  local result = values[i]
                  vim.fn.setreg('"', result) -- Neovim unnamed register
                  vim.fn.setreg("+", result) -- System clipboard
                  vim.notify("Copied: " .. result)
                end)
              end,
            },
          },
        },
      },
    },
  },
}

