local languages = {
  'bash',
  'c',
  'diff',
  'go',
  'html',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'python',
  'query',
  'rust',
  'toml',
  'typescript',
  'vim',
  'vimdoc',
  'xml',
  'yaml',
  'zsh',
}

return {
  {
    'neovim-treesitter/nvim-treesitter',
    branch = 'main',
    dependencies = {
      'neovim-treesitter/treesitter-parser-registry',
    },
    build = ':TSUpdate',
    lazy = false,
    config = function()
      local treesitter = require('nvim-treesitter')

      treesitter.setup({
        install_dir = vim.fn.stdpath('data') .. '/site',
      })

      vim.api.nvim_create_user_command('TSInstallConfigured', function()
        vim.cmd('TSInstall ' .. table.concat(languages, ' '))
      end, {
        desc = 'Install configured Treesitter parsers and queries',
      })
    end,
    keys = {
      {
        '<leader>ti',
        '<cmd>TSInstallConfigured<cr>',
        desc = 'Install Treesitter parsers',
      },
    },
  },
}
