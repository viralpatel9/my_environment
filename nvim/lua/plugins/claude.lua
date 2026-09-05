-- -------------------------------------------------------------- claude.lua --
-- Claude Code inside Neovim, in a right-hand split — the same integration the
-- VS Code/Cursor extension uses (this plugin reimplements that protocol in
-- pure Lua), so file/selection context and diffs flow the same way.
--
-- Requires the `claude` CLI on your PATH. If you installed it via
-- `claude migrate-installer` instead of npm, set terminal_cmd below to
-- `~/.claude/local/claude` (or whatever `which claude` reports).

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel",
      "ClaudeCodeAdd", "ClaudeCodeSend", "ClaudeCodeTreeAdd",
      "ClaudeCodeStatus", "ClaudeCodeStart", "ClaudeCodeStop",
      "ClaudeCodeOpen", "ClaudeCodeClose",
      "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny", "ClaudeCodeCloseAllDiffs",
    },
    opts = {
      terminal_cmd = nil, -- nil = "claude" on PATH; see note above if you need a custom path
      terminal = {
        split_side = "right",
        split_width_percentage = 0.35,
        provider = "auto", -- uses snacks.nvim if present, falls back to a native split
      },
      diff_opts = { layout = "vertical" },
      track_selection = true, -- Claude sees your current file + visual selection
    },
    keys = {
      { "<leader>a", nil, desc = "claude" },
      { "<leader>ac", "<cmd>ClaudeCode<CR>", desc = "Toggle Claude (right split)" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<CR>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<CR>", desc = "Resume last session" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<CR>", desc = "Continue last session" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", desc = "Select model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", desc = "Add current buffer to context" },
      { "<leader>as", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<CR>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<CR>", desc = "Reject diff" },
    },
  },

  -- Small UI toolkit claudecode.nvim uses for its terminal split and pickers.
  { "folke/snacks.nvim", lazy = true, opts = {} },
}
