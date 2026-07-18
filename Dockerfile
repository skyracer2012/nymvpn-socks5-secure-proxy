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

ARG NYM_VPND_URL="https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v2026.11.1/nym-vpnd_2026.11.1_amd64.deb"
ARG NYM_VPND_SHA256="5d8b5e5d36a5de6eeef03e62abb8c88951a21d0755bc2ac76cf72c786ea8b8a1"

ARG NYM_VPNC_URL="https://github.com/nymtech/nym-vpn-client/releases/download/nym-vpn-v2026.11.1/nym-vpnc_2026.11.1_amd64.deb"
ARG NYM_VPNC_SHA256="7f1c37438832e5c19c0780487e2e6132884e977a23606199b825e43b1df38423"

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
