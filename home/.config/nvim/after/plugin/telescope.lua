
-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
local actions = require("telescope.actions")
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
	-- when I hit `esc` I want to exit telescope, not go to normal mode
        ["<esc>"] = actions.close
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')

-- The following mappings are an attempt to recreate fzf.vim plugin
-- functionality in terms of telescope.  I don't currently use this, since
-- I find I still prefer the fzf plugin, and as long as it's maintained and works
-- I'll stick with that.  I'm still keeping the telescope config because other plugins
-- in the neovim ecosystem use telescope so it should still be set up to my liking
--
-- These mappings are only activated if there is no fzf and therefore the fzf-based
-- versions aren't available
if not vim.fn.executable("fzf")  then
	print("fzf not available; falling back to telescope for fuzzy file finding")

	-- List all files, not just git files, but respects .gitignore
	vim.keymap.set('n', '<C-t>', function()
		builtin.find_files( { find_command = {"fd", "--hidden"} })
	end)

	-- List all files, and do not respect .gitignore
	vim.keymap.set('n', '<leader>af', function() 
		builtin.find_files({ find_command = {"fd", "--no-ignore", "--hidden"} })
	end)

	-- List only files in under git source control, obviously also respecting .gitignore
	--
	vim.keymap.set('n', '<leader>gf', builtin.git_files, {})

	-- TODO: think of a binding for `builtin.resume` which will restore the last used telescope 
	-- including selection

	vim.keymap.set('n', '<leader>l', builtin.live_grep, {})

	-- List all open buffers in vim
	vim.keymap.set('n', '<leader>b', builtin.buffers, {})

	-- Live grep of all lines in current directory (recursive
	vim.keymap.set('n', '<leader>l', builtin.grep_string, {})

	-- Live grep of all lines in current buffer
	vim.keymap.set('n', 'C-p', builtin.current_buffer_fuzzy_find, {})

	-- List of previously opened files
	vim.keymap.set('n', '<leader>m', builtin.oldfiles, {})

	-- All help tags
	vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
end

-- NOTE: some key bindings in `lsp.lua` also use Telescope APIs.  They're stored in the 
-- lsp folder since they are logically concerened with LSP navigation.
