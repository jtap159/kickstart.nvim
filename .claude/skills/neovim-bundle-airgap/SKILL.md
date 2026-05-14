---
name: neovim-bundle-airgap
description: Bundle the Neovim config, plugins, Mason tools, and treesitter parsers into a single transferable archive for deployment to an air-gapped Linux x86_64 VM. Reads version from CHANGELOG.md, stages all assets, flips vim.g.airgapped=true in the bundled copy, generates RESTORE.md, and tars everything to bundles/nvim-airgapped-bundle-<version>.tar.gz.
---

You are creating an air-gapped deployment bundle for this Neovim config. Follow these steps exactly using Bash commands. Work from the config root: ~/.config/nvim/

## Step 1 — Read the version from CHANGELOG.md

Read CHANGELOG.md and extract the version from the first line matching `## v<version>`.
The bundle will be named `nvim-airgapped-bundle-<version>.tar.gz`.

Tell the user: "Bundling version <version>..."

## Step 2 — Check for existing bundle

Check if `bundles/nvim-airgapped-bundle-<version>.tar.gz` already exists.
If it does, warn the user: "Warning: bundle for <version> already exists — overwriting."
Create the bundles/ directory if it doesn't exist.

## Step 3 — Create a staging directory

Create a temp staging dir: `/tmp/nvim-airgapped-bundle-<version>/`

Inside it, create this structure:
```
nvim-airgapped-bundle-<version>/
  config/
  data/
    site/
      pack/
        core/
          opt/
      parser/
    mason/
```

Use: `mkdir -p /tmp/nvim-airgapped-bundle-<version>/{config,data/site/pack/core,data/site/parser,data/mason}`

## Step 4 — Copy the Neovim config

Copy the entire ~/.config/nvim/ directory into staging/config/nvim/:
```bash
cp -r ~/.config/nvim/ /tmp/nvim-airgapped-bundle-<version>/config/nvim/
```

Remove the bundles/ directory from the copy (it's gitignored and potentially huge):
```bash
rm -rf /tmp/nvim-airgapped-bundle-<version>/config/nvim/bundles/
```

## Step 5 — Flip airgapped=true in the bundled copy

Edit `/tmp/nvim-airgapped-bundle-<version>/config/nvim/init.lua` — find the line:
  `vim.g.airgapped = false`
and replace it with:
  `vim.g.airgapped = true`

Use sed to do this precisely:
```bash
sed -i 's/vim\.g\.airgapped = false/vim.g.airgapped = true/' /tmp/nvim-airgapped-bundle-<version>/config/nvim/init.lua
```

Verify the change took effect:
```bash
grep "vim.g.airgapped" /tmp/nvim-airgapped-bundle-<version>/config/nvim/init.lua
```

## Step 6 — Copy plugins

```bash
cp -r ~/.local/share/nvim/site/pack/core/opt/ /tmp/nvim-airgapped-bundle-<version>/data/site/pack/core/
```

## Step 7 — Copy treesitter parsers

```bash
cp ~/.local/share/nvim/site/parser/*.so /tmp/nvim-airgapped-bundle-<version>/data/site/parser/
```

## Step 8 — Copy Mason tools

```bash
cp -r ~/.local/share/nvim/mason/ /tmp/nvim-airgapped-bundle-<version>/data/mason/
```

Exclude the staging dir (temp files from previous installs):
```bash
rm -rf /tmp/nvim-airgapped-bundle-<version>/data/mason/staging/
```

## Step 9 — Generate RESTORE.md

Write the following file to `/tmp/nvim-airgapped-bundle-<version>/RESTORE.md`.
Replace `<version>` with the actual version string throughout.

The RESTORE.md content to write:

---
# Neovim Air-gapped Bundle — <version>

This archive contains a complete, self-contained Neovim setup for offline Linux x86_64 systems.
Everything needed to run Neovim with full LSP, treesitter, and plugin support is included.

## Contents

```
config/nvim/          ← Neovim config (airgapped mode enabled)
data/
  site/pack/core/opt/ ← All plugins (pre-compiled .so files included)
  site/parser/        ← Treesitter parser .so files
  mason/              ← LSP servers and tools (lua-language-server, stylua, prettier, etc.)
config/nvim/dist/
  nvim-linux-x86_64.tar.gz        ← Neovim binary (extract if not already installed)
  tree-sitter-cli-linux-x86.zip   ← tree-sitter CLI (optional, for manual parser work)
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

## Step 4 — Copy the Neovim config

```bash
mkdir -p ~/.config
cp -r config/nvim/ ~/.config/nvim/
```

The config already has `vim.g.airgapped = true` set — no edits needed.

## Step 5 — Copy plugins, parsers, and Mason tools

```bash
mkdir -p ~/.local/share/nvim/site/pack/core/
cp -r data/site/pack/core/opt/ ~/.local/share/nvim/site/pack/core/

mkdir -p ~/.local/share/nvim/site/parser/
cp data/site/parser/*.so ~/.local/share/nvim/site/parser/

mkdir -p ~/.local/share/nvim/
cp -r data/mason/ ~/.local/share/nvim/mason/
```

## Step 6 — Verify the installation

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
---

## Step 10 — Create the tarball

```bash
cd /tmp
tar -czf ~/.config/nvim/bundles/nvim-airgapped-bundle-<version>.tar.gz nvim-airgapped-bundle-<version>/
```

## Step 11 — Clean up staging dir

```bash
rm -rf /tmp/nvim-airgapped-bundle-<version>/
```

## Step 12 — Report results

Run:
```bash
ls -lh ~/.config/nvim/bundles/nvim-airgapped-bundle-<version>.tar.gz
```

Tell the user:
- Bundle path
- File size
- What's inside (version, plugin count, parser count, Mason tool count)
- Reminder: "Transfer this file to the VM and follow RESTORE.md inside the archive."

To inspect the archive contents without extracting:
```bash
tar -tzf ~/.config/nvim/bundles/nvim-airgapped-bundle-<version>.tar.gz | head -30
```
