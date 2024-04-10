local lsp_zero = require('lsp-zero')

local lsp = lsp_zero.preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = true,
})

require('mason').setup({})
require('mason-lspconfig').setup({
  handlers = {
    -- Setup language servers with default settings.
    lsp_zero.default_setup,

    -- use lspconfig to configure the Lua language server
    -- this recommended by the lsp-zero v1 to v3 migration guide
    lua_ls = function()
      local lua_opts = lsp_zero.nvim_lua_ls()
      require('lspconfig').lua_ls.setup(lua_opts)
    end,

    rust_analyzer = lsp_zero.noop,

    -- you can customize other language servers by making additional properties
    -- which must match exactly the name of the language server, and are set to a function
    -- that is invoked to configure that language server
  },

  -- we'll use Mason to auto-install LSPs as needed, but still seed some basic ones
  -- that we want all the time
  ensure_installed = {
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
    'bufls' -- a superior protobuf LS
  },
})

-- Show icons on the left gutter to indicate LSP findings
lsp_zero.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = ''
})

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})

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

-- 'cmp' autocompletion key bindings and other settings, in addition to whatever the defaults are
-- technically this isn't LSP-related, but because we use lsp-zero to orchestrate the various
-- plugins that are necessary to make auto-completion with LSP work, completion and LSP settings
-- are combined for now.
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local lspkind = require('lspkind')
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  -- preselect the first item
  preselect = 'item',
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },

  -- Format the completion menu w/ an icon to indicate the source
  formatting = lsp_zero.cmp_format(),

  -- bring in the non-LSP sources explicitly, as of lsp-zero v3 this must be done explicitly
  sources = {
    -- Copilot Source
    { name = "copilot", group_index = 2 },

    { name = 'path' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' },
    { name = 'buffer',  keyword_length = 3 },
    { name = 'luasnip', keyword_length = 2 },
  },

  -- tweak the sorting of completion suggestions to try to make the best suggestions come first.
  -- This is based on https://github.com/zbirenbaum/copilot-cmp#comparators because completions from copilot
  -- can be good or shit and need special consideration
  sorting = {
    priority_weight = 2,
    comparators = {
      require("copilot_cmp.comparators").prioritize,

      -- Below is the default comparitor list and order for nvim-cmp
      cmp.config.compare.offset,
      -- cmp.config.compare.scopes, --this is commented in nvim-cmp too
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.recently_used,
      cmp.config.compare.locality,
      cmp.config.compare.kind,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  mapping = cmp.mapping.preset.insert({
    -- Do not use Enter to accept the current autocomple option.  It's not always what I want
    -- and is very annoying in those cases
    ['<CR>'] = vim.NIL,

    -- toggle completion menu
    ['<C-e>'] = cmp_action.toggle_completion(),

    -- ANELSON TODO: do I need to add C-y here explicitly to accept a completion?

    -- tab complete
    --['<Tab>'] = cmp_action.tab_complete(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),

    -- navigate between snippet placeholder
    ['<C-d>'] = cmp_action.luasnip_jump_forward(),
    ['<C-b>'] = cmp_action.luasnip_jump_backward(),

    -- scroll documentation window
    ['<C-f>'] = cmp.mapping.scroll_docs(-5),
    --['<C-d>'] = cmp.mapping.scroll_docs(5),
  }),
  -- Add borders to documentation window in completion menu
  window = {
    documentation = cmp.config.window.bordered(),
  }
})

-- removed oct 2023 as migration from lsp-zero v1 to v3
--lsp.setup_nvim_cmp({
--  formatting = {
--    -- invoke lspkind to decorate the completion menu with fancy icons
--    format = lspkind.cmp_format({
--      mode = 'symbol',       -- show only symbol annotations
--      maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
--      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
--      -- The function below will be called before any actual modifications from lspkind
--      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
--      --before = function (entry, vim_item)
--      --  ...
--      --  return vim_item
--      --end
--    })
--  }
--})

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

local rt = require('rust-tools')
require('rust-tools').setup({ server = rust_lsp })
