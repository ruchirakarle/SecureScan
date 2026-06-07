const express = require('express');
const { v4: uuidv4 } = require('uuid');
const router = express.Router();
const { createScanJob, getScanJob } = require('../services/dynamodb');
const { publishScanJob } = require('../services/sqs');
const { getReport } = require('../services/s3');

// POST /api/scans/code  — submit a SAST scan
router.post('/code', async (req, res, next) => {
  try {
    const { code } = req.body;
    if (!code || typeof code !== 'string') {
      return res.status(400).json({ error: 'code field is required' });
    }
    if (code.length > 50000) {
      return res.status(400).json({ error: 'Code too large (max 50KB)' });
    }

    const scanId = uuidv4();
    const job = await createScanJob(scanId, 'SAST', code.substring(0, 100) + '...');

    await publishScanJob(process.env.SQS_SAST_QUEUE_URL, {
      scanId,
      scanType: 'SAST',
      code,
    });

    res.status(202).json({
      scanId,
      status: 'PENDING',
      message: 'Scan job submitted successfully',
      createdAt: job.createdAt,
    });
  } catch (err) {
    next(err);
  }
});

// POST /api/scans/url  — submit a Pentest scan
router.post('/url', async (req, res, next) => {
  try {
    const { targetUrl } = req.body;
    if (!targetUrl || typeof targetUrl !== 'string') {
      return res.status(400).json({ error: 'targetUrl field is required' });
    }
    try { new URL(targetUrl); } catch {
      return res.status(400).json({ error: 'Invalid URL format' });
    }

    const scanId = uuidv4();
    const job = await createScanJob(scanId, 'PENTEST', targetUrl);

    await publishScanJob(process.env.SQS_PENTEST_QUEUE_URL, {
      scanId,
      scanType: 'PENTEST',
      targetUrl,
    });

    res.status(202).json({
      scanId,
      status: 'PENDING',
      message: 'Scan job submitted successfully',
      createdAt: job.createdAt,
    });
  } catch (err) {
    next(err);
  }
});

// GET /api/scans/:scanId  — get a single scan result
router.get('/:scanId', async (req, res, next) => {
  try {
    const job = await getScanJob(req.params.scanId);
    if (!job) {
      return res.status(404).json({ error: 'Scan not found' });
    }

    let report = null;
    if (job.status === 'COMPLETED' && job.reportS3Key) {
      report = await getReport(job.reportS3Key);
    }

    res.json({ ...job, report });
  } catch (err) {
    next(err);
  }
});

module.exports = router;