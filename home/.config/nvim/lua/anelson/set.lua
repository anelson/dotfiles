-- Set color settings
-- according to the answer at https://vi.stackexchange.com/questions/3576/trouble-using-color-scheme-in-neovim
-- one should not ever set t_Co in neovim
-- set t_Co=256 -- tell vim our terminal supports 256 colors (it does, right)
vim.opt.termguicolors = true   -- if the term supports 24-bit color even better

vim.cmd.colorscheme("gruvbox") -- activate my current preferred scheme
vim.opt.background = "dark"    -- specifically the dark variant

-- At the terminal level at least, don't se a background.  To support terminals with translucent bg
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

-- Swap and Undo

-- completely disable swap files.  I've never once had my ass saved by this
-- feature, and I've been nagged about already-existing swap files at least a
-- million times already.  Enough.
vim.opt.swapfile = false

-- disable backup, because it conflicts with coc.vim and is generally useless
-- anyway (https://github.com/neoclide/coc.nvim/issues/649)
vim.opt.backup = false
vim.opt.writebackup = false

-- Keep undo files in the .vim directory where they wont' bother anyone
vim.opt.undodir = vim.fn.expand('~/.vim/undo//')
vim.opt.undofile = true

-- make sure that directories exists.  for obvious reasons they're not in git.
if vim.fn.isdirectory(vim.fn.expand('~/.vim/undo')) == 0 then
	vim.fn.mkdir(vim.fn.expand('~/.vim/undo'), 'p', 0755)
end

-- Line numbering

-- Use relative line numbers
vim.opt.relativenumber = true

-- Show the absolute line number of the current line
vim.opt.number = true

-- Tabs defaults

-- Configure sane defaults for tabs
vim.opt.tabstop = 8 -- make actual tabs very ugly so we notice them
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

-- Buffer (non)annoyingness policy
vim.o.hidden = true
vim.o.confirm = true

-- Auto saving when leaving insert mode
vim.cmd [[ autocmd InsertLeave * silent! update ]]

-- Showing unprintable characters
vim.o.list = true
vim.o.listchars = "tab:•-,trail:•,extends:»,precedes:«"

-- Assorted other tweaks
vim.o.updatetime = 50
vim.o.cmdheight = 2
vim.o.smartcase = true
vim.o.diffopt = vim.o.diffopt .. ",vertical"
vim.o.conceallevel = 3
vim.o.splitright = true
vim.o.splitbelow = true

vim.g.netrw_bufsettings = 'noma nomod nu relativenumber nobl nowrap ro'

if vim.fn.executable('rg') == 1 then
	vim.o.grepprg = 'rg --vimgrep'
elseif vim.fn.executable('ag') == 1 then
	vim.o.grepprg = 'ag --nogroup --no-color'
end


-- Overriding vim paste behavior
vim.keymap.set("n", "p", "gp", {})
vim.keymap.set("n", "P", "gP", {})
vim.keymap.set("n", "gp", "p", {})
vim.keymap.set("n", "gP", "P", {})

-- Automatically turn off highlighted search after it's not needed using
-- the incsearch auto_nohlsearch feature
vim.o.hlsearch = true
vim.g.incsearch_auto_nohlsearch = 1

-- Preserve not only the cursor position but also the location of the cursor
-- on the screen when switching between buffers in a window.
local save_cursor = require('anelson.save_cursor')

-- requires neovim 0.5 or greater
-- save and restore window view settings on buf leave/enter
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local save_cursor_aug = augroup("save_cursor", {})
autocmd({ "BufLeave" }, {
	group = save_cursor_aug,
	pattern = "*",
	callback = function()
		save_cursor.auto_save_win_view()
	end
})
autocmd({ "BufEnter" }, {
	group = save_cursor_aug,
	pattern = "*",
	callback = function()
		save_cursor.auto_restore_win_view()
	end
})
