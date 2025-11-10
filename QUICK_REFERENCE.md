# Quick Reference Guide

## 🚀 Start Commands

### Docker (Production-like)
```powershell
# Build and run
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

### Local Development
```powershell
# Terminal 1 - Backend
cd backend
npm install
npm start

# Terminal 2 - Frontend
cd frontend
npm install
npm start
```

## 🌐 URLs

| Environment | Frontend | API | Health |
|-------------|----------|-----|--------|
| Docker | http://localhost:3000 | http://localhost:3000/api/* | http://localhost:3000/api/health |
| Dev (Angular) | http://localhost:4200 | http://localhost:3000/api/* | http://localhost:3000/api/health |
| Dev (Backend) | - | http://localhost:3000/api/* | http://localhost:3000/api/health |

## 📝 Common Commands

### Docker
```powershell
# Build image
docker build -t angular-fastify-app .

# Run container
docker run -d -p 3000:3000 --name angular-fastify-app angular-fastify-app

# View logs
docker logs -f angular-fastify-app

# Stop and remove
docker stop angular-fastify-app && docker rm angular-fastify-app

# Remove image
docker rmi angular-fastify-app

# Clean everything
docker system prune -a
```

### Docker Compose
```powershell
# Build and start
docker-compose up --build

# Start in background
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down

# Rebuild
docker-compose up --build --force-recreate
```

### Check Health
```powershell
# Using curl (if installed)
curl http://localhost:3000/api/health

# Using PowerShell
Invoke-RestMethod -Uri http://localhost:3000/api/health

# Using browser
# Navigate to: http://localhost:3000/api/health
```

## 📁 File Locations

| Component | Location |
|-----------|----------|
| Backend Server | `backend/server.js` |
| Backend Dependencies | `backend/package.json` |
| Angular App | `frontend/src/` |
| Environment Config | `frontend/src/environments/` |
| Docker Build | `Dockerfile` |
| Docker Compose | `docker-compose.yml` |
| Deployment Docs | `DEPLOYMENT.md` |
| Setup Guide | `SETUP_COMPLETE.md` |

## 🔧 Configuration

### Environment Variables (docker-compose.yml)
```yaml
environment:
  - NODE_ENV=production
  - PORT=3000
  - HOST=0.0.0.0
  # Add your variables:
  - DATABASE_URL=your-db-url
  - JWT_SECRET=your-secret
```

### API Base URL (Angular)
- **Development**: `environment.ts` → `apiUrl: 'http://localhost:3000/api'`
- **Production**: `environment.prod.ts` → `apiUrl: '/api'`

### Proxy Configuration (Development)
- **File**: `frontend/proxy.conf.json`
- **Start**: `npm start` (uses proxy automatically)

## 🛠️ Adding Features

### Add API Route (backend/server.js)
```javascript
fastify.get('/api/your-route', async (request, reply) => {
  return { data: 'your data' };
});
```

### Call API (Angular)
```typescript
import { HttpClient } from '@angular/common/http';
import { environment } from '@environments/environment';

constructor(private http: HttpClient) {}

getData() {
  return this.http.get(`${environment.apiUrl}/your-route`);
}
```

## 🐛 Troubleshooting

### Port Already in Use
```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### View Container Files
```powershell
docker exec -it angular-fastify-app sh
ls -la /app
ls -la /app/public
```

### Rebuild from Scratch
```powershell
docker-compose down
docker rmi angular-fastify-app
docker system prune -f
docker-compose up --build
```

### Check Logs
```powershell
# Last 100 lines
docker logs --tail 100 angular-fastify-app

# Follow logs
docker logs -f angular-fastify-app

# Docker Compose
docker-compose logs -f
```

## 📦 Deployment

### Tag and Push
```powershell
# Tag
docker tag angular-fastify-app your-registry/app:1.0.0

# Push
docker push your-registry/app:1.0.0
```

### Cloud Platforms
- **AWS**: ECS, Fargate, Elastic Beanstalk
- **Azure**: Container Instances, App Service
- **GCP**: Cloud Run, Kubernetes Engine
- **Heroku**: Container Registry

See `DEPLOYMENT.md` for detailed cloud deployment instructions.

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| README.md | Overview and quick start |
| DEPLOYMENT.md | Complete deployment guide |
| SETUP_COMPLETE.md | Setup summary and next steps |
| QUICK_REFERENCE.md | This file - quick commands |

## 🎯 Scripts

| Script | Command | Purpose |
|--------|---------|---------|
| Deploy Script | `.\deploy.ps1` | Interactive deployment menu |
| Frontend Dev | `cd frontend && npm start` | Start Angular dev server |
| Backend Dev | `cd backend && npm start` | Start Fastify server |
| Docker Build | `docker build -t angular-fastify-app .` | Build Docker image |
| Docker Run | `docker run -p 3000:3000 angular-fastify-app` | Run container |
| Compose Up | `docker-compose up --build` | Build and run with compose |

## ⚡ Tips

1. **Use deploy.ps1** for easiest deployment
2. **Check health endpoint** first when troubleshooting
3. **View logs** to see what's happening
4. **Use environment variables** for configuration
5. **Prefix all API routes** with `/api/`
6. **Test locally** before building Docker image
7. **Tag your images** with version numbers
8. **Clean Docker cache** if builds are slow
9. **Use Docker Compose** for easier management
10. **Read DEPLOYMENT.md** for advanced topics

## 🔗 Quick Links

- Frontend: http://localhost:3000
- API Health: http://localhost:3000/api/health
- API Data: http://localhost:3000/api/data

---

**Need more help?** Check `DEPLOYMENT.md` for comprehensive documentation.
