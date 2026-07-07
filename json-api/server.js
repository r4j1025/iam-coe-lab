const express = require('express');
const fs = require('fs');
const path = require('path');

const app = express();
const DATA_DIR_V1 = '/opt/api-data';
const DATA_DIR_V2 = '/opt/api-data-no-auth';
const AUTH_TOKEN = 'iamcoe123';

app.use(express.json());

// Auth middleware
const authMiddleware = (req, res, next) => {
  const auth = req.headers['authorization'];
  if (!auth || auth !== `Bearer ${AUTH_TOKEN}`) {
    return res.status(401).json({ error: 'Unauthorized. Invalid or missing token.' });
  }
  next();
};

// ── V1 (with auth) ────────────────────────────────────────────────────────────

app.get('/api/V1', authMiddleware, (req, res) => {
  const files = fs.readdirSync(DATA_DIR_V1).filter(f => f.endsWith('.json'));
  const endpoints = files.map(f => `/api/V1/${path.basename(f, '.json')}`);
  res.json({ available_endpoints: endpoints });
});

app.all('/api/V1/loopback', authMiddleware, (req, res) => {
  res.json(req.body);
});

app.get('/api/V1/:name', authMiddleware, (req, res) => {
  const filename = `${req.params.name}.json`;
  const filepath = path.join(DATA_DIR_V1, filename);

  if (!fs.existsSync(filepath)) {
    return res.status(404).json({ error: `${filename} not found` });
  }

  try {
    const data = JSON.parse(fs.readFileSync(filepath, 'utf8'));
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: 'Invalid JSON file' });
  }
});

// ── V2 (no auth) ──────────────────────────────────────────────────────────────

app.get('/api/V2', (req, res) => {
  const files = fs.readdirSync(DATA_DIR_V2).filter(f => f.endsWith('.json'));
  const endpoints = files.map(f => `/api/V2/${path.basename(f, '.json')}`);
  res.json({ available_endpoints: endpoints });
});

app.get('/api/V2/:name', (req, res) => {
  const filename = `${req.params.name}.json`;
  const filepath = path.join(DATA_DIR_V2, filename);

  if (!fs.existsSync(filepath)) {
    return res.status(404).json({ error: `${filename} not found` });
  }

  try {
    const data = JSON.parse(fs.readFileSync(filepath, 'utf8'));
    res.json(data);
  } catch (e) {
    res.status(500).json({ error: 'Invalid JSON file' });
  }
});

app.listen(3000, () => console.log('JSON API running on port 3000'));
