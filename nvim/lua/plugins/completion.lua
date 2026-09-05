-- ---------------------------------------------------------- completion.lua --
-- blink.cmp: the autocomplete popup. Ships a prebuilt fuzzy-matcher binary and
-- transparently falls back to a pure-Lua matcher if it cannot be downloaded,
-- so a fresh machine with no Rust toolchain still works.

return {
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = (function()
          -- jsregexp powers snippet transforms; it is optional.
          if vim.fn.executable("make") == 1 then return "make install_jsregexp" end
        end)(),
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function() require("luasnip.loaders.from_vscode").lazy_load() end,
          },
        },
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
      },
    },
    opts = {
      snippets = { preset = "luasnip" },

      keymap = {
        preset = "none",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"]     = { "hide", "fallback" },
        ["<CR>"]      = { "accept", "fallback" },
        ["<Tab>"]     = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"]   = { "select_prev", "snippet_backward", "fallback" },
        ["<C-n>"]     = { "select_next", "fallback" },
        ["<C-p>"]     = { "select_prev", "fallback" },
        ["<C-b>"]     = { "scroll_documentation_up", "fallback" },
        ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono", -- matches "… Nerd Font Mono" terminal fonts
        use_nvim_cmp_as_default = false,
      },

      completion = {
        accept = { auto_brackets = { enabled = true } }, -- add () after functions
        menu = {
          border = "rounded",
          winblend = 0,
          draw = {
            treesitter = { "lsp" },
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
              { "source_name" },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 150,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = true },   -- inline preview of the top match
        list = { selection = { preselect = false, auto_insert = true } },
      },

      signature = { enabled = true, window = { border = "rounded" } },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          -- clangd returns thousands of items in a big TU; keep the list snappy.
          lsp = { score_offset = 10 },
          path = { score_offset = 5, opts = { get_cwd = function(_) return vim.fn.getcwd() end } },
          snippets = { score_offset = 2 },
          buffer = { score_offset = -3 },
        },
      },

      -- Rust matcher if the prebuilt binary landed; Lua matcher (with a warning)
      -- if it did not. Never a hard failure.
      fuzzy = { implementation = "prefer_rust_with_warning" },

      cmdline = {
        enabled = true,
        keymap = { preset = "cmdline" },
        completion = { menu = { auto_show = true } },
      },
    },
    opts_extend = { "sources.default" },
  },

  -- ============================================== pairs, surround, comment ==
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,           -- treesitter-aware: no pairs inside strings
      fast_wrap = { map = "<M-e>" },
    },
  },

  {
    "kylechui/nvim-surround",
    event = { "BufReadPost", "BufNewFile" },
    version = "*",
    opts = {},
    -- ysiw" -> wrap word in quotes | cs"' -> change " to ' | ds" -> delete quotes
  },

  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    -- gcc line | gc{motion} | gc in visual mode
  },
}
