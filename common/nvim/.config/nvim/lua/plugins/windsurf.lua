return {
  "Exafunction/windsurf.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  config = function()
    require("codeium").setup({
      enable_cmp_source = false,
      virtual_text = {
        enabled = true,
        manual = false, -- No auto-completions
        key_bindings = {
          accept = "<M-Tab>", -- Disable Tab for full completion
          accept_word = "<S-Tab>", -- Tab accepts next word only
        },
      },
    })

    vim.keymap.set("i", "<C-Space>", function()
      require("codeium.virtual_text").cycle_or_complete()
    end)
  end,
}
