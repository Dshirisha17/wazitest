# wazitest

const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');
const configs = require('./config'); // Import the configuration file

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

// Dynamically create servers based on configurations
configs.forEach(({ port, target, staticFolder }) => {
  const staticFolderPath = path.join(__dirname, staticFolder); // Resolve the static folder path
  configureApp(port, target, staticFolderPath);
});


config.js

// config.js

module.exports = [
    {
      port: 204,
      target: 'http://10.10.1.204:5040', // Target URL for 204
      staticFolder: 'public',           // Path to static files
    },
    {
      port: 182,
      target: 'http://10.10.1.182:5040', // Target URL for 182
      staticFolder: 'public',           // Path to static files
    },
  ];
  
