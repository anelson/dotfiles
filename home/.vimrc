" " vim:fdm=expr:fdl=0
" " vim:fde=getline(v\:lnum)=~'^"#'?'>'.(matchend(getline(v\:lnum),'"#*')-1)\:'='
"
" My .vimrc.  The vim modeline trickery above allows me to create nested folds
" using a sort of Markdown header syntax in VIM comments.  Use `zR` to fully
" expand all the folds, or `za` to toggle folds on a particular line.  Use
" `zv` to expand the folds necessary to reveal the current line.  That's handy
" if you've searched for a string and it is obscured by the folds.

"# Standard boilerplate

set nocompatible              " be iMproved, required
filetype plugin indent on
syntax on "enable syntax highlighting

"# Basic config settings

"## Swap file location

" completely disable swap files.  I've never once had my ass saved by this
" feature, and I've been nagged about already-existing swap files at least a
" million times already.  Enough.
set noswapfile

" disable backup, because it conflicts with coc.vim and is generally useless
" anyway (https://github.com/neoclide/coc.nvim/issues/649)
set nobackup
set nowritebackup

" Keep undo files in the .vim directory where they wont' bother anyone
set undodir=~/.vim/undo//

" make sure that directories exists.  for obvious reasons they're not in git.
if !isdirectory($HOME.'/.vim/undo')
  silent call mkdir ($HOME.'/.vim/undo', 'p')
endif

"## Leader and escape bindings

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
nnoremap <Leader>vn :split ~/.vim/vimnotes.txt<CR>

" Same for .vimrc
nnoremap <Leader>vc :split ~/.vimrc<CR>

" Search for the word under the cursor in the whole project with grep
" A cheap poor mans 'find usages'
nnoremap <Leader>* :silent grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Need a faster way to close a preview window
nnoremap <Leader>pc :pclose<CR>

" Ditto for quickfix
nnoremap <Leader>qc :cclose<CR>

" Fast saving (but only if there are unsaved changes)
nnoremap <Leader>s :update<CR>

"## Line numbering

" Use relative line numbers
set relativenumber

" Show the absolute line number of the current line
set number

"## Tabs defaults

" Configure sane defaults for tabs
set tabstop=8 "make actual tabs very ugly so we notice them
set softtabstop=4
set shiftwidth=4
set noexpandtab

"## Buffer (non)annoyingness policy

"allow buffers to be hidden without saving changes, but confirm on close
"unsaved changes
set hidden
set confirm

"## Auto saving when leaving insert mode
" This silently runs the 'update' command when leaving insert mode.  This is
" preferable to `write` because `update` only does any I/O if there are
" unsaved changes, and `silent!` avoids hassles and prompts if the current
" buffer isn't named.
autocmd InsertLeave * silent! update

"## Preserve not only the cursor position but also the location of the cursor
" on the screen when switching between buffers in a window.  Astonishingly this
" is not the default behavior.
" https://vim.fandom.com/wiki/Avoid_scrolling_when_switch_buffers
function! AutoSaveWinView()
    if !exists("w:SavedBufView")
        let w:SavedBufView = {}
    endif
    let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" Restore current view settings.
function! AutoRestoreWinView()
    let buf = bufnr("%")
    if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
        let v = winsaveview()
        let atStartOfFile = v.lnum == 1 && v.col == 0
        if atStartOfFile && !&diff
            call winrestview(w:SavedBufView[buf])
        endif
        unlet w:SavedBufView[buf]
    endif
endfunction

" When switching buffers, preserve window view.
if v:version >= 700
    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()
endif

"## Showing unprintable characters

set list          " Display unprintable characters f12 - switches
set listchars=tab:•-,trail:•,extends:»,precedes:« " Unprintable chars mapping

"## Assorted other tweaks

" Use a faster updatetime so vim-gutter reflects changes faster, as well as
" whatever LSP plugin we're using
set updatetime=250

" Give more space for displaying messages.
" This is particularly helpful with CoC
set cmdheight=2

set smartcase "assume all-lowercase searches are case insensitive; upper or mixed is case sensitive

