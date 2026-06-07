function calculateScore(findings) {
  if (!findings || findings.length === 0) return 100;

  const deductions = { HIGH: 15, MEDIUM: 7, LOW: 2 };
  let score = 100;

  findings.forEach(finding => {
    const severity = (finding.severity || '').toUpperCase();
    score -= (deductions[severity] || 0);
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

module.exports = { calculateScore, countBySeverity };

