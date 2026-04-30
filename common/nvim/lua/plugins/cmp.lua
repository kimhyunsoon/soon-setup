return {
  'hrsh7th/nvim-cmp',
  event = "InsertEnter",
  dependencies = {
    'roobert/tailwindcss-colorizer-cmp.nvim',
  },
  config = function()
    local cmp = require('cmp')
    local common = require('common')
    local symbols = common.symbols

    cmp.setup({
      preselect = cmp.PreselectMode.None,
      completion = {
        completeopt = 'menu,menuone,noinsert,noselect'
      },
      performance = {
        debounce = 60,
        throttle = 30,
        fetching_timeout = 500,
        confirm_resolve_timeout = 80,
        async_budget = 1,
        max_view_entries = 200,
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
          if symbols[kind] then
            vim_item.kind = string.format('%s %s', symbols[kind], kind)
          else
            vim_item.kind = string.format('󰠱 %s', kind)
          end
          vim_item.kind_hl_group = 'CmpItemKind' .. (kind or 'Text')

          -- tailwindcss-colorizer-cmp 적용
          local ok, tailwind = pcall(require, 'tailwindcss-colorizer-cmp')
          if ok then
            return tailwind.formatter(entry, vim_item)
          end

          return vim_item
        end
      },
      sources = cmp.config.sources({
        { name = 'nvim_lsp', max_item_count = 50 },
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
