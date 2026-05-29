-- 대용량 파일 점진적 처리 정책 (단일 출처, 자원 비용 순 누적 비활성화)
--
-- tier 0 normal  : < 256KB                          전기능 활성
-- tier 1 light   : 256KB ~ 1.5MB                    sha256 해시 / LSP semantic tokens & inlay hints / ibl scope / current_line_blame 차단
-- tier 2 heavy   : 1.5MB ~ 5MB                      + treesitter / ufo / colorizer / ibl / gitsigns / cmp / fold 비활성
-- tier 3 minimal : 5MB+ 또는 라인 > 5000자(미니파이)  + LSP detach / regex syntax off / swap·undo off / synmaxcol 200
--
-- 플러그인은 require('bigfile').tier(buf) 또는 vim.b[buf].bigfile_tier 만 보고 동작을 결정한다.

local M = {}

-- 임계값
M.size = {
  tier1 = 256 * 1024,
  tier2 = 1.5 * 1024 * 1024,
  tier3 = 5 * 1024 * 1024,
}
M.long_line_limit = 5000
M.sample_head = 256
M.sample_tail = 64

---@param buf integer|nil
---@return integer
function M.tier(buf)
  buf = buf or 0
  if buf == 0 then buf = vim.api.nvim_get_current_buf() end
  if not vim.api.nvim_buf_is_valid(buf) then return 0 end
  return vim.b[buf].bigfile_tier or 0
end

---@param buf integer|nil
---@param min integer|nil 비교할 최소 티어 (기본 2)
---@return boolean
function M.at_least(buf, min)
  return M.tier(buf) >= (min or 2)
end

---@param size integer
---@return integer
local function tier_for_size(size)
  if size > M.size.tier3 then return 3 end
  if size > M.size.tier2 then return 2 end
  if size > M.size.tier1 then return 1 end
  return 0
end

