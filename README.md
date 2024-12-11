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

  // Start the server on 10.10.1.174
  app.listen(port, '10.10.1.174', () => {
    console.log(`Server running on http://10.10.1.174:${port}`);
  });

  return app;
};

// Dynamically create servers based on configurations
configs.forEach(({ port, target, staticFolder }) => {
  const staticFolderPath = path.join(__dirname, staticFolder); // Resolve the static folder path
  configureApp(port, target, staticFolderPath);
});
