const AWS = require('aws-sdk');
const s3 = new AWS.S3({ region: process.env.AWS_REGION });

async function saveReport(scanId, reportData) {
  const key = `sast-reports/${scanId}.json`;
  await s3.putObject({
    Bucket: process.env.S3_REPORTS_BUCKET,
    Key: key,
    Body: JSON.stringify(reportData, null, 2),
    ContentType: 'application/json',
  }).promise();
  return key;
}

module.exports = { saveReport };