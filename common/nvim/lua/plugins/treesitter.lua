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
          'comment',
          'regex',
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(lang, buf)
            if lang == 'markdown' or lang == 'markdown_inline' then return true end
            return (vim.b[buf].bigfile_tier or 0) >= 2
          end,
        },
        indent = {
          enable = true,
          disable = function(lang, buf)
            if lang == 'markdown' or lang == 'markdown_inline' then return true end
            return (vim.b[buf].bigfile_tier or 0) >= 2
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
