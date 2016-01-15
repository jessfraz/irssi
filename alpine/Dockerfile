FROM alpine:3.3

ENV HOME /home/user
RUN adduser -u 1001 -D user \
	&& mkdir -p $HOME/.irssi \
	&& chown -R user:user $HOME

ENV LANG C.UTF-8

# gpg: key DDBEF0E1: public key "The Irssi project <staff@irssi.org>" imported
ENV GPG_KEY 7EE65E3082A5FB06AC7C368D00CCB587DDBEF0E1
ENV IRSSI_VERSION 0.8.17

RUN set -x \
	&& apk add --no-cache --virtual .build-deps \
		autoconf \
		automake \
		curl \
		gcc \
		glib-dev \
		gnupg \
		libc-dev \
		libtool \
		lynx \
		make \
		make \
		ncurses-dev \
		openssl-dev \
		perl-dev \
		pkgconf \
        && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& curl -fsSL "https://github.com/irssi-import/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.bz2" -o /tmp/irssi.tar.bz2 \
	&& curl -fsSL "https://github.com/irssi-import/irssi/releases/download/${IRSSI_VERSION}/irssi-${IRSSI_VERSION}.tar.bz2.sig" -o /tmp/irssi.tar.bz2.sig \
	&& gpg --verify /tmp/irssi.tar.bz2.sig \
	&& mkdir -p /usr/src \
	&& tar -xjf /tmp/irssi.tar.bz2 -C /usr/src \
	&& rm /tmp/irssi.tar.bz2* \
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
VOLUME $HOME/.irssi

USER user
CMD ["irssi"]
