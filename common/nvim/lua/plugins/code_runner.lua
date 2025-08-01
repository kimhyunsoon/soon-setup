return {
  'CRAG666/code_runner.nvim',
  cmd = 'RunCode',
  keys = { '<leader>rr' },
  config = function()
    require('code_runner').setup({
      filetype = {
        javascript = 'node',
        typescript = 'ts-node',
        python = 'python3',
        lua = 'lua',
      },
    })
  end,
}
