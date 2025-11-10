// server.js - Fastify server configuration to serve Angular app
const fastify = require('fastify')({ logger: true });
const path = require('path');
const fastifyStatic = require('@fastify/static');

// Register static file serving for Angular build
fastify.register(fastifyStatic, {
  root: path.join(__dirname, 'public'),
  prefix: '/', // optional: default is '/'
});

// API routes - add your existing API routes here
fastify.get('/api/health', async (request, reply) => {
  return { status: 'ok', timestamp: new Date().toISOString() };
});

// Example API route
fastify.get('/api/data', async (request, reply) => {
  return { message: 'Hello from Fastify API!' };
});

// Add your other API routes here
// fastify.get('/api/users', async (request, reply) => { ... });
// fastify.post('/api/users', async (request, reply) => { ... });

// Fallback route for Angular routing (SPA)
// This should be the last route registered
fastify.setNotFoundHandler((request, reply) => {
  if (request.url.startsWith('/api/')) {
    reply.code(404).send({ error: 'API endpoint not found' });
  } else {
    // Serve index.html for all non-API routes (Angular routing)
    reply.sendFile('index.html');
  }
});

// Start the server
const start = async () => {
  try {
    const port = process.env.PORT || 3000;
    const host = process.env.HOST || '0.0.0.0';
    
    await fastify.listen({ port, host });
    fastify.log.info(`Server is running on http://${host}:${port}`);
  } catch (err) {
    fastify.log.error(err);
    process.exit(1);
  }
};

start();
