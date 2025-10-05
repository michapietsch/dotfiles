-- lua/plugins/colorscheme.lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      integrations = {
        treesitter = true,
        lsp_trouble = true,
        cmp = true,
        gitsigns = true,
        telescope = true,
        nvimtree = true,
        notify = true,
        mini = true,
        which_key = true,
      },
    },
  },
}
