return {
  'sainnhe/sonokai',
  name = 'sonokai',
  priority = 1000,
  config = function()
    vim.g.sonokai_style = 'default'
    vim.g.sonokai_better_performance = 1
    vim.g.sonokai_transparent_background = 2
    vim.g.sonokai_disable_italic_comment = 1
    vim.g.sonokai_disable_terminal_colors = 0
    vim.g.sonokai_enable_italic = 0
    vim.g.sonokai_colors_override = {
      black = { '#333333', 232 },
      bg2 = { false, 236 },
      orange = { '#cccccc', 203 },
    }
    vim.cmd([[colorscheme sonokai]])
  end
}