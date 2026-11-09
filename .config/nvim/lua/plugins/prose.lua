return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        harper_ls = {
          filetypes = { "markdown", "typst" },
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
