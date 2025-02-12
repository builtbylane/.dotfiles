# History configuration
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# History options
setopt EXTENDED_HISTORY     # Save timestamps
setopt HIST_VERIFY          # Show history expansion before executing
setopt HIST_IGNORE_ALL_DUPS # Remove older dups if new command is added
setopt HIST_FIND_NO_DUPS    # Don't show dups when searching
setopt HIST_SAVE_NO_DUPS    # Don't save dups
setopt SHARE_HISTORY        # Share history between sessions
# setopt HIST_IGNORE_SPACE    # Don't save commands starting with space

# Directory options
setopt AUTO_NAME_DIRS    # Use named dirs when possible
setopt PUSHD_IGNORE_DUPS # Don't store duplicates in stack
unsetopt AUTO_CD         # Don't cd automatically
unsetopt BEEP            # No beep

# Completion options
setopt COMPLETE_IN_WORD # Complete from both ends of a word
setopt ALWAYS_TO_END    # Move cursor to end after completion
setopt PATH_DIRS        # Perform path search even on command names with slashes
setopt AUTO_LIST        # Automatically list choices on ambiguous completion
setopt AUTO_MENU        # Show completion menu on a successive tab press

# Input/Output options
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
setopt RM_STAR_WAIT         # Wait 10 seconds when doing 'rm *'
setopt EXTENDED_GLOB        # Use extended globbing syntax

# Speed up rbenv initialization
export RBENV_LAZY_LOAD=true

# Mail options
unset MAIL
MAILCHECK=0
