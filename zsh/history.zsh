# -------------------------------------------------------------- history.zsh --
# A large, deduplicated, shared history — pairs with zsh-autosuggestions
# (ghost text) and zsh-peco-history (Ctrl-R fuzzy search) from oh-my-zsh.

export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")" 2>/dev/null

export HISTSIZE=200000          # entries kept in memory
export SAVEHIST=400000          # entries kept on disk

setopt extended_history         # timestamp every entry
setopt hist_ignore_dups         # collapse immediate repeats
setopt hist_ignore_all_dups     # ...and older duplicates, keep the newest
setopt hist_expire_dups_first
setopt hist_ignore_space        # a leading space keeps a command out of history
setopt hist_reduce_blanks
setopt hist_verify              # expand !! into the line for review, don't run blind
setopt append_history
setopt inc_append_history       # write immediately, not just on exit
setopt share_history            # ...and share live between open terminals

# --- history helpers ------------------------------------------------------

# hgrep <pattern> — search history
hgrep() { fc -l 1 | grep -i --color=auto -- "$@"; }

# hstats — your 20 most used commands
hstats() {
    fc -l 1 \
      | awk '{ CMD[$2]++; count++ } END { for (a in CMD) printf "%5d  %5.2f%%  %s\n", CMD[a], CMD[a]/count*100, a }' \
      | sort -rn | head -"${1:-20}"
}

# hclean — rewrite the history file with duplicates removed, newest kept
hclean() {
    local tmp; tmp="$(mktemp)"
    tac "$HISTFILE" | awk '!/^#/ && !seen[$0]++ { print }' | tac > "$tmp"
    mv "$tmp" "$HISTFILE"
    fc -R "$HISTFILE"
    printf '%shistory deduplicated (%s entries)%s\n' "$c_green" "$(wc -l < "$HISTFILE")" "$c_reset"
}
