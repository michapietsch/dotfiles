-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_user_command("CopyPath", function(opts)
  local mode = (opts.args ~= "" and opts.args) or "root"
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file in current buffer", vim.log.levels.WARN, { title = "CopyPath" })
    return
  end

  local root = nil
  pcall(function()
    root = require("lazyvim.util").root.get()
  end)

  local text
  if mode == "root" then
    local r = root or vim.loop.cwd()
    text = vim.fn.fnamemodify(file, ":." .. r)
  elseif mode == "cwd" then
    text = vim.fn.fnamemodify(file, ":.")
  elseif mode == "abs" then
    text = file
  elseif mode == "file" then
    text = vim.fn.fnamemodify(file, ":t")
  elseif mode == "dir" then
    text = vim.fn.fnamemodify(file, ":h")
  else
    vim.notify("Unknown mode: " .. mode, vim.log.levels.ERROR, { title = "CopyPath" })
    return
  end

  -- Copy to system clipboard (works with clipboard=unnamedplus; LazyVim sets this by default)
  vim.fn.setreg("+", text)
  pcall(vim.fn.setreg, "*", text) -- best-effort for primary selection on X11
  vim.notify(text, vim.log.levels.INFO, { title = "CopyPath (" .. mode .. ")" })
end, {
  nargs = "?",
  complete = function()
    return { "root", "cwd", "abs", "file", "dir" }
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "html",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
    "php",
    "blade",
    "twig",
  },
  callback = function()
    -- make "-" part of words → "text-sm" is one keyword
    vim.opt_local.iskeyword:append("-")
  end,
})
