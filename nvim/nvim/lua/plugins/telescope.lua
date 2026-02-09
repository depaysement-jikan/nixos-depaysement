---@diagnostic disable: redefined-local
return {
  "nvim-telescope/telescope.nvim",
  opts = {
    priority = 1000,
    additional_args = function()
      return { "--follow" }
    end,
    defaults = {
      path_display = { "truncate" },
      layout_strategy = "vertical",
      layout_config = {
        prompt_position = "bottom",
        width = 0.95,
      },
      sorting_strategy = "ascending",
      winblend = 0,
    },
  },
  config = function(_, opts)
    require("telescope").setup(opts)

    local builtin = require("telescope.builtin")
    if not string.match(vim.bo.filetype, "snacks_dashboard") then
      vim.keymap.set("n", "<leader><leader>", function()
        builtin.find_files({
          cwd = vim.fn.getcwd(),
          find_command = { "fd", "--type", "f", "--follow" },
        })
      end, { desc = "Telescope (Root Dir)" })
      vim.keymap.set("n", "<leader>sg", function()
        builtin.live_grep({
          cwd = vim.fn.getcwd(),
        })
      end, { desc = "live Grep (Root Dir)" })
      local pickers_to_patch = {
        "grep_string",
        "buffers",
        "oldfiles",
        "quickfix",
        "loclist",
        "diagnostics",
        "lsp_definitions",
        "lsp_references",
        "lsp_implementations",
        "lsp_type_definitions",
        "lsp_declarations",
        "lsp_incoming_calls",
        "lsp_outgoing_calls",
        "lsp_code_actions",
        "lsp_range_code_actions",
        "lsp_document_symbols",
        "lsp_workspace_symbols",
        "lsp_dynamic_workspace_symbols",
      }

      for _, picker in ipairs(pickers_to_patch) do
        local original = builtin[picker]
        if original then
          builtin[picker] = function(opts)
            opts = opts or {}
            opts.cwd = vim.fn.getcwd()
            return original(opts)
          end
        end
      end
    end
  end,
}
