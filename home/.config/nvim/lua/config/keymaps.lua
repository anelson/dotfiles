-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Basic config settings

-- Use jj instead of <ESC> to exit insert mode
-- NOTE: I'm experimenting with using Caps Lock for this; maybe this will go
-- away soon
vim.keymap.set("i", "jj", "<ESC>")

-- Make a quick shortcut to hide the highlights from a search and close the
-- preview window.  Yes they seem unrelated, but they're both annoying
-- distractions
vim.keymap.set("n", "<Esc><Esc>", ":nohlsearch<CR>:pclose<CR><ESC>", { noremap = true })

-- Misc. shortcuts

-- Make it easy to open my vimnotes file to note something
vim.keymap.set("n", "<Leader>vn", ":split ~/.vim/vimnotes.txt<CR>", { noremap = true })

-- Same for .vimrc
vim.keymap.set("n", "<Leader>vc", ":split ~/.vimrc<CR>", { noremap = true })

-- Search for the word under the cursor in the whole project with grep
-- A cheap poor mans 'find usages'
vim.keymap.set("n", "<Leader>*", ':silent grep! "\\b<C-R><C-W>\\b"<CR>:cw<CR>', { noremap = true })

-- Need a faster way to close a preview window
vim.keymap.set("n", "<Leader>pc", ":pclose<CR>", { noremap = true })

-- Ditto for quickfix
vim.keymap.set("n", "<Leader>qc", ":cclose<CR>", { noremap = true })

-- Fast saving (but only if there are unsaved changes)
vim.keymap.set("n", "<Leader>U", ":update<CR>", { noremap = true })

-- Folding
vim.keymap.set("n", vim.g.mapleader .. "z", "za", {})
vim.keymap.set("n", vim.g.mapleader .. "Z", "zozczO", {})

-- Typing in Russian
vim.o.keymap = "russian-jcukenwin"
vim.o.iminsert = 0
vim.o.imsearch = -1

-- move selected blocks up and down (hat tip: the primeagean)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Use the old NERCommenter key bindings with the built-in neovim comment handling
vim.keymap.set("n", "<Leader>c<Space>", ":echo Use built-in gcc", { noremap = true })

-- Use <Tab> as "Super-Tab", accept copilot suggestions if there are any, otherwise do whatever
-- else Tab is bound to.
--
-- Based on https://github.com/zbirenbaum/copilot.lua/discussions/153
vim.keymap.set("i", "<Tab>", function()
  if require("copilot.suggestion").is_visible() then
    require("copilot.suggestion").accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
  end
end, { desc = "Super Tab" })
