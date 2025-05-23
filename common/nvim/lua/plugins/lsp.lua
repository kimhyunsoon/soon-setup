return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      'hrsh7th/nvim-cmp',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
    },
    config = function()
      require('mason').setup()
      local servers = {
        'ts_ls',
        'eslint',
        'volar',
        'lua_ls',
        'docker_compose_language_service',
        'dockerls',
        'powershell_es',
        'sqlls',
        'bashls',
        'svelte',
        'html',
        'css_variables',
        'cssls',
        'cssmodules_ls',
        'pyright',
        'kotlin_language_server',
        'jsonls',
        'jdtls',
        'golangci_lint_ls',
        'gopls',
        'clangd',
        'tailwindcss',
      }

      require('mason-lspconfig').setup({
        ensure_installed = servers,
        automatic_installation = true,
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      capabilities.textDocument.documentSymbol = {
        dynamicRegistration = false,
        symbolKind = {
          valueSet = vim.tbl_values(vim.lsp.protocol.SymbolKind),
        },
        hierarchicalDocumentSymbolSupport = true,
      }

      local lspconfig = require('lspconfig')

      local custom_server_configs = {

        eslint = function()
          return {
            cmd = { "vscode-eslint-language-server", "--stdio" },
            filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
            root_dir = function(fname)
              local util = require('lspconfig').util
              local project_root = util.find_git_ancestor(fname) or vim.fn.getcwd()
              local config_path = util.root_pattern(
                'eslint.config.js', '.eslintrc.js', '.eslintrc.json', '.eslintrc', '.eslintrc.yml',
                'packages/*/eslint.config.js', 'packages/*/.eslintrc.js', 'packages/*/.eslintrc.json', 'packages/*/.eslintrc', 'packages/*/.eslintrc.yml',
                'apps/*/eslint.config.js', 'apps/*/.eslintrc.js', 'apps/*/.eslintrc.json', 'apps/*/.eslintrc', 'apps/*/.eslintrc.yml'
              )(fname)
              return config_path or project_root
            end,
            settings = {
              workingDirectory = { mode = "auto" },
              nodePath = "",
              format = { enable = false }, -- eslint 포매팅 비활성화
              validate = "on",
              codeAction = {
                disableRuleComment = {
                  enable = true,
                  location = "separateLine"
                },
                showDocumentation = {
                  enable = true
                }
              },
              useWorkspaceDependencies = true,
              experimental = {
                useFlatConfig = true
              },
              packageManager = "pnpm",
              rulesCustomizations = {},
              run = "onType"
            }
          }
        end,

        volar = function()
          return {
            filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
            init_options = {
              typescript = {
                tsdk = vim.fn.getcwd() .. '/node_modules/typescript/lib'
              },
              languageFeatures = {
                implementation = true,
                references = true,
                definition = true,
                typeDefinition = true,
                callHierarchy = true,
                hover = true,
                rename = true,
                renameFileRefactoring = true,
                signatureHelp = true,
                codeAction = true,
                diagnostics = true,
                semanticTokens = true,
              }
            },
            on_attach = function(client)
              -- volar 포매팅 비활성화
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end
          }
        end,

        ts_ls = function()
          local mason_registry = require('mason-registry')
          if not mason_registry.is_installed('vue-language-server') then
            return {
              filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'json' },
              on_attach = function(client)
                -- tsserver 포매팅 비활성화
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
              end,
              settings = {
                typescript = {
                  inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                  }
                },
                javascript = {
                  inlayHints = {
                    includeInlayParameterNameHints = 'all',
                    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                  }
                }
              }
            }
          end

          return {
            init_options = {
              plugins = {
                {
                  name = '@vue/typescript-plugin',
                  location = mason_registry.get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server',
                  languages = { 'vue' },
                },
              },
            },
            filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
            on_attach = function(client, bufnr)
              -- tsserver 포매팅 비활성화
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end
          }
        end,
      }

      -- hover 창
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = 'rounded',
          focusable = false,
        }
      )

      for _, server in ipairs(servers) do
        local config = {
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 150,
          }
        }
        if custom_server_configs[server] then
          local custom_config = custom_server_configs[server]()
          config = vim.tbl_deep_extend('force', config, custom_config)
        end
        lspconfig[server].setup(config)
      end
    end
  },
}
