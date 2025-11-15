#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DOCKER="${INSTALL_DOCKER:-true}"
DOCKER_USER="${DOCKER_USER:-$USER}"
INSTALL_COMPOSE="${INSTALL_COMPOSE:-true}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Server Setup for Docker Deployments${NC}"
echo -e "${GREEN}========================================${NC}"

if [! -f /etc/debian_version ]; then
    echo -e "${RED}This script is intended for Debian-based systems.${NC}"
    exit 1
fi

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Docker
if [ "$INSTALL_DOCKER" = "true" ]; then
    if command_exists docker; then
        echo -e "${YELLOW}Docker is already installed.${NC}"
        docker --version
    else
        echo -e "${GREEN}Installing Docker...${NC}"
        
        # Update package index
        sudo apt-get update
        
        # Install prerequisites
        sudo apt-get install -y ca-certificates curl gnupg lsb-release
        
        # Add Docker's official GPG key
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        # Set up Docker repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker Engine
        sudo apt-get update
        
        if [ "$INSTALL_COMPOSE" = "true" ]; then
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        else
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        fi
        
        # Start and enable Docker
        sudo systemctl start docker
        sudo systemctl enable docker
        
        # Add user to docker group
        sudo usermod -aG docker "$DOCKER_USER"
        
        echo -e "${GREEN}Docker installed successfully!${NC}"
        docker --version
    fi
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Note: If you added a user to the docker group, log out and back in for changes to take effect.${NC}"
echo -e "${YELLOW}Or run: newgrp docker${NC}"