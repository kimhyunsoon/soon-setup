local colors = {
  red    = '#FF6077',
  blue   = '#85D3F2',
  green  = '#A7DF78',
  violet = '#d183e8',
  yellow = '#F5D16C',
  white  = '#FFFFFF',
  grey   = '#2a2a2a',
  black  = '#000000',
  transparent  = '#00000000',
}

return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    vim.api.nvim_set_hl(0, "NeoTreeGitAdded", { fg = colors.green })
    vim.api.nvim_set_hl(0, "NeoTreeGitModified", { fg = colors.blue })
    vim.api.nvim_set_hl(0, "NeoTreeGitRemoved", { fg = colors.red })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "neo-tree-popup",
      callback = function()
      end,
    })

    local components = require('neo-tree.sources.common.components')
    require('neo-tree').setup({
      close_if_last_window = true,
      popup_border_style = 'rounded',
      enable_git_status = true,
      enable_diagnostics = true,
      
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        components = {
          name = function(config, node, state)
              local name = components.name(config, node, state)
              if node:get_depth() == 1 then
                  name.text = vim.fs.basename(vim.loop.cwd() or '')
              end
              return name
          end,
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = false,
        },
        hijack_netrw_behavior = "open_default",
      },

      default_component_configs = {
        modified = {
          symbol = "",
          highlight = "TSField",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          highlight = "NeoTreeFileIcon"
        },
        indent = {
          indent_size = 2,
          padding = 1,
          with_markers = false,
          highlight = 'NeoTreeIndentMarker',
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
        },
        diagnostics = {
          align = "right",
          symbols = { error = '', warn = '', info = '', hint = '' },
        },
        git_status = {
          symbols = {
            added = '',
            modified = '󰏬',
            removed = '',
            deleted = '',
            renamed = '',
            untracked = '',
            ignored = '',
            unstaged = '',
            staged = '',
            conflict = '',
          },
        },
      },



      window = {
        position = 'left',
        width = 30,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ['/'] = false,
          ['f'] = false,
          ['<2-LeftMouse>'] = 'open',
          ['<cr>'] = 'open',
          ['a'] = 'add',
          ['d'] = 'delete',
          ['r'] = 'rename',
          ['c'] = 'copy',
          ['m'] = 'move',
          ['R'] = 'refresh',
        },
        enable_normal_mode_for_inputs = false,
        popup_border_style = "rounded",
        popup = {
          border = "rounded",
          position = { col = "100%", row = "2" },
          size = function(state)
            local root_name = vim.fn.fnamemodify(state.path, ":~")
            local root_len = string.len(root_name) + 4
            return {
              width = math.max(root_len, 50),
              height = 1
            }
          end,
        },
        winhighlight = "Normal:NeoTreeNormal,NormalNC:NeoTreeNormalNC,FloatBorder:FloatBorder,NormalFloat:Normal",
      },
    })
  end,
} 