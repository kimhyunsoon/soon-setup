return {
  "machakann/vim-highlightedyank",
  event = "VeryLazy",
  config = function()
    -- 하이라이트 지속 시간 (밀리초)
    vim.g.highlightedyank_highlight_duration = 200
    
    -- 하이라이트 색상 설정 (선택사항)
    vim.cmd([[highlight HighlightedyankRegion guibg=#888888]])
  end,
} 