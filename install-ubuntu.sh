#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname -s)" != Linux ]]; then
  echo "This installer only supports Ubuntu Linux." >&2
  exit 1
fi

# bin/install validates Ubuntu and handles the complete mise bootstrap.
exec "$repo_root/bin/install" "$@"
