return {
  -- Use the same keys to navigate vim windows and tmux panes seamlessly
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },

  -- Use the contents of other tmux windows as a completion source. Supposedly
  -- this plugin automatically integrates with coc as a completion source
  { "wellle/tmux-complete.vim", lazy = false },

  -- Use OSC-52 control codes to push the clipboard to the terminal client
  -- This is built-in to neovim if https://github.com/neovim/neovim/issues/3344 is present.
  -- Per https://github.com/neovim/neovim/blob/6b00c9acfde954a3e992a2932eca9fa5902a1298/runtime/doc/news-0.10.txt#L382
  -- this is new in neovim 0.10 and later.
  -- The `nvim-osc52` plugin was used before this landed natively.
  --
  -- A huge difference now with the native osc 52 support is that *paste* also tries to use OSC 52 to read the clipboard from the terminal
  -- emulator and paste it.  I don't know if I'm going to like this or not.
  --
  -- See https://github.com/neovim/neovim/discussions/28010 for a discussion about how to disable the paste side only; it's not as straightforward
  -- as it should be.  Wezterm doesn't support reading the clipboard (https://github.com/wezterm/wezterm/issues/2050) although Ghostty seems to do it fine.
  --
  -- See `:help clipboard` in Neovim for more details on this if in the future the automatic OCS 52 integration is found to be wanting.
  -- {
  --   "ojroques/nvim-osc52",
  --   config = function()
  --     local in_tmux = os.getenv("TMUX") ~= nil
  --
  --     require("osc52").setup({
  --       --It's possible that I would run Neovim in a local terminal not using tmux.  THat's not my usual workflow but it's not inconceivable either.
  --       --Make this conditional, enable it only when the env indicates tmux is running
  --       tmux_passthrough = in_tmux,
  --     })
  --
  --     local function copy()
  --       if vim.v.event.operator == "y" and vim.v.event.regname == "+" then
  --         require("osc52").copy_register("+")
  --       end
  --     end
  --
  --     vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
  --
  --     -- In my particular case I only want this happening under TMUX.  I may relax this in the future
  --     vim.g.clipboard = nil
  --
  --     -- TODO: I think Neovim 0.11 introduces this termfeature; set it then
  --     --vim.g.termfeatures.osc52 = false
  --   end,
  -- },
}
