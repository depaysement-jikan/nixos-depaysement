return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "L3MON4D3/LuaSnip", -- required even if you don't use snippets
  },
  config = function()
    local cmp = require("cmp")

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      window = {
        completion = {
          border = "rounded",
          winhighlight = "NormalFloat:Pmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel",
        },
        documentation = {
          border = "rounded",
          winhighlight = "NormalFloat:Pmenu,FloatBorder:CmpBorder",
        },
      },
      mapping = cmp.mapping.preset.insert({
        ["<Tab>"] = cmp.mapping.select_next_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }),
      sources = {
        { name = "nvim_lsp" },
      },
    })
  end,
}