" diffs should always use a vertical split, why would anyone want horizonal??
set diffopt+=vertical
set conceallevel=3 "enable all syntax concealing, like rendering _Markdown_ in italics

" when openning vertical splits, they should open to the right
" when openning horizontal splits, they should open below
set splitright
set splitbelow

" apply the same line number settings to newrw windows
" inspired by https://stackoverflow.com/questions/8730702/how-do-i-configure-vimrc-so-that-line-numbers-display-in-netrw-in-vim?rq=1
let g:netrw_bufsettings = 'noma nomod nu relativenumber nobl nowrap ro'

" optionally use a more powerful external tool for grep
if executable('rg')
  " use ripgrep it's even faster than ag
  set grepprg=rg\ --vimgrep
elseif executable('ag')
  " the silver searcher grep alternative is installed so use that
  set grepprg=ag\ --nogroup\ --no-color
endif

"# Folding

" enable folding based on the syntax information for a file, but start out
" files with folds fully expanded
set foldmethod=syntax
set foldlevelstart=99

"I like to quickly toggle folds open and closed
nnoremap <Leader>z  za
"This seems contradictory but there's a section in `vimnotes` that has the
"reasoning.  If the current fold is open, `zO` doesn't do anything, but if
"it's closed then `zO` recursively opens all child folds.
nnoremap <Leader>Z  zozczO

"# Typing in Russian

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

"# Overriding vim paste behavior

" normal vim paste behavior with p or P is to leave the cursor at the
" beginning of the pasted text.  For whatever reason most other editors do the
" opposite, leaving the cursor at the end of the pasted text.  I've gotten
" used to this behavior, so the Vim behavior is jarring.  Often the cursor is
" towards the bottom of the screen, then I `p` some text in and the pasted
" text is scrolled off the screen forcing me to `zz` or `zt` to see what I
" just pasted.
"
" In Vim the bindings `gp` and `gP` are equivalent to `p` and `P` but with the
" cursor at the end of the pasted text.  I want to swap these.
"
" Remember also that '[ and '] are marks that correspond to the beginning and
" end of the last pasted text, respectively, in case you want to move back to
" the beginning of the pasted text
noremap p gp
noremap P gP
noremap gp p
noremap gP P

"# vim-plug

" If vim-plug isn't present (for example this is a new install)
" then download and initialize it now
" per https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"# vim plugins
call plug#begin('~/.vim/plugged')

"## secure modelines alternative since modelines are now disabled by default
"and considered insecure

Plug 'ciaranm/securemodelines'

"## When `.editorconfig` file is present use it to determine editor settings
"like tabs etc

Plug 'editorconfig/editorconfig-vim'

" Don't attempt to apply editorconfig rules to anything Git related, or to
" remote files over SCP
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

"## tpope gets his own section

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

" Provide handy keystrokes for changing the case of a word
Plug 'tpope/vim-abolish'

"## vim-polyglot for language support for over 100 langauges
Plug 'sheerun/vim-polyglot'

"## machakann/vim-highlightedyank

" Briefly highlight yanked regions for clarity
Plug 'machakann/vim-highlightedyank'

"## rust support

Plug 'rust-lang/rust.vim'

" Disable the plugin's auto format, because coc should call rls to do that
let g:rustfmt_autosave = 0 " automatically rustfmt on save
let g:rust_fold = 0 "seems to cause slow rustfmt per https://github.com/rust-lang/rust.vim/issues/293

"## markdown support plugins

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

"## vimwiki related plugins
Plug 'vimwiki/vimwiki'
let g:vimwiki_list = [
      \ { 'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.mkd'},
      \ { 'path': '~/vimwiki/русский', 'syntax': 'markdown', 'ext': '.mkd'}
      \ ]

"## zoom and un-zoom vim windows
Plug 'dhruvasagar/vim-zoom'
" override the default vim keybinding, which makes a window full screen by
" making it the only window (the :only command).  That's, obviously,
" completely useless
nmap <C-w>o <Plug>(zoom-toggle)

"## TOML support
Plug 'cespare/vim-toml'

"## Hashicorp Terraform support
Plug 'hashivim/vim-terraform'

