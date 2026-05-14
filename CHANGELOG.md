# Changelog

## v1.1.0 — 2026-05-14

- Added `lazygit.nvim` as an opt-in kickstart plugin (`lua/kickstart/plugins/lazygit.lua`)
  - Keymaps: `<leader>gg` (open), `<leader>gf` (current file's repo), `<leader>gl` (file log filter)
  - Floating window via plenary
- Added `dist/lazygit_0.61.0_linux_x86_64.tar.gz` for air-gapped deployment
- Updated `neovim-bundle-airgap` skill:
  - Verifies all three offline binaries in `dist/` (nvim, tree-sitter, lazygit) before bundling
  - Generated `RESTORE.md` now includes a "Step 4 — Install lazygit" section that extracts to `/opt/lazygit/` and symlinks `/usr/local/bin/lazygit`
- Added `doc/lazygit.md` — full usage guide (commands, keymaps, hunk staging, rebase, conflicts, troubleshooting)
- Added Companion Docs section to `CLAUDE.md` pointing to `doc/lazygit.md`

## v1.0.0 — 2026-05-14

- Initial kickstart.nvim config based on nvim-lua/kickstart.nvim
- Plugin manager: vim.pack (built-in Neovim)
- LSP: lua_ls, yamlls, jsonls via Mason; formatters stylua, prettier, markdownlint-cli2
- Fuzzy finder: telescope.nvim + fzf-native + ui-select
- Completion: blink.cmp with LuaSnip
- Treesitter: bash, c, diff, html, lua, luadoc, markdown, markdown_inline, query, vim, vimdoc
- Opt-in extras: gitsigns keymaps, indent-blankline, nvim-lint, nvim-autopairs, neo-tree
- Custom plugins: render-markdown.nvim, harpoon2
- Added airgapped mode: vim.g.airgapped toggle + pack_add wrapper for offline deployment
- Added dist/: nvim-linux-x86_64.tar.gz and tree-sitter-cli-linux-x86.zip for VM deployment
