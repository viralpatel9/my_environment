-- ------------------------------------------------------------ keymaps.lua --
-- Non-plugin mappings. Plugin-specific keys live next to their spec in
-- lua/plugins/, and every group prefix is described in plugins/which-key.lua.
--
-- Leader = <Space>.   Press <Space>? for the full cheatsheet.

local function map(mode, lhs, rhs, desc, opts)
  opts = vim.tbl_extend("force", { silent = true, noremap = true, desc = desc }, opts or {})
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- ============================================================ essentials ===
map("i", "jk", "<Esc>", "Escape insert mode")
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")
map("n", "<leader>w", "<cmd>write<CR>", "Write file")
map("n", "<leader>W", "<cmd>wall<CR>", "Write all files")
map("n", "<leader>q", "<cmd>confirm quit<CR>", "Quit window")
map("n", "<leader>Q", "<cmd>confirm qall<CR>", "Quit all")
map("n", "<leader>x", "<cmd>bdelete<CR>", "Close buffer")

-- ============================================================ navigation ===
-- Move by screen line when a line is wrapped, unless a count was given.
map({ "n", "x" }, "j", function() return vim.v.count > 0 and "j" or "gj" end, "Down", { expr = true })
map({ "n", "x" }, "k", function() return vim.v.count > 0 and "k" or "gk" end, "Up", { expr = true })

-- Keep the cursor centred while scrolling and searching.
map("n", "<C-d>", "<C-d>zz", "Half page down")
map("n", "<C-u>", "<C-u>zz", "Half page up")
map("n", "n", "nzzzv", "Next match (centred)")
map("n", "N", "Nzzzv", "Prev match (centred)")
map("n", "*", "*zz", "Search word under cursor")
map("n", "G", "Gzz", "End of file")

-- Line start/end without stretching for ^ and $.
map({ "n", "x", "o" }, "H", "^", "First non-blank char")
map({ "n", "x", "o" }, "L", "g_", "Last non-blank char")

-- ============================================================== windows ===
map("n", "<C-h>", "<C-w>h", "Window left")
map("n", "<C-j>", "<C-w>j", "Window down")
map("n", "<C-k>", "<C-w>k", "Window up")
map("n", "<C-l>", "<C-w>l", "Window right")

map("n", "<C-Up>",    "<cmd>resize +2<CR>", "Taller")
map("n", "<C-Down>",  "<cmd>resize -2<CR>", "Shorter")
map("n", "<C-Left>",  "<cmd>vertical resize -4<CR>", "Narrower")
map("n", "<C-Right>", "<cmd>vertical resize +4<CR>", "Wider")

map("n", "<leader>sv", "<C-w>v", "Split vertical")
map("n", "<leader>sh", "<C-w>s", "Split horizontal")
map("n", "<leader>se", "<C-w>=", "Equalise splits")
map("n", "<leader>sx", "<cmd>close<CR>", "Close split")
map("n", "<leader>so", "<cmd>only<CR>", "Close other splits")

-- ============================================================== buffers ===
map("n", "<S-l>", "<cmd>bnext<CR>", "Next buffer")
map("n", "<S-h>", "<cmd>bprevious<CR>", "Previous buffer")
map("n", "<leader>bb", "<cmd>buffer #<CR>", "Last used buffer")
map("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")
map("n", "<leader>bo", function()          -- close every buffer but this one
  local cur = vim.api.nvim_get_current_buf()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= cur and vim.bo[b].buflisted and not vim.bo[b].modified then
      vim.api.nvim_buf_delete(b, {})
    end
  end
end, "Close other buffers")

-- ================================================================= tabs ===
map("n", "<leader><Tab>n", "<cmd>tabnew<CR>", "New tab")
map("n", "<leader><Tab>x", "<cmd>tabclose<CR>", "Close tab")
map("n", "<leader><Tab>]", "<cmd>tabnext<CR>", "Next tab")
map("n", "<leader><Tab>[", "<cmd>tabprevious<CR>", "Previous tab")

