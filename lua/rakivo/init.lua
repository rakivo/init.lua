require("rakivo.set")
require("rakivo.remap")
require("rakivo.lazy_init")

require("lazy").setup({
    { import = "rakivo.lazy" },
})

vim.api.nvim_create_user_command("Run", function(opts)
  local cmd = opts.args
  local qf_items = {}

  -- start an async job
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,

    -- collect stdout lines
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if #line > 0 then
            table.insert(qf_items, { filename = "", lnum = 1, col = 1, text = line })
          end
        end
      end
    end,

    -- collect stderr lines
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if #line > 0 then
            table.insert(qf_items, { filename = "", lnum = 1, col = 1, text = line })
          end
        end
      end
    end,

    -- when the process exits, populate Quickfix and open it
    on_exit = function()
      -- set qflist, replacing any existing list
      vim.fn.setqflist({}, "r", {
        title = "Run: " .. cmd,
        items = qf_items,
      })

      -- open Quickfix at the bottom
      vim.cmd("botright copen")
    end,
  })
end, {
  nargs     = "+",
  complete  = "shellcmd",
})

vim.keymap.set("n", "<leader>Q", function()
  vim.cmd("botright copen")  -- open at bottom
  vim.cmd("wincmd _")        -- maximize height
  vim.cmd("wincmd |")        -- maximize width
end, { noremap = true, silent = true })

local augroup = vim.api.nvim_create_augroup
local ThePrimeagenGroup = augroup('ThePrimeagen', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({"BufWritePre"}, {
    group = ThePrimeagenGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

autocmd('LspAttach', {
    group = ThePrimeagenGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("n", "<leader>help", function() vim.lsp.buf.signature_help() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "cpp", "c", "rust" },
  callback = function(args)
    local ft = vim.bo[args.buf].filetype
    if ft == "go" then
      vim.bo.makeprg = "go build"
    elseif ft == "rust" then
      vim.bo.makeprg = "cargo build"
    elseif ft == "cpp" or ft == "c" then
      vim.bo.makeprg = "g++ % -o %< && ./%<"
    end
  end,
})

-- Go-specific settings: use tabs, tab width 2
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.bo.expandtab = false      -- use tabs
    vim.bo.tabstop = 2            -- width of tab character
    vim.bo.shiftwidth = 2         -- indentation width
    vim.bo.softtabstop = 2        -- number of spaces for <Tab>

    vim.keymap.set("i", "<Tab>", function()
      if vim.fn.pumvisible() == 1 then
        return "<C-n>"  -- Keep completion menu navigation
      else
        return "<Tab>"  -- Insert literal tab character
      end
    end, { buffer = true, expr = true })
  end,
})

vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.opt.showtabline = 0
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }
-- vim.cmd.colorscheme("custom")
-- vim.cmd.colorscheme("habamax")
vim.cmd.colorscheme("naysayer")

vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
