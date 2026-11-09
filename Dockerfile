FROM debian:trixie-slim AS runtime

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      dbus \
      polkitd \
      iproute2 \
      curl \
      ca-certificates \
      microsocks \
      supervisor \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/dbus

ARG NYM_VPND_URL="https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v2026.15.0/nym-vpnd_2026.15.0_amd64.deb"
ARG NYM_VPND_SHA256="15cf20f7617cef8ae8bcf2dbdd036c476a6d9309472883de276f2bdbd48621f3"

ARG NYM_VPNC_URL="https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v2026.15.0/nym-vpnc_2026.15.0_amd64.deb"
ARG NYM_VPNC_SHA256="acf6f1da2503d024e81ea48b7b1f6e1ab00b3a5edb5aa494cac60be0827656e5"

ADD --checksum=sha256:${NYM_VPND_SHA256} \
    ${NYM_VPND_URL} \
    /tmp/nym-vpnd.deb

ADD --checksum=sha256:${NYM_VPNC_SHA256} \
    ${NYM_VPNC_URL} \
    /tmp/nym-vpnc.deb

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      /tmp/nym-vpnd.deb \
      /tmp/nym-vpnc.deb \
 && rm -rf /var/lib/apt/lists/* /tmp/nym-vpnd.deb /tmp/nym-vpnc.deb

COPY docker/nym-polkit.rules /etc/polkit-1/rules.d/49-nym-polkit.rules
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/vpnc-handler.sh /usr/local/bin/vpnc-handler.sh

RUN chmod +x /usr/local/bin/vpnc-handler.sh

EXPOSE 1080
CMD ["supervisord", "-n", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
