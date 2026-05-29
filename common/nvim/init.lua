-- lazy 세팅
local lazypath = vim.env.LAZY or vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 성능 향상을 위한 빠른 시작 설정
vim.g.python3_host_prog = '/usr/bin/python3'
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- 공통 설정
require 'common'

-- 대용량 파일 일괄 처리 (플러그인보다 먼저 등록되어야 BufReadPre 순서가 보장됨)
require('bigfile').setup()

require('lazy').setup({ import = 'plugins' }, {
  ui = { backdrop = 100 },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,
    rtp = {
      reset = true,
      paths = {},
      disabled_plugins = {
        'gzip',
        'matchit',
        'netrwPlugin',
        'tarPlugin',
        'tohtml',
        'tutor',
        'zipPlugin',
        'rplugin',
        'spellfile_plugin',
        'editorconfig',
        'rrhelper',
        'vimball',
        'vimballPlugin',
        'bugreport',
        'ftplugin',
        'getscript',
        'getscriptPlugin',
        'logipat',
        'man',
        'optwin',
        'syntax',
        '2html_plugin',
        'getscriptPlugin',
        'logiPat',
        'matchit',
        'netrw',
        'netrwFileHandlers',
        'netrwSettings',
        'rrhelper',
        'shada_plugin',
        'spec',
      },
    },
  },
  dev = {
    path = "~/projects",
    fallback = false,
  },
})



-- 컬러스키마
vim.cmd('colorscheme soontheme')
vim.cmd('highlight Visual guibg=#666666')

-- 키매핑
require 'keybindings'

-- Vue 파일에서 TypeScript 지원을 위한 추가 설정
vim.g.vue_pre_processors = 'detect_on_enter'

-- nvim 시작 시 자동으로 Neo-tree 열기
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    if vim.fn.argc() == 0 or vim.fn.isdirectory(vim.fn.argv(0)) == 1 then
      vim.defer_fn(function()
        pcall(vim.cmd, 'Neotree show')
          if vim.fn.bufname() == '' and vim.fn.line('$') == 1 and vim.fn.getline(1) == '' then
            vim.cmd('enew')
          end
          vim.cmd('wincmd l')
      end, 100)
    end
  end,
})

-- 기본 정규식 syntax 활성화 (트리시터가 처리하지 않는 파일타입용)
vim.api.nvim_create_autocmd('BufEnter', {
  once = true,
  callback = function() vim.cmd('syntax on') end,
})
