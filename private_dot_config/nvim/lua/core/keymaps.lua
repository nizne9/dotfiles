-- Built-in LSP keymaps (grn/grr/gra/gri/gO/gd/gD/K/[d/]d) are enabled by default in 0.11+.

local map = function(mode, lhs, rhs)
  vim.keymap.set(mode, lhs, rhs, { silent = true })
end

map('n', '<leader>w', '<cmd>w<CR>')
map('n', '<leader>q', '<cmd>q<CR>')
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

map('v', '<', '<gv')
map('v', '>', '>gv')
