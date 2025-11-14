return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  cmd = 'Neotree',
  keys = {
    {
      '<leader>o', function()
        if vim.bo.filetype == 'neo-tree' then
          vim.cmd('Neotree close')
          -- 일반 에디터 버퍼로 포커스 이동
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            if ft ~= 'neo-tree' and vim.bo[buf].buftype == '' then
              vim.api.nvim_set_current_win(win)
              break
            end
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

    -- 동일 창(분할 없이)으로 포커스를 옮기고 파일을 여는 헬퍼
    local function focus_normal_win()
      local prev_winnr = vim.fn.winnr('#')
      local function is_normal_win(win)
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.bo[buf].filetype
        local bt = vim.bo[buf].buftype
        return ft ~= 'neo-tree' and bt ~= 'terminal' and bt ~= 'nofile'
      end
      if prev_winnr > 0 then
        local prev_winid = vim.fn.win_getid(prev_winnr)
        if prev_winid ~= 0 and is_normal_win(prev_winid) then
          vim.api.nvim_set_current_win(prev_winid)
          return
        end
      end
      if vim.bo.filetype == 'neo-tree' then
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if is_normal_win(win) then
            vim.api.nvim_set_current_win(win)
            break
          end
        end
      end
    end

    local function open_file_no_split(path)
      focus_normal_win()
      vim.cmd('edit ' .. vim.fn.fnameescape(path))
    end

    -- NeoTreeGitUntracked 하이라이트 오버라이드
    local function apply_neo_tree_git_hl()
      vim.schedule(function()
        pcall(vim.cmd, 'highlight clear NeoTreeGitUntracked')
        -- 보라색에 링크함
        pcall(vim.cmd, 'highlight! link NeoTreeGitUntracked Label')
      end)
    end
    apply_neo_tree_git_hl()
    vim.api.nvim_create_autocmd({ 'User', 'ColorScheme' }, {
      pattern = { 'NeoTree*' },
      callback = apply_neo_tree_git_hl,
    })

    require('neo-tree').setup({
      -- 파일은 항상 마지막(네오트리가 아닌) 창에서 열고, 분할을 피함
      open_files_in_last_window = true,
      open_files_do_not_replace_types = { 'neo-tree' },
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
          ['<2-LeftMouse>'] = function(state)
            local node = state.tree:get_node()
            if not node then return end
            if node.type == 'file' then
              open_file_no_split(node.path)
            elseif node.type == 'directory' or node.type == 'message' then
              require('neo-tree.sources.filesystem.commands').toggle_node(state)
            else
              require('neo-tree.sources.common.commands').open(state)
            end
          end,
          ['<bs>'] = 'navigate_up',
          -- 엔터로 열 때도 항상 같은 창(분할 없이)에서 열리도록 강제
          ['<cr>'] = function(state)
            local node = state.tree:get_node()
            if not node then return end
            if node.type == 'file' then
              open_file_no_split(node.path)
            elseif node.type == 'directory' or node.type == 'message' then
              require('neo-tree.sources.filesystem.commands').toggle_node(state)
            else
              require('neo-tree.sources.common.commands').open(state)
            end
          end,
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
          -- 버퍼 이동 키맵핑
          ['{'] = function()
            -- 일반 버퍼로 포커스 이동 후 bprevious 실행
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.bo[buf].filetype
              if ft ~= 'neo-tree' and vim.bo[buf].buftype == '' then
                vim.api.nvim_set_current_win(win)
                vim.cmd('bprevious')
                return
              end
            end
          end,
          ['}'] = function()
            -- 일반 버퍼로 포커스 이동 후 bnext 실행
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.bo[buf].filetype
              if ft ~= 'neo-tree' and vim.bo[buf].buftype == '' then
                vim.api.nvim_set_current_win(win)
                vim.cmd('bnext')
                return
              end
            end
          end,
          -- 터미널 열기
          ['<leader>tt'] = function()
            -- 일반 버퍼로 포커스 이동
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              local ft = vim.bo[buf].filetype
              if ft ~= 'neo-tree' and vim.bo[buf].buftype == '' then
                vim.api.nvim_set_current_win(win)
                break
              end
            end

            -- 터미널 열기
            vim.cmd('enew')
            local term_buf = vim.api.nvim_get_current_buf()
            vim.fn.termopen(vim.env.SHELL or 'bash', {
              on_exit = function(_)
                vim.schedule(function()
                  if vim.api.nvim_buf_is_valid(term_buf) then
                    local bufs = vim.api.nvim_list_bufs()
                    local valid_bufs = {}
                    for _, buf in ipairs(bufs) do
                      if vim.api.nvim_buf_is_valid(buf)
                         and vim.bo[buf].buflisted
                         and buf ~= term_buf
                         and vim.bo[buf].filetype ~= 'neo-tree' then
                        table.insert(valid_bufs, buf)
                      end
                    end
                    if #valid_bufs > 0 then
                      vim.api.nvim_set_current_buf(valid_bufs[1])
                    else
                      vim.cmd('enew')
                    end
                    if vim.api.nvim_buf_is_valid(term_buf) then
                      vim.api.nvim_buf_delete(term_buf, { force = true })
                    end
                  end
                end)
              end
            })
          end,
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
