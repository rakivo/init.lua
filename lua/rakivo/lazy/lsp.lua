return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        {
          "hrsh7th/cmp-buffer",
          option = {
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end
          }
        },
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        {
          "hrsh7th/nvim-cmp",
          event = "InsertEnter",
        },
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {
            }
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        local on_attach = function(client, bufnr)
          local opts = { noremap=true, silent=true, buffer=bufnr }
          local buf_set_keymap = vim.api.nvim_buf_set_keymap
        end

        require("fidget").setup({})
        require("mason").setup()

        local mason_lspconfig = require("mason-lspconfig")

        local lspconfig = require("lspconfig")

        -- default setup function
        local function default_setup(server)
          lspconfig[server].setup({
            capabilities = capabilities,
            on_attach = on_attach,
          })
        end

        -- Setup all servers with default or custom config
        for _, server in ipairs(mason_lspconfig.get_installed_servers()) do
          if server == "zls" then
            lspconfig.zls.setup({
              root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
              settings = {
                zls = {
                  enable_inlay_hints = true,
                  enable_snippets = true,
                  warn_style = true,
                },
              },
            })
            vim.g.zig_fmt_parse_errors = 0
            vim.g.zig_fmt_autosave = 0
          elseif server == "lua_ls" then
            lspconfig.lua_ls.setup({
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = { version = "Lua 5.1" },
                  diagnostics = {
                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                  },
                },
              },
            })
          else
            default_setup(server)
          end
        end

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            completion = {
                autocomplete = { require("cmp.types").cmp.TriggerEvent.TextChanged }
            },
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ["<M-[>"] = cmp.mapping(function(fallback)
                    if not cmp.visible() then
                        cmp.complete()
                    else
                        cmp.select_prev_item(cmp_select)
                    end
                end, { "i", "c" }),
                ["<M-]>"] = cmp.mapping(function(fallback)
                    if not cmp.visible() then
                        cmp.complete()
                    else
                        cmp.select_next_item(cmp_select)
                    end
                end, { "i", "c" }),
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<M-tab>'] = cmp.mapping.confirm({ select = true }),
                ['<tab>'] = cmp.mapping.confirm({ select = true }),
                -- ["<M-tab>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        local function hide_completion_menu()
            if cmp.visible() then
                cmp.close()
            end
        end

        -- Call the function when leaving insert mode
        vim.api.nvim_create_autocmd("InsertLeave", {
            callback = hide_completion_menu,
        })

        -- Call the function when pressing Esc in insert mode
        vim.keymap.set("i", "<Esc>", "<Esc>:lua require('cmp').close()<CR>", { noremap = true, silent = true })

        vim.diagnostic.config({
            virtual_text = false,
            signs = false,
            underline = true,
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
