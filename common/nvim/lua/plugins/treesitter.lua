return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = { "BufReadPre", "BufNewFile" },
    build = ':TSUpdate',
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(args)
          vim.treesitter.stop(args.buf)
        end,
      })

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
          'styled',
          'jsdoc',
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(lang, buf)
            if lang == "markdown" or lang == "markdown_inline" then
              return true
            end
            local max_filesize = 2000 * 1024 -- 2MB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        indent = {
          enable = true,
          disable = function(lang, buf)
            if lang == "markdown" or lang == "markdown_inline" then
              return true
            end
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
