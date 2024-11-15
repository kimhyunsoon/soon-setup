local colors = {
  red    = '#FF6077',
  blue   = '#85D3F2',
  green  = '#A7DF78',
  violet = '#d183e8',
  yellow = '#F5D16C',
  white  = '#FFFFFF',
  grey   = '#2a2a2a',
  light_grey = '#cccccc',
  black  = '#000000',
  transparent  = '#00000000',
}

local bubbles_theme = {
  normal = {
    a = { fg = colors.black, bg = colors.green },
    b = { fg = colors.white, bg = colors.grey },
    c = { fg = colors.white, bg = colors.transparent },
  },

  insert = { a = { fg = colors.black, bg = colors.blue } },
  visual = { a = { fg = colors.black, bg = colors.red } },
  replace = { a = { fg = colors.black, bg = colors.violet } },

  inactive = {
    a = { fg = colors.white, bg = colors.black },
    b = { fg = colors.white, bg = colors.black },
    c = { fg = colors.black, bg = colors.black },
  },
}
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = bubbles_theme,
        component_separators = '',
        section_separators = { left = '', right = '' },
        globalstatus = true,
        ignore_focus = {},
      },
      sections = {
        lualine_a = {
          {
            'mode',
            separator = { left = '' },
            fmt = function(str) return str:sub(1,1) .. ' ' end,
          },
        },
        lualine_b = {
          {
            'branch',
            icon = ' ',
            separator = { right = ' ' },
          },
        },
        lualine_c = {
          {
            'diff',
            symbols = { added = ' ', modified = '󰏬 ', removed = ' ' },
            diff_color = {
              added = { fg = colors.green },
              modified = { fg = colors.blue },
              removed = { fg = colors.red },
            },
          },
          {
            'searchcount',
            maxcount = 999,
            timeout = 500,
          },
        },
        lualine_x = {
          {
            function()
              local mode = vim.fn.mode()
              if mode == 'v' or mode == 'V' or mode == '' then
                local start_line = vim.fn.line('v')
                local current_line = vim.fn.line('.')
                local line_count = math.abs(current_line - start_line) + 1
                local start_pos = vim.fn.getpos('v')
                local end_pos = vim.fn.getpos('.')
                local lines = vim.api.nvim_buf_get_text(
                  0,
                  math.min(start_pos[2] - 1, end_pos[2] - 1),
                  math.min(start_pos[3] - 1, end_pos[3] - 1),
                  math.max(start_pos[2] - 1, end_pos[2] - 1),
                  math.max(start_pos[3] - 1, end_pos[3] - 1),
                  {}
                )
                local char_count = 0
                for _, line in ipairs(lines) do
                  char_count = char_count + vim.fn.strchars(line)
                end
                return string.format('[%d/%d]', line_count, char_count)
              end
              return ''
            end,
            color = { fg = '#ffffff' },
          },
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
          },
          {
            'filesize',
            icon = '󰈔',
            color = { fg = colors.light_grey },
          },
        },
        lualine_y = {
          {
            'filetype',
            separator = { left = ' ' },
          },
        },
        lualine_z = {
          {
            'datetime',
            style = '%H:%M:%S',
            separator = { right = '' },
          },
        },
      },
      inactive_sections = {
        lualine_a = { 'filename' },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { 'location' },
      },
      tabline = {},
      extensions = {},
    },
  },
}
