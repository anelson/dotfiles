-- Preserve not only the cursor position but also the location of the cursor
-- on the screen when switching between buffers in a window.
-- Shockingly this is not the default behavior.
--
-- This is required as part of loading `set.lua`, it's not meant to be sourced directly
local M = {}

function M.auto_save_win_view()
  if vim.w.SavedBufView == nil then
    vim.w.SavedBufView = {}
  end
  vim.w.SavedBufView[vim.fn.bufnr("%")] = vim.fn.winsaveview()
end

function M.auto_restore_win_view()
  local buf = vim.fn.bufnr("%")
  if vim.w.SavedBufView ~= nil and vim.w.SavedBufView[buf] ~= nil then
    local v = vim.fn.winsaveview()
    local at_start_of_file = v.lnum == 1 and v.col == 0
    if at_start_of_file and vim.o.diff == false then
      vim.fn.winrestview(vim.w.SavedBufView[buf])
    end
    vim.w.SavedBufView[buf] = nil
  end
end

return M
