-- 단어 단위로 커서 이동 함수
local function move_cursor_by_word(is_end_key)
  if is_end_key == nil then is_end_key = true end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = vim.api.nvim_get_current_line()
  local line_length = string.len(current_line)
  local current_word = current_line:match('%w+', cursor[2])
  if is_end_key then
    if cursor[2] == line_length then
      return false
    end
  else
    local space_count = #current_line:match('^%s*')
    if (cursor[2] - space_count) <= 0 then
      return false
    else
      return true
    end
  end

  if current_word == nil or cursor[2] + #current_word == line_length then
    return true
  else
    return false
  end
end

-- 들여쓰기
vim.keymap.set('n', '<Tab>', ':norm>><cr>')
vim.keymap.set('v', '<Tab>', '>gv', { noremap = true, silent = true })
-- 내어쓰기 
vim.keymap.set('n', '<S-Tab>', ':norm<<<cr>')
vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true, silent = true })

-- 단어 선택
vim.keymap.set('n', '<leader>w', 'viw', { desc = '단어 선택' })
-- 단축키 검색
vim.keymap.set('n', '<leader>fk', '<cmd>Telescope keymaps<CR>', { desc = '단축키 검색' })
-- 파일 검색
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = '파일 검색' })
-- 파일 내 검색
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope live_grep<CR>', { desc = '파일 내 검색' })

-- 파일 탐색기 토글
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { silent = true }, { desc = '파일 탐색기 토글' })
-- 파일 탐색기 포커스 토글
vim.keymap.set('n', '<leader>o', function()
  if vim.bo.filetype == 'neo-tree' then
    local win_id = vim.fn.winnr('#')
    if win_id > 0 then
      vim.cmd(win_id .. 'wincmd w')
    else
      vim.cmd('wincmd p')
    end
  else
    vim.cmd('Neotree focus')
  end
end, { silent = true }, { desc = '파일 탐색기 포커스 토글' })

-- 이전 단어로 이동
vim.keymap.set({ 'i', 'v' }, '<Home>', function()
  if move_cursor_by_word(false) then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Left>', true, false, true), 'n', false)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Left><End>', true, false, true), 'n', false)
  end
end, { noremap = true, silent = true }, { desc = '이전 단어로 이동' })
-- 다음 단어로 이동
vim.keymap.set({ 'i', 'v' }, '<End>', function()
  if move_cursor_by_word(true) then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<End>', true, false, true), 'n', false)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Right>', true, false, true), 'n', false)
  end
end, { noremap = true, silent = true }, { desc = '다음 단어로 이동' })

-- 정의로 이동 + 레퍼런스 찾기
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.keymap.set('n', 'gr', function()
      require('telescope.builtin').lsp_references({
        include_declaration = false,
        show_line = false,
      })
    end, { buffer = args.buf }, { desc = '레퍼런스 찾기' })
    vim.keymap.set('n', 'gd', function()
      require('telescope.builtin').lsp_definitions({
        show_line = false,
      })
    end, { buffer = args.buf, desc = '정의로 이동' })
  end
})

-- 정보 창 열기
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = '정보 창 열기' })
-- 이름 변경
vim.keymap.set('n', '<leader>lr', function()
  local curr_name = vim.fn.expand('<cword>')
  local opts = {
    relative = 'cursor',
    row = 0,
    col = 0,
    width = 30,
    height = 1,
    style = 'minimal',
    border = 'rounded',
    title = ' Rename ',
    title_pos = 'center',
  }
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, { curr_name })
  vim.keymap.set('i', '<CR>', function()
    local new_name = vim.api.nvim_get_current_line()
    vim.api.nvim_win_close(win, true)
    vim.lsp.buf.rename(new_name)
  end, { buffer = buf })
  vim.keymap.set('i', '<ESC>', function()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf })
  vim.cmd('startinsert')
end, { desc = '이름 변경' })

-- 코드 수정 제안
vim.keymap.set('n', '<leader>la', vim.lsp.buf.code_action, { desc = '코드 수정 제안' })
-- 진단 창 열기
vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float, { desc = '진단 창 열기' })
-- 다음 진단으로 이동
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = '다음 진단으로 이동' })
-- 이전 진단으로 이동
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = '이전 진단으로 이동' })

-- hover 창이 열려있을 때 ESC로 닫기 + 검색 하이라이트 제거
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.keymap.set('n', '<ESC>', function()
      local closed = false
      local wins = vim.api.nvim_list_wins()
      for _, win in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(win)
        -- floating window인지 확인
        if config.relative ~= '' then
          vim.api.nvim_win_close(win, true)
          closed = true
        end
      end
      -- floating window를 닫지 않았다면 검색 하이라이트 제거
      if not closed then
        vim.cmd('noh')
      end
    end, { buffer = args.buf, silent = true })
  end,
})

