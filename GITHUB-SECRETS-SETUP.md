# 🔐 GitHub Secrets Setup Guide

## Quick Setup (5 minutes)

### Step 1: Go to Your Repository Settings

1. Open: https://github.com/vnyrjkmr/angular-fastify-deployment
2. Click **Settings** tab (top of page)
3. In left sidebar, click **Secrets and variables** → **Actions**

### Step 2: Add AWS Secrets

Click **"New repository secret"** button and add these **THREE** secrets:

#### Secret 1: AWS Access Key ID
```
Name:  AWS_ACCESS_KEY_ID
Value: [Get from: C:\Users\LENOVO\.aws\credentials - aws_access_key_id]
```

#### Secret 2: AWS Secret Access Key
```
Name:  AWS_SECRET_ACCESS_KEY
Value: [Get from: C:\Users\LENOVO\.aws\credentials - aws_secret_access_key]
```

#### Secret 3: AWS Account ID (Optional)
```
Name:  AWS_ACCOUNT_ID
Value: 466897160569
```

**To get your credentials:**
1. Open PowerShell
2. Run: `Get-Content $env:USERPROFILE\.aws\credentials`
3. Copy the values shown there

### Step 3: Trigger Deployment

After adding all secrets, go to:
https://github.com/vnyrjkmr/angular-fastify-deployment/actions

Then either:
- **Push a new commit** to trigger the workflow
- Or click **"Run workflow"** button to manually trigger it

---

## ✅ Verification

Once secrets are added:
1. The workflow will run automatically on next push
2. Check: https://github.com/vnyrjkmr/angular-fastify-deployment/actions
3. You should see a green checkmark ✓ when deployment succeeds

---

## 🚨 Important Security Notes

- **NEVER** commit AWS credentials to your repository
- These secrets are encrypted by GitHub
- Only GitHub Actions workflows can access them
- You can update/delete them anytime in Settings

---

## 📝 After Setup

Once secrets are configured, delete this file for security:
```bash
git rm GITHUB-SECRETS-SETUP.md
git commit -m "Remove secrets setup guide"
git push
```
