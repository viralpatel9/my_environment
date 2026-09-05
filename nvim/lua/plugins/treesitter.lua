-- --------------------------------------------------------- treesitter.lua --
-- Real syntax trees: accurate highlighting, folding, indentation, and the
-- af/if/ac/ic text objects that make refactoring C++ pleasant.

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall", "TSInstallInfo" },
    dependencies = {
      -- Must track the same branch as nvim-treesitter above: the `main`
      -- branches of both use a new API that ignores the `textobjects = {…}`
      -- block below, which silently costs you af/if/ac/ic and ]] / [[.
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    opts = {
      ensure_installed = {
        "c", "cpp", "cuda", "cmake", "make", "ninja",
        "lua", "vim", "vimdoc", "query", "luadoc",
        "bash", "python", "json", "jsonc", "yaml", "toml",
        "markdown", "markdown_inline", "regex", "diff", "gitcommit", "gitignore",
        "printf", "doxygen", "comment",
      },
      auto_install = true,
      sync_install = false,

      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        -- Treesitter is slow on very large generated files.
        disable = function(_, buf)
          local max = 512 * 1024
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          return ok and stats and stats.size > max
        end,
      },

      indent = { enable = true, disable = { "python" } },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",    -- start selecting the node
          node_incremental = "<C-space>",  -- grow to the parent node
          node_decremental = "<BS>",       -- shrink back
          scope_incremental = false,
        },
      },

      textobjects = {
        select = {
          enable = true,
          lookahead = true,   -- jump forward to the next one if not inside
          keymaps = {
            ["af"] = "@function.outer",   ["if"] = "@function.inner",
            ["ac"] = "@class.outer",      ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",  ["ia"] = "@parameter.inner",
            ["ai"] = "@conditional.outer",["ii"] = "@conditional.inner",
            ["al"] = "@loop.outer",       ["il"] = "@loop.inner",
            ["ab"] = "@block.outer",      ["ib"] = "@block.inner",
            ["a/"] = "@comment.outer",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          -- ]c / [c are deliberately left to gitsigns for hunk navigation.
          goto_next_start     = { ["]]"] = "@function.outer", ["]k"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end       = { ["]["] = "@function.outer", ["]K"] = "@class.outer" },
          goto_previous_start = { ["[["] = "@function.outer", ["[k"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end   = { ["[]"] = "@function.outer", ["[K"] = "@class.outer" },
        },
        swap = {
          enable = true,
          -- Reorder function arguments without touching the commas.
          swap_next     = { ["<leader>na"] = "@parameter.inner" },
          swap_previous = { ["<leader>pa"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- ================================== keep the enclosing scope on screen ==
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<leader>ok", "<cmd>TSContextToggle<CR>", desc = "Toggle sticky context" },
    },
    opts = { max_lines = 3, multiline_threshold = 1, trim_scope = "outer", mode = "cursor" },
  },

  -- ============================================ %-jump across #if/#endif ==
  {
    "andymass/vim-matchup",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
      vim.g.matchup_matchparen_deferred = 1
    end,
  },
}
