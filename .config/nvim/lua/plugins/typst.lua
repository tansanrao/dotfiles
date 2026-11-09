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
  {
    "chomosuke/typst-preview.nvim",
    opts = {
      -- Relative to Neovim's working directory (the project root).
      extra_args = { "--font-path=fonts" },
      -- Tinymist's partial rendering (experimental) can leave stale pages
      -- drawn over others, e.g. the last page on top of page 1.
      partial_rendering = false,
      -- Preview the whole paper when opened from a section file.
      get_main_file = function(path)
        return main_file(path) or path
      end,
    },
  },
}
