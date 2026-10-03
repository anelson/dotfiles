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
    lazy = false, -- This plugin is already lazy
    opts = function(_, opts)
      -- Extend LazyVim's rust extras config rather than replacing it
      opts.server = opts.server or {}
      opts.server.default_settings = opts.server.default_settings or {}

      -- Merge our custom settings with LazyVim's defaults using deep extend
      opts.server.default_settings["rust-analyzer"] =
        vim.tbl_deep_extend("force", opts.server.default_settings["rust-analyzer"] or {}, {
          -- rust-analyzer language server configuration

          imports = {
            granularity = {
              group = "module",
            },
            prefix = "self",
          },

          cargo = {
            -- Enable all features in rust crates.  This is an experiment to see if I like how this works
            allFeatures = true,

            -- Keep rust-analyzer's build artifacts separate from normal builds.
            targetDir = true,

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
        })

      -- Set up our custom on_attach, but call LazyVim's first if it exists
      local lazyvim_on_attach = opts.server.on_attach
      opts.server.on_attach = function(client, bufnr)
        -- Call LazyVim's on_attach if it exists
        if lazyvim_on_attach then
          lazyvim_on_attach(client, bufnr)
        end

        -- ============================================================================
        -- SEMANTIC TOKENS CONFIGURATION
        -- ============================================================================
        --
        -- By default, we use LSP semantic tokens for Rust syntax highlighting instead
        -- of Tree-sitter. This provides more accurate, semantically-aware highlighting
        -- that can distinguish between:
        --   - Mutable vs immutable bindings
        --   - Different types of variables (local, parameter, static, etc.)
        --   - Associated functions vs methods
        --   - Consumed vs borrowed values
        --   - And many other semantic distinctions
        --
        -- TRADE-OFFS:
        --   Semantic tokens (current):
        --     - More accurate and semantically meaningful
        --     - Understands code meaning, not just syntax
        --     - Depends on LSP being healthy
        --     - May have slight delay on large files
        --
        --   Tree-sitter (alternative):
        --     - Faster, synchronous highlighting
        --     - Works offline without LSP
        --     - Never breaks due to LSP issues
        --     - Purely syntax-based (can't understand semantics)
        --
        -- TO SWITCH TO TREE-SITTER:
        --   If you experience issues with semantic tokens (highlighting breaks,
        --   performance problems, conflicts), uncomment the line below:
        --
        --   client.server_capabilities.semanticTokensProvider = nil
        --
        --   This disables LSP semantic tokens, and Tree-sitter will handle all Rust
        --   syntax highlighting. The highlighting will be fast and reliable, but less
        --   semantically rich.
        --
        -- ============================================================================

        -- Disable semantic highlighting for now to see whether it's responsible
        -- for the intermittent loss of syntax highlighting.
        client.server_capabilities.semanticTokensProvider = nil

        -- Custom keymaps
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
      end

      return opts
    end,
  },
}
