#!/bin/sh -e

# Enable debug if requested
if [ "${DEBUG}" = "true" ]; then
  set -x
fi

# If command is provided run that
if [ "${1:0:1}" != '-' ]; then
  exec "$@"
fi

echo 'Verifying environment'

# TODO: Detect --net=host and fail

# Check for CAP_NET_ADMIN
if ! iptables -nL &> /dev/null; then
  >&2 echo 'Container requires CAP_NET_ADMIN, add using `--cap-add NET_ADMIN`.'
  exit 1
fi

# Ensure that the container only has eth0 and lo to start with
for interface in $(ip link show | awk '/^[0-9]*:/ {print $2}' | sed -e 's/:$//' -e 's/@.*$//'); do
  if [ "$interface" != "lo" ] && [ "$interface" != "eth0" ]; then
    >&2 echo 'Container should only have the `eth0` and `lo` interfaces'
    >&2 echo 'Additional interfaces should only be added once tor has been started'
    >&2 echo 'Killing to avoid accidental clobbering'
    exit 1
  fi
done

echo 'Setting up container'

# Rstr
iptables-restore "${TOR_ROUTER_HOME}/iptables.rules"

# Set Tor control port password
if [ -n "${TOR_CONTROL_PASSWORD}" ]; then
    echo 'Enabling Tor control port'
    HASHED_CONTROL_PASSWORD=$(exec sudo -u "${TOR_ROUTER_USER}" \
        tor --hash-password "${TOR_CONTROL_PASSWORD}")
    cat <<EOT >> "${TOR_CONFIG_FILE}"

# Setup Tor control port
ControlPort 0.0.0.0:9051
HashedControlPassword ${HASHED_CONTROL_PASSWORD}
EOT
fi

# Run tor as the TOR_ROUTER_USER
echo 'Starting the Tor router'
exec sudo -u "${TOR_ROUTER_USER}" tor -f "${TOR_CONFIG_FILE}" "$@"
