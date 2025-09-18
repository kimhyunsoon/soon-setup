return {
  'mhartington/formatter.nvim',
  event = { 'BufWritePre' },
  config = function()
    local util = require('formatter.util')

    require('formatter').setup({
      logging = false,
      filetype = {
        -- Prettier를 사용할 파일 타입들
        javascript = { require('formatter.defaults.prettier') },
        typescript = { require('formatter.defaults.prettier') },
        javascriptreact = { require('formatter.defaults.prettier') },
        typescriptreact = { require('formatter.defaults.prettier') },
        vue = { require('formatter.defaults.prettier') },
        css = { require('formatter.defaults.prettier') },
        scss = { require('formatter.defaults.prettier') },
        html = { require('formatter.defaults.prettier') },
        json = { require('formatter.defaults.prettier') },
        jsonc = { require('formatter.defaults.prettier') },
        yaml = { require('formatter.defaults.prettier') },
        mjs = { require('formatter.defaults.prettier') },
        markdown = { require('formatter.defaults.prettier') },

        xml = {
          function()
            return {
              exe = 'xmllint',
              args = { '--format', '--noblanks', util.escape_path(util.get_current_buffer_file_path()) },
              stdin = false,
            }
          end,
        },

        lua = {
          require('formatter.filetypes.lua').stylua,
        },

        ['*'] = {
          require('formatter.filetypes.any').indent,
          require('formatter.filetypes.any').trim_whitespace,
        },
      },
    })

    -- 저장 시 자동으로 포매팅을 실행하는 Autocmd 설정
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = vim.api.nvim_create_augroup('FormatOnSave', { clear = true }),
      pattern = '*',
      callback = function()
        -- :ws로 저장한 경우 포매팅 건너뛰기
        if vim.g.format_disable_once then
          vim.g.format_disable_once = false
          return
        end
        vim.cmd('FormatWrite')
      end,
    })
  end,
}
