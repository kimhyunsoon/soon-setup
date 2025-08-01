return {
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  config = function()
    local notify = require('notify')
    notify.setup({
      timeout = 2000,
      max_height = 3,
      max_width = 50,
      stages = 'static',
      render = 'minimal',
      minimum_width = 30,
      fps = 10,
    })
    vim.notify = notify
  end,
}