" Auto-format terraform files on save
let g:terraform_fmt_on_save=1

"## coc, the LSP client and autocompleter

" As of 2020-02-24, a bug with the behavior of the codeaction command in the
" release branch makes that critical feature useless.  So for now use the
" latest master.  That's far from ideal.  Switch back to release once this
" commit is in a release:
"
" https://github.com/neoclide/coc.nvim/commit/bf092608a14f3915c39ce1c7057e9c8342c6914c
Plug 'neoclide/coc.nvim', {'branch': 'release'} " Install latest release branch
"Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'} " Install from master and build from source

" Automatically install these CoC extensons.  Most of these are obvious based
" on the name.  Some less obvious ones:
" * css-tssserver - uses tsserver to support javascript and typescript
" * css-rust-analyzer - support Rust using rust-analyzer (and not rust-rls which seems out of date now)
" * coc-calc - evaluate arithmetic expressions right in the editor, wow
" * coc-spell-checker - a spell checker that, unlike vim's, is aware of camelCase
" * coc-cspec-dicts - non-english dictionaries (why would anyone need those??)
" * coc-dicionary - Use the dictionary as a completion source
" * coc-emoji - use the markdown placeholder names for emojits as a completion
" source
" * coc-syntax - Use each language's syntax keywords as a completion source
"
let g:coc_global_extensions = [
  \ 'coc-json',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-tsserver',
  \ 'coc-rust-analyzer',
  \ 'coc-yaml',
  \ 'coc-snippets',
  \ 'coc-markdownlint',
  \ 'coc-calc',
  "\ 'coc-spell-checker',
  \ 'coc-cspell-dicts',
  \ 'coc-dictionary',
  \ 'coc-emoji',
  \ 'coc-syntax',
  "\ 'coc-pairs',
  \ 'coc-actions'
\ ]

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved, which is annoying
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Define some custom commands for interacting with the Rust analyzer
" specifically
command! -nargs=0 RAStatus :CocCommand rust-analyzer.analyzerStatus
command! -nargs=0 RAGarbageCollect :CocCommand rust-analyzer.collectGarbage
command! -nargs=0 RAExpand :CocCommand rust-analyzer.expandMacro
command! -nargs=0 RAParentMod :CocCommand rust-analyzer.parentModule
command! -nargs=0 RAReload :CocCommand rust-analyzer.reload
command! -nargs=0 RARunnables :CocCommand rust-analyzer.run
command! -nargs=0 RARun :CocCommand rust-analyzer.runSingle
command! -nargs=0 RASyntaxTree :CocCommand rust-analyzer.syntaxTree
command! -nargs=0 RAUpgrade :CocCommand rust-analyzer.upgrade

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
"xmap <leader>a  <Plug>(coc-codeaction-selected)
"nmap <leader>a  <Plug>(coc-codeaction-selected)

" Use the coc-action extension to display a floating action menu
"
" <leader>a for the current selected range
" <leader>aw for the current word
" <leader>aas for the current sentence
" <leader>aap for the current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Mappings using CoCList:

" Show a list of all code actions
nnoremap <F5> :<C-u>CocList actions<CR>
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

"## A lighter version of the powerline plugin

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
let g:airline#extensions#tabline#show_tab_type = 1
let g:airline#extensions#tmuxline#enabled=0 " don't try to sync with tmuxline
let g:airline#extensions#coc#enabled = 1 " enable coc integration
let g:airline_theme='gruvbox'
let g:airline_solarized_bg='dark'
let g:airline_powerline_fonts=1

"## tmux sync and integration plugins

" Use the same keys to navigate vim windows and tmux panes seamlessly
Plug 'christoomey/vim-tmux-navigator'

" Use the contents of other tmux windows as a completion source.  supposedly
" this plugin automatically integrates with coc as a completion source
Plug 'wellle/tmux-complete.vim'

"## vim-gitgutter

" Show git status line by line
Plug 'airblade/vim-gitgutter'

"## rainbow (colorizes parenthesis)

" Use a fancy plugin to render nested parens in different colors
Plug 'luochen1990/rainbow'
let g:rainbow_active=1 " use :RainbowToggle to turn on and off

