# --------------------------------------------------------------- prompt.sh --
# A fast, dependency-free, git-aware two-line prompt.
#
#   ╭─ user@host  ~/git-repo/project   main ✚2 ●1 ⇡1   ⚙ Debug  1.2s
#   ╰─❯
#
# Set MY_ENV_PROMPT=starship in ~/.bashrc.local to use starship instead.
# Set MY_ENV_ASCII=1 if your terminal has no Nerd Font.

# --- starship escape hatch ---------------------------------------------
if [[ "${MY_ENV_PROMPT:-}" == "starship" ]] && command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
    return 0 2>/dev/null || true
fi

# --- glyphs -------------------------------------------------------------
# The Nerd Font ones are written as $'\uXXXX' escapes rather than pasted
# literals so they survive copying this file around.
#   e0a0 = powerline branch   f07b = folder   f017 = clock
if [[ "${MY_ENV_ASCII:-0}" == 1 ]]; then
    _g_top='+-' _g_bot='\-' _g_prompt='$' _g_err='x'
    _g_branch='' _g_dir='' _g_clock='' _g_box='[c]'
    _g_ahead='^' _g_behind='v' _g_dirty='*' _g_staged='+' _g_untracked='?'
else
    _g_top='╭─' _g_bot='╰─' _g_prompt='❯' _g_err='✗'
    _g_branch=$' ' _g_dir=$' ' _g_clock=$'' _g_box='▢'
    _g_ahead='⇡' _g_behind='⇣' _g_dirty='●' _g_staged='✚' _g_untracked='…'
fi
_g_ssh='ssh'   # a word reads better here than any icon

# --- colour shorthands (prompt-safe, \[ \] wrapped) ---------------------
_P_RST='\[\033[0m\]'   ; _P_BLD='\[\033[1m\]'  ; _P_DIM='\[\033[2m\]'
_P_RED='\[\033[38;5;211m\]'   ; _P_GRN='\[\033[38;5;150m\]'
_P_YEL='\[\033[38;5;223m\]'   ; _P_BLU='\[\033[38;5;111m\]'
_P_MAU='\[\033[38;5;183m\]'   ; _P_TEA='\[\033[38;5;115m\]'
_P_PCH='\[\033[38;5;216m\]'   ; _P_GRY='\[\033[38;5;245m\]'

# --- command timing -----------------------------------------------------
# The DEBUG trap fires for every simple command, including the ones inside
# PROMPT_COMMAND. __timer_armed makes sure only the *first* command after a
# prompt starts the clock, so sitting idle at the prompt is never counted.
__timer_start() {
    [[ -n "${__timer_armed:-}" ]] && return
    __timer_armed=1
    __timer_t0=$SECONDS
}
__timer_stop() {
    __timer_show=""
    [[ -n "${__timer_armed:-}" ]] || return
    local elapsed=$(( SECONDS - __timer_t0 ))
    (( elapsed < 3 )) && return          # don't clutter the prompt with fast commands
    if   (( elapsed < 60 ));   then __timer_show="${elapsed}s"
    elif (( elapsed < 3600 )); then __timer_show="$(( elapsed / 60 ))m$(( elapsed % 60 ))s"
    else                            __timer_show="$(( elapsed / 3600 ))h$(( elapsed % 3600 / 60 ))m"
    fi
}
# Runs as the LAST element of PROMPT_COMMAND, so nothing else can re-arm it.
__timer_reset() { unset __timer_armed __timer_t0; }
trap '__timer_start' DEBUG

# --- git status (single porcelain call, no forks per field) -------------
__git_segment() {
    local out branch ahead=0 behind=0 staged=0 dirty=0 untracked=0 conflict=0 line
    out="$(git --no-optional-locks status --porcelain=v2 --branch --untracked-files=normal 2>/dev/null)" || return

    while IFS= read -r line; do
        case "$line" in
            '# branch.head '*) branch="${line#\# branch.head }" ;;
            '# branch.ab '*)
                local ab="${line#\# branch.ab }"
                ahead="${ab%% *}"; ahead="${ahead#+}"
                behind="${ab##* }"; behind="${behind#-}"
                ;;
            '1 '*|'2 '*)
                local xy="${line:2:2}"
                [[ "${xy:0:1}" != "." ]] && (( staged++ ))
                [[ "${xy:1:1}" != "." ]] && (( dirty++ ))
                ;;
            'u '*) (( conflict++ )) ;;
            '? '*) (( untracked++ )) ;;
        esac
    done <<< "$out"

    [[ -z "$branch" ]] && branch="$(git rev-parse --short HEAD 2>/dev/null):detached"
    [[ "$branch" == "(detached)" ]] && branch="${_g_dirty}detached"

    local colour="$_P_GRN"
    (( dirty || untracked )) && colour="$_P_YEL"
    (( conflict ))           && colour="$_P_RED"

    local s=" ${_P_DIM}on${_P_RST} ${colour}${_g_branch}${branch}${_P_RST}"
    (( staged ))    && s+=" ${_P_GRN}${_g_staged}${staged}${_P_RST}"
    (( dirty ))     && s+=" ${_P_YEL}${_g_dirty}${dirty}${_P_RST}"
    (( untracked )) && s+=" ${_P_GRY}${_g_untracked}${untracked}${_P_RST}"
    (( conflict ))  && s+=" ${_P_RED}${_g_err}${conflict}${_P_RST}"
    (( ahead ))     && s+=" ${_P_MAU}${_g_ahead}${ahead}${_P_RST}"
    (( behind ))    && s+=" ${_P_MAU}${_g_behind}${behind}${_P_RST}"
    printf '%s' "$s"
}

