require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const scansRouter = require('./routes/scans');
const historyRouter = require('./routes/history');
const errorHandler = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '1mb' }));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes
app.use('/api/scans', scansRouter);
app.use('/api/history', historyRouter);

// Error handler (must be last)
app.use(errorHandler);

app.listen(PORT, () => {
  console.log(`SecureScan backend running on port ${PORT}`);
});

module.exports = app;