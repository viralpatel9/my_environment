-- ============================================================================
--  my_environment — Neovim
--  Leader is <Space>. Press <Space>? for the built-in cheatsheet.
-- ============================================================================

if vim.fn.has("nvim-0.11") == 0 then
  vim.notify(
    "my_environment requires Neovim >= 0.11 (found " .. tostring(vim.version()) .. ").\n"
      .. "Run install.sh again, or set FORCE_NVIM=1 ./install.sh",
    vim.log.levels.ERROR
  )
  return
end

-- Leader must be set before lazy.nvim loads any plugin that defines mappings.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("core.options")
require("core.lazy") -- bootstraps lazy.nvim and loads lua/plugins/*
require("core.keymaps")
require("core.autocmds")
require("core.cheatsheet")
