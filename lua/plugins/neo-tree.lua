---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)

    opts.window.mappings["<F2>"] = "rename"
    -- Disable <space> in neo-tree so it doesn't steal the leader key.
    opts.window.mappings["<space>"] = false
    opts.filesystem.filtered_items = {
      visible = true,
    }
    opts.filesystem.follow_current_file = { enabled = false }
    return opts
  end,

  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        -- disable default explorer mappings
        maps.n["<Leader>o"] = false
        maps.n["<Leader>e"] = {
          function()
            -- Only search windows in the current tab
            for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].filetype == "neo-tree" then
                -- Neo-tree is already open in this tab
                if vim.api.nvim_get_current_win() == win then
                  -- Currently focused on it → close
                  vim.cmd.Neotree "close"
                  return
                end
              end
            end
            -- Not currently focused on neo-tree → reveal current file
            vim.cmd.Neotree "reveal"
          end,
          desc = "Toggle Explorer Tree",
        }
      end,
    },
  },
}
