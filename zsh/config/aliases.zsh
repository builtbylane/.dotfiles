# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"

# Modern replacement tools
alias ls="eza --icons --hyperlink --git --git-repos --header"
alias l="eza -l --icons --hyperlink --git --git-repos --header"
alias la="eza -la --icons --hyperlink --git --git-repos --header"
alias lt="eza --tree --level=2 --icons"  # Tree view, 2 levels deep
alias ltt="eza --tree --level=3 --icons" # Tree view, 3 levels deep
alias cat="bat"
alias find="fd"
alias grep="rg"

# Function aliases
alias cl=copy_last_commit_message_to_clipboard

# Enhanced zoxide aliases and functions (see zsh/functions/navigation.zsh for more)
alias za="zoxide add"    # Add directory
alias zr="zoxide remove" # Remove directory

# Development
alias c="code ."

# Git
alias g="git"
alias gopen='git_open_repo'
alias gpr='git_open_pr'
alias gclonecd='git_clone_cd'
alias gclean='cleanup_branches'

# Node.js
alias ts='tsx --env-file=.env'

# Node Package manager run commands
alias r="npm run"
alias yr="yarn run"
alias br="bun run"
alias pr="pnpm run"

# System
alias reload='RELOAD_DIR="$PWD"; exec zsh -l'
alias dot="code ~/.dotfiles" # Edit dotfiles

# Network utilities
alias ip="curl -s https://api.ipify.org"
alias ip6="curl -s https://api64.ipify.org"
alias localip="ipconfig getifaddr en0"
alias serve="python3 -m http.server 8000 --bind 127.0.0.1"

# JSON/YAML tools
alias pretty-json="jq '.'"
alias pretty-yaml="yq '.'"

# Safety first
alias mv="mv -iv"
alias cp="cp -iv"

# Search
alias ff='fd --type f --hidden --exclude .git | fzf' # Fuzzy find files
alias fh='history | fzf'                             # Fuzzy search history
alias fps='ps aux | fzf'                             # Fuzzy search processes

# Tree with hidden files but exclude .git
alias tree-all='tree -a -I ".git"'
