#!/bin/bash
# Reusable Docker container deployment script
# This script handles the full lifecycle of deploying a containerized application

set -e  # Exit on error

# Required environment variables:
# - CONTAINER_NAME: Name for the container
# - IMAGE_TAG: Full Docker image tag to deploy
# - CONTAINER_PORT_MAPPING: Port mapping (e.g., "8080:8080")
# - ASPNETCORE_ENVIRONMENT: ASP.NET Core environment name (optional)
# - ENV_FILE_PATH: Path to environment file (optional)

# Function to check required variables
check_required_vars() {
    local missing_vars=()
    
    if [ -z "$CONTAINER_NAME" ]; then missing_vars+=("CONTAINER_NAME"); fi
    if [ -z "$IMAGE_TAG" ]; then missing_vars+=("IMAGE_TAG"); fi
    if [ -z "$CONTAINER_PORT_MAPPING" ]; then missing_vars+=("CONTAINER_PORT_MAPPING"); fi
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo "Error: Missing required environment variables: ${missing_vars[*]}"
        exit 1
    fi
}

# Function to pull Docker image
pull_image() {
    echo "Pulling Docker image: ${IMAGE_TAG}"
    docker pull "${IMAGE_TAG}"
}

# Function to stop and remove existing container
cleanup_existing_container() {
    echo "Cleaning up existing container: ${CONTAINER_NAME}"
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
}

# Function to run new container
run_container() {
    echo "Starting new container: ${CONTAINER_NAME}"
    
    local docker_run_cmd="docker run -d \
        --name ${CONTAINER_NAME} \
        --restart always \
        -p ${CONTAINER_PORT_MAPPING}"
    
    # Add environment file if provided
    if [ -n "$ENV_FILE_PATH" ] && [ -f "$ENV_FILE_PATH" ]; then
        docker_run_cmd="${docker_run_cmd} --env-file ${ENV_FILE_PATH}"
    fi
    
    # Add ASP.NET Core environment if provided
    if [ -n "$ASPNETCORE_ENVIRONMENT" ]; then
        docker_run_cmd="${docker_run_cmd} -e ASPNETCORE_ENVIRONMENT=${ASPNETCORE_ENVIRONMENT}"
    fi
    
    # Add any additional environment variables (EXTRA_ENV_VARS format: "KEY1=VALUE1 KEY2=VALUE2")
    if [ -n "$EXTRA_ENV_VARS" ]; then
        for env_var in $EXTRA_ENV_VARS; do
            docker_run_cmd="${docker_run_cmd} -e ${env_var}"
        done
    fi
    
    docker_run_cmd="${docker_run_cmd} ${IMAGE_TAG}"
    
    eval "$docker_run_cmd"
}

# Function to create systemd service for container persistence
create_systemd_service() {
    echo "Creating systemd service for container persistence"
    
    local service_file="/etc/systemd/system/${CONTAINER_NAME}.service"
    
    cat << EOF | sudo tee "$service_file" > /dev/null
[Unit]
Description=Docker Container ${CONTAINER_NAME}
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start ${CONTAINER_NAME}
ExecStop=/usr/bin/docker stop ${CONTAINER_NAME}
ExecReload=/usr/bin/docker restart ${CONTAINER_NAME}

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable "${CONTAINER_NAME}.service"
    echo "Systemd service created and enabled: ${CONTAINER_NAME}.service"
}

# Function to display deployment status
show_deployment_status() {
    echo "==================================="
    echo "Deployment Status"
    echo "==================================="
    echo "Container: ${CONTAINER_NAME}"
    echo "Image: ${IMAGE_TAG}"
    echo "Restart Policy: $(docker inspect ${CONTAINER_NAME} --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null || echo 'unknown')"
    echo "Systemd Service: $(systemctl is-enabled ${CONTAINER_NAME}.service 2>/dev/null || echo 'not created')"
    echo ""
    docker ps -a | grep "${CONTAINER_NAME}" || echo "Container not found!"
    echo ""
    echo "Recent container logs:"
    docker logs --tail 20 "${CONTAINER_NAME}" 2>/dev/null || echo "No logs available"
}

# Main deployment flow
main() {
    echo "Starting deployment process..."
    
    check_required_vars
    pull_image
    cleanup_existing_container
    run_container
    create_systemd_service
    cleanup_old_images
    show_deployment_status
    
    echo ""
    echo "Deployment completed successfully!"
}

# Execute main function
main
