# -------------------------------------------------------------- aliases.zsh --

# --- listing ------------------------------------------------------------
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -lg --group-directories-first --icons=auto --git --time-style=long-iso'
    alias la='eza -lag --group-directories-first --icons=auto --git'
    alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
    alias ltt='eza --tree --level=4 --icons=auto --group-directories-first'
    alias lsize='eza -lg --sort=size --reverse --icons=auto'
    alias lnew='eza -lg --sort=modified --reverse --icons=auto'
else
    alias ls='ls --color=auto --group-directories-first -h'
    alias ll='ls -lh --color=auto --group-directories-first'
    alias la='ls -lAh --color=auto --group-directories-first'
    alias lt='tree -L 2 -C'
    alias ltt='tree -L 4 -C'
    alias lsize='ls -lhS --color=auto'
    alias lnew='ls -lht --color=auto'
fi
alias l='ll'

# --- colour by default --------------------------------------------------
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'
alias dmesg='dmesg --color=always --human'

# --- navigation ---------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'
alias cd..='cd ..'
alias d='dirs -v | head -10'
alias md='mkdir -pv'

# --- safety nets --------------------------------------------------------
alias rm='rm -I --preserve-root'      # confirm once when removing >3 files
alias cp='cp -i'
alias mv='mv -i'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# --- editor -------------------------------------------------------------
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias sv='sudoedit'
alias nv='nvim'
alias vconf='nvim "$MY_ENV_ROOT/nvim/init.lua"'
alias zconf='nvim "$MY_ENV_ROOT/zsh/"'
alias reload='exec zsh'

# --- git ----------------------------------------------------------------
alias g='git'
alias gs='git status -sb'
alias gst='git status'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gc='git commit -v'
alias gca='git commit -v --amend'
alias gcm='git commit -m'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gb='git branch -vv'
alias gd='git diff'
alias gds='git diff --staged'
alias gdt='git difftool'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase --autostash'
alias gf='git fetch --all --prune'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all -30'
alias glp='git log -p'
alias gsh='git show'
alias gstash='git stash push -u'
alias gpop='git stash pop'
alias grh='git reset --hard'
alias grs='git restore --staged'
alias gclean='git clean -fdx -n'      # dry run by default; add -f yourself
alias gbl='git blame -w -C -C -C'
alias groot='cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"'

# --- build (C/C++) ------------------------------------------------------
alias m='make'
alias mj='make -j"$(nproc)"'
alias mc='make clean'
alias mt='make test'
alias cm='cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
alias cmd='cmake -S . -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
alias cmr='cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_EXPORT_COMPILE_COMMANDS=ON'
alias cb='cmake --build build -j"$(nproc)"'
alias ct='ctest --test-dir build --output-on-failure'
alias cmclean='rm -rf build'

# --- system -------------------------------------------------------------
alias df='df -hT -x tmpfs -x devtmpfs'
alias du='du -h'
alias free='free -h'
alias psg='ps aux | grep -v grep | grep -i'
alias ports='ss -tulpn'
alias myip='curl -fsS ifconfig.me; echo'
alias path='printf "%s\n" ${PATH//:/ }'
alias now='date "+%F %T %Z"'
alias week='date +%V'
alias mnt='mount | column -t'
alias hgs='history | grep'

# --- misc ---------------------------------------------------------------
alias c='clear'
alias q='exit'
alias h='history'
alias j='jobs -l'
alias sudo='sudo '                # lets sudo expand the alias after it
alias watch='watch --color '
alias wget='wget -c'
alias curltime='curl -w "\ntime_total: %{time_total}s\n" -o /dev/null -s'
alias serve='python3 -m http.server 8000'
alias ports_listen='ss -ltnp'
command -v bat  >/dev/null 2>&1 && alias cat='bat --paging=never'
command -v bat  >/dev/null 2>&1 && alias catp='bat'
command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1 && alias fd='fdfind'
command -v duf  >/dev/null 2>&1 && alias df='duf'
command -v btop >/dev/null 2>&1 && alias top='btop'
command -v htop >/dev/null 2>&1 && alias htop='htop -t'

# --- the cheatsheet -----------------------------------------------------
alias envhelp='"$MY_ENV_ROOT/bin/envhelp"'
alias cheat='envhelp'
