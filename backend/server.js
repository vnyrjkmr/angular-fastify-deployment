// server.js - Fastify server serving Angular app with API routes
const fastify = require('fastify')({ 
  logger: {
    level: 'info',
    transport: {
      target: 'pino-pretty',
      options: {
        translateTime: 'HH:MM:ss Z',
        ignore: 'pid,hostname'
      }
    }
  }
});
const path = require('path');
const fastifyStatic = require('@fastify/static');
const fastifyCors = require('@fastify/cors');

// Enable CORS for development
fastify.register(fastifyCors, {
  origin: true,
  credentials: true
});

// Register static file serving for Angular build
fastify.register(fastifyStatic, {
  root: path.join(__dirname, 'public'),
  prefix: '/',
});

// Health check endpoint
fastify.get('/api/health', async (request, reply) => {
  return { 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  };
});

// Example API routes - Add your backend API routes here
fastify.get('/api/data', async (request, reply) => {
  return { 
    message: 'Hello from Fastify API!',
    data: [
      { id: 1, name: 'Item 1' },
      { id: 2, name: 'Item 2' },
      { id: 3, name: 'Item 3' }
    ]
  };
});

// Example POST endpoint
fastify.post('/api/data', async (request, reply) => {
  const body = request.body;
  return { 
    message: 'Data received successfully',
    received: body 
  };
});

// Add your other API routes here
// Example:
// fastify.get('/api/users', async (request, reply) => {
//   // Your logic here
//   return { users: [] };
// });
//
// fastify.post('/api/users', async (request, reply) => {
//   // Your logic here
//   return { user: request.body };
// });

// Fallback route for Angular routing (SPA)
// This MUST be the last route registered
fastify.setNotFoundHandler((request, reply) => {
  // If it's an API request, return 404 JSON
  if (request.url.startsWith('/api/')) {
    reply.code(404).send({ 
      error: 'API endpoint not found',
      path: request.url,
      method: request.method 
    });
  } else {
    // For all other routes, serve index.html (Angular routing)
    reply.sendFile('index.html');
  }
});

// Graceful shutdown
const closeGracefully = async (signal) => {
  fastify.log.info(`Received signal to terminate: ${signal}`);
  await fastify.close();
  process.exit(0);
};

process.on('SIGINT', closeGracefully);
process.on('SIGTERM', closeGracefully);

// Start the server
const start = async () => {
  try {
    const port = parseInt(process.env.PORT || '3000', 10);
    const host = process.env.HOST || '0.0.0.0';
    
    await fastify.listen({ port, host });
    fastify.log.info(`🚀 Server is running on http://${host}:${port}`);
    fastify.log.info(`📱 Frontend: http://localhost:${port}`);
    fastify.log.info(`🔌 API: http://localhost:${port}/api`);
    fastify.log.info(`❤️  Health: http://localhost:${port}/api/health`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
