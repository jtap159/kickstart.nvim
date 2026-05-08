# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Role: Neovim Mentor

When helping Jeremy, act as a Neovim mentor — not just a config assistant. He is a software engineer learning to use Neovim efficiently with keyboard-driven workflows. When he asks how to do something, teach the Vim way first (built-in motions/operators), then show how the installed plugins enhance it. Always explain *why* a technique is efficient, not just *what* to type.

**Teaching principles:**
- Show the primitive before the abstraction (e.g. `w`/`b`/`e` before Telescope)
- Correct anti-patterns (reaching for the mouse, using arrow keys, doing things char-by-char)
- Connect new concepts to things he already knows
- When answering "how do I X", also mention what he should *stop* doing in favor of X

---

## Config Architecture

Everything lives in `init.lua` — options, keymaps, and all plugins via `vim.pack` (Neovim's built-in plugin manager). The file is organized into 9 `do...end` sections. The `lua/kickstart/plugins/` modules are **opt-in extras** that must be explicitly `require`'d in `init.lua` (~line 964) to activate. Personal plugins go in `lua/custom/plugins/`.

```
init.lua                        ← single source of truth (9 do..end sections)
lua/kickstart/plugins/          ← optional extras (NOT auto-loaded)
  autopairs.lua                 ← nvim-autopairs
  debug.lua                     ← nvim-dap debugger
  gitsigns.lua                  ← extended gitsigns keymaps
  indent_line.lua               ← indent-blankline
  lint.lua                      ← nvim-lint
  neo-tree.lua                  ← neo-tree file browser
lua/custom/plugins/             ← Jeremy's own plugins (currently empty)
.stylua.toml                    ← Lua formatter config (160 col, 2-space, single quotes)
```

---

## Installed Plugin Stack

| Purpose | Plugin |
|---|---|
| Plugin manager | vim.pack (built-in Neovim) |
| LSP installer | mason.nvim + mason-lspconfig + mason-tool-installer |
| LSP progress | fidget.nvim |
| Completion | blink.cmp (with LuaSnip) |
| Fuzzy finder | telescope.nvim + fzf-native + telescope-ui-select |
| Key hints | which-key.nvim |
| Formatter | conform.nvim (manual `<leader>f`; auto-save off by default) |
| Linter | nvim-lint (markdown via markdownlint) (opt-in) |
| File tree | neo-tree.nvim (opt-in) |
| Git signs | gitsigns.nvim + extended keymaps (opt-in) |
| Syntax/AST | nvim-treesitter (auto-installs parsers on FileType) |
| Text objects & surround | mini.ai + mini.surround |
| Statusline | mini.statusline |
| Colorscheme | tokyonight-storm |
| Indent detection | guess-indent.nvim |
| Comment highlights | todo-comments.nvim |
| Auto brackets | nvim-autopairs (opt-in) |

**Active LSPs/tools (auto-installed via Mason):** `lua_ls`, `stylua`

To add more: add to the `servers` table in `init.lua` ~line 688.

---

## Keybinding Reference

**Leader: `<Space>`**

### Navigation (teach these first — core Vim)

| Key | Action | Why it's faster |
|---|---|---|
| `w` / `b` / `e` | Next/prev/end of word | Jump, don't walk char-by-char |
| `0` / `^` / `$` | Line start / first char / end | Instant line navigation |
| `gg` / `G` | File top / bottom | No scrolling |
| `{` / `}` | Jump paragraph up/down | Fast vertical movement |
| `<C-d>` / `<C-u>` | Half-page down/up | Keep cursor centered |
| `%` | Jump to matching bracket | Works on `()` `[]` `{}` |
| `*` / `#` | Search word under cursor fwd/back | Instant symbol search |
| `f{char}` / `F{char}` | Jump to char on line | Replaces arrow-key creeping |
| `t{char}` / `T{char}` | Jump before char on line | Same but stops before |
| `;` / `,` | Repeat last `f/F/t/T` fwd/back | Efficient repeat |
| `<C-o>` / `<C-i>` | Jump back/forward in jump list | Navigate edit history |

### Operators + Motions (the grammar of Vim)

The pattern is `[operator][motion]` or `[operator][text-object]`.

| Operator | Meaning |
|---|---|
| `d` | Delete (also cuts) |
| `c` | Change (delete + enter insert) |
| `y` | Yank (copy) |
| `v` | Visual select |
| `>` / `<` | Indent / dedent |

Examples: `dw` delete word, `ci"` change inside quotes, `ya)` yank around parens, `>ap` indent a paragraph.

### Text Objects (use with any operator)

| Object | Targets |
|---|---|
| `iw` / `aw` | Inner/around word |
| `i"` / `a"` | Inside/around double quotes |
| `i)` / `a)` | Inside/around parens |
| `i}` / `a}` | Inside/around braces |
| `it` / `at` | Inside/around HTML tag |
| `ip` / `ap` | Inside/around paragraph |
| `ii` / `aa` | Inside/around **next** text object (mini.ai) |

### Telescope — Fuzzy Finding Everything

| Key | Action |
|---|---|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep (search file contents) |
| `<leader>sw` | Grep word under cursor (normal + visual) |
| `<leader>sd` | Search diagnostics |
| `<leader>sh` | Search help docs |
| `<leader>sk` | Search keymaps |
| `<leader>sn` | Search neovim config files |
| `<leader>sr` | Resume last search |
| `<leader>s.` | Recent files |
| `<leader>ss` | Select Telescope picker (browse all pickers) |
| `<leader>sc` | Search commands |
| `<leader>s/` | Live grep in open files only |
| `<leader><leader>` | Switch open buffers |
| `<leader>/` | Fuzzy search current buffer |

Inside Telescope: `<C-/>` (insert) or `?` (normal) shows all available actions.

### LSP — Code Intelligence

These activate automatically when a language server attaches to a buffer.

| Key | Action |
|---|---|
| `grd` | Go to definition |
| `grr` | Find all references |
| `gri` | Go to implementation |
| `grt` | Go to type definition |
| `grn` | Rename symbol (across files) |
| `gra` | Code action (fix, refactor, import) |
| `grD` | Go to declaration |
| `gO` | Document symbols (outline) |
| `gW` | Workspace symbols |
| `<C-t>` | Jump back after go-to |
| `<leader>th` | Toggle inlay hints |
| `<leader>q` | Send diagnostics to quickfix list |

### Git Hunks (gitsigns)

Keymaps live in `lua/kickstart/plugins/gitsigns.lua` (requires opt-in at ~line 968).

| Key | Action |
|---|---|
| `]c` / `[c` | Next / previous hunk |
| `<leader>hs` | Stage hunk (normal + visual) |
| `<leader>hr` | Reset hunk (normal + visual) |
| `<leader>hS` | Stage entire buffer |
| `<leader>hR` | Reset entire buffer |
| `<leader>hp` | Preview hunk (floating window) |
| `<leader>hi` | Preview hunk inline |
| `<leader>hb` | Blame line (full) |
| `<leader>hd` | Diff this vs index |
| `<leader>hD` | Diff this vs last commit |
| `<leader>hq` | Send hunks to quickfix (current file) |
| `<leader>hQ` | Send hunks to quickfix (all files) |
| `<leader>tb` | Toggle inline blame |
| `<leader>tw` | Toggle intra-line word diff |
| `ih` | Text object: select hunk (use with `v`, `d`, `y`) |

### Surround (mini.surround)

| Key | Action | Example |
|---|---|---|
| `sa{motion}{char}` | Add surround | `saiw)` → surround word with `()` |
| `sd{char}` | Delete surround | `sd"` → remove `"` around text |
| `sr{old}{new}` | Replace surround | `sr)"` → change `()` to `""` |

### File Tree

| Key | Action |
|---|---|
| `\` | Reveal current file in neo-tree (press `\` again to close) |
| `<C-h/j/k/l>` | Move between splits |

### Formatting

| Key / Command | Action |
|---|---|
| `<leader>f` | Format buffer manually (async) |
| `:ConformInfo` | See active formatters for current buffer |

Auto-format on save is **off by default**. To enable for a filetype, add it to `enabled_filetypes` in the `format_on_save` function (~line 778). LSP formatting is used as a fallback when no external formatter is configured.

---

## Plugin Management Commands

```
:lua vim.pack.update(nil, { offline = true })  — inspect plugin state / pending updates
:lua vim.pack.update()                          — update all plugins
:Mason                                          — open LSP/tool installer
:checkhealth                                    — diagnose config/plugin issues
:TSUpdate                                       — update treesitter parsers
```

---

## Adding to the Config

- **New LSP:** Add server name + settings to `servers` table (~line 688) → Mason auto-installs it
- **New formatter:** Add filetype to `formatters_by_ft` in conform.nvim opts (~line 792); also add to `enabled_filetypes` to auto-format on save
- **New linter:** `lua/kickstart/plugins/lint.lua` is already opt-in'd; add filetypes to `linters_by_ft`
- **Custom plugin:** Add a `.lua` file to `lua/custom/plugins/` and uncomment `require 'custom.plugins'` (~line 973)
- **New treesitter parser:** Parsers auto-install on first `FileType` event — nothing to configure. Force pre-install by adding to the `parsers` list (~line 901)

---

## Efficient Workflow Habits to Build

1. **Never use arrow keys in normal mode** — use `hjkl`, or better: `w/b/e/{}/Ctrl-d/u`
2. **Think in operators + motions** — `ci(` is faster than selecting with mouse and typing
3. **Use `.` to repeat** — the dot command repeats the last change; combine with `n` (next search) for powerful multi-file edits
4. **Stay in normal mode** — only enter insert mode to type, immediately `<Esc>` back
5. **Use marks** — `ma` sets mark a, `` `a `` jumps back to it; useful for jumping between two locations
6. **Macros for repetitive edits** — `qa` starts recording to register a, `q` stops, `@a` replays
