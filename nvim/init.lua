-- lazy 세팅
local lazypath = vim.env.LAZY or vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 공통 설정
require 'common'

require('lazy').setup({ import = "plugins" }, {
  ui = { backdrop = 100 },
  performance = {
    rtp = {
    disabled_plugins = {
      'gzip',
      'netrwPlugin',
      'tarPlugin',
      'tohtml',
      'zipPlugin',
    },
    },
  },
})

-- 복사 하이라이트 설정
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

-- 키매핑
require 'keybindings'
