return {
  'iamcco/markdown-preview.nvim',
  cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
  ft = { 'markdown' },
  init = function()
    -- firefox → safari → chromium 순으로 브라우저 탐색
    local browsers = { 'firefox', 'safari', 'chromium' }
    for _, browser in ipairs(browsers) do
      if vim.fn.executable(browser) == 1 then
        vim.g.mkdp_browser = browser
        break
      end
    end
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_combine_preview = 1
    vim.g.mkdp_refresh_slow = 1
    vim.g.mkdp_preview_options = { disable_sync_scroll = 1 }
  end,
  config = function()
    -- 플러그인 로드 후 binary가 없으면 자동 설치
    local bin_dir = vim.fn.stdpath('data') .. '/lazy/markdown-preview.nvim/app/bin'
    if vim.fn.isdirectory(bin_dir) == 0 then
      vim.fn['mkdp#util#install']()
    end
  end,
}
