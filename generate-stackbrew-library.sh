#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

url='git://github.com/jfrazelle/irssi'

echo '# maintainer: Jessie Frazelle <jess@docker.com> (@jfrazelle)'
echo '# maintainer: Tianon Gravi <admwiggin@gmail.com> (@tianon)'

commit="$(git log -1 --format='format:%H' -- Dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' Dockerfile))"
fullVersion="$(grep -m1 'ENV IRSSI_VERSION ' Dockerfile | cut -d' ' -f3)"

versionAliases=()
while [ "${fullVersion%.*}" != "$fullVersion" ]; do
	versionAliases+=( $fullVersion )
	fullVersion="${fullVersion%.*}"
done
versionAliases+=( $fullVersion latest )

echo
for va in "${versionAliases[@]}"; do
	echo "$va: ${url}@${commit}"
done
