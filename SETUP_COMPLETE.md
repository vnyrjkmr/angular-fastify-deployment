# 🎉 Setup Complete - Angular + Fastify Single Container Deployment

## What Has Been Configured

Your Angular + Fastify application is now ready for single-container deployment!

### ✅ Files Created/Modified

#### 1. Backend Setup
- **`backend/server.js`** - Fastify server that:
  - Serves Angular static files from `/public` folder
  - Handles API routes under `/api/*` prefix
  - Implements SPA fallback for Angular routing
  - Includes health check endpoint
  - Configured with CORS and logging

- **`backend/package.json`** - Dependencies:
  - `fastify` - Fast web framework
  - `@fastify/static` - Static file serving
  - `@fastify/cors` - CORS support
  - `pino-pretty` - Pretty logging

#### 2. Docker Configuration
- **`Dockerfile`** - Multi-stage build:
  - Stage 1: Build Angular app
  - Stage 2: Install backend dependencies
  - Stage 3: Combine into production image
  - Includes health check
  - Optimized for size (~150-200MB)

- **`docker-compose.yml`** - Already configured for easy deployment

- **`.dockerignore`** - Already configured to exclude unnecessary files

#### 3. Angular Configuration
- **`frontend/src/environments/environment.ts`**
  - Added `apiUrl: 'http://localhost:3000/api'` for development

- **`frontend/src/environments/environment.prod.ts`**
  - Added `apiUrl: '/api'` for production (same server)

#### 4. Documentation & Scripts
- **`DEPLOYMENT.md`** - Comprehensive deployment guide
  - Build and run instructions
  - Environment configuration
  - Production deployment steps
  - Troubleshooting guide
  - Cloud deployment examples

- **`deploy.ps1`** - PowerShell deployment script
  - Interactive menu for build/run/stop
  - Docker and Docker Compose support
  - Automatic health checks

- **`frontend/src/app/@core/services/api.service.example.ts`**
  - Example Angular service for API calls
  - Uses environment.apiUrl configuration
  - Example CRUD operations

- **`README.md`** - Updated with quick start guide

### 📁 Final Project Structure

```
angular-fastify-deployment/
├── backend/
│   ├── server.js           # ✅ NEW - Fastify server
│   └── package.json        # ✅ NEW - Backend dependencies
├── frontend/
│   ├── src/
│   │   ├── app/@core/services/
│   │   │   └── api.service.example.ts  # ✅ NEW - API service example
│   │   └── environments/
│   │       ├── environment.ts          # ✅ UPDATED - Added apiUrl
│   │       └── environment.prod.ts     # ✅ UPDATED - Added apiUrl
│   ├── angular.json
│   └── package.json
├── Dockerfile              # ✅ UPDATED - Corrected Angular build path
├── docker-compose.yml      # Already configured
├── .dockerignore          # Already configured
├── DEPLOYMENT.md          # ✅ NEW - Comprehensive guide
├── deploy.ps1             # ✅ NEW - Deployment script
└── README.md              # ✅ UPDATED - Quick start info
```

## 🚀 Next Steps

### 1. Test Locally (Without Docker)

**Terminal 1 - Backend:**
```powershell
cd backend
npm install
npm start
```

**Terminal 2 - Frontend:**
```powershell
cd frontend
npm install
npm start
```

Access at http://localhost:4200 (Angular dev server with proxy)

### 2. Test with Docker

```powershell
# Using the deployment script (easiest)
.\deploy.ps1

# Or using Docker Compose
docker-compose up --build

# Or using Docker commands
docker build -t angular-fastify-app .
docker run -p 3000:3000 angular-fastify-app
```

Access at http://localhost:3000

### 3. Verify Deployment

1. **Check Frontend**: http://localhost:3000
   - Should load your Angular application

2. **Check API Health**: http://localhost:3000/api/health
   - Should return: `{"status":"ok","timestamp":"...","environment":"production"}`

3. **Check Example API**: http://localhost:3000/api/data
   - Should return sample data

### 4. Add Your API Routes

Edit `backend/server.js` and add your routes:

```javascript
// Example: User management
fastify.get('/api/users', async (request, reply) => {
  // Your database query here
  return { users: [] };
});

fastify.post('/api/users', async (request, reply) => {
  const userData = request.body;
  // Save to database
  return { user: userData };
});
```

### 5. Use API in Angular

Copy `api.service.example.ts` to create your actual service:

```powershell
cd frontend/src/app/@core/services
cp api.service.example.ts api.service.ts
```

