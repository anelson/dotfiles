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
  {
    "ojroques/nvim-osc52",
    config = function()
      local in_tmux = os.getenv("TMUX") ~= nil

      require("osc52").setup({
        --It's possible that I would run Neovim in a local terminal not using tmux.  THat's not my usual workflow but it's not inconceivable either.
        --Make this conditional, enable it only when the env indicates tmux is running
        tmux_passthrough = in_tmux,
      })

      local function copy()
        if vim.v.event.operator == "y" and vim.v.event.regname == "+" then
          require("osc52").copy_register("+")
        end
      end

      vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
    end,
  },
}
