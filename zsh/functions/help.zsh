function help() {
  local category=$1
  local all_categories=("git" "navigation" "tools" "node" "system" "all")

  # Header function with a fixed approach to creating the underline
  print_header() {
    local title=$1
    local underline=""
    local i
    for ((i = 1; i <= ${#title}; i++)); do
      underline="${underline}-"
    done

    printf "\033[1;36m%s\033[0m\n" "$title"
    printf "\033[1;36m%s\033[0m\n" "$underline"
  }

  # Git helpers
  show_git_help() {
    print_header "Git Helpers"
    printf "\033[1;33mg open\033[0m      - Open current GitHub repository in browser\n"
    printf "\033[1;33mg pr\033[0m        - Open current branch's PR page\n"
    printf "\033[1;33mg clone-cd\033[0m  - Clone and cd into repo: git clone-cd https://github.com/user/repo\n"
    printf "\033[1;33mg cleanup\033[0m   - Cleanup merged branches (protects important branches)\n"
    printf "\033[1;33mg copy-last\033[0m - Copy last commit message to clipboard\n"
    printf "\033[1;33mg cl\033[0m        - Short alias for copy-last\n"
    printf "\033[1;33mg s\033[0m         - Short status\n"
    printf "\033[1;33mg l\033[0m         - Pretty log with graph\n"
    printf "\033[1;33mg lb\033[0m        - List local branches by date\n"
    printf "\033[1;33mg lba\033[0m       - List all branches by date (including remote)\n"
    printf "\033[1;33mg update\033[0m    - Rebase current branch with main branch\n"
    printf "\033[1;33mg squash\033[0m    - Rebase for squashing commits\n"
    printf "\033[1;33mg si\033[0m        - Interactive rebase for squashing commits\n"
    printf "\033[1;33mg pub\033[0m       - Push with force-with-lease safety\n"
  }

  # Navigation helpers
  show_navigation_help() {
    print_header "Navigation"
    printf "\033[1;33mzi\033[0m          - Interactive zoxide navigation (fuzzy directory jumping)\n"
    printf "\033[1;33mcdf\033[0m         - cd to current Finder folder\n"
    printf "\033[1;33mmkcd\033[0m        - Make directory and cd into it: mkcd new-project\n"
    printf "\n"
    printf "\033[1;33mzoxide\033[0m      - Smart cd that learns your habits\n"
    printf "\033[1;33m  z dirname\033[0m - Jump to most frecent directory matching dirname\n"
    printf "\033[1;33m  za dir\033[0m    - Add directory to zoxide database\n"
    printf "\033[1;33m  zr dir\033[0m    - Remove directory from zoxide database\n"
  }

  # Modern CLI tools
  show_tools_help() {
    print_header "Modern CLI Tools"
    printf "\033[1;33mls/l/la\033[0m     - Enhanced directory listings with eza\n"
    printf "\033[1;33mlt/ltt\033[0m      - Tree view with eza (2 or 3 levels deep)\n"
    printf "\033[1;33mcat\033[0m         - Syntax-highlighted cat with bat\n"
    printf "\033[1;33mfind\033[0m        - User-friendly find alternative with fd\n"
    printf "\033[1;33mgrep\033[0m        - Fast search with ripgrep (rg)\n"
    printf "\033[1;33mff\033[0m          - Fuzzy find files with fzf\n"
    printf "\033[1;33mfh\033[0m          - Fuzzy search command history\n"
    printf "\033[1;33mfps\033[0m         - Fuzzy search processes\n"
    printf "\n"
    printf "\033[1;33mbat\033[0m         - Better cat with syntax highlighting\n"
    printf "\033[1;33mbtop\033[0m        - Advanced system monitoring\n"
    printf "\033[1;33mdelta\033[0m       - Better git diff viewing\n"
    printf "\033[1;33mhttpie\033[0m      - User-friendly HTTP client\n"
    printf "\033[1;33mtldr\033[0m        - Simplified man pages with examples\n"
  }

  # Node.js development
  show_node_help() {
    print_header "Node.js Development"
    printf "\033[1;33mfnm\033[0m         - Fast Node Manager (auto-switches versions)\n"
    printf "\033[1;33mr\033[0m           - Run npm scripts: r dev\n"
    printf "\033[1;33myr\033[0m          - Run yarn scripts: yr start\n"
    printf "\033[1;33mbr\033[0m          - Run bun scripts: br dev\n"
    printf "\033[1;33mpr\033[0m          - Run pnpm scripts: pr build\n"
    printf "\033[1;33mts\033[0m          - Run TypeScript with tsx: ts script.ts\n"
  }

  # System utilities
  show_system_help() {
    print_header "System Utilities"
    printf "\033[1;33mdot\033[0m         - Open dotfiles in VS Code\n"
    printf "\033[1;33mreload\033[0m      - Reload shell configuration\n"
    printf "\033[1;33mserve\033[0m       - Start a simple HTTP server in current directory\n"
    printf "\033[1;33mwifi-password\033[0m - Get password for current/specified WiFi network\n"
    printf "\033[1;33mip/ip6\033[0m      - Show public IP addresses\n"
    printf "\033[1;33mlocalip\033[0m     - Show local IP address\n"
  }

  show_usage() {
    printf "Usage: help [category]\n"
    printf "Available categories:\n"
    for category in "${all_categories[@]}"; do
      printf "  \033[1;33m%s\033[0m\n" "$category"
    done
    printf "Example: help git\n"
    printf "Default: help all\n"
  }

  # Display help for all categories if no argument is provided
  if [[ -z "$category" || "$category" == "all" ]]; then
    show_git_help
    printf "\n"
    show_navigation_help
    printf "\n"
    show_tools_help
    printf "\n"
    show_node_help
    printf "\n"
    show_system_help
    printf "\n"
    printf "For specific categories, try: help [category]\n"
    printf "Available categories: ["
    local i=0
    for cat in "${all_categories[@]}"; do
      if [[ $i -gt 0 ]]; then
        printf ", "
      fi
      printf "%s" "$cat"
      ((i++))
    done
    printf "]\n"
    return 0
  fi

  # Display help for the specified category
  case "$category" in
  "git")
    show_git_help
    ;;
  "navigation")
    show_navigation_help
    ;;
  "tools")
    show_tools_help
    ;;
  "node")
    show_node_help
    ;;
  "system")
    show_system_help
    ;;
  "help")
    show_usage
    ;;
  *)
    printf "Unknown category: %s\n" "$category"
    show_usage
    return 1
    ;;
  esac
}
