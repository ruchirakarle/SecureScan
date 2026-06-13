const AWS = require('aws-sdk');
const dynamo = new AWS.DynamoDB.DocumentClient({
  region: process.env.AWS_REGION
});
const TABLE = process.env.DYNAMODB_TABLE;

async function createScanJob(scanId, scanType, targetInput) {
  const now = new Date().toISOString();
  const item = {
    scanId,
    createdAt: now,
    updatedAt: now,
    scanType,
    status: 'PENDING',
    targetInput,
    score: null,
    highCount: 0,
    mediumCount: 0,
    lowCount: 0,
    reportS3Key: null,
    retryCount: 0,
    errorMessage: null,
  };
  await dynamo.put({ TableName: TABLE, Item: item }).promise();
  return item;
}

async function getScanJob(scanId) {
  const result = await dynamo.get({
    TableName: TABLE,
    Key: { scanId }
  }).promise();
  return result.Item || null;
}

async function listScans(limit = 20) {
  const result = await dynamo.scan({ TableName: TABLE }).promise();
  return (result.Items || [])
    .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
    .slice(0, limit);
}

module.exports = { createScanJob, getScanJob, listScans };
