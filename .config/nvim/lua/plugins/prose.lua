return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        harper_ls = {
          filetypes = { "markdown" },
          settings = {
            ["harper-ls"] = {
              linters = { SpellCheck = true },
            },
          },
        },
      },
    },
  },
}
