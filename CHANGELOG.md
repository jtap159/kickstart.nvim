# Changelog

## v1.4.0 — 2026-05-15

- Added `claudecode.nvim` as an opt-in kickstart plugin (`lua/kickstart/plugins/claudecode.lua`)
  - Runs the `claude` CLI inside a Neovim `:terminal` split — no separate tmux pane needed
  - Keymaps relocated from the plugin's default `<leader>a` (taken by harpoon) to `<leader>c`: `cc` toggle, `cf` focus, `cr` resume, `cC` continue, `cm` select-model, `cb` add-current-buffer, `cs` send-visual-selection, `ca` accept-diff, `cd` deny-diff
  - which-key group `<leader>c` = `[C]laude Code` registered in `init.lua` Section 3
  - `terminal.provider = 'native'` (Neovim's built-in terminal) — skips the recommended `folke/snacks.nvim` dep to keep the plugin tree small
  - The plugin itself makes no outbound network calls; it spawns `claude` and talks to it over `~/.claude/ide/<port>.lock` + WebSocket
- Added `dist/claude_2.1.142_linux_x86_64.tar.gz` for air-gapped deployment (69 MB compressed, self-contained ELF — no Node runtime required at runtime)
- Updated `scripts/bundle-airgap.sh`: verifies `dist/claude_*_linux_x86_64.tar.gz` exists before bundling
- Updated `scripts/RESTORE.template.md`: added "Step 5 — Install Claude Code CLI" (extract to `/opt/claude/`, symlink `/usr/local/bin/claude`), renumbered subsequent steps (6 = copy config, 7 = copy plugins/parsers/Mason, 8 = verify); includes an auth/network-reachability note since the binary still needs a route to `api.anthropic.com` + credentials
- Added `doc/claudecode.md` — full usage guide (commands, keymaps, workflows, configuration, air-gap notes, troubleshooting)
- Updated `CLAUDE.md`: companion-docs entry, plugin-stack row, file-tree diagram, keybindings reference, and an air-gap notes paragraph for claudecode

## v1.3.1 — 2026-05-15

- Fixed `helm-ls`'s embedded yaml-language-server failing to load the Kubernetes JSON schema in air-gap
  - helm-ls spawns its own `yaml-language-server` for non-templated YAML chunks inside helm files. Its default config is `schemas = { kubernetes = "templates/**" }` — the magic string `kubernetes` makes the *embedded* yamlls fetch the schema directly from `raw.githubusercontent.com/yannh/...`, which is separate from SchemaStore. The v1.3.0 fix only covered the standalone `yamlls`, so opening any file under a `templates/` directory in air-gap still surfaced an "unable to load schema" notification.
  - `init.lua` helm_ls config (~line 845): in air-gap, override `helm-ls.yamlls.config.schemaStore.enable = false` and map a narrow set of k8s-shaped filename patterns (`templates/**/*-deployment.y*ml`, `*-service.y*ml`, `*-configmap.y*ml`, `*-pod.y*ml`, `*-statefulset.y*ml`, `*-daemonset.y*ml`, `*-ingress.y*ml`) to the locally-bundled schema. Non-resource files like `helm-values.yaml` (Loki/values blobs that happen to live under `templates/`) get no schema → no fetch error AND no false-positive validation diagnostics. Online: no override, helm-ls uses its default and fetches over the network as normal.
  - `CLAUDE.md`: added a "Helm + embedded yamlls (helm-ls)" section explaining the separate-process distinction so future debugging doesn't confuse standalone-yamlls config with embedded-yamlls config.

## v1.3.0 — 2026-05-15

- Fixed `yamlls` failing to load Kubernetes JSON schema in air-gap
  - yamlls's built-in SchemaStore catalog points Kubernetes YAML files at `https://raw.githubusercontent.com/yannh/kubernetes-json-schema/.../v1.32.1-standalone-strict/all.json`, which 404s on an offline VM. The schema is now shipped in the bundle and yamlls is wired to load it from disk.
  - `dist/k8s-schemas/v1.32.1-strict/{all.json,_definitions.json}` — checked into the repo as the air-gap source-of-truth
  - `scripts/bundle-airgap.sh`: stages `dist/k8s-schemas/` to `data/site/k8s-schemas/`, lands on the VM at `~/.local/share/nvim/site/k8s-schemas/`
  - `init.lua` yamlls config: when `vim.g.airgapped=true`, disables `yaml.schemaStore` and maps common Kubernetes/Helm-values filename patterns (`values.yaml`, `*values.yaml`, `*-deployment.yaml`, etc.) to the local schema via `yaml.schemas`. When online, the local `yaml.schemas` mapping is skipped entirely so yamlls falls back to the normal SchemaStore catalog (which fetches over the network).
  - Extend the pattern list in `init.lua:800` to cover more filename conventions
- Fixed treesitter query symlinks pointing at host-specific absolute paths in the air-gap bundle
  - `scripts/bundle-airgap.sh`: `cp -rL` dereferences the per-language symlinks so the tarball contains real `.scm` files instead of `/home/jeremy/...` symlinks that only resolved on Jeremy's box

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
