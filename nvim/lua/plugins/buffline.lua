return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    local pastel_purple = "#D6A2E8"

    opts.options = {
      mode = "buffers",
      indicator = {
        style = "underline",
      },
      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },
      diagnostics = "nvim_lsp",
      show_close_icon = false,
      show_buffer_close_icons = false,
    }

    opts.highlights = {
      buffer_visible = {
        fg = "#666666",
        italic = true,
        gui = "italic",
      },
      buffer_selected = {
        fg = pastel_purple,
        bold = true,
        sp = pastel_purple,
        underline = true,
        gui = "bold,underline",
      },
      separator_selected = {
        fg = pastel_purple,
        bg = "NONE",
      },
      indicator_selected = {
        fg = pastel_purple,
        sp = pastel_purple,
        underline = true,
        gui = "underline",
      },
    }

    return opts
  end,
}
