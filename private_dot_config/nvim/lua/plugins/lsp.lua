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

    end,
  },
}
