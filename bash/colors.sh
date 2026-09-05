# --------------------------------------------------------------- colors.sh --
# Terminal colour coding: ls, grep, man pages, diffs, and the prompt palette.

# --- Catppuccin Mocha palette (256/truecolor) ---------------------------
# Used by the prompt and by any script that wants consistent colours.
export CAT_ROSEWATER='#f5e0dc' CAT_FLAMINGO='#f2cdcd' CAT_PINK='#f5c2e7'
export CAT_MAUVE='#cba6f7'     CAT_RED='#f38ba8'      CAT_MAROON='#eba0ac'
export CAT_PEACH='#fab387'     CAT_YELLOW='#f9e2af'   CAT_GREEN='#a6e3a1'
export CAT_TEAL='#94e2d5'      CAT_SKY='#89dceb'      CAT_SAPPHIRE='#74c7ec'
export CAT_BLUE='#89b4fa'      CAT_LAVENDER='#b4befe' CAT_TEXT='#cdd6f4'
export CAT_SUBTLE='#6c7086'    CAT_SURFACE='#313244'  CAT_BASE='#1e1e2e'

# 24-bit escape helpers (named ansi_* so the fg/bg job-control builtins survive):
#   ansi_fg '#89b4fa'  ->  \[\033[38;2;137;180;250m\]
ansi_fg() { printf '\001\033[38;2;%d;%d;%dm\002' "0x${1:1:2}" "0x${1:3:2}" "0x${1:5:2}"; }
ansi_bg() { printf '\001\033[48;2;%d;%d;%dm\002' "0x${1:1:2}" "0x${1:3:2}" "0x${1:5:2}"; }

# Plain (non-prompt) variants — safe inside echo/printf in scripts.
c_reset=$'\033[0m'; c_bold=$'\033[1m';   c_dim=$'\033[2m';    c_italic=$'\033[3m'
c_red=$'\033[38;5;211m';   c_green=$'\033[38;5;150m'; c_yellow=$'\033[38;5;223m'
c_blue=$'\033[38;5;111m';  c_mauve=$'\033[38;5;183m'; c_teal=$'\033[38;5;115m'
c_peach=$'\033[38;5;216m'; c_grey=$'\033[38;5;245m'
export c_reset c_bold c_dim c_italic c_red c_green c_yellow c_blue c_mauve c_teal c_peach c_grey

# --- ls / eza -----------------------------------------------------------
if command -v dircolors >/dev/null 2>&1; then
    if [[ -r "$MY_ENV_ROOT/config/dircolors" ]]; then
        eval "$(dircolors -b "$MY_ENV_ROOT/config/dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi
export EXA_COLORS="da=38;5;245:uu=38;5;183:gu=38;5;245"
export TIME_STYLE=long-iso

# --- grep ---------------------------------------------------------------
export GREP_COLORS='mt=1;38;5;223:fn=38;5;111:ln=38;5;245:se=38;5;240'

# --- man pages (less termcap) -------------------------------------------
export LESS_TERMCAP_mb=$'\033[1;38;5;211m'   # blink  -> red
export LESS_TERMCAP_md=$'\033[1;38;5;111m'   # bold   -> blue
export LESS_TERMCAP_me=$'\033[0m'
export LESS_TERMCAP_so=$'\033[1;38;5;235;48;5;223m'  # search / status bar
export LESS_TERMCAP_se=$'\033[0m'
export LESS_TERMCAP_us=$'\033[4;38;5;150m'   # underline -> green
export LESS_TERMCAP_ue=$'\033[0m'
export GROFF_NO_SGR=1

# --- systemd / journal / misc -------------------------------------------
export SYSTEMD_COLORS=1

# --- helper: print the full 256-colour palette --------------------------
colortest() {
    local i
    printf '%s16-color:%s\n' "$c_bold" "$c_reset"
    for i in {0..15}; do printf '\033[48;5;%dm  %s' "$i" "$c_reset"; done; echo
    printf '\n%s256-color cube:%s\n' "$c_bold" "$c_reset"
    for i in {16..231}; do
        printf '\033[48;5;%dm  %s' "$i" "$c_reset"
        (( (i - 15) % 36 )) || echo
    done
    echo
    printf '\n%struecolor gradient:%s\n' "$c_bold" "$c_reset"
    for i in $(seq 0 79); do
        printf '\033[48;2;%d;%d;%dm ' $(( i * 3 )) $(( 255 - i * 3 )) 180
    done
    printf '%s\n' "$c_reset"
}
