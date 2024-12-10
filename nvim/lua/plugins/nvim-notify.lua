return {
  'rcarriga/nvim-notify',
  event = "VeryLazy",
  config = function()
    local notify = require("notify")
    notify.setup({
      background_colour = "#000000",
      fps = 30,
      level = 2,
      max_width = 80,
      render = "wrapped-compact",
      stages = "fade",
      timeout = 3000,
      top_down = true
    })

    local notify_func = notify
    vim.notify = function(msg, ...)
      -- 특정 eslint 오류 메시지 무시
      if msg:match("eslint.*32603.*diagnostic") then
        return
      end
      notify_func(msg, ...)
    end

    -- Telescope 통합 설정
    require("telescope").load_extension("notify")
  end,
  dependencies = {
    "telescope.nvim"
  }
}