"## nerdtree & friends

" because netrw tree mode sucks in cruel and unusual ways
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" NOTE: nerdtree-git-plugin had to be disabled.  It interferes badly with the
" appearance of NERDtree and vim-devicons.  The problem is summarized in
" https://github.com/Xuyuanp/nerdtree-git-plugin/issues/102 perhaps someday it
" will be fixed
" Plug 'Xuyuanp/nerdtree-git-plugin'

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

"## nerdcommenter

Plug 'scrooloose/nerdcommenter'
" Align line-wise comment delimiters flush left instead of following code indentation
let g:NERDDefaultAlign = 'left'
" Allow commenting and inverting empty lines (useful when commenting a region)
let g:NERDCommentEmptyLines = 1
" Enable trimming of trailing whitespace when uncommenting
let g:NERDTrimTrailingWhitespace = 1

"## Rice the vim terminal with nerd icons
Plug 'ryanoasis/vim-devicons'

" Work around the ugly excessive indenting of the file nodes in
" the nerdtree caused by this plugin
"
" Per https://github.com/ryanoasis/vim-devicons/issues/248
let g:WebDevIconsNerdTreeBeforeGlyphPadding = ""
let g:WebDevIconsUnicodeDecorateFolderNodes = v:true
let g:webdevicons_conceal_nerdtree_brackets = 1

let g:DevIconsEnableFoldersOpenClose = 1

"## Some themes

" Load some themes
Plug 'dracula/vim'
Plug 'altercation/vim-colors-solarized'
Plug 'morhetz/gruvbox'
let g:gruvbox_italic=1 "alacritty assures me it supports italics
let g:gruvbox_bold=1 "alacritty assures me it supports bold
let g:gruvbox_underline=1 "alacritty assures me it supports underline
let g:gruvbox_undercurl=1 "I don't know if this will work or not but it'd be cool
let g:gruvbox_contrast_dark='medium'

"## neovim terminal tweaks

" add some goodness to the neovim terminal
if has('nvim')
  Plug 'kassio/neoterm'
endif

"## hya14busa plugins related to easymotion and incremental search

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

" With a z prefix do incremental fuzzy search
map z/ <Plug>(incsearch-fuzzy-/)
map z? <Plug>(incsearch-fuzzy-?)
map zg/ <Plug>(incsearch-fuzzy-stay)

" Automatically turn off highlighted search after it's not needed using
" the incsearch auto_nohlsearch feature
set hlsearch
let g:incsearch#auto_nohlsearch = 1

"use the easymotion version of n/N so repeat easymotion searches
map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)

" use incsearch plugin for the usual search operators
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)

"## fzf

