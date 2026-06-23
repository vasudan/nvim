# AGENTS.md — Navigating this Neovim Configuration

This document helps AI agents (and humans) quickly locate configuration sources and understand the layering in this [AstroNvim](https://astronvim.com) setup.  Use it to **minimise search churn** when debugging mappings, plugin behaviour, or keybinding conflicts.

---

## 1. Directory Map

| Layer | Path | What lives here |
|-------|------|-----------------|
| **User config** | [`lua/`](lua/) | Your personal overrides and plugin specs |
| **User plugin specs** | [`lua/plugins/`](lua/plugins/) | One file per plugin; extends/overrides upstream defaults |
| **User polish** | [`lua/polish.lua`](lua/polish.lua) | Raw `vim.*` calls run after everything else |
| **User community** | [`lua/community.lua`](lua/community.lua) | AstroNvim community pack imports |
| **User lazy setup** | [`lua/lazy_setup.lua`](lua/lazy_setup.lua) | `lazy.nvim` bootstrap and `mapleader` |
| **Entry point** | [`init.lua`](init.lua) | Initialisation |
| **AstroNvim upstream** | `~/.local/share/nvim/lazy/AstroNvim/lua/astronvim/` | The distro's *default* plugin specs and mappings |
| **AstroNvim default mappings** | `…/astronvim/plugins/_astrocore_mappings.lua` | Global normal/terminal-mode keymaps |
| **Plugin source** | `~/.local/share/nvim/lazy/<plugin>/` | Actual plugin code (read-only; use for reference) |

---

## 2. How Mappings are Resolved

### 2.1. Global (normal-mode) keymaps

1. AstroNvim [`_astrocore_mappings.lua`](~/.local/share/nvim/lazy/AstroNvim/lua/astronvim/plugins/_astrocore_mappings.lua) sets the base.
2. Some plugins (*smart-splits*) **overwrite** those base mappings via their `specs` block — look at [`~/.local/share/nvim/lazy/AstroNvim/lua/astronvim/plugins/smart-splits.lua`](~/.local/share/nvim/lazy/AstroNvim/lua/astronvim/plugins/smart-splits.lua).
3. User overrides live in:
   * [`lua/plugins/astrocore.lua`](lua/plugins/astrocore.lua) → `opts.mappings`
   * or any `specs` block inside a user plugin file that targets `AstroNvim/astrocore`.
4. Raw overrides in [`lua/polish.lua`](lua/polish.lua) (runs last).

### 2.2. Buffer-local / window-local keymaps

Some UIs (*snacks picker*, *neo-tree*, *toggleterm*) define **window-local** keymaps that should shadow globals.  The snacks picker defines its per-window maps in the **plugin source** defaults:

| Picker sub-window | Defaults file |
|-------------------|---------------|
| `input` | [`~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/config/defaults.lua`](~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/config/defaults.lua) → `win.input.keys` |
| `list`  | same file → `win.list.keys` |
| `preview` | same file → `win.preview.keys` |

**User overrides** go in [`lua/plugins/snacks.lua`](lua/plugins/snacks.lua) → `opts.picker.win.<subwindow>.keys`.

### 2.3. Snacks picker actions

Available action names are in:
[`~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/actions.lua`](~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/actions.lua)

Key ones: `focus_input`, `focus_list`, `focus_preview`, `cycle_win`, `confirm`, `cancel`, `close`, `toggle_preview`, `toggle_hidden`, `toggle_ignored`.

---

## 3. Debugging a Keybinding Conflict

**If a key does something unexpected inside a special window (picker, terminal, neo-tree):**

1. **Check global maps first** — they are the usual culprit when a window-local map is missing:
   * [`_astrocore_mappings.lua`](~/.local/share/nvim/lazy/AstroNvim/lua/astronvim/plugins/_astrocore_mappings.lua)
   * [`smart-splits.lua`](~/.local/share/nvim/lazy/AstroNvim/lua/astronvim/plugins/smart-splits.lua)
2. **Check the window's local defaults** in the **plugin source**, not just the user config — the plugin may simply not define a map for that key.
3. **Check user overrides** in [`lua/plugins/<plugin>.lua`](lua/plugins/) — did we already shadow it?
4. **Add a window-local map** in the user plugin spec to consume the key locally and prevent the global from firing.

### Example: `<C-h>` / `<C-l>` in snacks picker

* **Symptom:** pressing `<C-h>` or `<C-l>` closes the picker.
* **Root cause:** The global map `<C-h>` → `<C-w>h` (from `_astrocore_mappings.lua` or `smart-splits.lua`) fires because the picker's window-local defaults don't define `<C-h>` / `<C-l>`.  Focus leaves the picker → picker closes.
* **Fix location:** [`lua/plugins/snacks.lua`](lua/plugins/snacks.lua) → `opts.picker.win.input.keys`, `opts.picker.win.list.keys`, `opts.picker.win.preview.keys`.

---

## 4. Common Plugin Config Locations

| Plugin | User spec | Upstream defaults (reference) |
|--------|-----------|-------------------------------|
| astrocore | [`lua/plugins/astrocore.lua`](lua/plugins/astrocore.lua) | `…/astronvim/plugins/_astrocore_mappings.lua` |
| astrolsp | [`lua/plugins/astrolsp.lua`](lua/plugins/astrolsp.lua) | `…/astronvim/plugins/astrolsp.lua` |
| astroui | [`lua/plugins/astroui.lua`](lua/plugins/astroui.lua) | `…/astronvim/plugins/astroui.lua` |
| snacks.nvim | [`lua/plugins/snacks.lua`](lua/plugins/snacks.lua) | `…/astronvim/plugins/snacks.lua` + `…/snacks.nvim/lua/snacks/picker/config/defaults.lua` |
| neo-tree | [`lua/plugins/neo-tree.lua`](lua/plugins/neo-tree.lua) | `…/astronvim/plugins/neo-tree.lua` |
| toggleterm | [`lua/plugins/toggleterm.lua`](lua/plugins/toggleterm.lua) | — |
| conform | [`lua/plugins/conform.lua`](lua/plugins/conform.lua) | — |
| treesitter | [`lua/plugins/treesitter.lua`](lua/plugins/treesitter.lua) | — |
| mason | [`lua/plugins/mason.lua`](lua/plugins/mason.lua) | — |
| user | [`lua/plugins/user.lua`](lua/plugins/user.lua) | — |
| smart-splits | — (loaded by AstroNvim) | `…/astronvim/plugins/smart-splits.lua` |

---

## 5. AstroNvim spec layering and lazy loading

User plugin files in [`lua/plugins/`](lua/plugins/) return a `LazySpec` and are auto-loaded by `lazy.nvim`.  They can:

* **Extend** the upstream spec by returning a table with the same plugin name — `opts` are deep-merged.
* **Add new specs** via a `specs` key, targeting other plugins (e.g., a snacks spec can bolt keys onto astrocore).
* **Override** keys by setting them in `opts.mappings` (for astrocore), `opts.picker.win.<sub>.keys` (for snacks), etc.

When hunting a config value, always check **three layers** in order:
1. User spec in [`lua/plugins/<plugin>.lua`](lua/plugins/)
2. AstroNvim upstream spec in `…/astronvim/plugins/<plugin>.lua`
3. Plugin source defaults in `…/<plugin>/lua/<plugin>/config/`

---

## 6. Quick Search Commands

```bash
# Find all files referencing a keymap
rg '<C-h>' lua/ ~/.local/share/nvim/lazy/AstroNvim/lua/astronvim/

# Find a plugin's default config
ls ~/.local/share/nvim/lazy/<plugin>/lua/<plugin>/config/

# Find all astrocore mappings (global)
rg 'maps\.n\[' ~/.local/share/nvim/lazy/AstroNvim/lua/astronvim/plugins/_astrocore_mappings.lua