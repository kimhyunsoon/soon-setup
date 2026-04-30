local M = {
  fg       = '#f0f0f0',
  red      = '#ed5f5f',
  orange   = '#f0b472',
  yellow   = '#f2da7a',
  green    = '#7edd8a',
  blue     = '#7ad2f0',
  purple   = '#b898de',
  grey     = '#8c939a',
  grey_dim = '#636b75',
  black    = '#1b2a34',
  white    = '#ffffff',
  bg0      = '#1e2228',
  bg1      = '#252a31',
  bg2      = '#2c323a',
  bg3      = '#343b44',
  bg4      = '#3d454f',
  bg_red   = '#3d2020',
  bg_yellow = '#3d3520',
  bg_green = '#203d28',
  bg_blue  = '#20303d',
  bg_purple = '#302040',
  filled_red   = '#ed5f5f',
  filled_green = '#7edd8a',
  filled_blue  = '#7ad2f0',
  none     = 'NONE',
}

-- 하이라이트 적용
function M.apply()
  vim.g.colors_name = 'soontheme'
  vim.opt.termguicolors = true

  local hi = vim.api.nvim_set_hl
  local c = M

  -- 에디터 UI
  hi(0, 'Normal',       { fg = c.fg, bg = c.none })
  hi(0, 'NormalNC',     { fg = c.fg, bg = c.none })
  hi(0, 'NormalFloat',  { fg = c.fg, bg = c.none })
  hi(0, 'Terminal',     { fg = c.fg, bg = c.none })
  hi(0, 'EndOfBuffer',  { fg = c.bg4, bg = c.none })
  hi(0, 'Folded',       { fg = c.grey, bg = c.none })
  hi(0, 'FoldColumn',   { fg = c.grey_dim, bg = c.none })
  hi(0, 'SignColumn',   { fg = c.fg, bg = c.none })
  hi(0, 'ToolbarLine',  { fg = c.fg, bg = c.none })
  hi(0, 'FloatBorder',  { fg = c.grey, bg = c.none })
  hi(0, 'FloatTitle',   { fg = c.red, bg = c.bg4, bold = true })
  hi(0, 'Cursor',       { reverse = true })
  hi(0, 'vCursor',      { link = 'Cursor' })
  hi(0, 'iCursor',      { link = 'Cursor' })
  hi(0, 'lCursor',      { link = 'Cursor' })
  hi(0, 'CursorIM',     { link = 'Cursor' })
  hi(0, 'CursorLine',   { bg = c.bg1 })
  hi(0, 'CursorColumn', { bg = c.bg1 })
  hi(0, 'LineNr',       { fg = c.grey_dim, bg = c.none })
  hi(0, 'CursorLineNr', { fg = c.fg, bg = c.none })
  hi(0, 'ColorColumn',  { bg = c.bg1 })
  hi(0, 'Conceal',      { fg = c.grey_dim, bg = c.none })

  -- 선택/검색
  hi(0, 'Visual',       { bg = c.bg4 })
  hi(0, 'VisualNOS',    { bg = c.bg4, underline = true })
  hi(0, 'IncSearch',    { fg = c.bg0, bg = c.filled_red })
  hi(0, 'CurSearch',    { link = 'IncSearch' })
  hi(0, 'Search',       { fg = c.bg0, bg = c.filled_green })
  hi(0, 'Substitute',   { fg = c.bg0, bg = c.yellow })
  hi(0, 'MatchParen',   { bg = c.bg4 })

  -- Diff
  hi(0, 'DiffAdd',      { bg = c.bg_green })
  hi(0, 'DiffChange',   { bg = c.bg_blue })
  hi(0, 'DiffDelete',   { bg = c.bg_red })
  hi(0, 'DiffText',     { fg = c.bg0, bg = c.blue })

  -- 팝업 메뉴
  hi(0, 'Pmenu',        { fg = c.fg, bg = c.none })
  hi(0, 'PmenuSbar',    { bg = c.none })
  hi(0, 'PmenuSel',     { fg = c.bg0, bg = c.filled_blue })
  hi(0, 'PmenuKind',    { fg = c.green, bg = c.none })
  hi(0, 'PmenuExtra',   { fg = c.grey, bg = c.none })
  hi(0, 'PmenuThumb',   { bg = c.grey })
  hi(0, 'WildMenu',     { link = 'PmenuSel' })

  -- 상태바/탭바
  hi(0, 'StatusLine',       { fg = c.fg, bg = c.none })
  hi(0, 'StatusLineTerm',   { fg = c.fg, bg = c.none })
  hi(0, 'StatusLineNC',     { fg = c.grey, bg = c.none })
  hi(0, 'StatusLineTermNC', { fg = c.grey, bg = c.none })
  hi(0, 'TabLine',          { fg = c.fg, bg = c.bg4 })
  hi(0, 'TabLineFill',      { fg = c.grey, bg = c.none })
  hi(0, 'TabLineSel',       { fg = c.bg0, bg = c.filled_red })
  hi(0, 'WinBar',           { fg = c.fg, bg = c.none, bold = true })
  hi(0, 'WinBarNC',         { fg = c.grey, bg = c.none })
  hi(0, 'VertSplit',        { fg = c.black, bg = c.none })
  hi(0, 'WinSeparator',     { link = 'VertSplit' })

  -- 메시지
  hi(0, 'ErrorMsg',     { fg = c.red, bg = c.none, bold = true, underline = true })
  hi(0, 'WarningMsg',   { fg = c.yellow, bg = c.none, bold = true })
  hi(0, 'ModeMsg',      { fg = c.fg, bg = c.none, bold = true })
  hi(0, 'MoreMsg',      { fg = c.blue, bg = c.none, bold = true })
  hi(0, 'Question',     { fg = c.yellow, bg = c.none })

  -- 디렉토리/특수
  hi(0, 'Directory',    { fg = c.green, bg = c.none })
  hi(0, 'NonText',      { fg = c.bg4, bg = c.none })
  hi(0, 'Whitespace',   { fg = c.bg4, bg = c.none })
  hi(0, 'SpecialKey',   { fg = c.purple, bg = c.none })
  hi(0, 'QuickFixLine', { fg = c.blue, bg = c.none, bold = true })
  hi(0, 'Debug',        { fg = c.yellow, bg = c.none })
  hi(0, 'debugPC',      { fg = c.bg0, bg = c.green })
  hi(0, 'debugBreakpoint', { fg = c.bg0, bg = c.red })
  hi(0, 'ToolbarButton',   { fg = c.bg0, bg = c.filled_blue })

  -- 스펠
  hi(0, 'SpellBad',     { undercurl = true, sp = c.red })
  hi(0, 'SpellCap',     { undercurl = true, sp = c.yellow })
  hi(0, 'SpellLocal',   { undercurl = true, sp = c.blue })
  hi(0, 'SpellRare',    { undercurl = true, sp = c.purple })

  -- 구문 강조
  hi(0, 'Comment',        { fg = c.grey, bg = c.none })
  hi(0, 'SpecialComment', { fg = c.grey, bg = c.none })
  hi(0, 'Todo',           { fg = c.bg0, bg = c.blue, bold = true })
  hi(0, 'String',         { fg = c.yellow, bg = c.none })
  hi(0, 'Character',      { fg = c.yellow, bg = c.none })
  hi(0, 'Number',         { fg = c.purple, bg = c.none })
  hi(0, 'Float',          { fg = c.purple, bg = c.none })
  hi(0, 'Boolean',        { fg = c.purple, bg = c.none })
  hi(0, 'Constant',       { fg = c.orange, bg = c.none })
  hi(0, 'Identifier',     { fg = c.orange, bg = c.none })
  hi(0, 'Function',       { fg = c.green, bg = c.none })
  hi(0, 'Statement',      { fg = c.red, bg = c.none })
  hi(0, 'Conditional',    { fg = c.red, bg = c.none })
  hi(0, 'Repeat',         { fg = c.red, bg = c.none })
  hi(0, 'Label',          { fg = c.purple, bg = c.none })
  hi(0, 'Operator',       { fg = c.red, bg = c.none })
  hi(0, 'Keyword',        { fg = c.red, bg = c.none })
  hi(0, 'Exception',      { fg = c.red, bg = c.none })
  hi(0, 'PreProc',        { fg = c.red, bg = c.none })
  hi(0, 'PreCondit',      { fg = c.red, bg = c.none })
  hi(0, 'Include',        { fg = c.red, bg = c.none })
  hi(0, 'Define',         { fg = c.red, bg = c.none })
  hi(0, 'Macro',          { fg = c.purple, bg = c.none })
  hi(0, 'Type',           { fg = c.blue, bg = c.none })
  hi(0, 'Structure',      { fg = c.blue, bg = c.none })
  hi(0, 'StorageClass',   { fg = c.blue, bg = c.none })
  hi(0, 'Typedef',        { fg = c.red, bg = c.none })
  hi(0, 'Special',        { fg = c.purple, bg = c.none })
  hi(0, 'SpecialChar',    { fg = c.purple, bg = c.none })
  hi(0, 'Tag',            { fg = c.orange, bg = c.none })
  hi(0, 'Delimiter',      { fg = c.fg, bg = c.none })
  hi(0, 'Title',          { fg = c.red, bg = c.none, bold = true })
  hi(0, 'Error',          { fg = c.red, bg = c.none })
  hi(0, 'Ignore',         { fg = c.grey, bg = c.none })
  hi(0, 'Underlined',     { underline = true })

  -- 유틸 하이라이트
  hi(0, 'Fg',          { fg = c.fg, bg = c.none })
  hi(0, 'Grey',        { fg = c.grey, bg = c.none })
  hi(0, 'Red',         { fg = c.red, bg = c.none })
  hi(0, 'Orange',      { fg = c.orange, bg = c.none })
  hi(0, 'Yellow',      { fg = c.yellow, bg = c.none })
  hi(0, 'Green',       { fg = c.green, bg = c.none })
  hi(0, 'Blue',        { fg = c.blue, bg = c.none })
  hi(0, 'Purple',      { fg = c.purple, bg = c.none })
  hi(0, 'RedSign',     { fg = c.red, bg = c.none })
  hi(0, 'OrangeSign',  { fg = c.orange, bg = c.none })
  hi(0, 'YellowSign',  { fg = c.yellow, bg = c.none })
  hi(0, 'GreenSign',   { fg = c.green, bg = c.none })
  hi(0, 'BlueSign',    { fg = c.blue, bg = c.none })
  hi(0, 'PurpleSign',  { fg = c.purple, bg = c.none })
  hi(0, 'Added',       { link = 'Green' })
  hi(0, 'Removed',     { link = 'Red' })
  hi(0, 'Changed',     { link = 'Blue' })
  hi(0, 'CurrentWord', { bg = c.bg2 })
  hi(0, 'ErrorText',      { undercurl = true, sp = c.red })
  hi(0, 'WarningText',    { undercurl = true, sp = c.yellow })
  hi(0, 'InfoText',       { undercurl = true, sp = c.blue })
  hi(0, 'HintText',       { undercurl = true, sp = c.purple })
  hi(0, 'ErrorFloat',     { fg = c.red, bg = c.none })
  hi(0, 'WarningFloat',   { fg = c.yellow, bg = c.none })
  hi(0, 'InfoFloat',      { fg = c.blue, bg = c.none })
  hi(0, 'HintFloat',      { fg = c.purple, bg = c.none })
  hi(0, 'OkFloat',        { fg = c.green, bg = c.none })
  hi(0, 'InlayHints',     { link = 'LineNr' })
  hi(0, 'VirtualTextWarning', { link = 'Grey' })
  hi(0, 'VirtualTextError',   { link = 'Grey' })
  hi(0, 'VirtualTextInfo',    { link = 'Grey' })
  hi(0, 'VirtualTextHint',    { link = 'Grey' })
  hi(0, 'VirtualTextOk',      { link = 'Grey' })

  -- 진단
  hi(0, 'DiagnosticError',          { fg = c.red, bg = c.none })
  hi(0, 'DiagnosticWarn',           { fg = c.yellow, bg = c.none })
  hi(0, 'DiagnosticInfo',           { fg = c.blue, bg = c.none })
  hi(0, 'DiagnosticHint',           { fg = c.purple, bg = c.none })
  hi(0, 'DiagnosticOk',             { fg = c.green, bg = c.none })
  hi(0, 'DiagnosticUnderlineError', { undercurl = true, sp = c.red })
  hi(0, 'DiagnosticUnderlineWarn',  { undercurl = true, sp = c.yellow })
  hi(0, 'DiagnosticUnderlineInfo',  { undercurl = true, sp = c.blue })
  hi(0, 'DiagnosticUnderlineHint',  { undercurl = true, sp = c.purple })
  hi(0, 'DiagnosticUnderlineOk',    { undercurl = true, sp = c.green })
  hi(0, 'DiagnosticFloatingError',  { link = 'ErrorFloat' })
  hi(0, 'DiagnosticFloatingWarn',   { link = 'WarningFloat' })
  hi(0, 'DiagnosticFloatingInfo',   { link = 'InfoFloat' })
  hi(0, 'DiagnosticFloatingHint',   { link = 'HintFloat' })
  hi(0, 'DiagnosticFloatingOk',     { link = 'OkFloat' })
  hi(0, 'DiagnosticVirtualTextError', { link = 'VirtualTextError' })
  hi(0, 'DiagnosticVirtualTextWarn',  { link = 'VirtualTextWarning' })
  hi(0, 'DiagnosticVirtualTextInfo',  { link = 'VirtualTextInfo' })
  hi(0, 'DiagnosticVirtualTextHint',  { link = 'VirtualTextHint' })
  hi(0, 'DiagnosticVirtualTextOk',    { link = 'VirtualTextOk' })
  hi(0, 'DiagnosticSignError',        { link = 'RedSign' })
  hi(0, 'DiagnosticSignWarn',         { link = 'YellowSign' })
  hi(0, 'DiagnosticSignInfo',         { link = 'BlueSign' })
  hi(0, 'DiagnosticSignHint',         { link = 'PurpleSign' })
  hi(0, 'DiagnosticSignOk',           { link = 'GreenSign' })

  -- Treesitter
  hi(0, '@variable',             { link = 'Fg' })
  hi(0, '@variable.builtin',    { fg = c.purple })
  hi(0, '@variable.parameter',  { link = 'Fg' })
  hi(0, '@variable.member',     { fg = c.orange })
  hi(0, '@constant',            { link = 'Fg' })
  hi(0, '@constant.builtin',    { fg = c.purple })
  hi(0, '@constant.macro',      { fg = c.purple })
  hi(0, '@module',              { fg = c.blue })
  hi(0, '@string',              { link = 'Yellow' })
  hi(0, '@string.escape',       { link = 'Green' })
  hi(0, '@string.regexp',       { link = 'Green' })
  hi(0, '@string.special',      { link = 'SpecialChar' })
  hi(0, '@character',           { link = 'Yellow' })
  hi(0, '@character.special',   { link = 'SpecialChar' })
  hi(0, '@boolean',             { link = 'Purple' })
  hi(0, '@number',              { link = 'Purple' })
  hi(0, '@number.float',        { link = 'Purple' })
  hi(0, '@type',                { fg = c.blue })
  hi(0, '@type.builtin',        { fg = c.blue })
  hi(0, '@type.definition',     { fg = c.blue })
  hi(0, '@type.qualifier',      { link = 'Red' })
  hi(0, '@attribute',           { fg = c.blue })
  hi(0, '@property',            { fg = c.orange })
  hi(0, '@function',            { link = 'Green' })
  hi(0, '@function.builtin',    { link = 'Green' })
  hi(0, '@function.macro',      { link = 'Green' })
  hi(0, '@function.call',       { link = 'Green' })
  hi(0, '@function.method',     { link = 'Green' })
  hi(0, '@function.method.call', { link = 'Green' })
  hi(0, '@constructor',         { link = 'Green' })
  hi(0, '@operator',            { link = 'Red' })
  hi(0, '@keyword',             { link = 'Red' })
  hi(0, '@keyword.function',    { link = 'Red' })
  hi(0, '@keyword.operator',    { link = 'Red' })
  hi(0, '@keyword.return',      { link = 'Red' })
  hi(0, '@keyword.import',      { link = 'Red' })
  hi(0, '@keyword.repeat',      { link = 'Red' })
  hi(0, '@keyword.conditional', { link = 'Red' })
  hi(0, '@keyword.exception',   { link = 'Red' })
  hi(0, '@keyword.storage',     { link = 'Red' })
  hi(0, '@punctuation.bracket',   { link = 'Grey' })
  hi(0, '@punctuation.delimiter', { link = 'Grey' })
  hi(0, '@punctuation.special',   { link = 'Yellow' })
  hi(0, '@comment',             { link = 'Comment' })
  hi(0, '@comment.todo',        { link = 'Todo' })
  hi(0, '@comment.note',        { fg = c.bg0, bg = c.green, bold = true })
  hi(0, '@comment.warning',     { fg = c.bg0, bg = c.yellow, bold = true })
  hi(0, '@comment.error',       { fg = c.bg0, bg = c.red, bold = true })
  hi(0, '@markup.strong',       { bold = true })
  hi(0, '@markup.emphasis',     { bold = true })
  hi(0, '@markup.underline',    { underline = true })
  hi(0, '@markup.strike',       { link = 'Grey' })
  hi(0, '@markup.heading',      { link = 'Title' })
  hi(0, '@markup.link',         { link = 'Constant' })
  hi(0, '@markup.link.url',     { fg = c.blue, underline = true })
  hi(0, '@markup.raw',          { link = 'String' })
  hi(0, '@markup.math',         { link = 'Yellow' })
  hi(0, '@tag',                 { fg = c.blue })
  hi(0, '@tag.attribute',       { link = 'Green' })
  hi(0, '@tag.delimiter',       { link = 'Red' })
  hi(0, '@label',               { link = 'Red' })

  -- LSP semantic tokens
  hi(0, '@lsp.type.class',         { link = '@type' })
  hi(0, '@lsp.type.decorator',     { link = '@attribute' })
  hi(0, '@lsp.type.enum',          { link = '@type' })
  hi(0, '@lsp.type.enumMember',    { link = 'Purple' })
  hi(0, '@lsp.type.function',      { link = '@function' })
  hi(0, '@lsp.type.interface',     { link = '@type' })
  hi(0, '@lsp.type.macro',         { link = '@function.macro' })
  hi(0, '@lsp.type.method',        { link = '@function.method' })
  hi(0, '@lsp.type.namespace',     { link = '@module' })
  hi(0, '@lsp.type.parameter',     { link = '@variable.parameter' })
  hi(0, '@lsp.type.property',      { link = '@property' })
  hi(0, '@lsp.type.struct',        { link = '@type' })
  hi(0, '@lsp.type.type',          { link = '@type' })
  hi(0, '@lsp.type.typeParameter', { link = '@type' })
  hi(0, '@lsp.type.variable',      { link = '@variable' })

  -- gitsigns
  hi(0, 'GitSignsAdd',              { link = 'GreenSign' })
  hi(0, 'GitSignsChange',           { link = 'BlueSign' })
  hi(0, 'GitSignsDelete',           { link = 'RedSign' })
  hi(0, 'GitSignsAddNr',            { link = 'Green' })
  hi(0, 'GitSignsChangeNr',         { link = 'Blue' })
  hi(0, 'GitSignsDeleteNr',         { link = 'Red' })
  hi(0, 'GitSignsAddLn',            { link = 'DiffAdd' })
  hi(0, 'GitSignsChangeLn',         { link = 'DiffChange' })
  hi(0, 'GitSignsDeleteLn',         { link = 'DiffDelete' })
  hi(0, 'GitSignsCurrentLineBlame', { link = 'Grey' })

  -- telescope
  hi(0, 'TelescopeMatching',     { fg = c.green, bold = true })
  hi(0, 'TelescopeBorder',       { link = 'Grey' })
  hi(0, 'TelescopePromptPrefix', { link = 'Blue' })
  hi(0, 'TelescopeSelection',    { link = 'DiffAdd' })

  -- nvim-cmp
  hi(0, 'CmpNormal',             { fg = c.fg, bg = c.none })
  hi(0, 'CmpBorder',             { fg = c.grey_dim, bg = c.none })
  hi(0, 'CmpItemAbbrMatch',      { fg = c.green, bold = true })
  hi(0, 'CmpItemAbbrMatchFuzzy', { fg = c.green, bold = true })
  hi(0, 'CmpItemAbbr',           { link = 'Fg' })
  hi(0, 'CmpItemAbbrDeprecated', { link = 'Grey' })
  hi(0, 'CmpItemMenu',           { link = 'Fg' })
  hi(0, 'CmpItemKind',           { link = 'Blue' })
  hi(0, 'CmpItemKindText',        { fg = c.fg })
  hi(0, 'CmpItemKindKeyword',     { fg = c.purple })
  hi(0, 'CmpItemKindConstant',    { fg = c.fg })
  hi(0, 'CmpItemKindFunction',    { fg = c.blue })
  hi(0, 'CmpItemKindMethod',      { fg = c.red })
  hi(0, 'CmpItemKindConstructor', { fg = c.red })
  hi(0, 'CmpItemKindClass',       { fg = c.red })
  hi(0, 'CmpItemKindInterface',   { fg = c.blue })
  hi(0, 'CmpItemKindModule',      { fg = c.red })
  hi(0, 'CmpItemKindProperty',    { fg = c.grey })
  hi(0, 'CmpItemKindVariable',    { fg = c.fg })
  hi(0, 'CmpItemKindField',       { fg = c.grey })
  hi(0, 'CmpItemKindSnippet',     { fg = c.purple })
  hi(0, 'CmpItemKindFile',        { fg = c.green })
  hi(0, 'CmpItemKindFolder',      { fg = c.green })
  hi(0, 'CmpItemKindCopilot',     { fg = c.purple })

  -- indent-blankline
  hi(0, 'IblScope',  { fg = c.grey, nocombine = true })
  hi(0, 'IblIndent', { fg = c.bg4, nocombine = true })
  hi(0, 'IndentBlanklineContextChar', { link = 'IblScope' })
  hi(0, 'IndentBlanklineChar',        { link = 'IblIndent' })

  -- nvim-notify
  hi(0, 'NotifyBackground',  { bg = c.bg0 })
  hi(0, 'NotifyERRORBorder', { link = 'Red' })
  hi(0, 'NotifyWARNBorder',  { link = 'Yellow' })
  hi(0, 'NotifyINFOBorder',  { link = 'Green' })
  hi(0, 'NotifyDEBUGBorder', { link = 'Grey' })
  hi(0, 'NotifyTRACEBorder', { link = 'Purple' })

  -- rainbow-delimiters
  hi(0, 'RainbowDelimiterRed',    { link = 'Red' })
  hi(0, 'RainbowDelimiterOrange', { link = 'Orange' })
  hi(0, 'RainbowDelimiterYellow', { link = 'Yellow' })
  hi(0, 'RainbowDelimiterGreen',  { link = 'Green' })
  hi(0, 'RainbowDelimiterCyan',   { link = 'Blue' })
  hi(0, 'RainbowDelimiterBlue',   { link = 'Blue' })
  hi(0, 'RainbowDelimiterViolet', { link = 'Purple' })

  -- treesitter-context
  hi(0, 'TreesitterContext', { fg = c.fg, bg = c.bg2 })

  -- neo-tree
  hi(0, 'NeoTreeDirectoryIcon', { fg = c.blue })
  hi(0, 'NeoTreeDirectoryName', { fg = c.green })
  hi(0, 'NeoTreeRootName',      { fg = c.red, bold = true })

  -- 터미널 ANSI 색상
  vim.g.terminal_color_0  = c.black
  vim.g.terminal_color_1  = c.red
  vim.g.terminal_color_2  = c.green
  vim.g.terminal_color_3  = c.yellow
  vim.g.terminal_color_4  = c.blue
  vim.g.terminal_color_5  = c.purple
  vim.g.terminal_color_6  = c.orange
  vim.g.terminal_color_7  = c.fg
  vim.g.terminal_color_8  = c.grey
  vim.g.terminal_color_9  = c.red
  vim.g.terminal_color_10 = c.green
  vim.g.terminal_color_11 = c.yellow
  vim.g.terminal_color_12 = c.blue
  vim.g.terminal_color_13 = c.purple
  vim.g.terminal_color_14 = c.orange
  vim.g.terminal_color_15 = c.fg
end

return M