" use fzf as a plugin
if executable("fzf")
  Plug 'junegunn/fzf' "the basic fzf pluging
  Plug 'junegunn/fzf.vim' "the more advanced one, ships separately

  " when opening a buffer, jump to the existing window if possible
  let g:fzf_buffers_jump = 1

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

  " If running under tmux, use a tmux popup for fzf
  if exists('$TMUX')
      let g:fzf_layout = { 'tmux': '-p90%,60%' }
  else
      let g:fzf_layout = { 'down': '~40%' }
  endif

  " The `Rg` fzf command, which uses Ripgrep to search the current directory,
  " is more useful if we can combine the interactive search results with the
  " quickfix list.
  function! s:build_quickfix_list(lines)
    " Note 'r' means replace the existing contents, and the 'title' makes it
    " clear which quickfix list we want replaced.
    "
    " BUG: This doesn't work right currently.  LanguageClient-neovim puts
    " errors in its own quickfix list, and when it does so for some reason all
    " other quickfix lists get cleared.
    "
    " ANOTHER BUG: The neovim docs are very clear about the use of a 'title'
    " element in the third arg to specify a title of the list, but it doesn't
    " work.  The title is always ":setqflist()".
    let items = map(copy(a:lines), '{ "filename": v:val }')
    call setqflist([], 'r', {'title' : 'ripgrep results', 'items' : items})
    copen
    cc
  endfunction

  " set non-default actions to open in a tab, split, etc
  let g:fzf_action = {
    \ 'ctrl-q': function('s:build_quickfix_list'),
    \ 'ctrl-t': 'tab split',
    \ 'ctrl-x': 'split',
    \ 'ctrl-v': 'vsplit'
  \}

  " The default Ctrl-A to select all items in the FZF results doesn't work
  " because we use Ctrl-A for tmux.  So use Ctrl-S instead, even though that
  " feels wrong.
  let $FZF_DEFAULT_OPTS .= ' --bind ctrl-s:select-all'

  " Define a custom command `AllFiles`, which is like `Files` but provides a
  " different command to `fd` so that it does not filter out files that are
  " ignored by `.gitignore`.  This is useful because sometimes you want to get
  " to a file produced by a build system but it's normally invisible to
  " `Files` due to `.gitignore`
  "
  " The help topic about customizing files command was helpful in figuring out
  " how to customize the behavior of #files
  command!  -bang -nargs=? -complete=dir AllFiles       call fzf#vim#files(<q-args>, {'source': $FZF_DEFAULT_COMMAND . ' --no-ignore' }, <bang>0)

  " fzf.vim provides so many handy commands.  Here are bindings for a few:
  " * Ctrl-T - Files - like ctrl-p but fast
  " * Ctrl-P - Lines in the current buffer
  " * <leader>p - BLines - Lines in all open buffers
  " * <leader>b - Buffers - like ctrl-p's buffer list but, again, fast
  " * <Leader>h - Helptags - fuzzy search help tags, lolwut??
  " * <Leader>m - History - most recently used files
  nmap <c-t> :Files<CR>
  nmap <Leader>af :AllFiles<CR>

  " For files that have LSP support the <C-p> and <Leader>p mappings are
  " overridden to use the LSP.  But I always want to be able to do a fzf lines
  " search so also bind to <Leader>l
  nmap <Leader>l :Lines<CR>
  nmap <c-p> :BLines<CR>
  nmap <Leader>p :Lines<Enter>
  nmap <Leader>b :Buffers<Enter>
  nmap <Leader>h :Helptags<Enter>
  nmap <Leader>m :History<Enter>
endif

"## vim-indent-guides

" use a plugin to render indent guides which are helpful dealing with
" indent-based languages like YAML and Python
Plug 'nathanaelkane/vim-indent-guides'
"don't enable on startup
"(it's <Leader>ig to enable btw)
let g:indent_guides_enable_on_vim_startup = 0
"tweak the layout a bit to make it less visually distracting
let g:indent_guides_start_level=1
let g:indent_guides_guide_size=1

"## vim-yaml override

" replace the built-in YAML support
Plug 'stephpy/vim-yaml'

"## vim-yaml-folds
" some file types don't fold with syntax and work better with indent. YAML
" specifically.  Fortunately, Theres a Plugin for That (tm)
Plug 'pedrohdz/vim-yaml-folds'

"## vim-test

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

"## vim-better-whitespace

" load a plugin to help call attention to trailing whitespace (which seems to
" wreak havoc with the YAML plugin I use) and expediently eradicate it on save
Plug 'ntpeters/vim-better-whitespace'
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1
let g:strip_whitespace_confirm=0

"## capnproto syntax support

Plug 'cstrahan/vim-capnp'

"## Auto-generate closing braces/parens and indent
Plug 'cohama/lexima.vim'

"## end plugins
" Add plugins to &runtimepath
call plug#end()

"# color and theme configs

" according to the answer at https://vi.stackexchange.com/questions/3576/trouble-using-color-scheme-in-neovim
" one should not ever set t_Co in neovim
"set t_Co=256 "tell vim our terminal supports 256 colors (it does, right))
set termguicolors "if the term supports 24-bit color even better

colorscheme gruvbox " activate my current preferred scheme
set background=dark "specifically the dark variant

"# vim-devicons .vimrc refresh support
"This is needed to avoid messing up the vim-devicons state when sourcing
".vimrc
if exists("g:loaded_webdevicons")
  call webdevicons#refresh()
endif

