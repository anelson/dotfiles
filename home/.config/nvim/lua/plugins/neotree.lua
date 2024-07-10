return {
  "nvim-neo-tree/neo-tree.nvim",
  dependencies = { "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
  cmd = "Neotree",
  keys = {
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({ toggle = true, reveal = false, dir = LazyVim.root() })
      end,
      desc = "Explorer NeoTree (Root Dir)",
    },
    {
      "<leader>fE",
      function()
        require("neo-tree.command").execute({ toggle = true, reveal = true, dir = LazyVim.root() })
      end,
      desc = "Reveal current file in NeoTree",
    },
  },
  config = function()
    require("neo-tree").setup({
      auto_expand_width = true,
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            -- Close the neotree panel if we open a file
            require("neo-tree.command").execute({ action = "close" })
          end,
        },
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            -- I *must* have relative line numbers to navitage this sidebar
            vim.opt_local.relativenumber = true
          end,
        },
      },
    })
  end,
}
