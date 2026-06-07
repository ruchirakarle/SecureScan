const AWS = require('aws-sdk');
const sqs = new AWS.SQS({ region: process.env.AWS_REGION });

async function publishScanJob(queueUrl, jobPayload) {
  const params = {
    QueueUrl: queueUrl,
    MessageBody: JSON.stringify(jobPayload),
    MessageAttributes: {
      scanType: {
        DataType: 'String',
        StringValue: jobPayload.scanType,
      },
    },
  };
  const result = await sqs.sendMessage(params).promise();
  return result.MessageId;
}

module.exports = { publishScanJob };