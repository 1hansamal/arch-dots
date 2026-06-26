-- ~/.config/nvim/lua/plugins/nvim-tree.lua
return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- file icons
    },
    config = function()
      require("nvim-tree").setup({
        view = {
          side = "left",
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = false,
        },
      })
    end,
  },
}