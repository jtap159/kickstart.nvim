# Changelog

## v1.2.1 — 2026-05-15

- Fixed missing treesitter syntax highlighting (e.g. YAML) on air-gapped restores
  - `nvim-treesitter` (main branch) keeps per-language `highlights.scm`/`indents.scm`/etc. in `~/.local/share/nvim/site/queries/<lang>/`, separate from the parser `.so` files. The bundle was copying parsers but not queries, so `vim.treesitter.query.get()` returned nil on the target and nothing got colored.
  - `scripts/bundle-airgap.sh`: stages `~/.local/share/nvim/site/queries/` into the tarball and reports a per-language query count
  - `scripts/RESTORE.template.md`: adds a copy step for `data/site/queries/` into `~/.local/share/nvim/site/queries/`

## v1.2.0 — 2026-05-14

- Added Helm support
  - Filetype detection: `**/templates/*.{yaml,yml,tpl}` and `helmfile*.yaml` now resolve to the `helm` filetype (init.lua Section 1)
  - LSP: `helm_ls` added to the Mason-managed servers — provides `.Values.*` go-to-definition, `include`/`define` jumps, completion, and hover
  - `yamlls` scoped to `{ yaml, yaml.docker-compose, yaml.gitlab }` so it no longer double-attaches to helm buffers
  - Treesitter parsers: added `helm`, `gotmpl`, and `yaml` to the pre-install list so they bundle for air-gap
  - Air-gap note in `CLAUDE.md`: `helm-ls` must be installed via Mason on the online box before bundling
- Markdown linting is now OFF by default
  - `lua/kickstart/plugins/lint.lua` starts with an empty `linters_by_ft` to silence baseline noise
  - `<leader>tl` toggles markdown linting on/off as before; the "on" branch now runs `lint.try_lint()` immediately so diagnostics appear without saving first
- Fixed nvim exiting when closing the last file buffer with neo-tree open
  - `close_if_last_window` flipped to `false` in `lua/kickstart/plugins/neo-tree.lua` — neo-tree now stays open instead of closing itself and dragging nvim down with it

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
