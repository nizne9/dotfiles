return {
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup({
        check_ts = true,
        ts_config = {
          lua = { 'string', 'comment' },
          python = { 'string', 'comment' },
          rust = { 'string', 'comment' },
          typst = { 'string', 'comment' },
        },
      })
    end,
  },
}
