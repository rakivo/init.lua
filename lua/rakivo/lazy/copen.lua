return {
    {
        "kevinhwang91/nvim-bqf",
        config = function()
            require("bqf").setup({
                auto_enable = true,
            })
        end
    },

    { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
}
