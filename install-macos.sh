#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname -s)" != Darwin ]]; then
  echo "This installer only supports macOS." >&2
  exit 1
fi

exec "$repo_root/bin/install" "$@"
