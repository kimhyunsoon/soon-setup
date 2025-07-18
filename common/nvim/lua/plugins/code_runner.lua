return {
  'CRAG666/code_runner.nvim',
  init = function()
    require('code_runner').setup({
      filetype = {
        javascript = 'node',
        typescript = 'ts-node',
        python = 'python3',
        c = 'cd $dir && gcc $fileName -o /tmp/$fileNameWithoutExt && /tmp/$fileNameWithoutExt',
      },
      mode = 'term',
      focus = false,
    })
  end
}
