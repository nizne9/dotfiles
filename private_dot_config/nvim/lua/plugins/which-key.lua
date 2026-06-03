return {
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      spec = {
        { '<leader>f', group = 'find' },
        { '<leader>h', group = 'hunk' },
      },
    },
  },
}
