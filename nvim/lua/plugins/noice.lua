return {
  "folke/noice.nvim",
  opts = {
    views = {
      cmdline_popup = {
        position = { row = 5, col = "50%" },
        size = { width = 60, height = "auto" },
      },
      popupmenu = {
        enabled = true,
        relative = "editor",
        position = { row = 8, col = "50%" },
        size = { width = 60, height = 10 },
        border = { style = "rounded", padding = { 0, 1 } },
        win_options = {
          winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
        },
      },
    },
    presets = {
      lsp_doc_border = true,
      command_palette = true,
    },
  },
  config = function(_, opts)
    -- Is there anything in this hover response worth showing? ts_ls answers
    -- with no contents at all and graphql with an empty `contents = {}`, both
    -- of which noice counts as a response worth notifying about.
    -- Same shape checks vim.lsp.buf.hover does in nvim 0.11+.
    local function has_content(contents)
      if type(contents) == "string" then
        return #contents > 0
      elseif type(contents) == "table" then
        local value = vim.tbl_get(contents, "value") -- MarkupContent / MarkedString pair
          or vim.tbl_get(contents, 1, "value") -- MarkedString[] of pairs
          or contents[1] -- MarkedString[] of strings
          or ""
        return #value > 0
      end
      return false
    end

    -- Noice's hover runs its handler once per attached client, so every client
    -- without anything to say fires its own "No information available" -- on a
    -- tsx buffer that's ts_ls and graphql notifying even when tailwindcss did
    -- return a doc. Keep noice's per-reply rendering (a client that is slow or
    -- never answers, as tailwindcss does while indexing, must not block the
    -- others) but hold the notification until every client has come back empty.
    local function hover()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/hover" })
      if #clients == 0 then
        vim.notify("No information available", vim.log.levels.INFO)
        return
      end

      local Docs = require("noice.lsp.docs")
      local Format = require("noice.lsp.format")

      local remaining = #clients
      local message, focused, shown

      for _, client in ipairs(clients) do
        local params = vim.lsp.util.make_position_params(0, client.offset_encoding)

        client:request("textDocument/hover", params, function(_, result)
          remaining = remaining - 1

          if result and has_content(result.contents) then
            if not message then
              message = Docs.get("hover")
              focused = message:focus()
            end
            if focused then
              return -- the hover window is focused: leave it alone
            end
            if shown then
              Format.format(message, "---", { ft = vim.bo[bufnr].filetype })
            end
            Format.format(message, result.contents, { ft = vim.bo[bufnr].filetype })
            shown = true
            Docs.show(message)
          elseif remaining == 0 and not shown then
            vim.notify("No information available", vim.log.levels.INFO)
          end
        end, bufnr)
      end
    end

    require("noice").setup(opts)

    -- noice.setup() defers its init to VimEnter, and that deferred init does
    -- `vim.lsp.buf.hover = M.hover`, so overriding the global here alone would
    -- just get clobbered. Patch the field it assigns from (this also keeps
    -- `:checkhealth noice` happy) plus the global, for the already-entered case
    -- where noice.setup() only schedules its init on the event loop.
    require("noice.lsp").hover = hover
    vim.lsp.buf.hover = hover
  end,
}
