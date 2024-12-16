------------------------------------------ 함수 ------------------------------------------
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

-- 랜덤 문자열 생성 함수
local function generate_random_string()
  math.randomseed(os.time())
  local charset = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
  local length = 8
  local random_string = ''
  for _ = 1, length do
    local random_index = math.random(1, #charset)
    random_string = random_string .. charset:sub(random_index, random_index)
  end
  return random_string
end


------------------------------------------ [editor] ------------------------------------------
-- Redo
vim.keymap.set('n', 'R', '<C-r>', { noremap = true, silent = true, desc = '[editor] Redo' })

-- 들여쓰기
vim.keymap.set('n', '<Tab>', ':norm>><cr>', { noremap = true, silent = true })
vim.keymap.set('v', '<Tab>', '>gv', { noremap = true, silent = true })
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 1 then
    return '<Tab>'
  end
  return '<C-o>>><Right><Right>'
end, { noremap = true, silent = true, expr = true })

-- 내어쓰기
vim.keymap.set('n', '<S-Tab>', ':norm<<<cr>', { noremap = true, silent = true })
vim.keymap.set('v', '<S-Tab>', '<gv', { noremap = true, silent = true })
vim.keymap.set('i', '<S-Tab>', '<C-o><<', { noremap = true, silent = true })

-- 단어 선택
vim.keymap.set('n', '<leader>w', 'viw', { noremap = true, silent = true, desc = '단어 선택' })

-- 이전 단어로 이동
vim.keymap.set('i', '<Home>',
  function()
    if move_cursor_by_word(false) then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Left>', true, false, true), 'n', false)
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Left><End>', true, false, true), 'n', false)
    end
  end, { noremap = true, silent = true, desc = '[editor] 이전 단어로 이동' }
)

-- 다음 단어로 이동
vim.keymap.set('i', '<End>',
  function()
    if move_cursor_by_word(true) then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<End>', true, false, true), 'n', false)
    else
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Right>', true, false, true), 'n', false)
    end
  end, { noremap = true, silent = true, desc = '[editor] 다음 단어로 이동' }
)

-- 코드 접기/펼치기 토글
vim.keymap.set('n', 'll', 'za', { noremap = true, silent = true, desc = '[editor] 코드 접기/펼치기 토글' })

-- 문자열 치환
vim.keymap.set('n', 'ls',
  function()
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
  end, { noremap = true, silent = true, desc = '[editor] 문자열 치환' }
)

-- 코드 Split-Jion 토글
vim.keymap.set('n', 'lw', '<cmd>lua require("treesj").toggle()<CR>', { noremap = true, silent = true, desc = '[editor] 코드 Split-Join 토글' })

-- 텍스트 wrap 토글
vim.keymap.set('n', '<leader>m', '<cmd>set wrap!<CR>', { noremap = true, silent = true, desc = '[editor] 텍스트 wrap 토글' })

-- ESC를 누르면 검색하이라이트 종료 + hover창 닫기
vim.keymap.set({ 'n', 'i', 'v' }, '<ESC>', function()

  -- 텔레스코프인 경우 처리
  if vim.bo.filetype == 'TelescopePrompt' then
    require('telescope.actions').close(vim.api.nvim_get_current_buf())
    return
  end

  -- copilot-chat 창인 경우 처리
  if vim.bo.filetype == 'copilot-chat' then
    if vim.fn.mode() == 'i' then
      -- 인서트 모드라면 노말모드로 전환
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, true, true), 'n', false)
    else
      -- 노말모드라면 종료
      vim.cmd('CopilotChatToggle')
    end
    return
  end

  -- 검색 하이라이트 종료
  vim.cmd('nohlsearch')
  -- LSP hover 창 닫기
  for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(winid).relative ~= '' then
      vim.api.nvim_win_close(winid, false)
    end
  end
  -- cmp 창 닫기
  require('cmp').close()

  -- 현재 모드가 노말 모드가 아닐 경우 노말 모드로 전환
  if vim.api.nvim_get_mode().mode ~= 'n' then
    vim.cmd('stopinsert')
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'n', false)
  end
end, { noremap = true, silent = true })

-- 주석 토글
vim.keymap.set('n', '<leader>/',
  function()
    require('Comment.api').toggle.linewise.current()
  end, { noremap = true, silent = true, desc = '[editor] 주석 토글' }
)
-- 선택 영역 주석 토글
vim.keymap.set('v', '<leader>/',
  function()
    local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'x', false)
    require('Comment.api').toggle.linewise(vim.fn.visualmode())
  end, { noremap = true, silent = true, desc = '[editor] 선택 영역 주석 토글' }
)

