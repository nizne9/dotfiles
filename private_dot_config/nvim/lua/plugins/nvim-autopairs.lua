return {
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      require('nvim-autopairs').setup({
        check_ts = true,
        ts_config = {
          lua = { 'string', 'string_content', 'comment', 'comment_content' },
          python = { 'string', 'string_content', 'comment' },
          rust = {
            'string_content',
            'string_literal',
            'raw_string_literal',
            'line_comment',
            'block_comment',
          },
          bash = { 'string', 'string_content', 'comment' },
          javascript = { 'string', 'string_fragment', 'template_string', 'comment' },
        },
      })
    end,
  },
}
