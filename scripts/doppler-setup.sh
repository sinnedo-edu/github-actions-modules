#!/bin/bash
# Reusable Doppler CLI installation and secrets management script

set -e  # Exit on error

# Function to install Doppler CLI if not present
install_doppler() {
    if ! command -v doppler &> /dev/null; then
        echo "Installing Doppler CLI..."
        curl -Ls --tlsv1.2 --proto "=https" --retry 3 https://cli.doppler.com/install.sh | sudo sh
        echo "Doppler CLI installed successfully"
    else
        echo "Doppler CLI already installed"
    fi
}

# Function to download secrets from Doppler
# Required environment variables:
# - DOPPLER_PROJECT: Doppler project name
# - DOPPLER_CONFIG: Doppler config name (environment)
# - OUTPUT_FILE: Path where to save the secrets file
download_secrets() {
    if [ -z "$DOPPLER_PROJECT" ] || [ -z "$DOPPLER_CONFIG" ] || [ -z "$OUTPUT_FILE" ]; then
        echo "Error: DOPPLER_PROJECT, DOPPLER_CONFIG, and OUTPUT_FILE must be set"
        exit 1
    fi
    
    echo "Downloading secrets from Doppler (Project: ${DOPPLER_PROJECT}, Config: ${DOPPLER_CONFIG})"
    doppler secrets download \
        --no-file \
        --format docker \
        --project "${DOPPLER_PROJECT}" \
        --config "${DOPPLER_CONFIG}" \
        > "${OUTPUT_FILE}"
    
    echo "Secrets saved to ${OUTPUT_FILE}"
}

# Function to cleanup secrets file
cleanup_secrets() {
    if [ -n "$1" ] && [ -f "$1" ]; then
        echo "Cleaning up secrets file: $1"
        rm -f "$1"
    fi
}

# Main function for complete Doppler setup
main() {
    local action="${1:-install}"
    
    case "$action" in
        install)
            install_doppler
            ;;
        download)
            install_doppler
            download_secrets
            ;;
        cleanup)
            cleanup_secrets "$2"
            ;;
        *)
            echo "Usage: $0 {install|download|cleanup} [file_path]"
            echo "  install  - Install Doppler CLI"
            echo "  download - Install Doppler CLI and download secrets"
            echo "  cleanup  - Remove secrets file (requires file path)"
            exit 1
            ;;
    esac
}

# Allow sourcing this script or running it directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    main "$@"
fi
