#!/usr/bin/env bash
set -eu

defaultVariant='debian'

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

getArches() {
	local repo="$1"; shift
	local officialImagesBase="${BASHBREW_LIBRARY:-https://github.com/docker-library/official-images/raw/HEAD/library}/"

	local parentRepoToArchesStr
	parentRepoToArchesStr="$(
		find -name 'Dockerfile' -exec awk -v officialImagesBase="$officialImagesBase" '
				toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ {
					printf "%s%s\n", officialImagesBase, $2
				}
			' '{}' + \
			| sort -u \
			| xargs -r bashbrew cat --format '["{{ .RepoName }}:{{ .TagName }}"]="{{ join " " .TagEntry.Architectures }}"'
	)"
	eval "declare -g -A parentRepoToArches=( $parentRepoToArchesStr )"
}
getArches 'irssi'

cat <<-EOH
# this file is generated via https://github.com/jessfraz/irssi/blob/$(fileCommit "$self")/$self

Maintainers: Jessie Frazelle <acidburn@google.com> (@jessfraz),
             Tianon Gravi <admwiggin@gmail.com> (@tianon)
GitRepo: https://github.com/jessfraz/irssi.git
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

for variant in debian alpine; do
	commit="$(dirCommit "$variant")"

	fullVersion="$(git show "$commit":"$variant/Dockerfile" | awk '$1 == "ENV" && $2 == "IRSSI_VERSION" { print $3; exit }')"

	versionAliases=()
	while [ "${fullVersion%.*}" != "$fullVersion" ]; do
		versionAliases+=( $fullVersion )
		fullVersion="${fullVersion%.*}"
	done
	versionAliases+=(
		$fullVersion
		latest
	)

	variantAliases=( "${versionAliases[@]/%/-$variant}" )
	variantAliases=( "${variantAliases[@]//latest-/}" )

	if [ "$variant" = "$defaultVariant" ]; then
		variantAliases=( "${versionAliases[@]}" )
	fi

	parent="$(awk 'toupper($1) == "FROM" { print $2 }' "$variant/Dockerfile")"
	arches="${parentRepoToArches[$parent]}"

	suiteAlias="${parent#*:}" # "alpine:3.18" -> "3.18", "debian:bookworm-slim" -> "bookworm-slim"
	suiteAlias="${suiteAlias%-slim}" # "bookworm-slim" -> "bookworm"
	if [ "$variant" = 'alpine' ]; then
		suiteAlias="$variant$suiteAlias" # "3.18" -> "alpine3.18"
	fi
	variantAliases+=( "${versionAliases[@]/%/-$suiteAlias}" )
	variantAliases=( "${variantAliases[@]//latest-/}" )

	echo
	cat <<-EOE
		Tags: $(join ', ' "${variantAliases[@]}")
		Architectures: $(join ', ' $arches)
		GitCommit: $commit
		Directory: $variant
	EOE
done
