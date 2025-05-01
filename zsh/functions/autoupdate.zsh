# Auto-updater for dotfiles repository
# Checks if there are updates to the dotfiles repository and prompts the user to update

LAST_UPDATE_CHECK_FILE="$HOME/.dotfiles/.last_update_check"
UPDATE_CHECK_INTERVAL=86400  # Check once a day (in seconds)

check_dotfiles_update() {
  # Skip if not in a terminal or if we've checked recently
  [[ ! -t 1 ]] && return 0
  
  # Create the update check file if it doesn't exist
  if [[ ! -f "$LAST_UPDATE_CHECK_FILE" ]]; then
    date +%s > "$LAST_UPDATE_CHECK_FILE"
    return 0
  fi
  
  # Check if we need to run the update check based on the interval
  local last_check
  last_check=$(<"$LAST_UPDATE_CHECK_FILE")
  local current_time
  current_time=$(date +%s)
  local time_diff=$((current_time - last_check))
  
  if [[ $time_diff -lt $UPDATE_CHECK_INTERVAL ]]; then
    return 0
  fi
  
  # Update the last check time
  echo "$current_time" > "$LAST_UPDATE_CHECK_FILE"
  
  # Check for updates
  (
    cd "$HOME/.dotfiles" || return 1
    
    # Fetch updates but don't apply them
    git fetch origin --quiet 2>/dev/null
    
    # Check if we're behind the remote
    local commits_behind
    commits_behind=$(git rev-list --count HEAD..origin/main 2>/dev/null)
    
    if [[ $commits_behind -gt 0 ]]; then
      # Get the latest commit message to show the user
      local latest_commit
      latest_commit=$(git log -1 --pretty=format:"%h: %s" origin/main 2>/dev/null)
      
      # Only output to terminal if we have updates
      {
        echo ""
        echo -e "\033[1;33m→ Hey buddy, there's been an update to your dotfiles!\033[0m"
        echo -e "\033[1;36m→ $commits_behind new commit(s) available\033[0m"
        echo -e "\033[1;32m→ Latest: $latest_commit\033[0m"
        echo ""
        echo -e "\033[1;37mWould you like to update now? (y/N)\033[0m"
        
        read -r choice
        if [[ $choice =~ ^[Yy]$ ]]; then
          echo -e "\033[1;34m→ Updating dotfiles...\033[0m"
          git pull --rebase --autostash
          
          # Run the install script to ensure everything is up to date
          "$HOME/.dotfiles/install.sh"
          
          echo -e "\033[1;32m✓ Dotfiles updated successfully!\033[0m"
          echo -e "\033[1;33m→ You might want to restart your terminal for all changes to take effect.\033[0m"
        else
          echo -e "\033[1;33m→ No problem! I'll remind you later.\033[0m"
        fi
      }
    fi
  ) &
}

# Add a function to manually check for updates
update-dotfiles() {
  echo -e "\033[1;34m→ Checking for dotfiles updates...\033[0m"
  
  # Make sure dotfiles directory exists
  if [[ ! -d "$HOME/.dotfiles" ]]; then
    echo -e "\033[1;31m✘ Dotfiles directory not found at $HOME/.dotfiles\033[0m"
    return 1
  fi
  
  # Check if it's a git repository
  if [[ ! -d "$HOME/.dotfiles/.git" ]]; then
    echo -e "\033[1;31m✘ Not a git repository. Please reinstall dotfiles.\033[0m"
    return 1
  fi
  
  (
    cd "$HOME/.dotfiles" || { echo -e "\033[1;31m✘ Failed to access dotfiles repository\033[0m"; return 1; }
    
    # Fetch updates
    if ! git fetch origin; then
      echo -e "\033[1;31m✘ Failed to fetch updates. Check your internet connection.\033[0m"
      return 1
    fi
    
    # Check if we're behind the remote
    local commits_behind
    commits_behind=$(git rev-list --count HEAD..origin/main 2>/dev/null)
    
    if [[ $commits_behind -eq 0 ]]; then
      echo -e "\033[1;32m✓ Already up to date!\033[0m"
      return 0
    fi
    
    # Show what's new
    echo -e "\033[1;36m→ $commits_behind new commit(s) available:\033[0m"
    git log --color --pretty=format:"%C(yellow)%h%Creset %C(cyan)%ar%Creset → %s" HEAD..origin/main
    echo ""
    
    echo -e "\033[1;37mDo you want to update now? (y/N)\033[0m"
    read -r choice
    
    if [[ $choice =~ ^[Yy]$ ]]; then
      echo -e "\033[1;34m→ Updating dotfiles...\033[0m"
      
      # Create a backup of the last update check file
      if [[ -f "$LAST_UPDATE_CHECK_FILE" ]]; then
        cp "$LAST_UPDATE_CHECK_FILE" "${LAST_UPDATE_CHECK_FILE}.backup"
      fi
      
      # Try to pull changes
      if ! git pull --rebase --autostash; then
        echo -e "\033[1;31m✘ Failed to update dotfiles. There might be conflicts.\033[0m"
        echo -e "\033[1;33m→ You can try manually by running:\033[0m"
        echo -e "  cd $HOME/.dotfiles"
        echo -e "  git pull --rebase --autostash"
        return 1
      fi
      
      # Run the install script to apply any changes
      if [[ -x "$HOME/.dotfiles/install.sh" ]]; then
        echo -e "\033[1;34m→ Running install script...\033[0m"
        if ! "$HOME/.dotfiles/install.sh"; then
          echo -e "\033[1;31m✘ Install script failed. You may need to run it manually:\033[0m"
          echo -e "  cd $HOME/.dotfiles"
          echo -e "  ./install.sh"
          return 1
        fi
      else
        echo -e "\033[1;31m✘ Install script not found or not executable.\033[0m"
        return 1
      fi
      
      echo -e "\033[1;32m✓ Dotfiles updated successfully!\033[0m"
      echo -e "\033[1;33m→ You might want to restart your terminal for all changes to take effect.\033[0m"
    else
      echo -e "\033[1;33m→ Update cancelled. Run 'update-dotfiles' any time to update.\033[0m"
    fi
  )
}

# Add the update check to happen at shell startup (it runs in the background)
check_dotfiles_update