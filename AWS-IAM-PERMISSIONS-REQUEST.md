# AWS IAM Permissions Request

## Current Issue
User `demo-access-key-user` cannot deploy to AWS ECR/ECS due to missing permissions.

## Error Messages
```
✗ ecr:GetAuthorizationToken - Cannot login to ECR
✗ ecr:CreateRepository - Cannot create ECR repository
✗ ecr:PutImage - Cannot push Docker images
✗ ecs:* - Cannot deploy to ECS
```

## Required IAM Policies

Please ask your AWS administrator to attach these policies to user: **demo-access-key-user**

### Option 1: Use AWS Managed Policies (Recommended)

```bash
# ECR Full Access
aws iam attach-user-policy \
  --user-name demo-access-key-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

# ECS Full Access (if deploying to ECS)
aws iam attach-user-policy \
  --user-name demo-access-key-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess
```

### Option 2: Create Custom Policy (Minimal Permissions)

Create a custom policy with only required permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:CreateRepository",
        "ecr:DescribeRepositories",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "*"
    }
  ]
}
```

Save as `ecr-deployment-policy.json` and attach:

```bash
# Create policy
aws iam create-policy \
  --policy-name ECRDeploymentPolicy \
  --policy-document file://ecr-deployment-policy.json

# Attach to user
aws iam attach-user-policy \
  --user-name demo-access-key-user \
  --policy-arn arn:aws:iam::466897160569:policy/ECRDeploymentPolicy
```

## Verification

After applying permissions, verify with:

```bash
# Test ECR access
aws ecr describe-repositories --region us-east-1

# Test create repository
aws ecr create-repository \
  --repository-name angular-fastify-app \
  --region us-east-1
```

## Once Fixed

1. Re-run the GitHub Actions workflow
2. Or push a new commit to trigger automatic deployment

---

**Account Details:**
- AWS Account ID: `466897160569`
- User: `demo-access-key-user`
- User ARN: `arn:aws:iam::466897160569:user/demo-access-key-user`
- Region: `us-east-1`
