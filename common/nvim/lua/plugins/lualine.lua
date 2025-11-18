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
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
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

              while current and #scopes < 3 do
                local node_type = current:type()
                local icon = symbol_icons[node_type]

                if icon then
                  local name = get_symbol_name(current, bufnr)

                  if name ~= '' then
                    local hl_name = 'LualineSymbol' .. node_type:gsub('_', '')
                    table.insert(scopes, 1, { icon = icon, name = name, hl = hl_name })
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
            color = { fg = '#ffffff' },
          },
          {
            'diagnostics',
            sources = { 'nvim_diagnostic' },
            symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
          },
          {
            'filesize',
            icon = '',
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
