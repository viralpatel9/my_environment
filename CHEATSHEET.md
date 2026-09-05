# Cheatsheet

Leader is `<Space>`. In Neovim, `<Space>?` opens this same reference in a floating
window; in the shell, `envhelp` (or `Ctrl-O`) prints the shell half.

---

## Survival

| Key | Does |
|---|---|
| `<Space>` | leader — every custom mapping starts here; press it and wait for which-key |
| `<Space>?` | this cheatsheet |
| `jk` | leave insert mode |
| `<Esc>` | clear search highlight |
| `<Space>w` / `<Space>q` | write / quit |
| `<Space>Q` | quit everything |
| `u` / `<C-r>` | undo / redo |
| `.` | repeat the last change — the highest-leverage key in vim |
| `:Lazy` `:Mason` `:checkhealth` | plugins / LSP servers / diagnose problems |

---

## Moving around

| Key | Does |
|---|---|
| `w` `b` `e` | next word / back a word / end of word |
| `W` `B` `E` | same but whitespace-delimited (skips punctuation) |
| `0` `H` `L` `$` | line start / first non-blank / last non-blank / line end |
| `f{c}` `t{c}` | jump to / just before the next `{c}`; `;` and `,` repeat |
| `{` `}` | previous / next blank line |
| `%` | matching bracket — also `<`/`>` in C++ templates |
| `gg` `G` | top / bottom of file |
| `{N}G` or `:{N}` | go to line N |
| `{N}j` `{N}k` | N lines down/up — the relative numbers in the gutter are N |
| `<C-d>` `<C-u>` | half page down / up, cursor stays centred |
| `<C-o>` `<C-i>` | back / forward through the jump list |
| `` `` `` | back to where you just were |
| `s{c}{c}` | **flash**: type two characters, jump anywhere on screen |
| `S` | flash treesitter: jump to any syntax node |
| `zz` `zt` `zb` | centre / top / bottom the cursor line |
| `m{a-z}` `'{a-z}` | set / jump to a mark (uppercase = across files) |

---

## Search and replace

| Key | Does |
|---|---|
| `/` `?` | search forward / backward, `n` `N` to repeat |
| `*` `#` | search the word under the cursor |
| `:%s/old/new/g` | replace in file (`gc` to confirm each) |
| `<Space>sr` | replace the word under the cursor, file-wide |
| `<Space>/` | fuzzy search inside this buffer |
| `<Space>fg` | live grep the project |
| `<Space>fw` | grep the word under the cursor |
| `<Space>sR` | project-wide search **and replace** (grug-far) |

---

## Files, buffers, windows

| Key | Does |
|---|---|
| `<Space>ff` / `<Space>fa` | find files / including ignored+hidden |
| `<Space>fr` `<Space>fb` | recent files / open buffers |
| `<Space>fs` `<Space>fS` | symbols in this file / in the workspace |
| `<Space>fk` `<Space>fh` | search keymaps / help |
| `<Space>e` `<Space>E` / `<C-n>` | toggle file tree / reveal current file in it |
| `<Space>fy` | copy the current file's path |
| `<S-h>` `<S-l>` | previous / next buffer |
| `<Space>bb` `<Space>bd` `<Space>bo` | last buffer / close / close others |
| `<C-h/j/k/l>` | move between splits (works from the terminal too) |
| `<Space>sv` `<Space>sh` | split vertical / horizontal |
| `<Space>sx` `<Space>so` `<Space>se` | close split / close others / equalise |
| `<C-arrows>` | resize the split |

In the file tree: `a` add, `d` delete, `r` rename, `x` cut, `p` paste, `?` help.

---

## Editing

| Key | Does |
|---|---|
| `i` `a` `I` `A` | insert before/after cursor, at line start/end |
| `o` `O` | open a line below / above |
| `ciw` `diw` `yiw` | change / delete / yank the inner word |
| `ci"` `ci(` `ci{` | change inside quotes / parens / braces |
| `ca(` `da{` | the `a` variants include the delimiters |
| `v` `V` `<C-v>` | visual char / line / **block** (column editing) |
| `J` `K` *(visual)* | move the selection down / up, re-indenting |
| `<` `>` *(visual)* | indent, keeping the selection |
| `<A-j>` `<A-k>` | move the current line down / up |
| `gcc` `gc{motion}` | toggle comment |
| `ysiw"` | surround the word with quotes |
| `cs"'` / `ds"` | change surrounding `"` to `'` / delete surrounding `"` |
| `<Space>y` `<Space>d` | yank to system clipboard / delete to black hole |
| `<Space>a` | select the whole file |
| `<C-space>` | grow the selection by syntax node (again to grow, `<BS>` to shrink) |
| `<Space>u` | undo tree |

---

## C / C++

| Key | Does |
|---|---|
| `K` | hover: type, signature, docs |
| `gd` `gD` `gi` `gy` | definition / declaration / implementation / type definition |
| `gr` | list references |
| `<C-k>` *(insert)* | signature help while typing arguments |
| `<Space>ca` | code action — add the include, extract, fix it |
| `<Space>rn` | rename the symbol everywhere |
| `<Space>cf` | format with clang-format |
| `<Space>cF` | toggle format-on-save |
| `<Space>ch` | **switch header ↔ source** |
| `<Space>ci` | toggle inlay hints (parameter names, deduced types) |
| `<Space>cs` `<Space>ct` `<Space>cA` | symbol info / type hierarchy / AST |
| `]d` `[d` | next / previous diagnostic |
| `<Space>e` | full diagnostic under the cursor |
| `<Space>xx` `<Space>xX` | all diagnostics: project / this buffer |
| `<Space>cm` | run `:make`, jump to the first error |
| `]]` `[[` | next / previous function |
| `]k` `[k` | next / previous class |
| `af` `if` | text object: a function / its body — try `daf`, `vif` |
| `ac` `ic` | a class / its body |
| `aa` `ia` | an argument / its inner — `<Space>na` swaps it with the next |