-- 이전 빈 줄로 이동
vim.keymap.set({ 'n', 'v' }, '[[',
  function()
    if vim.fn.search('^$', 'bW') == 0 then
      vim.cmd('normal! gg')
    end
  end, { noremap = true, silent = true, desc = '[editor] 이전 빈 줄로 이동' }
)

-- 다음 빈 줄로 이동
vim.keymap.set({'n', 'v'}, ']]',
  function()
    if vim.fn.search('^$', 'W') == 0 then
      vim.cmd('normal! G')
    end
  end, { noremap = true, silent = true, desc = '[editor] 다음 빈 줄로 이동' }
)

-- 프로젝트에서 문자열 검색 및 치환
vim.keymap.set('n', '<leader>ss', '<cmd>lua require("spectre").toggle()<CR>', { noremap = true, silent = true, desc = '[editor] 프로젝트에서 문자열 검색 및 치환' })

-- 삭제 및 붙여넣기 시 레지스터에 저장하지 않음
vim.keymap.set('n', 'd', '"_d', { noremap = true, silent = true })
vim.keymap.set('n', 'dd', '"_dd', { noremap = true, silent = true })

-- 붙여넣기 후 레지스터 업데이트
vim.keymap.set('n', 'p', 'p:let @+=@0<CR>', { noremap = true, silent = true })
vim.keymap.set('v', 'p', 'p:let @+=@0<CR>', { noremap = true, silent = true })

-- 빈 동작으로 설정된 키 매핑들 비활성화
local empty_keys = {'c', 'a', 'cc', 'o', 't', '<A-\\>', 's'}
for _, key in ipairs(empty_keys) do
  vim.keymap.set('n', key, '<Nop>', { noremap = true, silent = true })
end

-- x 모드에 i 르면 Esc + i 실행
vim.keymap.set('x', 'i', '<Esc>i', { noremap = true, silent = true })

-- 인서트 모드에 F1~F24 키를 무시
for i = 1, 24 do
  vim.keymap.set('i', '<F' .. i .. '>', '', { noremap = true, silent = true })
end



------------------------------------------ [common] ------------------------------------------
-- 단축키 검색
vim.keymap.set('n', '<leader>fk', '<cmd>Telescope keymaps<CR>', { noremap = true, silent = true, desc = '[common] 단축키 검색' })
-- 파일 검색
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<CR>', { noremap = true, silent = true, desc = '[common] 파일 검색' })
-- 파일 내 검색
vim.keymap.set('n', '<leader>fw', '<cmd>Telescope live_grep<CR>', { noremap = true, silent = true, desc = '[common] 파일 내 검색' })
-- 파일 탐색기 토글
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { noremap = true, silent = true, desc = '[common] 파일 탐색기 토글' })

-- 파일 탐색기 포커스 토글
vim.keymap.set('n', '<leader>o',
  function()
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
  end, { noremap = true, silent = true, desc = '[common] 파일 탐색기 포커스 토글' }
)

-- 스플릿 창 이동
vim.keymap.set('n', 'H', '<C-w>h', { noremap = true, silent = true, desc = '[common] 왼쪽 창으로 이동' })
vim.keymap.set('n', 'L', '<C-w>l', { noremap = true, silent = true, desc = '[common] 오른쪽 창으로 이동' })
vim.keymap.set('n', 'K', '<C-w>k', { noremap = true, silent = true, desc = '[common] 위 창으로 이동' })
vim.keymap.set('n', 'J', '<C-w>j', { noremap = true, silent = true, desc = '[common] 아래 창으로 이동' })

-- 이전 버퍼로 이동
vim.keymap.set('n', '{', ':bprevious<CR>', { noremap = true, silent = true, desc = '[common] 이전 버퍼로 이동' })

-- 다음 버퍼로 이동
vim.keymap.set('n', '}', ':bnext<CR>', { noremap = true, silent = true, desc = '[common] 다음 버퍼로 이동' })

