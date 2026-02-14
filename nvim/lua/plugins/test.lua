return {
  { "nvim-neotest/nvim-nio" },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
    },
    opts = function(_, opts)
      table.insert(opts.adapters, require("neotest-vitest"))
    end,
  },
}
