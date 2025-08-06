-- 탭 문자 설정
vim.cmd('set expandtab')
vim.cmd('set tabstop=2')
vim.cmd('set softtabstop=2')
vim.cmd('set shiftwidth=2')

-- 최대 탭 수를 1로 제한
vim.opt.tabpagemax = 1

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

vim.opt.maxmempattern = 2000000  -- 패턴 매칭 메모리 제한 증가
vim.opt.synmaxcol = 500  -- 구문 강조 컬럼 제한
vim.opt.updatetime = 250  -- CursorHold 이벤트 빈도
vim.opt.timeoutlen = 300  -- 키 시퀀스 대기 시간 단축
vim.opt.ttimeoutlen = 10  -- 키 코드 시퀀스 대기 시간 단축
vim.opt.redrawtime = 1500  -- 구문 강조 시간 제한
vim.opt.regexpengine = 1  -- 구 정규 표현식 엔진 사용
vim.opt.ttyfast = true  -- 빠른 터미널 연결
vim.opt.history = 1000  -- 명령어 히스토리 제한
vim.opt.backup = false  -- 백업 파일 생성 비활성화
vim.opt.writebackup = false  -- 쓰기 백업 비활성화
vim.opt.swapfile = true  -- 스왑 파일 활성화
vim.opt.cursorline = true -- 기본 커서라인만 활성화

-- diagnostics - 줄번호 색상으로 진단 표시
local signs = {
  { name = 'DiagnosticSignError', text = '', numhl = 'DiagnosticSignError' },
  { name = 'DiagnosticSignWarn', text = '', numhl = 'DiagnosticSignWarn' },
  { name = 'DiagnosticSignHint', text = '', numhl = 'DiagnosticSignHint' },
  { name = 'DiagnosticSignInfo', text = '', numhl = 'DiagnosticSignInfo' },
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, {
    texthl = '',
    text = sign.text,
    numhl = sign.numhl
  })
end

vim.diagnostic.config({
  float = {
    border = 'rounded',
    style = 'minimal',
    source = 'always',
    header = '',
    prefix = '',
  },
  virtual_text = {
    prefix = '',
    spacing = '2',
    source = true,
  },
  virtual_lines = false,
  severity_sort = true,
  signs = true,
  update_in_insert = false,
  -- 줄번호 색상 진단 표시 활성화
  underline = true,
  -- 줄번호별 진단 심각도 설정
  line_nr = {
    enable = true,
  },
})

-- undo 파일 저장 디렉토리 설정
vim.opt.undodir = vim.fn.stdpath('data') .. '/undodir'
-- undo 파일 사용 활성화
vim.opt.undofile = true

-- autocmd 그룹 생성
local augroup = vim.api.nvim_create_augroup('CommonSettings', { clear = true })

-- 복사한 텍스트 하이라이트 설정
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
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
vim.opt.list = true

-- 커서가 위치한 라인의 배경색 설정
vim.cmd([[
  highlight CursorLine guibg=#555555
  set cursorline
]])


-- 버퍼 관련 autocmd 그룹화
local buffer_group = vim.api.nvim_create_augroup('BufferSettings', { clear = true })

-- 커서 위치 저장 및 복원
vim.api.nvim_create_autocmd('BufReadPost', {
  group = buffer_group,
  callback = function()
    local line = vim.fn.line
    if line("'\"") > 0 and line("'\"") <= line('$') then
        vim.cmd('normal! g`"')
    end
  end,
})

-- 자동 주석 비활성화
vim.api.nvim_create_autocmd('FileType', {
  group = buffer_group,
  pattern = '*',
  callback = function()
    vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
  end,
})

-- eslint 설정 파일 없음 에러 무시
local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match('%-32603') and msg:match('eslint') then
    return
  end
  notify(msg, ...)
end
