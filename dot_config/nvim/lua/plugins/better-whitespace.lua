return {
  "ntpeters/vim-better-whitespace",
  config = function()
    vim.g.better_whitespace_enabled = 1
    vim.g.strip_whitespace_on_save = 1
    vim.g.strip_whitespace_confirm = 0
    vim.g.better_whitespace_filetypes_blacklist = {
      -- Spaces in the dashboard buffer on startup are not of concern to us
      "dashboard",

      -- The rest of the filetypes are part of the default blacklist from the plugin docs, copy-pasted hereby
      -- so we blocklist those defauls too.
      "diff",
      "git",
      "gitcommit",
      "unite",
      "qf",
      "help",
      "markdown",
      "fugitive",
    }
  end,
}
