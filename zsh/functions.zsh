# ------------------------------------------------------------ functions.zsh --

# mkcd <dir> — create a directory and enter it
mkcd() { mkdir -p -- "$1" && cd -P -- "$1" || return; }

# up [n] — climb n directories (default 1)
up() {
    local n="${1:-1}" p=""
    while (( n-- > 0 )); do p+="../"; done
    cd "${p:-.}" || return
}

# extract <archive…> — unpack anything
extract() {
    local f
    for f in "$@"; do
        [[ -f "$f" ]] || { printf '%snot a file: %s%s\n' "$c_red" "$f" "$c_reset" >&2; continue; }
        case "$f" in
            *.tar.bz2|*.tbz2) tar xjf "$f"   ;;
            *.tar.gz|*.tgz)   tar xzf "$f"   ;;
            *.tar.xz|*.txz)   tar xJf "$f"   ;;
            *.tar.zst)        tar --zstd -xf "$f" ;;
            *.tar)            tar xf "$f"    ;;
            *.bz2)            bunzip2 "$f"   ;;
            *.gz)             gunzip "$f"    ;;
            *.xz)             unxz "$f"      ;;
            *.zst)            unzstd "$f"    ;;
            *.zip)            unzip -q "$f"  ;;
            *.rar)            unrar x "$f"   ;;
            *.7z)             7z x "$f"      ;;
            *.deb)            ar x "$f"      ;;
            *) printf '%sunknown archive type: %s%s\n' "$c_red" "$f" "$c_reset" >&2 ;;
        esac
    done
}

# mkarchive <name.tar.zst> <paths…>
mkarchive() {
    local out="$1"; shift
    case "$out" in
        *.tar.zst) tar --zstd -cf "$out" "$@" ;;
        *.tar.gz)  tar -czf "$out" "$@" ;;
        *.zip)     zip -qr "$out" "$@" ;;
        *) printf 'use .tar.zst, .tar.gz or .zip\n' >&2; return 2 ;;
    esac
    printf '%s%s%s\n' "$c_green" "$out" "$c_reset"
}

# bak <file> — timestamped copy next to the original
bak() {
    local f
    for f in "$@"; do cp -a -- "$f" "$f.$(date +%Y%m%d-%H%M%S).bak" && printf 'backed up %s\n' "$f"; done
}

# ff <pattern> — find files by name, anywhere below cwd
ff() {
    if command -v fd >/dev/null 2>&1; then fd --hidden --follow --exclude .git -- "$@"
    else find . -iname "*$1*" -not -path '*/.git/*' 2>/dev/null; fi
}

# fif <pattern> — find *in* files (ripgrep, falls back to grep)
fif() {
    if command -v rg >/dev/null 2>&1; then rg --hidden --glob '!.git' --line-number --color=always "$@"
    else grep -rniI --color=auto --exclude-dir=.git "$@" .; fi
}

# --- C/C++ helpers ------------------------------------------------------

# cc-db — make clangd work in this project by producing compile_commands.json
cc-db() {
    if [[ -f CMakeLists.txt ]]; then
        printf '%scmake: generating compile_commands.json%s\n' "$c_blue" "$c_reset"
        cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON "$@" \
            && ln -sf build/compile_commands.json compile_commands.json \
            && printf '%s✓ compile_commands.json linked%s\n' "$c_green" "$c_reset"
    elif [[ -f Makefile ]] && command -v bear >/dev/null 2>&1; then
        printf '%sbear: recording a build%s\n' "$c_blue" "$c_reset"
        bear -- make -j"$(nproc)" "$@"
    elif [[ -f Makefile ]]; then
        printf '%sInstall `bear` to capture a Makefile build:%s\n' "$c_yellow" "$c_reset" >&2
        printf '  sudo apt install bear  &&  cc-db\n' >&2
        return 1
    else
        printf '%sNo CMakeLists.txt or Makefile here.%s\n' "$c_yellow" "$c_reset" >&2
        printf 'For loose files, create a .clangd or compile_flags.txt — try: cc-flags\n' >&2
        return 1
    fi
}

# cc-flags [flags…] — drop a compile_flags.txt so clangd understands loose files
cc-flags() {
    local flags=("${@:--std=c++20 -Wall -Wextra -I.}")
    printf '%s\n' "${flags[@]}" | tr ' ' '\n' > compile_flags.txt
    printf '%s✓ compile_flags.txt written:%s\n' "$c_green" "$c_reset"
    cat compile_flags.txt
}

# ccrun <file.c|file.cpp> [args…] — compile one file with sane flags and run it
ccrun() {
    local src="$1"; shift
    [[ -f "$src" ]] || { printf 'no such file: %s\n' "$src" >&2; return 2; }
    local out; out="$(mktemp -d)/${src##*/}"; out="${out%.*}"
    local cc_flags=(-g -O0 -Wall -Wextra -Wpedantic -fsanitize=address,undefined -fno-omit-frame-pointer)
    case "$src" in
        *.c)   cc  "$src" -std=c17   "${cc_flags[@]}" -o "$out" || return ;;
        *.cc|*.cpp|*.cxx) c++ "$src" -std=c++20 "${cc_flags[@]}" -o "$out" || return ;;
        *) printf 'not a C/C++ source: %s\n' "$src" >&2; return 2 ;;
    esac
    printf '%s─── running (asan+ubsan) ───%s\n' "$c_grey" "$c_reset"
    "$out" "$@"
}

# ccasm <file> — show the optimised assembly for a translation unit
ccasm() { c++ -std=c++20 -O2 -S -masm=intel -fno-asynchronous-unwind-tables "$1" -o - | grep -v '^\s*\.'; }

# gdbr <binary> [args…] — run under gdb, break on crash, show the backtrace
gdbr() { gdb -q -ex run -ex bt --args "$@"; }

# --- misc ---------------------------------------------------------------

# please — rerun the previous command with sudo
# (fc -ln -2 -2 is the entry *before* `please` itself, which is already in history)
please() {
    local last
    last="$(fc -ln -2 -2 2>/dev/null)"
    last="${last#"${last%%[![:space:]]*}"}"          # strip fc's leading indent
    [[ -n "$last" ]] || { printf 'no previous command\n' >&2; return 1; }
    printf '%ssudo %s%s\n' "$c_grey" "$last" "$c_reset"
    eval "sudo $last"
}

# calc <expr>
calc() { printf '%s\n' "$*" | bc -l; }

# genpass [len]
genpass() { LC_ALL=C tr -dc 'A-Za-z0-9!@#%^&*_+=' < /dev/urandom | head -c "${1:-24}"; echo; }

# weather [city]
weather() { curl -fsS "https://wttr.in/${1:-}?format=3" && echo; }

# mkgitignore <lang…>
mkgitignore() { curl -fsSL "https://www.toptal.com/developers/gitignore/api/$(IFS=,; echo "$*")" >> .gitignore; }

# note <text…> — append a timestamped line to ~/notes.md
note() {
    local f="${MY_ENV_NOTES:-$HOME/notes.md}"
    if (( $# )); then printf -- '- %s  %s\n' "$(date +%F\ %H:%M)" "$*" >> "$f"
    else "$EDITOR" "$f"; fi
}

# whichf <name> — resolve an alias/function/binary and show its definition
whichf() {
    local t; t="$(type -w "$1" 2>/dev/null)"
    case "$t" in
        *function)  functions "$1" ;;
        *alias)     alias "$1" ;;
        *command)   command -v "$1"; readlink -f "$(command -v "$1")" ;;
        *)          type "$1" ;;
    esac
}
