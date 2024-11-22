-- 탭 문자 설정
vim.cmd('set expandtab')
vim.cmd('set tabstop=2')
vim.cmd('set softtabstop=2')
vim.cmd('set shiftwidth=2')

-- 최대 탭 수를 1로 제한
vim.opt.tabpagemax = 1

-- 탭라인 숨기기
vim.opt.showtabline = 0

-- leader <space>
vim.g.mapleader= ' '

-- 빈 공간에서 '~' 기호 없애기
vim.opt.fillchars = 'eob: '

-- OS 클립보드와 nvim 레지스터 연동
-- linux: xclip or xsel
-- windows: win32yank
-- mac은 기본 지원
vim.opt.clipboard = 'unnamedplus'

-- 줄 번호 표시
vim.opt.number = true

-- 팝업 메뉴 최대 높이 설정
vim.opt.pumheight = 10

-- diagnostics
vim.diagnostic.config({
  float = {
    border = 'rounded',
    style = 'minimal',
    source = 'always',
    header = '',
    prefix = '',
  },
  virtual_text = true,
  severity_sort = true,
  -- signs = false,
  signs = {
    text = {
      [vim.diagnostic.severity.HINT] = '▎',
      [vim.diagnostic.severity.INFO] = '▎',
      [vim.diagnostic.severity.WARN] = '▎',
      [vim.diagnostic.severity.ERROR] = '▎',
    },
  },
})

-- undo 파일 저장 디렉토리 설정
vim.opt.undodir = vim.fn.stdpath('data') .. '/undodir'
-- undo 파일 사용 활성화
vim.opt.undofile = true

-- 플로팅 창에서 일반 버퍼처럼 복사 가능하도록 설정
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lspinfo', 'lsp-installer', 'null-ls-info', 'help' },
  callback = function()
    vim.keymap.set('n', 'y', '"+y', { buffer = true, remap = false })
    vim.keymap.set('v', 'y', '"+y', { buffer = true, remap = false })
  end,
})

-- hover, diagnostic 플로팅 창에서도 복사 가능하도록 설정
local function set_floating_window_keymap()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local win_config = vim.api.nvim_win_get_config(win)
    if win_config.relative ~= '' then  -- floating window인 경우
      vim.keymap.set('n', 'y', '"+y', { buffer = buf, remap = false })
      vim.keymap.set('v', 'y', '"+y', { buffer = buf, remap = false })
    end
  end
end

vim.api.nvim_create_autocmd('WinEnter', {
  callback = set_floating_window_keymap
})

-- 복사한 텍스트 하이라이트 설정
vim.api.nvim_create_autocmd('TextYankPost', {
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({
      higroup = 'YankHighlight',
      timeout = 200,
      on_macro = true,
      on_visual = true,
    })
  end,
})

-- 기본 모드 표시 비활성화
vim.opt.showmode = false

-- 명령줄 높이를 0으로 설정하여 상태바를 맨 아래로
vim.opt.cmdheight = 0

-- 자동 줄바꿈 비활성화 및 가로 스크롤 활성화
vim.opt.wrap = false
vim.opt.sidescroll = 1
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.listchars:append({
  extends = '⟩',
  precedes = '⟨'
})
vim.opt.list = true

-- 커서가 위치한 라인의 배경색 설정
vim.cmd([[
  highlight CursorLine guibg=#333333
  set cursorline
]])

-- 비활성 버퍼의 하이라이트 제거
vim.api.nvim_create_autocmd('WinLeave', {
  callback = function()
    if vim.bo.buftype == '' then
      vim.cmd('ownsyntax off')
      vim.cmd('setlocal nocursorline')
      vim.opt_local.hlsearch = false
    end
  end
})

-- 버퍼 다시 활성화될 때 하이라이트 복원
vim.api.nvim_create_autocmd('WinEnter', {
  callback = function()
    if vim.bo.buftype == '' then
      vim.cmd('ownsyntax on')
      vim.cmd('setlocal cursorline')
      vim.opt_local.hlsearch = true
    end
  end
})

-- 커서 위치 저장 및 복원
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local line = vim.fn.line
    if line("'\"") > 0 and line("'\"") <= line('$') then
        vim.cmd('normal! g`"')
    end
  end,
})

-- 버퍼 닫기 전에 커서 위치 저장
vim.api.nvim_create_autocmd('BufWritePost', {
  callback = function()
    vim.cmd('mkview') -- 뷰 저장
  end,
})

-- 버퍼를 열 때 저장된 뷰 로드
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    vim.cmd('silent! loadview')
  end,
})

-- diagnostic float 창에 자동으로 커서 이동
local function goto_float_window()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then  -- floating window 확인
      vim.api.nvim_set_current_win(win)
      break
    end
  end
end

-- diagnostic float 명령어 재정의
local orig_float = vim.diagnostic.open_float
vim.diagnostic.open_float = function(...)
  orig_float(...)
  vim.schedule(goto_float_window)
end

-- 자동 주석 비활성화
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
  end,
})

