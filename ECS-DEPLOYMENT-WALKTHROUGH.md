# 🎯 ECS Service Deployment - Complete Walkthrough

Let me guide you through deploying your application to AWS ECS using the Console.

---

## ✅ What You Have Ready

- ✅ Docker image in ECR: `466897160569.dkr.ecr.us-east-1.amazonaws.com/angular-fastify-app:latest`
- ✅ ECS Cluster: `angular-fastify-cluster`
- ✅ Image tested and working

---

## 📋 Step-by-Step Console Deployment

### **Step 1: Create Task Definition**

1. **Open ECS Task Definitions:**
   - URL: https://us-east-1.console.aws.amazon.com/ecs/v2/task-definitions
   - Click the blue **"Create new task definition"** button

2. **Choose Creation Method:**
   - Select **"Create new task definition with JSON"**
   - This is easier than the form

3. **Copy and Paste This JSON:**

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
          "hostPort": 3000,
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
          "awslogs-create-group": "true",
          "awslogs-group": "/ecs/angular-fastify-task",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
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

4. **Click "Create"**
   - If you get an error about the execution role, it's okay - continue to next step

---

### **Step 2: If Task Definition Creation Fails**

**Error: "Unable to assume role"**

This means we need to create the task definition without the execution role. Use this simplified JSON instead:

```json
{
  "family": "angular-fastify-task",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
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
        }
      ]
    }
  ]
}
```

---

### **Step 3: Create ECS Service**

1. **Go to Your Cluster:**
   - URL: https://us-east-1.console.aws.amazon.com/ecs/v2/clusters/angular-fastify-cluster
   - Click on **"Services"** tab
   - Click **"Create"** button

2. **Environment Section:**
   - **Compute configuration:** Click "Launch type"
   - **Launch type:** Select `FARGATE`
   - **Platform version:** `LATEST` (default)

3. **Deployment Configuration:**
   - **Application type:** `Service`
   - **Task definition:**
     - **Family:** `angular-fastify-task` (select from dropdown)
     - **Revision:** `LATEST` (default)
   - **Service name:** `angular-fastify-service`
   - **Desired tasks:** `1`

4. **Networking:**
   - **VPC:** Select your default VPC from dropdown
   - **Subnets:** Check **ALL** available subnets (at least 2)
   - **Security group:**
     - Click **"Create a new security group"**
     - **Security group name:** `angular-fastify-sg`
     - **Description:** `Security group for Angular Fastify app`
     - **Inbound rules for security groups:**
       - Click **"Add rule"**
       - **Type:** `Custom TCP`
       - **Port range:** `3000`
       - **Source type:** `Anywhere-IPv4` (0.0.0.0/0)
       - **Description:** `Allow HTTP traffic on port 3000`
   - **Public IP:** **TURN ON** (Toggle to enabled) ⚠️ **Very Important!**

5. **Load balancing (Optional):**
   - Leave as **"None"** for now

6. **Service auto scaling:**
   - Leave **disabled** for now

7. **Review and Create:**
   - Scroll to bottom
   - Click **"Create"**
   - Wait for deployment (2-5 minutes)

---

### **Step 4: Monitor Deployment**

1. **Watch Service Status:**
   - Stay on the cluster page
   - Go to **"Services"** tab
   - You should see `angular-fastify-service`
   - **Status** should change from "Deploying" → "Active"
   - **Desired tasks:** 1
   - **Running tasks:** Should become 1

2. **Check Tasks:**
   - Click **"Tasks"** tab
   - You should see 1 task
   - **Status:** Should be `RUNNING` (green)
   - If status is `PENDING`, wait 1-2 minutes
   - If status is `STOPPED` (red), see troubleshooting below

---

### **Step 5: Get Your Application URL**

1. **Click on Running Task:**
   - In the Tasks tab, click on the task ID
   - Task details page will open

2. **Find Public IP:**
   - Look for **"Configuration"** section
   - Find **"Public IP"** field
   - Copy the IP address (e.g., `3.123.45.67`)

3. **Access Your App:**
   - Open browser and go to: `http://<PUBLIC_IP>:3000`
   - You should see your Angular app!

4. **Test Endpoints:**
   ```
   Frontend:   http://<PUBLIC_IP>:3000/
   API Health: http://<PUBLIC_IP>:3000/api/health
   API Data:   http://<PUBLIC_IP>:3000/api/data
   ```

---

## 🔍 Troubleshooting

### Issue 1: "Unable to assume the service linked role"

**What it means:** AWS account needs the ECS service-linked role created.

**Solution:**
Ask your AWS administrator to run:
```bash
aws iam create-service-linked-role --aws-service-name ecs.amazonaws.com
```

After they run this, delete the failed service and try creating it again.

---

### Issue 2: Task Status Shows "STOPPED"

**What to check:**
1. Click on the stopped task
2. Look at **"Stopped reason"** field
3. Check **"Logs"** tab for errors

**Common causes:**
- **Image pull error:** Execution role doesn't have ECR permissions
- **Health check failing:** App isn't starting correctly
- **Port conflict:** Another service using port 3000

**Solution:**
- Use the simplified JSON without execution role
- Or ask admin to fix execution role permissions

---

### Issue 3: Can't Access via Public IP

**Checklist:**
1. ✅ Public IP is enabled in service networking
2. ✅ Security group allows inbound port 3000 from 0.0.0.0/0
3. ✅ Task status is "RUNNING" (not pending/stopped)
4. ✅ Using `http://` not `https://`

**Test from command line:**
```bash
curl http://<PUBLIC_IP>:3000/api/health
```

---

### Issue 4: Task Keeps Restarting

**What to check:**
1. Click on task → **"Logs"** tab
2. Look for application errors
3. Check health check endpoint

**Common fixes:**
- Remove health check from task definition (temporary)
- Check container logs for startup errors
- Verify ECR image is accessible

---

## 💡 Alternative: Deploy to Render.com

If you keep hitting AWS permission issues, **Render.com is a great alternative**:

### Why Render.com?
- ✅ No AWS permissions needed
- ✅ Free forever (with auto-sleep)
- ✅ SSL certificate included
- ✅ 5-minute deployment
- ✅ Your Docker image already works

### Quick Steps:
1. Go to: https://render.com
2. Sign up with GitHub (free)
3. Click **"New +"** → **"Web Service"**
4. Select repo: `vnyrjkmr/angular-fastify-deployment`
5. Configure:
   - **Name:** `angular-fastify-app`
   - **Environment:** `Docker`
   - **Branch:** `master`
   - **Plan:** `Free`
6. Click **"Create Web Service"**
7. Wait 5 minutes
8. Your app is live at: `https://angular-fastify-app.onrender.com`

---

## 📊 Deployment Checklist

Before creating service:
- [ ] Task definition created
- [ ] VPC selected
- [ ] At least 2 subnets selected
- [ ] Security group created with port 3000 open
- [ ] Public IP enabled

After creating service:
- [ ] Service status is "Active"
- [ ] Running tasks = 1
- [ ] Task status is "RUNNING"
- [ ] Public IP assigned to task
- [ ] Can access `http://<PUBLIC_IP>:3000`

---

## 📞 Need Help?

If you're stuck at any step:
1. Take a screenshot of the error
2. Check which step number you're on
3. Look at the troubleshooting section above

Or simply deploy to Render.com - it's much simpler! 😊

---

**Let me know which step you're on and I'll help you through it!**
