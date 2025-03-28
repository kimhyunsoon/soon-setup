return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  config = function()
    require('ibl').setup {
      indent = { char = '│' },
      whitespace = { highlight = { 'NonText', 'NonText' } },
      scope = {
        char = '│',
        highlight = 'NonText',
        show_end = false,
        show_start = false,
      },
    }
  end,
}
