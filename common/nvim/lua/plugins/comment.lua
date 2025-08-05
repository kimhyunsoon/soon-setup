return {
  'numToStr/Comment.nvim',
  keys = { '<leader>/' },
  config = function()
    require('Comment').setup()
    -- 주석 토글 키맵 설정
    vim.keymap.set('n', '<leader>/', function()
      require('Comment.api').toggle.linewise.current()
    end, { noremap = true, silent = true, desc = '[editor] 주석 토글' })
    -- 선택 영역 주석 토글
    vim.keymap.set('v', '<leader>/', function()
      local esc = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
      vim.api.nvim_feedkeys(esc, 'x', false)
      require('Comment.api').toggle.linewise(vim.fn.visualmode())
    end, { noremap = true, silent = true, desc = '[editor] 선택 영역 주석 토글' })
  end,
}

