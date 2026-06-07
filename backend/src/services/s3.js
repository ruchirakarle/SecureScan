const AWS = require('aws-sdk');
const s3 = new AWS.S3({ region: process.env.AWS_REGION });

async function getReport(s3Key) {
  if (!s3Key) return null;
  const result = await s3.getObject({
    Bucket: process.env.S3_REPORTS_BUCKET,
    Key: s3Key,
  }).promise();
  return JSON.parse(result.Body.toString());
}

module.exports = { getReport };