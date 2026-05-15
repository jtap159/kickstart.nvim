# Claude Code Usage Guide

Claude Code is Anthropic's CLI agent. In this config it runs *inside* Neovim via the `claudecode.nvim` plugin (`lua/kickstart/plugins/claudecode.lua`), in a `:terminal` split — no separate tmux pane needed.

The plugin is **opt-in** — toggle it by commenting/uncommenting its `require` line near the bottom of `init.lua`.

---

## Prerequisites

The plugin shells out to the external `claude` binary. It must be on `$PATH`.

- **Online install:** `npm install -g @anthropic-ai/claude-code` (the npm package wraps a self-contained ELF — Node is only used by the installer, not at runtime).
- **Air-gapped install:** the binary tarball ships inside the airgap bundle at `config/nvim/dist/claude_*_linux_x86_64.tar.gz`. `scripts/bundle-airgap.sh` verifies it before bundling, and `RESTORE.md` (generated inside each bundle) has an "Install Claude Code CLI" step that extracts it to `/opt/claude/claude` and symlinks `/usr/local/bin/claude`.

Verify: `claude --version` should print something like `2.1.142 (Claude Code)`.

**Auth:** the binary itself needs credentials. If you used `claude login` on your dev box, copy `~/.claude/.credentials.json` to the VM (or re-run `claude login` if the VM can reach Anthropic). Without creds, the plugin loads fine and the terminal opens, but chats won't return.

**Air-gap reachability:** the *plugin* makes no network calls of its own — it spawns `claude` and talks to it over a local lockfile + WebSocket (`~/.claude/ide/<port>.lock`). The `claude` *binary* still needs a route to `api.anthropic.com`. On a true air-gap VM with no outbound path, the plugin works mechanically but you won't get responses. On a VM with an internal proxy to Anthropic, everything works.

---

## Neovim Commands

| Command | What it does |
|---|---|
| `:ClaudeCode` | Toggle the Claude terminal split |
| `:ClaudeCodeFocus` | Move cursor into the Claude split (without toggling) |
| `:ClaudeCode --resume` | Resume the most recent session |
| `:ClaudeCode --continue` | Continue the previous turn |
| `:ClaudeCodeSelectModel` | Pick the model interactively (uses `vim.ui.select` → telescope-ui-select dropdown) |
| `:ClaudeCodeAdd <path>` | Add a file to Claude's context. `%` for the current buffer |
| `:ClaudeCodeSend` | Send the current visual selection as a message |
| `:ClaudeCodeTreeAdd` | (Inside a file tree like neo-tree) add the focused file |
| `:ClaudeCodeDiffAccept` | Accept the diff Claude proposed in the current diff buffer |
| `:ClaudeCodeDiffDeny` | Discard the diff Claude proposed |

## Neovim Keybindings

