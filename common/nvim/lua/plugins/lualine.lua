local p = require('soontheme')
local colors = {
  red    = p.filled_red,
  blue   = p.filled_blue,
  green  = p.filled_green,
  violet = p.purple,
  yellow = p.yellow,
  white  = p.white,
  grey   = p.bg0,
  light_grey = p.orange,
  black  = p.black,
  transparent  = p.none,
}

local function setup_symbol_highlights()
  local symbol_colors = {
    function_declaration = colors.blue,
    function_definition = colors.blue,
    function_item = colors.blue,
    ['function'] = colors.blue,
    arrow_function = colors.blue,
    function_expression = colors.blue,
    lexical_declaration = colors.blue,
    variable_declarator = colors.blue,
    method_declaration = colors.green,
    method_definition = colors.green,
    method = colors.green,
    class_declaration = colors.yellow,
    class_definition = colors.yellow,
    ['class'] = colors.yellow,
    interface_declaration = colors.violet,
    type_alias_declaration = colors.violet,
    type_declaration = colors.violet,
    struct_item = colors.yellow,
    enum_declaration = colors.yellow,
    enum_item = colors.yellow,
  }

  for node_type, color in pairs(symbol_colors) do
    local hl_name = 'LualineSymbol' .. node_type:gsub('_', '')
    vim.api.nvim_set_hl(0, hl_name, { fg = color, bg = 'NONE' })
  end
end

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = setup_symbol_highlights,
})
setup_symbol_highlights()

-- 구분자
local SEP = '›'

-- 경로 하이라이트: 폴더명은 기본색, 구분자만 연하게
local function setup_path_highlights()
  vim.api.nvim_set_hl(0, 'LualinePathRoot', { fg = colors.white, bg = 'NONE' })
  vim.api.nvim_set_hl(0, 'LualinePathDim', { fg = p.grey, bg = 'NONE' })
end
vim.api.nvim_create_autocmd('ColorScheme', { callback = setup_path_highlights })
setup_path_highlights()

-- 프로젝트 루트: 현재 파일 기준 git 루트, 없으면 cwd (디렉토리별 캐시)
local root_cache = {}
local function project_root()
  local name = vim.api.nvim_buf_get_name(0)
  local dir = (vim.bo.buftype == '' and name ~= '') and vim.fs.dirname(name) or vim.fn.getcwd()
  if root_cache[dir] == nil then
    root_cache[dir] = vim.fs.root(dir, '.git') or false
  end
  return root_cache[dir] or vim.fn.getcwd()
end

-- 전체 경로를 클립보드(+)와 기본 레지스터에 복사
local function copy_path(path)
  if not path or path == '' then return end
  vim.fn.setreg('+', path)
  vim.fn.setreg('"', path)
  vim.notify('경로 복사됨: ' .. path, vim.log.levels.INFO, { title = 'lualine' })
end

local function copy_full_path()
  copy_path(vim.fn.expand('%:p'))
end

