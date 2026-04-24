return {
  {
    'neovim/nvim-lspconfig',
    version = '^1.0.0',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/nvim-cmp',
      { "mason-org/mason.nvim", version = "^1.0.0" },
      { "mason-org/mason-lspconfig.nvim", version = "^1.0.0" },
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
        'lemminx',
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

      -- hover 모달 설정 (테두리 + 코드블록 제거)
      local original_floating_preview = vim.lsp.util.open_floating_preview
      vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
        -- 코드블록 제거
        if #contents >= 2 and vim.startswith(contents[1], '```') and contents[#contents] == '```' then
          local lang = vim.trim(string.sub(contents[1], 4))
          if lang ~= '' then
            syntax = lang
          end
          local new_contents = {}
          for i = 2, #contents - 1 do
            table.insert(new_contents, contents[i])
          end
          contents = new_contents
        end
        -- 테두리 설정
        opts = opts or {}
        opts.border = 'rounded'
        return original_floating_preview(contents, syntax, opts)
      end

      local custom_server_configs = {

        eslint = function()
          return {
            cmd = { "vscode-eslint-language-server", "--stdio" },
            filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
            root_dir = function(fname)
              local util = require('lspconfig').util
              local config_path = util.root_pattern(
                'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.mjs', '.eslintrc.json', '.eslintrc', '.eslintrc.yml', '.eslintrc.yaml',
                'packages/*/eslint.config.js', 'packages/*/eslint.config.mjs', 'packages/*/eslint.config.cjs', 'packages/*/.eslintrc.js', 'packages/*/.eslintrc.cjs', 'packages/*/.eslintrc.mjs', 'packages/*/.eslintrc.json', 'packages/*/.eslintrc', 'packages/*/.eslintrc.yml', 'packages/*/.eslintrc.yaml',
                'apps/*/eslint.config.js', 'apps/*/eslint.config.mjs', 'apps/*/eslint.config.cjs', 'apps/*/.eslintrc.js', 'apps/*/.eslintrc.cjs', 'apps/*/.eslintrc.mjs', 'apps/*/.eslintrc.json', 'apps/*/.eslintrc', 'apps/*/.eslintrc.yml', 'apps/*/.eslintrc.yaml'
              )(fname)
              -- ESLint 설정 파일이 있는 경우에만 활성화
              return config_path
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
                codeAction = false,
                diagnostics = true,
                semanticTokens = true,
              }
            },
            on_attach = function(client)
              client.server_capabilities.hoverProvider = false
              -- volar 포매팅 비활성화
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
              -- volar code action 비활성화
              client.server_capabilities.codeActionProvider = false
            end
          }
        end,

        ts_ls = function()
          local mason_registry = require('mason-registry')

          -- ts-lit-plugin 경로 탐색 (npm i -g ts-lit-plugin 필요)
          local lit_plugin = nil
          local npm_root = vim.fn.trim(vim.fn.system('npm root -g'))
          if vim.v.shell_error == 0 and vim.fn.isdirectory(npm_root .. '/ts-lit-plugin') == 1 then
            lit_plugin = { name = 'ts-lit-plugin', location = npm_root .. '/ts-lit-plugin' }
          end

          if not mason_registry.is_installed('vue-language-server') then
            return {
              init_options = lit_plugin and { plugins = { lit_plugin } } or nil,
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

          local plugins = {
            {
              name = '@vue/typescript-plugin',
              location = mason_registry.get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server',
              languages = { 'vue' },
            },
          }
          if lit_plugin then
            table.insert(plugins, lit_plugin)
          end

          return {
            init_options = {
              plugins = plugins,
            },
            filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' },
            on_attach = function(client)
              -- tsserver 포매팅 비활성화
              client.server_capabilities.documentFormattingProvider = false
              client.server_capabilities.documentRangeFormattingProvider = false
            end
          }
        end,
      }

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