-- 현재 버퍼 닫기
vim.keymap.set('n', '<leader>c',
  function()
    local current_buf = vim.api.nvim_get_current_buf()
    
    if vim.bo[current_buf].modified then
      if vim.fn.bufname(current_buf) == '' then
        -- 다음 단계로 진행
      else
        vim.api.nvim_echo({{
          '저장되지 않은 변경사항이 있습니다. 저장하시겠습니까? [y/n]: ',
          'WarningMsg'
        }}, false, {})

        local char = vim.fn.getchar()
        local answer = vim.fn.nr2char(char)
        
        if char == 27 then  -- ESC key
          vim.api.nvim_echo({{'', ''}}, false, {})
          return
        elseif answer:lower() == 'y' then
          vim.cmd('write')
        end
        -- n을 선택하면 저장하지 않고 계속 진행
      end
    end
    
    -- neo-tree 버퍼인 경우 빠르게 리턴
    if vim.bo[current_buf].filetype == 'neo-tree' then
      return
    end
    
    -- 현재 윈도우 ID 캐싱
    local current_win = vim.api.nvim_get_current_win()
    local wins = vim.api.nvim_list_wins()
    
    -- crunner 창 처리 (한 번의 반복문으로 valid_wins도 같이 처리)
    local valid_wins = {}
    for _, win in ipairs(wins) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      
      if ft == 'crunner' then
        vim.api.nvim_win_close(win, true)
        return
      elseif ft ~= 'neo-tree' then
        table.insert(valid_wins, win)
      end
    end
    
    -- 스플릿 창 처리
    if #valid_wins > 1 and current_win ~= valid_wins[1] then
      vim.cmd('quit')
      return
    end
    
    -- 버퍼 처리 로직
    local bufs = vim.api.nvim_list_bufs()
    local valid_buf_count = 0
    
    for _, buf in ipairs(bufs) do
      if vim.api.nvim_buf_is_valid(buf) 
         and vim.bo[buf].buflisted
         and vim.bo[buf].filetype ~= 'neo-tree' then
        valid_buf_count = valid_buf_count + 1
        if valid_buf_count > 1 then
          break
        end
      end
    end
    
    -- 버퍼 닫기 처리
    if valid_buf_count <= 1 then
      vim.cmd('enew')
      vim.cmd('bd! ' .. current_buf)
    else
      vim.cmd('bp|bd! ' .. current_buf)
    end
  end,
  { noremap = true, silent = true, desc = '[common] 현재 버퍼 닫기' }
)

-- 전체 닫기
vim.cmd('cabbrev q <c-r>=(getcmdtype()==\':\' && getcmdpos()==1 ? \'Q\' : \'q\')<CR>')

vim.api.nvim_create_user_command('Q',
  function()
    local has_unsaved = false
    for _, buf in ipairs(vim.fn.getbufinfo()) do
      if buf.changed == 1 and buf.name ~= '' then
        has_unsaved = true
        break
      end
    end

    if not has_unsaved then
      vim.cmd('qa')
      return
    end

    while true do
      vim.api.nvim_echo({{
        '저장되지 않은 변경사항이 있습니다. 저장하시겠습니까? [y/n]: ',
        'WarningMsg'
      }}, false, {})

      local char = vim.fn.getchar()
      local answer = vim.fn.nr2char(char)
      
      if char == 27 then  -- ESC key
        vim.api.nvim_echo({{'', ''}}, false, {})
        return
      elseif answer:lower() == 'y' then
        vim.cmd('wqa')
        break
      elseif answer:lower() == 'n' then
        vim.cmd('qa!')
        break
      end
    end
  end, {}
)

-- 현재 버퍼를 오른쪽으로 스플릿
vim.keymap.set('n', '|', ':vsplit<CR>', { noremap = true, silent = true, desc = '[common] 버퍼 세로 분할' })

-- 현재 파일을 시스템 기본 프로그램으로 열기
vim.keymap.set('n', '<leader>fo', ':!open %:p<cr><cr>', { noremap = true, silent = true, desc = '[common] 파일 열기' })

-- 현재 파일의 전체 경로를 클립보드에 복사
vim.keymap.set('n', '<leader>yp',
  function()
    local command = 'let @+ = expand("%:~")'
    vim.cmd(command)
  end, { noremap = true, silent = true, desc = '[common] 파일 경로 복사' }
)

-- 랜덤 문자열 생성
vim.keymap.set('n', '<leader>rs', function() vim.api.nvim_put({generate_random_string()}, 'c', false, true) end, 
  { noremap = true, silent = true, desc = '[common] 랜덤 문자열 생성' })

-- 현재 파일 코드 실행
vim.keymap.set('n', '<leader>rr', ':RunCode<CR>', { noremap = true, silent = true, desc = '[common] 코드 실행' })

-- 터미널 열기
vim.keymap.set('n', '<leader>tt', ':ToggleTerm<CR>', { noremap = true, silent = true, desc = '[common] 터미널 열기' })

-- 새 버퍼 생성
vim.keymap.set('n', '<leader>n',
  function()
    
  end, { noremap = true, silent = true, desc = '[common] 새 버퍼 생성' }
)

