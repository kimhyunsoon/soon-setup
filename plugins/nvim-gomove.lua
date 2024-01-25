return {
  'booperlv/nvim-gomove',
  init = function()
    local map = vim.api.nvim_set_keymap;
    map( "x", "<C-h>", "<Plug>GoVMLineLeft", {} )
    map( "x", "<C-j>", "<Plug>GoVMLineDown", {} )
    map( "x", "<C-k>", "<Plug>GoVMLineUp", {} )
    map( "x", "<C-l>", "<Plug>GoVMLineRight", {} )

    require("gomove").setup {
      map_defaults = false,
      reindent = false,
      undojoin = false,
      move_past_end_col = true,
    }
  end,
}
