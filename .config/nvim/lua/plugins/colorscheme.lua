return {
  { "projekt0n/github-nvim-theme", name = "github-theme", lazy = true },
  {
    "LazyVim/LazyVim",
    opts = {
      -- Select the GitHub variant matching the terminal's detected appearance.
      colorscheme = function()
        -- Keep the theme's background assignment out of the sourced startup
        -- context, which would disable Neovim's native terminal detection.
        vim.schedule(function()
          local variant = vim.o.background == "light" and "github_light_default" or "github_dark_default"
          require("github-theme").load({ theme = variant })
          vim.g.colors_name = "rex"
        end)
      end,
    },
  },
}
