return {
  colorscheme = "sonokai",
  options = {
    opt = {
      relativenumber = false,
    },
  }, 
  lsp = {
    formatting = {
      format_on_save = false,
    },
  },
  plugins = {
    {
      "nvim-telescope/telescope.nvim",
      requires = {{"nvim-lua/popup.nvim"}, {"nvim-lua/plenary.nvim"}},
      config = function()
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

        require('telescope').setup {
          defaults = {
            path_display = { "truncate" },
            sorting_strategy = "ascending",
            layout_config = {
              horizontal = { prompt_position = "top", preview_width = 0.55 },
              vertical = { mirror = false },
              width = 0.87,
              height = 0.80,
              preview_cutoff = 120,
            },
            mappings = {
              i = {
                ["<CR>"] = select_one_or_multi,
              }
            },
          }
        }
      end,
    },
    {
      "sainnhe/sonokai",
      init = function()
        vim.g.sonokai_style = "shusia";
        vim.g.sonokai_disable_italic_comment = 1;
        vim.g.sonokai_colors_override = {
          bg_dim = {"#000000", 232},
          bg0 = {"#000000", 235},
          bg1 = {"#111111", 236},
          bg2 = {"#111111", 236},
          bg3 = {"#222222", 237},
          bg4 = {"#222222", 237},
        };
      end,
    },
  },
}

