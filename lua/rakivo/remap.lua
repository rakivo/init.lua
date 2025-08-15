vim.g.mapleader = " "
vim.keymap.set("n", "<leader>J", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<leader>r", function()
    -- when rename opens the prompt, this autocommand will trigger
    -- it will "press" CTRL-F to enter the command-line window `:h cmdwin`
    -- in this window I can use normal mode keybindings
    local cmdId
    cmdId = vim.api.nvim_create_autocmd({ "CmdlineEnter" }, {
        callback = function()
          local key = vim.api.nvim_replace_termcodes("<C-f>", true, false, true)
          vim.api.nvim_feedkeys(key, "c", false)
          vim.api.nvim_feedkeys("0", "n", false)
          -- autocmd was triggered and so we can remove the ID and return true to delete the autocmd
          cmdId = nil
          return true
        end,
      })
    vim.lsp.buf.rename()
    -- if LPS couldn't trigger rename on the symbol, clear the autocmd
    vim.defer_fn(function()
        -- the cmdId is not nil only if the LSP failed to rename
        if cmdId then
          vim.api.nvim_del_autocmd(cmdId)
        end
      end, 500)
  end)

-- Function to format the visually selected block
local function indent_region()
    if vim.fn.mode() == "v" then
        local _, csrow, cscol, _ = unpack(vim.fn.getpos("'<"))
        local _, cerow, cecol, _ = unpack(vim.fn.getpos("'>"))
        vim.lsp.buf.range_formatting({}, {csrow - 1, cscol}, {cerow - 1, cecol})
    else
        vim.notify("No visual selection found.", vim.log.levels.WARN)
    end
end

local wk = vim.api.nvim_create_autocmd

-- 1) Your global mappings
local global_opts = { noremap = true, silent = true }

-- C-x 2 → split horizontally
vim.keymap.set({ "n", "i", "v" }, "<C-x>2", ":split<CR>", global_opts)

-- C-x 3 → split vertically
vim.keymap.set({ "n", "i", "v" }, "<C-x>3", ":vsplit<CR>", global_opts)

-- C-x 1 → close all other splits (keep current)
vim.keymap.set({ "n", "i", "v" }, "<C-x>1", "<Cmd>only<CR>", global_opts)

-- C-x 0 → close current split
vim.keymap.set({ "n", "i", "v" }, "<C-x>0", "<Cmd>close<CR>", global_opts)

vim.keymap.set({ "n", "i", "v" }, "<C-x>J", "<Cmd>Ex <CR>", global_opts)
--
-- Alt+2 → cycle to next window
vim.keymap.set({ "n", "i", "v" }, "<M-2>", "<Cmd>wincmd w<CR>", global_opts)

wk("FileType", {
  pattern = { "qf", "netrw" },
  callback = function(args)
    local buf_opts = vim.tbl_extend("force", global_opts, { buffer = args.buf })
    vim.keymap.set({ "n", "i", "v" }, "<C-x>1", "<Cmd>only<CR>", buf_opts)
    vim.keymap.set({ "n", "i", "v" }, "<C-x>0", "<Cmd>close<CR>", buf_opts)
    vim.keymap.set({ "n", "i", "v" }, "<C-x>J", "<Cmd>Ex<CR>",    buf_opts)
    vim.keymap.set({ "n", "i", "v" }, "<M-2>",     "<Cmd>wincmd w<CR>", buf_opts)
  end
})

-- Normal‑mode window navigation
vim.keymap.set("n", "<C-x>h", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-x>j", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-x>k", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-x>l", "<C-w>l", { noremap = true, silent = true })

-- Terminal‑mode window navigation
vim.keymap.set("t", "<C-x>h", "<C-\\><C-n><C-w>h", { noremap = true, silent = true })
vim.keymap.set("t", "<C-x>j", "<C-\\><C-n><C-w>j", { noremap = true, silent = true })
vim.keymap.set("t", "<C-x>k", "<C-\\><C-n><C-w>k", { noremap = true, silent = true })
vim.keymap.set("t", "<C-x>l", "<C-\\><C-n><C-w>l", { noremap = true, silent = true })

-- Map <Leader>i to indent the visually selected block
vim.keymap.set("v", "<Leader>i", indent_region, { noremap = true, silent = true })

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = { "make*", "grep*" },
  callback = function()
    -- Open Quickfix at bottom using half of the current screen height
    local height = math.floor(vim.o.lines / 2) - 2
    vim.cmd(height .. "copen")
    vim.cmd("wincmd J")  -- move QF window to the bottom just in case
  end,
})

