return {
  -- NOTE: I do *NOT* use the LazyVim copilot extra, therefore all of this config must be done manually
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    lazy = false,
    opts = {
      panel = {
        enabled = false,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        keymap = {
          -- <Tab> is mapped to accepting the copilot suggestion, but it's in keymaps.lua because
          -- it's a bit more complex than just setting `accept` here.
          accept = false,
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        --Don't need to explicitly enable most file types, but copilot is by default disabled
        --for these, but I want to re-enabled it.
        yaml = true,
        markdown = true,
        help = true,
        gitcommit = true,
        gitrebase = true,
      },
    },
  },
}
