# Change working directory to the top-most Finder window location
function cdf() {
  local dir
  dir="$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)' 2>/dev/null)" || return 1

  if [[ -d "${dir}" ]]; then
    cd "${dir}" || return 1
    echo "${dir}"
  else
    echo "Could not get Finder location" >&2
    return 1
  fi
}

# Make directory and change into it
function mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <directory>" >&2
    return 1
  fi
  mkdir -p "$1" || return 1
  cd "$1" || return 1
}

function zi() {
  local result
  result="$(zoxide query -i)"
  if [ -n "$result" ]; then
    cd "$result" || return 1
  fi
}
