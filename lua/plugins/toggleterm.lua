local terms = require "toggleterm.terminal"
local lazy = require "toggleterm.lazy"
local utils = lazy.require "toggleterm.utils"


---@type LazySpec
return {
  "akinsho/toggleterm.nvim",
  opts = function(_, opts)
    -- Preserve the original on_create if it exists
    local orig_on_create = opts.on_create
    opts.on_create = function(t)
      -- Call the original on_create first (from AstroNvim)
      if orig_on_create then orig_on_create(t) end

      -- Map <Esc> in terminal mode to exit terminal mode (return to normal mode)
      -- This uses <C-\><C-n> which is the standard Neovim way to exit terminal mode
      vim.keymap.set("t", "<C-\\><C-\\>", "<C-\\><C-n>", {
        buffer = t.bufnr,
        desc = "Exit terminal mode",
      })
    end
  end,

  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local function select_terminal()
          local terminals = terms.get_all()
          if terminals == 0 then return utils.notify("No toggleterms are open yet", "info") end

          vim.ui.select(terminals, {
            prompt = "Please select a terminal to open (or focus): ",
            format_item = function(term) return term.id .. ": " .. term:_display_name() end,
          }, function(_, idx)
            local term = terminals[idx]
            if not term then return end
            if term:is_open() then
              term:focus()
            else
              term:open()
            end
          end)
        end

        opts.mappings.n["<Leader>ts"] = { select_terminal, desc = "Select terminal" }
      end,
    },
  },
}
