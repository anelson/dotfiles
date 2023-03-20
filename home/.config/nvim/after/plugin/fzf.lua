-- configure the fzf plugin upon which I rely heavily for my neovim productivity
-- use fzf as a plugin
if vim.fn.executable("fzf") then
  -- when opening a buffer, jump to the existing window if possible
  vim.g.fzf_buffers_jump = 1

  -- Customize fzf colors to match your color scheme
  vim.g.fzf_colors = {
    fg = {'fg', 'Normal'},
    bg = {'bg', 'Normal'},
    hl = {'fg', 'Comment'},
    ['fg+'] = {'fg', 'CursorLine', 'CursorColumn', 'Normal'},
    ['bg+'] = {'bg', 'CursorLine', 'CursorColumn'},
    ['hl+'] = {'fg', 'Statement'},
    info = {'fg', 'PreProc'},
    border = {'fg', 'Ignore'},
    prompt = {'fg', 'Conditional'},
    pointer = {'fg', 'Exception'},
    marker = {'fg', 'Keyword'},
    spinner = {'fg', 'Label'},
    header = {'fg', 'Comment'}
  }

  -- customize the layout
  -- If running under tmux, use a tmux popup for fzf
  if vim.env.TMUX ~= nil then
    vim.g.fzf_layout = {tmux = '-p90%,60%'}
  else
    vim.g.fzf_layout = {down = '~40%'}
  end

  -- The `Rg` fzf command, which uses Ripgrep to search the current directory,
  -- is more useful if we can combine the interactive search results with the
  -- quickfix list.
  local function build_quickfix_list(lines)
    -- Note 'r' means replace the existing contents, and the 'title' makes it
    -- clear which quickfix list we want replaced.
    --
    -- BUG: This doesn't work right currently.  LanguageClient-neovim puts
    -- errors in its own quickfix list, and when it does so for some reason all
    -- other quickfix lists get cleared.
    --
    -- ANOTHER BUG: The neovim docs are very clear about the use of a 'title'
    -- element in the third arg to specify a title of the list, but it doesn't
    -- work.  The title is always ":setqflist()".
    local items = vim.tbl_map(function(val)
      return {filename = val}
    end, lines)
    vim.fn.setqflist({}, 'r', {title = 'ripgrep results', items = items})
    vim.cmd('copen')
    vim.cmd('cc')
  end

  -- set non-default actions to open in a tab, split, etc
  vim.g.fzf_action = {
    ['ctrl-q'] = build_quickfix_list,
    ['ctrl-t'] = 'tab split',
    ['ctrl-x'] = 'split',
    ['ctrl-v'] = 'vsplit'
  }

  -- The default Ctrl-A to select all items in the FZF results doesn't work
  -- because we use Ctrl-A for tmux.  So use Ctrl-S instead, even though that
  -- feels wrong.
  vim.env.FZF_DEFAULT_OPTS = vim.env.FZF_DEFAULT_OPTS .. ' --bind ctrl-s:select-all'

  -- Define a custom command `AllFiles`, which is like `Files` but provides a
  -- different command to `fd` so that it does not filter out files that are
  -- ignored by `.gitignore`.  This is useful because sometimes you want to get
  -- to a file produced by a build system but it's normally invisible to
  -- `Files` due to `.gitignore`
  --
  -- The help topic about customizing files command was helpful in figuring out
  -- how to customize the behavior of #files
  -- TODO: there must be a more neovim-native way to do this
  vim.cmd("command! -bang -nargs=? -complete=dir AllFiles call luaeval('require(\"fzf\")#vim#files(_A.arg, {\"source\": _A.fzf_default_command .. \" --no-ignore\"}, _A.bang)', {'argvim.cmd. <q-args>, 'fzf_default_commandvim.cmd. $FZF_DEFAULT_COMMAND, 'bangvim.cmd. <bang>0})")

  -- fzf.vim provides so many handy commands.  Here are bindings for a few:
  -- * Ctrl-T - Files - like ctrl-p but fast
  -- * Ctrl-P - Lines in the current buffer
  -- * <leader>p - BLines - Lines in all open buffers
  -- * <leader>b - Buffers - like ctrl-p's buffer list but, again, fast
  -- * <Leader>h - Helptags - fuzzy search help tags, lolwut??
  -- * <Leader>m - History - most recently used files
  vim.keymap.set("n", "<C-t>", vim.cmd.Files)
  -- vim.keymap.set('n', '<C-t>', vim.cmd.Files, {})
  vim.keymap.set("n", '<Leader>af', vim.cmd.AllFiles)

  -- For files that have LSP support the <C-p> and <Leader>p mappings are
  -- overridden to use the LSP.  But I always want to be able to do a fzf lines
  -- search so also bind to <Leader>l
  vim.keymap.set('n', '<Leader>l', vim.cmd.Lines)
  vim.keymap.set('n', '<C-p>', vim.cmd.BLines)
  vim.keymap.set('n', '<Leader>p', vim.cmd.Lines)
  vim.keymap.set('n', '<Leader>b', vim.cmd.Buffers)
  vim.keymap.set('n', '<Leader>h', vim.cmd.Helptags)
  vim.keymap.set('n', '<Leader>m', vim.cmd.History)
end