-- 경로 표시: 프로젝트 › 폴더 › 폴더 › (깊으면 중간을 … 로 생략)
local MAX_DIRS = 4
local function build_crumbs()
  local root = project_root()
  local crumbs = { { name = vim.fs.basename(root), path = root, hl = 'LualinePathRoot' } }
  local name = vim.api.nvim_buf_get_name(0)
  if vim.bo.buftype == '' and name ~= '' then
    local dir = vim.fs.dirname(name)
    local rel = vim.fs.relpath(root, dir)
    if rel == nil then
      -- 프로젝트 밖 파일: 상위 폴더 이름만
      crumbs = { { name = vim.fs.basename(dir), path = dir, hl = 'LualinePathRoot' } }
    elseif rel ~= '.' then
      local acc = root
      local dirs = {}
      for _, d in ipairs(vim.split(rel, '/', { plain = true })) do
        acc = acc .. '/' .. d
        table.insert(dirs, { name = d, path = acc, hl = 'LualinePathRoot' })
      end
      if #dirs > MAX_DIRS then
        dirs = { dirs[1], { name = '…', hl = 'LualinePathDim' }, dirs[#dirs - 1], dirs[#dirs] }
      end
      vim.list_extend(crumbs, dirs)
    end
  end
  return crumbs
end

-- 경로 조각 클릭 → 그 폴더까지의 전체 경로 복사 (%N@...@ 의 N 이 조각 번호)
-- 렌더 시점 상태에 기대지 않도록 클릭 시점에 현재 버퍼 기준으로 다시 계산
function _G.LualinePathClick(idx)
  local c = build_crumbs()[idx]
  copy_path(c and c.path)
end

local function path_crumbs()
  local out = {}
  for i, c in ipairs(build_crumbs()) do
    local text = '%#' .. c.hl .. '#' .. c.name:gsub('%%', '%%%%')
    if c.path then
      text = '%' .. i .. '@v:lua.LualinePathClick@' .. text .. '%T'
    end
    table.insert(out, text)
  end
  local sep = ' %#LualinePathDim#' .. SEP .. ' '
  return table.concat(out, sep) .. sep
end

local function file_size()
  local file = vim.fn.expand('%:p')
  if file == '' then return '' end
  local size = vim.fn.getfsize(file)
  if size < 0 then return '' end
  if size < 1024 then
    return string.format('%dB', size)
  elseif size < 1048576 then
    return string.format('%.1fK', size / 1024)
  end
  return string.format('%.1fM', size / 1048576)
end

-- 일반 파일 버퍼인가 (이름 없는 새 버퍼 포함). 터미널 · neo-tree · help 등은 false
local function is_file()
  return vim.bo.buftype == ''
end

-- 파일이 아닌 버퍼용 표시: 아이콘 1개 + 이름
local special_buffers = {
  ['neo-tree'] = { '\u{f0645}', 'Neo-tree' },
  ['neo-tree-popup'] = { '\u{f0645}', 'Neo-tree' },
  lazy = { '\u{f0b7e}', 'Lazy' },
  mason = { '\u{f0ab7}', 'Mason' },
  TelescopePrompt = { '\u{f0349}', 'Telescope' },
  qf = { '\u{f0ca0}', 'Quickfix' },
  checkhealth = { '\u{f04d9}', 'Health' },
  notify = { '\u{f009a}', 'Notify' },
}
local function special_buffer()
  local bt, ft = vim.bo.buftype, vim.bo.filetype
  if bt == 'terminal' then
    -- term://cwd//pid:cmd → 실행 중인 명령 이름
    local cmd = vim.api.nvim_buf_get_name(0):match('//%d+:(.*)$') or 'terminal'
    cmd = vim.fs.basename(vim.split(cmd, ' ')[1])
    return '\u{f489} ' .. cmd
  end
  if bt == 'help' then
    return '\u{f02d6} ' .. vim.fn.expand('%:t:r')
  end
  local entry = special_buffers[ft]
  if entry then return entry[1] .. ' ' .. entry[2] end
  return '\u{f2d0} ' .. (ft ~= '' and ft or bt)
end

-- 파일 아이콘 (devicons, 언어별 색상 / 알 수 없으면 기본 파일 아이콘)
local function file_icon()
  local ok, devicons = pcall(require, 'nvim-web-devicons')
  if not ok then return '', nil end
  local name = vim.fn.expand('%:t')
  return devicons.get_icon_color(name, vim.fn.expand('%:e'), { default = true })
end

local flat_theme = {
  normal = {
    a = { fg = colors.green, bg = colors.transparent },
    b = { fg = colors.white, bg = colors.transparent },
    c = { fg = colors.white, bg = colors.transparent },
  },

  insert = { a = { fg = colors.blue, bg = colors.transparent } },
  terminal = { a = { fg = colors.blue, bg = colors.transparent } },
  visual = { a = { fg = colors.red, bg = colors.transparent } },
  replace = { a = { fg = colors.violet, bg = colors.transparent } },

  inactive = {
    a = { fg = colors.white, bg = colors.black },
    b = { fg = colors.white, bg = colors.black },
    c = { fg = colors.black, bg = colors.black },
  },
}
return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        theme = flat_theme,
        component_separators = '',
        section_separators = '',
        globalstatus = true,
        ignore_focus = {},
      },
      sections = {
        lualine_a = {
          -- 문자 없이 모드 색상만 보이는 작은 원
          {
            'mode',
            fmt = function() return '●' end,
            padding = { left = 1, right = 0 },
          },
        },
        lualine_b = {
          -- 프로젝트 › 폴더 › … › 파일아이콘 파일명 용량
          {
            path_crumbs,
            padding = { left = 1, right = 0 },
          },
          {
            special_buffer,
            cond = function() return not is_file() end,
            padding = { left = 0, right = 1 },
          },
          {
            function() return (file_icon()) end,
            color = function()
              local _, fg = file_icon()
              return fg and { fg = fg } or nil
            end,
            cond = is_file,
            padding = 0,
          },
          {
            'filename',
            path = 0,
            symbols = { modified = '●', readonly = '[RO]', unnamed = '[No Name]', newfile = '[New]' },
            color = { gui = 'bold' },
            on_click = copy_full_path,
            cond = is_file,
            padding = { left = 1, right = 0 },
          },
          {
            file_size,
            color = { fg = p.grey },
            cond = is_file,
            padding = { left = 1, right = 1 },
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
          {
            function()
              local bufnr = vim.api.nvim_get_current_buf()
              local cursor = vim.api.nvim_win_get_cursor(0)
              local row, col = cursor[1] - 1, cursor[2]

              local symbol_icons = {
                function_declaration = '󰊕',
                function_definition = '󰊕',
                function_item = '󰊕',
                ['function'] = '󰊕',
                arrow_function = '󰊕',
                function_expression = '󰊕',
                method_declaration = '󰊕',
                method_definition = '󰊕',
                method = '󰊕',
                class_declaration = '󰠱',
                class_definition = '󰠱',
                ['class'] = '󰠱',
                interface_declaration = '󰜰',
                type_alias_declaration = '󰜰',
                type_declaration = '󰜰',
                struct_item = '󰙅',
                enum_declaration = '󰕘',
                enum_item = '󰕘',
                lexical_declaration = '󰊕',
                variable_declarator = '󰊕',
              }

              local name_node_types = {
                'identifier', 'property_identifier', 'type_identifier', 'name'
              }

              local function get_symbol_name(node, _)
                for child in node:iter_children() do
                  for _, name_type in ipairs(name_node_types) do
                    if child:type() == name_type then
                      return vim.treesitter.get_node_text(child, bufnr)
                    end
                  end
                end

                if node:type() == 'arrow_function' or node:type() == 'function_expression' then
                  local parent = node:parent()
                  if parent and parent:type() == 'variable_declarator' then
                    for child in parent:iter_children() do
                      if child:type() == 'identifier' then
                        return vim.treesitter.get_node_text(child, bufnr)
                      end
                    end
                  end
                end

                return ''
              end

              local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
              if not ok or not parser then return '' end

              if not pcall(parser.parse, parser) then return '' end

              local all_trees = {}
              parser:for_each_tree(function(tree, lang_tree)
                local lang = lang_tree:lang()
                local priority = (lang == 'javascript' or lang == 'typescript' or lang == 'tsx' or lang == 'jsx') and 3
                               or (lang == 'html' or lang == 'vue') and 2
                               or 1

                table.insert(all_trees, { tree = tree, priority = priority })
              end)

              table.sort(all_trees, function(a, b) return a.priority > b.priority end)

              local node = nil
              for _, tree_info in ipairs(all_trees) do
                local root = tree_info.tree:root()
                local start_row, _, end_row, _ = root:range()

                if row >= start_row and row <= end_row then
                  local candidate = root:descendant_for_range(row, col, row, col)
                  if candidate and candidate:type() ~= 'ERROR' then
                    node = candidate
                    break
                  end
                end
              end

              if not node then return '' end

              local scopes = {}
              local current = node
              local last_name = nil

              while current and #scopes < 3 do
                local node_type = current:type()
                local icon = symbol_icons[node_type]

                if icon then
                  local name = get_symbol_name(current, bufnr)

                  if name ~= '' and name ~= last_name then
                    local hl_name = 'LualineSymbol' .. node_type:gsub('_', '')
                    table.insert(scopes, 1, { icon = icon, name = name, hl = hl_name })
                    last_name = name
                  end
                end

                current = current:parent()
              end

              if #scopes == 0 then return '' end

              local parts = {}
              for i, scope in ipairs(scopes) do
                local separator = i == 1 and '' or '  '
                table.insert(parts, string.format('%s%%#%s#%s%%* %s', separator, scope.hl, scope.icon, scope.name))
              end

              return table.concat(parts, '')
            end,
            color = { fg = colors.white, bg = colors.transparent },
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
            color = { fg = p.white },
          },
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
          },
          {
            'branch',
            icon = '',
            padding = { left = 1, right = 1 },
          },
        },
        lualine_y = {},
        lualine_z = {},
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
