FROM debian:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		libglib2.0-0 \
		libdatetime-perl \
		libwww-perl \
		perl \
		wget \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd --create-home user \
	&& mkdir -p /home/user/.irssi \
	&& chown -R user:user /home/user
ENV HOME /home/user
WORKDIR /home/user

ENV LANG C.UTF-8

ENV IRSSI_VERSION 0.8.17
ENV IRSSI_VERSION_DATE 20141011
ENV IRSSI_VERSION_TIME 1044

RUN buildDeps=' \
		autoconf \
		automake \
		libglib2.0-dev \
		libncurses-dev \
		libperl-dev \
		libssl-dev \
		libtool \
		lynx \
		make \
		pkg-config \
	' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/irssi \
	&& curl -sSL "https://github.com/irssi/irssi/archive/${IRSSI_VERSION}.tar.gz" \
		| tar -xzC /usr/src/irssi --strip-components 1 \
	&& cd /usr/src/irssi \
	&& { \
		echo '#!/bin/sh'; \
		echo 'echo "#define IRSSI_VERSION_DATE $IRSSI_VERSION_DATE"'; \
		echo 'echo "#define IRSSI_VERSION_TIME $IRSSI_VERSION_TIME"'; \
	} > irssi-version.sh \
	&& NOCONFIGURE=1 ./autogen.sh \
	&& ./configure \
		--enable-true-color \
		--with-bot \
		--with-proxy \
		--with-socks \
	&& make \
	&& make install \
	&& rm -rf /usr/src/irssi \
	&& apt-get purge -y --auto-remove $buildDeps

USER user
CMD ["irssi"]
