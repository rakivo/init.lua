return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- blink.cmp and optional compat layer
    { "Saghen/blink.cmp",              version = "*" },
    { "Saghen/blink.compat",           optional = true },

    -- your existing non-completion plugins
    "stevearc/conform.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "j-hui/fidget.nvim",
  },

  opts = {
    autoformat = false,
  },

  config = function()
    -- Conform
    require("conform").setup({ formatters_by_ft = {} })

    -- Fidget
    require("fidget").setup({})

    -- Mason + LSPconfig bootstrap
    require("mason").setup()
    local mason_lsp = require("mason-lspconfig")
    local lspconfig  = require("lspconfig")

    -- Build LSP capabilities via blink.cmp
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      require("blink.cmp").get_lsp_capabilities()
    )

    local on_attach = function(client, bufnr)
      -- Go auto‑format on save via gopls only
      if client.name == "gopls" then
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function() vim.lsp.buf.format({ async = false }) end,
        })
      end
    end

    -- Default LSP setup helper
    local function setup_server(name, opts)
      lspconfig[name].setup(vim.tbl_deep_extend("force", {
        capabilities = capabilities,
        on_attach    = on_attach,
      }, opts or {}))
    end

    -- Rust‑analyzer tweak
    setup_server("rust-analyzer", { settings = { ["rust-analyzer"] = { checkOnSave = { enable = false } } } })

    -- Per‑server customizations
    for _, srv in ipairs(mason_lsp.get_installed_servers()) do
      if srv == "zls" then
        setup_server("zls", {
          root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
          settings = { zls = { enable_inlay_hints = true, enable_snippets = true, warn_style = true } },
        })
        vim.g.zig_fmt_parse_errors = 0
        vim.g.zig_fmt_autosave      = 0

      elseif srv ~= "rust-analyzer" then
        setup_server(srv)
      end
    end

    -- -----------------------------------------------------------------------
    -- blink.cmp setup
    -- -----------------------------------------------------------------------
    local blink = require("blink.cmp")
    blink.setup({
      -- which completion sources to enable
      sources = {
        default  = { "lsp", "path", "buffer" },
      },

      -- keymaps for navigation & confirmation
      keymap = {
        preset = "none",          -- disable all defaults
        ["<C-n>"] = { "insert_next" },
        ["<C-p>"] = { "insert_prev" },
        ["<M-Tab>"] = { "accept" },
        ["<Esc>"] = { "hide", "fallback" },
      },

      completion = {
        menu = {
          enabled = false,
        },
        ghost_text = {
          enabled            = true,
          show_with_selection    = true,  -- still show when you’ve moved in the menu
          show_without_selection = true, -- don’t ghost‑text the first item automatically
          show_with_menu         = true, -- since there is no menu, we turn this off
          show_without_menu      = true,  -- crucial: show ghost text when menu is closed
        },
        trigger = {
         -- disable the normal “on keyword” (alphanumeric) trigger
         show_on_keyword                     = false,
         -- allow “trigger characters” (LSP‐defined *plus* your “.”)
         show_on_trigger_character           = true,
         -- ensure that typing a trigger char in insert mode pops it open
         show_on_insert_on_trigger_character = true,
         -- don’t auto‑retrigger after accepting on a trigger char
         show_on_accept_on_trigger_character = false,
        },
      }
    })
    -- -----------------------------------------------------------------------

    -- Diagnostics display
    vim.diagnostic.config({
      virtual_text = false,
      signs        = false,
      underline    = true,
      float = {
        focusable = false,
        style     = "minimal",
        border    = "rounded",
        source    = "always",
        header    = "",
        prefix    = "",
      },
    })
  end,
}