-- ============================================================== editing ===
-- Move the selection up/down, re-indenting as it goes.
map("x", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("x", "K", ":m '<-2<CR>gv=gv", "Move selection up")
map("n", "<A-j>", "<cmd>m .+1<CR>==", "Move line down")
map("n", "<A-k>", "<cmd>m .-2<CR>==", "Move line up")

map("x", "<", "<gv", "Outdent, keep selection")
map("x", ">", ">gv", "Indent, keep selection")

-- Paste over a selection without losing the yank register.
map("x", "p", [["_dP]], "Paste without clobbering register")
map({ "n", "x" }, "<leader>d", [["_d]], "Delete to black hole")
map({ "n", "x" }, "<leader>y", [["+y]], "Yank to system clipboard")
map("n", "<leader>Y", [["+Y]], "Yank line to system clipboard")

-- Undo break-points: these characters start a new undo chunk.
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", ";", ";<C-g>u")

map("n", "J", "mzJ`z", "Join lines, keep cursor")
map("n", "<leader>a", "ggVG", "Select whole file")

-- Substitute the word under the cursor everywhere.
map("n", "<leader>sr", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]],
    "Replace word under cursor", { silent = false })

-- ================================================================ quick ===
map("n", "<leader>ol", "<cmd>set list!<CR>", "Toggle whitespace chars")
map("n", "<leader>ow", "<cmd>set wrap!<CR>", "Toggle wrap")
map("n", "<leader>os", "<cmd>set spell!<CR>", "Toggle spellcheck")
map("n", "<leader>on", "<cmd>set relativenumber!<CR>", "Toggle relative numbers")
map("n", "<leader>od", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, "Toggle diagnostics")

-- ========================================================== quickfix ======
map("n", "<leader>co", "<cmd>copen<CR>", "Open quickfix")
map("n", "<leader>cc", "<cmd>cclose<CR>", "Close quickfix")
map("n", "]q", "<cmd>cnext<CR>zz", "Next quickfix item")
map("n", "[q", "<cmd>cprevious<CR>zz", "Prev quickfix item")
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
map("n", "<leader>e", vim.diagnostic.open_float, "Show diagnostic under cursor")

-- ============================================================ terminal ====
map("t", "<Esc><Esc>", [[<C-\><C-n>]], "Leave terminal mode")
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], "Window left")
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], "Window down")
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], "Window up")
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], "Window right")

-- ================================================================ C/C++ ===
-- Alternate between header and source (uses LSP when clangd is attached,
-- otherwise falls back to a filename guess).
map("n", "<leader>ch", function()
  local ok = pcall(vim.cmd, "ClangdSwitchSourceHeader")
  if ok then return end
  local file = vim.fn.expand("%:p")
  local stem, ext = file:match("^(.*)%.([^.]+)$")
  if not stem then return end
  local candidates = ({
    c = { "h" }, cc = { "h", "hpp" }, cpp = { "h", "hpp", "hh" }, cxx = { "h", "hpp" },
    h = { "c", "cpp", "cc", "cxx" }, hpp = { "cpp", "cc", "cxx" }, hh = { "cc", "cpp" },
  })[ext] or {}
  for _, alt in ipairs(candidates) do
    local target = stem .. "." .. alt
    if vim.uv.fs_stat(target) then
      vim.cmd.edit(target)
      return
    end
  end
  vim.notify("No matching header/source for " .. vim.fn.expand("%:t"), vim.log.levels.WARN)
end, "Switch header/source")

map("n", "<leader>cm", "<cmd>make<CR>", "Run :make")

-- =============================================================== files ====
map("n", "<leader>fy", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Copied path" })
end, "Yank file path")

map("n", "<leader>fX", "<cmd>!chmod +x %<CR>", "Make file executable")
