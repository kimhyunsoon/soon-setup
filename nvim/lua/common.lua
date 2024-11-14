-- 탭 문자 설정
vim.cmd('set expandtab')
vim.cmd('set tabstop=2')
vim.cmd('set softtabstop=2')
vim.cmd('set shiftwidth=2')

-- leader <space>
vim.g.mapleader= ' '

-- 빈 공간에서 '~' 기호 없애기
vim.opt.fillchars = "eob: "

-- 줄 번호 표시
vim.opt.number = true

-- 수정된 파일 저장
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local bufs = vim.api.nvim_list_bufs()
    for _, buf in ipairs(bufs) do
      if vim.api.nvim_buf_get_option(buf, "modified") then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent! write")
        end)
      end
    end
  end,
})

-- 팝업 메뉴 최대 높이 설정
vim.opt.pumheight = 10

-- hover 창
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded",
  }
)

-- diagnostics
vim.diagnostic.config({
  float = {
    border = "rounded",
    style = "minimal",
    source = "always",
    header = "",
    prefix = "",
  },
  virtual_text = false,
  severity_sort = true,
})

-- undo 파일 저장 디렉토리 설정
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
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
