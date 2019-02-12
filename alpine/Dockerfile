FROM alpine:3.7

RUN apk --no-cache add \
	ca-certificates

ENV HOME /home/user
RUN adduser -u 1001 -D user \
	&& mkdir -p $HOME/.irssi \
	&& chown -R user:user $HOME

ENV LANG C.UTF-8

ENV IRSSI_VERSION 1.2.0

RUN set -x \
	&& apk add --no-cache --virtual .build-deps \
		autoconf \
		automake \
		coreutils \
		dpkg-dev dpkg \
		gcc \
		glib-dev \
		gnupg \
		libc-dev \
		libtool \
		lynx \
		make \
		ncurses-dev \
		openssl \
		openssl-dev \
		perl-dev \
		pkgconf \
		tar \
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
	&& runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)" \
	&& apk add --no-cache --virtual .irssi-rundeps $runDeps perl-libwww \
	&& apk del .build-deps

WORKDIR $HOME

USER user
CMD ["irssi"]
