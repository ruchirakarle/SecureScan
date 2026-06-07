const AWS = require('aws-sdk');
const sns = new AWS.SNS({ region: process.env.AWS_REGION });

async function sendHighSeverityAlert(scanId, scanType, highCount) {
  const message = `
🚨 HIGH SEVERITY VULNERABILITIES DETECTED

Scan ID: ${scanId}
Scan Type: ${scanType}
High Severity Findings: ${highCount}
Time: ${new Date().toISOString()}

Please review your scan results immediately.
  `.trim();

  await sns.publish({
    TopicArn: process.env.SNS_TOPIC_ARN,
    Subject: `[SecureScan] HIGH severity vulnerabilities found`,
    Message: message,
  }).promise();
}

async function sendFailureAlert(scanId, errorMessage) {
  await sns.publish({
    TopicArn: process.env.SNS_TOPIC_ARN,
    Subject: `[SecureScan] Scan job FAILED`,
    Message: `Scan ${scanId} failed after retries.\nError: ${errorMessage}`,
  }).promise();
}

module.exports = { sendHighSeverityAlert, sendFailureAlert };