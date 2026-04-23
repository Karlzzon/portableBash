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

# +------------+
# | Completion |
# +------------+
bind 'set show-all-if-ambiguous on'     # show list immediately instead of beeping
bind 'set completion-ignore-case on'    # case insensitive matching
bind 'set menu-complete-display-prefix on'   # first Tab shows list, second Tab starts cycling
bind 'TAB:menu-complete'                # Tab cycles forward through suggestions
bind '"\e[Z":menu-complete-backward'    # Shift+Tab cycles backward

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

# +-----+
# | Vim |
# +-----+

_setup_vim() {
    local vimrc="$HOME/.vimrc"
    # Don't overwrite an existing vimrc
    [[ -f "$vimrc" ]] && return

    cat > "$vimrc" << 'EOF'
" portable vimrc

" +----------+
" | Defaults |
" +----------+
set nocompatible                " disable vi compatibility mode
set encoding=utf-8              " use utf-8 internally
set backspace=indent,eol,start  " allow backspace over indents, line breaks, and insert start
set updatetime=300              " ms before swap file write and CursorHold triggers

" +---------+
" | Display |
" +---------+
set relativenumber        " show relative distances on all other lines
set cursorline            " highlight the line the cursor is on
set scrolloff=8           " keep at least 8 lines visible above and below the cursor
set wrap                  " visually wrap long lines
set linebreak             " when wrapping, break at word boundaries instead of mid-word

" +---------+
" | Editing |
" +---------+
set tabstop=4             " a tab character visually spans 4 spaces
set shiftwidth=4          " indent/dedent by 4 spaces with >> and 
set expandtab             " insert spaces when Tab is pressed, not a tab character
set smartindent           " auto-indent new lines based on code syntax
set autoindent            " copy indent from current line when starting a new line

" +--------+
" | Search |
" +--------+
set incsearch             " jump to matches as you type the search pattern
set hlsearch              " highlight all matches after search
set ignorecase            " case insensitive search by default
set smartcase             " override ignorecase when the pattern contains uppercase
nnoremap <Esc> :nohlsearch<CR>  " clear search highlights with Esc in normal mode

EOF
}

_setup_vim
