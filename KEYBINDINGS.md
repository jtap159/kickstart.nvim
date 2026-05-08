# Neovim Keybinding Quick Reference

> Leader key is `<Space>`. Discovered a useful key? Add it here.

---

## Motion — Move Without Thinking

| Key               | Action                                      |
| ----------------- | ------------------------------------------- |
| `w` / `b` / `e`   | Next / prev / end of word                   |
| `W` / `B` / `E`   | Same but ignores punctuation                |
| `0` / `^` / `$`   | Line start / first non-blank / end          |
| `gg` / `G`        | File top / bottom                           |
| `{` / `}`         | Jump up / down by paragraph                 |
| `<C-d>` / `<C-u>` | Half-page down / up (cursor stays centered) |
| `%`               | Jump to matching bracket `()` `[]` `{}`     |
| `f{x}` / `F{x}`   | Jump to char `x` forward / backward on line |
| `t{x}` / `T{x}`   | Jump _before_ char `x` forward / backward   |
| `;` / `,`         | Repeat last `f/F/t/T` forward / backward    |
| `*` / `#`         | Search word under cursor forward / backward |
| `<C-o>` / `<C-i>` | Jump back / forward through jump history    |

---

## The Vim Grammar: `[operator][motion or text-object]`

| Operator  | Meaning                             |
| --------- | ----------------------------------- |
| `d`       | Delete (cuts to register)           |
| `c`       | Change (delete + enter insert mode) |
| `y`       | Yank (copy)                         |
| `>` / `<` | Indent / dedent                     |

| Text Object | Targets                    |
| ----------- | -------------------------- |
| `iw` / `aw` | inner / around word        |
| `i"` / `a"` | inside / around `"quotes"` |
| `i)` / `a)` | inside / around `(parens)` |
| `i}` / `a}` | inside / around `{braces}` |
| `ip` / `ap` | inside / around paragraph  |

**Examples:**

- `ciw` — change the word under cursor
- `di"` — delete contents of a string
- `ya)` — yank everything including the parens
- `>ap` — indent the whole paragraph
- `ci(` — change everything inside `(`

---

## Power Commands

| Key                    | Action                                          |
| ---------------------- | ----------------------------------------------- |
| `.`                    | Repeat last change — extremely powerful         |
| `u` / `<C-r>`          | Undo / redo                                     |
| `~`                    | Toggle case of char under cursor                |
| `J`                    | Join line below to current line                 |
| `<C-a>` / `<C-x>`      | Increment / decrement number under cursor       |
| `qa` ... `q` then `@a` | Record / replay macro into register `a`         |
| `gg=G`                 | Re-indent entire file                           |
| `<C-v>`                | Visual block mode — edit multiple lines at once |

---

## Splits & Buffers

| Key                | Action                                  |
| ------------------ | --------------------------------------- |
| `<C-h/j/k/l>`      | Move between splits                     |
| `:vsp` / `:sp`     | Open vertical / horizontal split        |
| `<leader><leader>` | Switch between open buffers (Telescope) |
| `<leader>s.`       | Recent files                            |

---

## Telescope — Find Anything

| Key          | Action                           |
| ------------ | -------------------------------- |
| `<leader>sf` | Find files                       |
| `<leader>sg` | Live grep (search file contents) |
| `<leader>sw` | Grep word under cursor           |
| `<leader>sh` | Search help docs                 |
| `<leader>sd` | Search diagnostics               |
| `<leader>/`  | Fuzzy find in current buffer     |
| `<leader>sr` | Resume last search               |

---

## LSP — Code Intelligence

| Key         | Action                              |
| ----------- | ----------------------------------- |
| `grd`       | Go to definition                    |
| `grr`       | Find all references                 |
| `grn`       | Rename symbol across files          |
| `gra`       | Code action (fix, import, refactor) |
| `gO`        | Document symbols (outline)          |
| `<C-t>`     | Jump back after go-to               |
| `<leader>q` | Diagnostics → quickfix list         |

---

## Git Hunks (gitsigns)

A "hunk" is a block of changed lines in the current file.

| Key          | Action                             |
| ------------ | ---------------------------------- |
| `]c` / `[c`  | Jump to next / prev hunk           |
| `<leader>hp` | Preview hunk (see the diff inline) |
| `<leader>hs` | Stage hunk                         |
| `<leader>hr` | Reset hunk (discard change)        |
| `<leader>hb` | Blame line                         |
| `<leader>hd` | Diff this file vs index            |
| `<leader>tb` | Toggle inline blame on every line  |

---

## Surround (mini.surround)

| Key     | Example              | Result    |
| ------- | -------------------- | --------- |
| `saiw)` | cursor on `hello`    | `(hello)` |
| `sd"`   | cursor inside `"hi"` | `hi`      |
| `sr)"`  | cursor inside `(hi)` | `"hi"`    |

---

## Terminal

| Key          | Action                                      |
| ------------ | ------------------------------------------- |
| `<leader>\`` | Toggle terminal                             |
| `<leader>a`  | Toggle terminal size (small ↔ half screen) |
| `<Esc>`      | Exit terminal mode back to normal           |
