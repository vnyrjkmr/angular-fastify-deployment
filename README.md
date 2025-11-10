# Angular + Fastify Single Container Deployment 🚀

Deploy your Angular frontend and Fastify backend in a single Docker container for easy deployment and management.

## ✅ Setup Complete!

Your project is now configured for single-container deployment. The setup includes:

- ✅ **Fastify backend** server (`backend/server.js`)
- ✅ **Package configuration** for backend dependencies
- ✅ **Multi-stage Dockerfile** optimized for production
- ✅ **Docker Compose** configuration for easy management
- ✅ **Environment configuration** for Angular
- ✅ **Deployment scripts** and documentation

## 🚀 Quick Start

### Prerequisites
- Docker Desktop installed and running
- No other services using port 3000

### Build and Run

**Option 1: PowerShell Script (Easiest)**
```powershell
.\deploy.ps1
```

**Option 2: Docker Compose**
```powershell
docker-compose up --build -d
```

**Option 3: Docker Commands**
```powershell
docker build -t angular-fastify-app .
docker run -d -p 3000:3000 --name angular-fastify-app angular-fastify-app
```

### Access Your Application

- **Frontend**: http://localhost:3000
- **API Health**: http://localhost:3000/api/health
- **API Endpoints**: http://localhost:3000/api/*

## 📖 Documentation

### Local Development & Docker
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Complete deployment guide with troubleshooting
- **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - Quick command reference
- **[backend/server.js](./backend/server.js)** - Backend server with example API routes
- **[frontend/src/app/@core/services/api.service.ts](./frontend/src/app/@core/services/api.service.ts)** - API service for backend calls

### AWS Deployment
- **[AWS-QUICK-START.md](./AWS-QUICK-START.md)** - ⚡ Quick AWS deployment guide
- **[AWS-DEPLOYMENT.md](./AWS-DEPLOYMENT.md)** - Complete AWS deployment documentation
- **[deploy-to-aws.ps1](./deploy-to-aws.ps1)** - Automated AWS deployment script

## ☁️ Deploy to AWS

Deploy your application to AWS in minutes:

```powershell
# Option 1: Use automated script
.\deploy-to-aws.ps1

# Option 2: Use AWS Elastic Beanstalk
eb init -p docker angular-fastify-app
eb create angular-fastify-env
eb open

# Option 3: Manual ECS deployment
# See AWS-QUICK-START.md for step-by-step instructions
```

**Deployment Options:**
- 🚀 **AWS Elastic Beanstalk** - Easiest, fully managed (~$24/month)
- ⚡ **AWS ECS Fargate** - Serverless containers (~$15/month)
- 🎯 **AWS App Runner** - Simplest container service (~$15/month)
- 💰 **AWS Lightsail** - Fixed pricing ($7-10/month)

See **[AWS-QUICK-START.md](./AWS-QUICK-START.md)** for detailed instructions.

## 🎯 How It Works

This deployment bundles your Angular frontend and Fastify backend in a single container:

## 📁 Project Structure

Your project should be organized like this:

```
your-project/
├── frontend/                 # Angular application
│   ├── src/
│   ├── angular.json
│   ├── package.json
│   └── ...
├── backend/                  # Fastify application
│   ├── server.js
│   ├── package.json
│   └── ...
├── Dockerfile
├── docker-compose.yml
└── .dockerignore
```

## 🔧 Setup Instructions

### 1. Configure Your Fastify Server

Your Fastify server needs to serve the Angular build files. Install the required package:

```bash
cd backend
npm install @fastify/static
```

Update your `backend/server.js` to serve static files (see `server.example.js` for reference):

- Register `@fastify/static` to serve the Angular build from `/public`
- Add a fallback handler to serve `index.html` for Angular routes
- Keep your API routes prefixed with `/api/`

### 2. Update Angular Build Configuration

Ensure your Angular app builds to `dist` folder. Check `angular.json`:

```json
{
  "projects": {
    "your-app": {
      "architect": {
        "build": {
          "options": {
            "outputPath": "dist"
          }
        }
      }
    }
  }
}
```

### 3. Adjust Dockerfile if Needed

The provided `Dockerfile` assumes:
- Frontend is in `./frontend/` directory
- Backend is in `./backend/` directory
- Backend entry point is `server.js`
- Angular builds to `dist/` folder
- Fastify runs on port 3000

**Important adjustments:**

