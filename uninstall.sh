#!/usr/bin/env bash
# Removes the my_environment hooks and symlinks. Your own ~/.bashrc content,
# the backups taken at install time, and your history file are all left alone.
set -Eeuo pipefail

ENV_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/my_environment"
NVIM_CFG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

C_G=$'\033[32m'; C_Y=$'\033[33m'; C_D=$'\033[2m'; C_RST=$'\033[0m'
ok()   { printf '  %s✓%s %s\n' "$C_G" "$C_RST" "$*"; }
skip() { printf '  %s·%s %s\n' "$C_D" "$C_RST" "$*"; }

PURGE=0
[[ "${1:-}" == "--purge" ]] && PURGE=1

printf '\nRemoving my_environment…\n\n'

# 1. the ~/.bashrc and ~/.zshrc blocks
for _rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if grep -qF '# >>> my_environment >>>' "$_rc" 2>/dev/null; then
        cp "$_rc" "$_rc.pre-uninstall"
        sed -i '/# >>> my_environment >>>/,/# <<< my_environment <<</d' "$_rc"
        ok "removed the $(basename "$_rc") block (previous copy: $(basename "$_rc").pre-uninstall)"
    else
        skip "no $(basename "$_rc") block found"
    fi
done
unset _rc

# 2. symlinks we created — only if they still point into this repo
unlink_if_ours() {
    local link="$1"
    if [[ -L "$link" ]] && [[ "$(readlink -f "$link")" == "$ENV_ROOT"* ]]; then
        rm -f "$link"; ok "unlinked $link"
    else
        skip "$link is not ours, leaving it"
    fi
}
unlink_if_ours "$NVIM_CFG"
unlink_if_ours "$HOME/.inputrc"
unlink_if_ours "$HOME/.clang-format"
unlink_if_ours "${XDG_CONFIG_HOME:-$HOME/.config}/clangd/config.yaml"

# 3. binaries we installed into ~/.local/bin
for b in nvim fd bat fzf peco; do
    link="$HOME/.local/bin/$b"
    if [[ -L "$link" ]] && [[ "$(readlink -f "$link")" == "$STATE_DIR"* ]]; then
        rm -f "$link"; ok "unlinked $link"
    fi
done

if (( PURGE )); then
    printf '\n%s--purge: removing downloaded artefacts%s\n' "$C_Y" "$C_RST"
    rm -rf "$STATE_DIR/neovim"                          && ok "removed the Neovim install"
    rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/nvim"  && ok "removed Neovim plugins/data"
    rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/nvim" && ok "removed Neovim state"
    rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/blesh" && ok "removed legacy ble.sh (if present)"
    rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh" && ok "removed oh-my-zsh (theme, plugins)"
    rm -rf "$STATE_DIR/peco" && ok "removed peco"
    printf '  %sfonts, shell history and ~/.p10k.zsh were kept%s\n' "$C_D" "$C_RST"
fi

printf '\nDone. Backups from install time are in %s/backups/\n' "$STATE_DIR"
printf 'Run %sexec bash%s to drop back to a plain shell.\n\n' "$C_G" "$C_RST"
