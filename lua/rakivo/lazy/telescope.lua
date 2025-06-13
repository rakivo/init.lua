return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local actions = require("telescope.actions")

    require("telescope").setup({
      defaults = {
        -- Ivy‑style layout
        layout_strategy = "vertical",

        -- no preview window
        preview = { hidden = true },

        -- mappings *inside* the picker
        mappings = {
          i = {
            ["<C-j>"] = require("telescope.actions").move_selection_next,
            ["<C-k>"] = require("telescope.actions").move_selection_previous,
            ["<esc>"] = require("telescope.actions").close,
          },
          n = {
            ["q"] = require("telescope.actions").close,
          },
        },
      },

      pickers = {
        find_files = {
          hidden    = true,  -- show dotfiles
          no_ignore = false, -- still respect .gitignore
        },
        git_files = {
          show_untracked = true,
        },
      },
    })

    local builtin = require("telescope.builtin")
    local opts = { noremap = true, silent = true }
    vim.keymap.set("n", "<M-q>", builtin.find_files, opts)
    vim.keymap.set("n", "<C-p>", builtin.git_files,  opts)
    vim.keymap.set("n", "<M-e>", builtin.live_grep,  opts)
    vim.keymap.set("n", "<leader>pWs", function()
      builtin.grep_string({ search = vim.fn.expand("<cWORD>") })
    end, opts)
    vim.keymap.set("n", "<leader>ps", function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end, opts)
    vim.keymap.set("n", "<leader>vh", builtin.help_tags, opts)
  end,
}
