# NymVPN SOCKS5 Proxy

NymVPN to SOCKS5 with username and password authentification. Exposed to port 1080 in the container.

> [!CAUTION]
> Keep in mind that you will need to wrap SOCKS5 in TLS before using it securely!  
> SOCKS5 is UNENCRYPTED by itself!

# Usage

## Setup
The simplest way to get started is using this `docker-compose.yml`:

```yaml
services:
  nymvpn-socks-proxy:
    image: todo
    container_name: nymvpn-socks-proxy
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
    ports:
      - "127.0.0.1:1080:1080"
    volumes:
      - nym-config:/etc/nym
      - nym-state:/var/lib/nym-vpnd
    environment:
      NYM_SECRET: "${NYM_SECRET}"
      NYM_ENTRY_COUNTRY: "${NYM_ENTRY_COUNTRY}"
      NYM_EXIT_COUNTRY: "${NYM_EXIT_COUNTRY}"
      NYM_RESIDENTIAL_EXIT: "${NYM_RESIDENTIAL_EXIT}"
      SOCKS_USER: "${SOCKS_USER}"
      SOCKS_PASS: "${SOCKS_PASS}"
volumes:
  nym-config:
  nym-state:
```

You can define the enviroment variables either directly in the compose or use a `.env` file (recommended)  
To do this, copy the `.env.example` file and edit it as per your needs.  
The program will not work without having an active, paid NymVPN account.

## Test

You can test if the proxy is working by running:
```shell
curl --proxy socks5h://user:password@127.0.0.1:1080 https://ifconfig.me
```
Keep in mind to check if the IP-Address is different! If you are not using socks5h, you will leak your DNS-Queries.

## Inspiration
This repo was inspired by  
https://github.com/speeddragon/nym-docker
and
https://github.com/cs224/docker-nymvpn-socks5