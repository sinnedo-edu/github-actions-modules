# GitHub Actions Modules

A collection of reusable GitHub Actions and deployment scripts for streamlined CI/CD workflows. This repository provides modular, composable actions and shell scripts that can be used across multiple projects for container deployment, secrets management, and infrastructure automation.

## 📦 Repository Structure

```text
github-actions-modules/
├── actions/
│   ├── build-push-docker/         # Build and push Docker images
│   ├── detect-environment/        # Environment detection from branches/tags
│   ├── setup-doppler/            # Doppler secrets management
│   ├── setup-server/             # Server setup and configuration
│   └── ssh-deploy-base/          # Base SSH deployment action
├── scripts/
│   ├── deploy-orchestrator.sh    # Master deployment orchestrator
│   ├── deploy-container.sh       # Container lifecycle management
│   ├── doppler-setup.sh          # Doppler CLI setup and secrets download
│   ├── docker-registry-login.sh  # Docker registry authentication
│   └── setup-docker-server.sh    # Docker server initialization
├── ABSTRACTION_SUMMARY.md        # Architecture and design details
├── DEPLOYMENT_GUIDE.md           # Deployment instructions
├── DEPLOYMENT_CHECKLIST.md       # Pre-deployment verification
├── LICENSE                        # MIT License
└── README.md                      # This file
```

## 🚀 Available Actions

### 1. Build and Push Docker Image

Build Docker images and push them to a container registry with environment-specific tags.

```yaml
- uses: sinnedo-edu/github-actions-modules/actions/build-push-docker@v1
  with:
    linode_token: ${{ secrets.LINODE_TOKEN }}
    image_name: 'my-app'
    environment: 'production'
    sha: ${{ github.sha }}
```

**Features:**

- Docker Buildx support
- Multi-tag support (environment-latest, environment-sha)
- Build cache optimization
- Linode Container Registry integration

### 2. Detect Environment

Automatically detect the deployment environment based on branch or tag names.

```yaml
- uses: sinnedo-edu/github-actions-modules/actions/detect-environment@v1
  with:
    branch_prefixes: 'dev:development,staging:staging,main:production'
    tag_prefixes: 'v1-:production,v2-:staging'
    event_name: ${{ github.event_name }}
    ref: ${{ github.ref }}
```

**Supported Branches:**

- `main` → `prod`
- `beta` → `beta`
- `test` → `test`
- Others → `dev`

### 3. Setup Doppler

Install Doppler CLI and fetch secrets from your Doppler project.

```yaml
- uses: sinnedo-edu/github-actions-modules/actions/setup-doppler@v1
  with:
    doppler_token: ${{ secrets.DOPPLER_TOKEN }}
    environment: 'production'
    project: 'my-app'
```

**Features:**

- Automatic Doppler CLI installation
- Secrets downloaded and injected into environment
- Project and environment configuration

### 4. SSH Deploy Base

Reusable SSH deployment action for executing scripts on remote servers.

```yaml
- uses: sinnedo-edu/github-actions-modules/actions/ssh-deploy-base@v1
  with:
    host: ${{ secrets.DEPLOY_HOST }}
    username: ${{ secrets.DEPLOY_USER }}
    ssh_key: ${{ secrets.SSH_PRIVATE_KEY }}
    ssh_port: '22'
    envs: 'LINODE_TOKEN,DOPPLER_TOKEN,CONTAINER_NAME'
    script: |
      export OUTPUT_FILE="/tmp/secrets.env"
      curl -sS https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/main/scripts/deploy-orchestrator.sh | bash
```

**Features:**

- SSH authentication with private key
- Environment variable passthrough
- Configurable SSH port
- Based on `appleboy/ssh-action`

### 5. Setup Server

Initialize and configure a Docker-ready server environment.

```yaml
- uses: sinnedo-edu/github-actions-modules/actions/setup-server@v1
  with:
    # Server setup configuration
```

## 📜 Deployment Scripts

### Master Orchestrator

The `deploy-orchestrator.sh` script provides a single entry point for the entire deployment workflow.

**Usage:**

