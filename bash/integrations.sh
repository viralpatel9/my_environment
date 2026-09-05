# --------------------------------------------------- integrations.sh --
# Third-party tools + the key bindings that give you history suggestions.

# ============================================================ 1. ble.sh ====
# Fish-style *inline* autosuggestions: as you type, the rest of the best
# matching history entry appears greyed out ahead of the cursor.
#   Right-arrow / End / Ctrl-F   accept the whole suggestion
#   Alt-F                        accept one word
if [[ -n "${BLE_VERSION-}" ]]; then
    # Suggest from history first, then from completion sources.
    bleopt complete_auto_complete=1
    bleopt complete_auto_delay=1
    bleopt complete_ambiguous=1
    bleopt complete_menu_style=desc
    bleopt history_share=1                # live history sharing between terminals
    bleopt exec_errexit_mark=

    # Colours for the ghost text and the syntax highlighting of your input.
    ble-face auto_complete='fg=245,italic'      # the suggestion itself
    ble-face syntax_command='fg=111,bold'       # commands   -> blue
    ble-face syntax_quoted='fg=150'             # strings    -> green
    ble-face syntax_error='fg=211,bold'         # bad syntax -> red
    ble-face syntax_varname='fg=223'            # variables  -> yellow
    ble-face syntax_comment='fg=245,italic'
    ble-face command_directory='fg=111,underline'
    ble-face filename_directory='fg=111,bold'
    ble-face region_insert='bg=238'

    # Accept the suggestion the way fish does.
    ble-bind -m auto_complete -f 'C-f' auto_complete/insert
    ble-bind -m auto_complete -f 'right' auto_complete/insert
    ble-bind -m auto_complete -f 'M-f' auto_complete/insert-word
    MY_ENV_SUGGEST="ble.sh"
else
    # ---- fallback: no ble.sh, so bind prefix-search to the arrow keys.
    # Type `git ch` then press Up to walk only through matching history.
    bind '"\e[A": history-search-backward' 2>/dev/null
    bind '"\e[B": history-search-forward'  2>/dev/null
    bind '"\eOA": history-search-backward' 2>/dev/null
    bind '"\eOB": history-search-forward'  2>/dev/null
    MY_ENV_SUGGEST="readline prefix search (install ble.sh for inline ghost text)"
fi
export MY_ENV_SUGGEST

