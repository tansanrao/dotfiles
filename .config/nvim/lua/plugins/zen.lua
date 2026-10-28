return {
  {
    "folke/snacks.nvim",
    opts = {
      zen = {
        win = {
          backdrop = {
            transparent = false,
            blend = 0,
            -- Follow the active theme instead of the default black backdrop.
            win = { wo = { winhighlight = "Normal:Normal,NormalNC:Normal" } },
          },
        },
      },
    },
  },
}
