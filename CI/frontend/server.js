const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

// Serve static files from the React app build directory
app.use(express.static(path.join(__dirname, 'build')));

// Health check endpoints with explicit response
app.get('/healthz.txt', (req, res) => {
  res.setHeader('Content-Type', 'text/plain');
  res.status(200).send('ok');
});

app.get('/healthz', (req, res) => {
  res.setHeader('Content-Type', 'text/plain');
  res.status(200).send('ok');
});

// More comprehensive health check
app.get('/health', (req, res) => {
  const healthcheck = {
    uptime: process.uptime(),
    message: 'OK',
    timestamp: Date.now(),
    environment: process.env.NODE_ENV || 'development'
  };
  
  res.status(200).json(healthcheck);
});

// Handle React routing - this should be LAST
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'build', 'index.html'));
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running on port ${port}`);
});