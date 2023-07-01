local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = true,
})

-- we'll use Mason to auto-install LSPs as needed, but still seed some basic ones
-- that we want all the time
lsp.ensure_installed({
  'ansiblels',
  'bashls',
  'dockerls',
  'eslint',
  'jsonls',
  'lua_ls',
  'ruby_ls',
  'rust_analyzer',
  'tsserver',
  'vimls',
})

-- don't initialize this language server
-- we will use rust-tools to setup rust_analyzer
lsp.skip_server_setup({ 'rust_analyzer' })

-- I like my LSP to do formatting on save
-- This is commented out and instead buffer_autoformat is called inside of the `on_attach` function
-- Note that this will need to be uncommented for cases where there's more than one LSP per file type
-- and the wrong LSP is getting asked to format the buffer
--lsp.format_on_save({
--  servers = {
--    ['lua_ls'] = { 'lua' },
--    ['rust_analyzer'] = { 'rust' },
--  }
--})

-- Custom mappings applied only to buffers with a corresponding LSP
local telescope_builtins = require('telescope.builtin')

lsp.on_attach(function(client, bufnr)
  -- tell the LSP, whatever it is, to auto-format the buffer on save
  lsp.buffer_autoformat()

  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "<leader>aw", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("n", "]g", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "[g", function() vim.diagnostic.goto_prev() end, opts)

  -- TODO: CoC has CocList that provides fuzzy matching on the list of symbols.
  -- Figure out how to do that with LSP
  vim.keymap.set("n", "<space>s", function() telescope_builtins.lsp_workspace_symbols() end, opts)
  vim.keymap.set("n", "<space>o", function() telescope_builtins.lsp_document_symbols() end, opts)
  vim.keymap.set("n", "gr", function() telescope_builtins.lsp_references() end, opts)
  vim.keymap.set("n", "gd", function() telescope_builtins.lsp_definitions() end, opts)
  vim.keymap.set("n", "gi", function() telescope_builtins.lsp_implementations() end, opts)

  -- The below are stolen from theprimagen and are mostly the default bindings.
  -- Kept here so I can easily copy/paste when I need to make my own bindings.

  --vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  --vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  --vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  --vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  --vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  --vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  --vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  --vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  --vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  --vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

-- 'cmp' autocompletion key bindings, in addition to whatever the defaults are
-- technically this isn't LSP-related, but because we use lsp-zero to orchestrate the various
-- plugins that are necessary to make auto-completion with LSP work, completion and LSP settings
-- are combined for now.
local cmp = require('cmp')
local lspkind = require('lspkind')

lsp.setup_nvim_cmp({
  mapping = lsp.defaults.cmp_mappings({
    -- Do not use Enter to accept the current autocomple option.  It's not always what I want
    -- and is very annoying in those cases
    ['<CR>'] = vim.NIL,
    -- ['<C-e>'] = cmp.mapping.abort(),
  }),
  -- HACK: customize completion sources by completely replacing the default completion sources
  -- This is hopefully all of the default sources, but that can change over time.
  -- Got this hack from   https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/doc/md/autocomplete.md#configure-a-source
  sources = {
    -- default sources
    { name = 'nvim_lsp' },
    { name = 'path' },
    { name = 'buffer',  keyword_length = 3 },
    { name = 'luasnip', keyword_length = 2 },

    -- anelson bonus sources
    { name = "copilot" },

  },
  formatting = {
    -- invoke lspkind to decorate the completion menu with fancy icons
    format = lspkind.cmp_format({
      mode = 'symbol',       -- show only symbol annotations
      maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      --before = function (entry, vim_item)
      --  ...
      --  return vim_item
      --end
    })
  }
})

-- (Optional) Configure lua language server for neovim
lsp.nvim_workspace()

lsp.setup()

-- initialize rust_analyzer with rust-tools
-- see :help lsp-zero.build_options()
local rust_lsp = lsp.build_options('rust_analyzer', {
  single_file_support = true,
  on_attach = function(client, bufnr)
    --print('hello rust-tools')
  end,
  settings = {
    -- customize the rust-analyzer TLS
    ["rust-analyzer"] = {
      -- Run clippy, not just check, and use a separate temp dir for
      -- rust-analizer so as not to clobber the workspace's output directory
      -- and thereby constantly cause rebuilds
      checkOnSave = true,
      check = {
        allTargets = true,
        command = "clippy",
        extraArgs = {
          "--target-dir", "/tmp/rust-analyzer-check",
        },
      },

      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },

      cargo = {
        -- Rust analyzer should run build scripts as part of its evaluation.  This is critical for things like
        -- prost and tonic which generate Rust bindings on the fly
        buildScripts = { enable = true },
        -- Enable all features in rust crates.  This is an experiment to see if I like how this works
        features = "all"
      },

      procMacro = {
        -- Enable proc macro support
        enable = true
      }
    },
  },
})

require('rust-tools').setup({ server = rust_lsp })