-- 이전/다음커서 이동
vim.keymap.set('n', 'o', '<C-o>', { noremap = true, silent = true, desc = '[common] 이전 커서로 이동' })
vim.keymap.set('n', 'O', '<C-i>', { noremap = true, silent = true, desc = '[common] 다음 커서로 이동' })


vim.keymap.set('n', '<leader>nh', '<cmd>Telescope notify<CR>', { noremap = true, silent = true, desc = '[common] 알림 기록 보기' })

------------------------------------------ [lsp] ------------------------------------------
-- 레퍼런스 찾기
vim.keymap.set('n', 'gr',
  function()
    require('telescope.builtin').lsp_references({
      include_declaration = false,
      show_line = false,
    })
  end, { noremap = true, silent = true, desc = '[lsp] 레퍼런스 찾기' }
)

-- 정의로 이동
vim.keymap.set('n', 'gd',
  function()
    require('telescope.builtin').lsp_definitions({
      show_line = false,
    })
  end, { noremap = true, silent = true, desc = '[lsp] 정의로 이동' }
)

-- 정보 창 열기
vim.keymap.set('n', 'lk', vim.lsp.buf.hover, { noremap = true, silent = true, desc = '[lsp] 정보 창 열기' })

-- 식별자 변경
vim.keymap.set('n', 'lr',
  function()
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
      vim.cmd('stopinsert')
      vim.schedule(function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'n', false)
        vim.lsp.buf.rename(new_name)
      end)
    end, { buffer = buf })
    vim.keymap.set('i', '<ESC>', function()
      vim.api.nvim_win_close(win, true)
      vim.cmd('stopinsert')
      vim.schedule(function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>', true, false, true), 'n', false)
      end)
    end, { buffer = buf })
    vim.cmd('startinsert')
  end, { noremap = true, silent = true, desc = '[lsp] 식별자 변경' }
)

-- 코드 수정 제안
vim.keymap.set('n', 'la', vim.lsp.buf.code_action, { noremap = true, silent = true, desc = '[lsp] 코드 수정 제안' })

-- 진단 열기
vim.keymap.set('n', 'ld', vim.diagnostic.open_float, { noremap = true, silent = true, desc = '[lsp] 진단 창 열기' })

-- 다음 진단으로 이동
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true, desc = '[lsp] 다음 진단으로 이동' })

-- 이전 진단으로 이동
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true, desc = '[lsp] 이전 진단으로 이동' })


------------------------------------------ [git] ------------------------------------------
-- 다음 Git 변경사항으로 이동
vim.keymap.set('n', ']g', function() require('gitsigns').next_hunk() end, { noremap = true, silent = true, desc = '[git] 다음 Git 변경사항으로 이동' })

-- 이전 Git 변경사항으로 이동
vim.keymap.set('n', '[g', function() require('gitsigns').prev_hunk() end, { noremap = true, silent = true, desc = '[git] 이전 Git 변경사항으로 이동' })

-- Git blame 보기
vim.keymap.set('n', 'gl', function() require('gitsigns').blame_line{ full = true, float = true } end, { noremap = true, silent = true, desc = '[git] Git blame 보기' })

-- Git diff 보기
vim.keymap.set('n', '<leader>gd', function() require('gitsigns').diffthis() end, { noremap = true, silent = true, desc = '[git] Git diff 보기' })

-- 수정된 파일 탐색
vim.keymap.set('n', '<leader>gs', require('telescope.builtin').git_status, {
  noremap = true,
  silent = true,
  desc = '[git] 수정된 파일 탐색',
})

-- Staged 파일 탐색
vim.keymap.set('n', '<leader>gc', require('telescope.builtin').git_commits, {
  noremap = true,
  silent = true,
  desc = '[git] Git Commit 탐색',
})

-- Git 브랜치 탐색
vim.keymap.set('n', '<leader>gb', require('telescope.builtin').git_branches, {
  noremap = true,
  silent = true,
  desc = '[git] Git 브랜치 탐색',
})

-- Git Graph 열기
vim.keymap.set('n', '<leader>gg',
  function()
    require('gitgraph').draw({}, { all = true, max_count = 5000 })
  end, { noremap = true, silent = true, desc = '[git] Git Graph 열기' }
)


------------------------------------------ [Copilot] ------------------------------------------
vim.keymap.set({ 'n', 'v' }, '<leader>i', '<cmd>:CopilotChatToggle<CR>', { noremap = true, silent = true, desc = '[copilot] 채팅 토글' })
vim.keymap.set('n', '<leader>r', '', { desc = '[copilot] 채팅 초기화' })
vim.keymap.set('n', '<leader>y', '', { desc = '[copilot] 채팅 제안 수락' })

