#!/bin/bash
set -eo pipefail

current="$(curl -fsSL 'http://www.irssi.org/download' | grep '<li>Latest release version: ' | sed -r 's!^.*<li>Latest release version: <strong>([^"]+)</strong></li>.*$!\1!' | head -1)"

set -x

sed -ri 's/^(ENV IRSSI_VERSION) .*/\1 '"$current"'/' Dockerfile
