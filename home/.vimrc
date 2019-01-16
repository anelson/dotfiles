set nocompatible              " be iMproved, required
filetype off                  " required

" put all swap files in one directory so I can easily purge them after a
" laptop hang
set directory=~/.vim/swap,.

" Use the comma as the leader
let mapleader = ","

" Use jj instead of <ESC> to exit insert mode
inoremap jj <ESC>

" Make a quick shortcut to hide the highlights from a search
nnoremap <Esc><Esc> :nohlsearch<CR><ESC>

" Make it easy to open my vimnotes file to note something
nnoremap <Leader>vn :split ~/.vim/vimnotes.txt<CR>

" Same for .vimrc
nnoremap <Leader>vc :split ~/.vimrc<CR>

" Search for the word under the cursor in the whole project with grep
" A cheap poor mans 'find usages'
nnoremap <Leader>* :silent grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Improve the experience in terminal mode
" UPDATE: I disabled this.  I never use terminal mode as a terminal, and
" plugins like fugitive and fzf.vim open terminals that I want to close with
" escape but I can't because of this
" :tnoremap <Esc> <C-\><C-n> "Pressing <ESC> in terminal mode switches to normal mode
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

" diffs should always use a vertical split, why would anyone want horizonal??
set diffopt+=vertical

" enable folding based on the syntax information for a file, but start out
" files with folds fully expanded
set foldmethod=syntax
set foldlevelstart=99

"I like to quickly toggle folds open and closed
nnoremap <Leader>z  za
nnoremap <Leader>Z  zA

set conceallevel=3 "enable all syntax concealing, like rendering _Markdown_ in italics

" to help when writing Russian, enable a Russian keymap in input mode
" This command will make the Russian keymap the default, which isn't quite
" right, but follow along
set keymap=russian-jcukenwin

" Disable the use of a keymap in insert mode, which should make Vim default to
" English (or rather ,whatever the system keyboard layout is) and toggle
" Russian on with CTRL-^
set iminsert=0

" don't remember a separate keymap setting for searching; it should be the
" same as insert mode
set imsearch=-1

" apply the same line number settings to newrw windows
" inspired by https://stackoverflow.com/questions/8730702/how-do-i-configure-vimrc-so-that-line-numbers-display-in-netrw-in-vim?rq=1
let g:netrw_bufsettings = 'noma nomod nu relativenumber nobl nowrap ro'

" If vim-plug isn't present (for example this is a new install)
" then download and initialize it now
" per https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

" CtrlP for fuzzy file/MRU/buffer navigation
Plug 'ctrlpvim/ctrlp.vim'
" also install a compiled fuzzy matcher library for added performance
Plug 'nixprime/cpsm', { 'do': './install.sh' }
" By default <C-p> is mapped to :CtrlP, I want to add a mapping to :CtrlPBuffer
" since I often use that too
"nnoremap <Leader>b :CtrlPBuffer<Enter>

let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard'] "respect gitignore
let g:ctrlp_by_filename = 1 "searching by filename is a more sensible default; Ctrl-d in prompt to switch
let g:ctrlp_match_window='bottom,order:ttb' "why would anyone want bottom-to-top by default??
let g:ctrlp_open_new_file='r' " open files in the current window, dont' open a new window or a new tab
let g:ctrlp_mruf_max = 500 "remember more files
let g:ctrlp_show_hidden = 1 "working with dotfiles requires this
let g:ctrlp_match_func = { 'match': 'cpsm#CtrlPMatch' }

if executable('fd')
   " if present, 'fd' is the best option for listing files
   " ripgrep is meant to search inside files 
   let g:ctrlp_user_command = 'fd --type file --color never --hidden --exclude .git "" %s'
    " fd is fast no need to cache
    let g:ctrlp_use_caching = 0
endif

" optionally use a more powerful external tool for grep
if executable('rg')
    " use ripgrep it's even faster than ag
    set grepprg=rg\ --vimgrep
elseif executable('ag')
    " the silver searcher grep alternative is installed so use that
    set grepprg=ag\ --nogroup\ --no-color
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
" Automatically delete ephemeral fugitive buffers so they don't drive me mad
autocmd BufReadPost fugitive://* set bufhidden=delete

" Try to automatically deduce the proper tab settings for a particular file
Plug 'tpope/vim-sleuth'

" Implement async background running of compiles and tests.  Not used directly
" but this makes vim-test better
Plug 'tpope/vim-dispatch'

" support saving vim sessions and restoring them later
" this is used with the tmux plugin tmux-resurrect 
Plug 'tpope/vim-obsession'

" detect and handle Jekyll files which have YAML front matter and Liquid
" templates
Plug 'tpope/vim-liquid'

