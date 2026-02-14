return {
  "akinsho/git-conflict.nvim",
  version = "*",
  config = true,
  keys = function()
    local conflict = require("git-conflict")
    vim.keymap.set({ "n" }, "<leader>co", function()
      conflict.choose("ours")
    end, { desc = "Conflict choose ours" })
    vim.keymap.set({ "n" }, "<leader>ct", function()
      conflict.choose("theirs")
    end, { desc = "Conflict choose theirs" })
    vim.keymap.set({ "n" }, "<leader>cb", function()
      conflict.choose("both")
    end, { desc = "Conflict choose both" })
    vim.keymap.set({ "n" }, "<leader>cx", function()
      conflict.choose("none")
    end, { desc = "Conflict choose none" })
    vim.keymap.set({ "n" }, "<leader>cn", function()
      conflict.find_next("base")
    end, { desc = "Conflict next" })
    vim.keymap.set({ "n" }, "<leader>cp", function()
      conflict.find_prev("base")("none")
    end, { desc = "Conflict previous" })
    -- vim.keymap.set({ "n" }, "<leader>cq", function()
    --   conflict.conflicts_to_qf_items(callback)
    -- end, { desc = "Conflict add to quickfix" })
  end,
}
