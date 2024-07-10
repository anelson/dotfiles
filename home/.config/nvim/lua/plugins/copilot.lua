return {
  "github/copilot.vim",
  config = function()
    --vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)')
    --vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)')
    vim.keymap.set("i", "<C-Space>", "<Plug>(copilot-suggest)")
  end,
}
