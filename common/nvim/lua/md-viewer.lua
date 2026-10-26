-- 마크다운 정적 뷰어
--
-- 현재 버퍼의 마크다운을 md2html(md4c)로 GitHub 스타일 HTML 파일로 변환해
-- ~/.cache/nvim/md-viewer/<hash>/<파일명>.html 에 저장한다.
-- 브라우저에서는 그냥 file:// 로 열리는 정적 페이지이므로
-- 저장(BufWritePost) 시 HTML 파일만 다시 생성되고, 브라우저는 새로고침해야 반영된다.

local M = {}

local CSS = [[
:root { color-scheme: light dark; }
body { margin: 0; background: #ffffff; color: #1f2328; }
.markdown-body {
  box-sizing: border-box; max-width: 980px; margin: 0 auto; padding: 32px 45px;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans", Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji";
  font-size: 16px; line-height: 1.6; word-wrap: break-word;
}
.markdown-body > :first-child { margin-top: 0 !important; }
.markdown-body h1, .markdown-body h2, .markdown-body h3, .markdown-body h4, .markdown-body h5, .markdown-body h6 {
  margin-top: 24px; margin-bottom: 16px; font-weight: 600; line-height: 1.25;
}
.markdown-body h1 { font-size: 2em; padding-bottom: .3em; border-bottom: 1px solid #d1d9e0; }
.markdown-body h2 { font-size: 1.5em; padding-bottom: .3em; border-bottom: 1px solid #d1d9e0; }
.markdown-body h3 { font-size: 1.25em; }
.markdown-body h4 { font-size: 1em; }
.markdown-body h5 { font-size: .875em; }
.markdown-body h6 { font-size: .85em; color: #59636e; }
.markdown-body p, .markdown-body blockquote, .markdown-body ul, .markdown-body ol, .markdown-body dl,
.markdown-body table, .markdown-body pre { margin-top: 0; margin-bottom: 16px; }
.markdown-body a { color: #0969da; text-decoration: none; }
.markdown-body a:hover { text-decoration: underline; }
.markdown-body blockquote { padding: 0 1em; color: #59636e; border-left: .25em solid #d1d9e0; margin-left: 0; }
.markdown-body ul, .markdown-body ol { padding-left: 2em; }
.markdown-body li + li { margin-top: .25em; }
.markdown-body li.task-list-item { list-style-type: none; margin-left: -1.5em; }
.markdown-body li.task-list-item input { margin: 0 .4em .25em -.2em; vertical-align: middle; }
.markdown-body hr { height: .25em; padding: 0; margin: 24px 0; background-color: #d1d9e0; border: 0; }
.markdown-body img { max-width: 100%; box-sizing: border-box; }
.markdown-body code, .markdown-body pre {
  font-family: ui-monospace, SFMono-Regular, "SF Mono", Menlo, Consolas, "Liberation Mono", monospace;
  font-size: 85%;
}
.markdown-body code { padding: .2em .4em; margin: 0; background-color: #f0f1f2; border-radius: 6px; }
.markdown-body pre { padding: 16px; overflow: auto; line-height: 1.45; background-color: #f6f8fa; border-radius: 6px; }
.markdown-body pre code { padding: 0; margin: 0; background: transparent; border: 0; font-size: 100%; white-space: pre; }
.markdown-body table { display: block; width: max-content; max-width: 100%; overflow: auto; border-spacing: 0; border-collapse: collapse; }
.markdown-body table th { font-weight: 600; }
.markdown-body table th, .markdown-body table td { padding: 6px 13px; border: 1px solid #d1d9e0; }
.markdown-body table tr { background-color: #ffffff; border-top: 1px solid #d1d9e0; }
.markdown-body table tr:nth-child(2n) { background-color: #f6f8fa; }
.markdown-body kbd {
  display: inline-block; padding: 3px 5px; font-size: 11px; line-height: 10px; vertical-align: middle;
  background-color: #f6f8fa; border: 1px solid #d1d9e0; border-bottom-color: #c8d1da; border-radius: 6px; box-shadow: inset 0 -1px 0 #c8d1da;
}
@media (prefers-color-scheme: dark) {
  body { background: #0d1117; color: #e6edf3; }
  .markdown-body h1, .markdown-body h2 { border-bottom-color: #30363d; }
  .markdown-body h6 { color: #8b949e; }
  .markdown-body a { color: #4493f8; }
  .markdown-body blockquote { color: #8b949e; border-left-color: #30363d; }
  .markdown-body hr { background-color: #30363d; }
  .markdown-body code { background-color: #2a2f37; }
  .markdown-body pre { background-color: #161b22; }
  .markdown-body table th, .markdown-body table td { border-color: #30363d; }
  .markdown-body table tr { background-color: #0d1117; border-top-color: #30363d; }
  .markdown-body table tr:nth-child(2n) { background-color: #161b22; }
  .markdown-body kbd { background-color: #161b22; border-color: #30363d; border-bottom-color: #3d444d; box-shadow: inset 0 -1px 0 #3d444d; }
}
]]

-- highlight.js (CDN, 오프라인이면 코드 블록이 그냥 색 없이 보임)
local HLJS = 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0'

local function html_escape(s)
  return (s:gsub('[&<>"]', { ['&'] = '&amp;', ['<'] = '&lt;', ['>'] = '&gt;', ['"'] = '&quot;' }))
end

local function wrap(body, title, base_dir)
  return table.concat({
    '<!DOCTYPE html>',
    '<html lang="ko">',
    '<head>',
    '<meta charset="utf-8">',
    '<meta name="viewport" content="width=device-width, initial-scale=1">',
    '<title>' .. html_escape(title) .. '</title>',
    -- md 파일 기준 상대 경로(이미지 등)가 그대로 동작하도록
    '<base href="' .. vim.uri_from_fname(base_dir) .. '/">',
    '<style>' .. CSS .. '</style>',
    '<link rel="stylesheet" href="' .. HLJS .. '/styles/github.min.css" media="(prefers-color-scheme: light)">',
    '<link rel="stylesheet" href="' .. HLJS .. '/styles/github-dark.min.css" media="(prefers-color-scheme: dark)">',
    '<script src="' .. HLJS .. '/highlight.min.js" defer></script>',
    '<script>document.addEventListener("DOMContentLoaded", function () { if (window.hljs) hljs.highlightAll(); });</script>',
    '</head>',
    '<body><article class="markdown-body">',
    body,
    '</article></body>',
    '</html>',
  }, '\n')
end

-- md 경로 → 캐시 HTML 경로 (같은 파일명이 다른 폴더에 있어도 충돌하지 않도록 경로 해시로 하위 폴더 분리)
local function html_path(md_path)
  local dir = vim.fn.stdpath('cache') .. '/md-viewer/' .. vim.fn.sha256(md_path):sub(1, 10)
  vim.fn.mkdir(dir, 'p')
  return dir .. '/' .. vim.fn.fnamemodify(md_path, ':t:r') .. '.html'
end

-- 버퍼 내용을 변환해 HTML 파일로 쓴다. 성공 시 HTML 경로, 실패 시 nil
function M.render(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local md_path = vim.api.nvim_buf_get_name(bufnr)
  if md_path == '' then
    vim.notify('md-viewer: 저장되지 않은 버퍼는 열 수 없습니다', vim.log.levels.WARN)
    return nil
  end

  if vim.fn.executable('md2html') ~= 1 then
    vim.notify('md-viewer: md2html 이 없습니다 (arch: pacman -S md4c / mac: brew install md4c)', vim.log.levels.ERROR)
    return nil
  end

  -- 저장 여부와 상관없이 현재 버퍼 내용을 변환 (stdin)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local body = vim.fn.system({ 'md2html', '--github' }, lines)
  if vim.v.shell_error ~= 0 then
    vim.notify('md-viewer: md2html 실패\n' .. body, vim.log.levels.ERROR)
    return nil
  end

  local out = html_path(md_path)
  local html = wrap(body, vim.fn.fnamemodify(md_path, ':t'), vim.fn.fnamemodify(md_path, ':h'))
  local ok, err = pcall(vim.fn.writefile, vim.split(html, '\n', { plain = true }), out)
  if not ok then
    vim.notify('md-viewer: HTML 쓰기 실패: ' .. tostring(err), vim.log.levels.ERROR)
    return nil
  end

  -- 이후 저장할 때마다 HTML 재생성 (브라우저에서 새로고침하면 반영)
  local group = vim.api.nvim_create_augroup('md-viewer-' .. bufnr, { clear = true })
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = group,
    buffer = bufnr,
    callback = function() M.render(bufnr) end,
  })

  return out
end

return M