# ============================================================== 2. fzf ====
# Ctrl-R  fuzzy history search       Ctrl-T  fuzzy file picker
# Alt-C   fuzzy cd
if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="
      --height=60% --layout=reverse --border=rounded --info=inline
      --prompt='❯ ' --pointer='▶' --marker='✓'
      --color=fg:#cdd6f4,bg:-1,hl:#f38ba8
      --color=fg+:#cdd6f4,bg+:#313244,hl+:#f38ba8
      --color=info:#cba6f7,prompt:#89b4fa,pointer:#f5c2e7
      --color=marker:#a6e3a1,spinner:#f5e0dc,header:#94e2d5
      --color=border:#6c7086
      --bind='ctrl-/:toggle-preview,ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'
      --bind='ctrl-y:execute-silent(printf {} | pbcopy 2>/dev/null || printf {} | xclip -selection clipboard 2>/dev/null)'
    "
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
    if command -v bat >/dev/null 2>&1; then
        export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :300 {}'"
    else
        export FZF_CTRL_T_OPTS="--preview 'head -300 {}'"
    fi
    # Show full multi-line commands and the timestamp in Ctrl-R.
    export FZF_CTRL_R_OPTS="--preview 'printf %s {}' --preview-window=down:4:wrap --header='history'"
    export FZF_ALT_C_OPTS="--preview 'ls --color=always {} 2>/dev/null | head -50'"

    # fzf >= 0.48 ships its own bash integration; older packages use example files.
    if fzf --bash >/dev/null 2>&1; then
        eval "$(fzf --bash)"
    else
        for _f in /usr/share/doc/fzf/examples/key-bindings.bash \
                  /usr/share/fzf/key-bindings.bash \
                  "$HOME/.fzf/shell/key-bindings.bash"; do
            [[ -r "$_f" ]] && { . "$_f"; break; }
        done
        for _f in /usr/share/doc/fzf/examples/completion.bash \
                  /usr/share/fzf/completion.bash \
                  "$HOME/.fzf/shell/completion.bash"; do
            [[ -r "$_f" ]] && { . "$_f"; break; }
        done
        unset _f
    fi

    # fh — pick a command out of history. Bound to Alt-H it edits the command
    # line in place; called as a plain function it just prints the choice.
    # The sed strips the history index *and* the HISTTIMEFORMAT timestamp.
    fh() {
        local cmd
        cmd="$(history \
               | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+([0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]+[0-9:]+[[:space:]]+)?//' \
               | awk 'NF && !seen[$0]++' | tac \
               | fzf --no-sort --query="$*" --header='pick a command')" || return
        if [[ -n "${READLINE_LINE+x}" ]]; then
            READLINE_LINE="$cmd"; READLINE_POINT=${#cmd}
        else
            printf '%s\n' "$cmd"
        fi
    }
    bind -x '"\eh": fh' 2>/dev/null      # Alt-H

    # fkill — fuzzy pick a process to kill
    fkill() {
        local pid
        pid="$(ps -eo pid,ppid,pcpu,pmem,comm,args --sort=-pcpu \
               | fzf --header-lines=1 --multi --header='select processes to kill' \
               | awk '{print $1}')" || return
        [[ -n "$pid" ]] && kill "${1:--TERM}" $pid && printf 'killed: %s\n' "$pid"
    }

    # fcd — fuzzy cd anywhere below here
    fcd() {
        local dir
        dir="$( { command -v fd >/dev/null 2>&1 && fd --type d --hidden --exclude .git || \
                  find . -type d -not -path '*/.git/*'; } \
               | fzf --preview 'ls --color=always {} | head -50')" && cd "$dir" || return
    }

    # fgb — fuzzy checkout a git branch
    fgb() {
        local br
        br="$(git branch -a --format='%(refname:short)' | sed 's|^origin/||' | sort -u \
              | fzf --preview 'git log --oneline --graph --color=always -20 {}')" \
            && git switch "$br"
    }
fi

# =========================================================== 3. zoxide ====
# `z <partial>` jumps to the directory you visit most that matches.
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash --cmd z)"
fi

# ============================================================ 4. direnv ====
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"

# ============================================================== 5. misc ====
# Syntax-highlighted `--help` output. Named `hlp` so the `help` builtin
# (help while, help test, …) keeps working.
if command -v bat >/dev/null 2>&1; then
    hlp() { "$@" --help 2>&1 | bat --plain --language=help --paging=never; }
else
    hlp() { "$@" --help 2>&1 | less -FRX; }
fi

# GPG needs to know which terminal is asking for the passphrase.
export GPG_TTY="$(tty 2>/dev/null)"

# ssh-agent: reuse a running one rather than spawning a new agent per shell.
if [[ -z "${SSH_AUTH_SOCK:-}" ]] && command -v ssh-agent >/dev/null 2>&1; then
    _agent_env="${XDG_RUNTIME_DIR:-$HOME/.cache}/ssh-agent.env"
    [[ -r "$_agent_env" ]] && . "$_agent_env" >/dev/null
    if ! kill -0 "${SSH_AGENT_PID:-0}" 2>/dev/null; then
        ssh-agent -s > "$_agent_env" 2>/dev/null && . "$_agent_env" >/dev/null
    fi
    unset _agent_env
fi

# ============================================== 6. extra key bindings ====
# Ctrl-G stays readline's abort; Alt-* is used for our additions.
__jump_git_root() { cd "$(git rev-parse --show-toplevel 2>/dev/null || printf .)" || return; }

bind -x '"\eg": __jump_git_root'            2>/dev/null   # Alt-G  -> repo root
bind '"\C-o": "\C-a\C-k envhelp\C-m"'       2>/dev/null   # Ctrl-O -> cheatsheet
bind '"\e[1;5C": forward-word'              2>/dev/null   # Ctrl-Right
bind '"\e[1;5D": backward-word'             2>/dev/null   # Ctrl-Left
bind '"\C-x\C-e": edit-and-execute-command' 2>/dev/null   # edit the line in $EDITOR
