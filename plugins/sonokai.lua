return {
  'sainnhe/sonokai',
  init = function()
    vim.g.sonokai_style = 'shusia';
    vim.g.sonokai_disable_italic_comment = 1;
    vim.g.sonokai_colors_override = {
      bg_dim = {'#000000', 232},
      bg0 = {'#000000', 235},
      bg1 = {'#111111', 236},
      bg2 = {'#111111', 236},
      bg3 = {'#222222', 237},
      bg4 = {'#222222', 237},
    };
  end,
}

