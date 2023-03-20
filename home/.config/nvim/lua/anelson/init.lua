-- anelson's neovim config
--
-- guide:
--
-- `packer` contains the packer invocations to initialize packer itself, and to load various plugins.
-- `remap` contains all key bindings that are not plugin specific
-- `set` contains (neo)vim option settings that do not pertain to any specific plugin
--
-- Configuration of individual plugins is in `XDG_CONFIG_HOME/nvim/plugin/after`, with an individual Lua file 
-- for each plugion.

-- disable netrw at the very start of init.lua (strongly advised by nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('anelson.packer')
require('anelson.remap')
require('anelson.set')