" Briefly highlight yanked regions for clarity
Plug 'machakann/vim-highlightedyank'

" Enable Ensime for Scala/Java code
Plug 'ensime/ensime-vim'

" ALE for syntax highlighting including Ensime-aware highlighting of
" Scala and Java
Plug 'w0rp/ale'
" I am worried the ALE linters conflict with the LSP support which I've
" enabled for rust.  TODO: If other languages are enabled exclude them from ALE also
let g:ale_linters = { 
\ 'rust': [ ], 
\}

" vim-scala plugin to set up vim for scala coding
Plug 'derekwyatt/vim-scala'

" rust support
Plug 'rust-lang/rust.vim'
let g:rustfmt_autosave = 1 " automatically rustfmt on save

" markdown support plugins
"Plug 'tpope/vim-markdown' "trying the platicboy/vim-markdown for richer
"Jekyll support
Plug 'godlygeek/tabular' " required by vim-markdown to support Markdown table formatting

Plug 'plasticboy/vim-markdown'
let g:vim_markdown_math = 1	"enable LaTeX syntax highlighting in markdown
let g:vim_markdown_frontmatter = 1 "enable YAML front matter highlighting for Jekyll content

Plug 'reedes/vim-pencil' " modify vim to behave better when writing prose
augroup pencil
  autocmd!
  " automatically enable pencil on common text editing tasks
  autocmd FileType markdown,mkd,text call pencil#init({'wrap': 'hard', 'autoformat': 0 })
						\ | set textwidth=120
						\ | setlocal spell spelllang=en_us,ru

  " regretably, the 'autoformat' feature doesn't play well with vimwiki.  it
  " seems to bind <CR> in insert mode to something that results in newlines
  " not being inserted into the text.  I can't be bothered to figure out why.
  " I think there's a bug report on vim-pencil related to this
  " incompatibility:
  " [here](https://github.com/reedes/vim-pencil/issues/45)
  autocmd FileType vimwiki call pencil#init({'wrap': 'hard', 'autoformat': 0 })
						\ | set textwidth=120
						\ | setlocal spell spelllang=en_us,ru
augroup END

" vimwiki related plugins
Plug 'vimwiki/vimwiki'
let g:vimwiki_list = [
	    \ { 'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.mkd'},
	    \ { 'path': '~/vimwiki/русский', 'syntax': 'markdown', 'ext': '.mkd'}
	\ ]

" A lighter version of the powerline plugin
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#ale#enabled = 1
let g:airline_theme='gruvbox'
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

" LSP client for those languages that provide a language server
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
" TODO: add other languages' LSP configs here over time, and make sure if you add other languages here that you disable
" ALE linters above so they don't step on each other
let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'nightly', 'rls']
    \ }
"FIXME: LanguageClient tries to create ad-hoc snippets for method calls but
"the snippet plugin isn't involved so the result is craptastic
"for now disable this until
"https://github.com/autozimu/LanguageClient-neovim/issues/379 is fixed
let g:LanguageClient_hasSnippetSupport = 0

nnoremap <F5> :call LanguageClient_contextMenu()<CR>

" Use the autocompleter
" Trying out deoplete instead of YCM due to LSP support in deoplete
"Plug 'Valloric/YouCompleteMe'
"let g:ycm_key_list_select_completion = ['<C-j>', '<Down>'] "Avoid collisions with UltiSnips
"let g:ycm_key_list_previous_completion = ['<C-k>', '<Up>'] "Avoid collisions with UltiSnips
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_complete_start_length = 1
let g:deoplete#enable_smart_case = 1

" Trying out neosnippet for its integration with deoplete
"" UltiSnips which depends on vim-snippets
"Plug 'honza/vim-snippets'
"Plug 'SirVer/ultisnips' 
"let g:UltiSnipsExpandTrigger = '<TAB>'
"let g:UltiSnipsJumpForwardTrigger = '<C-j>'
"let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

" I simply MUST have automatic insertion of closing delimiters
Plug 'Raimondi/delimitMate'
let delimitMate_expand_cr = 1 "automatically indent within braces when Enter is pressed

" Load some themes
Plug 'dracula/vim'
Plug 'altercation/vim-colors-solarized'
Plug 'morhetz/gruvbox'
let g:gruvbox_italic=1 "alacritty assures me it supports italics
let g:gruvbox_bold=1 "alacritty assures me it supports bold
let g:gruvbox_underline=1 "alacritty assures me it supports underline
let g:gruvbox_undercurl=1 "I don't know if this will work or not but it'd be cool
let g:gruvbox_contrast_dark='medium'

" add some goodness to the neovim terminal
if has('nvim')
  Plug 'kassio/neoterm'
endif

