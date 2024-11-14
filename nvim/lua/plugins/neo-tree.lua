return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
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
          symbol = "",
          highlight = "DiagnosticSignError",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
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
          symbols = {
            hint = "",
            info = "",
            warn = "",
            error = "",
          },
        },
        git_status = {
          symbols = {
            added = "",
            modified = "",
            deleted = "",
            renamed = "",
            untracked = "",
            ignored = "",
            unstaged = "",
            staged = "",
            conflict = "",
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
          ['t'] = false,
          ['<space>'] = { 
            'toggle_node', 
            nowait = false,
          },
          ['<2-LeftMouse>'] = 'open',
          ['<cr>'] = 'open',
          ['l'] = 'open',
          ['h'] = 'close_node',
          ['a'] = 'add',
          ['d'] = 'delete',
          ['r'] = 'rename',
          ['c'] = 'copy',
          ['m'] = 'move',
          ['q'] = 'close_window',
          ['R'] = 'refresh',
        },
        enable_normal_mode_for_inputs = false,
        popup_border_style = "rounded",
        winhighlight = "Normal:NeoTreeNormal,NormalNC:NeoTreeNormalNC",
      },
    })
  end,
} 