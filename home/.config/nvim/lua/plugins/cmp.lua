-- Customize the completion sources and behavior
-- In my previous config this was mixed in with lsp.lua but it makes more sense to separate it
local cmp = require("cmp")

return {
  "hrsh7th/nvim-cmp",
  dependencies = { "hrsh7th/cmp-emoji" },
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    -- Without overriding whatever sources are configured by default, add some additional sources
    table.insert(opts.sources, { name = "emoji" })

    table.insert(opts.sources, { name = "path" })
    table.insert(opts.sources, { name = "nvim_lsp" })
    table.insert(opts.sources, { name = "nvim_lua" })
    table.insert(opts.sources, { name = "buffer", keyword_length = 3 })
    -- Adding luasnip isn't needed under LazyVim, the luasnip extra does this automatically
    -- table.insert(opts.sources, { name = "luasnip", keyword_length = 2 })

    opts.completion = {
      completeopt = "menu,menuone,noinsert,noselect",
    }

    opts.mapping = cmp.mapping.preset.insert({
      -- Do not use Enter to accept the current autocomple option.  It's not always what I want
      -- and is very annoying in those cases.
      --
      -- This is an nvim-cmp default that must be overridden, however people using LazyVim get confused and think that this very odd default behavior is a LazyVim default.
      -- For a lot of background see https://github.com/LazyVim/LazyVim/issues/2533
      ["<CR>"] = vim.NIL,

      -- Tab also has no place in the completion flow.  Tab is used to expand Copilot suggestions
      ["<Tab>"] = vim.NIL,

      -- toggle completion menu
      ["<C-e>"] = cmp.mapping.complete(),
    })
  end,
}
