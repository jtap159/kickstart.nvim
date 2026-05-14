---
name: neovim-bundle-airgap
description: Bundle the Neovim config, plugins, Mason tools, and treesitter parsers into a single transferable archive for deployment to an air-gapped Linux x86_64 VM. Reads version from CHANGELOG.md, stages all assets, flips vim.g.airgapped=true in the bundled copy, generates RESTORE.md, and tars everything to bundles/nvim-airgapped-bundle-<version>.tar.gz.
---

The bundling logic now lives in `scripts/bundle-airgap.sh`. Do not re-implement it here.

Run the script:

```bash
bash scripts/bundle-airgap.sh
```

It reads the version from `CHANGELOG.md`, stages assets in `/tmp/`, flips `vim.g.airgapped=true` in the bundled copy, generates `RESTORE.md` from `scripts/RESTORE.template.md`, and writes `bundles/nvim-airgapped-bundle-<version>.tar.gz`. The script reports bundle path, size, and plugin/parser/Mason counts on success.

If the script fails (missing `dist/` binaries, missing plugin/parser/Mason dirs, sed-flip didn't take), read the error message and help the user fix the underlying issue. Do not work around it by reproducing the bundling steps inline — fix the input and re-run the script.

To change what gets bundled or how, edit `scripts/bundle-airgap.sh` directly. To change the RESTORE.md instructions, edit `scripts/RESTORE.template.md` (uses `__VERSION__` as the version placeholder).
