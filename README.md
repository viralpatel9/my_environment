# my_environment

A portable Bash + Neovim development environment for C/C++, meant to be dropped
onto any fresh Linux machine and be productive in one command.

```bash
git clone <your-repo-url> ~/git-repo/my_environment
cd ~/git-repo/my_environment
./install.sh
exec bash
```

Then set your terminal font to **JetBrainsMono Nerd Font Mono** and open `nvim`.

---

## What you get

| | |
|---|---|
| **Shell** | Two-line git-aware prompt, 200k-entry shared history, colour everywhere |
| **Suggestions** | Fish-style inline ghost text from your history (ble.sh) + `Ctrl-R` fuzzy search (fzf) |
| **Editor** | Neovim with Catppuccin Mocha, statusline, file tree, dashboard, 48 plugins |
| **C/C++** | clangd IntelliSense: completion, diagnostics, inlay hints, refactors, header↔source |
| **Debugging** | nvim-dap + codelldb, breakpoints and a variable inspector on `<F5>` |
| **Claude Code** | CLI installed by the setup script; `<Space>ac` opens it in a Neovim split, same protocol as the VS Code extension |
| **Markdown preview** | `<Space>mp` opens a live browser preview with Mermaid, KaTeX and sequence diagrams rendered |
| **Cheatsheets** | `envhelp` in the shell, `<Space>?` in Neovim |

---

## Installation

The installer is idempotent — run it as often as you like. It backs up anything
it replaces to `~/.local/share/my_environment/backups/<timestamp>/`.

```bash
./install.sh                 # everything
./install.sh --dry-run       # print what it would do, change nothing
./install.sh --minimal       # skip fonts, extra CLI tools, debugger
./install.sh --no-fonts      # you already have a Nerd Font
./install.sh --no-nvim       # keep your existing Neovim binary
./install.sh --no-claude     # skip the Claude Code CLI
./install.sh --help
```

It detects `apt`, `dnf`, `pacman`, `zypper` and `apk`, and skips gracefully when
a package is unavailable rather than aborting. Nothing but system packages needs
root; everything else lands in `~/.local`.

**What it touches**

- appends one guarded block to `~/.bashrc` (everything else is sourced from this repo)
- symlinks `~/.config/nvim`, `~/.inputrc`, `~/.config/clangd/config.yaml`, `~/.clang-format`
- installs Neovim, Nerd Fonts, ble.sh and optional CLI tools under `~/.local`

**Uninstall**

```bash
./uninstall.sh            # remove hooks and symlinks
./uninstall.sh --purge    # also delete downloaded Neovim, plugins and ble.sh
```

---

## Getting C/C++ IntelliSense working

clangd learns your include paths and flags from a **compile database**. Without
one you get basic completion; with one you get the real thing. In your project:

```bash
cc-db                     # detects CMake or Makefile and does the right thing
```

Under the hood that is:

```bash
# CMake projects
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -sf build/compile_commands.json .

# Makefile projects (needs `bear`)
bear -- make

# a handful of loose files
cc-flags -std=c++20 -Iinclude      # writes compile_flags.txt
```

`~/.config/clangd/config.yaml` supplies sane fallbacks (C++20, `-Wall`, a curated
clang-tidy set) so single files still work before you configure anything, and it
strips GCC-only flags that make clangd choke on kernel-style builds.

Check it attached: the statusline shows the server name on the right, or run
`:LspInfo`. `:Mason` installs clangd if your distro did not.

---

## Layout

```
my_environment/
├── install.sh              # the installer
├── uninstall.sh
├── bin/envhelp             # shell cheatsheet (also on Ctrl-O)
├── bash/
│   ├── bashrc              # entry point, sourced by ~/.bashrc
│   ├── env.sh              # PATH, EDITOR, XDG, toolchain vars
│   ├── colors.sh           # palette, LS_COLORS, man-page colours
│   ├── history.sh          # 200k shared history + helpers
│   ├── options.sh          # shopt/readline behaviour
│   ├── aliases.sh
│   ├── functions.sh        # mkcd, extract, cc-db, ccrun, …
│   ├── prompt.sh           # the git-aware prompt
│   └── integrations.sh     # ble.sh, fzf, zoxide, key bindings
├── config/
│   ├── clangd.yaml         # global clangd defaults
│   ├── clang-format        # global fallback C++ style
│   ├── inputrc             # readline (bash, gdb, python REPL)
│   └── ripgreprc
└── nvim/
    ├── init.lua
    ├── lazy-lock.json      # pinned plugin commits — commit this
    └── lua/
        ├── core/           # options, keymaps, autocmds, icons, cheatsheet
        └── plugins/        # one file per concern
```

Per-machine tweaks go in `~/.bashrc.local` — it is sourced last and never
committed.

`nvim/lazy-lock.json` pins all 48 plugins to the exact commits this config was
tested against, so every new machine gets the same known-good set instead of
whatever is newest. Run `:Lazy update` when you want to move forward, then
commit the updated lockfile. `:Lazy restore` rolls back to it.

