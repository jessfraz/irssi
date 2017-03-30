FROM debian:jessie

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		libdatetime-perl \
		libgcrypt20 \
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

ENV IRSSI_VERSION 0.8.19
ENV LIB_OTR_VERSION 4.1.1
ENV IRSSI_OTR_VERSION 1.0.1
ENV PATCH_FOR_IRSSI_OTR https://github.com/cryptodotis/irssi-otr/commit/d03ab59b6f27142c1c5e99fedc635a589b1607bb.diff

RUN buildDeps=' \
		autoconf \
		automake \
		bzip2 \
		libglib2.0-dev \
		libgcrypt20-dev \
		libncurses-dev \
		libperl-dev \
		libssl-dev \
		libtool \
		lynx \
		make \
		patch \
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
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 7EE65E3082A5FB06AC7C368D00CCB587DDBEF0E1 \
	&& gpg --batch --verify /tmp/irssi.tar.xz.asc /tmp/irssi.tar.xz \
	&& rm -r "$GNUPGHOME" /tmp/irssi.tar.xz.asc \
	&& mkdir -p /usr/src/irssi \
	&& tar -xf /tmp/irssi.tar.xz -C /usr/src/irssi --strip-components 1 \
	&& rm /tmp/irssi.tar.xz \
	&& ( \
		cd /usr/src/irssi \
		&& ./configure \
			--enable-true-color \
			--with-bot \
			--with-proxy \
			--with-socks \
			--prefix=/usr \
		&& make -j$(nproc) \
		&& make install \
	) \
	&& wget "https://otr.cypherpunks.ca/libotr-${LIB_OTR_VERSION}.tar.gz" -O /tmp/libotr.tar.gz \
	&& wget "https://otr.cypherpunks.ca/libotr-${LIB_OTR_VERSION}.tar.gz.asc" -O /tmp/libotr.tar.gz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
# gpg: key 42C2ABAD: public key "OTR Dev Team (Signing Key) <otr@cypherpunks.ca>" imported
	&& gpg --keyserver pgp.mit.edu --recv-keys 22DF3305DF56667CE15784FCF24DE08F42C2ABAD \
	&& gpg --batch --verify /tmp/libotr.tar.gz.asc /tmp/libotr.tar.gz \
	&& rm -r "$GNUPGHOME" /tmp/libotr.tar.gz.asc \
	&& mkdir -p /usr/src/libotr \
	&& tar -xzf /tmp/libotr.tar.gz -C /usr/src/libotr --strip-components 1 \
	&& rm /tmp/libotr.tar.gz \
	&& ( \
		cd /usr/src/libotr \
		&& ./configure \
			--with-pic \
			--prefix=/usr \
		&& make \
		&& make install \
	) \
	&& mkdir -p /usr/src/irssi-otr \
	&& wget "https://github.com/cryptodotis/irssi-otr/archive/v${IRSSI_OTR_VERSION}.tar.gz" -O /tmp/irssi-otr.tar.gz \
	&& mkdir -p /usr/src/irssi-otr \
	&& tar -xf /tmp/irssi-otr.tar.gz -C /usr/src/irssi-otr --strip-components 1 \
	&& rm /tmp/irssi-otr.tar.gz \
	&& ( \
		cd /usr/src/irssi-otr \
		&& wget "$PATCH_FOR_IRSSI_OTR" -O patch.diff \
		&& patch -p1 < patch.diff \
		&& ./bootstrap \
		&& ./configure \
			--prefix=/usr \
		&& make \
		&& make install \
	) \
	&& rm -rf /usr/src/irssi \
	&& rm -rf /usr/src/libotr \
	&& rm -rf /usr/src/irssi-otr \
	&& apt-get purge -y --auto-remove $buildDeps

WORKDIR $HOME
VOLUME $HOME/.irssi

USER user
CMD ["irssi"]
