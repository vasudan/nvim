local icons = require "icons"

vim.keymap.set("t", "<C-\\><C-\\>", "<C-\\><C-n>", {
  desc = "Exit terminal mode",
})

local function terminal_picker()
  local terminals = Snacks.terminal.list()
  if #terminals == 0 then
    vim.notify "No active terminals"
    return
  end
  local items = {} ---@type {buf: number, id: number, title: string, cwd: string, tab: string}[]
  for _, t in ipairs(terminals) do
    local buf = t.buf
    local info = vim.b[buf].snacks_terminal or {}
    local id = info.id or "?"
    local cwd = info.cwd or vim.fn.getcwd()
    local title = vim.b[buf].term_title or ("Terminal " .. id)
    local tab = info.env and info.env.tab or ""
    table.insert(items, {
      buf = buf,
      id = id,
      title = title,
      tab = tab,
      text = ("%s %s %s tab:%s"):format(id, title, cwd, tab),
    })
  end
  Snacks.picker {
    title = "Terminals",
    items = items,
    format = function(item)
      local id_str = string.format("%-2s", tostring(item.id))
      local tab_str = item.tab ~= "" and (" [tab:" .. item.tab .. "]") or ""
      return {
        { id_str .. " ", "SnacksPickerDir" },
        { tab_str, "SnacksPickerComment" },
        { item.title .. "  ", "SnacksPickerLabel" },
      }
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      for _, t in ipairs(Snacks.terminal.list()) do
        if t.buf == item.buf then
          t:show():focus()
          return
        end
      end
    end,
  }
end

-- Build <leader>t1 through <leader>t9 keymaps
local terminal_keys = {}
for i = 1, 9 do
  local n = i
  terminal_keys[#terminal_keys + 1] = {
    "<leader>t" .. n,
    function() Snacks.terminal.toggle(nil, { count = n, env = { tab = tostring(vim.api.nvim_get_current_tabpage()) } }) end,
    desc = "Toggle terminal " .. n,
  }
end

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>t", "<Nop>", desc = icons["Terminal"] .. " Terminal" },
    },
  },
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    keys = vim.list_extend({
      {
        "<leader>tf",
        function()
          Snacks.terminal.toggle(
            nil,
            { win = { position = "float" }, env = { tab = tostring(vim.api.nvim_get_current_tabpage()) } }
          )
        end,
        desc = "Toggle floating terminal",
      },
      {
        "<leader>ts",
        terminal_picker,
        desc = "Select terminal",
      },
    }, terminal_keys),
    opts = {
      ---@class snacks.terminal.Opts
      terminal = {
        interactive = false,
        --- Override the default tid function to derive the id from count, cmd, and tab number.
        --- This makes the terminal scoped to the tab instead of the cwd
        ---@param cmd? string | string[]
        ---@param opts? snacks.terminal.Opts
        tid = function(cmd, opts)
          opts = opts or {}
          return vim.inspect {
            cmd = type(cmd) == "table" and cmd or { cmd },
            count = opts.count or vim.v.count1,
            tab = vim.api.nvim_get_current_tabpage(),
          }
        end,
        keys = {
          term_normal = {} -- override default "exit terminal mode" keymap
        }
      },
    },
  },
}
