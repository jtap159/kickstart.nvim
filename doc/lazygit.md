# Lazygit Usage Guide

Lazygit is a terminal UI for git. In this config it runs inside a floating Neovim window via the `lazygit.nvim` plugin (`lua/kickstart/plugins/lazygit.lua`).

The plugin is **opt-in** — toggle it by commenting/uncommenting its `require` line near the bottom of `init.lua`.

---

## Prerequisites

The plugin shells out to the external `lazygit` binary. It must be on `$PATH`.

- **Online install:** `sudo mv lazygit /usr/local/bin/ && sudo chmod +x /usr/local/bin/lazygit`
- **Air-gapped install:** the binary tarball ships inside the airgap bundle at `config/nvim/dist/lazygit_*_linux_x86_64.tar.gz`. The `neovim-bundle-airgap` skill includes it automatically, and `RESTORE.md` (generated inside each bundle) has a "Install lazygit" step that extracts it to `/opt/lazygit/lazygit` and symlinks `/usr/local/bin/lazygit`.

Verify: `lazygit --version` should print a version string.

---

## Neovim Commands

| Command | What it does |
|---|---|
| `:LazyGit` | Open lazygit on the repo containing cwd |
| `:LazyGitCurrentFile` | Open lazygit on the repo containing the current buffer |
| `:LazyGitFilter` | Open commit-log filter mode for the whole repo |
| `:LazyGitFilterCurrentFile` | Commit-log filter restricted to the current file |
| `:LazyGitConfig` | Open lazygit's own config (`~/.config/lazygit/config.yml`) |

## Neovim Keybindings

`<leader>` is `<Space>`.

| Key | Action |
|---|---|
| `<leader>gg` | Open lazygit (`:LazyGit`) |
| `<leader>gf` | Open lazygit scoped to current file's repo |
| `<leader>gl` | Filtered commit log for current file |

Press `q` or `<Esc>` to return to Neovim.

---

## Inside Lazygit — Panel Layout

Five panels on the left, diff/output on the right. Press `?` at any time for context-sensitive help for the focused panel.

1. **Status** — repo state, current branch
2. **Files** — working tree + staged changes
3. **Local branches** — list/checkout/create/delete branches
4. **Commits** — log of current branch
5. **Stash** — stashed changes

| Key | Action |
|---|---|
| `h` / `l` or `1`..`5` | Switch between panels |
| `j` / `k` | Move within a panel |
| `?` | Show help for the focused panel |
| `q` / `<Esc>` | Quit |

---

## Everyday Staging and Commit (Files Panel)

| Key | Action |
|---|---|
| `<space>` | Stage / unstage selected file (toggle) |
| `a` | Stage / unstage all |
| `d` | Discard changes (prompts first) |
| `e` | Edit file in `$EDITOR` |
| `i` | Add to `.gitignore` |
| `c` | Commit staged changes |
| `C` | Commit using git's editor (long messages) |
| `A` | Amend last commit |
| `w` | Commit, skip pre-commit hook |

Commit message editor: type, `<Esc>` then `:wq`. Empty message aborts.

---

## Hunk-Level Staging

The killer feature. With a file selected in the Files panel:

| Key | Action |
|---|---|
| `<enter>` | Drill into file — shows each hunk |
| `<space>` | Stage / unstage the focused hunk |
| `j` / `k` | Move between hunks |
| `<tab>` | Toggle staged / unstaged view of this file |
| `e` | Edit hunk manually (line-by-line) |
| `<Esc>` | Back out to Files panel |

Use this when one file has several unrelated edits you want to commit separately.

> This complements gitsigns' `<leader>hs` (stage hunk under cursor) — gitsigns stages from the buffer, lazygit gives you a visual diff view across the whole file.

---

## Push / Pull / Fetch

| Key | Action |
|---|---|
| `p` | Pull |
| `P` | Push |
| `<C-f>` | Fetch (no merge) |
| `f` | Force push (prompts) |

---

## Branches Panel

| Key | Action |
|---|---|
| `<space>` | Checkout focused branch |
| `n` | New branch from current HEAD |
| `N` | New branch from focused branch |
| `d` | Delete branch |
| `r` | Rebase current branch onto focused branch |
| `M` | Merge focused branch into current |
| `f` | Fast-forward focused branch without checking it out |
| `R` | Rename branch |
| `o` | Create pull request (if a forge is configured) |

---

## Commits Panel

| Key | Action |
|---|---|
| `<enter>` | Show files changed in commit + per-file diff |
| `<space>` | Checkout commit (detached HEAD) |
| `r` | Reword commit message |
| `R` | Reword via `$EDITOR` |
| `e` | Edit commit (drops into interactive rebase here) |
| `d` | Drop commit |
| `s` | Squash into commit below |
| `f` | Fixup into commit below |
| `g` | Reset to this commit (soft/mixed/hard) |
| `t` | Revert (creates a new revert commit) |
| `c` | Copy commit hash to clipboard |
| `C` | Copy commit message to clipboard |
| `T` | Tag this commit |

