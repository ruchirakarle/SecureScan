const axios = require('axios');

async function runSASTScan(code) {
  const scannerUrl = process.env.SAST_SCANNER_URL || 'http://localhost:3000';

  const response = await axios.post(`${scannerUrl}/scan/code`, { code }, {
    timeout: 30000,
    headers: { 'Content-Type': 'application/json' },
  });

  return response.data;
}

module.exports = { runSASTScan };