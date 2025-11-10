# 🚀 AWS Deployment Guide - Angular + Fastify Application

Complete guide to deploy your Angular + Fastify single-container application to AWS.

## 📋 Prerequisites

Before deploying to AWS, ensure you have:

1. ✅ **AWS Account** - Active AWS account with appropriate permissions
2. ✅ **AWS CLI** - Installed and configured (`aws configure`)
3. ✅ **Docker** - For building the container image
4. ✅ **Application tested locally** - Ensure it works with `docker-compose up`

---

## 🎯 AWS Deployment Options

Choose the option that best fits your needs:

| Option | Best For | Complexity | Cost | Auto-Scaling |
|--------|----------|------------|------|--------------|
| **AWS Elastic Beanstalk** | Quick deployment, managed infrastructure | Low | $$ | Yes |
| **AWS ECS Fargate** | Serverless containers, no server management | Medium | $$ | Yes |
| **AWS ECS EC2** | More control, cost optimization | High | $ | Yes |
| **AWS App Runner** | Simplest container deployment | Very Low | $$ | Yes |
| **AWS Lightsail** | Small apps, fixed pricing | Low | $ | No |

---

## 🚀 Option 1: AWS Elastic Beanstalk (Recommended for Beginners)

Easiest deployment with automatic infrastructure management.

### Step 1: Install EB CLI

```powershell
pip install awsebcli --upgrade
```

### Step 2: Initialize Elastic Beanstalk

```powershell
cd c:\Users\LENOVO\Desktop\angular-fastify-deployment

# Initialize EB application
eb init -p docker angular-fastify-app --region us-east-1

# Create environment and deploy
eb create angular-fastify-env --instance-type t3.micro

# Deploy updates
eb deploy
```

### Step 3: Configure Environment

Create `Dockerrun.aws.json` in project root:

```json
{
  "AWSEBDockerrunVersion": "1",
  "Image": {
    "Name": "angular-fastify-app",
    "Update": "true"
  },
  "Ports": [
    {
      "ContainerPort": 3000,
      "HostPort": 80
    }
  ]
}
```

### Step 4: Access Application

```powershell
eb open
```

Your app will be available at: `http://angular-fastify-env.us-east-1.elasticbeanstalk.com`

### Elastic Beanstalk Commands

```powershell
# View status
eb status

# View logs
eb logs

# Set environment variables
eb setenv NODE_ENV=production PORT=3000

# Terminate environment
eb terminate angular-fastify-env
```

---

## 🐳 Option 2: AWS ECS Fargate (Serverless Containers)

Deploy containers without managing servers.

### Step 1: Build and Push to ECR

Use the provided script: `.\deploy-to-aws-ecr.ps1`

Or manually:

```powershell
# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com

# Create ECR repository
aws ecr create-repository --repository-name angular-fastify-app --region us-east-1

# Build Docker image
docker build -t angular-fastify-app .

# Tag image for ECR
docker tag angular-fastify-app:latest YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:latest

# Push to ECR
docker push YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:latest
```

### Step 2: Create ECS Cluster

```powershell
# Create cluster
aws ecs create-cluster --cluster-name angular-fastify-cluster --region us-east-1
```

### Step 3: Register Task Definition

Use the provided file: `aws-ecs-task-definition.json`

```powershell
aws ecs register-task-definition --cli-input-json file://aws-ecs-task-definition.json --region us-east-1
```

### Step 4: Create ECS Service

```powershell
# Create service
aws ecs create-service `
  --cluster angular-fastify-cluster `
  --service-name angular-fastify-service `
  --task-definition angular-fastify-task `
  --desired-count 1 `
  --launch-type FARGATE `
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxxxx],securityGroups=[sg-xxxxx],assignPublicIp=ENABLED}" `
  --region us-east-1
```

### Step 5: Set Up Application Load Balancer (Optional)

For production, add an ALB for HTTPS and better routing.

---

## ⚡ Option 3: AWS App Runner (Simplest Option)

Fully managed container service with automatic deployments.

### Deploy via Console

1. Go to AWS App Runner console
2. Click "Create service"
3. Source: Container registry → Amazon ECR
4. Select your image
5. Deployment: Automatic
6. Configure:
   - Port: 3000
   - Environment variables (if needed)
7. Click "Create & deploy"

### Deploy via CLI

```powershell
aws apprunner create-service `
  --service-name angular-fastify-app `
  --source-configuration '{
    "ImageRepository": {
      "ImageIdentifier": "YOUR_AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:latest",
      "ImageRepositoryType": "ECR",
      "ImageConfiguration": {
        "Port": "3000"
      }
    }
  }' `
  --instance-configuration '{
    "Cpu": "1024",
    "Memory": "2048"
  }' `
  --region us-east-1
```

---

## 💰 Option 4: AWS Lightsail (Fixed Pricing)

Best for small applications with predictable traffic.

### Step 1: Create Container Service

```powershell
# Create Lightsail container service
aws lightsail create-container-service `
  --service-name angular-fastify-app `
  --power small `
  --scale 1 `
  --region us-east-1