" Use several of the handy haya14busa plugins
Plug 'easymotion/vim-easymotion' " Visually pick motion targets
let g:EasyMotion_do_mapping = 0 "Do not create automatic key mappings I want to control everything!
let g:EasyMotion_smartcase = 1 "use something similar to Vim's smartcase
" Use easymotion's version of 'f' (there's no equivalent of 'F' because it's
" bidi)
map s <Plug>(easymotion-bd-f2)
nmap s <Plug>(easymotion-overwin-f2)
map <Leader><Leader> <Plug>(easymotion-bd-w)

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
map <Leader>L <Plug>(easymotion-bd-jk)
nmap <Leader>L <Plug>(easymotion-overwin-line)

Plug 'haya14busa/incsearch.vim' " Incremental search that works with regex
Plug 'haya14busa/incsearch-easymotion.vim' " Use EasyMotion motions with incsearch matches
Plug 'haya14busa/incsearch-fuzzy.vim' " Do fuzzy incremental searches

" Replace default search with incsearch
map / <Plug>(incsearch-easymotion-/)
map ? <Plug>(incsearch-easymotion-?)
map g/ <Plug>(incsearch-easymotion-stay)

" Automatically turn off highlighted search after it's not needed using
" the incsearch auto_nohlsearch feature
set hlsearch
let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

" use fzf as a plugin
if executable("fzf")
    Plug 'junegunn/fzf' "the basic fzf pluging
    Plug 'junegunn/fzf.vim' "the more advanced one, ships separately

    " when opening a buffer, jump to the existing window if possible
    let g:fzf_buffers_jump = 1

    " fzf.vim provides so many handy commands.  Here are bindings for a few:
    " * Ctrl-T - Files - like ctrl-p but fast
    " * <leader>b - Buffers - like ctrl-p's buffer list but, again, fast
    " * <Leader>h - Helptags - fuzzy search help tags, lolwut??
    " * <Leader>m - History - most recently used files
    nmap <c-t> :Files<CR>
    nmap <Leader>b :Buffers<Enter>
    nmap <Leader>h :Helptags<Enter>
    nmap <Leader>m :History<Enter>

    " Customize fzf colors to match your color scheme
    let g:fzf_colors =
    \ { 'fg':      ['fg', 'Normal'],
      \ 'bg':      ['bg', 'Normal'],
      \ 'hl':      ['fg', 'Comment'],
      \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
      \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
      \ 'hl+':     ['fg', 'Statement'],
      \ 'info':    ['fg', 'PreProc'],
      \ 'border':  ['fg', 'Ignore'],
      \ 'prompt':  ['fg', 'Conditional'],
      \ 'pointer': ['fg', 'Exception'],
      \ 'marker':  ['fg', 'Keyword'],
      \ 'spinner': ['fg', 'Label'],
      \ 'header':  ['fg', 'Comment'] }

    " customize the layout
    let g:fzf_layout = { 'down': '~40%' }
endif

" use a plugin to render indent guides which are helpful dealing with
" indent-based languages like YAML and Python
Plug 'nathanaelkane/vim-indent-guides'
"don't enable on startup
"(it's <Leader>ig to enable btw)
let g:indent_guides_enable_on_vim_startup = 0
"tweak the layout a bit to make it less visually distracting
let g:indent_guides_start_level=1
let g:indent_guides_guide_size=1

" some file types don't fold with syntax and work better with indent. YAML
" specifically.  Fortunately, Theres a Plugin for That (tm)
Plug 'pedrohdz/vim-yaml-folds'

" vim-test makes it easy-ish to run tests in various languages, with some help
" from vim-dispatch
Plug 'janko-m/vim-test'

" use vim-dispatch to handle the actual invocation of the test commands
let test#strategy = "dispatch"
nmap <silent> t<C-n> :TestNearest<CR> " t Ctrl+n
nmap <silent> t<C-f> :TestFile<CR>    " t Ctrl+f
nmap <silent> t<C-s> :TestSuite<CR>   " t Ctrl+s
nmap <silent> t<C-l> :TestLast<CR>    " t Ctrl+l
nmap <silent> t<C-g> :TestVisit<CR>   " t Ctrl+g

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
" according to the answer at https://vi.stackexchange.com/questions/3576/trouble-using-color-scheme-in-neovim
" one should not ever set t_Co in neovim
"set t_Co=256 "tell vim our terminal supports 256 colors (it does, right))
set termguicolors "if the term supports 24-bit color even better
" color dracula "Use the Dracula color scheme
"colorscheme solarized "use the solarized scheme
colorscheme gruvbox
set background=dark "specifically the dark variant

" Ensime config
let ensime_server_v2=1

" Underline errors and warnings from ale
"highlight ALEError cterm=underline
"highlight ALEWarning cterm=underline


