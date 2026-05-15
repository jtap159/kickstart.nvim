-- Claude Code integration — runs the `claude` CLI in a Neovim-managed
-- terminal split, with selection-sending, diff review, and IDE-style
-- file context. https://github.com/coder/claudecode.nvim
--
-- The plugin makes no outbound network calls of its own — it spawns the
-- `claude` binary and talks to it over a local WebSocket (lockfile at
-- ~/.claude/ide/<port>.lock). Only the binary itself reaches the API.
-- Air-gap notes: the binary tarball ships in dist/claude_*_linux_x86_64.tar.gz
-- and RESTORE.md installs it to /usr/local/bin/claude. The binary works in
-- air-gap iff the VM can still reach api.anthropic.com (typically via an
-- internal proxy); otherwise the plugin loads cleanly but chats won't return.
--
-- `folke/snacks.nvim` is the plugin's recommended terminal provider but is
-- optional — we use `terminal.provider = 'native'` (Neovim's built-in :terminal)
-- to avoid pulling in a large dep we don't otherwise need.

pack_add { 'https://github.com/coder/claudecode.nvim' }

require('claudecode').setup {
  terminal = {
    provider = 'native',
    split_side = 'right',
    split_width_percentage = 0.35,
  },
}

-- Keymaps — repurposed under <leader>c since <leader>a is taken by harpoon.
local map = function(lhs, rhs, desc, mode) vim.keymap.set(mode or 'n', lhs, rhs, { desc = desc }) end

map('<leader>cc', '<cmd>ClaudeCode<cr>', '[C]laude: toggle session')
map('<leader>cf', '<cmd>ClaudeCodeFocus<cr>', '[C]laude: [f]ocus')
map('<leader>cr', '<cmd>ClaudeCode --resume<cr>', '[C]laude: [r]esume last session')
map('<leader>cC', '<cmd>ClaudeCode --continue<cr>', '[C]laude: [C]ontinue')
map('<leader>cm', '<cmd>ClaudeCodeSelectModel<cr>', '[C]laude: select [m]odel')
map('<leader>cb', '<cmd>ClaudeCodeAdd %<cr>', '[C]laude: add current [b]uffer')
map('<leader>cs', '<cmd>ClaudeCodeSend<cr>', '[C]laude: [s]end selection', 'v')
map('<leader>ca', '<cmd>ClaudeCodeDiffAccept<cr>', '[C]laude: [a]ccept diff')
map('<leader>cd', '<cmd>ClaudeCodeDiffDeny<cr>', '[C]laude: [d]eny diff')