```

### Step 2: Push Image to Lightsail

```powershell
# Push image directly to Lightsail
aws lightsail push-container-image `
  --service-name angular-fastify-app `
  --label angular-fastify-app `
  --image angular-fastify-app:latest `
  --region us-east-1
```

### Step 3: Deploy Container

Create deployment JSON and deploy:

```powershell
aws lightsail create-container-service-deployment `
  --service-name angular-fastify-app `
  --cli-input-json file://lightsail-deployment.json `
  --region us-east-1
```

---

## 🔧 Environment Variables Configuration

For all deployment methods, set these environment variables:

```bash
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
```

### Setting Variables by Deployment Type

**Elastic Beanstalk:**
```powershell
eb setenv NODE_ENV=production PORT=3000
```

**ECS:**
Add to task definition JSON under `environment` section

**App Runner:**
Add in console under "Environment variables" or in CLI configuration

**Lightsail:**
Add to deployment JSON under `environment` section

---

## 🔒 Security Best Practices

1. **Use HTTPS**: Set up SSL/TLS certificates
   - Elastic Beanstalk: Use AWS Certificate Manager
   - ECS: Configure ALB with ACM certificate
   - App Runner: Automatic HTTPS included

2. **Set Security Groups**: 
   - Allow inbound traffic only on port 80/443
   - Restrict outbound as needed

3. **Use IAM Roles**: 
   - Create roles with minimum required permissions
   - Never hardcode AWS credentials

4. **Environment Variables**:
   - Use AWS Systems Manager Parameter Store for secrets
   - Or AWS Secrets Manager for sensitive data

---

## 📊 Monitoring & Logging

### CloudWatch Logs

All services automatically send logs to CloudWatch:

```powershell
# View logs (Elastic Beanstalk)
eb logs

# View logs (ECS)
aws logs tail /ecs/angular-fastify-task --follow

# View logs (App Runner)
aws apprunner describe-service --service-arn YOUR_SERVICE_ARN
```

### Enable X-Ray (Optional)

For distributed tracing, enable AWS X-Ray in your task definition or EB configuration.

---

## 💲 Cost Estimation

### Monthly Costs (Approximate)

**Elastic Beanstalk (t3.micro):**
- EC2: ~$8/month
- ELB: ~$16/month
- **Total: ~$24/month**

**ECS Fargate:**
- 0.25 vCPU, 0.5 GB RAM
- **~$15/month** (24/7 uptime)

**App Runner:**
- Minimal traffic: **~$15-20/month**
- Includes automatic scaling

**Lightsail:**
- Nano: **$7/month** (fixed)
- Micro: **$10/month** (fixed)

---

## 🔄 CI/CD Pipeline

### GitHub Actions (Recommended)

See `aws-github-actions-deploy.yml` for complete workflow.

### AWS CodePipeline

1. Create CodePipeline
2. Source: GitHub/CodeCommit
3. Build: CodeBuild (build Docker image)
4. Deploy: ECS/Elastic Beanstalk

---

## 🧪 Testing Deployment

After deployment, test these endpoints:

```powershell
# Replace with your AWS URL
$AWS_URL = "http://your-app.region.elasticbeanstalk.com"

# Test health
Invoke-RestMethod -Uri "$AWS_URL/api/health"

# Test data endpoint
Invoke-RestMethod -Uri "$AWS_URL/api/data"

# Open in browser
Start-Process $AWS_URL
```

---

## 🔥 Quick Deployment Script

Use the provided script for fastest deployment:

```powershell
.\deploy-to-aws.ps1
```

This script will:
1. ✅ Build Docker image
2. ✅ Push to AWS ECR
3. ✅ Update ECS service (if selected)
4. ✅ Display deployment URL

---

## 📝 Troubleshooting

### Issue: Container fails to start

**Solution:**
- Check CloudWatch logs
- Verify PORT environment variable is set to 3000
- Ensure health check endpoint `/api/health` is accessible

### Issue: 502 Bad Gateway

**Solution:**
- Container may not be listening on correct port
- Check security group allows traffic on port 3000
- Verify target group health checks

### Issue: High costs

**Solution:**
- Use t3.micro or t3.small instances
- Enable auto-scaling with min instances = 1
- Consider Lightsail for fixed pricing
- Stop/terminate unused resources

---

## 🎯 Recommended Deployment Path

For your application, I recommend:

1. **Development/Testing**: AWS Elastic Beanstalk
   - Easy setup and management
   - Good for learning AWS
   - Can scale when needed

2. **Production**: AWS ECS Fargate
   - No server management
   - Better cost control
   - Production-grade reliability

3. **Budget-Conscious**: AWS Lightsail
   - Predictable pricing
   - Simple management
   - Good for small/medium traffic

---

## 📚 Additional Resources

- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [AWS App Runner Documentation](https://docs.aws.amazon.com/apprunner/)
- [AWS Pricing Calculator](https://calculator.aws/)

---

## 🚀 Next Steps

1. Choose your deployment option
2. Run the deployment script or follow manual steps
3. Test your deployed application
4. Set up monitoring and alerts
5. Configure auto-scaling (if needed)
6. Set up CI/CD pipeline for automatic deployments

---

**Ready to deploy? Run: `.\deploy-to-aws.ps1`**
