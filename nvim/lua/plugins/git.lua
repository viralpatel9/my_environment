-- ----------------------------------------------------------------- git.lua --
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = (function()
        local g = require("core.icons").git
        return {
          add          = { text = g.add },
          change       = { text = g.change },
          delete       = { text = g.delete },
          topdelete    = { text = g.top },
          changedelete = { text = g.change },
          untracked    = { text = g.add },
        }
      end)(),
      current_line_blame = false,
      current_line_blame_opts = { delay = 400, virt_text_pos = "eol" },
      current_line_blame_formatter = "  <author>, <author_time:%R> · <summary>",
      preview_config = { border = "rounded" },

      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc, extra)
          local o = { buffer = bufnr, silent = true, desc = "Git: " .. desc }
          vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", o, extra or {}))
        end

        -- Hunk navigation. These return a string, so they must be expr maps;
        -- inside a real diff view they fall through to vim's own ]c / [c.
        map("n", "]c", function()
          if vim.wo.diff then return "]c" end
          vim.schedule(function() gs.nav_hunk("next") end)
          return "<Ignore>"
        end, "Next hunk", { expr = true })

        map("n", "[c", function()
          if vim.wo.diff then return "[c" end
          vim.schedule(function() gs.nav_hunk("prev") end)
          return "<Ignore>"
        end, "Previous hunk", { expr = true })

        map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Stage selection")
        map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Reset selection")
        map("n", "<leader>gS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>gR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
        map("n", "<leader>gd", gs.diffthis, "Diff against index")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff against last commit")
        map({ "o", "x" }, "ih", gs.select_hunk, "Select hunk (text object)")
      end,
    },
  },

  -- Full git UI. Only mapped if lazygit is actually installed.
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    cond = function() return vim.fn.executable("lazygit") == 1 end,
    keys = { { "<leader>gg", "<cmd>LazyGit<CR>", desc = "LazyGit" } },
  },

  -- Side-by-side diffs and file history for the whole repo.
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gv", "<cmd>DiffviewOpen<CR>", desc = "Diffview (working tree)" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "Repo history" },
    },
    opts = { enhanced_diff_hl = true },
  },
}
