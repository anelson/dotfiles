-- Use `is` in place of the built-in neovim inc search because it is smart enough to
-- clear the highlight after some cursor movement
--vim.api.nvim_set_keymap('', '/', '<Plug>(is-nohl)', {})
--vim.api.nvim_set_keymap('', '?', '<Plug>(incsearch-easymotion-?)', {})
--vim.api.nvim_set_keymap('', 'g/', '<Plug>(incsearch-easymotion-stay)', {})
--vim.api.nvim_set_keymap('', 'z/', '<Plug>(incsearch-fuzzy-/)', {})
--vim.api.nvim_set_keymap('', 'z?', '<Plug>(incsearch-fuzzy-?)', {})
--vim.api.nvim_set_keymap('', 'zg/', '<Plug>(incsearch-fuzzy-stay)', {})
--
--
---- Use the easymotion version of n/N so repeat easymotion searches
--vim.api.nvim_set_keymap('', 'n', '<Plug>(easymotion-next)', {})
--vim.api.nvim_set_keymap('', 'N', '<Plug>(easymotion-prev)', {})
--
---- Use incsearch plugin for the usual search operators
--vim.api.nvim_set_keymap('', '*', '<Plug>(incsearch-nohl-*)', {})
--vim.api.nvim_set_keymap('', '#', '<Plug>(incsearch-nohl-#)', {})
--vim.api.nvim_set_keymap('', 'g*', '<Plug>(incsearch-nohl-g*)', {})
--vim.api.nvim_set_keymap('', 'g#', '<Plug>(incsearch-nohl-g#)', {})
--