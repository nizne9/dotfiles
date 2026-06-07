return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      indent = { enabled = true },
      picker = { enabled = true },
      explorer = { enabled = true },
    },
    keys = {
      { '<leader>ff', function() Snacks.picker.files() end, desc = 'Find files' },
      { '<leader>fg', function() Snacks.picker.grep() end, desc = 'Live grep' },
      { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
      { '<leader>fh', function() Snacks.picker.help() end, desc = 'Help tags' },
      { '<leader>fr', function() Snacks.picker.resume() end, desc = 'Resume last' },
      { '<leader>fd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
      { '<leader>fs', function() Snacks.picker.lsp_symbols() end, desc = 'Document symbols' },
      { '<leader>fS', function() Snacks.picker.lsp_workspace_symbols() end, desc = 'Workspace symbols' },
      { '<leader>e', function() Snacks.explorer() end, desc = 'File explorer' },
    },
  },
}
