# GlobalProtect VPN control functions
# Inspo: https://gist.github.com/kaleksandrov/3cfee92845a403da995e7e44ba771183?permalink_comment_id=5007981#gistcomment-5007981

globalprotect() {
  local usage="Usage: globalprotect|gp {start|stop|connect|status}"

  case "$1" in
    stop)
      echo -e "\033[0;90m→ Stopping GlobalProtect VPN...\033[0m"

      # Kill the GUI app first
      pkill -9 GlobalProtect 2>/dev/null

      # Unload the launch agents
      launchctl bootout gui/$(id -u) /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist > /dev/null 2>&1
      launchctl bootout gui/$(id -u) /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist > /dev/null 2>&1

      # Get any remaining GlobalProtect process IDs from launchctl
      local pids
      pids="$(launchctl list | grep palo | cut -f 1)"

      # Kill the processes only if found
      if [[ -n "$pids" ]]; then
        echo "$pids" | xargs kill -9 2>/dev/null
      fi

      # Kill any remaining PanGPS processes (sometimes lingers)
      pkill -9 PanGPS 2>/dev/null

      echo -e "\033[1;32m✓ GlobalProtect VPN unloaded\033[0m"
      ;;

    start)
      echo -e "\033[0;90m→ Starting GlobalProtect VPN...\033[0m"

      # Clean up any lingering processes first to avoid "another instance" error
      pkill -9 GlobalProtect 2>/dev/null
      pkill -9 PanGPS 2>/dev/null
      pkill -9 PanGPA 2>/dev/null

      launchctl bootout gui/$(id -u) /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist > /dev/null 2>&1
      launchctl bootout gui/$(id -u) /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist > /dev/null 2>&1

      # Longer pause to ensure all processes fully terminate
      sleep 2

      # Start fresh
      launchctl bootstrap gui/$(id -u) /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist 2>/dev/null
      launchctl bootstrap gui/$(id -u) /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist 2>/dev/null

      # Another brief pause before launching the app
      sleep 1

      open -a /Applications/GlobalProtect.app
      echo -e "\033[1;32m✓ GlobalProtect VPN loaded\033[0m"

      # Wait for app to be ready, then auto-connect
      echo -e "\033[0;90m→ Waiting for app to be ready...\033[0m"
      sleep 3

      # Auto-connect
      globalprotect connect
      ;;

    connect)
      echo -e "\033[0;90m→ Connecting to VPN...\033[0m"

      # Click the Connect button via AppleScript
      osascript <<EOF 2>/dev/null
      tell application "System Events"
        tell process "GlobalProtect"
          if not (exists window 1) then
            click menu bar item 1 of menu bar 2
            delay 2
          end if
          set frontmost to true
          tell window 1
            if exists (first button whose title is "Connect") then
              tell (first button whose title is "Connect") to if exists then click
            end if
          end tell
        end tell
      end tell
EOF

      if [[ $? -eq 0 ]]; then
        echo -e "\033[1;32m✓ Connect button clicked\033[0m"
      else
        echo -e "\033[1;31m✗ Failed to click Connect button\033[0m"
        return 1
      fi
      ;;

    status)
      echo -e "\033[0;90m→ Checking GlobalProtect status...\033[0m"
      local running_agents
      running_agents=$(launchctl list | grep palo | wc -l | tr -d ' ')

      if [[ $running_agents -gt 0 ]]; then
        echo -e "\033[1;32m✓ GlobalProtect is running ($running_agents agent(s))\033[0m"
        launchctl list | grep palo
      else
        echo -e "\033[1;31m✗ GlobalProtect is not running\033[0m"
      fi
      ;;

    *)
      echo "$usage" >&2
      return 1
      ;;
  esac
}

# Shortcut alias
alias gp='globalprotect'
