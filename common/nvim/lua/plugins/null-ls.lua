return {
  'nvimtools/none-ls.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  dependencies = {
    'mason.nvim',
  },
  config = function()
    local null_ls = require('null-ls')

    local function find_workspace_root(dir)
      local current_dir = dir
      while current_dir do
        local workspace_file = current_dir .. '/pnpm-workspace.yaml'
        if vim.fn.filereadable(workspace_file) == 1 then
          return current_dir
        end
        local parent = vim.fn.fnamemodify(current_dir, ':h')
        if parent == current_dir then
          break
        end
        current_dir = parent
      end
      return nil
    end

    local function find_prettier_config(dir)
      if not dir then return nil end
      local config_files = {
        '.prettierrc',
        '.prettierrc.json',
        '.prettierrc.yml',
        '.prettierrc.yaml',
        '.prettierrc.js',
        '.prettierrc.cjs',
        'prettier.config.js',
      }

      for _, config_file in ipairs(config_files) do
        local config_path = dir .. '/' .. config_file
        if vim.fn.filereadable(config_path) == 1 then
          return config_path
        end
      end

      local package_json = dir .. '/package.json'
      if vim.fn.filereadable(package_json) == 1 then
        local content = vim.fn.readfile(package_json)
        local decoded = vim.fn.json_decode(content)
        if decoded and decoded.prettier then
          return package_json
        end
      end
      return nil
    end

    local function should_format(utils)
      local buffer_path = vim.api.nvim_buf_get_name(0)
      local buffer_dir = vim.fn.fnamemodify(buffer_path, ':h')
      if not buffer_dir then return false end

      local workspace_root = find_workspace_root(buffer_dir)
      if workspace_root then
        return find_prettier_config(buffer_dir) ~= nil or find_prettier_config(workspace_root) ~= nil
      end
      return find_prettier_config(buffer_dir) ~= nil
    end

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.prettier.with({
          condition = should_format,
          filetypes = {
            'javascript',
            'typescript',
            'javascriptreact',
            'typescriptreact',
            'vue',
            'css',
            'scss',
            'html',
          },
        }),
      },
      on_attach = function(client, bufnr)
        if client.supports_method('textDocument/formatting') then
          local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
    })
  end,
}
