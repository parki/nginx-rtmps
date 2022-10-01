FROM alpine:latest as builder
LABEL stage=builder
LABEL org.opencontainers.image.authors="Insik Park <parki@insikpark.com>"

ARG NGINX_VERSION=1.23.1
ARG NGINX_RTMP_VERSION=1.2.2

RUN	apk update		&&	\
	apk add				\
		git				\
		gcc				\
		binutils		\
		gmp				\
		isl				\
		libgomp			\
		libatomic		\
		libgcc			\
		openssl			\
		pkgconf			\
		pkgconfig		\
		mpfr4			\
		mpc1			\
		libstdc++		\
		ca-certificates	\
		libssh2			\
		curl			\
		expat			\
		pcre			\
		musl-dev		\
		libc-dev		\
		pcre-dev		\
		zlib-dev		\
		openssl-dev		\
		curl			\
		make

RUN	cd /tmp && \
	curl --remote-name http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
	git clone https://github.com/arut/nginx-rtmp-module.git -b v${NGINX_RTMP_VERSION}

RUN	cd /tmp										&&	\
	tar xzf nginx-${NGINX_VERSION}.tar.gz		&&	\
	cd nginx-${NGINX_VERSION}					&&	\
	./configure										\
		--with-http_ssl_module						\
		--add-module=../nginx-rtmp-module		&&	\
	make										&&	\
	make install

FROM alpine:latest as target

RUN apk update &&		\
	apk add 			\
		openssl 		\
		libstdc++ 		\
		ca-certificates \
		pcre 			\
		stunnel

COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY entrypoint.sh /
COPY stunnel.conf /etc/stunnel

EXPOSE 1935/tcp

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/local/nginx/sbin/nginx"]

