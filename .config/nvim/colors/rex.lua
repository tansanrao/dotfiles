-- Neovim detects the terminal background and reloads this scheme when it changes.
local variant = vim.o.background == "light" and "github_light_default" or "github_dark_default"
require("github-theme").load({ theme = variant })

-- Reload this selector rather than pinning subsequent reloads to one variant.
vim.g.colors_name = "rex"
