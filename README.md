# wazitest

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');
const config = require('./config'); // Import the configuration file

const configureApp = (port, target, staticFolder) => {
  const app = express();

  // Serve static files
  app.use(express.static(staticFolder));

  // Set up proxy middleware for API requests
  app.use(
    '/api',
    createProxyMiddleware({
      target,
      changeOrigin: true,
      pathRewrite: { '^/api': '' },
      secure: false,
    })
  );

  // Fallback to index.html for SPA
  app.get('*', (req, res) => {
    res.sendFile(path.resolve(staticFolder, 'index.html'));
  });

  // Start the server
  app.listen(port, () => {
    console.log(`Server running on http://localhost:${port}`);
  });

  return app;
};

// Read configuration and start servers
config.servers.forEach(({ port, targetPort, staticFolder }) => {
  const targetURL = `http://${config.hostIP}:${targetPort}`;
  const staticFolderPath = path.join(__dirname, staticFolder); // Resolve static folder path
  configureApp(port, targetURL, staticFolderPath);
});



config.js

// config.js

module.exports = {
  hostIP: '10.10.1.174', // IP address
  servers: [
    {
      port: 204,
      targetPort: 5040,
      staticFolder: 'public',
    },
    {
      port: 182,
      targetPort: 5040,
      staticFolder: 'public',
    },
  ],
};

