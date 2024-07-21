-- Customize some Mason settings beyond the LazyVim defaults
return {
  "williamboman/mason.nvim",

  opts = {
    -- Some LSPs I use so often that I don't want to install them lazily, let's install them proactively
    ensure_installed = {
      "stylua",
      "shfmt",
      "ansible-language-server",
      "bash-language-server",
      "eslint-lsp",
      "json-lsp",
      -- "rust_analyzer", -- This needs to be installed on a per-project basis using rust-toolchain.toml to ensure it matches the Rust version

      -- There seems not to be a Protobuf language server solution right now.  FML.
      -- "bufls" - Used to use that but it's been rebraned as `buf-language-server`
      -- "buf-language-server", - Some prototype from the buf project, it loads okay, but it doesn't work.  Doesn't show errors and doesn't do any formatting
      -- "pbkit" - Not supported by Mason apparently
      "pbls", -- Seems to work okay for detecing errors, but doesn't autofmt.
    },
  },
}
