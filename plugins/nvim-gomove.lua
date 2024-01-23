return {
  'booperlv/nvim-gomove',
    init = function()
    local map = vim.api.nvim_set_keymap;
    map( "x", "<C-h>", "<Plug>GoVSMLeft", {} )
    map( "x", "<C-j>", "<Plug>GoVSMDown", {} )
    map( "x", "<C-k>", "<Plug>GoVSMUp", {} )
    map( "x", "<C-l>", "<Plug>GoVSMRight", {} )

    require("gomove").setup {
      map_defaults = false,
      reindent = true,
      undojoin = true,
      move_past_end_col = false,
    }
  end,
}
