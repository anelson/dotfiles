return {
  -- STUPID: Why do I have to explicitly enable telescope?  It's listed as a dependency of ChatGPT below,
  -- but if I don't put this here then when I run `:Lazy` it shows telescope as "disabled", but it still tries to load ChatGPT which fails because telescope
  -- isn't loaded.
  {
    "nvim-telescope/telescope.nvim",
    enabled = true,
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      local config_path = vim.fn.stdpath("config")
      require("chatgpt").setup({
        -- The idea is to use the 1password CLI to get this, but that only makes sense when running on a desktop.  On a headless remote server
        -- there is no way to pop up the 1P UI to unlock the vault, so this `op read` command will just fail, making it utterly useless.
        -- So the fallback is to just put the key on a local file that's not under version control.  Bummer.
        -- api_key_cmd = 'op read "op://Shared - Karina and Adam/OpenAI/chatgpt.nvim"',
        api_key_cmd = "cat " .. config_path .. "/chatgpt-api-key",
      })
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}
