local select_one_or_multi = function(prompt_bufnr)
  local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    require('telescope.actions').close(prompt_bufnr)
    for _, j in pairs(multi) do
      if j.path ~= nil then
        vim.cmd(string.format('%s %s', 'edit', j.path))
      end
    end
  else
    require('telescope.actions').select_default(prompt_bufnr)
  end
end

return {
  'nvim-telescope/telescope.nvim', tag = '0.1.6',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'tsakirist/telescope-lazy.nvim',
  },
  config = function()
    require('telescope').load_extension('ui-select')
    require('telescope').setup({
      defaults = {
        prompt_prefix = '  ',
        selection_caret = '  ',
        multi_icon = '  ',
        entry_prefix = '   ',
        path_display = { 'truncate' },
        sorting_strategy = 'ascending',
        borderchars = {
          prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          results = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
          preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        },
        layout_config = {
          horizontal = { prompt_position = 'top', preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.8,
          height = 0.6,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ['<CR>'] = select_one_or_multi,
          }
        },
      },
      pickers = {
        git_status = {
          git_icons ={
            added = "",
            changed = "",
            copied = "",
            deleted = "",
            renamed = "",
            unmerged = "",
            untracked = "",
          },
        },
        git_commits = {
          mappings = {
            i = {
              ["<CR>"] = function(prompt_bufnr)
                -- 현재 선택된 항목 가져오기
                local selection = require('telescope.actions.state').get_selected_entry()
                -- telescope 창 닫기
                require('telescope.actions').close(prompt_bufnr)
                -- 새 버퍼 생성
                vim.cmd('enew')
                local buf = vim.api.nvim_get_current_buf()
                -- git show 명령어로 커밋 전체 내용 가져오기
                local commit_hash = selection.value
                local result = vim.fn.systemlist('git show ' .. commit_hash)
                -- 버퍼에 내용 쓰기
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, result)
                -- 버퍼를 읽기 전용으로 설정
                vim.bo[buf].modifiable = false
                vim.bo[buf].readonly = true
                -- 파일 타입을 git으로 설정 (구문 강조를 위해)
                vim.bo[buf].filetype = 'git'
              end,
            },
          },
        },
      },
    })
    vim.cmd([[
      highlight! link TelescopeSelection TabLine
    ]])
  end
}
