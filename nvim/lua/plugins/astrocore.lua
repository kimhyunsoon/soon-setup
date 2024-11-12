local function move_cursor_by_word(is_end_key)
  if is_end_key == nil then is_end_key = true end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local current_line = vim.api.nvim_get_current_line()
  local line_length = string.len(current_line)
  local current_word = current_line:match("%w+", cursor[2])
  if is_end_key then
    if cursor[2] == line_length then
      return false
    end
  else
    local space_count = #current_line:match("^%s*")
    if (cursor[2] - space_count) <= 0 then
      return false
    else
      return true
    end
  end

  if current_word == nil or cursor[2] + #current_word == line_length then
    return true
  else
    return false
  end
end

return {
  "AstroNvim/astrocore",
  opts = {
    diagnostics = {
      virtual_text = false,
    },
    performance = {
      disable_unneeded_features = true,
    },
    options = {
      opt = { -- vim.opt.<key>
        clipboard = "unnamedplus",
        relativenumber = false,
        tabstop = 2,
        shiftwidth = 2,
        softtabstop = 2,
        expandtab = true,

      },
      g = { -- vim.g.<key>
      },
    },
    mappings = {
      [''] = {
        ['c'] = { function()end },
        ['a'] = { function()end },
        ['cc'] = { function()end },
        ['o'] = { function()end },
        ['t'] = { function()end },
        ['<A-Bslash>'] = { function()end },
        ['<Tab>'] = { ':norm>><cr>' },
        ['<S-Tab>'] = { ':norm<<<cr>' },
        ["d"] = { '"_d', noremap = true, silent = true },
        ["dd"] = { '"_dd', noremap = true, silent = true },
        ["p"] = { 'p:let @+=@0<CR>', noremap = true, silent = true },
      },
      x = {
        ['i'] = { [[<Esc>i]] },
      },
      i = {
        ['<Home>'] = {
          function()
            if move_cursor_by_word(false) then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Left>", true, false, true), 'n', false)
            else
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Left><End>", true, false, true), 'n', false)
            end
          end
        },
        ['<End>'] = {
          function()
            if move_cursor_by_word(true) then
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<End>", true, false, true), 'n', false)
            else
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<S-Right>", true, false, true), 'n', false)
            end
          end
        },
        ['<C-u>'] = { [[<Esc>:undo<cr>i]] },
        ['<C-r>'] = { [[<Esc>:redo<cr>i]] },
      },
      n = {
        ['<leader>w'] = { 'viw', desc = 'Select Current Word' },
        ['<A-[>'] = {
          function() require("astrocore.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
          desc = "Previous buffer",
        },
        ['<A-]>'] = {
          function() require("astrocore.buffer").nav((vim.v.count > 0 and vim.v.count or 1)) end,
          desc = "Next buffer",
        },
        ['<leader>yp'] = {
          function()
            local command = 'let @+ = expand("%:~")'
            vim.cmd(command)
            vim.notify('Copied "' .. vim.fn.expand('%:p') .. '" to the clipboard!')
          end,
          desc = 'Copy Full Path',
        },
        ['<leader>fo'] = {
          ':!open %:p<cr><cr>',
          desc = 'Open File',
        },
        ['<leader>rr'] = {
          ':RunCode<cr>',
          desc = 'Code Run Current File'
        },
        ['<leader>rs'] = {
          function()
            function generate_random_string()
              math.randomseed(os.time())
              local charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
              local length = 8
              local random_string = ""
              for _ = 1, length do
                local random_index = math.random(1, #charset)
                random_string = random_string .. charset:sub(random_index, random_index)
              end
              return random_string
            end
            local command = 'lua vim.api.nvim_put({generate_random_string()}, "c", true, true)'
            vim.cmd(command);
            vim.notify('Generated Random String.')
          end,
          desc = 'Generate Random String',
        }
      },
    },
  },
}
