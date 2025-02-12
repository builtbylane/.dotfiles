# Initialize path with system defaults
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Homebrew paths (prioritize)
if [[ -d "/opt/homebrew" ]]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:${PATH}"
fi

# System paths
export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"

# Node.js
if [[ -d "/usr/local/lib/node_modules/npm" ]]; then
  export PATH="/usr/local/lib/node_modules/npm:${PATH}"
fi

# Ruby (rbenv)
if [[ -d "${HOME}/.rbenv" ]]; then
  export PATH="${HOME}/.rbenv/bin:${HOME}/.rbenv/shims:${PATH}"
fi

# Local binaries
if [[ -d "${HOME}/bin" ]]; then
  export PATH="${HOME}/bin:${PATH}"
fi

# FNM (Fast Node Manager)
if [[ -d "${HOME}/.fnm" ]]; then
  export PATH="${HOME}/.fnm:${PATH}"
fi
