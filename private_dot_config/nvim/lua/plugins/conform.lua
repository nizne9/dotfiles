return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'ruff_organize_imports', 'ruff_fix', 'ruff_format' },
        rust = { 'rustfmt' },
        go = { 'gofmt', 'goimports' },
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'prettierd', 'prettier' },
        yaml = { 'prettierd', 'prettier' },
        bash = { 'shfmt' },
        sh = { 'shfmt' },
        zsh = { 'shfmt' },
        ['_'] = { 'trim_whitespace' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = 'fallback',
      },
    },
    keys = {
      {
        '<leader>fm',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        desc = 'Format buffer',
      },
    },
  },
}
