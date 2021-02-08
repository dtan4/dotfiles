#!/bin/bash

default_branch() {
  git branch -l | grep -E "^(\* )?(main|master)$" | sed -E "s/^(\* )//"
}

git_push_db() {
  local remote db
  remote="${1}"
  db="$(default_branch)"

  git checkout "${db}"
  git push "${remote}" "${db}"
}

git_pull_db() {
  local remote db
  remote="${1}"
  db="$(default_branch)"

  git checkout "${db}"
  git pull "${remote}" "${db}"
}

main() {
  set -eu
  set -o pipefail

  if [[ "$#" -lt 2 ]]; then
    echo "[ERROR] command (push|pull) and remote are required" >&2
    return 1
  fi

  local command remote
  command="${1}"
  remote="${2}"

  case "${command}" in
    "push")
      git_push_db "${remote}"
      ;;
    "pull")
      git_pull_db "${remote}"
      ;;
    *)
    echo "[ERROR] invalid command: ${command}" >&2
    return 1
  esac
}

main "${@}"
