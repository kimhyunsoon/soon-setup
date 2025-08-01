-- 탭 문자 설정
vim.cmd('set expandtab')
vim.cmd('set tabstop=2')
vim.cmd('set softtabstop=2')
vim.cmd('set shiftwidth=2')

-- 최대 탭 수를 1로 제한
vim.opt.tabpagemax = 1

-- 탭라인 항상 표시 (mini.tabline 사용)
vim.opt.showtabline = 2

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

-- 성능 최적화 설정
vim.opt.maxmempattern = 2000000  -- 패턴 매칭 메모리 제한 증가
vim.opt.synmaxcol = 500  -- 구문 강조 컬럼 제한 (긴 줄에서 성능 향상)
vim.opt.updatetime = 100  -- CursorHold 이벤트 빈도 감소
vim.opt.timeoutlen = 300  -- 키 시퀀스 대기 시간 단축
vim.opt.ttimeoutlen = 10  -- 키 코드 시퀀스 대기 시간 단축
vim.opt.redrawtime = 1500  -- 구문 강조 시간 제한
vim.opt.regexpengine = 1  -- 구 정규 표현식 엔진 사용 (더 빠름)
vim.opt.lazyredraw = true  -- 매크로 실행 중 화면 재그리기 지연

-- diagnostics
local signs = {
  { name = "DiagnosticSignError", text = "▎" },
  { name = "DiagnosticSignWarn", text = "▎" },
  { name = "DiagnosticSignHint", text = "▎" },
  { name = "DiagnosticSignInfo", text = "▎" },
}

-- signs 등록
for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

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
  signs = true,
  update_in_insert = false,
})

-- undo 파일 저장 디렉토리 설정
vim.opt.undodir = vim.fn.stdpath('data') .. '/undodir'
-- undo 파일 사용 활성화
vim.opt.undofile = true

-- autocmd 그룹 생성
local augroup = vim.api.nvim_create_augroup('CommonSettings', { clear = true })

-- 복사한 텍스트 하이라이트 설정 (성능 최적화)
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

-- 성능 최적화: 기본 cursorline만 사용
vim.opt.cursorline = true

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
  if msg:match("%-32603") and msg:match("eslint") then
    return
  end
  notify(msg, ...)
end
