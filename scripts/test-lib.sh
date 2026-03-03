#!/usr/bin/env bash
# Shared helpers for test scripts.

set -euo pipefail

test_info() {
  printf 'INFO: %s\n' "$1"
}

test_warn() {
  printf 'WARN: %s\n' "$1"
}

test_err() {
  printf 'ERROR: %s\n' "$1" >&2
}

semver_ge() {
  local a="${1#v}"
  local b="${2#v}"
  [[ "$(printf '%s\n%s\n' "$b" "$a" | sort -V | tail -n1)" == "$a" ]]
}

json_escape() {
  local input="$1"
  printf '%s' "$input" | sed 's/\\/\\\\/g; s/"/\\"/g'
}
