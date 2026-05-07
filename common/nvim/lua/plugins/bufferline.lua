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
          fg = p.white,
        },
        modified_visible = {
          fg = p.white,
        },
      },
    })
    -- 저장 시점의 해시를 저장하고, 유휴 시 비교하여 modified 플래그 해제
    vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
      callback = function()
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        vim.b.saved_hash = vim.fn.sha256(table.concat(lines, '\n'))
      end,
    })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'InsertLeave' }, {
      callback = function()
        if not vim.bo.modified or not vim.b.saved_hash then return end
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        if vim.fn.sha256(table.concat(lines, '\n')) == vim.b.saved_hash then
          vim.bo.modified = false
        end
      end,
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
