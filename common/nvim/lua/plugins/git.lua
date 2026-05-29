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
      max_file_length = 40000,
    },
    config = function(_, opts)
      require('gitsigns').setup(opts)

      -- 버퍼 진입 시 gitsigns 새로고침 (tier 2 이상에서는 건너뜀)
      vim.api.nvim_create_autocmd('BufEnter', {
        callback = function(args)
          if (vim.b[args.buf].bigfile_tier or 0) >= 2 then return end
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
}
