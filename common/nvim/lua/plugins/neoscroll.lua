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

    local function smooth_scroll(isUp)
      local cursor = vim.api.nvim_win_get_cursor(0)
      local current_line = cursor[1]
      local current_col = cursor[2]
      local total_lines = vim.api.nvim_buf_line_count(0)

      local target_line = isUp
          and math.max(current_line - 50, 1)
          or  math.min(current_line + 50, total_lines)

      local distance = target_line - current_line
      if distance == 0 then return end

      local steps = 15
      local step_size = distance / steps
      local delay = 10

      for i = 1, steps do
        vim.defer_fn(function()
          local next_line = math.floor(current_line + step_size * i)
          if vim.api.nvim_win_is_valid(0) then
            vim.api.nvim_win_set_cursor(0, {next_line, current_col})
          end
        end, delay * i)
      end
    end

    -- 전역에서 사용할 수 있도록 설정
    _G.smooth_scroll = smooth_scroll
  end,
}
