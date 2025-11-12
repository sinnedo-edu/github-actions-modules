# Deployment Checklist

Use this checklist when deploying the modules to github-actions-modules repository.

## 📋 Pre-Deployment

- [ ] Review all files in `github-actions-modules-export/`
- [ ] Verify scripts have correct shebang (`#!/bin/bash`)
- [ ] Ensure all documentation is accurate
- [ ] Check that repository URLs are correct

## 🚀 Deployment Steps

### Step 1: Copy Files
- [ ] Navigate to `github-actions-modules` repository
- [ ] Copy all files from `github-actions-modules-export/`
- [ ] Verify file structure matches:
  ```
  github-actions-modules/
  ├── scripts/
  │   ├── deploy-orchestrator.sh
  │   ├── deploy-container.sh
  │   ├── doppler-setup.sh
  │   └── docker-registry-login.sh
  ├── actions/
  │   └── ssh-deploy-base/
  │       └── action.yml
  ├── README.md
  ├── LICENSE
  ├── DEPLOYMENT_GUIDE.md
  └── ABSTRACTION_SUMMARY.md
  ```

### Step 2: Git Operations
- [ ] `git add .`
- [ ] `git commit -m "Add reusable deployment modules v1.0.0"`
- [ ] `git push origin main`
- [ ] Wait for push to complete

### Step 3: Create Version Tags
- [ ] `git tag -a v1.0.0 -m "Initial release - deployment orchestration modules"`
- [ ] `git tag -a v1 -m "Version 1.x - latest"`
- [ ] `git push origin v1.0.0`
- [ ] `git push origin v1`

### Step 4: Verify Deployment
- [ ] Visit: https://github.com/sinnedo-edu/github-actions-modules
- [ ] Check all files are visible
- [ ] Verify tags exist in releases/tags section
- [ ] Test raw URL: https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/main/scripts/deploy-orchestrator.sh

## ✅ Post-Deployment Testing

### Test in Current Project (group1-workshop)

- [ ] Commit updated `deploy-linode/action.yml`
- [ ] Push to trigger deployment workflow
- [ ] Monitor workflow execution
- [ ] Verify orchestrator downloads successfully
- [ ] Check deployment completes without errors
- [ ] Review deployment logs

### Test Script Access
Run these commands to verify scripts are accessible:

```bash
# Test orchestrator download
curl -I https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/main/scripts/deploy-orchestrator.sh

# Should return: HTTP/2 200

# Test with version tag
curl -I https://raw.githubusercontent.com/sinnedo-edu/github-actions-modules/v1.0.0/scripts/deploy-orchestrator.sh

# Should return: HTTP/2 200
```

## 🧹 Optional Cleanup (After Verification)

Only do this after confirming everything works:

- [ ] Delete `.github/scripts/` directory (scripts now external)
- [ ] Delete `.github/actions/ssh-deploy-base/` (now external)
- [ ] Delete `github-actions-modules-export/` (no longer needed)
- [ ] Update `.github/README.md` to reference external modules
- [ ] Commit cleanup changes

## 📝 Update Other Projects

For each project that needs deployment:

- [ ] Copy deployment workflow pattern from group1-workshop
- [ ] Update environment variables
- [ ] Test deployment
- [ ] Document project-specific configurations

## 🎉 Success Criteria

You'll know it's working when:

- ✅ github-actions-modules repository has all files
- ✅ Version tags exist (v1.0.0, v1)
- ✅ Scripts are downloadable via raw.githubusercontent.com
- ✅ group1-workshop deployment workflow runs successfully
- ✅ Orchestrator downloads and executes all modules
- ✅ Container deploys without errors

## 🆘 Troubleshooting

### Scripts return 404
- Check repository is public
- Verify file paths are correct
- Ensure commits are pushed
- Wait a few minutes for GitHub cache

### Action not found
- Verify path: `sinnedo-edu/github-actions-modules/actions/ssh-deploy-base@v1`
- Check repository visibility
- Confirm action.yml exists in correct location

### Deployment fails
- Check all environment variables are set
- Review logs for specific error messages
- Verify DOPPLER_TOKEN is valid
- Ensure LINODE_TOKEN has correct permissions

## 📞 Support Resources

- GitHub Actions Docs: https://docs.github.com/en/actions
- Repository: https://github.com/sinnedo-edu/github-actions-modules
- Issues: https://github.com/sinnedo-edu/github-actions-modules/issues
