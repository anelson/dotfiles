" All LSP-related configs, including LSP bindings
"
" This assumes we're in NeoVim, and that the LSP-related plugins are loaded

" Make sure rust-analyzer is in the path.  If not download it
if empty(glob($HOME.'/.local/bin/rust-analyzer'))
	echo "Downloading rust-analyzer"
	silent execute '!curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer'
	silent execute '!chmod +x ~/.local/bin/rust-analyzer'
	echo "Downloaded rust-analyzer"
endif

" Wire up mappings for LSP-related items
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gy    <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>

" display code actions
nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>

" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

" Show diagnostic popup on cursor hold
set updatetime=300
autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

" Enable type inlay hints
autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
\ lua require'lsp_extensions'.inlay_hints{ prefix = '', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }


" Configure LSP
" https://github.com/neovim/nvim-lspconfig#rust_analyzer

lua <<EOF

-- nvim_lsp object
local nvim_lsp = require'lspconfig'

-- function to attach completion when setting up lsp
local on_attach = function(client)
		-- this actually isn't needed because we configure completion-nvim to attach on every buffer
    -- require'completion'.on_attach(client)
end

-- Enable rust_analyzer
nvim_lsp.rust_analyzer.setup({ on_attach=on_attach })

-- Enable diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)
EOF

