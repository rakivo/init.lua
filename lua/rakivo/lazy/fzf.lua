return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local fzf = require("fzf-lua")
      local opts = { noremap = true, silent = true }

      fzf.setup({
        winopts = {
          height = 0.3,   -- 30% height
          width = 1,      -- full width
          row = 1,        -- align bottom
          col = 0,        -- start from left edge
          border = "none",
          preview = { hidden = "hidden" }, -- no preview by default
        },
        -- winopts = {
        --   height = 0.85,
        --   width = 0.80,
        --   preview = { hidden = "hidden" }, -- no preview by default
        -- },
      })

      vim.keymap.set("n", "<C-p>", fzf.git_files, opts)
      vim.keymap.set("n", "<M-q>", fzf.files, opts)
      vim.keymap.set("n", "<M-e>", fzf.live_grep, opts)
      vim.keymap.set("n", "<leader>ps", function()
        fzf.grep({ search = vim.fn.input("Grep > ") })
      end, opts)
      vim.keymap.set("n", "<leader>vh", fzf.help_tags, opts)
    end,
  },
}
