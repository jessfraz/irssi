#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

url='git://github.com/jfrazelle/irssi'

echo '# maintainer: Jessie Frazelle <jess@docker.com> (@jfrazelle)'
echo '# maintainer: Tianon Gravi <admwiggin@gmail.com> (@tianon)'

for variant in "" alpine; do
	dockerfile=${variant:+$variant/}Dockerfile
	suffix=${variant:+-$variant}
	commit="$(git log -1 --format='format:%H' -- $dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' $dockerfile))"
	fullVersion="$(grep -m1 'ENV IRSSI_VERSION ' $dockerfile | cut -d' ' -f3)"

	versionAliases=()
	while [ "${fullVersion%.*}" != "$fullVersion" ]; do
		versionAliases+=( ${fullVersion}${suffix} )
		fullVersion="${fullVersion%.*}"
	done
	versionAliases+=( ${fullVersion}${suffix} ${variant:-latest} )

	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit}"
	done
done