All Nerd Font glyphs live in `nvim/lua/core/icons.lua` as `\u{XXXX}` escapes
rather than pasted characters — pasted glyphs get mangled in transit, and an
empty `fillchars` entry is a hard startup error. Add new icons there.

---

## Shell highlights

**History suggestions.** With ble.sh installed, the rest of your best-matching
past command appears greyed out as you type; press `→` or `Ctrl-F` to accept it,
`Alt-F` to take one word. Without ble.sh, `Up`/`Down` do prefix search instead
(type `git ch`, press `Up`, walk only through matching entries). `Ctrl-R` is
always fuzzy search over everything. Run `envhelp` to see which engine is live.

History is 200k entries, timestamped, deduplicated, flushed after every command
and shared live between open terminals.

**Prompt.** Shows user@host, path, branch with staged/dirty/untracked/ahead/behind
counts, virtualenv, CMake build type, exit code, and the duration of anything
that took over 3 seconds. It shells out to git exactly once per prompt.

Set `MY_ENV_ASCII=1` if your terminal has no Nerd Font, or
`MY_ENV_PROMPT=starship` to use starship instead.

**Handy commands.** `cc-db` `ccrun` `ccasm` `gdbr` `mkcd` `up` `extract` `bak`
`ff` `fif` `fkill` `fcd` `fgb` `hstats` `please` `whichf` `colortest`.
`envhelp` documents them all; `envhelp git` filters to one section.

---

## Neovim highlights

Leader is `<Space>`. Press `<Space>?` for the full cheatsheet, or just press
`<Space>` and wait — which-key lists what is available.

- **Find** `<Space>ff` files · `<Space>fg` grep · `<Space>fs` symbols · `<Space>/` in buffer
- **LSP** `gd` definition · `gr` references · `K` hover · `<Space>ca` code action · `<Space>rn` rename
- **C/C++** `<Space>ch` header↔source · `<Space>ci` inlay hints · `<Space>cf` clang-format
- **Jump** `s` + two characters lands anywhere on screen · `]]`/`[[` between functions
- **Text objects** `daf` delete a function · `vic` select a class body · `cia` change an argument
- **Debug** `<F5>` start · `<Space>db` breakpoint · `<Space>du` inspector
- **Claude Code** `<Space>ac` toggle in a right split · `<Space>as` send selection *(visual)* · `<C-n>` file tree (also `<Space>e`)

Plugins are managed by lazy.nvim (`:Lazy`) and LSP servers by Mason (`:Mason`).
Both update themselves on a weekly check.

See [CHEATSHEET.md](CHEATSHEET.md) for the printable version.

---

## Markdown preview with Mermaid

`<Space>mp` opens the current `.md` file in your browser with live reload —
Mermaid diagrams, KaTeX math, and sequence/flow diagrams all render as the
real thing, not code blocks. It's [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim).

It needs **Node.js + npm** on your `PATH`. The plugin's own auto-installer
normally fetches a prebuilt binary instead of using Node, but that binary
segfaults on current glibc (verified on Ubuntu 24.04, glibc 2.39 — a known
`pkg`-snapshot/glibc incompatibility, not a config issue). This config builds
against your local Node instead, which sidesteps it. `install.sh` does not
install Node itself; if `npm` isn't found, `:Lazy build markdown-preview.nvim`
will fail with a clear "npm: not found" rather than silently producing a
preview that crashes.

---

## Claude Code inside Neovim

`<Space>ac` opens Claude in a right-hand split — the same WebSocket-based
integration the VS Code/Cursor extension uses, reimplemented in pure Lua by
[coder/claudecode.nvim](https://github.com/coder/claudecode.nvim). It tracks
your current file and visual selection as context, and shows proposed edits as
an inline diff you accept (`<Space>aa`) or reject (`<Space>ad`) — you never
have to leave the editor to review a change.

`install.sh` installs the CLI itself (the official native installer — no Node
required), so `claude` is already on your `PATH` by the time you open Neovim.
The one manual step is logging in: run `claude` once and follow the browser
prompt. If you installed a different way and `terminal_cmd` needs to point
somewhere non-standard, set it in `nvim/lua/plugins/claude.lua`.

---

## Troubleshooting

**Boxes instead of icons** — your terminal font is not a Nerd Font yet. Install
one (`./install.sh --no-nvim` re-runs just the font step among others) and select
"JetBrainsMono Nerd Font Mono" in your terminal preferences. Fonts are a terminal
setting, not something a shell config can change.

**No completion in C++** — run `cc-db` in the project root, then `:LspRestart`.
Confirm with `:LspInfo` that clangd attached and `:ClangdShowStatus` that it found
your compile database.

**`:checkhealth`** diagnoses most other problems.

**Colours look flat** — you need a truecolor terminal. `colortest` shows what
yours supports; the bottom gradient should be smooth, not banded.

**Slow shell startup** — `MY_ENV_PROMPT=starship` and ble.sh both add a little.
Time it with `time bash -lic exit`.
