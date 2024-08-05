-- Various tweaks to the out-of-the-box LazyVim LSP config
return {
  {
    -- NOTE: Many LSP key bindings are in `fzf.lua` since  they invoke Fzf functions to display information from the LSP
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        -- Do not let lspconfig/mason run rust-analyzer.  The rustaceanvim plugin will handle this on its own,
        -- with some Rust-specific goodness
        rust_analyzer = function()
          return true
        end,

        -- Try to force pbls to be enabled.  This doesn't actually help since apparently there is no Protobuf LSP that does auto-formatting.  FML.
        pbls = require("lspconfig").pbls.setup({}),
      },
    },
  },

  {
    -- Rust LSP config in LazyVim is obtained using rustaceanvim, so it's that plugin's config that must be customized to configure the rust-analyzer
    -- LSP behavior
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>aw", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          -- For rename, the default LSP binding for rename should be used.  RustLsp doesn't have any special-case rename functionality
          -- vim.keymap.set("n", "<leader>rn", function()
          --   vim.cmd.RustLsp("rename")
          -- end, { desc = "Rename", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
        end,
        default_settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            -- Run clippy, not just check, and use a separate temp dir for
            -- rust-analizer so as not to clobber the workspace's output directory
            -- and thereby constantly cause rebuilds
            checkOnSave = true,
            check = {
              allTargets = true,
              command = "clippy",
              extraArgs = {
                "--target-dir",
                "/tmp/rust-analyzer-check",
              },
            },

            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },

            cargo = {
              -- Enable all features in rust crates.  This is an experiment to see if I like how this works
              allFeatures = true,

              loadOutDirsFromCheck = true,

              -- Rust analyzer should run build scripts as part of its evaluation.  This is critical for things like
              -- prost and tonic which generate Rust bindings on the fly
              buildScripts = {
                enable = true,
              },
            },

            procMacro = {
              -- Enable proc macro support
              enable = true,
            },
          },
        },
      },
    },
  },
}
