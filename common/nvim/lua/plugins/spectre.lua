return {
  'nvim-pack/nvim-spectre',
  cmd = 'Spectre',
  keys = {
    { '<leader>ss', '<cmd>Spectre<CR>', desc = '[editor] 프로젝트에서 문자열 검색 및 치환' }
  },
  dependencies = {
    'nvim-lua/plenary.nvim'
  },
  config = function()
    require('spectre').setup({
      mapping = {
        ['replace_cmd'] = {
          map = "<leader>rc",
          cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
          desc = "input replace command"
        },
        ['quit'] = {
          map = "<leader>c",
          cmd = "<cmd>close<CR>",
          desc = "닫기"
        },
      }
    })
  end,
}
