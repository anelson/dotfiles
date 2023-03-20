vim.g.mapleader = ","

-- TODO: these aren't needed in Neovim right?  They're on by default?
-- vim.cmd('filetype plugin indent on')
-- vim.cmd('syntax on') -- enable syntax highlighting

-- Basic config settings

-- Use jj instead of <ESC> to exit insert mode
-- NOTE: I'm experimenting with using Caps Lock for this; maybe this will go
-- away soon
vim.keymap.set('i', 'jj', '<ESC>')

-- Make a quick shortcut to hide the highlights from a search and close the
-- preview window.  Yes they seem unrelated, but they're both annoying
-- distractions
vim.keymap.set('n', '<Esc><Esc>', ':nohlsearch<CR>:pclose<CR><ESC>', { noremap = true })

-- Misc. shortcuts

-- Make it easy to open my vimnotes file to note something
vim.keymap.set('n', '<Leader>vn', ':split ~/.vim/vimnotes.txt<CR>', { noremap = true })

-- Same for .vimrc
vim.keymap.set('n', '<Leader>vc', ':split ~/.vimrc<CR>', { noremap = true })

-- Search for the word under the cursor in the whole project with grep
-- A cheap poor mans 'find usages'
vim.keymap.set('n', '<Leader>*', ':silent grep! "\\b<C-R><C-W>\\b"<CR>:cw<CR>', { noremap = true })

-- Need a faster way to close a preview window
vim.keymap.set('n', '<Leader>pc', ':pclose<CR>', { noremap = true })

-- Ditto for quickfix
vim.keymap.set('n', '<Leader>qc', ':cclose<CR>', { noremap = true })

-- Fast saving (but only if there are unsaved changes)
vim.keymap.set('n', '<Leader>s', ':update<CR>', { noremap = true })

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
