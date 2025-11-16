#!/bin/bash

set -e

DOMAIN="${DOMAIN:-sinnedo.com}"
APP_PORT="${APP_PORT:-8080}"

echo "Setting up https with Caddy for ${DOMAIN} on port ${APP_PORT}"

# Install Caddy if not installed
if ! command -v caddy &> /dev/null; then
    echo "Caddy not found, installing..."

    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

    sudo apt update
    sudo apt install -y caddy

    # Configure Caddy
    cat <<EOF | sudo tee /etc/caddy/Caddyfile
${DOMAIN} {
    reverse_proxy localhost:${APP_PORT}
}
EOF

    # Restart Caddy to apply changes
    sudo systemctl restart caddy
    sudo systemctl enable caddy

    echo "Caddy installed and configured successfully."
else
    echo "Caddy is already installed."
fi
echo "HTTPS setup complete for ${DOMAIN}."