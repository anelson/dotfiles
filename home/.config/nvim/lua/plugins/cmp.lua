-- Customize the completion sources and behavior
-- In my previous config this was mixed in with lsp.lua but it makes more sense to separate it
return {
  "hrsh7th/nvim-cmp",
  dependencies = { "hrsh7th/cmp-emoji" },
  ---@param opts cmp.ConfigSchema
  opts = function(_, opts)
    table.insert(opts.sources, { name = "emoji" })

    table.insert(opts.sources, { name = "path" })
    table.insert(opts.sources, { name = "nvim_lsp" })
    table.insert(opts.sources, { name = "nvim_lua" })
    table.insert(opts.sources, { name = "buffer", keyword_length = 3 })
    table.insert(opts.sources, { name = "luasnip", keyword_length = 2 })
  end,
}
