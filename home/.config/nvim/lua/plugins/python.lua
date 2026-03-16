-- Try to unfuck the default Python config which runs a very broken `pylsp` internal formatter
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pylsp = {
          settings = {
            pylsp = {
              plugins = {
                -- Disable ALL formatting in pylsp
                autopep8 = { enabled = false },
                yapf = { enabled = false },
                pycodestyle = { enabled = false },
                pyflakes = { enabled = true }, -- Keep linting
                pylint = { enabled = false },
                rope_completion = { enabled = true },
                jedi_completion = { enabled = true },
                jedi_hover = { enabled = true },
                jedi_references = { enabled = true },
                jedi_signature_help = { enabled = true },
                jedi_symbols = { enabled = true },
              },
            },
          },
        },
      },
    },
  },
}
