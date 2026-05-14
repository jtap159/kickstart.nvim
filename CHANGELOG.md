# Changelog

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
