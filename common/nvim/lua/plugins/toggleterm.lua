return {
  'akinsho/toggleterm.nvim',
  version = '*',
  event = 'VeryLazy',
  config = function()
    require('toggleterm').setup({
      hide_numbers = true,
      start_in_insert = false,
      insert_mappings = true,
      direction = 'horizontal',
      close_on_exit = true,
      auto_scroll = true,
      size = 15,
    })
  end,
}
