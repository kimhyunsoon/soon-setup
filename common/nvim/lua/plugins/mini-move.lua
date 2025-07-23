return {
  'echasnovski/mini.move',
  keys = {
    { '<A-h>', mode = 'n', desc = '[editor] 한 줄 왼쪽으로' },
    { '<A-j>', mode = 'n', desc = '[editor] 한 줄 아래로' },
    { '<A-k>', mode = 'n', desc = '[editor] 한 줄 위로' },
    { '<A-l>', mode = 'n', desc = '[editor] 한 줄 오른쪽으로' },
    { '<A-h>', mode = 'v', desc = '[editor] 선택 영역 왼쪽으로' },
    { '<A-j>', mode = 'v', desc = '[editor] 선택 영역 아래로' },
    { '<A-k>', mode = 'v', desc = '[editor] 선택 영역 위로' },
    { '<A-l>', mode = 'v', desc = '[editor] 선택 영역 오른쪽으로' },
  },
  opts = {
    mappings = {
      left = '<A-h>',
      right = '<A-l>',
      down = '<A-j>',
      up = '<A-k>',
      line_left = '<A-h>',
      line_right = '<A-l>',
      line_down = '<A-j>',
      line_up = '<A-k>',
    },
  },
}
