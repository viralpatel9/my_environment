-- ------------------------------------------------------------ options.lua --
local opt = vim.opt
local icons = require("core.icons")

-- appearance ---------------------------------------------------------------
opt.termguicolors  = true          -- 24-bit colour (needs a modern terminal)
opt.number         = true
opt.relativenumber = true          -- jump N lines with Nj / Nk
opt.cursorline     = true
opt.signcolumn     = "yes:1"       -- never shift text when diagnostics appear
opt.colorcolumn    = "100"
opt.showmode       = false         -- lualine already shows it
opt.cmdheight      = 1
opt.pumheight      = 12            -- completion popup height
opt.pumblend       = 8
opt.winblend       = 0
opt.laststatus     = 3             -- one global statusline
opt.splitbelow     = true
opt.splitright     = true
opt.splitkeep      = "screen"
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.wrap           = false
opt.linebreak      = true          -- if wrap is toggled on, break at words
opt.conceallevel   = 0
opt.fillchars = {
  eob = " ",                       -- no ~ on empty lines
  fold = " ",
  foldopen = icons.fold.open,      -- must be exactly one character each
  foldclose = icons.fold.closed,
  diff = "╱",
}
opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣", extends = "»", precedes = "«" }
opt.list = true

-- editing ------------------------------------------------------------------
opt.expandtab   = true
opt.tabstop     = 4
opt.shiftwidth  = 4
opt.softtabstop = 4
opt.shiftround  = true
opt.smartindent = true
opt.autoindent  = true
opt.cindent     = true             -- C-aware indenting
opt.textwidth   = 0
opt.formatoptions:remove("o")      -- don't continue comments on o/O
opt.formatoptions:append("jcrql")
opt.virtualedit = "block"          -- select past EOL in visual block
opt.completeopt = { "menu", "menuone", "noselect", "popup" }

-- search -------------------------------------------------------------------
opt.ignorecase = true
opt.smartcase  = true              -- ...unless the query has a capital
opt.hlsearch   = true
opt.incsearch  = true
opt.inccommand = "split"           -- live preview of :%s///

-- files & undo -------------------------------------------------------------
opt.undofile   = true
opt.undolevels = 10000
opt.swapfile   = false
opt.backup     = false
opt.writebackup = false
opt.autoread   = true
opt.confirm    = true              -- ask instead of failing on :q with changes
opt.updatetime = 200               -- faster CursorHold => faster LSP hints
opt.timeoutlen = 400               -- which-key popup delay
opt.ttimeoutlen = 10

-- behaviour ----------------------------------------------------------------
opt.mouse       = "a"
opt.clipboard   = "unnamedplus"    -- share the system clipboard
opt.hidden      = true
opt.history     = 1000
opt.wildmode    = "longest:full,full"
opt.wildignorecase = true
opt.wildignore:append({ "*.o", "*.a", "*.so", "*.d", "*.obj", "*/build/*", "*/.git/*" })
opt.path:append("**")              -- :find searches recursively
opt.grepprg = "rg --vimgrep --smart-case --hidden --glob=!.git"
opt.grepformat = "%f:%l:%c:%m"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" }

-- folding (treesitter-driven, everything open on file entry) ----------------
opt.foldmethod     = "expr"
opt.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext       = ""
opt.foldlevel      = 99
opt.foldlevelstart = 99
opt.foldenable     = true

-- diagnostics --------------------------------------------------------------
vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = "●", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = icons.diagnostics.error,
      [vim.diagnostic.severity.WARN]  = icons.diagnostics.warn,
      [vim.diagnostic.severity.INFO]  = icons.diagnostics.info,
      [vim.diagnostic.severity.HINT]  = icons.diagnostics.hint,
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many", header = "", prefix = "" },
})

-- rounded borders everywhere -----------------------------------------------
vim.o.winborder = "rounded"

-- disable unused providers (faster startup, no bogus :checkhealth warnings) --
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_netrwPlugin = 1       -- nvim-tree replaces netrw
vim.g.loaded_netrw = 1
