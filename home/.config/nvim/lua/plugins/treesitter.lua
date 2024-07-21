return {
  {
    "nvim-treesitter/nvim-treesitter",
    requires = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "nvim-treesitter/playground",
    },
    run = ":TSUpdate",

    opts = function(_, opts)
      -- add some additional parsers to whatever the LazyVim defaults are
      vim.list_extend(opts.ensure_installed, {
        "javascript",
        "typescript",
        "c",
        "lua",
        "rust",
        "toml",
        "yaml",
        "json",
      })
    end,
  },
}
