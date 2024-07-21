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
      "buf",
      "buf-language-server",
    },
  },
}
