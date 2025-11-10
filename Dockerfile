# Multi-stage Dockerfile for Angular + Fastify deployment

# Stage 1: Build Angular Frontend
FROM node:18-alpine AS frontend-build

WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package*.json ./

# Install dependencies (including dev dependencies for build)
RUN npm ci

# Copy frontend source
COPY frontend/ ./

# Build Angular app for production
RUN npm run build -- --configuration production

# Stage 2: Setup Fastify Backend
FROM node:18-alpine AS backend-build

WORKDIR /app/backend

# Copy backend package files
COPY backend/package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Stage 3: Production Image
FROM node:18-alpine

WORKDIR /app

# Copy backend dependencies and source
COPY --from=backend-build /app/backend/node_modules ./node_modules
COPY backend/server.js ./server.js
COPY backend/package.json ./package.json

# Copy built Angular app from frontend stage to public folder
# Angular builds to dist/angular-boilerplate/browser
COPY --from=frontend-build /app/frontend/dist/angular-boilerplate/browser ./public

# Expose the port your Fastify server runs on
EXPOSE 3000

# Set environment to production
ENV NODE_ENV=production
ENV PORT=3000
ENV HOST=0.0.0.0

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start the Fastify server
CMD ["node", "server.js"]