```bash
# Required environment variables
export LINODE_TOKEN="your-token"
export DOPPLER_PROJECT="my-app"
export DOPPLER_CONFIG="production"
export OUTPUT_FILE="/tmp/secrets.env"
export CONTAINER_NAME="my-app"
export IMAGE_TAG="registry.linode.com/my-app:prod-latest"
export CONTAINER_PORT_MAPPING="3000:3000"

# Optional
export ASPNETCORE_ENVIRONMENT="Production"
export SCRIPTS_VERSION="v1"  # Pin to specific version

# Run orchestrator
curl -sS https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/main/scripts/deploy-orchestrator.sh | bash
```

**What it does:**

1. Downloads all required deployment scripts
2. Sets up Doppler and downloads secrets
3. Authenticates with Docker registry
4. Deploys/updates the container
5. Cleans up temporary files

### Individual Scripts

#### `doppler-setup.sh`

Install Doppler CLI and download secrets.

```bash
source doppler-setup.sh
install_doppler
download_secrets
```

**Required Environment Variables:**

- `DOPPLER_PROJECT` - Doppler project name
- `DOPPLER_CONFIG` - Environment/config name
- `OUTPUT_FILE` - Path to save secrets

#### `docker-registry-login.sh`

Authenticate with Docker container registry.

```bash
source docker-registry-login.sh
docker_login
```

**Required Environment Variables:**

- `LINODE_TOKEN` - Linode API token

#### `deploy-container.sh`

Deploy or update a Docker container.

```bash
source deploy-container.sh
deploy_container
```

**Required Environment Variables:**

- `CONTAINER_NAME` - Name of the container
- `IMAGE_TAG` - Full image tag to deploy
- `CONTAINER_PORT_MAPPING` - Port mapping (e.g., "3000:3000")
- `ENV_FILE_PATH` - Path to environment file (from Doppler)

**Optional Environment Variables:**

- `ASPNETCORE_ENVIRONMENT` - ASP.NET Core environment setting

#### `setup-docker-server.sh`

Initialize a fresh server with Docker and required dependencies.

```bash
bash setup-docker-server.sh
```

## 💡 Usage Examples

### Complete Deployment Workflow

```yaml
name: Deploy Application

on:
  push:
    branches: [main, beta, test]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Detect Environment
        id: env
        uses: sinnedo-edu/github-actions-modules/actions/detect-environment@v1
        with:
          branch_prefixes: 'main:prod,beta:beta,test:test'
          event_name: ${{ github.event_name }}
          ref: ${{ github.ref }}

      - name: Build and Push Docker Image
        uses: sinnedo-edu/github-actions-modules/actions/build-push-docker@v1
        with:
          linode_token: ${{ secrets.LINODE_TOKEN }}
          image_name: 'my-app'
          environment: ${{ steps.env.outputs.environment }}
          sha: ${{ github.sha }}

      - name: Deploy to Server
        uses: sinnedo-edu/github-actions-modules/actions/ssh-deploy-base@v1
        env:
          LINODE_TOKEN: ${{ secrets.LINODE_TOKEN }}
          DOPPLER_TOKEN: ${{ secrets.DOPPLER_TOKEN }}
          DOPPLER_PROJECT: 'my-app'
          DOPPLER_CONFIG: ${{ steps.env.outputs.environment }}
          CONTAINER_NAME: 'my-app'
          IMAGE_TAG: registry.linode.com/my-app:${{ steps.env.outputs.environment }}-${{ github.sha }}
          CONTAINER_PORT_MAPPING: '3000:3000'
          OUTPUT_FILE: '/tmp/secrets.env'
        with:
          host: ${{ secrets.DEPLOY_HOST }}
          username: ${{ secrets.DEPLOY_USER }}
          ssh_key: ${{ secrets.SSH_PRIVATE_KEY }}
          envs: 'LINODE_TOKEN,DOPPLER_TOKEN,DOPPLER_PROJECT,DOPPLER_CONFIG,CONTAINER_NAME,IMAGE_TAG,CONTAINER_PORT_MAPPING,OUTPUT_FILE'
          script: |
            curl -sS https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/main/scripts/deploy-orchestrator.sh | bash
```

### Direct SSH Deployment (Without GitHub Actions)

