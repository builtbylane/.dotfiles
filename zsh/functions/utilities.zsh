wifi-password() {
  # Check if running on macOS
  if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This function only works on macOS."
    return 1
  fi

  local ssid=""

  # Method 1: Try using newer /usr/sbin/airport command (available on M1 Macs)
  if [ -z "$ssid" ]; then
    echo "Trying to detect current Wi-Fi network..."
    if [ -x "/usr/sbin/airport" ]; then
      ssid=$(/usr/sbin/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')
    else
      # Fallback to the older path
      ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk -F': ' '/^[[:space:]]*SSID/ {print $2}')
    fi
  fi

  # Method 2: Try using networksetup with more reliable parsing
  if [ -z "$ssid" ]; then
    echo "Trying alternative detection method..."
    local wifi_device
    wifi_device=$(networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}')
    if [ -n "$wifi_device" ]; then
      ssid=$(networksetup -getairportnetwork "$wifi_device" 2>/dev/null | awk -F": " '{print $NF}')
    fi
  fi

  # Method 3: Try using defaults command to read Wi-Fi preferences
  if [ -z "$ssid" ]; then
    echo "Trying system preferences detection..."
    ssid=$(defaults read /Library/Preferences/SystemConfiguration/com.apple.airport.preferences 2>/dev/null | grep -A 1 "LastConnected" | grep "SSIDString" | cut -d '"' -f 2)
  fi

  # If automatic detection failed, prompt for manual input
  if [ -z "$ssid" ]; then
    echo "Could not automatically detect a valid Wi-Fi network."
    read -r "ssid?Enter the Wi-Fi network name (SSID): "
  else
    # Before confirming, validate that it's not an error message
    if [[ "$ssid" == *"not associated"* || "$ssid" == *"No network"* ]]; then
      echo "You don't appear to be connected to a Wi-Fi network."
      read -r "ssid?Enter the Wi-Fi network name (SSID): "
    else
      echo "Detected Wi-Fi network: $ssid"
      # Confirm the detected network or allow changing it
      read -r "confirm?Is this the correct network? [Y/n] (or enter a different network name): "
      if [[ "$confirm" =~ ^[Nn].* ]]; then
        read -r "ssid?Enter the Wi-Fi network name (SSID): "
      elif [[ -n "$confirm" && "$confirm" != "Y" && "$confirm" != "y" ]]; then
        # User entered a different network name
        ssid="$confirm"
      fi
    fi
  fi

  if [ -z "$ssid" ]; then
    echo "No SSID provided. Exiting."
    return 1
  fi

  echo "Looking up password for network: $ssid"

  # Try to get the password from Keychain
  local password
  password=$(security find-generic-password -D "AirPort network password" -a "$ssid" -w 2>/dev/null)

  # Try alternative keychain search if the first one fails
  if [ -z "$password" ]; then
    password=$(security find-generic-password -l "$ssid" -w 2>/dev/null)
  fi

  if [ -z "$password" ]; then
    echo "Could not find saved password for \"$ssid\"."
    echo "Possible reasons:"
    echo "  - Password not saved in Keychain"
    echo "  - Network uses enterprise authentication"
    echo "  - Network name was misspelled"
    return 1
  else
    # Copy password to clipboard
    echo -n "$password" | pbcopy
    echo "Password: $password"
    echo "✓ Password copied to clipboard"
  fi
}
