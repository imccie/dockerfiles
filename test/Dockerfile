## 修改自：https://github.com/crazy-max/docker-qbittorrent/blob/master/Dockerfile
## Github Action构建使用，需要在使用前替换LIBTORRENT_MAJOR_VERSION

FROM nevinee/libtorrent-rasterbar:LIBTORRENT_MAJOR_VERSION AS builder
RUN apk add --update --no-cache \
       boost-dev \
       build-base \
       qt5-qttools-dev \
       git \
       cmake \
       samurai \
    && rm -rf /tmp/* /var/cache/apk/*
ARG QBITTORRENT_VERSION
RUN cd /tmp \
    && git clone --branch release-${QBITTORRENT_VERSION} https://github.com/qbittorrent/qBittorrent \
    && cd qBittorrent \
    && cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_CXX_STANDARD=17 \
        -DVERBOSE_CONFIGURE=OFF \
        -DSTACKTRACE=OFF \
        -DDBUS=OFF \
        -DGUI=OFF \
        -B release \
        -G Ninja \
    && cd release \
    && ninja -j $(nproc) \
    && ninja install \
    && ls -al /usr/local/bin/ \
    && qbittorrent-nox --help
RUN echo "Copy to /out" \
    && strip /usr/local/lib/libtorrent-rasterbar.so.* \
    && strip /usr/local/bin/qbittorrent-nox \
    && mkdir /out \
    && mkdir -p /out/usr/lib \
    && mkdir -p /out/usr/bin \
    && cp -d /usr/local/lib/libtorrent-rasterbar.so* /out/usr/lib \
    && cp /usr/local/bin/qbittorrent-nox /out/usr/bin

FROM alpine
ENV QBITTORRENT_HOME="/home/qbittorrent" \
    TZ="Asia/Shanghai" \
    PUID="1000" \
    PGID="100" \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ "
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk add --update --no-cache \
       curl \
       openssl \
       qt5-qtbase \
       shadow \
       tzdata \
       jq \
       bash \
       s6-overlay \
    && rm -rf /tmp/* /var/cache/apk/* \
    && ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo "${TZ}" > /etc/timezone \
    && useradd qbittorrent -u ${PUID} -g ${PGID} -m -d ${QBITTORRENT_HOME} -s /sbin/nologin
COPY --from=builder /out /
COPY s6-overlay /
WORKDIR /data
VOLUME ["/data"]
ENTRYPOINT ["/init"]
