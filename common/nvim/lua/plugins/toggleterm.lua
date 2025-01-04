return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup({
      highlights = {
        FloatBorder = { guifg = '#888888' },
      },
      hide_numbers = true,
      start_in_insert = true,
      insert_mappings = true,
      direction = 'float',
      close_on_exit = true,
      auto_scroll = true,
      float_opts = {
        width = 100,
        height = 20,
      },
    })
  end,
}