# --- context segments ---------------------------------------------------
__ctx_segment() {
    local s=""
    # python virtualenv
    [[ -n "${VIRTUAL_ENV:-}" ]] && s+=" ${_P_TEA}(${VIRTUAL_ENV##*/})${_P_RST}"
    [[ -n "${CONDA_DEFAULT_ENV:-}" ]] && s+=" ${_P_TEA}(${CONDA_DEFAULT_ENV})${_P_RST}"
    # cmake build type, if a build dir is configured here
    if [[ -r ./build/CMakeCache.txt ]]; then
        local bt
        bt="$(sed -n 's/^CMAKE_BUILD_TYPE:STRING=\(.*\)/\1/p' ./build/CMakeCache.txt 2>/dev/null)"
        [[ -n "$bt" ]] && s+=" ${_P_PCH}⚙ ${bt}${_P_RST}"
    fi
    # active toolbox/container
    [[ -r /run/.containerenv || -r /.dockerenv ]] && s+=" ${_P_BLU}${_g_box}${_P_RST}"
    printf '%s' "$s"
}

# --- assemble -----------------------------------------------------------
__set_prompt() {
    local exit_code=$?
    __timer_stop

    # status glyph reflects the last command
    local status_seg
    if (( exit_code == 0 )); then
        status_seg="${_P_GRN}${_g_prompt}${_P_RST}"
    else
        status_seg="${_P_RED}${_g_prompt}${_P_RST}"
    fi

    # user@host — highlighted when root or over ssh
    local userhost
    if (( EUID == 0 )); then
        userhost="${_P_RED}${_P_BLD}\u${_P_RST}${_P_DIM}@${_P_RST}${_P_RED}\h${_P_RST}"
    elif [[ -n "${SSH_CONNECTION:-}${SSH_TTY:-}" ]]; then
        userhost="${_P_PCH}${_g_ssh} \u${_P_RST}${_P_DIM}@${_P_RST}${_P_PCH}\h${_P_RST}"
    else
        userhost="${_P_MAU}\u${_P_RST}${_P_DIM}@${_P_RST}${_P_MAU}\h${_P_RST}"
    fi

    local right=""
    (( exit_code != 0 )) && right+=" ${_P_RED}${_g_err} ${exit_code}${_P_RST}"
    [[ -n "${__timer_show:-}" ]] && right+=" ${_P_YEL}${_g_clock} ${__timer_show}${_P_RST}"
    local jobs_n; jobs_n=$(jobs -p | wc -l)
    (( jobs_n )) && right+=" ${_P_BLU}⚙${jobs_n}${_P_RST}"

    PS1="\n${_P_GRY}${_g_top}${_P_RST} ${userhost} ${_P_BLU}${_P_BLD}${_g_dir}\w${_P_RST}"
    PS1+="$(__git_segment)$(__ctx_segment)${right}"
    PS1+="\n${_P_GRY}${_g_bot}${_P_RST}${status_seg} "

    PS2="${_P_GRY}  ${_g_bot}${_P_RST} "

    # terminal title: user@host + cwd
    printf '\033]0;%s: %s\007' "${USER}@${HOSTNAME}" "${PWD/#$HOME/\~}"
}

# PS4 is not a prompt string — \[ \] would be printed literally, so use raw
# escapes here. Shown by `set -x` while debugging scripts.
PS4=$'\033[2m+ ${BASH_SOURCE##*/}:${LINENO}:\033[0m '

# __set_prompt first (it must see the real $?), __timer_reset strictly last.
case ";${PROMPT_COMMAND:-};" in
    *";__set_prompt;"*) ;;
    *) PROMPT_COMMAND="__set_prompt;${PROMPT_COMMAND:-}__timer_reset;" ;;
esac
