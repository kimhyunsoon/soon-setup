local select_one_or_multi = function(prompt_bufnr)
  local picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
  local multi = picker:get_multi_selection()
  if not vim.tbl_isempty(multi) then
    require('telescope.actions').close(prompt_bufnr)
    for _, j in pairs(multi) do
      local file_path = j.path or j.filename
      if picker.picker_name == 'git_status' then
        file_path = j.value
      end

      if file_path then
        if j.lnum then
          vim.cmd(string.format('%s +%d %s', 'edit', j.lnum, file_path))
        else
          vim.cmd(string.format('%s %s', 'edit', file_path))
        end
      end
    end
  else
    require('telescope.actions').select_default(prompt_bufnr)
  end
end

return {
  'nvim-telescope/telescope.nvim', tag = '0.1.6',
  cmd = 'Telescope',
  keys = {
    -- 탐색
    {
      '<leader>ff',
      '<cmd>Telescope find_files<cr>',
      desc = '[common] 파일 찾기',
    },
    {
      '<leader>fw',
      '<cmd>Telescope live_grep<cr>',
      desc = '[common] 문자열 찾기',
    },

    {
      '<leader>fs',
      function()
        require('telescope.builtin').lsp_document_symbols()
      end,
      desc = '[common] 심볼 찾기',
    },
    {
       '<leader>fk',
       function()
         -- 모든 플러그인 키매핑이 로드되도록 강제 로드
         local lazy = require('lazy')
         for _, plugin in pairs(lazy.plugins()) do
           if not plugin._.loaded then
             lazy.load({ plugins = { plugin.name } })
           end
         end
         vim.cmd('Telescope keymaps')
       end,
       desc = '[common] 단축키 찾기',
     },
    {
      'gr', function()
      require('telescope.builtin').lsp_references({ include_declaration = false, show_line = false }) end,
      desc = '[lsp] 참조 찾기'
    },
    { 'gd', function() require('telescope.builtin').lsp_definitions() end, desc = '[lsp] 정의로 이동' },
    { 'la', function() vim.lsp.buf.code_action() end, desc = '[lsp] 코드 수정 제안' },
    -- git
    {
      '<leader>gs',
      function()
        require('telescope.builtin').git_status({
          git_command = { 'git', 'status', '--porcelain' },
          entry_maker = function(entry)
            local status = entry:sub(1, 2)
            local file_path = entry:sub(4)

            -- staged only 파일 제외
            if status:sub(1, 1) ~= ' ' and status:sub(2, 2) == ' ' then
              return nil
            end

            -- deleted 파일 제외
            if status:match(' D') or status:match('D ') then
              return nil
            end

            return {
              value = file_path,
              display = file_path,
              ordinal = file_path,
              path = file_path,
            }
          end,
        })
      end,
      desc = '[git] 변경사항',
    },
    {
    '<leader>gc',
      function()
        require('telescope.builtin').git_commits({
          entry_maker = function(entry)
            local hash = entry:match('^(%w+)')
            local rest = entry:match('^%w+%s*(.+)') or ''
            return {
              display = rest,
              value = hash,
             ordinal = entry,
           }
        end,
      })
      end,
      desc = '[git] 커밋 목록'
    },
    {
      '<leader>gf',
      function()
        require('telescope.builtin').git_bcommits({
          entry_maker = function(entry)
            local hash = entry:match('^(%w+)')
            local rest = entry:match('^%w+%s*(.+)') or ''
            return {
              display = rest,
              value = hash,
              ordinal = entry,
            }
          end,
        })
      end,
      desc = '[git] 현재 파일 커밋 목록'
    },
    {
      '<leader>gb',
      function() require('telescope.builtin').git_branches() end,
      desc = '[git] 브렌치 목록',
    },
    -- 기타..
    {
      '<leader>nh',
      '<cmd>Telescope notify<cr>',
      desc = '[common] 알림 목록',
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    'tsakirist/telescope-lazy.nvim',
  },
  config = function()
    require('telescope').setup({
      defaults = {
        prompt_prefix = '  ',
        selection_caret = '  ',
        multi_icon = '  ',
        entry_prefix = '   ',
        path_display = { 'truncate' },
        sorting_strategy = 'ascending',
        cache_picker = {
          num_pickers = 10,
        },
        borderchars = {
          prompt = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          results = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
          preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
        },
        layout_config = {
          horizontal = { prompt_position = 'top', preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.8,
          height = 0.6,
          preview_cutoff = 120,
        },
        preview = {
          filesize_limit = 0.5555,
        },
        mappings = {
          i = {
            ['<CR>'] = select_one_or_multi,
          }
        },
        file_ignore_patterns = {
          '^.git/',          -- git 디렉토리
          '^node_modules/',  -- node_modules 디렉토리
          '^.idea/',         -- JetBrains IDE 설정 디렉토리
          '^.vscode/',       -- VSCode 설정 디렉토리
          '^.DS_Store$',     -- macOS 숨김 파일
          '^dist/',          -- 빌드 결과물 디렉토리
          '^build/',         -- 빌드 결과물 디렉토리
          '^out/',           -- 빌드 결과물 디렉토리
          '^.pnpm-store/',   -- pnpm 저장소 디렉토리
          '^.cache/',        -- 캐시 디렉토리
          '^.yarn/',         -- Yarn 캐시 디렉토리
          '^.turbo/',        -- Turborepo 캐시 디렉토리
          '^.next/',         -- Next.js 빌드 디렉토리
          '^.nuxt/',         -- Nuxt.js 빌드 디렉토리
          '^.svelte-kit/',   -- SvelteKit 빌드 디렉토리
          '^.vercel/',       -- Vercel 배포 캐시 디렉토리
          '^.netlify/',      -- Netlify 배포 캐시 디렉토리
          '^pnpm-lock.yaml', -- pnpm-lock.yaml 파일
          '^package-lock.json', -- package-lock.json 파일
          '^yarn.lock',      -- yarn.lock 파일
        },
        hidden = true,  -- 숨김 파일 검색 활성화
      },
      pickers = {
        find_files = {
          find_command = {
            'rg',
            '--files',        -- 파일 목록만 출력
            '--hidden',       -- 숨김 파일 포함
            '--no-ignore',    -- .gitignore 및 .ignore 규칙 무시
            '--glob', '!**/.git/*',       -- .git 디렉토리 제외
            '--glob', '!**/node_modules/*', -- node_modules 디렉토리 제외
            '--glob', '!**/.idea/*',      -- .idea 디렉토리 제외
            '--glob', '!**/.vscode/*',    -- .vscode 디렉토리 제외
            '--glob', '!**/.pnpm-store/*', -- pnpm 저장소 디렉토리 제외
            '--glob', '!**/.cache/*',     -- 캐시 디렉토리 제외
            '--glob', '!**/.yarn/*',      -- Yarn 캐시 디렉토리 제외
            '--glob', '!**/.turbo/*',    -- Turborepo 캐시 디렉토리 제외
            '--glob', '!**/.next/*',     -- Next.js 빌드 디렉토리 제외
            '--glob', '!**/.nuxt/*',     -- Nuxt.js 빌드 디렉토리 제외
            '--glob', '!**/.svelte-kit/*', -- SvelteKit 빌드 디렉토리 제외
            '--glob', '!**/.vercel/*',   -- Vercel 배포 캐시 디렉토리 제외
            '--glob', '!**/.netlify/*',  -- Netlify 배포 캐시 디렉토리 제외
            '--glob', '!**/*.min.*',    -- 압축 파일 제외
          },
        },
        live_grep = {
          additional_args = function()
            return {
              '--hidden',       -- 숨김 파일 포함
              '--no-ignore',    -- .gitignore 및 .ignore 규칙 무시
              '--max-filesize', '1M',  -- 1MB 이상 파일 제외
              '--glob', '!**/.git/*',       -- .git 디렉토리 제외
              '--glob', '!**/node_modules/*', -- node_modules 디렉토리 제외
              '--glob', '!**/.idea/*',      -- .idea 디렉토리 제외
              '--glob', '!**/.vscode/*',    -- .vscode 디렉토리 제외
              '--glob', '!**/.pnpm-store/*', -- pnpm 저장소 디렉토리 제외
              '--glob', '!**/.cache/*',     -- 캐시 디렉토리 제외
              '--glob', '!**/.yarn/*',      -- Yarn 캐시 디렉토리 제외
              '--glob', '!**/.turbo/*',    -- Turborepo 캐시 디렉토리 제외
              '--glob', '!**/.next/*',     -- Next.js 빌드 디렉토리 제외
              '--glob', '!**/.nuxt/*',     -- Nuxt.js 빌드 디렉토리 제외
              '--glob', '!**/.svelte-kit/*', -- SvelteKit 빌드 디렉토리 제외
              '--glob', '!**/.vercel/*',   -- Vercel 배포 캐시 디렉토리 제외
              '--glob', '!**/.netlify/*',  -- Netlify 배포 캐시 디렉토리 제외
              '--glob', '!**/dist/*',      -- dist 디렉토리 제외
              '--glob', '!**/build/*',     -- build 디렉토리 제외
              '--glob', '!**/out/*',       -- out 디렉토리 제외
              '--glob', '!**/pnpm-lock.yaml', -- pnpm-lock.yaml 파일 제외
              '--glob', '!**/package-lock.json', -- package-lock.json 파일 제외
              '--glob', '!**/yarn.lock',   -- yarn.lock 파일 제외
              '--glob', '!**/*.min.*',    -- 압축 파일 제외
            }
          end,
        },
        git_status = {
          mappings = {
            i = {
              ['<Tab>'] = function(prompt_bufnr)
                require('telescope.actions').toggle_selection(prompt_bufnr)
                require('telescope.actions').move_selection_next(prompt_bufnr)
              end,
              ['<S-Tab>'] = function(prompt_bufnr)
                require('telescope.actions').toggle_selection(prompt_bufnr)
                require('telescope.actions').move_selection_previous(prompt_bufnr)
              end,
            },
            n = {
              ['<Tab>'] = function(prompt_bufnr)
                require('telescope.actions').toggle_selection(prompt_bufnr)
                require('telescope.actions').move_selection_next(prompt_bufnr)
              end,
              ['<S-Tab>'] = function(prompt_bufnr)
                require('telescope.actions').toggle_selection(prompt_bufnr)
                require('telescope.actions').move_selection_previous(prompt_bufnr)
              end,
            },
          },

        },
        git_commits = {
          mappings = {
            i = {
              ['<CR>'] = function(prompt_bufnr)
                -- 현재 선택된 항목 가져오기
                local selection = require('telescope.actions.state').get_selected_entry()
                -- telescope 창 닫기
                require('telescope.actions').close(prompt_bufnr)
                -- 새 버퍼 생성
                vim.cmd('enew')
                local buf = vim.api.nvim_get_current_buf()
                -- git show 명령어로 커밋 전체 내용 가져오기
                local commit_hash = selection.value
                local result = vim.fn.systemlist('git show --stat --date=format:"%Y-%m-%d %H:%M:%S" --format=fuller ' .. commit_hash)
                -- 커밋 정보를 더 사용자 친화적으로 포맷
                local formatted_result = {}
                for _, line in ipairs(result) do
                  table.insert(formatted_result, line)
                end
                -- 버퍼에 내용 쓰기
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, formatted_result)
                -- 버퍼를 읽기 전용으로 설정
                vim.bo[buf].modifiable = false
                vim.bo[buf].readonly = true
                -- 파일 타입을 git으로 설정 (구문 강조를 위해)
                vim.bo[buf].filetype = 'git'
                -- 버퍼 이름 설정
                vim.api.nvim_buf_set_name(buf, 'Git Commit: ' .. commit_hash:sub(1, 8))
              end,
            },
          },
        },
        git_bcommits = {
          mappings = {
            i = {
              ['<CR>'] = function(prompt_bufnr)
                -- 현재 선택된 항목 가져오기
                local selection = require('telescope.actions.state').get_selected_entry()
                -- telescope 창 닫기
                require('telescope.actions').close(prompt_bufnr)
                -- 커밋 해시에서 해당 파일의 내용 가져오기
                local commit_hash = selection.value
                local result = vim.fn.systemlist('git show ' .. commit_hash .. ':' .. vim.fn.expand('%:.'))
                -- 현재 버퍼의 내용을 덮어쓰기
                vim.api.nvim_buf_set_lines(0, 0, -1, false, result)
                 -- 파일 수정됨 표시
                 vim.bo.modified = true
                 vim.notify('File changed to commit ' .. commit_hash:sub(1, 8), vim.log.levels.INFO)
              end,
            },
          },
        },
        lsp_definitions = {
          show_line = false,
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown {}
        }
      },
    })
    require('telescope').load_extension('ui-select')
    vim.cmd([[
      highlight! link TelescopeSelection TabLine
    ]])
  end
}
