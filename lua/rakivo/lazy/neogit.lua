return {
  "NeogitOrg/neogit",
  event = "BufReadPre",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  config = function()
    require("neogit").setup {
      kind = "split",
      integrations = {
        diffview = true
      },
    }
  end
}
