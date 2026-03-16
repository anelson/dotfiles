-- tpope gets his own section.  If it was possible to write `tpope/*` and just blindly install all of his plugins
-- I would probably do that.
return {
  -- Apply tpope's sensible defaults
  { "tpope/vim-sensible" },

  -- Use vim-surround for quoting/parenthesizing
  { "tpope/vim-surround" },

  -- repeat.vim to support repeating vim-surround operations with .
  { "tpope/vim-repeat" },

  -- unimpaired to add convenient short aliases for next/previous things
  { "tpope/vim-unimpaired" },

  -- add some 'vinegar' (inside joke) to netrw so it sucks less and maybe
  -- NERDtree isn't needed
  { "tpope/vim-vinegar" },

  -- Add git integration to vim
  { "tpope/vim-fugitive" },

  -- Try to automatically deduce the proper tab settings for a particular file
  { "tpope/vim-sleuth" },

  -- Implement async background running of compiles and tests.  Not used directly
  -- but this makes vim-test better
  { "tpope/vim-dispatch" },

  -- support saving vim sessions and restoring them later
  -- this is used with the tmux plugin tmux-resurrect
  { "tpope/vim-obsession" },

  -- detect and handle Jekyll files which have YAML front matter and Liquid
  -- templates
  { "tpope/vim-liquid" },

  -- Provide handy keystrokes for changing the case of a word
  { "tpope/vim-abolish" },
}
