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
vim.keymap.set('n', '[Tab]', ':norm>><cr>')
-- 내어쓰기 
vim.keymap.set('n', '[S-Tab]', ':norm<<<cr>')
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
    vim.cmd('wincmd p')
  else
    vim.cmd('Neotree focus')
  end
end, { silent = true }, { desc = '파일 탐색기 포커스 토글' })
-- 이전 단어로 이동
vim.keymap.set('i', '<Home>', function()
  if move_cursor_by_word(false) then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Left>', true, false, true), 'n', false)
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Left><End>', true, false, true), 'n', false)
  end
end, { noremap = true, silent = true }, { desc = '이전 단어로 이동' })
-- 다음 단어로 이동
vim.keymap.set('i', '<End>', function()
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
-- 이름 변경을 floating window로 설정
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

-- hover 창이 열려있을 때 ESC로 닫기
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    vim.keymap.set('n', '<ESC>', function()
      local wins = vim.api.nvim_list_wins()
      for _, win in ipairs(wins) do
        local config = vim.api.nvim_win_get_config(win)
        -- floating window인지 확인
        if config.relative ~= '' then
          vim.api.nvim_win_close(win, true)
          return
        end
      end
    end, { buffer = args.buf })
  end,
})