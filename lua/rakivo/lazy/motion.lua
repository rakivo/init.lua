return {
  {
    "bkad/CamelCaseMotion",
    config = function()
      -- Map w/b/e to CamelCase motions in NORMAL, OPERATOR, and VISUAL modes
      vim.keymap.set({ "n", "x", "o" }, "w", "<Plug>CamelCaseMotion_w", {})
      vim.keymap.set({ "n", "x", "o" }, "b", "<Plug>CamelCaseMotion_b", {})
      vim.keymap.set({ "n", "x", "o" }, "e", "<Plug>CamelCaseMotion_e", {})

      -- Optional: keep original motions under leader+w/b/e
      vim.keymap.set({ "n", "x", "o" }, "<leader>w", "w", { remap = true })
      vim.keymap.set({ "n", "x", "o" }, "<leader>b", "b", { remap = true })
      vim.keymap.set({ "n", "x", "o" }, "<leader>e", "e", { remap = true })
    end,
  },
}
