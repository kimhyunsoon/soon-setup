local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

if not pcall(require, "lazy") then
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

vim.api.nvim_set_keymap('n', ':ㅈ', ':w<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ':ㅂ', ':q<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ㅑ', 'i', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ㅛㅛ', 'yy', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ㅇㅇ', 'dd', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ㅔ', 'p', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', 'ㅕ', 'u', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<C-ㄱ>', '<C-r>', { noremap = true, silent = true })

require "lazy_setup"
require "polish"
