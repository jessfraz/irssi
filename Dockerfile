FROM debian:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		libwww-perl \
		wget \
	&& rm -rf /var/lib/apt/lists/*

RUN useradd --create-home user \
	&& mkdir -p /home/user/.irssi \
	&& chown -R user:user /home/user
ENV HOME /home/user
WORKDIR /home/user

ENV LANG C.UTF-8

ENV IRSSI_VERSION 0.8.17

RUN buildDeps=' \
		autoconf \
		automake \
		libtool \
		lynx \
	' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/irssi \
	&& curl -sSL "https://github.com/irssi/irssi/archive/${IRSSI_VERSION}.tar.gz" \
		| tar -xzC /usr/src/irssi --strip-components 1 \
	&& cd /usr/src/irssi \
	&& ./autogen.sh
