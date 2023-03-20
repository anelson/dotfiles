-- Packer config wuhich specifies plugins to download and compile with packer
--
-- Packer is a bit different than previous plugin managers I've used, like vim-plug.  This lua
-- file with the Packer config does not need to be loaded unless the set of plugins has changed.
-- When packer downloads plugins, it generates some lazy-loading code and puts it in an auto-include
-- path that neovim will look in at startup.  That's why this Lua module isn't `require`d from `init.lua`.
--
-- However, I use this neovim config on multiple systems, and I might add or remove a plugin on one system and then
-- sync my dotfiles with other systems, so that default behavior where you manually compile plugins only when you change
-- them doesn't quite work for me.  That's where the bootstrapping comes in.  This is described in more detail in the Packer
-- repo README under [Bootstrapping](https://github.com/wbthomason/packer.nvim#bootstrapping).
--
-- If this file has been synced from another computer, it will not automatically install the plugins unless Packer has never
-- run before.  If it has, it will not automatically detect that there are new plugins to load.  To do that, run
-- `:PackerSync` which will both download new versions of plugins and re-compile them.  `:PackerUpdate` will do a clean first,
-- which is necessary if plugins were removed and should not be loaded anymore.

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

local packer = require('packer')

-- Make Packer display with a pop-up window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
  max_jobs = 50,
}