---

## Interactive Rebase

No need to memorize `git rebase -i` syntax — lazygit gives you the visual version.

1. Go to **Commits** panel.
2. Move to the commit **just before** the range you want to edit.
3. Press `e` — lazygit drops you into the rebase at that commit.
4. Above the rebase marker, commits are editable:
   - `<C-j>` / `<C-k>` — reorder commits (plain `j`/`k` only moves the cursor)
   - `s` — squash into commit above
   - `f` — fixup into commit above
   - `d` — drop
   - `r` — reword
   - `p` — pick (default)
5. Use the rebase menu (`m`) to continue or abort.

Conflicts are flagged in the Files panel — see Merge Conflicts below.

---

## Stash

| Where | Key | Action |
|---|---|---|
| Files panel | `s` | Stash all changes (prompts for message) |
| Files panel | `S` | Stash menu (stash staged only, keep index, etc.) |
| Stash panel | `<space>` | Apply stash |
| Stash panel | `g` | Pop (apply + drop) |
| Stash panel | `d` | Drop stash |
| Stash panel | `n` | New branch from stash |
| Stash panel | `r` | Rename stash |

---

## Merge Conflicts

Conflicted files appear in red in the Files panel. Press `<enter>` on one to enter conflict view:

| Key | Action |
|---|---|
| `<space>` | Pick the focused hunk |
| `b` | Pick both versions |
| `<up>` / `<down>` | Move between conflict chunks |
| `e` | Open in `$EDITOR` for manual edit |
| `<Esc>` | Back out |

Once all conflicts are resolved, lazygit auto-continues the merge or rebase.

---

## Reflog (Recovery)

If you lose work — bad rebase, dropped commit, hard reset — the reflog has your back. In the Status panel, scroll to the **Reflog** section (or press `5` if it's the active panel index in your build). Each entry is a recoverable state. Press `g` then "hard" to reset back to it.

---

## Configuration

Plugin-level options live in `lua/kickstart/plugins/lazygit.lua`:

```lua
vim.g.lazygit_floating_window_use_plenary       = 1     -- already set
vim.g.lazygit_floating_window_winblend          = 0     -- 0 = opaque
vim.g.lazygit_floating_window_scaling_factor    = 0.9   -- fraction of screen
vim.g.lazygit_use_neovim_remote                 = 1     -- requires `nvr` (pip install neovim-remote)
```

Lazygit's own config (colors, custom commands, prompts) is at `~/.config/lazygit/config.yml`. Open it with `:LazyGitConfig`.

---

## Air-gapped Notes

For deployment to an air-gapped machine, the bundle needs:

1. The **`lazygit` binary** — already in `dist/lazygit_*_linux_x86_64.tar.gz`. The `neovim-bundle-airgap` skill copies `dist/` into the bundle and `RESTORE.md` includes a step that extracts it to `/opt/lazygit/lazygit` and symlinks to `/usr/local/bin/lazygit`.
2. The **`lazygit.nvim` plugin** at `~/.local/share/nvim/site/pack/core/opt/lazygit.nvim/`.
3. The **`plenary.nvim` plugin** at `~/.local/share/nvim/site/pack/core/opt/plenary.nvim/`.
4. `vim.g.airgapped = true` in `init.lua` — the bundling skill flips this automatically.

The bundle and RESTORE.md handle 1–4. If you ever bump the lazygit version, drop the new tarball into `dist/` (replacing the old one) before running the bundling skill.

---

## Troubleshooting

**`lazygit: command not found`**
The binary isn't on `$PATH`. Run `which lazygit` — if empty, copy or symlink the binary into `/usr/local/bin/`.

**`E492: Not an editor command: LazyGit`**
The plugin isn't loaded. Check the `require 'kickstart.plugins.lazygit'` line in `init.lua` is uncommented, restart Neovim, then `:lua print(vim.fn.exists(':LazyGit'))` should return `2`.

**Commit message editor hangs / nested nvim**
Lazygit is launching a separate `nvim` for the message. Either set `EDITOR=nvim` in your shell rc, or install `nvr` (`pip install neovim-remote`) — then `vim.g.lazygit_use_neovim_remote = 1` opens commits in the *current* Neovim instance.

**Floating window looks broken / no borders**
Terminal may lack Unicode box-drawing chars. Override `vim.g.lazygit_floating_window_border_chars` with ASCII alternatives like `{ '+', '-', '+', '|', '+', '-', '+', '|' }`.

---

## See Also

- `lua/kickstart/plugins/lazygit.lua` — plugin spec and keymaps
- `lua/kickstart/plugins/gitsigns.lua` — in-buffer hunk staging (complementary to lazygit)
- Upstream: <https://github.com/jesseduffield/lazygit> and <https://github.com/kdheepak/lazygit.nvim>
