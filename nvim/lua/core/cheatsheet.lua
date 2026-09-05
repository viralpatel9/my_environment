-- ---------------------------------------------------------- cheatsheet.lua --
-- A floating, filterable keybinding reference.
--   <leader>?   or  :Cheatsheet          open it
--   /           search inside it,  q / <Esc>  close
--
-- This is hand-written rather than generated from the keymap table so it can
-- group things the way you actually think about them, and include plain Vim
-- motions that were never remapped.

local M = {}

local sections = {
  { "SURVIVAL", {
    { "<Space>",        "leader key — every custom mapping starts here" },
    { "<Space>?",       "this cheatsheet" },
    { "jk",             "leave insert mode (instead of reaching for Esc)" },
    { "<Esc>",          "clear search highlight (normal mode)" },
    { "<Space>w / q",   "write file / quit window" },
    { "<Space>Q",       "quit everything" },
    { ":Lazy",          "plugin manager    :Mason  LSP/tool installer" },
    { ":checkhealth",   "diagnose a broken setup" },
  }},

  { "MOVING AROUND", {
    { "h j k l",        "left down up right" },
    { "w / b / e",      "next word / back a word / end of word" },
    { "W / B / E",      "same, but whitespace-delimited (skips punctuation)" },
    { "0 / H / L / $",  "line start / first non-blank / last non-blank / line end" },
    { "f{c} / t{c}",    "jump to / just before next {c} on the line — ; and , repeat" },
    { "{ / }",          "previous / next blank line (paragraph)" },
    { "% ",             "jump to the matching bracket — also works on <> in C++" },
    { "gg / G",         "top / bottom of file" },
    { "{N}G  or  :{N}", "go to line N" },
    { "{N}j / {N}k",    "N lines down/up — the relative numbers on the left are N" },
    { "<C-d> / <C-u>",  "half page down / up (cursor stays centred)" },
    { "<C-o> / <C-i>",  "jump back / forward through the jump list" },
    { "``",             "back to where you just were" },
    { "s{char}{char}",  "flash: jump anywhere on screen by 2 characters" },
    { "S",              "flash treesitter: jump to any syntax node" },
  }},

  { "SEARCH & REPLACE", {
    { "/ / ?",          "search forward / backward,  n / N to repeat" },
    { "*  / #",         "search the word under the cursor forward / backward" },
    { ":%s/old/new/g",  "replace in file — :%s/old/new/gc to confirm each" },
    { "<Space>sr",      "replace the word under the cursor, file-wide" },
    { "<Space>/",       "fuzzy search inside the current buffer" },
    { "<Space>fg",      "live grep the whole project (ripgrep)" },
    { "gc / gcc",       "toggle comment on a motion / on this line" },
  }},

  { "FILES & BUFFERS", {
    { "<Space>ff",      "find file by name" },
    { "<Space>fg",      "grep across the project" },
    { "<Space>fr",      "recent files" },
    { "<Space>fb",      "open buffers" },
    { "<Space>fs",      "document symbols (functions, classes) in this file" },
    { "<Space>fS",      "symbols across the whole workspace" },
    { "<Space>fk",      "search every keymap" },
    { "<Space>e",       "toggle the file tree      (inside: a=new  d=delete  r=rename)" },
    { "<Space>fy",      "copy the current file's path" },
    { "<S-h> / <S-l>",  "previous / next buffer" },
    { "<Space>bb",      "back to the last buffer" },
    { "<Space>bd / bo", "close this buffer / close all others" },
  }},

  { "WINDOWS & SPLITS", {
    { "<C-h/j/k/l>",    "move between splits (works in the terminal too)" },
    { "<Space>sv / sh", "split vertical / horizontal" },
    { "<Space>sx / so", "close this split / close all other splits" },
    { "<Space>se",      "make all splits equal" },
    { "<C-arrows>",     "resize the current split" },
    { "<Space><Tab>n",  "new tab   — <Space><Tab>] and [ to cycle" },
  }},

  { "EDITING", {
    { "i / a / I / A",  "insert before/after cursor, at line start/end" },
    { "o / O",          "open a line below / above" },
    { "ciw / diw / yiw","change / delete / yank the inner word" },
    { "ci\" ci( ci{",   "change inside quotes / parens / braces" },
    { "ca( da{",        "…the 'a' variants include the delimiters" },
    { "v / V / <C-v>",  "visual char / line / BLOCK — block is for column edits" },
    { "J / K (visual)", "move the selection down / up" },
    { "< / > (visual)", "indent, keeping the selection" },
    { ". ",             "repeat the last change — the most valuable key in vim" },
    { "u / <C-r>",      "undo / redo" },
    { "<Space>y",       "yank to the system clipboard" },
    { "<Space>d",       "delete without touching the yank register" },
    { "ys{motion}{c}",  "surround: ysiw\" wraps the word in quotes" },
    { "cs\"'  /  ds\"",  "change surrounding \" to '  /  delete surrounding \"" },
    { "gcc / gc{motion}","comment this line / a motion" },
  }},

  { "C / C++  ·  LSP", {
    { "K",              "hover: type, signature and docs under the cursor" },
    { "gd / gD",        "go to definition / declaration" },
    { "gi / gr",        "go to implementation / list references" },
    { "gy",             "go to type definition" },
    { "<C-k> (insert)", "signature help while typing arguments" },
    { "<Space>ca",      "code action — fix it, include it, extract it" },
    { "<Space>rn",      "rename the symbol everywhere" },
    { "<Space>cf",      "format buffer (clang-format)" },
    { "<Space>ch",      "switch between header and source" },
    { "<Space>ci",      "toggle inlay hints (parameter names, deduced types)" },
    { "]d / [d",        "next / previous diagnostic" },
    { "<Space>e",       "show the full diagnostic under the cursor" },
    { "<Space>xx",      "Trouble: every diagnostic in the project, in one list" },
    { "<Space>cm",      "run :make and jump to the first error" },
    { "]] / [[",        "next / previous function (treesitter)" },
    { "af / if",        "text object: a function / its body — try  daf, vif" },
    { "ac / ic",        "text object: a class / its body" },
  }},

  { "COMPLETION (insert mode)", {
    { "<C-Space>",      "open the completion menu on demand" },
    { "<Tab> / <S-Tab>","next / previous item, and jump between snippet slots" },
    { "<CR>",           "accept the selected completion" },
    { "<C-e>",          "dismiss the menu" },
    { "<C-b> / <C-f>",  "scroll the documentation window" },
  }},

  { "DEBUGGING (nvim-dap)", {
    { "<F5>",           "start / continue" },
    { "<F10>",          "step over        <F11> step into      <S-F11> step out" },
    { "<Space>db",      "toggle breakpoint" },
    { "<Space>dB",      "conditional breakpoint" },
    { "<Space>du",      "toggle the debugger UI" },
    { "<Space>dr",      "open the REPL     <Space>dt terminate" },
  }},

  { "GIT", {
    { "]c / [c",        "next / previous hunk" },
    { "<Space>gp",      "preview the hunk under the cursor" },
    { "<Space>gs / gr", "stage / reset the hunk" },
    { "<Space>gb",      "blame this line" },
    { "<Space>gd",      "diff this file against the index" },
    { "<Space>gg",      "open lazygit (if installed)" },
  }},

  { "TERMINAL", {
    { "<C-\\>",         "toggle a floating terminal" },
    { "<Esc><Esc>",     "leave terminal mode back to normal mode" },
    { "<Space>tg",      "lazygit    <Space>tp python    <Space>tf floating shell" },
  }},

  { "FOLDS & MARKS", {
    { "za / zR / zM",   "toggle this fold / open all / close all" },
    { "zz / zt / zb",   "centre / top / bottom the cursor line" },
    { "m{a-z} / '{a-z}","set a mark / jump to it (lowercase = this file)" },
    { "m{A-Z} / '{A-Z}","global marks — jump across files" },
  }},
}

