return {
  'hrsh7th/nvim-cmp',
  config = function()
    local cmp = require('cmp')
    vim.api.nvim_set_hl(0, 'CmpItemKindText', { fg = '#e2e2e3' })
    vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { fg = '#b39df3' })
    vim.api.nvim_set_hl(0, 'CmpItemKindConstant', { fg = '#e2e2e3' })
    vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { fg = '#76cce0' })
    vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { fg = '#fc5d7c' })
    vim.api.nvim_set_hl(0, 'CmpItemKindConstructor', { fg = '#fc5d7c' })
    vim.api.nvim_set_hl(0, 'CmpItemKindClass', { fg = '#fc5d7c' })
    vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { fg = '#76cce0' })
    vim.api.nvim_set_hl(0, 'CmpItemKindModule', { fg = '#fc5d7c' })
    vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { fg = '#7f8490' })
    vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { fg = '#e2e2e3' })
    vim.api.nvim_set_hl(0, 'CmpItemKindField', { fg = '#7f8490' })
    vim.api.nvim_set_hl(0, 'CmpItemKindSnippet', { fg = '#b39df3' })
    vim.api.nvim_set_hl(0, 'CmpItemKindFile', { fg = '#9ed072' })
    vim.api.nvim_set_hl(0, 'CmpItemKindFolder', { fg = '#9ed072' })
    vim.api.nvim_set_hl(0, 'CmpItemKindCopilot', { fg = '#b39df3' })

    local kind_icons = {
      Text = '󰉿',
      Method = '󰆧',
      Function = '󰊕',
      Constructor = '󰒓',
      Field = '',
      Variable = '󰀫',
      Class = '󰠱',
      Interface = '󰜰',
      Module = '󰕳',
      Property = '󰜢',
      Unit = '󰑭',
      Value = '󰎠',
      Enum = '󰕘',
      Keyword = '󰌋',
      Snippet = '󰃐',
      Color = '󰏘',
      File = '󰈙',
      Reference = '',
      Folder = '󰉋',
      EnumMember = '',
      Constant = '󰏿',
      Struct = '󰙅',
      Event = '󰂚',
      Operator = '󰆕',
      Copilot = '',
      TypeParameter = '󰅲',
    }
    cmp.setup({
      preselect = cmp.PreselectMode.None,
      completion = {
        completeopt = 'menu,menuone,noinsert,noselect'
      },
      mapping = {
        ['<CR>'] = function(fallback)
          if cmp.visible() then
            local selected = cmp.get_selected_entry()
            if selected then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
            else
              fallback()
            end
          else
            fallback()
          end
        end,
        ['<Up>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
        ['<Down>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
      },
      formatting = {
        format = function(entry, vim_item)
          local kind = vim_item.kind
          if kind_icons[kind] then
            vim_item.kind = string.format('%s %s', kind_icons[kind], kind)
          else
            vim_item.kind = string.format('󰠱 %s', kind)
          end
          vim_item.kind_hl_group = 'CmpItemKind' .. (kind or 'Text')
          return vim_item
        end
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'copilot' },
      }),
      window = {
        completion = {
          border = 'rounded',
          winhighlight = 'Normal:CmpNormal,FloatBorder:CmpBorder',
        },
        documentation = {
          border = 'rounded',
          winhighlight = 'Normal:Normal,FloatBorder:FloatBorder',
        },
      },
    })
  end
}
