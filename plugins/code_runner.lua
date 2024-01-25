return {
  'CRAG666/code_runner.nvim',
  init = function()
    require('code_runner').setup({
      filetype = {
        javascript = "node",
        typescript = "ts-node",
      },
    })
  end
}