-- ---------------------------------------------------------------- render ---
local function build_lines()
  local lines, highlights = {}, {}
  local W = 78

  local function add(text, hl)
    lines[#lines + 1] = text
    if hl then highlights[#highlights + 1] = { line = #lines - 1, group = hl } end
  end

  add("  Neovim cheatsheet — leader is <Space>", "Title")
  add("  " .. string.rep("─", W - 4), "Comment")

  for _, section in ipairs(sections) do
    local title, entries = section[1], section[2]
    add("")
    add("  ▸ " .. title, "Function")
    for _, e in ipairs(entries) do
      local key, desc = e[1], e[2]
      add(string.format("    %-18s %s", key, desc))
    end
  end

  add("")
  add("  " .. string.rep("─", W - 4), "Comment")
  add("  /  search    q or <Esc>  close    <Space>fk  searchable keymap list", "Comment")
  return lines, highlights
end

local ns = vim.api.nvim_create_namespace("my_env_cheatsheet")

function M.open()
  local lines, highlights = build_lines()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  for _, h in ipairs(highlights) do
    vim.api.nvim_buf_set_extmark(buf, ns, h.line, 0, { end_row = h.line + 1, hl_group = h.group })
  end
  -- Colour the key column (the first 18 chars) of every entry line.
  for i, line in ipairs(lines) do
    local key = line:match("^    (%S.-)%s%s")
    if key then
      vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 4, {
        end_col = 4 + #key,
        hl_group = "String",
      })
    end
  end

  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "my_env_cheatsheet"
  vim.bo[buf].bufhidden = "wipe"

  local width = math.min(84, math.floor(vim.o.columns * 0.9))
  local height = math.min(#lines + 1, math.floor(vim.o.lines * 0.85))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = "  cheatsheet ",
    title_pos = "center",
  })

  vim.wo[win].wrap = false
  vim.wo[win].cursorline = true
  vim.wo[win].winhighlight = "Normal:Normal,FloatBorder:FloatBorder"

  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  for _, key in ipairs({ "q", "<Esc>", "<C-c>" }) do
    vim.keymap.set("n", key, close, { buffer = buf, silent = true, nowait = true })
  end
end

vim.api.nvim_create_user_command("Cheatsheet", M.open, { desc = "Keybinding cheatsheet" })
vim.keymap.set("n", "<leader>?", M.open, { desc = "Cheatsheet", silent = true })

return M
