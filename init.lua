return {
  colorscheme = 'sonokai',
  options = {
    opt = {
      relativenumber = false,
    },
  }, 
  lsp = {
    formatting = {
      format_on_save = false,
    },
  },
  mappings = {
    n = {
      ['<leader>yp'] = {
        function()
          local command = 'let @+ = expand("%:p")'
          vim.cmd(command)
          vim.notify('Copied "' .. vim.fn.expand('%:p') .. '" to the clipboard!')
        end,
        desc = 'Copy Full Path',
      },
      ['<leader>fo'] = {
        ':!open %:p<cr><cr>',
        desc = 'Open File',
      },
    },
  }
}

