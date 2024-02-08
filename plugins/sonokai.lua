return {
  'sainnhe/sonokai',
  init = function()
    vim.g.sonokai_transparent_background = 2;
    vim.g.sonokai_style = 'default';
    vim.g.sonokai_disable_italic_comment = 1;
    vim.g.sonokai_disable_terminal_colors = 0;
    vim.g.sonokai_enable_italic = 0;
    vim.g.sonokai_colors_override = {
      black = { '#333333', 232 },
      bg2 = { false, 236 },
    };
  end
}

