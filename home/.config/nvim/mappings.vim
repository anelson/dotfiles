" Included from init.vim; not intended to be loaded by itself
"
" Some mappings which control interaction with plugins are set where the
" plugin is loaded, not in this file.

" Use the comma as the leader
let mapleader = ","

" Use jj instead of <ESC> to exit insert mode
" NOTE: I'm experimenting with using Caps Lock for this; maybe this will go
" away soon
inoremap jj <ESC>

" Make a quick shortcut to hide the highlights from a search and close the
" preview window.  Yes they seem unrelated, but they're both annoying
" distractions
nnoremap <Esc><Esc> :nohlsearch<CR>:pclose<CR><ESC>

"## Misc. shortcuts

" Make it easy to open my vimnotes file to note something
nnoremap <Leader>vn :split ~/.config/nvim/vimnotes.txt<CR>

" Search for the word under the cursor in the whole project with grep
" A cheap poor mans 'find usages'
nnoremap <Leader>* :silent grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Need a faster way to close a preview window
nnoremap <Leader>pc :pclose<CR>

" Ditto for quickfix
nnoremap <Leader>qc :cclose<CR>

" Fast saving (but only if there are unsaved changes)
nnoremap <Leader>s :update<CR>

"I like to quickly toggle folds open and closed
nnoremap <Leader>z  za

"This seems contradictory but there's a section in `vimnotes` that has the
"reasoning.  If the current fold is open, `zO` doesn't do anything, but if
"it's closed then `zO` recursively opens all child folds.
nnoremap <Leader>Z  zozczO

