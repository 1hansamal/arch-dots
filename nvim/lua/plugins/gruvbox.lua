return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- load before other plugins, since it's a colorscheme
    config = function()
      require("gruvbox").setup({
        contrast = "hard", -- "hard", "soft" or "" (default/medium)
      })
      vim.o.background = "dark"
      vim.cmd("colorscheme gruvbox")
    end,
  },
}