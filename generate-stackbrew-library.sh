#!/bin/bash
set -e

defaultVariant='debian'

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

url='git://github.com/jessfraz/irssi'

echo '# maintainer: Jessie Frazelle <acidburn@google.com> (@jessfraz)'
echo '# maintainer: Tianon Gravi <admwiggin@gmail.com> (@tianon)'

for variant in debian alpine; do
	commit="$(cd "$variant" && git log -1 --format='format:%H' -- Dockerfile $(awk 'toupper($1) == "COPY" { for (i = 2; i < NF; i++) { print $i } }' Dockerfile))"
	fullVersion="$(git show "$commit:$variant/Dockerfile" | awk 'toupper($1) == "ENV" && $2 == "IRSSI_VERSION" { print $3 }')"

	versionAliases=()
	while [ "${fullVersion%.*}" != "$fullVersion" ]; do
		versionAliases+=( $fullVersion )
		fullVersion="${fullVersion%.*}"
	done
	versionAliases+=( $fullVersion latest )

	variantAliases=( "${versionAliases[@]/%/-$variant}" )
	variantAliases=( "${variantAliases[@]//latest-/}" )
	if [ "$variant" = "$defaultVariant" ]; then
		versionAliases+=( "${variantAliases[@]}" )
	else
		versionAliases=( "${variantAliases[@]}" )
	fi

	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $variant"
	done
done
