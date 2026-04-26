#!/usr/bin/env bash
# Prepare minimal prerequisites inside a test container.

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y install \
  bash coreutils findutils git curl wget unzip tar gzip xz-utils ca-certificates passwd util-linux
