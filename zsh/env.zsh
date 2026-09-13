# ------------------------------------------------------------------ env.zsh --
# Environment variables, PATH, and tool defaults.

# --- PATH ---------------------------------------------------------------
# prepend without creating duplicates
path_prepend() {
    local d
    for d in "$@"; do
        [[ -d "$d" ]] || continue
        case ":$PATH:" in
            *":$d:"*) ;;
            *) PATH="$d:$PATH" ;;
        esac
    done
    export PATH
}

path_prepend \
    "$HOME/.local/bin" \
    "$HOME/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/go/bin" \
    "${XDG_DATA_HOME:-$HOME/.local/share}/my_environment/neovim/bin"

# --- XDG ----------------------------------------------------------------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# --- editor -------------------------------------------------------------
if command -v nvim >/dev/null 2>&1; then
    export EDITOR=nvim VISUAL=nvim
    export MANPAGER='nvim +Man!'
    export MANWIDTH=999
else
    export EDITOR="${EDITOR:-vim}" VISUAL="${VISUAL:-vim}"
fi

# --- locale / terminal --------------------------------------------------
export LANG="${LANG:-en_US.UTF-8}"
export LC_COLLATE=C                 # deterministic sort order in globs
export COLORTERM="${COLORTERM:-truecolor}"

# --- pager --------------------------------------------------------------
export PAGER=less
# -R keep colors, -F quit if one screen, -X don't clear, -i smart case
export LESS='-R -F -X -i -M -j5'
export LESSHISTFILE="$XDG_STATE_HOME/less_history"

# --- C/C++ toolchain ----------------------------------------------------
export CMAKE_EXPORT_COMPILE_COMMANDS=ON   # clangd needs compile_commands.json
export CMAKE_GENERATOR="${CMAKE_GENERATOR:-Unix Makefiles}"
command -v ninja >/dev/null 2>&1 && export CMAKE_GENERATOR=Ninja
export MAKEFLAGS="-j$(command -p nproc 2>/dev/null || echo 4)"
# Readable GCC/Clang diagnostics.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# --- misc tool defaults -------------------------------------------------
export GIT_PAGER='less -FRX'
export BAT_THEME="${BAT_THEME:-Catppuccin Mocha}"
export RIPGREP_CONFIG_PATH="$MY_ENV_ROOT/config/ripgreprc"
export PYTHONDONTWRITEBYTECODE=1
export PIP_REQUIRE_VIRTUALENV=true
export DOCKER_BUILDKIT=1
