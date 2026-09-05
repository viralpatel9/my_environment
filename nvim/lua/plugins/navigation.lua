-- --------------------------------------------------------- navigation.lua --
-- Fuzzy finding, the file tree, and 2-character jumps anywhere on screen.

return {
  -- ========================================================== telescope ===
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        -- Native fzf sorter: much faster on big C++ trees. Falls back silently
        -- if `make` is unavailable at install time.
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fa", "<cmd>Telescope find_files hidden=true no_ignore=true<CR>", desc = "Find files (all)" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep project" },
      { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Grep word under cursor" },
      { "<leader>fb", "<cmd>Telescope buffers sort_mru=true<CR>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help tags" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<leader>fc", "<cmd>Telescope commands<CR>", desc = "Commands" },
      { "<leader>fm", "<cmd>Telescope marks<CR>", desc = "Marks" },
      { "<leader>fj", "<cmd>Telescope jumplist<CR>", desc = "Jump list" },
      { "<leader>fq", "<cmd>Telescope quickfix<CR>", desc = "Quickfix" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>fS", "<cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Workspace symbols" },
      { "<leader>fi", "<cmd>Telescope lsp_incoming_calls<CR>", desc = "Incoming calls" },
      { "<leader>fo", "<cmd>Telescope lsp_outgoing_calls<CR>", desc = "Outgoing calls" },
      { "<leader>f:", "<cmd>Telescope command_history<CR>", desc = "Command history" },
      { "<leader>f/", "<cmd>Telescope search_history<CR>", desc = "Search history" },
      { "<leader>fR", "<cmd>Telescope resume<CR>", desc = "Resume last picker" },
      { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in buffer" },
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Git commits" },
      { "<leader>gt", "<cmd>Telescope git_status<CR>", desc = "Git status" },
    },
    opts = function()
      local actions = require("telescope.actions")
      return {
        defaults = {
          prompt_prefix = require("core.icons").fa.search .. "  ",
          selection_caret = "▶ ",
          entry_prefix = "  ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_strategy = "horizontal",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
            vertical = { mirror = false },
            width = 0.9,
            height = 0.85,
            preview_cutoff = 100,
          },
          file_ignore_patterns = {
            "^%.git/", "node_modules/", "%.o$", "%.a$", "%.so$", "%.d$",
            "^build/", "^cmake%-build.*/", "%.pdf$", "%.png$", "%.jpg$",
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden", "--glob=!.git/",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
              ["<C-u>"] = actions.preview_scrolling_up,
              ["<C-d>"] = actions.preview_scrolling_down,
              ["<Esc>"] = actions.close,
            },
            n = { ["q"] = actions.close },
          },
        },
        pickers = {
          find_files = { hidden = true, find_command = { "rg", "--files", "--hidden", "--glob=!.git/" } },
          buffers = { mappings = { i = { ["<C-x>"] = actions.delete_buffer } } },
          lsp_document_symbols = { symbol_width = 50 },
        },
        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },

  -- =========================================================== file tree ===
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus", "NvimTreeFindFile" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "File tree" },
      { "<leader>E", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal file in tree" },
      { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "File tree" }, -- familiar from other editors
    },
    opts = {
      sort = { sorter = "case_sensitive" },
      view = { width = 34, preserve_window_proportions = true },
      -- Icon glyphs are left at nvim-tree's defaults, which are already
      -- correct Nerd Font codepoints.
      renderer = {
        group_empty = true,
        highlight_git = true,
        indent_markers = { enable = true },
      },
      filters = { dotfiles = false, custom = { "^\\.git$", "\\.o$", "\\.d$" } },
      git = { enable = true, ignore = false },
      diagnostics = {
        enable = true,
        show_on_dirs = true,
        -- nvim-tree spells this key "warning", not "warn".
        icons = (function()
          local d = require("core.icons").diagnostics
          return { hint = d.hint, info = d.info, warning = d.warn, error = d.error }
        end)(),
      },
      actions = { open_file = { quit_on_open = false, window_picker = { enable = true } } },
      update_focused_file = { enable = true, update_root = false },
    },
  },

  -- ================================================= jump anywhere fast ===
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = { jump_labels = true },  -- f/t/F/T get labels too
        search = { enabled = false },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter search" },
    },
  },

  -- ================================== ]  and [  for everything, uniformly ==
  {
    "echasnovski/mini.bracketed",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      -- ]b buffer  ]q quickfix  ]f file  ]i indent  ]j jump  ]t treesitter…
      comment = { suffix = "" },  -- keep ]c for gitsigns
      diagnostic = { suffix = "" }, -- ]d is already mapped in core/keymaps
    },
  },

  -- ============================================== undo history as a tree ==
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
    keys = { { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Undo tree" } },
    init = function() vim.g.undotree_SetFocusWhenToggle = 1 end,
  },
}
