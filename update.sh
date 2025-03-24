#!/usr/bin/env bash
set -eo pipefail

current="$(git ls-remote --tags https://github.com/irssi/irssi.git | cut -d/ -f3 | cut -d^ -f1 | sort -uV | grep -vE -- '-rc|-git$|-dev$' | tail -1)"

set -x

sed -ri 's/^(ENV IRSSI_VERSION) .*/\1 '"$current"'/' */Dockerfile
