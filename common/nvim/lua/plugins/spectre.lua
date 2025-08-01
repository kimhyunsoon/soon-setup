return {
  'nvim-pack/nvim-spectre',
  cmd = 'Spectre',
  keys = { '<leader>ss' },
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    require('spectre').setup()
  end,
}
