FROM debian:stretch-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		libdatetime-perl \
		libglib2.0-0 \
		libwww-perl \
		perl \
		wget \
	&& rm -rf /var/lib/apt/lists/*

ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
	&& mkdir -p $HOME/.irssi \
	&& chown -R user:user $HOME

ENV LANG C.UTF-8

ENV IRSSI_VERSION 1.2.0

RUN buildDeps=' \
		autoconf \
		automake \
		bzip2 \
		dirmngr \
		dpkg-dev \
		gnupg \
		libglib2.0-dev \
		libncurses-dev \
		libperl-dev \
		libssl-dev \
		libtool \
		lynx \
		make \
		pkg-config \
		xz-utils \
	' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& wget "https://github.com/irssi/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.xz" -O /tmp/irssi.tar.xz \
	&& wget "https://github.com/irssi/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.xz.asc" -O /tmp/irssi.tar.xz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
# gpg: key DDBEF0E1: public key "The Irssi project <staff@irssi.org>" imported
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys 7EE65E3082A5FB06AC7C368D00CCB587DDBEF0E1 \
	&& gpg --batch --verify /tmp/irssi.tar.xz.asc /tmp/irssi.tar.xz \
	&& gpgconf --kill all \
	&& rm -rf "$GNUPGHOME" /tmp/irssi.tar.xz.asc \
	&& mkdir -p /usr/src/irssi \
	&& tar -xf /tmp/irssi.tar.xz -C /usr/src/irssi --strip-components 1 \
	&& rm /tmp/irssi.tar.xz \
	&& cd /usr/src/irssi \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-true-color \
		--with-bot \
		--with-proxy \
		--with-socks \
	&& make -j "$(nproc)" \
	&& make install \
	&& rm -rf /usr/src/irssi \
	&& apt-get purge -y --auto-remove $buildDeps

WORKDIR $HOME

USER user
CMD ["irssi"]
