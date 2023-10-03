FROM debian:bookworm-slim

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		libdatetime-perl \
		libwww-perl \
		perl \
		wget \
	; \
	rm -rf /var/lib/apt/lists/*

ENV HOME /home/user
RUN set -eux; \
	useradd --create-home --home-dir "$HOME" user; \
	mkdir "$HOME/.irssi"; \
	chown -R user:user "$HOME"

ENV LANG C.UTF-8

ENV IRSSI_VERSION 1.4.5

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		bzip2 \
		gnupg \
		libglib2.0-dev \
		libncurses-dev \
		libperl-dev \
		libssl-dev \
		libtool \
		lynx \
		meson \
		ninja-build \
		pkg-config \
		xz-utils \
	; \
	rm -rf /var/lib/apt/lists/*; \
	\
	wget "https://github.com/irssi/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.xz" -O /tmp/irssi.tar.xz; \
	wget "https://github.com/irssi/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.xz.asc" -O /tmp/irssi.tar.xz.asc; \
	export GNUPGHOME="$(mktemp -d)"; \
# gpg: key DDBEF0E1: public key "The Irssi project <staff@irssi.org>" imported
	gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 7EE65E3082A5FB06AC7C368D00CCB587DDBEF0E1; \
	gpg --batch --verify /tmp/irssi.tar.xz.asc /tmp/irssi.tar.xz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" /tmp/irssi.tar.xz.asc; \
	\
	mkdir -p /usr/src/irssi; \
	tar -xf /tmp/irssi.tar.xz -C /usr/src/irssi --strip-components 1; \
	rm /tmp/irssi.tar.xz; \
	\
	cd /usr/src/irssi; \
	meson \
		-Denable-true-color=yes \
		-Dwith-bot=yes \
		-Dwith-perl=yes \
		-Dwith-proxy=yes \
		Build \
	; \
	ninja -C Build -j "$(nproc)"; \
	ninja -C Build install; \
	\
	cd /; \
	rm -rf /usr/src/irssi; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
# basic smoke test
	irssi --version

WORKDIR $HOME

USER user
CMD ["irssi"]
