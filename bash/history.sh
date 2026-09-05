# -------------------------------------------------------------- history.sh --
# A large, deduplicated, shared history — this is what powers the
# autosuggestions (ble.sh), Ctrl-R fuzzy search (fzf) and Up/Down prefix search.

export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/bash/history"
mkdir -p "$(dirname "$HISTFILE")" 2>/dev/null

export HISTSIZE=200000          # entries kept in memory
export HISTFILESIZE=400000      # entries kept on disk
export HISTTIMEFORMAT='%F %T  ' # timestamp every entry
export HISTCONTROL=ignoredups:erasedups   # collapse repeats, keep one copy
# Noise that is never worth suggesting back.
export HISTIGNORE='ls:ll:la:l:cd:cd -:pwd:exit:clear:c:bg:fg:history:h:* --help:?:??'

shopt -s histappend      # append instead of overwrite on exit
shopt -s cmdhist         # multi-line commands stored as one entry
shopt -s lithist         # ...with embedded newlines, not semicolons
shopt -s histreedit      # re-edit a failed history substitution
shopt -s histverify      # expand !! into the line for review, don't run blind

# Flush after every command so a new terminal immediately sees what you just
# typed elsewhere, and so a crash never loses the session.
__hist_sync() { history -a; }
case ";${PROMPT_COMMAND:-};" in
    *";__hist_sync;"*) ;;
    *) PROMPT_COMMAND="__hist_sync;${PROMPT_COMMAND:-}" ;;
esac

# --- history helpers ----------------------------------------------------

# hgrep <pattern> — search history
hgrep() { history | grep -i --color=auto -- "$@"; }

# htop-commands — your 20 most used commands
hstats() {
    history \
      | awk '{ CMD[$4]++; count++ } END { for (a in CMD) printf "%5d  %5.2f%%  %s\n", CMD[a], CMD[a]/count*100, a }' \
      | sort -rn | head -"${1:-20}"
}

# hclean — rewrite the history file with duplicates removed, newest kept
hclean() {
    local tmp; tmp="$(mktemp)"
    tac "$HISTFILE" | awk '!/^#/ && !seen[$0]++ { print }' | tac > "$tmp"
    mv "$tmp" "$HISTFILE"
    history -c; history -r
    printf '%shistory deduplicated (%s entries)%s\n' "$c_green" "$(wc -l < "$HISTFILE")" "$c_reset"
}