**Completion (insert mode):** `<C-space>` open · `<Tab>`/`<S-Tab>` next/prev and
snippet slots · `<CR>` accept · `<C-e>` dismiss · `<C-b>`/`<C-f>` scroll docs.

---

## Markdown preview

| Key | Does |
|---|---|
| `<Space>mp` | toggle a live browser preview (Mermaid, KaTeX, sequence diagrams) |
| `<Space>ms` | stop the preview |

Requires Node.js + npm on `PATH` — the plugin builds against local Node rather
than its own prebuilt binary, which segfaults on current glibc (see README).

---

## Claude Code

| Key | Does |
|---|---|
| `<Space>ac` | toggle Claude in a right-hand split |
| `<Space>af` | focus the Claude pane |
| `<Space>ab` | add the current buffer to Claude's context |
| `<Space>as` *(visual)* | send the selection to Claude |
| `<Space>aa` `<Space>ad` | accept / reject a proposed diff |
| `<Space>ar` `<Space>aC` | resume / continue the last session |
| `<Space>am` | pick a model |

`install.sh` installs the `claude` CLI for you (skip with `--no-claude`). Log
in once with `claude` before using this — it opens a browser prompt.

---

## Debugging

| Key | Does |
|---|---|
| `<F5>` | start / continue |
| `<F10>` `<F11>` `<S-F11>` | step over / into / out |
| `<Space>db` `<Space>dB` | breakpoint / conditional breakpoint |
| `<Space>du` | toggle the debugger UI |
| `<Space>de` | evaluate the expression under the cursor |
| `<Space>dr` `<Space>dt` `<Space>dl` | REPL / terminate / run last |

Build with debug info first: `cmd && cb` (that is `cmake -DCMAKE_BUILD_TYPE=Debug`
then build). `<F5>` prompts for the binary, defaulting to `build/`.

---

## Git

| Key | Does |
|---|---|
| `]c` `[c` | next / previous hunk |
| `<Space>gp` | preview the hunk |
| `<Space>gs` `<Space>gr` | stage / reset the hunk (works on a visual selection) |
| `<Space>gS` `<Space>gR` | stage / reset the whole buffer |
| `<Space>gb` `<Space>gB` | blame this line / toggle inline blame |
| `<Space>gd` `<Space>gD` | diff against index / last commit |
| `<Space>gv` `<Space>gh` | diffview / this file's history |
| `<Space>gc` `<Space>gt` | commits / status (telescope) |
| `<Space>gg` | lazygit |
| `ih` | text object: a hunk — `vih` selects it |

---

## Terminal

| Key | Does |
|---|---|
| `<C-\>` | toggle a floating terminal |
| `<Esc><Esc>` | back to normal mode from the terminal |
| `<Space>tf` `<Space>th` `<Space>tv` | floating / horizontal / vertical terminal |
| `<Space>tg` `<Space>tp` | lazygit / python REPL |

---

# Shell

## History and suggestions

| Key | Does |
|---|---|
| `→` or `Ctrl-F` | accept the greyed-out suggestion (ble.sh) |
| `Alt-F` | accept one word of it |
| `Up` / `Down` | prefix search — type `git ch`, press Up (fallback mode) |
| `Ctrl-R` | fuzzy search all history |
| `Alt-H` | pick a past command onto the line |
| `Alt-.` | insert the last argument of the previous command |
| `!!` `!$` `!^` | previous command / its last / first argument |
| `^old^new` | rerun the previous command with one substitution |
| `hgrep` `hstats` `hclean` | grep history / most-used commands / deduplicate |

## Navigation and files

| Command | Does |
|---|---|
| `..` `...` `....` | up 1 / 2 / 3 directories |
| `-` | previous directory |
| `up 3` | up N directories |
| `z <partial>` | jump to a frequent directory (zoxide) |
| `fcd` / `Alt-C` | fuzzy-pick a directory |
| `Alt-G` | jump to the git repo root |
| `mkcd <dir>` | create a directory and enter it |
| `Ctrl-T` | fuzzy file picker, inserts the path |
| `ff` / `fif` | find files by name / find text in files |
| `ll` `la` `lt` | long list / with hidden / tree |
| `extract <archive>` | unpack anything |
| `bak <file>` | timestamped backup |

## Git aliases

`gs` status · `ga` `gaa` `gap` add/all/patch · `gc` `gcm` commit · `gco` `gsw` `gcb`
checkout/switch/branch · `gd` `gds` diff/staged · `gl` `gla` log graph · `gp` `gpf`
`gpl` push/force-with-lease/pull-rebase · `gstash` `gpop` · `fgb` fuzzy branch ·
`groot` repo root.

## C/C++ build

| Command | Does |
|---|---|
| `cc-db` | **generate `compile_commands.json` — do this first in any project** |
| `cc-flags` | write a `compile_flags.txt` for loose files |
| `cm` `cmd` `cmr` | cmake configure: default / Debug / RelWithDebInfo |
| `cb` `ct` | cmake build / ctest |
| `mj` | `make -j$(nproc)` |
| `ccrun f.cpp` | compile one file with asan+ubsan and run it |
| `ccasm f.cpp` | show the optimised assembly |
| `gdbr ./prog` | run under gdb, break on crash, print a backtrace |

## Misc

`envhelp [section]` this page · `reload` restart bash · `colortest` check colours ·
`whichf <name>` what is this? · `hlp <cmd>` highlighted `--help` · `please` rerun
with sudo · `fkill` fuzzy kill · `genpass` · `note` · `serve` · `myip` · `weather`.
