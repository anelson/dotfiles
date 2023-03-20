local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local function is_file_tree_window()
    local filetype = vim.bo.filetype
    return filetype == "nerdtree" or filetype == "NvimTree"
end

local function disable_statusline()
    -- TODO: sadly this seems not to work.  I have found some other reports that setting this window variable
    -- doesn't actually do anything.  How to suppress the status line in its entirety for these kinds of windows 
    -- is as yet unknown
    if is_file_tree_window() then
        vim.api.nvim_win_set_var(0, "airline_disable_statusline", 1)
    else
        vim.api.nvim_win_set_var(0, "airline_disable_statusline", 0)
    end
end

local disable_airline_au = augroup("DisableAirlineForCertainWindows", {})
autocmd({"BufWinEnter", "BufReadPost"}, {
    group = disable_airline_au,
    pattern = "*",
    callback = function() 
	disable_statusline()
    end
})

-- TODO:
-- Files don't show file icons in tab bar
