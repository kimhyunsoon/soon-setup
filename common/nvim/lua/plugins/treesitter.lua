return {
  {
    'nvim-treesitter/nvim-treesitter',
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
        highlight = { enable = true },
        indent = { enable = true },
        autotag = { enable = true },
      })
    end,
  }
}
