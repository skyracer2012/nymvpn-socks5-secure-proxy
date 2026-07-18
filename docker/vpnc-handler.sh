#!/bin/sh
set -eu

until nym-vpnc info >/dev/null 2>&1; do
    echo "Waiting for nym-vpnd RPC..."
    sleep 1
done

ACCOUNT=$(nym-vpnc account get)

echo "$ACCOUNT"

if echo "$ACCOUNT" | grep -q "Account state: LoggedOut"; then
    echo "Logging in..."
    nym-vpnc account set "$NYM_SECRET"
fi

nym-vpnc tunnel set --two-hop on

if [ -n "${NYM_ENTRY_COUNTRY:-}" ]; then
    nym-vpnc gateway set --entry-country "$NYM_ENTRY_COUNTRY"
else
    nym-vpnc gateway set --entry-random
fi

if [ -n "${NYM_EXIT_COUNTRY:-}" ]; then
    nym-vpnc gateway set --exit-country "$NYM_EXIT_COUNTRY"
else
    nym-vpnc gateway set --exit-random
fi

if [ "${NYM_RESIDENTIAL_EXIT:-false}" = "true" ]; then
    nym-vpnc gateway set --residential-exit on
else
    nym-vpnc gateway set --residential-exit off
fi

nym-vpnc lan set allow
nym-vpnc connect --wait

while ! nym-vpnc status | grep -q "State: Connected"; do
    echo "$(date): waiting for VPN..."
    nym-vpnc status || true
    sleep 2
done

echo "VPN connected, enabling SOCKS"
exec microsocks -i 0.0.0.0 -p 1080 -u "$SOCKS_USER" -P "$SOCKS_PASS"