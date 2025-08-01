return {
  'numToStr/Comment.nvim',
  keys = { '<leader>/' },
  config = function()
    require('Comment').setup()
  end,
}

