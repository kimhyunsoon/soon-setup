return {
  "hrsh7th/nvim-cmp",
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    
    local kind_icons = {
      Text = "󰉿",
      Method = "󰆧",
      Function = "󰊕",
      Constructor = "",
      Field = "󰜢",
      Variable = "󰀫",
      Class = "󰠱",
      Interface = "",
      Module = "",
      Property = "󰜢",
      Unit = "󰑭",
      Value = "󰎠",
      Enum = "",
      Keyword = "󰌋",
      Snippet = "",
      Color = "󰏘",
      File = "󰈙",
      Reference = "󰈇",
      Folder = "󰉋",
      EnumMember = "",
      Constant = "󰏿",
      Struct = "󰙅",
      Event = "",
      Operator = "󰆕",
      TypeParameter = "",
    }
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      preselect = cmp.PreselectMode.None,
      completion = {
        completeopt = 'menu,menuone,noinsert,noselect'
      },
      mapping = {
        ["<CR>"] = function(fallback)
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
          vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)
          return vim_item
        end
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "copilot" },
      }),
      window = {
        completion = {
          border = "rounded",
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
        },
        documentation = {
          border = "rounded",
          winhighlight = "Normal:CmpNormal,FloatBorder:CmpBorder",
        },
      },
    })
  end
}
