return {
  'akinsho/bufferline.nvim',
  version = '*',
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    local p = require('soontheme')
    require('bufferline').setup({
      options = {
        mode = 'buffers',
        separator_style = { '', '' },
        themable = false,
        always_show_bufferline = true,
        show_buffer_icons = true,
        show_buffer_close_icons = false,
        indicator = { style = 'none' },
        buffer_close_icon = '',
        diagnostics = true,
        separator = false,
        text_align = 'center',
        offsets = {
          {
            filetype = 'neo-tree',
            text = '',
            separator = false
          }
        },
        modified_icon = '',
        padding = 0,
        clickable = true,
      },
      highlights = {
        buffer_selected = {
          fg = p.white,
          bold = true,
          italic = false,
        },
        indicator_selected = {
          fg = p.black,
        },
        modified = {
          fg = p.grey,
        },
        modified_selected = {
          fg = p.orange,
        },
        modified_visible = {
          fg = p.orange,
        },
      },
    })
    vim.api.nvim_create_autocmd('BufEnter', {
      pattern = { '[No Name]' },
      callback = function()
        if vim.bo.buftype == '' then
          vim.cmd('bdelete')
        end
      end
    })
  end,
}
