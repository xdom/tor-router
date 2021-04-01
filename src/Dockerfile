FROM alpine:3.13

# Install the required packages
RUN apk add --update tor iptables sudo

# Expose the ports made available through Tor
EXPOSE 9001 9040 9050 9051 5353/udp

# Populate the tor-router configurations
COPY . /opt/tor-router

# Configure environment variables
ENV TOR_ROUTER_USER "tor-router"
ENV TOR_ROUTER_UID "9001"
ENV TOR_ROUTER_HOME "/opt/tor-router"
ENV TOR_CONFIG_FILE "${TOR_ROUTER_HOME}/torrc"

# Setup the TOR_ROUTER_USER
RUN adduser -h "${TOR_ROUTER_HOME}" -u "${TOR_ROUTER_UID}" -D "${TOR_ROUTER_USER}"

# Set the container's WORKDIR and ENTRYPOINT
WORKDIR /opt/tor-router
ENTRYPOINT ["/opt/tor-router/entrypoint.sh"]
