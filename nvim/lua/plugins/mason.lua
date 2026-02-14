return {
  "mason-org/mason.nvim",
  enabled = false,
  opts = {},
  config = function(opts)
    local mason = require("mason")
    mason.setup(opts)
    require("mason-lspconfig").setup({
      -- ensure_installed = { "angularls", "bashls", "tsserver" }, -- auto install
      automatic_installation = false,
    })
  end,
}
