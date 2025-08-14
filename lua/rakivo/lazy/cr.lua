return {
  {
    'tpope/vim-dispatch',
    -- only load when you first hit Dispatch/Make/Focus/Start
    cmd = { 'Dispatch', 'Make', 'Focus', 'Start' },
    config = function()
      -- ──────────────────────────────────────────────────────────────
      -- 1) Dispatch window height = half of your total lines
      -- ──────────────────────────────────────────────────────────────
      -- vim.o.lines is total lines including statusline & cmdline,
      -- so floor it for half your code-window height.
      vim.g.dispatch_quickfix_height = math.floor(vim.o.lines / 2)

      -- ──────────────────────────────────────────────────────────────
      -- 2) Keymaps: M-x, M-r, C-o
      -- ──────────────────────────────────────────────────────────────
      local map = vim.keymap.set
      -- M-x: start ":Dispatch " and leave you typing
      map('n', '<M-x>', ':Dispatch ', { silent = false, desc = 'Dispatch prompt' })
      -- M-r: repeat last Dispatch (with bang)
      map('n', '<M-r>', '<Cmd>Dispatch!<CR>', { desc = 'Dispatch (repeat)' })
      -- C-o: open the QuickFix window
      map('n', '<C-o>', '<Cmd>copen<CR>', { desc = 'Open QuickFix' })

      -- ──────────────────────────────────────────────────────────────
      -- 3) Color your QF window (errors, warnings, current line)
      -- ──────────────────────────────────────────────────────────────
      vim.cmd([[
        augroup DispatchQFColors
          autocmd!
          " highlight the current QF line
          autocmd FileType qf highlight QuickFixLine guibg=#2e2e2e guifg=#ffffff
          " error messages in red
          autocmd FileType qf highlight ErrorMsg      guifg=#ff5555 gui=bold
          " warnings in yellow
          autocmd FileType qf highlight WarningMsg    guifg=#ffcc00 gui=bold
        augroup END
      ]])
    end,
  }
}
