return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▁' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
        untracked = { text = '▎' },
      },
      signs_staged = {
        add = { text = '▎' },
        change = { text = '▎' },
        delete = { text = '▁' },
        topdelete = { text = '' },
        changedelete = { text = '▎' },
      },
      signs_staged_enable = true,
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol',
        delay = 300,
      },
      current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
    },
    config = function(_, opts)
      require('gitsigns').setup(opts)

      -- 버퍼 진입 시 gitsigns 새로고침
      vim.api.nvim_create_autocmd('BufEnter', {
        callback = function()
          vim.schedule(function()
            pcall(require('gitsigns').refresh)
          end)
        end,
      })
    end,
  },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
    config = true,
  },
  {
    'isakbm/gitgraph.nvim',
    cmd = 'GitGraph',
    keys = { '<leader>gg' },
    opts = {
      symbols = {
        merge_commit = '',
        commit = '',
        merge_commit_end = '',
        commit_end = '',
      },
      format = {
        timestamp = '%Y-%m-%d %H:%M',
        fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
      },
      colors = {
        branch1 = '#ff7575',
      },
      hooks = {
        on_select_commit = function(commit)
          vim.fn.setreg('+', commit.hash)
        end,
      },
    },
  },
}
