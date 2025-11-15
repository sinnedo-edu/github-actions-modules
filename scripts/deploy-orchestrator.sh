#!/bin/bash
# Master deployment orchestration script
# Handles downloading modules, registry login, secrets, and deployment

set -e  # Exit on error

# Configuration
SCRIPTS_REPO="https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/main/scripts"
TEMP_DIR="/tmp"

# Required environment variables will be validated by individual scripts
# But we can list them here for documentation:
# - LINODE_TOKEN: For registry authentication
# - DOPPLER_PROJECT: Doppler project name
# - DOPPLER_CONFIG: Doppler config/environment
# - OUTPUT_FILE: Path for secrets file
# - CONTAINER_NAME: Container name
# - IMAGE_TAG: Docker image tag
# - CONTAINER_PORT_MAPPING: Port mapping
# Optional:
# - ASPNETCORE_ENVIRONMENT: ASP.NET Core environment
# - SCRIPTS_VERSION: Version/branch to use (default: main)
# - DOMAIN: Domain name for SSL certificate (default: sinnedo.com)
# - APP_PORT: Internal application port (default: 8080)

SCRIPTS_VERSION="${SCRIPTS_VERSION:-main}"
SCRIPTS_BASE="https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/${SCRIPTS_VERSION}/scripts"

echo "========================================="
echo "Starting Deployment Orchestration"
echo "========================================="

# Download required scripts
echo "Downloading deployment modules..."
curl -sS "${SCRIPTS_BASE}/doppler-setup.sh" -o "${TEMP_DIR}/doppler-setup.sh"
curl -sS "${SCRIPTS_BASE}/docker-registry-login.sh" -o "${TEMP_DIR}/docker-registry-login.sh"
curl -sS "${SCRIPTS_BASE}/deploy-container.sh" -o "${TEMP_DIR}/deploy-container.sh"
curl -sS "${SCRIPTS_BASE}/setup-ssl.sh" -o "${TEMP_DIR}/setup-ssl.sh"
chmod +x "${TEMP_DIR}"/*.sh

echo "Modules downloaded successfully"
echo ""

# Setup Doppler and download secrets
echo "========================================="
echo "Step 1: Setting up secrets with Doppler"
echo "========================================="
source "${TEMP_DIR}/doppler-setup.sh"
install_doppler
download_secrets
echo ""

# Login to Container Registry
echo "========================================="
echo "Step 2: Authenticating with registry"
echo "========================================="
source "${TEMP_DIR}/docker-registry-login.sh"
linode_registry_login
echo ""

# Deploy the container
echo "========================================="
echo "Step 3: Deploying container"
echo "========================================="
"${TEMP_DIR}/deploy-container.sh"
echo ""

# Setup SSL/HTTPS
echo "========================================="
echo "Step 4: Configuring SSL/HTTPS"
echo "========================================="
"${TEMP_DIR}/setup-ssl.sh"
echo ""

# Cleanup
echo "========================================="
echo "Step 5: Cleanup"
echo "========================================="
cleanup_secrets "${OUTPUT_FILE}"
rm -f "${TEMP_DIR}/doppler-setup.sh" "${TEMP_DIR}/docker-registry-login.sh" "${TEMP_DIR}/deploy-container.sh" "${TEMP_DIR}/setup-ssl.sh"
echo "Cleanup completed"
echo ""

echo "========================================="
echo "Deployment Completed Successfully!"
echo "========================================="
