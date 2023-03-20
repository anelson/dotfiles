-- This is the old NERDtree config, that this config is attempting to duplicate:
-- nnoremap <Leader>f :NERDTreeToggle<Enter>
-- nnoremap <Leader>F :NERDTreeFind<Enter>
-- let NERDTreeHijackNetrw = 1 " netrw is crap; NERDTree sucks less
-- let NERDTreeQuitOnOpen = 1 " I want to force myself to use a vim-like way of exploring
-- let NERDTreeAutoDeleteBuffer = 1 "No reason to keep the buffer of a deleted file around
-- let NERDTreeChDirMode = 2 "changing the root in nerdtree changes vim's cwd
-- let NERDTreeMinimalUI = 1
-- let NERDTreeDirArrows = 1
-- let NERDTreeShowLineNumbers = 1 " I am addicted to navigation by line number
-- autocmd FileType nerdtree setlocal relativenumber " make sure relative line numbers are used

local M = {}

local api = require("nvim-tree.api")

function M.on_attach(bufnr)
  -- apply the default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- then override the ones that I want to change
  vim.keymap.set('n', 'h', api.tree.toggle_help,   { desc = 'Help',  buffer = bufnr, noremap = true, silent = true, nowait = true })
  vim.keymap.set('n', '?', api.tree.toggle_help,   { desc = 'Help',  buffer = bufnr, noremap = true, silent = true, nowait = true })
  vim.keymap.set('n', 'p', M.print_node_path,      { desc = 'Print', buffer = bufnr, noremap = true, silent = true, nowait = true })
end

function M.print_node_path()
  local node = api.tree.get_node_under_cursor()
  print(node.absolute_path)
end

require("nvim-tree").setup({
  renderer = {
    group_empty = true,
  },
  filters = {
    -- Don't hide dotfiles by default
    dotfiles = true,
  },
  view = {
    -- I like to navigate in the tree with relative line numbers just like I do anywhere else
    relativenumber = true,

    -- The default width of 30 is a bit too cramped
    width = 40
  },
  actions = {
    open_file = {
      -- After opening a file with the tree, close the tree.  If I want to see the tree again
      -- I'll re-open it myself
      quit_on_open = true
    }
  },

  -- Override some keyboard shortcuts because I'm very used to NERDtree
  on_attach = M.on_attach
})

vim.keymap.set("n", "<Leader>f", vim.cmd.NvimTreeToggle)
vim.keymap.set("n", "<Leader>F", vim.cmd.NvimTreeFindFileToggle)
