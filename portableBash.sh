# Guard against non-interactive shells
[[ $- != *i* ]] && return

# +---------+
# | Helpers |
# +---------+

# Check if a command exists
_has() { command -v "$1" &>/dev/null; }

# +--------+
# | System |
# +--------+

alias shutdown='sudo shutdown now'
alias restart='sudo reboot'

# +-----+
# | Git |
# +-----+

alias g='git'
alias ga='git add'
alias gc='git commit -m'
alias gst='git status'
alias gco='git checkout'
alias gb='git branch'
alias gpl='git pull'
alias gps='git push'
alias gs='git switch'

# +------+
# | tmux |
# +------+

alias tmuxl='tmux list-sessions'
alias tmuxk='tmux kill-session -t'
alias tmuxa='tmux attach -t'

# +------+
# | Dirs |
# +------+

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'

# +-----+
# | ls / eza |
# +-----+
# Falls back to plain ls if eza is not installed.

if _has eza; then
    alias l='eza -1 --icons --git -a --no-permissions --no-user --no-filesize --sort=extension --group-directories-first'
    alias lt='eza --tree --level=2 --icons --git --no-permissions --no-user --no-filesize --sort=extension'
    alias ltree='eza --tree --level=2 --icons --git --sort=extension'
    alias L='eza -l --icons --git -a --sort=extension --group-directories-first'
    alias Lt='eza --tree --level=2 --long --icons --git -a --sort=extension'
    alias Ltree='eza --tree --level=2 --icons --git -a --sort=extension'
else
    alias l='ls -1A --color=auto --group-directories-first 2>/dev/null || ls -1A'
    alias lt='ls -A --color=auto'
    alias ltree='ls -A --color=auto'
    alias L='ls -lAh --color=auto --group-directories-first 2>/dev/null || ls -lAh'
    alias Lt='ls -lAh --color=auto'
    alias Ltree='ls -lAh --color=auto'
fi

# +-----+
# | bat |
# +-----+
# Handles both 'bat' (Arch/Fedora) and 'batcat' (Debian/Ubuntu) installs.
# Falls back to cat if neither exists.

if _has batcat; then
    alias bat='batcat'
    alias cat='batcat'
elif _has bat; then
    alias cat='bat'
fi

# +---------+
# | kubectl |
# +---------+

if _has kubectl; then
    alias k='kubectl'
fi
if _has kubectx; then
    alias kctx='kubectx'
    alias kc='kubectx'
fi
if _has kubens; then
    alias kns='kubens'
fi
if _has velero; then
    alias v='velero'
fi

# +-------+
# | Shell |
# +-------+

# Sane history defaults
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth   # ignore duplicates and lines starting with space
shopt -s histappend      # append to history file, don't overwrite

#   auto-correct minor typos
shopt -s cdspell 2>/dev/null

# Resize terminal output after window resize
shopt -s checkwinsize

# +--------+
# | Prompt |
# +--------+
# Shows git branch when inside a repo.
_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || \
    branch=$(git rev-parse --short HEAD 2>/dev/null) || return
    printf ' (%s)' "$branch"
}

# Colors (safe for all terminals via tput)
_c_reset=$(tput sgr0 2>/dev/null)
_c_green=$(tput setaf 2 2>/dev/null)
_c_blue=$(tput setaf 4 2>/dev/null)
_c_yellow=$(tput setaf 3 2>/dev/null)
_c_red=$(tput setaf 1 2>/dev/null)

# Use red user@host when root, green otherwise
if [[ $EUID -eq 0 ]]; then
    _c_user=$_c_red
else
    _c_user=$_c_green
fi

PROMPT_COMMAND='printf "%$((COLUMNS-1))s\r"'

PS1='\[${_c_user}\]\u@\h\[${_c_reset}\]:\[${_c_blue}\]\w\[${_c_yellow}\]$(_git_branch)\[${_c_reset}\] \$ '