return {
  "uga-rosa/ccc.nvim",
  event = "VeryLazy",
  config = function()
    require("ccc").setup({
      highlighter = {
        auto_enable = true,
        lsp = false, -- optional: enable if you want LSP color integration too
      },
    })
  end,
}
