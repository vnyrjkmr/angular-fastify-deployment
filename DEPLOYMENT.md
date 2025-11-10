# 🚀 Deployment Guide - Angular + Fastify Single Container

This guide provides step-by-step instructions to build and deploy your Angular frontend and Fastify backend in a single Docker container.

## 📋 Prerequisites

- Docker installed (version 20.10 or higher)
- Docker Compose installed (optional, for easier management)
- Your project structure is set up correctly

## 🏗️ Project Structure

```
angular-fastify-deployment/
├── frontend/                 # Angular application
│   ├── src/
│   ├── angular.json
│   └── package.json
├── backend/                  # Fastify server
│   ├── server.js
│   └── package.json
├── Dockerfile               # Multi-stage build configuration
├── docker-compose.yml       # Docker Compose configuration
└── .dockerignore           # Files to exclude from Docker build
```

## 🎯 Quick Start

### Option 1: Using Docker Compose (Recommended)

```powershell
# Build and start the container
docker-compose up --build

# Or run in detached mode (background)
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### Option 2: Using Docker Commands

```powershell
# Build the Docker image
docker build -t angular-fastify-app .

# Run the container
docker run -p 3000:3000 --name angular-fastify-app angular-fastify-app

# Run in detached mode
docker run -d -p 3000:3000 --name angular-fastify-app angular-fastify-app

# View logs
docker logs -f angular-fastify-app

# Stop the container
docker stop angular-fastify-app

# Remove the container
docker rm angular-fastify-app
```

## 🌐 Accessing Your Application

Once the container is running, you can access:

- **Frontend**: http://localhost:3000
- **API Health Check**: http://localhost:3000/api/health
- **API Endpoints**: http://localhost:3000/api/*

## 📦 What Happens During Build

The Dockerfile uses a multi-stage build process:

1. **Stage 1 - Frontend Build**
   - Installs Angular dependencies
   - Builds the Angular app for production
   - Output: `dist/angular-boilerplate/browser/`

2. **Stage 2 - Backend Dependencies**
   - Installs Fastify production dependencies
   - Prepares the backend runtime

3. **Stage 3 - Production Image**
   - Combines backend with built Angular files
   - Angular files served from `/public` folder
   - Fastify server handles both static files and API routes
   - Final image size: ~150-200MB

## 🔧 Development Workflow

### Local Development (Without Docker)

1. **Start Backend**:
```powershell
cd backend
npm install
npm run dev
```

2. **Start Frontend** (in another terminal):
```powershell
cd frontend
npm install
npm start
```

Frontend will run on http://localhost:4200 and proxy API calls to backend on port 3000.

### Testing with Docker Before Deployment

```powershell
# Build the image
docker build -t angular-fastify-app:test .

# Run with environment variables
docker run -p 3000:3000 -e NODE_ENV=production -e PORT=3000 angular-fastify-app:test

# Test the health endpoint
curl http://localhost:3000/api/health
```

## 🔐 Environment Variables

You can configure the application using environment variables:

### In docker-compose.yml:

```yaml
environment:
  - NODE_ENV=production
  - PORT=3000
  - HOST=0.0.0.0
  # Add your custom variables here
  - DATABASE_URL=your-database-url
  - API_KEY=your-api-key
```

### Using .env file (docker-compose):

Create a `.env` file in the project root:

```env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:pass@host:5432/db
API_KEY=your-secret-key
```

Then reference it in docker-compose.yml:

```yaml
env_file:
  - .env
```

### Using Docker run command:

```powershell
docker run -p 3000:3000 `
  -e NODE_ENV=production `
  -e PORT=3000 `
  -e DATABASE_URL=your-db-url `
  angular-fastify-app
```

## 🚢 Production Deployment

### 1. Build and Tag Image

```powershell
# Build for production
docker build -t angular-fastify-app:latest .

# Tag for your registry
docker tag angular-fastify-app:latest your-registry/angular-fastify-app:1.0.0
docker tag angular-fastify-app:latest your-registry/angular-fastify-app:latest
```

### 2. Push to Container Registry

```powershell
# Docker Hub
docker push your-registry/angular-fastify-app:1.0.0
docker push your-registry/angular-fastify-app:latest

# Or Azure Container Registry
docker push yourregistry.azurecr.io/angular-fastify-app:1.0.0

# Or AWS ECR
docker push 123456789.dkr.ecr.region.amazonaws.com/angular-fastify-app:1.0.0
```

### 3. Deploy to Cloud Platform

#### AWS ECS/Fargate
```json
{
  "image": "your-registry/angular-fastify-app:latest",
  "portMappings": [
    {
      "containerPort": 3000,
      "protocol": "tcp"
    }
  ]
}
```

#### Google Cloud Run
```powershell
gcloud run deploy angular-fastify-app `
  --image your-registry/angular-fastify-app:latest `
  --platform managed `
  --port 3000
```

