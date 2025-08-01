return {
  "karb94/neoscroll.nvim",
  event = 'VeryLazy',
  config = function()
    require('neoscroll').setup({
      mappings = {}, -- 기본 매핑 비활성화
      hide_cursor = false,
      stop_eof = true,
      respect_scrolloff = false,
      cursor_scrolls_alone = true,
      easing_function = nil,
      pre_hook = nil,
      post_hook = nil,
      performance_mode = false,
    })

    local neoscroll = require('neoscroll')

    -- smooth scroll 함수들
    local function smooth_scroll_down()
      neoscroll.ctrl_d({ duration = 200 })
      vim.schedule(function()
        vim.cmd('normal! zz')
      end)
    end

    local function smooth_scroll_up()
      neoscroll.ctrl_u({ duration = 200 })
      vim.schedule(function()
        vim.cmd('normal! zz')
      end)
    end

    -- 전역에서 사용할 수 있도록 설정
    _G.smooth_scroll_down = smooth_scroll_down
    _G.smooth_scroll_up = smooth_scroll_up
  end,
}
