-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = LazyVim.safe_keymap_set

map({ "n" }, "<leader>fp", ":Explore<cr>", { desc = "Explore" })
map({ "n" }, "<C-h>", "<cmd> TmuxNavigateLeft<CR>", { desc = "window left" })
map({ "n" }, "<C-k>", "<cmd> TmuxNavigateUp<CR>", { desc = "window Up" })
map({ "n" }, "<C-j>", "<cmd> TmuxNavigateDown<CR>", { desc = "window Down" })
map({ "n" }, "<C-l>", "<cmd> TmuxNavigateRight<CR>", { desc = "window Right" })
map({ "n" }, "<leader>pp", function()
  vim.api.nvim_call_function("setreg", { "+", vim.fn.fnamemodify(vim.fn.expand("%"), ":.") })
  local path = vim.fn.fnamemodify(vim.fn.expand("%"), ":.")
  vim.notify('Copied "' .. path .. '" to the clipboard!')
end, { desc = "Copy Relative Path" })
-- map({ "n" }, "<leader>p", { name = "Filepath commands" })
require("which-key").add({ "<leader>p", group = "Filepath commands" })
map({ "n" }, "<leader>g.", "<cmd> tab G<cr>", { desc = "Git Fugitive" })
