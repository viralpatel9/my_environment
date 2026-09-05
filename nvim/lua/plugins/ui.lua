-- ------------------------------------------------------------------ ui.lua --
-- Statusline, bufferline, dashboard, indent guides, notifications.
-- All of the icons below need a Nerd Font in your terminal.

return {
  -- ============================================================== icons ===
  { "nvim-tree/nvim-web-devicons", lazy = true, opts = {} },

  -- ========================================================= statusline ===
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      -- Show which LSP servers are attached — quick confirmation clangd is up.
      local function lsp_status()
        local names = {}
        for _, client in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
          names[#names + 1] = client.name
        end
        if #names == 0 then return "" end
        return "  " .. table.concat(names, " ")
      end

      -- Current function/class from treesitter, so you always know where you are.
      local function context()
        local ok, navic = pcall(require, "nvim-navic")
        if ok and navic.is_available() then return navic.get_location({ depth_limit = 3 }) end
        return ""
      end

      local icons = require("core.icons")
      local d = icons.diagnostics

      return {
        options = {
          -- catppuccin ships one lualine theme per flavour (catppuccin-mocha,
          -- catppuccin-latte, …), not a single "catppuccin" theme — must match
          -- the `flavour` set in plugins/colorscheme.lua.
          theme = "catppuccin-mocha",
          globalstatus = true,
          component_separators = { left = "│", right = "│" },
          section_separators = { left = icons.sep.right_solid, right = icons.sep.left_solid },
          disabled_filetypes = { statusline = { "alpha", "dashboard", "NvimTree" } },
        },
        sections = {
          lualine_a = { { "mode", separator = { left = icons.sep.left_solid }, right_padding = 2 } },
          lualine_b = {
            { "branch", icon = icons.sep.branch },
            { "diff" }, -- lualine's own +/~/- symbols
          },
          lualine_c = {
            { "filename", path = 1, symbols = { modified = " ●", readonly = " [RO]", unnamed = "[No Name]" } },
            { context, color = { fg = "#6c7086" } },
          },
          lualine_x = {
            {
              "diagnostics",
              symbols = { error = d.error .. " ", warn = d.warn .. " ",
                          info = d.info .. " ", hint = d.hint .. " " },
            },
            { lsp_status, color = { fg = "#94e2d5" } },
            { "filetype", icon_only = false },
          },
          lualine_y = { { "encoding" }, { "fileformat" }, { "progress" } },
          lualine_z = { { "location", separator = { right = icons.sep.right_solid }, left_padding = 2 } },
        },
        extensions = { "nvim-tree", "quickfix", "toggleterm", "lazy", "trouble", "man" },
      }
    end,
  },

  -- ============================================== breadcrumbs in the bar ===
  {
    "SmiteshP/nvim-navic",
    lazy = true,
    -- Icons are left at the plugin's defaults: it ships a correct Nerd Font
    -- glyph for every LSP symbol kind, which is a long table to get right by
    -- hand and easy to break with a mistyped codepoint.
    opts = {
      separator = " › ",
      highlight = true,
      depth_limit = 4,
    },
  },

  -- ========================================================= bufferline ===
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Pin buffer" },
      { "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Close unpinned" },
    },
    opts = {
      options = {
        mode = "buffers",
        separator_style = "slant",
        always_show_bufferline = false,
        show_buffer_close_icons = true,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local d = require("core.icons").diagnostics
          local s = ""
          if diag.error then s = s .. " " .. d.error .. diag.error end
          if diag.warning then s = s .. " " .. d.warn .. diag.warning end
          return s
        end,
        offsets = {
          { filetype = "NvimTree", text = "Files", highlight = "Directory", separator = true },
        },
        hover = { enabled = true, delay = 150, reveal = { "close" } },
      },
    },
  },

  -- ========================================================== dashboard ===
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        [[                                                    ]],
        [[ ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗ ]],
        [[ ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║ ]],
        [[ ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║ ]],
        [[ ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║ ]],
        [[ ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║ ]],
        [[ ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝ ]],
        [[                                                    ]],
      }

      local fa = require("core.icons").fa
      dashboard.section.buttons.val = {
        dashboard.button("f", fa.search .. "  Find file", "<cmd>Telescope find_files<CR>"),
        dashboard.button("g", fa.search .. "  Grep project", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("r", fa.history .. "  Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("n", fa.file .. "  New file", "<cmd>ene | startinsert<CR>"),
        dashboard.button("e", fa.folder .. "  File tree", "<cmd>NvimTreeToggle<CR>"),
        dashboard.button("?", fa.question .. "  Cheatsheet", "<cmd>Cheatsheet<CR>"),
        dashboard.button("c", fa.gear .. "  Config", "<cmd>edit $MYVIMRC<CR>"),
        dashboard.button("l", fa.rocket .. "  Plugins", "<cmd>Lazy<CR>"),
        dashboard.button("m", fa.wrench .. "  Mason (LSP)", "<cmd>Mason<CR>"),
        dashboard.button("q", fa.power .. "  Quit", "<cmd>qa<CR>"),
      }

      for _, button in ipairs(dashboard.section.buttons.val) do
        button.opts.hl = "AlphaButtons"
        button.opts.hl_shortcut = "AlphaShortcut"
      end
      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.opts.layout[1].val = 6

      alpha.setup(dashboard.opts)

      -- Footer: plugin count + startup time. `VeryLazy` is fired by lazy.nvim
      -- itself once startup finishes, which is when stats() has a startuptime.
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          local stats = require("lazy").stats()
          dashboard.section.footer.val =
            ("  %d plugins loaded in %.0f ms      <Space>? for the cheatsheet")
              :format(stats.count, stats.startuptime)
          dashboard.section.footer.opts.hl = "Comment"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- ====================================================== indent guides ===
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { "help", "alpha", "dashboard", "NvimTree", "Trouble",
                      "trouble", "lazy", "mason", "notify", "toggleterm", "man" },
      },
    },
  },

  -- ======================================================== better UI ====
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    opts = {}, -- prettier vim.ui.select / vim.ui.input (used by code actions & rename)
  },

  -- ================================== highlight other uses of the symbol ==
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
        delay = 150,
        filetypes_denylist = { "NvimTree", "alpha", "Trouble", "toggleterm" },
      })
    end,
  },

  -- ============================================= colour codes, inline =====
  {
    "brenoprata10/nvim-highlight-colors",
    event = { "BufReadPost", "BufNewFile" },
    opts = { render = "virtual", virtual_symbol = "󰝤" },
  },

  -- ================================================ LSP progress spinner ==
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = { display = { done_icon = "✓" } },
      notification = { window = { winblend = 0 } },
    },
  },
}
