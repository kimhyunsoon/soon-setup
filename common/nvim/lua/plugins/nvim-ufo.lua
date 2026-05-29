return {
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      vim.o.foldcolumn = '0'
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      require('ufo').setup({
        provider_selector = function(bufnr, filetype)
          if (vim.b[bufnr].bigfile_tier or 0) >= 2 then return '' end
          if filetype == 'markdown' then
            return { 'indent' }
          end
          return { 'treesitter', 'indent' }
        end
      })
    end,
  },
}
