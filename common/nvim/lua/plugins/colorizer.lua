return {
  'norcalli/nvim-colorizer.lua',
  event = { 'BufReadPost', 'BufNewFile' },
  ft = { 'css', 'scss', 'html', 'javascript', 'typescript', 'vue', 'svelte' },
  config = function()
    require('colorizer').setup()
  end,
}
