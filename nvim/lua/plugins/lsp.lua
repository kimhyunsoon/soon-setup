return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/nvim-cmp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
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
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- documentSymbol 기능 명시적 활성화
      capabilities.textDocument.documentSymbol = {
        dynamicRegistration = false,
        symbolKind = {
          valueSet = (function()
            local result = {}
            for i = 1, 26 do
              table.insert(result, i)
            end
            return result
          end)(),
        },
        hierarchicalDocumentSymbolSupport = true,
      }

      local lspconfig = require('lspconfig')
      -- 특정 LSP 서버에 대한 추가 설정
      local custom_server_configs = {
        html = {
          filetypes = { "html", "vue" },
          init_options = {
            documentSymbols = true,
            configurationSection = { "html", "css", "javascript" },
          }
        },
        cssls = {
          filetypes = { "css", "scss", "less", "vue" },
        },
        volar = {
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue", "json" },
        }
      }

      for _, server in ipairs(servers) do
        local config = {
          capabilities = capabilities,
          flags = {
            debounce_text_changes = 150,
          }
        }

        -- 서버별 커스텀 설정이 있다면 병합
        if custom_server_configs[server] then
          config = vim.tbl_deep_extend("force", config, custom_server_configs[server])
        end

        lspconfig[server].setup(config)
      end
    end
  },
}
