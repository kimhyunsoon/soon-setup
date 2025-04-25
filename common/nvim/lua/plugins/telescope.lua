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
        file_ignore_patterns = {
          "^.git/",          -- git 디렉토리
          "^node_modules/",  -- node_modules 디렉토리
          "^.idea/",         -- JetBrains IDE 설정 디렉토리
          "^.vscode/",       -- VSCode 설정 디렉토리
          "^.DS_Store$",     -- macOS 숨김 파일
          "^dist/",          -- 빌드 결과물 디렉토리
          "^build/",         -- 빌드 결과물 디렉토리
          "^out/",           -- 빌드 결과물 디렉토리
          "^.pnpm-store/",   -- pnpm 저장소 디렉토리
          "^.cache/",        -- 캐시 디렉토리
          "^.yarn/",         -- Yarn 캐시 디렉토리
          "^.turbo/",        -- Turborepo 캐시 디렉토리
          "^.next/",         -- Next.js 빌드 디렉토리
          "^.nuxt/",         -- Nuxt.js 빌드 디렉토리
          "^.svelte-kit/",   -- SvelteKit 빌드 디렉토리
          "^.vercel/",       -- Vercel 배포 캐시 디렉토리
          "^.netlify/",      -- Netlify 배포 캐시 디렉토리
          "^pnpm-lock.yaml", -- pnpm-lock.yaml 파일
          "^package-lock.json", -- package-lock.json 파일
          "^yarn.lock",      -- yarn.lock 파일
        },
        hidden = true,  -- 숨김 파일 검색 활성화
      },
      pickers = {
        find_files = {
          find_command = {
            "rg",
            "--files",        -- 파일 목록만 출력
            "--hidden",       -- 숨김 파일 포함
            "--no-ignore",    -- .gitignore 및 .ignore 규칙 무시
            "--glob", "!**/.git/*",       -- .git 디렉토리 제외
            "--glob", "!**/node_modules/*", -- node_modules 디렉토리 제외
            "--glob", "!**/.idea/*",      -- .idea 디렉토리 제외
            "--glob", "!**/.vscode/*",    -- .vscode 디렉토리 제외
            "--glob", "!**/.pnpm-store/*", -- pnpm 저장소 디렉토리 제외
            "--glob", "!**/.cache/*",     -- 캐시 디렉토리 제외
            "--glob", "!**/.yarn/*",      -- Yarn 캐시 디렉토리 제외
            "--glob", "!**/.turbo/*",    -- Turborepo 캐시 디렉토리 제외
            "--glob", "!**/.next/*",     -- Next.js 빌드 디렉토리 제외
            "--glob", "!**/.nuxt/*",     -- Nuxt.js 빌드 디렉토리 제외
            "--glob", "!**/.svelte-kit/*", -- SvelteKit 빌드 디렉토리 제외
            "--glob", "!**/.vercel/*",   -- Vercel 배포 캐시 디렉토리 제외
            "--glob", "!**/.netlify/*",  -- Netlify 배포 캐시 디렉토리 제외
            -- "--glob", "!**/*-[A-Za-z0-9_]*", -- 해시가 포함된 파일 제외
          },
        },
        live_grep = {
          additional_args = function(opts)
            return {
              "--hidden",       -- 숨김 파일 포함
              "--no-ignore",    -- .gitignore 및 .ignore 규칙 무시
              "--max-filesize", "1M",  -- 1MB 이상 파일 제외
              "--glob", "!**/.git/*",       -- .git 디렉토리 제외
              "--glob", "!**/node_modules/*", -- node_modules 디렉토리 제외
              "--glob", "!**/.idea/*",      -- .idea 디렉토리 제외
              "--glob", "!**/.vscode/*",    -- .vscode 디렉토리 제외
              "--glob", "!**/.pnpm-store/*", -- pnpm 저장소 디렉토리 제외
              "--glob", "!**/.cache/*",     -- 캐시 디렉토리 제외
              "--glob", "!**/.yarn/*",      -- Yarn 캐시 디렉토리 제외
              "--glob", "!**/.turbo/*",    -- Turborepo 캐시 디렉토리 제외
              "--glob", "!**/.next/*",     -- Next.js 빌드 디렉토리 제외
              "--glob", "!**/.nuxt/*",     -- Nuxt.js 빌드 디렉토리 제외
              "--glob", "!**/.svelte-kit/*", -- SvelteKit 빌드 디렉토리 제외
              "--glob", "!**/.vercel/*",   -- Vercel 배포 캐시 디렉토리 제외
              "--glob", "!**/.netlify/*",  -- Netlify 배포 캐시 디렉토리 제외
              "--glob", "!**/dist/*",      -- dist 디렉토리 제외
              "--glob", "!**/build/*",     -- build 디렉토리 제외
              "--glob", "!**/out/*",       -- out 디렉토리 제외
              "--glob", "!**/pnpm-lock.yaml", -- pnpm-lock.yaml 파일 제외
              "--glob", "!**/package-lock.json", -- package-lock.json 파일 제외
              "--glob", "!**/yarn.lock",   -- yarn.lock 파일 제외
              -- "--glob", "!**/*-[A-Za-z0-9_]*", -- 해시가 포함된 파일 제외
            }
          end,
        },
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
