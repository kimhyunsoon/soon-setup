return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { "BufReadPre", "BufNewFile" },
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'lua',
          'javascript',
          'typescript',
          'python',
          'html',
          'css',
          'scss',
          'json',
          'markdown',
          'vue',
          'svelte',
          'java',
          'go',
          'kotlin',
          'swift',
          'rust',
          'c',
          'cpp',
          'sql',
          'bash',
          'dockerfile',
          'xml',
          'yaml',
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(_, buf)
            local max_filesize = 2000 * 1024 -- 2MB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        indent = {
          enable = true,
          disable = function(_, buf)
            local max_filesize = 2000 * 1024 -- 2MB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        autotag = { enable = true },
        incremental_selection = {
          enable = false,
        },
        textobjects = {
          enable = false,
        },
      })
    end,
  }
}
