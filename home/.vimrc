set nocompatible              " be iMproved, required
filetype off                  " required

" Use the comma as the leader
let mapleader = ","

" Use jj instead of <ESC> to exit insert mode
inoremap jj <ESC>

" Make a quick shortcut to hide the highlights from a search
nnoremap <Leader>h :noh<CR><ESC>

" Make it easy to open my vimnotes file to note something
nnoremap <Leader>vn :split ~/.vim/vimnotes.txt<CR>

" Use relative line numbers
set relativenumber

" Show the absolute line number of the current line
set number

" Use a faster updatetime to vim-gutter reflects changes faster
" TODO: Make sure this doesn't slow things down
set updatetime=250

" Configure sane defaults for tabs
set tabstop=8 "make actual tabs very ugly so we notice them
set softtabstop=4
set shiftwidth=4
set noexpandtab

" apply the same line number settings to newrw windows
" inspired by https://stackoverflow.com/questions/8730702/how-do-i-configure-vimrc-so-that-line-numbers-display-in-netrw-in-vim?rq=1
let g:netrw_bufsettings = 'noma nomod nu relativenumber nobl nowrap ro'

call plug#begin('~/.vim/plugged')

" CtrlP for fuzzy file/MRU/buffer navigation
Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard'] "respect gitignore

" Use vim-surround for quoting/parenthesizing
Plug 'tpope/vim-surround'

" repeat.vim to support repeating vim-surround operations with .
Plug 'tpope/vim-repeat'

" unimpaired to add convenient short aliases for next/previous things
Plug 'tpope/vim-unimpaired'

" add some 'vinegar' (inside joke) to netrw so it sucks less and maybe
" NERDtree isn't needed
Plug 'tpope/vim-vinegar'

" Add git integration to vim
Plug 'tpope/vim-fugitive'

" Briefly highlight yanked regions for clarity
Plug 'machakann/vim-highlightedyank'

" Enable Ensime for Scala/Java code
Plug 'ensime/ensime-vim'

" Vim-Syntastic for syntax highlighting including Ensime-aware highlighting of
" Scala and Java
Plug 'vim-syntastic/syntastic'

" vim-scala plugin to set up vim for scala coding
Plug 'derekwyatt/vim-scala'

" A lighter version of the powerline plugin
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts=1

" Show git status line by line 
Plug 'airblade/vim-gitgutter'

" Use a fancy plugin to render nested parens in different colors
Plug 'luochen1990/rainbow'

" because netrw tree mode sucks in cruel and unusual ways
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

let NERDTreeHijackNetrw = 1 " netrw is crap; NERDTree sucks less
let NERDTreeQuitOnOpen = 1 " I want to force myself to use a vim-like way of exploring
let NERDTreeShowLineNumbers = 1 " I am addicted to navigation by line number
autocmd FileType nerdtree setlocal relativenumber " make sure relative line numbers are used

" add smarter commenting-out logic
Plug 'scrooloose/nerdcommenter'

" UltiSnips which depends on vim-snippets
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips' 
let g:UltiSnipsExpandTrigger = '<TAB>'
let g:UltiSnipsJumpForwardTrigger = '<C-j>'
let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

" Use the autocompleter
Plug 'Valloric/YouCompleteMe'
let g:ycm_key_list_select_completion = ['<C-j>', '<Down>'] "Avoid collisions with UltiSnips
let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>'] "Avoid collisions with UltiSnips

" I simply MUST have automatic insertion of closing delimiters
Plug 'Raimondi/delimitMate'
let delimitMate_expand_cr = 1 "automatically indent within braces when Enter is pressed

" Load some themes
Plug 'dracula/vim'
Plug 'altercation/vim-colors-solarized'

" add some goodness to the neovim terminal
if has('nvim')
  Plug 'kassio/neoterm'
endif


" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
"Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
"Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Group dependencies, vim-snippets depends on ultisnips
"Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
"Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
"Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-master branch
" Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
" Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
" Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
" Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Unmanaged plugin (manually installed and updated)
" Plug '~/my-prototype-plugin'

" Add plugins to &runtimepath
call plug#end()

syntax on "enable syntax highlighting
set t_Co=256 "tell vim our terminal supports 256 colors (it does, right))
" color dracula "Use the Dracula color scheme
colorscheme solarized "use the solarized scheme
set background=dark "specifically the dark variant

"Syntastic config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" The Syntastic checks on open and populating the location list is rather
" overbearing. 
" TODO: If this config works remove these commented-out lines
" let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
" let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Ensime config
let ensime_server_v2=1

