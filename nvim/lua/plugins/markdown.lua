-- ------------------------------------------------------------ markdown.lua --
-- Live browser preview for .md files, with Mermaid, PlantUML and KaTeX math
-- rendered as real diagrams/equations, not code blocks.

return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    -- The plugin's own auto-install (`mkdp#util#install()`) fetches a
    -- prebuilt `pkg`-compiled binary. That binary segfaults on startup on
    -- current glibc (verified on Ubuntu 24.04, glibc 2.39) — a known
    -- incompatibility between old `pkg` snapshot builds and newer glibc, not
    -- something a config option fixes. Building against local Node instead
    -- sidesteps it entirely and is what the plugin falls back to whenever no
    -- working binary is present. Requires Node.js + npm on your machine.
    -- A plain `npm install` here would work, but npm rewrites the tracked
    -- app/yarn.lock (normalizes registry URLs / integrity hashes) even
    -- though nothing here uses yarn — that leaves lazy's git checkout dirty
    -- and blocks every future `:Lazy update` with "local changes, please
    -- remove them". `--no-save` doesn't stop that rewrite; skip-worktree
    -- does, and survives across installs since it's a git flag, not a file
    -- state.
    build = function()
      local dir = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim"
      vim.fn.system({ "git", "-C", dir, "update-index", "--skip-worktree", "app/yarn.lock" })
      vim.fn.system({ "npm", "--prefix", dir .. "/app", "install", "--no-save" })
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_auto_close = true      -- close the browser tab when you leave the buffer
      vim.g.mkdp_refresh_slow = false   -- live-update on every edit, not just on save
      vim.g.mkdp_theme = "dark"
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", ft = "markdown", desc = "Toggle preview (browser)" },
      { "<leader>ms", "<cmd>MarkdownPreviewStop<CR>", ft = "markdown", desc = "Stop preview" },
    },
  },
}
