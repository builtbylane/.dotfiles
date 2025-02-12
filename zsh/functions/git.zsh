# Clone and cd in one command
function git_clone_cd() {
  if [[ -z "$1" ]]; then
    echo "Usage: git_clone_cd <repository>" >&2
    return 1
  fi
  git clone "$1" || return 1
  cd "$(basename "$1" .git)" || return 1
}

# Copy last commit message
function copy_last_commit_message_to_clipboard() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local last_commit_message
    last_commit_message=$(git log -1 --pretty=format:'%s')
    echo -n "$last_commit_message" | pbcopy
    echo "Copied: \"$last_commit_message\""
  else
    echo "No git repository found."
  fi
}

# Open current GitHub repo in browser
function git_open_repo() {
  local remote_url
  local web_url

  remote_url=$(git config --get remote.origin.url)
  if [[ -z "$remote_url" ]]; then
    echo "No remote URL found"
    return 1
  fi

  web_url=$(echo "$remote_url" | sed -e 's|git@github.com:|https://github.com/|' -e 's/\.git$//')
  open "$web_url"
}

# Open GitHub PR in browser
function git_open_pr() {
  local current_branch
  local remote
  local remote_url
  local target_branch
  local pr_url

  # Get the current branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if ! git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
    echo "Error: Not in a git repository"
    return 1
  fi

  # Get the remote URL
  remote=$(git config --get "branch.${current_branch}.remote" || echo "origin")
  remote_url=$(git remote get-url "$remote")
  if ! git remote get-url "$remote" >/dev/null 2>&1; then
    echo "Error: Could not get remote URL"
    return 1
  fi

  # Convert SSH URL to HTTPS URL if necessary
  if [[ $remote_url =~ ^git@ ]]; then
    remote_url=${remote_url/git@github.com:/https://github.com/}
  fi

  # Clean up the URL
  remote_url=${remote_url%.git}

  # Get the target branch name
  target_branch=$(git config --get "branch.${current_branch}.merge" | sed 's|refs/heads/||')
  if [[ -z $target_branch ]]; then
    target_branch="main"
  fi

  # Construct and open the URL
  pr_url="${remote_url}/compare/${target_branch}?expand=1"
  open "$pr_url"
}

# Protected branches that should never be deleted
PROTECTED_BRANCHES=(
  "master"
  "main"
  "develop"
  "staging"
  "stage"
  "test"
  "testing"
  "prod"
  "production"
)

# Get list of merged branches excluding protected ones
get_merged_branches() {
  local protected_pattern
  protected_pattern=$(printf "|%s" "${PROTECTED_BRANCHES[@]}")
  protected_pattern="\\*${protected_pattern}"
  git branch --merged | grep -v "${protected_pattern}" | tr -d ' '
}

# Main cleanup function
cleanup_branches() {
  # Display a warning message with emoji
  echo "=============================================="
  echo "WARNING: This script will delete merged branches."
  echo "Make sure you have reviewed the branches to be deleted."
  echo "Protected branches (will not be deleted):"
  printf "%s\n" "${PROTECTED_BRANCHES[@]}"
  echo "=============================================="
  echo

  local branches=()
  while IFS= read -r branch; do
    branches+=("$branch")
  done < <(get_merged_branches)

  if [ ${#branches[@]} -eq 0 ]; then
    echo "✅ No merged branches to clean up."
    return 0
  fi

  echo "The following merged branches will be deleted:"
  printf "🗑️ %s\n" "${branches[@]}"
  echo

  # Use a compatible read command
  echo -n "❓ Do you want to proceed? (y/N) "
  read -r confirm

  if [[ $confirm =~ ^[Yy]$ ]]; then
    for branch in "${branches[@]}"; do
      git branch -d "$branch"
      echo "✅ Deleted branch: $branch"
    done
    echo "🎉 Cleanup complete!"
  else
    echo "❌ Operation cancelled."
  fi
}
