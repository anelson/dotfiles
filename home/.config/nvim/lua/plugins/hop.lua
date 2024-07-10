return {
  -- LazyVim enables Flash for this but I hate it and can't get it to work for me
  {
    "folke/flash.nvim",
    enabled = false,
  },
  {
    "phaazon/hop.nvim",
    branch = "v2", -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      local hop = require("hop")
      local directions = require("hop.hint").HintDirection

      hop.setup({ keys = "etovxqpdygfblzhckisuran" })

      vim.api.nvim_set_keymap("", "s", ":HopChar2<CR>", {})
      vim.api.nvim_set_keymap("", "<Leader><Leader>", ":HopWord<CR>", {})
      vim.api.nvim_set_keymap("", "<Leader>L", ":HopLineStart<CR>", {})
    end,
  },
}
