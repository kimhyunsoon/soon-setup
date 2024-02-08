return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    sources = {
      "filesystem",
    },
    source_selector = {
      winbar = false,
    },
    window = {
      mappings = {
        ['t'] = false,
      },
    },
    buffers = {},
    filesystem = {
      filtered_items = {
	      visible = true,
	      show_hidden_count = true,
	      hide_dotfiles = false,
	      hide_gitignored = false,
	      hide_by_name = {
	      },
	      never_show = {},
      },
    },
  },
  -- config = function()
  --   require('neo-tree').setup({
  --     sources = {
  --       "filesystem",
  --     }
  --   });
  -- end
}
