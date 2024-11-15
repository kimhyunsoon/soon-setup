return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    require("bufferline").setup({
      options = {
        mode = "buffers",
        separator_style = "",
        themable = false,
        always_show_bufferline = true,
        show_buffer_icons = true,
        show_buffer_close_icons = false,
        buffer_close_icon = "",
        diagnostics = false,
        separator = false,
        text_align = "center",
        offsets = {
          {
            filetype = "neo-tree",
            text = "",
            separator = false
          }
        },
        modified_icon = '',
        tab_size = 0,
        padding = 0,
        clickable = true,
      },
      highlights = {
        buffer_selected = {
          fg = "#ffffff",
          bold = true,
          italic = false,
          fg = '#ffffff',
        },
        indicator_selected = {
          fg = '#000000',
        },
        modified = {
          fg = '#888888',
        },
        modified_selected = {
          fg = '#cccccc',
        },
        modified_visible = {
          fg = '#cccccc',
        },
        separator = {
          fg = "#000000",
        },
        separator_selected = {
          fg = "#000000",
        },
      },
    })
  end,
} 