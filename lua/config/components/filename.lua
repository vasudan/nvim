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
function M.filename()
  return {
    provider = function()
      local path = vim.api.nvim_buf_get_name(0)
      if path == "" then return "[No Name]" end
      local max_len = math.floor(vim.api.nvim_win_get_width(0) / 2)
      return M.truncate_path(vim.fn.fnamemodify(path, ":~"), max_len)
    end,
    hl = { fg = "winbar_fg" },
  }
end

return M