return packer.startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Use native fzf for fuzzy finder in Telescope
  use {
    'nvim-telescope/telescope-fzf-native.nvim',
    run =
    'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
  }
  -- Load and configure Telescope (although I still use the fzf plugin for most of my fuzzy needs)
  use {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }

  -- The basic `fzf` plugin is concerned with making sure the `fzf` executable is found.
  -- The editor commands are in fzf.vim
  if vim.fn.executable("fzf") then
    use {
      -- NB: I don't use the `run = ` here because that just makes sure `fzf` is in the path and offers to download it
      -- if it's not.  That's not how I want to get `fzf`, so I rely on my normal devbox setup scripts to make sure fzf is present
      'junegunn/fzf'
    }
    use {
      'junegunn/fzf.vim'
    }
  end

  -- Replace the programmer at the keyboard with an AI copilot
  use {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        -- Disable separate copilot suggestions; use the cmp plugin instead
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  }
  use {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end
  }

  -- Rust analyzer support
  use {
    'simrat39/rust-tools.nvim',
    config = function()
      require("rust-tools").setup({
        server = {
          settings = {
            -- customize the rust-analyzer TLS
            ["rust-analyzer"] = {
              -- Run clippy, not just check, and use a separate temp dir for
              -- rust-analizer so as not to clobber the workspace's output directory
              -- and thereby constantly cause rebuilds
              checkOnSave = {
                enable = true,
                command = "clippy",
                extraArgs = {
                  { "--target-dir", "/tmp/rust-analyzer-check" },
                },
              },

              -- TODO: copy the other coc-settings.json rust analyzer configs here
              cargo = {
                -- Load Rust code from `OUT_DIR` so code generated at build time is also analyzed
                -- https://github.com/rust-analyzer/rust-analyzer/pull/3582
                loadOutDirsFromCheck = true,
                -- Rust analyzer should run build scripts as part of its evaluation.  This is critical for things like
                -- prost and tonic which generate Rust bindings on the fly
                runBuildScripts = true,
                -- Enable all features in rust crates.  This is an experiment to see if I like how this works
                -- allFeatures = true
              },

              procMacro = {
                -- Enable proc macro support
                enable = true
              }
            },
          },
        },
      })
    end
  }

  -- Enable inlay hints for certain LSPs that support it
  -- TODO: is this needed?  I can't tell if its built in now to lsp-zero.
  -- `rust-tools` seems to handle inlay hints directly, at least for Rust.
  --use { 'simrat39/inlay-hints.nvim',
  --        config = function()
  --                require("inlay-hints").setup()
  --        end }

  -- A super-powered quickfix-like list for LSP diagnostics of all kinds
  use {
    "folke/trouble.nvim",
    requires = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        vim.keymap.set("n", "<leader>tt", "<cmd>TroubleToggle<cr>",
          { silent = true, noremap = true }
        )
      }
    end
  }

  -- treesitter and associated ecosystem plugins
  use { "nvim-treesitter/nvim-treesitter",
    requires = { "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/playground",
      "nvim-treesitter/nvim-treesitter-context"
    },
    run = ":TSUpdate"
  }

  use {
    'VonHeikemen/lsp-zero.nvim',
    -- TODO: 2.x should be released April 2023, switch to that when it's ready
    branch = 'v1.x',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },             -- Required
      { 'williamboman/mason.nvim' },           -- Optional
      { 'williamboman/mason-lspconfig.nvim' }, -- Optional
      { 'nvim-telescope/telescope.nvim' },     -- For using Telescope pickers to navigate symbols
      { 'simrat39/rust-tools.nvim' },          -- use this instead of talking to rust-analyzer directly

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },         -- Required
      { 'hrsh7th/cmp-nvim-lsp' },     -- Required
      { 'hrsh7th/cmp-buffer' },       -- Optional
      { 'hrsh7th/cmp-path' },         -- Optional
      { 'saadparwaiz1/cmp_luasnip' }, -- Optional
      { 'hrsh7th/cmp-nvim-lua' },     -- Optional
      { 'zbirenbaum/copilot-cmp' },   -- Tie Copilot suggestions into the completion system
      { 'onsails/lspkind.nvim' },     -- Fancy vscode-like icons on the completion prompt

      -- Snippets
      { 'L3MON4D3/LuaSnip' },             -- Required
      { 'rafamadriz/friendly-snippets' }, -- Optional
    }
  }

  -- Use `fidget` to report LSP status in a kind of text mode toaster popup over the status line
  -- NB: There is a more "correct" API in NeoVim for getting this information, `LspProgressUpdate`, but as of now fidget doesn't use that.
  -- See https://github.com/j-hui/fidget.nvim/pull/80 to monitor status.  It might be that in the near future this will break or conflict with
  -- something else.  A different plugin may be needed to provide this functionality.
  use {
    'j-hui/fidget.nvim',
    after = { "lsp-zero.nvim", "nvim-lspconfig" },
    config = function()
      require "fidget".setup {}
    end
  }

  -- more advanced undo capabilities
  use 'mbbill/undotree'

  -- RIP NERDtree, let's try something new
  use {
    'nvim-tree/nvim-tree.lua',
    requires = { { 'nvim-tree/nvim-web-devicons' } }
  }

  -- NERDCommenter plugin
  use 'scrooloose/nerdcommenter'

  -- Use the same keys to navigate vim windows and tmux panes seamlessly
  use 'christoomey/vim-tmux-navigator'

  -- Use the contents of other tmux windows as a completion source. Supposedly
  -- this plugin automatically integrates with coc as a completion source
  use 'wellle/tmux-complete.vim'

  -- vim-gitgutter
  -- Show git status line by line
  use 'airblade/vim-gitgutter'

  -- rainbow (colorizes parenthesis)
  -- Use a fancy plugin to render nested parens in different colors
  use 'luochen1990/rainbow'

  -- new Lua impl of lexima plugin that automatically generates closing punctuation
  use {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup {
        -- Don't add pairs if it already has a close pair in the same line
        enable_check_bracket_line = false
      }
    end
  }

  -- tpope gets his own section.  If it was possible to write `tpope/*` and just blindly install all of his plugins
  -- I would probably do that.
  -- Apply tpope's sensible defaults
  use 'tpope/vim-sensible'

  -- Use vim-surround for quoting/parenthesizing
  use 'tpope/vim-surround'

  -- repeat.vim to support repeating vim-surround operations with .
  use 'tpope/vim-repeat'

  -- unimpaired to add convenient short aliases for next/previous things
  use 'tpope/vim-unimpaired'

  -- add some 'vinegar' (inside joke) to netrw so it sucks less and maybe
  -- NERDtree isn't needed
  use 'tpope/vim-vinegar'

  -- Add git integration to vim
  use 'tpope/vim-fugitive'

  -- Try to automatically deduce the proper tab settings for a particular file
  use 'tpope/vim-sleuth'

  -- Implement async background running of compiles and tests.  Not used directly
  -- but this makes vim-test better
  use 'tpope/vim-dispatch'

  -- support saving vim sessions and restoring them later
  -- this is used with the tmux plugin tmux-resurrect
  use 'tpope/vim-obsession'

  -- detect and handle Jekyll files which have YAML front matter and Liquid
  -- templates
  use 'tpope/vim-liquid'

  -- Provide handy keystrokes for changing the case of a word
  use 'tpope/vim-abolish'


  -- Call out trailing whitespace, and automatically remove it on save
  use {
    'ntpeters/vim-better-whitespace',
    config = function()
      vim.g.better_whitespace_enabled = 1
      vim.g.strip_whitespace_on_save = 1
      vim.g.strip_whitespace_confirm = 0
    end
  }

  -- Look and feel improvements

  -- Seems duplicative of 'nvim-tree/nvim-web-devicons', but this plugin specifically
  -- enables file type icons in the vim-airline tab bar so I need it as well.
  -- nvim-web-devicons will never support this, as per https://github.com/nvim-tree/nvim-web-devicons/issues/38
  use 'ryanoasis/vim-devicons'

  -- rice that status line
  use {
    'vim-airline/vim-airline',
    -- vim-airline is a bit different from other plugins, in that it reads
    -- these settings when it loads.  Therefore these globals need to be
    -- set *before* the plugin itself loads. There is still some config in
    -- `after/plugin`; only the global vars are set here since they need to
    -- be in place before the plugin loads
    setup = function()
      vim.g['airline#extensions#tabline#enabled'] = 1
      vim.g['airline#extensions#tabline#tab_nr_type'] = 1 -- tab number
      vim.g['airline#extensions#tabline#show_tab_type'] = 1
      vim.g['airline#extensions#tmuxline#enabled'] = 0    -- don't try to sync with tmuxline
      -- TODO: enable this only if we end up using CoC
      -- vim.g['airline#extensions#coc#enabled'] = 1 -- enable coc integration
      vim.g.airline_theme = 'gruvbox'
      vim.g.airline_solarized_bg = 'dark'
      vim.g.airline_powerline_fonts = 1

      -- Add (Neo)Vim's native statusline support.
      -- NOTE: Please see `:h coc-status` for integrations with external plugins that
      -- provide custom statusline: lightline.vim, vim-airline.
      vim.api.nvim_exec([[
          " TODO: do this if we end up using CoC in this new config
          " set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
        ]], false)

      -- Do not render airline on buffers made by certain plugins
      vim.g.airline_exclude_filetypes = { "NvimTree" }
    end,
  }
  use { 'vim-airline/vim-airline-themes', requires = 'vim-airline/vim-airline' }

  -- easymotion for quick movement to specific places with the keyboard
  -- NOTE: this is disabled for now, `hop` is a better alternative
  --use {
  --        'easymotion/vim-easymotion',
  --        config = function()
  --                vim.g.EasyMotion_do_mapping = 0
  --                vim.g.EasyMotion_smartcase = 1
  --                vim.api.nvim_set_keymap('', 's', '<Plug>(easymotion-bd-f2)', {})
  --                vim.api.nvim_set_keymap('n', 's', '<Plug>(easymotion-overwin-f2)', {})
  --                vim.api.nvim_set_keymap('', '<Leader><Leader>', '<Plug>(easymotion-bd-w)', {})
  --                vim.api.nvim_set_keymap('', '<Leader>j', '<Plug>(easymotion-j)', {})
  --                vim.api.nvim_set_keymap('', '<Leader>k', '<Plug>(easymotion-k)', {})
  --                vim.api.nvim_set_keymap('', '<Leader>L', '<Plug>(easymotion-bd-jk)', {})
  --                vim.api.nvim_set_keymap('n', '<Leader>L', '<Plug>(easymotion-overwin-line)', {})
  --        end
  --}

  -- use hop in place of easymotion for fast movement within VIM
  use {
    'phaazon/hop.nvim',
    branch = 'v2', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      local hop = require('hop')
      local directions = require('hop.hint').HintDirection

      hop.setup { keys = 'etovxqpdygfblzhckisuran' }

      vim.api.nvim_set_keymap('', 's', ':HopChar2<CR>', {})
      vim.api.nvim_set_keymap('', '<Leader><Leader>', ':HopWord<CR>', {})
      vim.api.nvim_set_keymap('', '<Leader>L', ':HopLineStart<CR>', {})
    end
  }

  -- fix vim's shitty incremental search
  use 'haya14busa/is.vim'

  -- Rice the terminal with fancy icons
  use 'nvim-tree/nvim-web-devicons'

  -- Load my favorite color scheme
  use 'morhetz/gruvbox'

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
