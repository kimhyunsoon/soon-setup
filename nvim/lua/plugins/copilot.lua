return {
  {
    'zbirenbaum/copilot-cmp',
    dependencies = {
      'zbirenbaum/copilot.lua',
    },
    config = function()
      require('copilot').setup({
        suggestion = { enabled = true },
        panel = { enabled = true },
      })
      require('copilot_cmp').setup()
    end
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
    },
    -- Only on MacOS or Linux
    build = 'make tiktoken',
    opts = {
      chat_autocomplete = false,
      model = 'claude-3.5-sonnet',
      question_header = '󰚩 soon',
      answer_header = ' copilot',
      auto_insert_mode = true,
      show_folds = false,
      -- 아래 코드 현재버전에서 에러남.
      -- show_help = false,
      window = {
        title = '',
        layout = 'float',
        relative = 'cursor',
        width = 0.5,
        height = 0.4,
        row = 1
      },
      mappings = {
        reset = {
          normal = '<Leader>r',
        },
        accept_diff = {
          normal = '<Leader>y',
        },
      },
    },
  },
}
