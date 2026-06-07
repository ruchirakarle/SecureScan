const { runSASTScan } = require('./services/scanner');
const { updateJobStatus } = require('./services/dynamodb');
const { saveReport } = require('./services/s3');
const { sendHighSeverityAlert, sendFailureAlert } = require('./services/sns');

function calculateScore(findings) {
  if (!findings || findings.length === 0) return 100;
  const deductions = { HIGH: 15, MEDIUM: 7, LOW: 2 };
  let score = 100;
  findings.forEach(f => {
    score -= (deductions[(f.severity || '').toUpperCase()] || 0);
  });
  return Math.max(0, score);
}

function countBySeverity(findings) {
  const counts = { HIGH: 0, MEDIUM: 0, LOW: 0 };
  (findings || []).forEach(f => {
    const s = (f.severity || '').toUpperCase();
    if (counts[s] !== undefined) counts[s]++;
  });
  return counts;
}

exports.handler = async (event) => {
  const results = [];

  for (const record of event.Records) {
    const job = JSON.parse(record.body);
    const { scanId, code } = job;

    console.log(`Processing SAST scan job: ${scanId}`);

    try {
      await updateJobStatus(scanId, { status: 'RUNNING' });

      const scanResult = await runSASTScan(code);
      const findings = scanResult.vulnerabilities || scanResult.findings || [];

      const score = calculateScore(findings);
      const { HIGH, MEDIUM, LOW } = countBySeverity(findings);

      const reportS3Key = await saveReport(scanId, {
        scanId,
        scanType: 'SAST',
        findings,
        score,
        scannedAt: new Date().toISOString(),
      });

      await updateJobStatus(scanId, {
        status: 'COMPLETED',
        score,
        highCount: HIGH,
        mediumCount: MEDIUM,
        lowCount: LOW,
        reportS3Key,
      });

      if (HIGH > 0) {
        await sendHighSeverityAlert(scanId, 'SAST', HIGH);
      }

      console.log(`SAST scan ${scanId} completed. Score: ${score}, HIGH: ${HIGH}`);
      results.push({ scanId, status: 'success' });

    } catch (error) {
      console.error(`SAST scan ${scanId} failed:`, error.message);

      await updateJobStatus(scanId, {
        status: 'FAILED',
        errorMessage: error.message,
      });

      const receiveCount = parseInt(
        record.attributes?.ApproximateReceiveCount || '1'
      );
      if (receiveCount >= 3) {
        await sendFailureAlert(scanId, error.message);
      }

      throw error;
    }
  }

  return { processed: results.length };
};