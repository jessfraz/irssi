FROM alpine:3.5

RUN apk --no-cache add \
	ca-certificates

ENV HOME /home/user
RUN adduser -u 1001 -D user \
	&& mkdir -p $HOME/.irssi \
	&& chown -R user:user $HOME

ENV LANG C.UTF-8

ENV IRSSI_VERSION 1.0.2

RUN set -x \
	&& apk add --no-cache --virtual .build-deps \
		autoconf \
		automake \
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
	&& wget "https://github.com/irssi/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.xz" -O /tmp/irssi.tar.xz \
	&& wget "https://github.com/irssi/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.xz.asc" -O /tmp/irssi.tar.xz.asc \
	&& export GNUPGHOME="$(mktemp -d)" \
# gpg: key DDBEF0E1: public key "The Irssi project <staff@irssi.org>" imported
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys 7EE65E3082A5FB06AC7C368D00CCB587DDBEF0E1 \
	&& gpg --batch --verify /tmp/irssi.tar.xz.asc /tmp/irssi.tar.xz \
	&& rm -r "$GNUPGHOME" /tmp/irssi.tar.xz.asc \
	&& mkdir -p /usr/src \
	&& tar -xJf /tmp/irssi.tar.xz -C /usr/src \
	&& rm /tmp/irssi.tar.xz \
	&& cd /usr/src/irssi-$IRSSI_VERSION \
	&& ./configure \
		--enable-true-color \
		--with-bot \
		--with-proxy \
		--with-socks \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /usr/src/irssi-$IRSSI_VERSION \
	&& runDeps="$( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --no-cache --virtual .irssi-rundeps $runDeps perl-libwww \
	&& apk del .build-deps

WORKDIR $HOME

USER user
CMD ["irssi"]
