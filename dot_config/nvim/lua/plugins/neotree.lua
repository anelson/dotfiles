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
      commands = {
        -- Courtesy: https://github.com/nvim-neo-tree/neo-tree.nvim/discussions/370#discussioncomment-8303412
        copy_selector = function(state)
          -- NeoTree is based on [NuiTree](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree)
          -- The node is based on [NuiNode](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree#nuitreenode)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local results = {
            filepath,
            modify(filepath, ":."),
            modify(filepath, ":~"),
            filename,
            modify(filename, ":r"),
            modify(filename, ":e"),
          }

          vim.ui.select({
            "1. Absolute path: " .. results[1],
            "2. Path relative to CWD: " .. results[2],
            "3. Path relative to HOME: " .. results[3],
            "4. Filename: " .. results[4],
            "5. Filename without extension: " .. results[5],
            "6. Extension of the filename: " .. results[6],
          }, { prompt = "Choose to copy to clipboard:" }, function(choice)
            if choice then
              local i = tonumber(choice:sub(1, 1))
              if i then
                local result = results[i]

                -- Copy the chosen path to the internal clipboard register and the system clipboard as well
                vim.fn.setreg('"', result)
                vim.fn.setreg("+", result)
                vim.notify("Copied: " .. result)
              else
                vim.notify("Invalid selection")
              end
            else
              vim.notify("Selection cancelled")
            end
          end)
        end,
      },
      window = {
        mappings = {
          Y = "copy_selector",
        },
      },
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
