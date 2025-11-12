#!/bin/bash
# Reusable Docker registry authentication script

set -e  # Exit on error

# Function to login to Linode Container Registry
# Required environment variables:
# - LINODE_TOKEN: Linode API token
linode_registry_login() {
    if [ -z "$LINODE_TOKEN" ]; then
        echo "Error: LINODE_TOKEN environment variable must be set"
        exit 1
    fi
    
    echo "Logging into Linode Container Registry..."
    echo "$LINODE_TOKEN" | docker login registry.linode.com -u "$LINODE_TOKEN" --password-stdin
    echo "Successfully logged into Linode Container Registry"
}

# Function to login to generic Docker registry
# Required environment variables:
# - REGISTRY_URL: Docker registry URL
# - REGISTRY_USERNAME: Registry username
# - REGISTRY_PASSWORD: Registry password/token
generic_registry_login() {
    if [ -z "$REGISTRY_URL" ] || [ -z "$REGISTRY_USERNAME" ] || [ -z "$REGISTRY_PASSWORD" ]; then
        echo "Error: REGISTRY_URL, REGISTRY_USERNAME, and REGISTRY_PASSWORD must be set"
        exit 1
    fi
    
    echo "Logging into Docker registry: ${REGISTRY_URL}"
    echo "$REGISTRY_PASSWORD" | docker login "$REGISTRY_URL" -u "$REGISTRY_USERNAME" --password-stdin
    echo "Successfully logged into registry"
}

# Main function
main() {
    local registry_type="${1:-linode}"
    
    case "$registry_type" in
        linode)
            linode_registry_login
            ;;
        generic)
            generic_registry_login
            ;;
        *)
            echo "Usage: $0 {linode|generic}"
            echo "  linode  - Login to Linode Container Registry (requires LINODE_TOKEN)"
            echo "  generic - Login to generic Docker registry (requires REGISTRY_URL, REGISTRY_USERNAME, REGISTRY_PASSWORD)"
            exit 1
            ;;
    esac
}

# Allow sourcing this script or running it directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    main "$@"
fi
