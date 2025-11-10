# 🚀 Quick AWS Deployment Guide

Choose your deployment method and follow the steps below.

## 📋 Before You Start

1. **AWS Account**: Ensure you have an AWS account
2. **AWS CLI**: Install and configure AWS CLI
   ```powershell
   # Install AWS CLI
   # Download from: https://aws.amazon.com/cli/
   
   # Configure credentials
   aws configure
   # Enter: AWS Access Key ID
   # Enter: AWS Secret Access Key
   # Enter: Default region (e.g., us-east-1)
   # Enter: Default output format (json)
   ```

3. **Test Local Build**:
   ```powershell
   docker-compose up --build
   ```

---

## 🎯 Option 1: Automated Script (Recommended)

Use the PowerShell script for easiest deployment:

```powershell
# Run the deployment script
.\deploy-to-aws.ps1

# Select option:
# 1 = Build and push to ECR only
# 2 = Build, push, and prepare ECS deployment
# 3 = Build, push, and prepare Elastic Beanstalk deployment
```

---

## 🎯 Option 2: AWS Elastic Beanstalk (Simplest)

### Step 1: Install EB CLI
```powershell
pip install awsebcli --upgrade
```

### Step 2: Initialize and Deploy
```powershell
# Initialize Elastic Beanstalk
eb init -p docker angular-fastify-app --region us-east-1

# Create environment and deploy
eb create angular-fastify-env --instance-type t3.micro

# Open application
eb open
```

### Update Dockerrun.aws.json
Replace `YOUR_AWS_ACCOUNT_ID` with your actual AWS account ID.

---

## 🎯 Option 3: AWS ECS Fargate (Production-Ready)

### Step 1: Build and Push to ECR
```powershell
# Get your AWS account ID
$AWS_ACCOUNT_ID = aws sts get-caller-identity --query Account --output text

# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Create ECR repository
aws ecr create-repository --repository-name angular-fastify-app --region us-east-1

# Build and tag image
docker build -t angular-fastify-app .
docker tag angular-fastify-app:latest $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:latest

# Push to ECR
docker push $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:latest
```

### Step 2: Update Task Definition
Edit `aws-ecs-task-definition.json`:
- Replace `YOUR_AWS_ACCOUNT_ID` with your account ID
- Update `executionRoleArn` (create role if needed)

### Step 3: Create ECS Cluster
```powershell
aws ecs create-cluster --cluster-name angular-fastify-cluster --region us-east-1
```

### Step 4: Register Task Definition
```powershell
aws ecs register-task-definition --cli-input-json file://aws-ecs-task-definition.json --region us-east-1
```

### Step 5: Create ECS Service
```powershell
# You'll need VPC subnet and security group IDs
# Get default VPC
$VPC_ID = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text --region us-east-1

# Get subnets
$SUBNET_IDS = aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[*].SubnetId" --output text --region us-east-1

# Create security group
$SG_ID = aws ec2 create-security-group --group-name angular-fastify-sg --description "Security group for Angular Fastify app" --vpc-id $VPC_ID --query "GroupId" --output text --region us-east-1

# Allow inbound traffic on port 3000
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp --port 3000 --cidr 0.0.0.0/0 --region us-east-1

# Create ECS service
aws ecs create-service `
  --cluster angular-fastify-cluster `
  --service-name angular-fastify-service `
  --task-definition angular-fastify-task `
  --desired-count 1 `
  --launch-type FARGATE `
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET_IDS],securityGroups=[$SG_ID],assignPublicIp=ENABLED}" `
  --region us-east-1
```

### Step 6: Get Public IP
```powershell
# Wait a minute for task to start, then:
$TASK_ARN = aws ecs list-tasks --cluster angular-fastify-cluster --service-name angular-fastify-service --query "taskArns[0]" --output text --region us-east-1

$ENI_ID = aws ecs describe-tasks --cluster angular-fastify-cluster --tasks $TASK_ARN --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text --region us-east-1

$PUBLIC_IP = aws ec2 describe-network-interfaces --network-interface-ids $ENI_ID --query "NetworkInterfaces[0].Association.PublicIp" --output text --region us-east-1

Write-Host "Application URL: http://${PUBLIC_IP}:3000" -ForegroundColor Green
```

---

## 🎯 Option 4: AWS App Runner (Easiest Serverless)

### Via AWS Console:
1. Go to AWS App Runner console
2. Click "Create service"
3. Choose "Container registry" → "Amazon ECR"
4. Select your pushed image
5. Configure:
   - Port: 3000
   - Click "Create & deploy"

### Via CLI:
```powershell
$AWS_ACCOUNT_ID = aws sts get-caller-identity --query Account --output text

aws apprunner create-service `
  --service-name angular-fastify-app `
  --source-configuration "{
    \"ImageRepository\": {
      \"ImageIdentifier\": \"$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:latest\",
      \"ImageRepositoryType\": \"ECR\",
      \"ImageConfiguration\": {
        \"Port\": \"3000\"
      }
    }
  }" `
  --instance-configuration "{
    \"Cpu\": \"1024\",
    \"Memory\": \"2048\"
  }" `
  --region us-east-1
```

---

## ✅ Verify Deployment

Test these endpoints after deployment:

```powershell
# Replace with your deployment URL
$URL = "http://your-app-url"

# Test health endpoint
Invoke-RestMethod -Uri "$URL/api/health"

# Test data endpoint
Invoke-RestMethod -Uri "$URL/api/data"

# Open in browser
Start-Process $URL
```

---

## 🔄 Update Deployment

### Elastic Beanstalk:
```powershell
eb deploy
```

### ECS:
```powershell
# Build and push new image
.\deploy-to-aws.ps1

# ECS will automatically detect new image and update
```

---

## 💰 Cost Estimates

- **Elastic Beanstalk (t3.micro)**: ~$24/month
- **ECS Fargate (0.25 vCPU, 0.5GB)**: ~$15/month
- **App Runner**: ~$15-20/month (scales automatically)

---

## 🔥 Troubleshooting

### Issue: Task fails to start
```powershell
# Check logs
aws ecs describe-tasks --cluster angular-fastify-cluster --tasks <task-id> --region us-east-1
```

### Issue: Can't access application
- Check security group allows inbound traffic on port 3000
- Verify task has public IP
- Check application logs in CloudWatch

### Issue: 502 Bad Gateway
- Container may not be listening on port 3000
- Check environment variables are set correctly
- Verify health check endpoint is accessible

---

## 📚 Additional Resources

- **AWS-DEPLOYMENT.md** - Comprehensive deployment guide
- **DEPLOYMENT.md** - General deployment instructions
- [AWS Documentation](https://docs.aws.amazon.com/)

---

## 🆘 Need Help?

1. Check CloudWatch logs
2. Verify AWS credentials: `aws sts get-caller-identity`
3. Test Docker image locally: `docker-compose up`
4. See AWS-DEPLOYMENT.md for detailed troubleshooting

---

**Choose your method above and start deploying! 🚀**
