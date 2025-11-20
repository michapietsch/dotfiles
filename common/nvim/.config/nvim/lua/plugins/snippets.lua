return {
  -- Disable friendly-snippets entirely
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  },

  {
    "L3MON4D3/LuaSnip",
    config = function()
      local vscode_loader = require("luasnip.loaders.from_vscode")

      -- ❌ Do NOT load friendly-snippets
      -- ❌ Do NOT load the default VSCode snippets
      -- vscode_loader.lazy_load()    <-- remove or comment out

      -- ✔️ Only load your personal snippets
      vscode_loader.lazy_load({
        paths = { vim.fn.stdpath("config") .. "/snippets" },
      })
    end,
  },
}
