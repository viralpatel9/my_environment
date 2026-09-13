# -------------------------------------------------------------- options.zsh --
# Shell behaviour: navigation, globbing, safety, completion.
# (oh-my-zsh's own defaults already cover a lot of this; only the deltas
# my_environment cares about are set explicitly here.)

# --- navigation ---------------------------------------------------------
setopt auto_cd            # `..` or `/tmp` alone changes directory
setopt cdable_vars        # `cd varname` works if varname holds a path
setopt correct            # offer a fix for small command-name typos
CDPATH=".:$HOME:$HOME/git-repo:$HOME/projects"

# --- globbing -------------------------------------------------------------
setopt extended_glob      # !(x) @(a|b) <1-9> patterns, ~ exclusion
setopt no_case_glob       # case-insensitive globbing
unsetopt nomatch          # unmatched globs stay literal instead of erroring
# glob_dots is deliberately OFF (the zsh default): `rm *` must not reach
# dotfiles. `**` recursive globbing needs no option — zsh always has it.

# --- windows / jobs -----------------------------------------------------
setopt check_jobs         # warn before exiting with running jobs
setopt hup                # don't leak background jobs when the shell dies
setopt notify             # report finished background jobs immediately

# Disable Ctrl-S terminal freeze; frees it up for forward history search.
stty -ixon 2>/dev/null

# --- completion -----------------------------------------------------------
# oh-my-zsh already ran compinit by the time this loads (see zsh/zshrc); just
# add style refinements — these apply fine whether set before or after it.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:warnings' format 'no matches for: %d'
zstyle ':completion:*' list-prompt '%SAt %p: TAB for more, or type a char%s'
zstyle ':completion:*' squeeze-slashes true