---@param buf integer
---@return integer, string|nil
local function detect_size(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == '' then return 0, nil end
  local ok, stat = pcall(vim.loop.fs_stat, name)
  if not ok or not stat or not stat.size then return 0, nil end
  return tier_for_size(stat.size), string.format('%.1fMB', stat.size / 1048576)
end

-- 미니파이/긴 라인은 즉시 최상위 티어
---@param buf integer
---@return boolean, string|nil
local function detect_long_lines(buf)
  if not vim.api.nvim_buf_is_loaded(buf) then return false, nil end
  local total = vim.api.nvim_buf_line_count(buf)
  local function scan(s, e)
    for i = s, e - 1 do
      local line = vim.api.nvim_buf_get_lines(buf, i, i + 1, false)[1]
      if line and #line > M.long_line_limit then
        return true, string.format('long line %d', #line)
      end
    end
    return false, nil
  end
  local head = math.min(total, M.sample_head)
  local hit, reason = scan(0, head)
  if hit then return hit, reason end
  if total > head then
    return scan(math.max(head, total - M.sample_tail), total)
  end
  return false, nil
end

-- 티어별 누적 비활성 적용 (idempotent)
---@param buf integer
---@param tier integer
local function apply_tier(buf, tier)
  if not vim.api.nvim_buf_is_valid(buf) then return end

  -- tier 1+ : 비싼 보조 기능
  if tier >= 1 then
    -- ibl scope 하이라이트만 끔 (선/들여쓰기 표시는 유지)
    local ok_ibl, ibl = pcall(require, 'ibl')
    if ok_ibl then
      pcall(ibl.setup_buffer, buf, { scope = { enabled = false } })
    end
    -- LSP semantic tokens & inlay hints 차단
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      if c.server_capabilities then
        c.server_capabilities.semanticTokensProvider = nil
        c.server_capabilities.inlayHintProvider = nil
      end
    end
    pcall(vim.lsp.inlay_hint.enable, false, { bufnr = buf })
  end

  -- tier 2+ : 트리시터/플러그인 본격 축소
  if tier >= 2 then
    pcall(vim.treesitter.stop, buf)
    -- colorizer detach
    local ok_cl, colorizer = pcall(require, 'colorizer')
    if ok_cl and colorizer.detach_from_buffer then
      pcall(colorizer.detach_from_buffer, buf)
    end
    -- ibl 전체 비활성
    local ok_ibl, ibl = pcall(require, 'ibl')
    if ok_ibl then pcall(ibl.setup_buffer, buf, { enabled = false }) end
    -- gitsigns detach
    local ok_gs, gs = pcall(require, 'gitsigns')
    if ok_gs then pcall(gs.detach, buf) end
    -- 폴드 / 무거운 윈도우 옵션
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      vim.api.nvim_win_call(win, function()
        vim.wo.foldenable = false
        vim.wo.foldmethod = 'manual'
        vim.wo.spell = false
      end)
    end
  end

  -- tier 3 : 미니멀 모드
  if tier >= 3 then
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      pcall(vim.lsp.buf_detach_client, buf, c.id)
    end
    vim.bo[buf].syntax = ''
    vim.bo[buf].swapfile = false
    vim.bo[buf].undofile = false
    vim.bo[buf].bufhidden = 'unload'
    vim.bo[buf].synmaxcol = 200
    pcall(vim.api.nvim_set_option_value, 'undolevels', 100, { buf = buf })
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      vim.api.nvim_win_call(win, function()
        vim.wo.wrap = false
        vim.wo.cursorline = false
        vim.wo.list = false
        vim.wo.colorcolumn = ''
      end)
    end
  end
end

local LABEL = { [1] = '경량', [2] = '중량', [3] = '최소' }

-- 티어를 상향만 가능하게 설정 (하향 금지)
---@param buf integer
---@param new_tier integer
---@param reason string|nil
local function bump(buf, new_tier, reason)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local cur = vim.b[buf].bigfile_tier or 0
  if new_tier <= cur then return end
  vim.b[buf].bigfile_tier = new_tier
  vim.b[buf].bigfile = new_tier >= 2 -- 편의 플래그
  vim.b[buf].bigfile_reason = reason

  -- BufReadPre 시점부터 즉시 효과를 보는 옵션만 직접 적용 (tier 3 경우)
  if new_tier >= 3 then
    vim.bo[buf].swapfile = false
    vim.bo[buf].undofile = false
    vim.bo[buf].bufhidden = 'unload'
  end

  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(buf) then return end
    apply_tier(buf, new_tier)
    vim.api.nvim_exec_autocmds('User', {
      pattern = 'BigFile',
      modeline = false,
      data = { buf = buf, tier = new_tier },
    })
    vim.notify(
      string.format('대용량 파일 %s 모드 [tier %d] (%s)', LABEL[new_tier] or '', new_tier, reason or ''),
      vim.log.levels.INFO
    )
  end)
end

---@param buf integer
function M.check(buf)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  local t, reason = detect_size(buf)
  if t > 0 then bump(buf, t, reason) end
  local long, lreason = detect_long_lines(buf)
  if long then bump(buf, 3, lreason) end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('BigFile', { clear = true })

  -- 크기 기반 사전 감지 (플러그인 BufReadPre 핸들러보다 먼저 실행되도록 lazy.setup 앞에서 호출됨)
  vim.api.nvim_create_autocmd({ 'BufReadPre', 'FileReadPre' }, {
    group = group,
    callback = function(args)
      local t, reason = detect_size(args.buf)
      if t > 0 then bump(args.buf, t, reason) end
    end,
  })

  -- 로드 후 라인 길이 기반 감지 (미니파이 파일은 크기가 작아도 무거움)
  vim.api.nvim_create_autocmd({ 'BufReadPost', 'FileReadPost' }, {
    group = group,
    callback = function(args)
      local long, reason = detect_long_lines(args.buf)
      if long then bump(args.buf, 3, reason) end
    end,
  })

  -- 뒤늦게 attach되는 LSP 클라이언트에도 티어 정책 적용
  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(args)
      local t = M.tier(args.buf)
      if t == 0 then return end
      if t >= 3 then
        vim.schedule(function()
          pcall(vim.lsp.buf_detach_client, args.buf, args.data.client_id)
        end)
        return
      end
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client and client.server_capabilities then
        client.server_capabilities.semanticTokensProvider = nil
        client.server_capabilities.inlayHintProvider = nil
      end
      pcall(vim.lsp.inlay_hint.enable, false, { bufnr = args.buf })
    end,
  })
end

return M
