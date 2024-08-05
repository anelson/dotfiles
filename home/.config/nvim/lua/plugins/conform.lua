return {
  {
    "stevearc/conform.nvim",
    opts = {
      ---@type table<string, conform.FormatterUnit[]>
      formatters_by_ft = {
        protobuf = { "buf" },

        -- `markdownlint-cli2` always fails with a timeout error when formatting.
        -- Although prettier just doesn't do anything so that's not much better.
        markdown = { "prettier" },
      },

      -- This workaround suggested in https://github.com/stevearc/conform.nvim/issues/297 to address formatter timeout issues
      -- I am unable to get Markdown formatted due to a timeout message
      --
      -- UPDATE: Doesn't work.  LazyVim complains that I should not set `format_on_save`, and it seems to be overwriding this setting.
      -- Even an absurd timeout like 10 seconds doesn't work.  Doing a `gq` on Markdown immediately fails with a timeout error.
      -- format_on_save = {
      --   timeout_ms = 10000,
      --   lsp_fallback = true,
      -- },
    },
  },
}
