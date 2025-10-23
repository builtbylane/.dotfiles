# This is the main configuration file for Zsh shell. It's responsible for:
# 1. Plugin management through Zinit
# 2. Shell options and behavior configuration
# 3. Theme configuration (Powerlevel10k)
# 4. Integration with various development tools
# 5. Loading additional configuration files
#
# Note: The load order is important! Some features depend on others being loaded first.
# Initialize Zinit package manager
# Zinit is a flexible and fast plugin manager for Zsh
source "${HOME}/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
[[ -v _comps ]] && _comps[zinit]=_zinit # Completions for zinit

# Restore directory after reload if RELOAD_DIR is set
if [[ -n $RELOAD_DIR ]]; then
  cd "$RELOAD_DIR" || return 1
fi

# Load Zinit annexes for extended functionality
# These provide additional features like:
# - Binary downloads and compilation
# - Monitoring for changes
# - Patch applying capabilities
# - Rust binaries management
zinit light-mode for \
  zdharma-continuum/zinit-annex-as-monitor \
  zdharma-continuum/zinit-annex-bin-gem-node \
  zdharma-continuum/zinit-annex-patch-dl \
  zdharma-continuum/zinit-annex-rust

# Enable Powerlevel10k instant prompt
# This dramatically speeds up shell startup time by showing a prompt before
# other initialization is complete
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USERNAME}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${USERNAME}.zsh"
fi

# Load Powerlevel10k theme
# Using ice depth=1 to limit clone depth for faster installation
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Cleanup potential zi command conflicts
# This prevents naming conflicts with other commands
disable -f zi 2>/dev/null
unalias zi 2>/dev/null

# Load core plugins with optimizations
# These plugins provide:
# - Syntax highlighting
# - Command suggestions based on history
# - Enhanced completions
# Using 'wait lucid' for async loading to improve startup time
zinit wait lucid for \
  atinit"zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
  zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
  zsh-users/zsh-completions

# Load custom configurations and functions
# This loads all .zsh files from the config and functions directories
for config_file in ${HOME}/.dotfiles/zsh/config/*.zsh; do
  source $config_file
done

# Load private environment variables if they exist
# Fix for source commands in .zshrc:
if [[ -f "${HOME}/.private_env.zsh" ]]; then
  source "${HOME}/.private_env.zsh"
fi

# Load custom functions
for function_file in ${HOME}/.dotfiles/zsh/functions/*.zsh; do
  source $function_file
done

# Setup FZF integration
# FZF provides fuzzy finding capabilities for files, history, and more
zinit ice from"gh-r" as"program"
zinit light junegunn/fzf
zinit light Aloxaf/fzf-tab

# Initialize modern development tools
# zoxide: A smarter cd command that learns your habits
# fnm: Fast Node.js version manager
eval "$(zoxide init zsh)"
eval "$(fnm env --use-on-cd)"

# Set default editor
export EDITOR="code"

# Load Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Initialize rbenv if present
# rbenv manages Ruby versions
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init - zsh)"
fi

# Load FZF configuration if present
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# TODO: Uncomment to enable starship prompt
# Starship is a fast, customizable cross-shell prompt, it's just not as feature-rich as Powerlevel10k
# eval "$(starship init zsh)"

# Bun completions
[ -s "${HOME}/.bun/_bun" ] && source "${HOME}/.bun/_bun"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
