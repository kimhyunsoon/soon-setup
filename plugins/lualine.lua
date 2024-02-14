local colors = {
  red    = '#FF6077',
  blue   = '#85D3F2',
  green  = '#A7DF78', 
  violet = '#d183e8',
  yellow = '#F5D16C',
  grey   = '#333333',
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

local config = {
  options = {
    theme = bubbles_theme,
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {
      {
        'mode',
        separator = { left = '' },
        fmt = function(str) return str:sub(1,1) end,
      },
    },
    lualine_b = {
      {
        'branch',
        icon = '',
      },
    },
    lualine_c = {
      {
        'diff',
        symbols = { added = ' ', modified = '󰏬 ', removed = ' ' },
        diff_color = {
          added = { fg = colors.cyan },
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
       'diagnostics',
        sources = { 'nvim_diagnostic' },
        symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      },
      {
        'filesize',
      },
    },
    lualine_y = {
      {
        'filetype',
        icon = { align = 'left' },
      },
    },
    lualine_z = {
      {
      'datetime',
        style = '%H:%M:%S',
        separator = { right = '' },
        left_padding = 2,
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
}
return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = config,
  },
  {
    "rebelot/heirline.nvim",
    optional = true,
    opts = function(_, opts) opts.statusline = nil end,
  },
}
