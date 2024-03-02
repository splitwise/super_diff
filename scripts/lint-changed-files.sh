#!/bin/bash

get-files-to-lint() {
  local flag="$1"
  local current_branch_name="$(git branch --show-current)"

  if [[ "$current_branch_name" == "main" ]]; then
    git diff origin/main...HEAD --name-only --diff-filter=d
  else
    git diff main...HEAD --name-only --diff-filter=d
  fi

  if [[ $flag == "--include-uncommitted" ]]; then
    git diff --name-only --diff-filter=d
  fi
}

main() {
  local prettier_flag
  local include_uncommitted_flag

  while [[ -n "$1" ]]; do
    case "$1" in
      --check | --write)
        prettier_flag="$1"
        shift
        ;;
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

  if [[ -z "$prettier_flag" ]]; then
    echo "ERROR: Missing --check or --write."
    exit 1
  fi

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
    done | xargs -0 yarn prettier "$prettier_flag" --ignore-unknown
  else
    echo "No files to lint this time."
  fi
}

main "$@"
