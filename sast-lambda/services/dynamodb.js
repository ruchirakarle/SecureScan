const AWS = require('aws-sdk');
const dynamo = new AWS.DynamoDB.DocumentClient({
  region: process.env.AWS_REGION
});
const TABLE = process.env.DYNAMODB_TABLE;

async function updateJobStatus(scanId, updates) {
  const updateExpression = [];
  const expressionValues = {};
  const expressionNames = {};

  updates.updatedAt = new Date().toISOString();

  Object.entries(updates).forEach(([key, value]) => {
    updateExpression.push(`#${key} = :${key}`);
    expressionValues[`:${key}`] = value;
    expressionNames[`#${key}`] = key;
  });

  await dynamo.update({
    TableName: TABLE,
    Key: { scanId },
    UpdateExpression: `SET ${updateExpression.join(', ')}`,
    ExpressionAttributeValues: expressionValues,
    ExpressionAttributeNames: expressionNames,
  }).promise();
}

module.exports = { updateJobStatus };