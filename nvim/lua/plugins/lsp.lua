return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      local servers = {
        'ts_ls',
        'eslint',
        'vtsls',
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
        ts_ls = function()
          local mason_registry = require('mason-registry')
          if not mason_registry.is_installed("vue-language-server") then
            return {
              filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "json" },
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
            filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
          }
        end,
      }

      -- hover 창
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
        vim.lsp.handlers.hover, {
          border = "rounded",
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
          config = vim.tbl_deep_extend("force", config, custom_config)
        end
        lspconfig[server].setup(config)
      end
    end
  },
}