- If your Angular app builds to `dist/browser` or `dist/your-app-name`, update the Dockerfile:
  ```dockerfile
  COPY --from=frontend-build /app/frontend/dist/browser ./public
  ```

- If your backend is TypeScript and needs compilation, uncomment in the Dockerfile:
  ```dockerfile
  RUN npm run build
  ```
  And update the CMD:
  ```dockerfile
  CMD ["node", "dist/server.js"]
  ```

- If your backend entry point is different (e.g., `index.js`, `app.js`), update:
  ```dockerfile
  CMD ["node", "your-entry-file.js"]
  ```

### 4. Place Your Project Files

Copy the deployment files to your project root:

1. Copy `Dockerfile` to your project root
2. Copy `docker-compose.yml` to your project root
3. Copy `.dockerignore` to your project root
4. Update `backend/server.js` using `server.example.js` as a guide

Your structure should look like:

```
your-project/
├── frontend/
├── backend/
├── Dockerfile           ← Place here
├── docker-compose.yml   ← Place here
└── .dockerignore        ← Place here
```

## 🚀 Building and Running

### Option 1: Using Docker Compose (Recommended)

```bash
# Build and start the container
docker-compose up --build

# Or run in detached mode
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop the container
docker-compose down
```

### Option 2: Using Docker Commands

```bash
# Build the image
docker build -t angular-fastify-app .

# Run the container
docker run -p 3000:3000 --name angular-fastify-app angular-fastify-app

# Run in detached mode
docker run -d -p 3000:3000 --name angular-fastify-app angular-fastify-app

# View logs
docker logs -f angular-fastify-app

# Stop and remove
docker stop angular-fastify-app
docker rm angular-fastify-app
```

## 🌐 Accessing Your Application

Once the container is running:

- **Frontend (Angular)**: http://localhost:3000
- **API endpoints**: http://localhost:3000/api/*
- **Health check**: http://localhost:3000/api/health

## 🔍 Troubleshooting

### Build Fails

1. **Frontend build errors**: Check your Angular `package.json` has a build script:
   ```json
   "scripts": {
     "build": "ng build"
   }
   ```

2. **Backend dependency errors**: Ensure `@fastify/static` is in `backend/package.json`:
   ```json
   "dependencies": {
     "fastify": "^4.x.x",
     "@fastify/static": "^6.x.x"
   }
   ```

### Runtime Issues

1. **404 on Angular routes**: Ensure the fallback handler in `server.js` serves `index.html` for non-API routes

2. **Static files not loading**: Verify the Angular dist path matches in the Dockerfile

3. **Port already in use**: Change the port mapping in `docker-compose.yml`:
   ```yaml
   ports:
     - "8080:3000"  # Access on localhost:8080
   ```

### Checking Logs

```bash
# Docker Compose
docker-compose logs -f

# Docker
docker logs -f angular-fastify-app
```

## 🔄 Environment Variables

Add environment variables in `docker-compose.yml`:

```yaml
environment:
  - NODE_ENV=production
  - PORT=3000
  - DATABASE_URL=your-database-url
  - API_KEY=your-api-key
```

Or use an `.env` file (don't commit sensitive data!):

```yaml
env_file:
  - .env
```

## 📦 Production Deployment

### Push to Container Registry

```bash
# Tag the image
docker tag angular-fastify-app your-registry/angular-fastify-app:latest

# Push to registry
docker push your-registry/angular-fastify-app:latest
```

### Deploy to Cloud

- **AWS ECS/Fargate**: Use the pushed image
- **Google Cloud Run**: Deploy directly from image
- **Azure Container Instances**: Use the container image
- **Kubernetes**: Create deployment with your image

## ⚡ Performance Optimization

The Dockerfile uses multi-stage builds to:
- ✅ Keep final image small (~150-200MB)
- ✅ Separate build and runtime dependencies
- ✅ Only include production node_modules
- ✅ Optimize layer caching

## 📝 Notes

- The container runs as a single process (Fastify server)
- Angular app is served as static files
- All API calls should be prefixed with `/api/`
- Angular routing is handled by the fallback to `index.html`
- Use environment variables for configuration

## 🎯 Next Steps

1. Test your application locally with Docker
2. Set up CI/CD pipeline for automated builds
3. Configure environment-specific settings
4. Add health checks and monitoring
5. Set up logging and error tracking
6. Configure HTTPS/SSL for production
7. Add database and other services to `docker-compose.yml` if needed
# AWS Deployment Ready
