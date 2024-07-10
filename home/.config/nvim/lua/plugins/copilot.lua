return {
  {
    -- I don't like the default behavior of the lua copilot version.
    -- Maybe this will bite me in the ass since LazyVim presumably tightly integrates this into the completion methods.
    -- We'll see.
    "zbirenbaum/copilot.lua",
    enabled = false,
  },
  {
    "github/copilot.vim",
    config = function()
      --vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)')
      --vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)')
      vim.keymap.set("i", "<C-Space>", "<Plug>(copilot-suggest)")
    end,
  },
}
