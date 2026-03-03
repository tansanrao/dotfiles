#!/usr/bin/env bash
# Prepare minimal prerequisites inside a test container.

set -euo pipefail

if (( "$#" < 1 )); then
  echo "Usage: tests/container/prepare.sh <family>" >&2
  exit 1
fi

family="$1"

case "$family" in
  fedora)
    dnf -y makecache --refresh
    dnf -y install \
      bash coreutils findutils git curl wget unzip tar gzip xz ca-certificates shadow-utils util-linux which
    ;;
  el)
    dnf -y makecache --refresh
    dnf -y install \
      bash findutils git wget unzip tar gzip xz ca-certificates shadow-utils util-linux which
    ;;
  ubuntu)
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get -y install \
      bash coreutils findutils git curl wget unzip tar gzip xz-utils ca-certificates passwd util-linux
    ;;
  *)
    echo "Unknown container family: $family" >&2
    exit 1
    ;;
esac