Then modify it for your needs and import in your components:

```typescript
import { ApiService } from '@core/services';

export class MyComponent {
  constructor(private apiService: ApiService) {}

  ngOnInit() {
    this.apiService.getData().subscribe(data => {
      console.log(data);
    });
  }
}
```

### 6. Environment Variables

For production, add environment variables in `docker-compose.yml`:

```yaml
environment:
  - NODE_ENV=production
  - PORT=3000
  - DATABASE_URL=postgresql://user:pass@host:5432/db
  - JWT_SECRET=your-secret-key
  - API_KEY=your-api-key
```

### 7. Deploy to Production

See **DEPLOYMENT.md** for:
- Container registry setup
- Cloud deployment (AWS, Azure, GCP)
- Kubernetes deployment
- CI/CD pipeline setup

## 🔧 Configuration Details

### API Communication

- **Development**: Angular runs on port 4200, Fastify on port 3000
  - Angular proxy configuration handles API calls
  - Frontend calls: `http://localhost:3000/api/*`

- **Production**: Single container on port 3000
  - Fastify serves Angular static files
  - API calls use relative path: `/api/*`
  - Same-origin, no CORS issues

### Docker Build Process

1. **Frontend Build**: Angular app is built to `dist/angular-boilerplate/browser`
2. **Backend Setup**: Fastify dependencies installed
3. **Combine**: Built frontend copied to `backend/public`
4. **Serve**: Fastify serves static files and handles API routes

### Health Check

The Dockerfile includes automatic health checks:
- Every 30 seconds
- Checks `/api/health` endpoint
- Container marked unhealthy if 3 consecutive failures

## 📊 What to Expect

### Build Time
- First build: 5-10 minutes (downloads dependencies)
- Subsequent builds: 2-3 minutes (uses Docker cache)

### Image Size
- Final image: ~150-200 MB
- Includes Node.js runtime + app code
- Production dependencies only

### Performance
- Fast startup: 2-3 seconds
- Efficient static file serving
- Low memory footprint: ~50-100 MB RAM

## ⚠️ Important Notes

1. **API Prefix**: All backend routes MUST start with `/api/`
   - Non-API routes will serve `index.html` (Angular routing)

2. **Environment URLs**: 
   - Use `environment.apiUrl` in all Angular HTTP calls
   - Never hardcode API URLs

3. **CORS**: Already configured in backend for development
   - Adjust for production if needed

4. **Port 3000**: Default port, change in `docker-compose.yml` if needed

5. **Health Check**: Use `/api/health` for monitoring and load balancers

## 🆘 Common Issues

### Port 3000 Already in Use
```powershell
# Find and kill process
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### Docker Build Fails
- Ensure Docker Desktop is running
- Check internet connection (downloads dependencies)
- Try: `docker system prune -a` to clean cache

### Application Not Loading
- Check logs: `docker logs -f angular-fastify-app`
- Verify health: `curl http://localhost:3000/api/health`
- Check browser console for errors

### API 404 Errors
- Ensure routes start with `/api/`
- Check `server.js` for route definitions
- Verify `environment.apiUrl` is set correctly

## 📚 Resources

- **DEPLOYMENT.md** - Full deployment documentation
- **backend/server.js** - Server implementation with examples
- **api.service.example.ts** - Angular service example
- [Fastify Documentation](https://www.fastify.io/)
- [Angular Documentation](https://angular.io/)
- [Docker Documentation](https://docs.docker.com/)

## ✨ Features Included

- ✅ Multi-stage Docker build for optimization
- ✅ Production-ready Fastify server
- ✅ Static file serving for Angular
- ✅ SPA routing support
- ✅ API endpoint separation
- ✅ Health check endpoint
- ✅ CORS configuration
- ✅ Structured logging
- ✅ Graceful shutdown
- ✅ Environment configuration
- ✅ Docker Compose support
- ✅ PowerShell deployment script
- ✅ Comprehensive documentation

## 🎓 Learning More

To understand how everything works:

1. Read `backend/server.js` - See how Fastify serves both static files and API
2. Check `Dockerfile` - Understand the multi-stage build process
3. Review `DEPLOYMENT.md` - Learn deployment strategies
4. Explore `api.service.example.ts` - See Angular HTTP integration

---

**You're all set! 🎉**

Run `.\deploy.ps1` or `docker-compose up --build` to get started!

For questions or issues, check DEPLOYMENT.md troubleshooting section.
