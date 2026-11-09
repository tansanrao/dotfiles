-- Rex configuration. Reload with: rex config check && rex config reload

-- Live Typst preview in a pane beside the editor (github.com/CiaranMcDonnell/rex-typst).
-- rex-typst.lua is a symlink into ~/work/rex-typst; the binary is installed
-- to ~/.local/bin with `cargo install --locked --path . --root ~/.local`.
-- Papers that vendor fonts (fonts/) need them installed in ~/Library/Fonts,
-- since rex-typst only loads system fonts.
require("rex-typst").setup{}
rex.bind("ctrl+space>t", "typst_toggle")
