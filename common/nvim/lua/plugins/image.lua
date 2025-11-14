return {
  '3rd/image.nvim',
  event = 'VeryLazy',
  dependencies = {
    {
      'vhyrro/luarocks.nvim',
      priority = 1001,
      opts = {
        rocks = { 'magick' },
      },
    },
  },
  opts = {
    backend = 'kitty',
    integrations = {
      markdown = { enabled = false },
      neorg = { enabled = false },
    },
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
    editor_only_render_when_focused = true,
    hijack_file_patterns = {},
  }
}
