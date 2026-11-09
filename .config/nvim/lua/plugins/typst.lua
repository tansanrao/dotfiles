-- Typst papers keep their fonts in a `fonts/` directory next to the main file
-- so builds match `make` (typst compile --font-path fonts). Relative paths
-- are resolved against the project root. Harmless in projects without one.

-- Projects split into several files (e.g. sections/*.typ) have one main file
-- that includes the rest. Returns the nearest `paper.typ` or `main.typ` above
-- `path`, or nil.
local main_names = { "paper.typ", "main.typ" }
local function main_file(path)
  local root = vim.fs.root(path, main_names)
  if not root then
    return nil
  end
  for _, name in ipairs(main_names) do
    local file = root .. "/" .. name
    if vim.uv.fs_stat(file) then
      return file
    end
  end
end

-- Opens or closes the rex-typst preview pane for the Rex pane Neovim runs in.
local function toggle_rex_preview()
  local block = vim.env.REX_BLOCK
  if not block then
    vim.notify("Typst preview needs Neovim running in a Rex pane", vim.log.levels.WARN)
    return
  end
  vim.system({ "rex", "do", "-b", block, "typst_toggle" }, { text = true }, function(r)
    if r.code ~= 0 then
      vim.schedule(function()
        vim.notify("rex-typst: " .. vim.trim(r.stderr ~= "" and r.stderr or r.stdout), vim.log.levels.ERROR)
      end)
    end
  end)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tinymist = {
          settings = {
            fontPaths = { "fonts" },
            -- Same as Zed: typstyle reflows prose to 80 columns on format.
            formatterMode = "typstyle",
            formatterProseWrap = true,
            formatterPrintWidth = 80,
          },
        },
      },
    },
    init = function()
      -- <leader>cp toggles the rex-typst preview beside this Neovim pane.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function(args)
          vim.keymap.set("n", "<leader>cp", toggle_rex_preview, { buffer = args.buf, desc = "Toggle Typst Preview (Rex)" })
        end,
      })
      -- Pin the main file so a section file is checked as part of the whole
      -- document: its citations and cross-references resolve.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client or client.name ~= "tinymist" then
            return
          end
          local main = main_file(vim.api.nvim_buf_get_name(args.buf))
          if main then
            client:request("workspace/executeCommand", {
              command = "tinymist.pinMain",
              arguments = { main },
            }, nil, args.buf)
          end
        end,
      })
    end,
  },
  -- Previews come from rex-typst in a Rex pane (see ~/.config/rex/init.lua),
  -- which follows the cursor and compiles unsaved buffers. Replaces
  -- typst-preview.nvim's browser preview.
  { "chomosuke/typst-preview.nvim", enabled = false },
}
