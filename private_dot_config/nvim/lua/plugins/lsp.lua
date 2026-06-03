-- Python coordination: pyright owns types/hover/definition, ruff owns lint+format.

local servers = {
  'lua_ls',
  'ts_ls',
  'pyright',
  'ruff',
  'rust_analyzer',
  'gopls',
  'clangd',
  'bashls',
  'jsonls',
  'yamlls',
  'tinymist',
}

local ruff_disable_caps = {
  'hoverProvider',
  'definitionProvider',
  'typeDefinitionProvider',
  'referencesProvider',
  'implementationProvider',
}

return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    config = function()
      require('mason').setup()
    end,
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = {
      ensure_installed = servers,
      automatic_enable = true,
    },
    config = function(_, opts)
      require('mason-lspconfig').setup(opts)
      -- Force ensure_installed after setup. mason-lspconfig's
      -- registry.refresh callback may not fire reliably in all
      -- startup paths; explicit call bypasses that race.
      vim.defer_fn(function()
        require('mason-lspconfig.features.ensure_installed')()
      end, 1000)
    end,
  },

  {
    'neovim/nvim-lspconfig',
    event = 'BufReadPre',
    config = function()
      vim.lsp.config('pyright', {
        settings = {
          pyright = {
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'openFilesOnly',
            },
          },
        },
      })

      vim.lsp.config('ruff', {
        init_options = {
          settings = {
            lineLength = 100,
            fixAll = true,
            organizeImports = true,
            lint = { enable = true, preview = false },
            format = { preview = false },
            codeAction = {
              disableRuleComment = { enable = true },
              fixViolation = { enable = true },
            },
          },
        },
        on_attach = function(client)
          for _, cap in ipairs(ruff_disable_caps) do
            client.server_capabilities[cap] = false
          end
        end,
      })

      -- 0.11+ provides: grn/grr/gra/gri/gO/gd/gD/K/[d/]d
      vim.lsp.config('*', {
        on_attach = function(_, bufnr)
          vim.keymap.set('n', '<leader>fm', function()
            vim.lsp.buf.format({ async = true })
          end, {
            buffer = bufnr,
            silent = true,
            desc = 'LSP format',
          })
        end,
      })

      local py_format_group = vim.api.nvim_create_augroup('format_on_save_python', { clear = true })

      vim.api.nvim_create_autocmd('BufWritePre', {
        group = py_format_group,
        pattern = '*.py',
        callback = function(args)
          if #vim.lsp.get_clients({ bufnr = args.buf, name = 'ruff' }) == 0 then return end
          vim.lsp.buf.code_action({
            context = { only = { 'source.fixAll.ruff', 'source.organizeImports.ruff' } },
            apply = true,
          })
        end,
        desc = 'Format Python with ruff on save',
      })
    end,
  },
}
