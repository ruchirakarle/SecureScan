const express = require('express');
const router = express.Router();
const { listScans } = require('../services/dynamodb');

// GET /api/history  — get all past scans
router.get('/', async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const scans = await listScans(limit);
    res.json({ scans, count: scans.length });
  } catch (err) {
    next(err);
  }
});

module.exports = router;