return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  config = function()
    local p = require('soontheme')
    vim.api.nvim_set_hl(0, 'IblScopeLine', { fg = p.grey_dim })

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
