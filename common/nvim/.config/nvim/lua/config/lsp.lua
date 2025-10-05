-- ~/.config/nvim/lua/config/lsp.lua
return {
  servers = {
    phpactor = {
      init_options = {
        ["language_server_phpstan.enabled"] = false,
        ["language_server_psalm.enabled"] = false,
      },
      -- Optional: only needed if you want to add custom on_attach logic
      on_attach = function(client, bufnr)
        -- Example: custom mapping for code actions
        local map = function(mode, lhs, rhs)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
        end
        map("n", "<leader>ca", vim.lsp.buf.code_action)
      end,
    },
  },
}
