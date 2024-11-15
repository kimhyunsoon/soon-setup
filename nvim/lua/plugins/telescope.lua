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
    "nvim-telescope/telescope-ui-select.nvim",
    'tsakirist/telescope-lazy.nvim',
  },
  config = function()
    require("telescope").load_extension("ui-select")
    require('telescope').setup({
      defaults = {
        prompt_prefix = "  ",
        selection_caret = "  ",
        multi_icon = "  ",
        entry_prefix = "   ",
        path_display = { 'truncate' },
        sorting_strategy = 'ascending',
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
    })
    vim.cmd([[
      highlight! link TelescopeSelection TabLine
    ]])
  end
}