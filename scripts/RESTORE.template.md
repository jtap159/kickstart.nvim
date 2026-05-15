# Neovim Air-gapped Bundle — __VERSION__

This archive contains a complete, self-contained Neovim setup for offline Linux x86_64 systems.
Everything needed to run Neovim with full LSP, treesitter, and plugin support is included.

## Contents

```
config/nvim/          ← Neovim config (airgapped mode enabled)
data/
  site/pack/core/opt/ ← All plugins (pre-compiled .so files included)
  site/parser/        ← Treesitter parser .so files
  site/queries/       ← Treesitter highlight/indent/fold queries (per language)
  site/k8s-schemas/   ← Kubernetes JSON schemas (yamlls reads from here)
  mason/              ← LSP servers and tools (lua-language-server, stylua, prettier, etc.)
config/nvim/dist/
  nvim-linux-x86_64.tar.gz          ← Neovim binary (extract if not already installed)
  tree-sitter-cli-linux-x86.zip     ← tree-sitter CLI (optional, for manual parser work)
  lazygit_*_linux_x86_64.tar.gz     ← lazygit TUI (required for the lazygit.nvim plugin)
```

## Step 1 — Install system dependencies

These packages are required for Neovim to function correctly. Install them with apt
(requires access to apt mirrors — an internal corporate mirror is fine):

```bash
sudo apt update
sudo apt install -y ripgrep fd-find unzip xclip
```

- `ripgrep` — required for Telescope live grep (`<leader>sg`)
- `fd-find` — required for Telescope find files (`<leader>sf`)
- `unzip` — required to extract the tree-sitter CLI (Step 3)
- `xclip` — required for system clipboard sync (yanking to/from the OS clipboard)

> **Note:** `fd-find` installs as `fdfind` on Debian/Ubuntu. Telescope expects `fd`. Create an alias:
> ```bash
> mkdir -p ~/bin && ln -s $(which fdfind) ~/bin/fd
> echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
> ```

## Step 2 — Install Neovim (skip if already installed)

Check if Neovim is installed and what version:
```bash
nvim --version 2>/dev/null | head -1
```

If Neovim is not installed or is older than 0.10, install from the bundled tarball:
```bash
sudo mkdir -p /opt/nvim-linux-x86_64
sudo tar -xzf config/nvim/dist/nvim-linux-x86_64.tar.gz -C /opt --strip-components=1
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

Verify:
```bash
nvim --version | head -1
```

## Step 3 — Install tree-sitter CLI (optional)

The tree-sitter CLI is not required for normal Neovim usage in air-gapped mode.
Install it if you may need to manually compile new parsers offline:
```bash
mkdir -p ~/bin
unzip -j config/nvim/dist/tree-sitter-cli-linux-x86.zip tree-sitter -d ~/bin/
chmod +x ~/bin/tree-sitter
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Verify:
```bash
tree-sitter --version
```

## Step 4 — Install lazygit

Required for the `lazygit.nvim` plugin (`<leader>gg`). Skip only if you have
already disabled that plugin in `init.lua`.

```bash
sudo mkdir -p /opt/lazygit
sudo tar -xzf config/nvim/dist/lazygit_*_linux_x86_64.tar.gz -C /opt/lazygit lazygit
sudo ln -sf /opt/lazygit/lazygit /usr/local/bin/lazygit
```

Verify:
```bash
lazygit --version
```

## Step 5 — Copy the Neovim config

```bash
mkdir -p ~/.config
cp -r config/nvim/ ~/.config/nvim/
```

The config already has `vim.g.airgapped = true` set — no edits needed.

## Step 6 — Copy plugins, parsers, and Mason tools

```bash
mkdir -p ~/.local/share/nvim/site/pack/core/
cp -r data/site/pack/core/opt/ ~/.local/share/nvim/site/pack/core/

mkdir -p ~/.local/share/nvim/site/parser/
cp data/site/parser/*.so ~/.local/share/nvim/site/parser/

mkdir -p ~/.local/share/nvim/site/queries/
cp -r data/site/queries/. ~/.local/share/nvim/site/queries/

mkdir -p ~/.local/share/nvim/site/k8s-schemas/
cp -r data/site/k8s-schemas/. ~/.local/share/nvim/site/k8s-schemas/

mkdir -p ~/.local/share/nvim/
cp -r data/mason/ ~/.local/share/nvim/mason/
```

## Step 7 — Verify the installation

Launch Neovim and run the health check:
```
:checkhealth
```

Expected: no errors related to plugins or treesitter. LSP servers should attach when you open
a supported file type (Lua, YAML, JSON, Markdown).

If any plugin shows as missing in the health check, check that its directory exists under
`~/.local/share/nvim/site/pack/core/opt/<plugin-name>/`.

## Notes

- `vim.g.airgapped = true` is set — Mason will not attempt to download tools at startup.
- Treesitter parsers are pre-compiled `.so` files; no compilation happens at runtime.
- All plugin `.so` files (telescope-fzf-native, LuaSnip jsregexp) are pre-built and included.
- To add a new parser or plugin later, do it on an internet-connected machine and re-bundle.
