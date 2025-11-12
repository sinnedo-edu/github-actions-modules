# Deployment Guide for GitHub Actions Modules

## 📋 What's Been Prepared

All reusable scripts and actions have been exported to:
```
github-actions-modules-export/
├── scripts/
│   ├── deploy-container.sh
│   ├── doppler-setup.sh
│   └── docker-registry-login.sh
├── actions/
│   └── ssh-deploy-base/
│       └── action.yml
├── README.md
└── LICENSE
```

## 🚀 Deployment Steps

### 1. Copy Files to github-actions-modules Repository

Navigate to your existing repository:

```powershell
cd path\to\github-actions-modules
```

Copy the exported files:

```powershell
# From this project's root
Copy-Item -Path "github-actions-modules-export\*" -Destination "path\to\github-actions-modules\" -Recurse -Force
```

Or manually copy the contents of `github-actions-modules-export/` to your `github-actions-modules` repository.

### 2. Commit and Push to GitHub

```powershell
cd path\to\github-actions-modules

git add .
git commit -m "Add reusable deployment scripts and actions"
git push origin main
```

### 3. Create a Version Tag (Recommended)

```powershell
# Create and push v1.0.0 tag
git tag -a v1.0.0 -m "Initial release with deployment scripts"
git push origin v1.0.0

# Also create v1 tag for easy updates
git tag -a v1 -m "Version 1.x"
git push origin v1
```

### 4. Update This Project

The `deploy-linode` action has already been updated to reference the external repository:

- Changed from: `./.github/actions/ssh-deploy-base`
- Changed to: `sinnedo-edu/github-actions-modules/actions/ssh-deploy-base@main`

Script URLs now point to:
```
https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/main/scripts/...
```

### 5. Test the Changes

After deploying to `github-actions-modules`:

1. Commit the updated `deploy-linode/action.yml` in this project
2. Push to trigger your deployment workflow
3. Verify that scripts are downloaded from the external repository

## 🔄 Version Pinning (Recommended for Production)

Once deployed, update the action to use a specific version:

```yaml
# In deploy-linode/action.yml, change:
uses: sinnedo-edu/github-actions-modules/actions/ssh-deploy-base@main

# To:
uses: sinnedo-edu/github-actions-modules/actions/ssh-deploy-base@v1
```

For scripts, use tagged URLs:
```bash
curl -sS https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/v1.0.0/scripts/deploy-container.sh
```

## 📦 Using in Other Projects

Any project can now use these modules:

### Option 1: Reference Actions Directly

```yaml
- name: Deploy
  uses: sinnedo-edu/github-actions-modules/actions/ssh-deploy-base@v1
  with:
    host: ${{ secrets.SERVER_HOST }}
    username: ${{ secrets.SSH_USERNAME }}
    ssh_key: ${{ secrets.SSH_KEY }}
    script: |
      # Your deployment commands
```

### Option 2: Download Scripts

```bash
curl -sS https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/main/scripts/deploy-container.sh -o deploy.sh
chmod +x deploy.sh
./deploy.sh
```

## 🧹 Cleanup (Optional)

After successfully deploying and testing, you can remove the local copies:

```powershell
# Remove local scripts (they're now pulled from external repo)
Remove-Item -Path ".github\scripts" -Recurse -Force

# Remove local ssh-deploy-base action (now using external)
Remove-Item -Path ".github\actions\ssh-deploy-base" -Recurse -Force

# Remove the export directory
Remove-Item -Path "github-actions-modules-export" -Recurse -Force
```

⚠️ **Note**: Only do this after confirming the external repository is working correctly!

## ✅ Verification Checklist

- [ ] Files copied to github-actions-modules repository
- [ ] Committed and pushed to GitHub
- [ ] Version tags created (v1.0.0, v1)
- [ ] Updated deploy-linode action tested
- [ ] Scripts accessible via raw.githubusercontent.com URLs
- [ ] Local copies removed (optional, after verification)

## 🆘 Troubleshooting

### Scripts not found (404 error)
- Verify the repository is public or provide authentication
- Check the branch name (main vs master)
- Ensure files are committed and pushed

### Action not found
- Wait a few minutes after pushing (GitHub Actions cache)
- Verify the path: `sinnedo-edu/github-actions-modules/actions/ssh-deploy-base`
- Check repository visibility settings

### Permission denied
- Ensure scripts have execute permissions (`chmod +x`)
- Check SSH key has proper permissions on the server
