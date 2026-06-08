-- Python coordination: pyright owns types/hover/definition, ruff owns lint+format.

local servers = {
  'lua_ls',
  'pyright',
  'ruff',
  'bashls',
  'jsonls',
  'yamlls',
  'tinymist',
}

local tools = {
  'stylua',
  'goimports',
  'prettier',
  'prettierd',
  'shfmt',
}

local lsp_install_command = 'LspInstall ' .. table.concat(servers, ' ')

local ruff_disable_caps = {
  'hoverProvider',
  'definitionProvider',
  'typeDefinitionProvider',
  'referencesProvider',
  'implementationProvider',
}

return {
  {
    'mason-org/mason.nvim',
    lazy = false,
    keys = {
      {
        '<leader>mi',
        '<cmd>MasonInstallConfigured<cr>',
        desc = 'Install configured Mason tools',
      },
    },
    config = function()
      require('mason').setup()
      vim.api.nvim_create_user_command('MasonInstallConfigured', function()
        vim.cmd('MasonToolsInstall')
        vim.cmd(lsp_install_command)
      end, {
        desc = 'Install configured Mason tools and LSP servers',
      })
    end,
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'mason-org/mason.nvim',
    },
    opts = {
      ensure_installed = tools,
      auto_update = false,
      run_on_start = false,
    },
  },

  {
    'neovim/nvim-lspconfig',
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

  {
    'mason-org/mason-lspconfig.nvim',
    dependencies = {
      'mason-org/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    opts = {
      ensure_installed = {},
      automatic_enable = servers,
    },
  },
}
