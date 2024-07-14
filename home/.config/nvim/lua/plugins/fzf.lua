-- I have used fzf.vim for a long time, but LazyVim has an "extra" for Fzf that uses fzf-lua instead.
-- So I''ve adapted my config to that.
return {
  "ibhagwan/fzf-lua",

  -- optional for icon support
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    -- calling `setup` is optional for customization
    require("fzf-lua").setup({
      -- Set Fzf colors based on current neovim color scheme
      fzf_colors = true,
    })
  end,

  -- These bindings are a mix of my old fzf bindings, and the stock LazyVim bindings from
  -- https://github.com/LazyVim/LazyVim/blob/11268d8ff1c3675dd4afe45dfd0348cd36a98731/lua/lazyvim/plugins/extras/editor/fzf.lua#L219, but
  -- tweaked
  keys = {
    -- This map I use in hop, having it automatically mapped to fzf is maddening
    { "<Leader>,", false },

    -- File navigation
    {
      "<Leader>fr",
      function()
        require("fzf-lua").resume()
      end,
      desc = "Re-open last fzf",
    },

    { "<leader>ff", LazyVim.pick("auto"), desc = "Find Files (Root Dir)" },

    -- Keep the Control-T binding for compatibility with years of muscle memory
    { "<C-t>", LazyVim.pick("auto"), desc = "Find Files (Root Dir)" },
    { "<leader>fF", LazyVim.pick("auto", { root = false }), desc = "Find Files (cwd)" },

    { "<leader>fm", "<cmd>FzfLua oldfiles<cr>", desc = "Recent" },
    { "<leader>fM", LazyVim.pick("oldfiles", { cwd = vim.uv.cwd() }), desc = "Recent (cwd)" },

    { "<leader>f/", LazyVim.pick("live_grep"), desc = "Grep (Root Dir)" },

    {
      "<Leader>fL",
      function()
        require("fzf-lua").lines()
      end,
      desc = "FZF search all lines in all open buffers",
    },
    {
      "<Leader>fl",
      function()
        require("fzf-lua").blines()
      end,
      desc = "FZF search all lines in the current buffer",
    },
    {
      "<Leader>fb",
      function()
        require("fzf-lua").buffers()
      end,
      desc = "FZF search the list of open buffers",
    },
    {
      "<Leader>bb",
      "<Leader>fb",
      desc = "FZF search the list of open buffers",
    },
    {
      "<Leader>fh",
      function()
        require("fzf-lua").helptags()
      end,
      desc = "FZF search all help tags",
    },

    -- LSP-related operations
    {
      "<space>s",
      function()
        require("fzf-lua").lsp_live_workspace_symbols({})
      end,
      desc = "Goto Symbol (Workspace)",
    },
    {
      "<space>o",
      function()
        require("fzf-lua").lsp_document_symbols({})
      end,
      desc = "Goto Symbol (Document)",
    },
    {
      "gr",
      function()
        require("fzf-lua").lsp_document_symbols({})
      end,
      desc = "Goto Symbol (Document)",
    },
    {
      "gd",
      "<cmd>FzfLua lsp_definitions     jump_to_single_result=true ignore_current_line=true<cr>",
      desc = "Goto Definition",
    },
    {
      "gr",
      "<cmd>FzfLua lsp_references      jump_to_single_result=true ignore_current_line=true<cr>",
      desc = "References",
      nowait = true,
    },
    {
      "gI",
      "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>",
      desc = "Goto Implementation",
    },
    {
      "gy",
      "<cmd>FzfLua lsp_typedefs        jump_to_single_result=true ignore_current_line=true<cr>",
      desc = "Goto T[y]pe Definition",
    },
  },
}