-- 코드 접기/펼치기 토글
vim.keymap.set('n', 'll', 'za', { desc = '코드 접기/펼치기 토글' })

-- 이전 버퍼로 이동
vim.keymap.set('n', '{', ':bprevious<CR>', { silent = true, desc = '이전 버퍼로 이동' })
-- 다음 버퍼로 이동
vim.keymap.set('n', '}', ':bnext<CR>', { silent = true, desc = '다음 버퍼로 이동' })
-- 현재 버퍼 닫기
vim.keymap.set('n', '<leader>c', function()
    local buftype = vim.bo.filetype
    if buftype == "spectre_panel" then
        vim.cmd('lua require("spectre").close()')
    elseif buftype == "crunner" then
        vim.cmd('q')
    else
        local prev_buf = vim.fn.bufnr('#')
        if prev_buf == -1 or not vim.api.nvim_buf_is_loaded(prev_buf) then
            return
        end
        vim.cmd('bp|bd #')
    end
end, { silent = true, desc = '현재 버퍼 닫기' })

-- 현재 버퍼를 오른쪽으로 스플릿
vim.keymap.set('n', '|', ':vsplit<CR>', { silent = true, desc = '버퍼 세로 분할' })

-- 스플릿 창 이동
vim.keymap.set('n', 'H', '<C-w>h', { silent = true, desc = '왼쪽 창으로 이동' })
vim.keymap.set('n', 'L', '<C-w>l', { silent = true, desc = '오른쪽 창으로 이동' })
vim.keymap.set('n', 'K', '<C-w>k', { silent = true, desc = '위 창으로 이동' })
vim.keymap.set('n', 'J', '<C-w>j', { silent = true, desc = '아래 창으로 이동' })

-- 닫기
vim.keymap.set('n', '<leader>q', ':q<CR>', { silent = true, desc = '닫기' })

-- 문자열 치환
vim.keymap.set('n', '<leader>sr', function()
  -- 현재 커서 위치의 단어 가져오기
  initial_text = vim.fn.expand('<cword>')

  local opts = {
    relative = 'cursor',
    row = 0,
    col = 0,
    width = 50,
    height = 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Replace ',
    title_pos = 'center',
  }
  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {'', ''})
  vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, { initial_text })
  -- Enter 키를 눌렀을 때의 동작
  vim.keymap.set('i', '<CR>', function()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local find_text = lines[1]
    local replace_text = lines[2]
    vim.api.nvim_win_close(win, true)
    vim.cmd('stopinsert') -- 인서트 모드 종료
    -- 전체 파일에서 문자열 치환 실행
    local cmd = string.format('%%s/%s/%s/g', find_text:gsub('/', '\\/'), replace_text:gsub('/', '\\/'))
    vim.cmd(cmd)
  end, { buffer = buf })
  -- ESC 키를 눌렀을 때 창 닫기
  vim.keymap.set('i', '<ESC>', function()
    vim.api.nvim_win_close(win, true)
    vim.cmd('stopinsert') -- 인서트 모드 종료
  end, { buffer = buf })
  -- Tab 키로 두 줄 간 이동
  vim.keymap.set('i', '<Tab>', function()
    local pos = vim.api.nvim_win_get_cursor(win)
    if pos[1] == 1 then
      vim.api.nvim_win_set_cursor(win, {2, 0})
    else
      vim.api.nvim_win_set_cursor(win, {1, 0})
    end
  end, { buffer = buf })
  vim.cmd('startinsert')
end, { desc = '문자열 치환' })

-- 이전 빈 줄로 이동
vim.keymap.set({ 'n', 'v' }, '[[', function()
  if vim.fn.search('^$', 'bW') == 0 then
    vim.cmd('normal! gg')
  end
end, { noremap = true, silent = true, desc = '이전 빈 줄로 이동' })

-- 다음 빈 줄로 이동
vim.keymap.set({'n', 'v'}, ']]', function()
  if vim.fn.search('^$', 'W') == 0 then
    vim.cmd('normal! G')
  end
end, { noremap = true, silent = true, desc = '다음 빈 줄로 이동' })

-- 프로젝트에서 문자열 검색 및 치환
vim.keymap.set('n', '<leader>ss', '<cmd>lua require("spectre").toggle()<CR>', { desc = '프로젝트에서 문자열 검색 및 치환' })