```bash
ssh user@server << 'EOF'
  export LINODE_TOKEN="your-token"
  export DOPPLER_TOKEN="your-doppler-token"
  export DOPPLER_PROJECT="my-app"
  export DOPPLER_CONFIG="production"
  export OUTPUT_FILE="/tmp/secrets.env"
  export CONTAINER_NAME="my-app"
  export IMAGE_TAG="registry.linode.com/my-app:prod-latest"
  export CONTAINER_PORT_MAPPING="3000:3000"
  
  curl -sS https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/main/scripts/deploy-orchestrator.sh | bash
EOF
```

### Local Testing

```bash
# Clone the repository
git clone https://github.com/sinnedo-edu/github-actions-modules.git
cd github-actions-modules

# Set environment variables
export LINODE_TOKEN="your-token"
export DOPPLER_TOKEN="your-doppler-token"
export DOPPLER_PROJECT="my-app"
export DOPPLER_CONFIG="development"
export OUTPUT_FILE="/tmp/secrets.env"
export CONTAINER_NAME="my-app-dev"
export IMAGE_TAG="registry.linode.com/my-app:dev-latest"
export CONTAINER_PORT_MAPPING="3000:3000"

# Run orchestrator locally
./scripts/deploy-orchestrator.sh
```

## 🔧 Configuration

### Version Pinning

For production environments, pin to specific versions instead of using `main`:

```yaml
# Pin to major version (recommended)
uses: sinnedo-edu/github-actions-modules/actions/ssh-deploy-base@v1

# Pin to specific version
uses: sinnedo-edu/github-actions-modules/actions/ssh-deploy-base@v1.0.0
```

For scripts:

```bash
export SCRIPTS_VERSION="v1.0.0"
curl -sS https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/v1.0.0/scripts/deploy-orchestrator.sh | bash
```

### Environment Variables Reference

| Variable | Required | Description |
|----------|----------|-------------|
| `LINODE_TOKEN` | Yes | Linode API token for registry authentication |
| `DOPPLER_TOKEN` | Yes | Doppler service token |
| `DOPPLER_PROJECT` | Yes | Doppler project name |
| `DOPPLER_CONFIG` | Yes | Doppler config/environment |
| `OUTPUT_FILE` | Yes | Path to save secrets file |
| `CONTAINER_NAME` | Yes | Name of the Docker container |
| `IMAGE_TAG` | Yes | Full Docker image tag |
| `CONTAINER_PORT_MAPPING` | Yes | Port mapping (format: "host:container") |
| `ASPNETCORE_ENVIRONMENT` | No | ASP.NET Core environment setting |
| `SCRIPTS_VERSION` | No | Script version to use (default: main) |

## 🎯 Benefits

- **Modularity**: Use individual components or the complete orchestration
- **Reusability**: Share actions across multiple projects
- **Version Control**: Pin to specific versions for stability
- **Maintainability**: Update deployment logic in one place
- **Testability**: Test scripts independently before integration
- **Flexibility**: Combine actions to create custom workflows
- **Abstraction**: Hide complexity while maintaining control

## 📚 Documentation

- [Abstraction Summary](ABSTRACTION_SUMMARY.md) - Architecture and design details
- [Deployment Guide](DEPLOYMENT_GUIDE.md) - Step-by-step deployment instructions
- [Deployment Checklist](DEPLOYMENT_CHECKLIST.md) - Pre-deployment verification

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Keep scripts modular and focused on single responsibility
- Add comprehensive error handling with `set -e`
- Document all environment variables
- Include usage examples in comments
- Test scripts locally before committing
- Follow shell script best practices

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

This module repository is designed to work with various deployment scenarios:

- Container orchestration (Docker)
- Secrets management (Doppler)
- Container registries (Linode, others)
- CI/CD platforms (GitHub Actions)

## 📞 Support

For issues, questions, or contributions:

- **Issues**: [GitHub Issues](https://github.com/sinnedo-edu/github-actions-modules/issues)
- **Discussions**: [GitHub Discussions](https://github.com/sinnedo-edu/github-actions-modules/discussions)

## 🚦 Status

- ✅ Production Ready
- 🔄 Actively Maintained
- 📦 Semantic Versioning

---

Made with ❤️ for streamlined deployments
