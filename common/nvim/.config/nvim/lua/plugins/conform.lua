require("conform").setup({
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
  formatters_by_ft = {
    javascript = { "prettier" },
    vue = { "prettier" },
    typescript = { "prettier" },
    json = { "prettier" },
    css = { "prettier" },
    markdown = { "prettier" },
    html = { "prettier" },
  },
})