-- 삭제 및 붙혀넣기 시 레지스터에 저장하지 않음
vim.keymap.set('n', 'd', '"_d', { noremap = true, silent = true })
vim.keymap.set('n', 'dd', '"_dd', { noremap = true, silent = true })

-- 붙여넣기 후 레지스터 업데이트
vim.keymap.set('n', 'p', 'p:let @+=@0<CR>', { noremap = true, silent = true })
vim.keymap.set('v', 'p', 'p:let @+=@0<CR>', { noremap = true, silent = true })

-- 빈 동작으로 설정된 키 매핑들 비활성화
local empty_keys = {'c', 'a', 'cc', 'o', 't', '<A-\\>'}
for _, key in ipairs(empty_keys) do
  vim.keymap.set('n', key, '<Nop>', { noremap = true, silent = true })
end

-- x 모드에서 i를 누르면 Esc + i 실행
vim.keymap.set('x', 'i', '<Esc>i', { noremap = true })

-- 현재 파일의 전체 경로를 클립보드에 복사
vim.keymap.set('n', '<leader>yp', function()
  local command = 'let @+ = expand("%:~")'
  vim.cmd(command)
end, { desc = '파일 경로 복사' })

-- 현재 파일을 시스템 기본 프로그램으로 열기
vim.keymap.set('n', '<leader>fo', ':!open %:p<cr><cr>', { desc = '파일 열기' })

-- 랜덤 문자열 생성
vim.keymap.set('n', '<leader>rs', function()
  local function generate_random_string()
    math.randomseed(os.time())
    local charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local length = 8
    local random_string = ""
    for _ = 1, length do
      local random_index = math.random(1, #charset)
      random_string = random_string .. charset:sub(random_index, random_index)
    end
    return random_string
  end

  vim.api.nvim_put({generate_random_string()}, 'c', false, true)
end, { desc = '랜덤 문자열 생성' })

-- 현재 파일 코드 실행
vim.keymap.set('n', '<leader>rr', ':RunCode<CR>', { silent = true, desc = '코드 실행' })

-- 터미널 열기
vim.keymap.set('n', '<leader>tt', ':ToggleTerm<CR>', { noremap = true, silent = true, desc = '터미널 열기' })

-- Git 관련 키매핑
vim.api.nvim_create_autocmd('BufEnter', {
  callback = function(args)
    local gs = package.loaded.gitsigns
    if gs then
      -- 다음 변경사항으로 이동
      vim.keymap.set('n', ']g', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, {expr=true, buffer = args.buf, desc = '다음 Git 변경사항으로 이동'})

      -- 이전 변경사항으로 이동
      vim.keymap.set('n', '[g', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, {expr=true, buffer = args.buf, desc = '이전 Git 변경사항으로 이동'})
      -- git blame
      vim.keymap.set('n', 'gl', function()
        gs.blame_line{
          full = true,
          float = true,
        }
      end, { buffer = args.buf, desc = 'Git blame 보기' })

      -- diff 보기
      vim.keymap.set('n', '<leader>gd', gs.diffthis, { buffer = args.buf, desc = 'Git diff 보기' })
    end
  end
})

-- 수정된 파일 탐색
vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, {
  desc = 'Git 수정된 파일 탐색',
  noremap = true,
  silent = true,
})

-- Staged 파일 탐색
vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, {
  desc = 'Git Commit 탐색',
  noremap = true,
  silent = true,
})

-- Git 브랜치 탐색
vim.keymap.set('n', '<leader>gb', require('telescope.builtin').git_branches, {
  desc = 'Git 브랜치 탐색',
  noremap = true,
  silent = true,
})

-- Git Graph 열기
vim.keymap.set('n', '<leader>gg', function()
  require('gitgraph').draw({}, { all = true, max_count = 5000 })
end, { desc = 'Git Graph 열기' })

-- 주석 토글
vim.keymap.set('n', '<leader>/', function()
    require('Comment.api').toggle.linewise.current()
end, { noremap = true, silent = true, desc = '주석 토글' })
vim.keymap.set('v', '<leader>/', function()
  local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
  vim.api.nvim_feedkeys(esc, 'x', false) -- 비주얼 모드 종료 후 범위 사용
  require('Comment.api').toggle.linewise(vim.fn.visualmode())
end, { noremap = true, silent = true, desc = '선택 영역 주석 토글' })

-- 새 버퍼 생성
vim.keymap.set("n", "<leader>n", function()
  vim.cmd("enew")
end, { noremap = true, silent = true, desc = "새 버퍼 생성" })

-- 인서트 모드에서 F1~F24 키를 무시
for i = 1, 24 do
    vim.keymap.set('i', '<F' .. i .. '>', '', { noremap = true, silent = true })
end
