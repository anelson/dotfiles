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

" Same for .vimrc
nnoremap <Leader>vc :split ~/.vimrc<CR>

" Search for the word under the cursor in the whole project with grep
" A cheap poor mans 'find usages'
nnoremap <Leader>* :silent grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Improve the experience in terminal mode
:tnoremap <Esc> <C-\><C-n> "Pressing <ESC> in terminal mode switches to normal mode
:tnoremap <expr> <C-R> '<C-\><C-N>"'.nr2char(getchar()).'pi' "Use Ctrl-R to paste from a register in terminal insert mode

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

"allow buffers to be hidden without saving changes, but confirm on close
"unsaved changes
set hidden
set confirm

set list          " Display unprintable characters f12 - switches
set listchars=tab:•-,trail:•,extends:»,precedes:« " Unprintable chars mapping

set smartcase "assume all-lowercase searches are case insensitive; upper or mixed is case sensitive

" apply the same line number settings to newrw windows
" inspired by https://stackoverflow.com/questions/8730702/how-do-i-configure-vimrc-so-that-line-numbers-display-in-netrw-in-vim?rq=1
let g:netrw_bufsettings = 'noma nomod nu relativenumber nobl nowrap ro'

call plug#begin('~/.vim/plugged')

" CtrlP for fuzzy file/MRU/buffer navigation
Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard'] "respect gitignore
let g:ctrlp_by_filename = 1 "searching by filename is a more sensible default; Ctrl-d in prompt to switch
let g:ctrlp_match_window='bottom,order:ttb' "why would anyone want bottom-to-top by default??
let g:ctrlp_open_new_file='r' " open files in the current window, dont' open a new window or a new tab

if executable('ag')
    " the silver searcher grep alternative is installed so use that
    set grepprg=ag\ --nogroup\ --no-color

    " Also use ag with CtrlP
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

    " ag is fast no need to cache
    let g:ctrlp_use_caching = 0

    " Define an Ag command to invoke the ag search tool
    " Most of the time just using the grep command is find, but this way we also
    " have the option of invoking Ag directly with command line args to override
    " default behaviors
    command! -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!
endif

" Apply tpope's sensible defaults
Plug 'tpope/vim-sensible'

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

" Try to automatically deduce the proper tab settings for a particular file
Plug 'tpope/vim-sleuth'

" Briefly highlight yanked regions for clarity
Plug 'machakann/vim-highlightedyank'

" Enable Ensime for Scala/Java code
Plug 'ensime/ensime-vim'

" Vim-Syntastic for syntax highlighting including Ensime-aware highlighting of
" Scala and Java
" NB: Syntastic runs checks synchronously and blocks the editor while doing so
" For the time being I'm disabling this and trying vim-ale
"Plug 'vim-syntastic/syntastic'

Plug 'w0rp/ale'

" vim-scala plugin to set up vim for scala coding
Plug 'derekwyatt/vim-scala'

" A lighter version of the powerline plugin
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#ale#enabled = 1
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts=1
let g:airline#extensions#tmuxline#enabled=0 " don't try to sync with tmuxline 

" Use tmuxline to generate a tmux statusline config that matches our airline
" config.  It's a bit odd to use vim code to generate a tmux config, but it's
" that or use a shell script to generate the vim config, and I like this
" better
Plug 'edkolev/tmuxline.vim'
let g:tmuxline_preset = {
      \'a'    : '#S',
      \'win'  : ['#I', '#W'],
      \'cwin' : ['#I', '#W', '#F'],
      \'y'    : ['%R', '%a', '%Y'],
      \'z'    : '#H'}

" Use the same keys to navigate vim windows and tmux panes seamlessly
Plug 'christoomey/vim-tmux-navigator'

" Show git status line by line 
Plug 'airblade/vim-gitgutter'

" Use a fancy plugin to render nested parens in different colors
Plug 'luochen1990/rainbow'

" because netrw tree mode sucks in cruel and unusual ways
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

nnoremap <Leader>f :NERDTreeToggle<Enter>
nnoremap <Leader>F :NERDTreeFind<Enter>
let NERDTreeHijackNetrw = 1 " netrw is crap; NERDTree sucks less
let NERDTreeQuitOnOpen = 1 " I want to force myself to use a vim-like way of exploring
let NERDTreeAutoDeleteBuffer = 1 "No reason to keep the buffer of a deleted file around
let NERDTreeChDirMode = 2 "changing the root in nerdtree changes vim's cwd
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
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

" Need the ability to toggle a single window full screen why is this not built
" in?
" TODO: Maybe bring this back if it is updated to work with latest neovim
"Plug 'regedarek/ZoomWin'

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

" Ensime config
let ensime_server_v2=1

" Underline errors and warnings from ale
"highlight ALEError cterm=underline
"highlight ALEWarning cterm=underline


