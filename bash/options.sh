# -------------------------------------------------------------- options.sh --
# Shell behaviour: navigation, globbing, safety, completion.

# --- navigation ---------------------------------------------------------
shopt -s autocd         # `..` or `/tmp` alone changes directory
shopt -s cdspell        # fix small typos in cd targets
shopt -s dirspell       # ...and in directory names during completion
CDPATH=".:$HOME:$HOME/git-repo:$HOME/projects"
shopt -s cdable_vars

# --- globbing -----------------------------------------------------------
shopt -s globstar       # ** matches across directories
shopt -s extglob        # !(x) @(a|b) +(x) patterns
shopt -s nocaseglob     # case-insensitive globbing
shopt -u dotglob        # deliberately OFF: `rm *` must not reach dotfiles
shopt -u failglob       # unmatched globs stay literal instead of erroring

# --- windows / jobs -----------------------------------------------------
shopt -s checkwinsize   # keep $LINES/$COLUMNS correct after a resize
shopt -s checkjobs      # warn before exiting with running jobs
shopt -s huponexit      # don't leak background jobs when the shell dies
set -o notify           # report finished background jobs immediately

# --- safety -------------------------------------------------------------
shopt -s no_empty_cmd_completion   # don't scan $PATH on an empty TAB
# Opt-in in ~/.bashrc.local if you want `>` to refuse to truncate (use >| to force):
#   set -o noclobber

# Disable Ctrl-S terminal freeze; frees it up for forward history search.
stty -ixon 2>/dev/null

# --- completion ---------------------------------------------------------
bind 'set completion-ignore-case on'        2>/dev/null
bind 'set completion-map-case on'           2>/dev/null
bind 'set show-all-if-ambiguous on'         2>/dev/null
bind 'set menu-complete-display-prefix on'  2>/dev/null
bind 'set colored-stats on'                 2>/dev/null
bind 'set colored-completion-prefix on'     2>/dev/null
bind 'set visible-stats on'                 2>/dev/null
bind 'set mark-symlinked-directories on'    2>/dev/null
bind 'set page-completions off'             2>/dev/null
bind 'set completion-query-items 200'       2>/dev/null

# Load the system completion library once.
if ! shopt -oq posix; then
    if [[ -r /usr/share/bash-completion/bash_completion ]]; then
        . /usr/share/bash-completion/bash_completion
    elif [[ -r /etc/bash_completion ]]; then
        . /etc/bash_completion
    fi
fi

# Extra completions dropped into the repo.
if [[ -d "$MY_ENV_ROOT/completions" ]]; then
    for _c in "$MY_ENV_ROOT"/completions/*.bash; do
        [[ -r "$_c" ]] && . "$_c"
    done
    unset _c
fi
