# syntax=docker/dockerfile:1

#FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-alpine:edge

# set version label
ARG BUILD_DATE
ARG VERSION
ARG QBITTORRENT_VERSION
ARG QBT_CLI_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

# install runtime packages and qbitorrent-cli
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    grep \
    icu-libs \
    p7zip \
    python3 \
    qt6-qtbase-sqlite && \
  if [ -z ${QBITTORRENT_VERSION+x} ]; then \
    QBITTORRENT_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/edge/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:qbittorrent-nox$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add -U --upgrade --no-cache \
    qbittorrent-nox==${QBITTORRENT_VERSION} && \
  echo "***** install qbitorrent-cli ****" && \
  mkdir /qbt && \
  if [ -z ${QBT_CLI_VERSION+x} ]; then \
    QBT_CLI_VERSION=$(curl -sL "https://api.github.com/repos/fedarovich/qbittorrent-cli/releases/latest" \
    | jq -r '. | .tag_name'); \
  fi && \
  curl -o \
    /tmp/qbt.tar.gz -L \
    "https://github.com/fedarovich/qbittorrent-cli/releases/download/${QBT_CLI_VERSION}/qbt-linux-alpine-x64-net6-${QBT_CLI_VERSION#v}.tar.gz" && \
  tar xf \
    /tmp/qbt.tar.gz -C \
    /qbt && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /root/.cache \
    /tmp/*

# MY CUSTOMIZATIONS
RUN \
echo "**** install WireGuard ****" && \
rm -f /usr/sbin/resolvconf && \
apk add --no-cache \
  wireguard-tools \
  iptables \
  iproute2 \
  openresolv \
  curl && \
rm -rf /root/.cache && \
echo "**** done ****"

# Install BoringTun (latest release from Cloudflare)
RUN curl -L -o /usr/local/bin/boringtun \
    https://github.com/cloudflare/boringtun/releases/latest/download/boringtun-linux-amd64 && \
    chmod +x /usr/local/bin/boringtun

ENV WG_QUICK_USERSPACE_IMPLEMENTATION=boringtun
# DONE CUSTOMIZATIONS

# add local files
COPY root/ /

# add unrar
#COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

# ports and volumes
EXPOSE 8080 6881 6881/udp

VOLUME /config