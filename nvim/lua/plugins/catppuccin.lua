return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    colorscheme = "catppuccin-frappe",
    term_colors = true,
    priority = 1000,
    transparent_background = true,
    dim_inactive = {
      enabled = false,
      shade = "dark",
      percentage = 0.25,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)

    -- Set colorscheme first
    vim.cmd.colorscheme("catppuccin-macchiato")

    -- Hook into ColorScheme event to override highlight groups
    vim.api.nvim_create_autocmd("ColorScheme", {
      pattern = "*",
      callback = function()
        local hl = vim.api.nvim_set_hl
        hl(0, "Normal", { bg = "NONE" })
        hl(0, "NormalNC", { bg = "NONE" })
        hl(0, "CursorLine", { bg = "NONE" })
        hl(0, "Pmenu", { bg = "NONE" })
        hl(0, "VertSplit", { bg = "NONE" })
      end,
    })
  end,
}
