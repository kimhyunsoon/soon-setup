return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  cmd = 'Neotree',
  keys = {
    {
      '<leader>o', function()
        if vim.bo.filetype == 'neo-tree' then
          local win_id = vim.fn.winnr('#')
          if win_id > 0 then
            vim.cmd(win_id .. 'wincmd w')
          else
            vim.cmd('wincmd p')
          end
        else
          vim.cmd('Neotree focus')
        end
      end, desc = '[common] Neo Tree 토글'
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    'MunifTanjim/nui.nvim',
  },
  config = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'neo-tree-popup',
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
        window = {
          mappings = {
            ['i'] = 'show_folder_size'
          },
        },
        commands = {
          show_folder_size = function(state)
            local node = state.tree:get_node()
            if node.type == 'directory' then
              local cmd = 'du -sh ' .. node.path
              local handle = io.popen(cmd)
              local result = handle:read('*a')
              handle:close()
              vim.notify('Folder Size: ' .. result:match('([^%s]+)'), vim.log.levels.INFO)
            else
              -- show_file_details 기능 호출
              require('neo-tree.sources.common.commands').show_file_details(state)
            end
          end,
          copy_name_to_clipboard = function(state)
            local node = state.tree:get_node()
            local name = vim.fn.fnamemodify(node.path, ':t')
            vim.fn.setreg('+', name)
            vim.notify('Copied File name: ' .. name, vim.log.levels.INFO)
          end,
          copy_path_to_clipboard = function(state)
            local node = state.tree:get_node()
            vim.fn.setreg('+', node.path)
            vim.notify('Copied Path: ' .. node.path, vim.log.levels.INFO)
          end,
        },
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
        hijack_netrw_behavior = 'open_default',
      },

      default_component_configs = {
        modified = {
          symbol = '',
          highlight = 'TSField',
        },
        icon = {
          folder_closed = '',
          folder_open = '',
          folder_empty = '',
          highlight = 'NeoTreeFileIcon'
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
          align = 'right',
          symbols = { error = '', warn = '', info = '', hint = '' },
        },
        git_status = {
          symbols = {
            added = '',
            modified = '󰏬',
            removed = '',
            deleted = '',
            renamed = '',
            untracked = '󰎂',
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
          ['#'] = false,
          ['/'] = false,
          ['<'] = false,
          ['>'] = false,
          ['A'] = false,
          ['C'] = false,
          ['D'] = false,
          ['H'] = false,
          ['P'] = false,
          ['S'] = false,
          ['e'] = false,
          ['f'] = false,
          ['l'] = false,
          ['o'] = false,
          ['oc'] = false,
          ['od'] = false,
          ['og'] = false,
          ['om'] = false,
          ['on'] = false,
          ['os'] = false,
          ['ot'] = false,
          ['s'] = false,
          ['t'] = false,
          ['w'] = false,
          ['z'] = false,
          ['<space>'] = false,
           ['<leader>p'] = false,
          ['.'] = 'set_root',
          ['<2-LeftMouse>'] = 'open',
          ['<bs>'] = 'navigate_up',
          ['<cr>'] = 'open',
          ['<esc>'] = 'cancel',
          ['?'] = 'show_help',
          ['R'] = 'refresh',
          ['[g'] = 'prev_git_modified',
          [']g'] = 'next_git_modified',
          ['a'] = 'add',
          ['c'] = 'copy',
          ['d'] = 'delete',
          ['i'] = 'show_folder_size',
          ['m'] = 'move',
          ['p'] = 'paste_from_clipboard',
          ['q'] = 'close_window',
          ['r'] = 'rename',
          ['x'] = 'cut_to_clipboard',
          ['y'] = 'copy_name_to_clipboard',
          ['Y'] = 'copy_path_to_clipboard',
        },
        enable_normal_mode_for_inputs = false,
        popup_border_style = 'rounded',
        popup = {
          border = 'rounded',
          position = { col = '100%', row = '2' },
          size = function(state)
            local root_name = vim.fn.fnamemodify(state.path, ':~')
            local root_len = string.len(root_name) + 4
            return {
              width = math.max(root_len, 50),
              height = 1
            }
          end,
        },
        winhighlight = 'Normal:NeoTreeNormal,NormalNC:NeoTreeNormalNC,FloatBorder:FloatBorder,NormalFloat:Normal',
      },
    })
  end,
}
