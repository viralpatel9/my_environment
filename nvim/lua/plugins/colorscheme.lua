-- ------------------------------------------------------- colorscheme.lua --
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000, -- must load before anything that reads highlight groups
    opts = {
      flavour = "mocha", -- latte / frappe / macchiato / mocha
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = { enabled = true, shade = "dark", percentage = 0.10 },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        keywords = { "bold" },
        functions = { "bold" },
        types = { "italic" },
      },
      integrations = {
        cmp = true,
        blink_cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        telescope = { enabled = true },
        which_key = true,
        indent_blankline = { enabled = true, colored_indent_levels = false },
        mason = true,
        dap = true,
        dap_ui = true,
        lsp_trouble = true,
        illuminate = { enabled = true },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
          },
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
          },
          inlay_hints = { background = true },
        },
      },
      custom_highlights = function(c)
        return {
          -- Make the C/C++ story read well: types and namespaces stand apart.
          ["@type.builtin.c"]     = { fg = c.yellow, style = { "italic" } },
          ["@type.builtin.cpp"]   = { fg = c.yellow, style = { "italic" } },
          ["@lsp.type.namespace"] = { fg = c.peach },
          ["@lsp.type.class"]     = { fg = c.yellow },
          ["@lsp.type.macro"]     = { fg = c.red, style = { "bold" } },
          ["@keyword.directive"]  = { fg = c.pink },
          -- Softer, less shouty UI chrome.
          CursorLine   = { bg = c.mantle },
          ColorColumn  = { bg = c.mantle },
          WinSeparator = { fg = c.surface1 },
          FloatBorder  = { fg = c.blue, bg = c.base },
          NormalFloat  = { bg = c.base },
        }
      end,
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
