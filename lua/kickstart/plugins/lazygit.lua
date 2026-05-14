-- LazyGit integration — opens the lazygit TUI in a floating window
-- https://github.com/kdheepak/lazygit.nvim
--
-- Requires the `lazygit` binary on $PATH (install separately, e.g. /usr/local/bin/lazygit).

pack_add {
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/kdheepak/lazygit.nvim',
}

-- Open in floating window inside Neovim instead of spawning a separate terminal.
vim.g.lazygit_floating_window_use_plenary = 1

vim.keymap.set('n', '<leader>gg', '<Cmd>LazyGit<CR>', { desc = '[G]it: open lazy[g]it' })
vim.keymap.set('n', '<leader>gf', '<Cmd>LazyGitCurrentFile<CR>', { desc = '[G]it: lazygit for current [f]ile repo' })
vim.keymap.set('n', '<leader>gl', '<Cmd>LazyGitFilterCurrentFile<CR>', { desc = '[G]it: lazygit [l]og for current file' })
