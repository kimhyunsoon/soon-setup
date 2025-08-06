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

-- 대용량 파일 처리를 위한 설정
local large_file_group = vim.api.nvim_create_augroup('LargeFileHandling', { clear = true })

vim.api.nvim_create_autocmd('BufReadPre', {
  group = large_file_group,
  callback = function(args)
    local buf = args.buf
    local filename = vim.api.nvim_buf_get_name(buf)
    local size = vim.fn.getfsize(filename)

    if size > 1048576 then  -- 1MB 이상
      -- 매우 큰 파일: Treesitter 비활성화하되 기본 syntax highlighting 유지
      vim.b[buf].large_file = true
      vim.bo[buf].swapfile = false
      vim.bo[buf].bufhidden = 'unload'
      vim.bo[buf].undolevels = 100  -- undo 완전 비활성화 대신 제한
      vim.wo.foldenable = false
      vim.wo.wrap = false

      -- 성능 최적화하되 하이라이트는 유지
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          -- Treesitter 비활성화
          vim.cmd('TSBufDisable highlight')
          vim.cmd('TSBufDisable indent')
          vim.cmd('TSBufDisable incremental_selection')

          -- 파일 타입별 기본 syntax 활성화 (하이라이트 유지)
          if filename:match('%.xml$') or filename:match('%.xsd$') or filename:match('%.xsl$') then
            vim.bo[buf].syntax = 'xml'
          elseif filename:match('%.json$') then
            vim.bo[buf].syntax = 'json'
          elseif filename:match('%.js$') then
            vim.bo[buf].syntax = 'javascript'
          elseif filename:match('%.ts$') then
            vim.bo[buf].syntax = 'typescript'
          elseif filename:match('%.py$') then
            vim.bo[buf].syntax = 'python'
          elseif filename:match('%.html$') then
            vim.bo[buf].syntax = 'html'
          elseif filename:match('%.css$') then
            vim.bo[buf].syntax = 'css'
          end
        end
      end)

      vim.notify(string.format('Enable large file mode. (%.1fMB)', size / 1048576), vim.log.levels.INFO)

    elseif size > 512000 then  -- 500KB 이상
      -- 중간 크기 파일: 일부 Treesitter 기능만 비활성화
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.cmd('TSBufDisable incremental_selection')
        end
      end)
    end
  end,
})

-- 간소화된 하이라이팅 설정
vim.api.nvim_create_autocmd('BufEnter', {
  once = true,
  callback = function() vim.cmd('syntax on') end,
})