#### Azure Container Instances
```powershell
az container create `
  --resource-group myResourceGroup `
  --name angular-fastify-app `
  --image your-registry/angular-fastify-app:latest `
  --ports 3000 `
  --dns-name-label my-app
```

#### Kubernetes
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: angular-fastify-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: angular-fastify-app
  template:
    metadata:
      labels:
        app: angular-fastify-app
    spec:
      containers:
      - name: angular-fastify-app
        image: your-registry/angular-fastify-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
```

## 🔍 Troubleshooting

### Build Fails

**Issue**: Angular build fails
```
Error: Cannot find module '@angular/cli'
```
**Solution**: The Dockerfile now uses `npm ci` instead of `npm ci --only=production` for the frontend build stage to include dev dependencies.

**Issue**: Backend dependencies missing
```
Error: Cannot find module 'fastify'
```
**Solution**: Ensure `backend/package.json` exists and contains all required dependencies.

### Runtime Issues

**Issue**: 404 on Angular routes
**Solution**: The `server.js` fallback handler serves `index.html` for all non-API routes. Make sure your API routes are prefixed with `/api/`.

**Issue**: Static files not loading
**Solution**: Check that the Dockerfile copies from the correct build output path: `dist/angular-boilerplate/browser`

**Issue**: CORS errors
**Solution**: The backend includes `@fastify/cors` configured to allow requests. For specific origins, update `server.js`:
```javascript
fastify.register(fastifyCors, {
  origin: ['https://yourdomain.com'],
  credentials: true
});
```

### Port Already in Use

```powershell
# Find and kill process using port 3000
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Or use a different port
docker run -p 8080:3000 angular-fastify-app
```

### View Container Logs

```powershell
# Docker Compose
docker-compose logs -f

# Docker
docker logs -f angular-fastify-app

# Last 100 lines
docker logs --tail 100 angular-fastify-app
```

### Inspect Running Container

```powershell
# Get container details
docker inspect angular-fastify-app

# Execute commands inside container
docker exec -it angular-fastify-app sh

# Check files in container
docker exec angular-fastify-app ls -la /app
docker exec angular-fastify-app ls -la /app/public
```

## 📊 Monitoring & Health Checks

The application includes a health check endpoint:

```powershell
# Check health
curl http://localhost:3000/api/health

# Response
{
  "status": "ok",
  "timestamp": "2025-11-10T12:00:00.000Z",
  "environment": "production"
}
```

Docker health check is configured in the Dockerfile:
- Interval: 30 seconds
- Timeout: 3 seconds
- Start period: 5 seconds
- Retries: 3

Check health status:
```powershell
docker ps
# Look for "healthy" in STATUS column
```

## 🔄 Updating Your Application

```powershell
# Pull latest code
git pull

# Rebuild and restart
docker-compose up --build -d

# Or with Docker commands
docker build -t angular-fastify-app:latest .
docker stop angular-fastify-app
docker rm angular-fastify-app
docker run -d -p 3000:3000 --name angular-fastify-app angular-fastify-app:latest
```

## 🧹 Cleanup

```powershell
# Stop and remove container
docker-compose down

# Remove images
docker rmi angular-fastify-app

# Remove all unused images, containers, networks
docker system prune -a
```

## 📝 Adding Your API Routes

Edit `backend/server.js` to add your API endpoints:

```javascript
// GET endpoint
fastify.get('/api/users', async (request, reply) => {
  // Your logic here
  return { users: [] };
});

// POST endpoint
fastify.post('/api/users', async (request, reply) => {
  const userData = request.body;
  // Your logic here
  return { user: userData };
});

// With parameters
fastify.get('/api/users/:id', async (request, reply) => {
  const { id } = request.params;
  // Your logic here
  return { user: { id } };
});
```

## 🎓 Best Practices

1. **Use environment variables** for configuration, never hardcode secrets
2. **Tag your images** with version numbers for production
3. **Implement proper logging** using Fastify's built-in logger
4. **Add database migrations** if using a database
5. **Set up CI/CD** to automate builds and deployments
6. **Use health checks** for production monitoring
7. **Implement rate limiting** for API endpoints
8. **Add authentication** for protected routes
9. **Use HTTPS** in production with proper certificates
10. **Monitor your application** with tools like Prometheus, Grafana, or cloud-native solutions

## 📚 Additional Resources

- [Fastify Documentation](https://www.fastify.io/)
- [Angular Documentation](https://angular.io/)
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🆘 Need Help?

If you encounter issues:
1. Check the logs: `docker logs -f angular-fastify-app`
2. Verify the health endpoint: `curl http://localhost:3000/api/health`
3. Inspect the container: `docker exec -it angular-fastify-app sh`
4. Check the Docker build output for errors
5. Ensure all files are in the correct locations

---

**Happy Deploying! 🚀**
