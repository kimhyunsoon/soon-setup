return {
  'sainnhe/sonokai',
  init = function()
    vim.g.sonokai_transparent_background = 2;
    vim.g.sonokai_style = 'shusia';
    vim.g.sonokai_disable_italic_comment = 1;
    vim.g.sonokai_colors_override = {
      black = { '#333333', 232 },
    };
  end
}

