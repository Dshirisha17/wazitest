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

E:\users\sandhata\next-gen-bank\ui\cardservice\node_modules\http-proxy-middleware\dist\configuration.js:7
        throw new Error(errors_1.ERRORS.ERR_CONFIG_FACTORY_TARGET_MISSING);
        ^

Error: [HPM] Missing "target" option. Example: {target: "http://www.example.org"}
    at verifyConfig (E:\users\sandhata\next-gen-bank\ui\cardservice\node_modules\http-proxy-middleware\dist\configuration.js:7:15)
    at new HttpProxyMiddleware (E:\users\sandhata\next-gen-bank\ui\cardservice\node_modules\http-proxy-middleware\dist\http-proxy-middleware.js:123:42)
    at createProxyMiddleware (E:\users\sandhata\next-gen-bank\ui\cardservice\node_modules\http-proxy-middleware\dist\index.js:20:28)
    at configureApp (E:\users\sandhata\next-gen-bank\ui\cardservice\server.js:15:5)
    at E:\users\sandhata\next-gen-bank\ui\cardservice\server.js:39:3
    at Array.forEach (<anonymous>)
    at Object.<anonymous> (E:\users\sandhata\next-gen-bank\ui\cardservice\server.js:37:9)
    at Module._compile (node:internal/modules/cjs/loader:1358:14)
    at Module._extensions..js (node:internal/modules/cjs/loader:1416:10)
    at Module.load (node:internal/modules/cjs/loader:1208:32)

Node.js v20.15.0
