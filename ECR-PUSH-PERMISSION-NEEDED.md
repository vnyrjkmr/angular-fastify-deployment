# 🚨 URGENT: ECR Push Permission Needed

## Current Status
- ✅ ECR repository `angular-fastify-app` exists
- ✅ You can read/describe the repository
- ❌ **Cannot push images** (403 Forbidden)

## Quick Fix Required

Your AWS administrator needs to run **ONE command**:

```bash
aws iam attach-user-policy \
  --user-name demo-access-key-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
```

This gives you permission to:
- ✅ Push images to ECR
- ✅ Pull images from ECR
- ✅ Manage repository contents
- ❌ Cannot delete repositories (safe)

---

## Alternative: Add Specific Permissions

If Power User access is too broad, add only push permissions:

### Step 1: Create inline policy
```bash
aws iam put-user-policy \
  --user-name demo-access-key-user \
  --policy-name ECRPushPolicy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        "Resource": "arn:aws:ecr:us-east-1:466897160569:repository/angular-fastify-app"
      },
      {
        "Effect": "Allow",
        "Action": "ecr:GetAuthorizationToken",
        "Resource": "*"
      }
    ]
  }'
```

---

## Verify Permissions Work

After applying, test with:

```bash
# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 466897160569.dkr.ecr.us-east-1.amazonaws.com

# Push test image
docker tag angular-fastify-app 466897160569.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:test
docker push 466897160569.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:test
```

If successful, you'll see:
```
✓ Pushed successfully
```

---

## Timeline
- **Current:** 403 Forbidden when pushing
- **After fix:** ~1 minute
- **Deployment:** Run `.\deploy-to-aws.ps1` again

---

**Send this file to your AWS administrator for immediate action.**
