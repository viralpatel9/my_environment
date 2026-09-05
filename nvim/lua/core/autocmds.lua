-- ----------------------------------------------------------- autocmds.lua --
local function augroup(name)
  return vim.api.nvim_create_augroup("my_env_" .. name, { clear = true })
end
local au = vim.api.nvim_create_autocmd

-- Flash the yanked region so you can see what was copied.
au("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function() vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 }) end,
})

-- Reopen a file exactly where you left it.
au("BufReadPost", {
  group = augroup("last_position"),
  callback = function(ev)
    if vim.b[ev.buf].my_env_restored then return end
    vim.b[ev.buf].my_env_restored = true
    local exclude = { "gitcommit", "gitrebase", "commit", "svn" }
    if vim.tbl_contains(exclude, vim.bo[ev.buf].filetype) then return end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lines = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.cmd("normal! zz")
    end
  end,
})

-- Strip trailing whitespace on save, but leave markdown (2 spaces = <br>).
au("BufWritePre", {
  group = augroup("trim_whitespace"),
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "markdown" then return end
    if not vim.bo[ev.buf].modifiable then return end
    local view = vim.fn.winsaveview()
    vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Create missing parent directories when writing a new file.
au("BufWritePre", {
  group = augroup("mkdir_on_save"),
  callback = function(ev)
    if ev.match:match("^%w%w+://") then return end
    local dir = vim.fn.fnamemodify(vim.uv.fs_realpath(ev.match) or ev.match, ":p:h")
    if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
  end,
})

-- Reload files changed outside Neovim.
au({ "FocusGained", "TermClose", "TermLeave", "BufEnter" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then vim.cmd("checktime") end
  end,
})

-- Resize splits when the terminal window changes size.
au("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- `q` closes throwaway windows.
au("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "man", "qf", "lspinfo", "checkhealth", "startuptime",
              "netrw", "notify", "query", "spectre_panel", "neotest-output" },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true, desc = "Close window" })
  end,
})

-- Cursorline only in the focused window.
local cl = augroup("cursorline")
au({ "WinEnter", "BufWinEnter" }, { group = cl, callback = function() vim.wo.cursorline = true end })
au("WinLeave", { group = cl, callback = function() vim.wo.cursorline = false end })

-- Relative numbers are noise in insert mode and in unfocused windows.
local nm = augroup("numbers")
au({ "InsertEnter", "WinLeave" }, {
  group = nm,
  callback = function() if vim.wo.number then vim.wo.relativenumber = false end end,
})
au({ "InsertLeave", "WinEnter" }, {
  group = nm,
  callback = function() if vim.wo.number then vim.wo.relativenumber = true end end,
})

-- ---------------------------------------------------------------- C/C++ ---
-- Kernel/embedded projects often want tabs; project .editorconfig wins if set.
au("FileType", {
  group = augroup("cpp_indent"),
  pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
  callback = function()
    vim.opt_local.commentstring = "// %s"
    vim.opt_local.cinoptions = "l1,g0,N-s,t0,(0,W4"   -- sane C++ class/namespace indent
    vim.opt_local.matchpairs:append("<:>")            -- % jumps across templates
  end,
})

-- Treat these as C++ rather than falling back to plain text.
vim.filetype.add({
  extension = {
    h = function(_, bufnr)
      -- A .h with C++ constructs is C++, otherwise C.
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 200, false)
      for _, l in ipairs(lines) do
        if l:match("^%s*template%s*<") or l:match("^%s*namespace%s") or l:match("^%s*class%s")
          or l:match("#include%s*<[%a_]+>%s*$") and not l:match("%.h>") then
          return "cpp"
        end
      end
      return "c"
    end,
    tpp = "cpp", ipp = "cpp", ixx = "cpp", cppm = "cpp",
    inl = "cpp", hxx = "cpp", cu = "cuda", cuh = "cuda",
  },
  filename = {
    [".clang-format"] = "yaml",
    [".clang-tidy"] = "yaml",
    ["compile_flags.txt"] = "conf",
  },
})

-- Make the quickfix window read cleanly after :make.
au("QuickFixCmdPost", {
  group = augroup("make_qf"),
  pattern = { "make", "grep", "grepadd", "vimgrep" },
  command = "cwindow",
})
