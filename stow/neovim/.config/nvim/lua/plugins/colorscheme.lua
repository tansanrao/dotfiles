return {
  {
    "Shatur/neovim-ayu",
    name = "ayu",
    lazy = false,
    priority = 1000,
    opts = {
      mirage = false,
      terminal = true,
      overrides = {},
    },
    config = function(_, opts)
      require("ayu").setup(opts)
      vim.o.background = "dark"
      vim.cmd.colorscheme("ayu")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "ayu" },
  },
}
