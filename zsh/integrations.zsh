# --------------------------------------------------- integrations.zsh --
# Third-party tools + the key bindings that give you history suggestions.

# ================================================ 1. autosuggestions ====
# Inline *ghost text* from the zsh-autosuggestions plugin (loaded by
# oh-my-zsh — see zsh/zshrc's `plugins=(...)`). The plugin binds Right-arrow
# and End itself; Ctrl-F is added here as a third way to accept it whole.
if (( ${+widgets[autosuggest-accept]} )); then
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245,italic'
    bindkey '^F' autosuggest-accept 2>/dev/null
    MY_ENV_SUGGEST="zsh-autosuggestions (→/End/Ctrl-F accepts)"
else
    MY_ENV_SUGGEST="zsh history search (Up/Down)"
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

    # fzf >= 0.48 ships its own zsh integration; older packages use example files.
    if fzf --zsh >/dev/null 2>&1; then
        source <(fzf --zsh)
    else
        for _f in /usr/share/doc/fzf/examples/key-bindings.zsh \
                  /usr/share/fzf/key-bindings.zsh \
                  "$HOME/.fzf/shell/key-bindings.zsh"; do
            [[ -r "$_f" ]] && { source "$_f"; break; }
        done
        for _f in /usr/share/doc/fzf/examples/completion.zsh \
                  /usr/share/fzf/completion.zsh \
                  "$HOME/.fzf/shell/completion.zsh"; do
            [[ -r "$_f" ]] && { source "$_f"; break; }
        done
        unset _f
    fi

    # fh — pick a command out of history. As a key binding (Alt-H) it edits
    # the command line in place; called as a plain function it just prints
    # the choice. The sed strips fc's leading index column.
    fh() {
        local cmd
        cmd="$(fc -l 1 \
               | sed -E 's/^[[:space:]]*[0-9]+[[:space:]]+//' \
               | awk 'NF && !seen[$0]++' | tac \
               | fzf --no-sort --query="$*" --header='pick a command')" || return
        if [[ -n "$WIDGET" ]]; then
            LBUFFER="$cmd"
        else
            print -r -- "$cmd"
        fi
    }
    zle -N fh 2>/dev/null
    bindkey '^[h' fh 2>/dev/null                  # Alt-H

    # fkill — fuzzy pick a process to kill
    fkill() {
        local pid
        pid="$(ps -eo pid,ppid,pcpu,pmem,comm,args --sort=-pcpu \
               | fzf --header-lines=1 --multi --header='select processes to kill' \
               | awk '{print $1}')" || return
        [[ -n "$pid" ]] && kill "${1:--TERM}" ${(z)pid} && printf 'killed: %s\n' "$pid"
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
    eval "$(zoxide init zsh --cmd z)"
fi

# ============================================================ 4. direnv ====
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# ============================================================== 5. misc ====
# Syntax-highlighted `--help` output. Named `hlp` so the `help` builtin
# keeps working (zsh doesn't have one, but the name still reads best).
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
    [[ -r "$_agent_env" ]] && source "$_agent_env" >/dev/null
    if ! kill -0 "${SSH_AGENT_PID:-0}" 2>/dev/null; then
        ssh-agent -s > "$_agent_env" 2>/dev/null && source "$_agent_env" >/dev/null
    fi
    unset _agent_env
fi

# ============================================== 6. extra key bindings ====
__jump_git_root() {
    cd "$(git rev-parse --show-toplevel 2>/dev/null || print .)" || return
    zle reset-prompt
}
zle -N __jump_git_root 2>/dev/null
bindkey '^[g' __jump_git_root 2>/dev/null         # Alt-G  -> repo root

__cheatsheet_widget() { BUFFER="envhelp"; zle accept-line; }
zle -N __cheatsheet_widget 2>/dev/null
bindkey '^O' __cheatsheet_widget 2>/dev/null      # Ctrl-O -> cheatsheet

bindkey '^[[1;5C' forward-word 2>/dev/null        # Ctrl-Right
bindkey '^[[1;5D' backward-word 2>/dev/null       # Ctrl-Left

autoload -Uz edit-command-line
zle -N edit-command-line 2>/dev/null
bindkey '^X^E' edit-command-line 2>/dev/null      # edit the line in $EDITOR
