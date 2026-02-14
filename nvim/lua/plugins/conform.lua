return {
  "stevearc/conform.nvim",
  opts = function()
    return {
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
        json = { "prettier" },
        jsonc = { "prettier" },
        typescript = { "prettier" },
        javascript = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        htmlangular = { "prettier" },
        go = { "gofumpt" },
        markdown = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        python = { "black" },
        nix = { "alejandra" },
      },
    }
  end,
}
