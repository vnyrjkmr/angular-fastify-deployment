# 🚀 Deploy to AWS ECS via Console - Step by Step Guide

Since CLI deployment is blocked by IAM permissions, follow these steps to deploy via AWS Console.

---

## Prerequisites
✅ Your Docker image is in ECR: `466897160569.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:latest`
✅ ECS Cluster exists: `angular-fastify-cluster`

---

## Step 1: Create Task Definition

### 1.1 Go to ECS Console
Open: https://us-east-1.console.aws.amazon.com/ecs/v2/task-definitions

### 1.2 Create New Task Definition
- Click **"Create new task definition"** (blue button)
- Select **"Create new task definition with JSON"**

### 1.3 Paste This JSON Configuration
```json
{
  "family": "angular-fastify-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::466897160569:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "angular-fastify-container",
      "image": "466897160569.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        },
        {
          "name": "PORT",
          "value": "3000"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/angular-fastify-task",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs",
          "awslogs-create-group": "true"
        }
      },
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:3000/api/health || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "startPeriod": 10
      }
    }
  ]
}
```

### 1.4 Review and Create
- Click **"Create"**
- Wait for task definition to be created

---

## Step 2: Create ECS Service

### 2.1 Go to Your Cluster
Open: https://us-east-1.console.aws.amazon.com/ecs/v2/clusters/angular-fastify-cluster

### 2.2 Create Service
- Click **"Services"** tab
- Click **"Create"** button

### 2.3 Configure Service

**Environment:**
- Compute options: `Launch type`
- Launch type: `FARGATE`
- Platform version: `LATEST`

**Deployment configuration:**
- Application type: `Service`
- Family: `angular-fastify-task` (select from dropdown)
- Revision: `LATEST`
- Service name: `angular-fastify-service`
- Desired tasks: `1`

**Networking:**
- VPC: (select your default VPC)
- Subnets: (select at least 2 subnets - check all available)
- Security group: 
  - Click **"Create new security group"**
  - Name: `angular-fastify-sg`
  - Inbound rules:
    - Type: `Custom TCP`
    - Port: `3000`
    - Source: `0.0.0.0/0` (Anywhere IPv4)
  - Click **"Create"**
- Public IP: **TURN ON** (Important!)

### 2.4 Load Balancer (Optional - Skip for Now)
- Leave as "None" for simplicity

### 2.5 Service Auto Scaling (Optional - Skip for Now)
- Leave disabled

### 2.6 Review and Create
- Click **"Create"**
- Wait for deployment to complete (2-3 minutes)

---

## Step 3: Get Your App URL

### 3.1 View Running Task
- Stay in your cluster page
- Click **"Tasks"** tab
- You should see 1 running task (status: RUNNING)
- Click on the task ID

### 3.2 Find Public IP
- In the task details, look for **"Public IP"**
- Copy the IP address (e.g., `54.123.45.67`)

### 3.3 Access Your App
Open in browser:
```
http://<PUBLIC_IP>:3000
```

**Test Endpoints:**
- Frontend: `http://<PUBLIC_IP>:3000/`
- API Health: `http://<PUBLIC_IP>:3000/api/health`
- API Data: `http://<PUBLIC_IP>:3000/api/data`

---

## Step 4: Verify Deployment

### Check Container Logs
- In your task details, click on the container name
- Click **"Logs"** tab
- You should see:
```
[INFO] Server listening at http://0.0.0.0:3000
[INFO] 🚀 Server is running on http://0.0.0.0:3000
```

### Test Health Endpoint
```bash
curl http://<PUBLIC_IP>:3000/api/health
```

Expected response:
```json
{"status":"ok","timestamp":"2025-11-11T...","environment":"production"}
```

---

## Troubleshooting

### Task Won't Start
**Issue:** Task status shows "STOPPED"
**Solution:** 
1. Click on the stopped task
2. Check "Logs" tab for errors
3. Check "Stopped reason"
4. Most common: Security group doesn't allow traffic on port 3000

### Can't Access via Public IP
**Issue:** Browser shows "Connection refused"
**Solution:**
1. Verify Security Group allows inbound port 3000 from 0.0.0.0/0
2. Verify "Public IP" is enabled in service configuration
3. Wait 1-2 minutes for DNS propagation
4. Try with `http://` not `https://`

### Task Keeps Restarting
**Issue:** Task starts then stops repeatedly
**Solution:**
1. Check container logs for application errors
2. Verify ECR image is accessible
3. Check health check is passing

---

## Optional: Add Load Balancer

For production with a domain name:

### 1. Create Application Load Balancer
- Go to EC2 Console → Load Balancers
- Create ALB
- Add target group pointing to port 3000
- Configure health check to `/api/health`

### 2. Update ECS Service
- Edit service
- Add load balancer
- Register with target group

### 3. Point Domain
- Add CNAME record pointing to ALB DNS
- Access via your domain: `https://yourdomain.com`

---

## Cost Estimate

**Fargate Pricing (us-east-1):**
- 0.25 vCPU: $0.04048/hour
- 0.5 GB RAM: $0.004445/hour
- **Total:** ~$0.045/hour = ~$32/month for 24/7 uptime

**Free Tier:**
- First 750 hours/month free for first year
- Your app runs free for ~1 month!

---

## Alternative: Use Render.com (Free Forever)

If you don't want AWS costs, deploy to Render.com:

1. Go to https://render.com
2. Sign up with GitHub
3. New Web Service → Select `vnyrjkmr/angular-fastify-deployment`
4. Environment: Docker, Plan: Free
5. Deploy!

**URL:** `https://angular-fastify-deployment.onrender.com`
**Cost:** $0 forever (with sleep after 15 min inactivity)

---

## Summary

✅ **Via AWS Console:** Full control, costs ~$32/month (or free first year)
✅ **Via Render.com:** Zero configuration, free forever

**Choose the option that fits your needs!**

After deployment, your app will be accessible at:
- AWS: `http://<PUBLIC_IP>:3000`
- Render: `https://your-app.onrender.com`

🎉 **Your Angular + Fastify app is production-ready!**
