#!/bin/bash

get-files-to-lint() {
  local flag="$1"
  local current_branch_name="$(git branch --show-current)"

  if [[ "$current_branch_name" == "main" ]]; then
    git diff origin/main...HEAD --name-only --diff-filter=d -- '*.rb'
  else
    git diff main...HEAD --name-only --diff-filter=d -- '*.rb'
  fi

  if [[ $flag == "--include-uncommitted" ]]; then
    git diff --name-only --diff-filter=d -- '*.rb'
  fi
}

main() {
  local include_uncommitted_flag

  while [[ -n "$1" ]]; do
    case "$1" in
      --include-uncommitted)
        include_uncommitted_flag="$1"
        shift
        ;;
      *)
        echo "ERROR: Unknown option $1."
        exit 1
        ;;
    esac
  done

  local files_to_lint="$(get-files-to-lint "$include_uncommitted_flag")"

  echo "*** Checking for lint violations in changed files ***************"
  echo

  if [[ -n "$files_to_lint" ]]; then
    echo "Files to check:"
    echo "$files_to_lint" | while IFS=$'\n' read -r line; do
      echo "- $line"
    done

    echo
    echo "$files_to_lint" | while IFS=$'\n' read -r line; do
      printf '%s\0' "$line"
    done | xargs -0 bundle exec rubocop -a
  else
    echo "No files to lint this time."
  fi
}

main "$@"
