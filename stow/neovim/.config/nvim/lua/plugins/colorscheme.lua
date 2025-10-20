return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000,
    opts = {
      -- optional: tweak here if you like
      variant = "auto", -- main/moon/dawn auto picks by background
      dark_variant = "main", -- "main" for classic Rosé Pine dark
      styles = { transparency = false },
    },
    config = function(_, opts)
      require("rose-pine").setup(opts)
      vim.o.background = "light"
      vim.cmd.colorscheme("rose-pine")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "rose-pine" },
  },
}
