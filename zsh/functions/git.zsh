# Enhanced Git Helper Functions

function git_clone_cd() {
  if [[ -z "$1" ]]; then
    echo -e "\033[31m✘ Usage: git_clone_cd <repository>\033[0m" >&2
    return 1
  fi
  git clone "$1" || return 1
  cd "$(basename "$1" .git)" || return 1
  echo -e "\033[32m✓ Cloned and changed to $(pwd)\033[0m"
}

function copy_last_commit_message_to_clipboard() {
  if git rev-parse --git-dir >/dev/null 2>&1; then
    local last_commit_message
    last_commit_message=$(git log -1 --pretty=format:'%s')
    echo -n "$last_commit_message" | pbcopy
    echo -e "\033[32m✓ Copied:\033[0m \033[36m\"$last_commit_message\"\033[0m"
  else
    echo -e "\033[31m✘ No git repository found\033[0m"
  fi
}

function git_open_repo() {
  local remote_url
  local web_url

  remote_url=$(git config --get remote.origin.url)
  if [[ -z "$remote_url" ]]; then
    echo -e "\033[31m✘ No remote URL found\033[0m"
    return 1
  fi

  # Handle custom GitHub host aliases (e.g., github-*)
  web_url=$(echo "$remote_url" | sed -e 's|git@github[^:]*:|https://github.com/|' -e 's/\.git$//')
  open "$web_url"
  echo -e "\033[32m✓ Opening:\033[0m \033[36m$web_url\033[0m"
}

function git_open_pr() {
  local current_branch
  local remote
  local remote_url
  local target_branch
  local pr_url

  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if ! git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
    echo -e "\033[31m✘ Not in a git repository\033[0m"
    return 1
  fi

  remote=$(git config --get "branch.${current_branch}.remote" || echo "origin")
  remote_url=$(git remote get-url "$remote")
  if ! git remote get-url "$remote" >/dev/null 2>&1; then
    echo -e "\033[31m✘ Could not get remote URL\033[0m"
    return 1
  fi

  # Handle custom GitHub host aliases (e.g., github-*)
  if [[ $remote_url =~ ^git@github ]]; then
    remote_url=$(echo "$remote_url" | sed 's|git@github[^:]*:|https://github.com/|')
  fi

  remote_url=${remote_url%.git}

  target_branch=$(git config --get "branch.${current_branch}.merge" | sed 's|refs/heads/||')
  if [[ -z $target_branch ]]; then
    target_branch="main"
  fi

  # Try to get existing PR number
  if command -v gh &>/dev/null; then
    pr_number=$(gh pr view --json number -q .number 2>/dev/null)
    if [[ -n "$pr_number" ]]; then
      pr_url="${remote_url}/pull/${pr_number}"
      open "$pr_url"
      echo -e "\033[32m✓ Opening existing PR #${pr_number}:\033[0m \033[36m$pr_url\033[0m"
      return 0
    fi
  fi

  # Fall back to PR creation page
  pr_url="${remote_url}/compare/${current_branch}?expand=1"
  open "$pr_url"
  echo -e "\033[32m✓ Opening PR creation page:\033[0m \033[36m$pr_url\033[0m"
}

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

get_merged_branches() {
  local branches
  branches=$(git branch --merged)

  # Filter out protected branches and current branch
  while IFS= read -r branch; do
    # Remove leading whitespace and asterisk
    branch=$(echo "$branch" | sed 's/^[[:space:]]*\**//' | tr -d ' ')

    # Skip empty lines
    [[ -z "$branch" ]] && continue

    # Skip if it's a protected branch
    local is_protected=0
    for protected in "${PROTECTED_BRANCHES[@]}"; do
      if [[ "$branch" == "$protected" ]]; then
        is_protected=1
        break
      fi
    done

    [[ $is_protected -eq 0 ]] && echo "$branch"
  done <<< "$branches"
}

cleanup_branches() {
  echo -e "\033[33m⚠️  WARNING: About to delete merged branches\033[0m"
  echo -e "\033[36m🛡️  Protected:\033[0m ${PROTECTED_BRANCHES[*]}"
  echo

  local branches=()
  while IFS= read -r branch; do
    branches+=("$branch")
  done < <(get_merged_branches)

  if [ ${#branches[@]} -eq 0 ]; then
    echo -e "\033[32m✓ No branches to clean\033[0m"
    return 0
  fi

  echo -e "\033[35mBranches to delete:\033[0m"
  printf "\033[31m🗑️  %s\033[0m\n" "${branches[@]}"
  echo

  echo -n -e "\033[33m❓ Proceed? (y/N) \033[0m"
  read -r confirm

  if [[ $confirm =~ ^[Yy]$ ]]; then
    for branch in "${branches[@]}"; do
      git branch -d "$branch"
      echo -e "\033[32m✓ Deleted:\033[0m $branch"
    done
    echo -e "\033[32m🎉 Cleanup complete!\033[0m"
  else
    echo -e "\033[31m✘ Cancelled\033[0m"
  fi
}
