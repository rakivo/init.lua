require("rakivo")
vim.opt.clipboard:append("unnamedplus")
vim.opt.colorcolumn = "0"

vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_floating_blur_amount_x = 0
vim.g.neovide_floating_blur_amount_y = 0
vim.g.neovide_opacity = 1
vim.g.neovide_no_idle = true
vim.g.neovide_refresh_rate = 144
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_scroll_animation_length = 0
vim.o.guifont = "Consolas:h14"

vim.api.nvim_set_hl(0, "BlinkCmpGhostText", { fg = "#7f89a3", bg = "NONE", italic = true })