vim.cmd([[
  cnoreabbrev <expr> make v:cmdbang ? 'make' : 'make!'
]])

vim.keymap.set("n", "<M-r>", function()
  -- Find latest :make command from history
  local cmd = nil
  for i = -1, -vim.fn.histnr("cmd"), -1 do
    local entry = vim.fn.histget("cmd", i)
    if entry and entry:match("^make") then
      cmd = entry
      break
    end
  end

  if not cmd then
    vim.notify("No recent :make command found.", vim.log.levels.WARN)
    return
  end

  vim.cmd(cmd)

  -- Open QF window at bottom first (custom height)
  local height = math.floor(vim.o.lines / 2) - 3
  vim.cmd(height .. "copen")
  vim.cmd("wincmd J")
end, { noremap = true, silent = true })

vim.o.quickfixtextfunc = ''

vim.api.nvim_set_keymap('i', '<C-a>', '<C-o>0', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-e>', '<C-o>$', { noremap = true, silent = true })

vim.keymap.set({ "n", "i", "v" }, '<C-b>', '<Left>', { noremap = true, silent = true })
vim.keymap.set({ "n", "i", "v" }, '<C-f>', '<Right>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('i', '<Char-0x08>', '<Left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-l>', '<Right>', { noremap = true, silent = true })

vim.api.nvim_set_keymap('i', '<C-j>', '<Down>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-k>', '<Up>', { noremap = true, silent = true })

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "=ap", "ma=ap'a")
vim.keymap.set("n", "<leader>zig", "<cmd>LspRestart<cr>")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

local function map_bufnav(key, cmd)
  vim.keymap.set("n", key, cmd, { noremap = true, silent = true })
  vim.keymap.set("i", key, "<Esc>" .. cmd .. "gi", { noremap = true, silent = true }) -- preserves insert mode
  vim.keymap.set("v", key, "<Esc>" .. cmd, { noremap = true, silent = true })
  vim.keymap.set("t", key, "<C-\\><C-n>" .. cmd, { noremap = true, silent = true })
end

map_bufnav("<M-1>", ":bprevious<CR>")
map_bufnav("<M-3>", ":bnext<CR>")

vim.keymap.set("v", "y", "y`>", { noremap = true })

vim.keymap.set({"n", "v"}, "<leader>d", "\"_d")

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-o>", "<cmd>copen<CR>zz")
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")

local function add_current_location_to_qf()
    local bufnr = vim.api.nvim_get_current_buf()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local filename = vim.fn.expand('%:p')
    local qf_item = {
        bufnr = bufnr,
        lnum = line,
        col = col + 1, -- Convert 0-based column index to 1-based
        text = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1],
        filename = filename,
    }
    vim.fn.setqflist({}, 'a', { items = { qf_item } })
end

vim.keymap.set("n", "<Leader>l", add_current_location_to_qf, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

vim.keymap.set("i", "<Tab>", "    ", { noremap = true, silent = true })
vim.keymap.set("i", "\t", "    ", { noremap = true, silent = true })

vim.keymap.set(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

vim.keymap.set(
    "n",
    "<leader>ea",
    "oassert.NoError(err, \"\")<Esc>F\";a"
)

vim.keymap.set(
    "n",
    "<leader>ef",
    "oif err != nil {<CR>}<Esc>Olog.Fatalf(\"error: %s\\n\", err.Error())<Esc>jj"
)

vim.keymap.set(
    "n",
    "<leader>el",
    "oif err != nil {<CR>}<Esc>O.logger.Error(\"error\", \"error\", err)<Esc>F.;i"
)

vim.keymap.set("i", "<C-g>", "<Esc>")
vim.keymap.set("c", "<C-g>", "<Esc>")
vim.keymap.set("t", "<C-g>", "<C-\\><C-n>")
vim.keymap.set({ "n", "i", "v" }, "<M-`>", function()
  require("fzf-lua").buffers()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- Emacs like pasting
vim.keymap.set("n", "p", "P", { noremap = true })

vim.keymap.set("n", "<leader>gg", function()
  require("neogit").open()
end, { desc = "Open Neogit" })

-- Bind hop pattern to /
vim.keymap.set('n', '<C-s>', ':HopPattern<CR>', { desc = 'Hop to pattern' })

