return {
  {
    'neovim/nvim-lspconfig',
    event = { "BufReadPre", "BufNewFile" },
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

      -- hover 핸들러를 재정의하여 테두리, 자동 포커스, 중복 응답 문제를 모두 해결
      local original_hover_handler = vim.lsp.handlers["textDocument/hover"]
      local hover_processed = false
      local hover_timer = nil

      vim.lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
        -- 이미 처리된 hover가 있으면 무시
        if hover_processed then
          return
        end

        -- 기존 타이머 취소
        if hover_timer then
          vim.fn.timer_stop(hover_timer)
        end

        -- 유효한 결과가 있는 첫 번째 응답만 처리
        if result and result.contents then
          hover_processed = true

          -- 테두리 설정
          config = vim.tbl_deep_extend("force", { border = "rounded" }, config or {})

          -- 원래 핸들러 호출
          original_hover_handler(err, result, ctx, config)

          -- 정보 창이 표시된 후 포커스를 맞추는 함수
          vim.schedule(function()
            vim.defer_fn(function()
              local wins = vim.api.nvim_list_wins()
              for _, win in ipairs(wins) do
                local win_config = vim.api.nvim_win_get_config(win)
                -- floating window라면 포커스 이동 (조건 단순화)
                if win_config.relative ~= "" then
                  vim.api.nvim_set_current_win(win)
                  break
                end
              end
            end, 10) -- 10ms 지연으로 창이 완전히 생성된 후 포커스
          end)

          -- 500ms 후 플래그 리셋
          hover_timer = vim.fn.timer_start(500, function()
            hover_processed = false
          end)
        end
      end

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
              -- volar가 활성화된 버퍼에서는 ts_ls의 hover 기능을 비활성화
              local volar_clients = vim.lsp.get_clients({ name = 'volar', bufnr = bufnr })
              if #volar_clients > 0 then
                client.server_capabilities.hoverProvider = false
              end

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
