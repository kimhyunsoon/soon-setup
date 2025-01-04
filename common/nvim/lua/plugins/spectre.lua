return {
  'nvim-pack/nvim-spectre',
  cmd = 'Spectre',
  config = function()
    require('spectre').setup({
      open_cmd = 'botright vnew',
      live_update = true,
      mapping = {
        ['replace_cmd'] = {
          map = 'tiiwornfosdjf', -- 매핑 해제
        },
      },
    })
  end,
}
