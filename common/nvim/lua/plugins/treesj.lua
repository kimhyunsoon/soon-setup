return {
  'Wansmer/treesj',
  config = function()
    require('treesj').setup({
      use_default_keymaps = false,  -- 기본 키맵 비활성화 (keybindings.lua에서 관리)
      check_syntax_error = true,    -- 구문 오류 확인
      max_join_length = 120,        -- 한 줄로 합칠 최대 길이
      cursor_behavior = 'hold',     -- 커서 위치 유지
      notify = true,                -- 알림 활성화
      dot_repeat = true,            -- . 반복 명령 지원
      on_error = nil,               -- 오류 시 콜백
      langs = {
        -- 모든 언어에 대한 범용 설정
        ['*'] = {
          both = {
            fallback = function()
              -- fallback 동작: 기본 vim의 J 명령어 사용
              local line = vim.fn.line('.')
              local col = vim.fn.col('.')
              vim.cmd('normal! J')
              vim.fn.cursor(line, col)
            end,
          },
        },
        -- JavaScript/TypeScript 특별 설정
        javascript = {
          both = {
            non_bracket_node = { 'comment', 'string', 'string_fragment' },
          },
        },
        typescript = {
          both = {
            non_bracket_node = { 'comment', 'string', 'string_fragment' },
          },
        },
        -- HTML/XML 설정
        html = {
          both = {
            separator = ' ',
          },
        },
        -- XML 설정
        xml = {
          both = {
            separator = ' ',
          },
        },
        -- CSS 설정
        css = {
          both = {
            separator = ' ',
          },
        },
        -- JSON 설정
        json = {
          both = {
            separator = ' ',
          },
        },
        -- Lua 설정
        lua = {
          both = {
            non_bracket_node = { 'comment', 'string' },
          },
        },
        -- Python 설정
        python = {
          both = {
            separator = ' ',
          },
        },
      },
    })
  end,
}
