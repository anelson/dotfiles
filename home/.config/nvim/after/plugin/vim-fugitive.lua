-- Automatically delete ephemeral fugitive buffers so they don't drive me mad
vim.cmd [[ autocmd BufReadPost fugitive://* set bufhidden=delete ]]