`<leader>` is `<Space>`. The prefix is `<leader>c` (the plugin's default `<leader>a` collides with harpoon).

| Key | Mode | Action |
|---|---|---|
| `<leader>cc` | n | Toggle Claude session |
| `<leader>cf` | n | Focus Claude split |
| `<leader>cr` | n | Resume last session |
| `<leader>cC` | n | Continue previous turn |
| `<leader>cm` | n | Select model |
| `<leader>cb` | n | Add current buffer to context |
| `<leader>cs` | v | Send visual selection |
| `<leader>ca` | n | Accept proposed diff |
| `<leader>cd` | n | Deny proposed diff |

Inside the Claude terminal, the standard Neovim terminal escape applies: `<Esc><Esc>` exits terminal mode (mapped at `init.lua` Section 1), then you can use normal-mode motions, copy text with `y`, etc. Re-enter terminal-insert with `i` or `a`.

---

## Typical Workflows

### Ask a quick question
1. `<leader>cc` opens the split.
2. Type your question, `<Enter>` to send.
3. `<leader>cc` again to hide. The session stays alive.

### Send a code selection for review
1. Visual-select a region (`v`, `V`, or `<C-v>`).
2. `<leader>cs` ships the selection into Claude.
3. The Claude split focuses automatically and the assistant responds.

### Drop a whole file into context
1. With the buffer open: `<leader>cb` (binds to `:ClaudeCodeAdd %`).
2. Or in neo-tree: navigate to the file, `<leader>cs` (the plugin remaps it to `:ClaudeCodeTreeAdd` for file-tree filetypes).

### Review and apply a proposed change
When Claude proposes an edit, the plugin opens a diff view:
- `<leader>ca` accepts and writes the change.
- `<leader>cd` rejects and discards.

### Continue across Neovim restarts
`<leader>cr` (resume) attaches to the most recent session — chat history intact.

---

## Configuration

The setup call lives in `lua/kickstart/plugins/claudecode.lua`:

```lua
require('claudecode').setup {
  terminal = {
    provider = 'native',           -- Neovim built-in :terminal (no snacks dep)
    split_side = 'right',
    split_width_percentage = 0.35,
  },
}
```

To customize:

- **Switch to snacks.nvim terminal** (richer UI): install `folke/snacks.nvim`, then change `provider = 'snacks'`. We currently skip snacks to avoid the dep.
- **Move the split to the left:** `split_side = 'left'`.
- **Wider/narrower split:** tune `split_width_percentage` (0.0–1.0).
- **Use a non-PATH binary:** add `terminal_cmd = '/full/path/to/claude'` at the top level of the setup table. Useful if you have multiple `claude` installs or are running a beta.
- **Disable auto-start:** add `auto_start = false` to setup. Default is to start the WebSocket server on Neovim launch (cheap — no binary spawned until you open the terminal).

See the [upstream README](https://github.com/coder/claudecode.nvim) for the full list of options (`port_range`, `log_level`, `diff_opts`, etc.).

---

## Air-gapped Notes

For deployment to an air-gapped machine, the bundle needs:

1. The **`claude` binary** — already in `dist/claude_*_linux_x86_64.tar.gz`. `scripts/bundle-airgap.sh` verifies the glob and `RESTORE.md` includes a step that extracts it to `/opt/claude/claude` and symlinks to `/usr/local/bin/claude`.
2. The **`claudecode.nvim` plugin** at `~/.local/share/nvim/site/pack/core/opt/claudecode.nvim/`.
3. `vim.g.airgapped = true` in `init.lua` — flipped automatically by the bundle script.

The bundle and RESTORE handle 1–3. The only thing the air-gap script *can't* do for you is the credential / network reachability piece (see "Auth" above) — those are environment-specific.

If you ever bump the claude version, drop the new tarball into `dist/` (replacing the old one) before running the bundle script. The version is encoded in the filename for traceability; the symlink at `/usr/local/bin/claude` stays the same.

To regenerate the tarball from a fresh npm install:

```bash
SRC=$(npm root -g)/@anthropic-ai/claude-code/bin/claude.exe
VERSION=$(claude --version | awk '{print $1}')
BUILD=$(mktemp -d)
cp "$SRC" "$BUILD/claude"
chmod +x "$BUILD/claude"
tar -czf "dist/claude_${VERSION}_linux_x86_64.tar.gz" -C "$BUILD" claude
rm -rf "$BUILD"
```

---

## Troubleshooting

**`claude: command not found`**
The binary isn't on `$PATH`. Run `which claude` — if empty, follow the install step in RESTORE.md (or re-run `npm install -g @anthropic-ai/claude-code` online).

**`E492: Not an editor command: ClaudeCode`**
The plugin isn't loaded. Check that the `require 'kickstart.plugins.claudecode'` line in `init.lua` is uncommented, restart Neovim, then `:lua print(vim.fn.exists(':ClaudeCode'))` should return `2`.

**Toggle key does nothing / silent fail**
The plugin spawns `claude` lazily — check `:messages` for errors. Try `:ClaudeCode` directly to see the underlying error.

**`<leader>cc` works but the response never returns / hangs**
The binary can't reach `api.anthropic.com`. On the air-gap VM, confirm your outbound proxy is configured (env vars `HTTPS_PROXY` / `ANTHROPIC_API_URL` if you use a relay).

**Claude prompts for login every time**
Credentials aren't persisted. Copy `~/.claude/.credentials.json` from a logged-in machine, or run `claude login` once if the VM can reach Anthropic.

**The terminal split is too narrow / on the wrong side**
Edit `terminal.split_side` and `terminal.split_width_percentage` in `lua/kickstart/plugins/claudecode.lua`.

---

## See Also

- `lua/kickstart/plugins/claudecode.lua` — plugin spec, setup, and keymaps
- Upstream: <https://github.com/coder/claudecode.nvim> and <https://github.com/anthropics/claude-code>
