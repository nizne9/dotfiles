return {
  {
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable('make') == 1
        end,
      },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({})

      telescope.load_extension('fzf')

      local builtin = require('telescope.builtin')

      local map = function(lhs, rhs, desc)
        vim.keymap.set('n', lhs, rhs, { silent = true, desc = 'Telescope ' .. desc })
      end

      map('<leader>ff', builtin.find_files, 'find files')
      map('<leader>fg', builtin.live_grep, 'live grep')
      map('<leader>fb', builtin.buffers, 'buffers')
      map('<leader>fh', builtin.help_tags, 'help tags')
      map('<leader>fr', builtin.resume, 'resume last')
      map('<leader>fd', builtin.diagnostics, 'diagnostics')
      map('<leader>fs', builtin.lsp_document_symbols, 'document symbols')
      map('<leader>fS', builtin.lsp_workspace_symbols, 'workspace symbols')
    end,
  },
}
