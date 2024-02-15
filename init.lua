return {
  colorscheme = 'sonokai',
  options = {
    opt = {
      relativenumber = false,
      tabstop = 2,
      shiftwidth = 2,
   },
  },
  heirline = {
    separators = { breadcrumbs = '  ' },
    attributes = {
      buffer_active = { italic = false, bold = true },
    },
  },
  lsp = {
    formatting = {
      format_on_save = false,
    },
  },
  mappings = {
    [''] = {
      ['c'] = { function()end },
      ['cc'] = { function()end },
      ['o'] = { function()end },
      ['<Tab>'] = { ':norm>><cr>' },
      ['<S-Tab>'] = { ':norm<<<cr>' },
      ['t'] = { function()end },
    },
    x = {
      ['i'] = { [[<Esc>i]] },
    },
    i = {
      ['<Home>'] = { [[<S-Left>]] },
      ['<End>'] = { [[<S-Right>]] },
      ['<C-u>'] = { [[<Esc>:undo<cr>i]] },
      ['<C-r>'] = { [[<Esc>:redo<cr>i]] },
      ['<Tab>'] = { [[<Esc>:norm>><cr>i]] },
      ['<S-Tab>'] = { [[<Esc>:norm<<<cr>i]] },
    },
    n = {
      ['{'] = {
        function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
        desc = "Previous buffer",
      },
      ['}'] = {
        function() require("astronvim.utils.buffer").nav((vim.v.count > 0 and vim.v.count or 1)) end,
        desc = "Next buffer",
      },
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
      ['<leader>rr'] = {
        ':RunCode<cr>',
        desc = 'Code Run Current File'
      },
      ['<leader>rs'] = {
        function()
          function generate_random_string()
            math.randomseed(os.time())
            local charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
            local length = 8
            local random_string = ""
            for _ = 1, length do
              local random_index = math.random(1, #charset)
              random_string = random_string .. charset:sub(random_index, random_index)
            end
            return random_string
          end
          local command = 'lua vim.api.nvim_put({generate_random_string()}, "c", true, true)'
          vim.cmd(command);
          vim.notify('Generated Random String.')
        end,
        desc = 'Generate Random String',
      }
    },
  }
}

