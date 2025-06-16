wifi-password() {
  # Check if running on macOS
  if [[ "$(uname)" != "Darwin" ]]; then
    print -P "%F{red}Error:%f This function only works on macOS."
    return 1
  fi

  local ssid=""

  # Method 1: Try using newer /usr/sbin/airport command (available on M1 Macs)
  if [ -z "$ssid" ]; then
    print -P "%F{blue}Detecting current Wi-Fi network...%f"
    if [ -x "/usr/sbin/airport" ]; then
      ssid=$(/usr/sbin/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
    else
      # Fallback to the older path
      ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk -F': ' '/^[[:space:]]*SSID/ {print $2}')
    fi
  fi

  # Method 2: Try using networksetup with more reliable parsing
  if [ -z "$ssid" ]; then
    local wifi_device
    wifi_device=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')
    if [ -n "$wifi_device" ]; then
      ssid=$(networksetup -getairportnetwork "$wifi_device" 2>/dev/null | awk -F": " '{print $NF}')
    fi
  fi

  # Method 3: Try using defaults command to read Wi-Fi preferences
  if [ -z "$ssid" ]; then
    ssid=$(defaults read /Library/Preferences/SystemConfiguration/com.apple.airport.preferences 2>/dev/null | grep -A 1 "LastConnected" | grep "SSIDString" | cut -d '"' -f 2)
  fi

  # If automatic detection failed, prompt for manual input
  if [ -z "$ssid" ]; then
    print -P "%F{yellow}Could not automatically detect a valid Wi-Fi network.%f"
    print -nP "%F{blue}Enter the Wi-Fi network name (SSID):%f "
    read -r ssid
  else
    # Before confirming, validate that it's not an error message
    if [[ "$ssid" == *"not associated"* || "$ssid" == *"No network"* ]]; then
      print -P "%F{yellow}You don't appear to be connected to a Wi-Fi network.%f"
      print -nP "%F{blue}Enter the Wi-Fi network name (SSID):%f "
      read -r ssid
    else
      print -P "%F{green}Detected Wi-Fi network:%f %F{blue}$ssid%f"
      # Confirm the detected network or allow changing it
      print -nP "%F{blue}Is this the correct network? [Y/n] (or enter a different network name):%f "
      read -r confirm
      if [[ "$confirm" =~ ^[Nn].* ]]; then
        print -nP "%F{blue}Enter the Wi-Fi network name (SSID):%f "
        read -r ssid
      elif [[ -n "$confirm" && "$confirm" != "Y" && "$confirm" != "y" ]]; then
        # User entered a different network name
        ssid="$confirm"
      fi
    fi
  fi

  if [ -z "$ssid" ]; then
    print -P "%F{red}No SSID provided. Exiting.%f"
    return 1
  fi

  print -P "\n%F{blue}Looking up password for network:%f %F{blue}$ssid%f"

  # Try to get the password from Keychain
  local password
  password=$(security find-generic-password -D "AirPort network password" -a "$ssid" -w 2>/dev/null)

  # Try alternative keychain search if the first one fails
  if [ -z "$password" ]; then
    password=$(security find-generic-password -l "$ssid" -w 2>/dev/null)
  fi

  if [ -z "$password" ]; then
    print -P "\n%F{red}Could not find saved password for \"$ssid\".%f"
    print -P "%F{yellow}Possible reasons:%f"
    print -P "  - Password not saved in Keychain"
    print -P "  - Network uses enterprise authentication"
    print -P "  - Network name was misspelled"
    return 1
  else
    # Copy password to clipboard
    echo -n "$password" | pbcopy
    print -P "\n%F{green}Password:%f $password"
    print -P "%F{green}Password copied to clipboard%f"
  fi
}
