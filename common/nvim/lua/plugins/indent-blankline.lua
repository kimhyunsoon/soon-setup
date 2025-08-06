return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  config = function()
    -- 현재 스코프 라인
    vim.cmd [[highlight IblScopeLine guifg=#666666]]

    require('ibl').setup {
      indent = { char = '│' },
      whitespace = { highlight = { 'NonText', 'NonText' } },
      scope = {
        char = '│',
        highlight = 'IblScopeLine',
        show_end = false,
        show_start = false,
      },
    }
  end,
}
