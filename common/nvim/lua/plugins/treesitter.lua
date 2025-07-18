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
        },
        indent = { enable = true },
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
