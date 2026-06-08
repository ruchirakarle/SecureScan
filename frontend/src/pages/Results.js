import React from "react";
import { useLocation, useNavigate } from "react-router-dom";

function scoreClass(score) {
  if (score < 40) return "high";
  if (score < 70) return "medium";
  return "good";
}

function scoreColor(score) {
  if (score < 40) return "var(--high)";
  if (score < 70) return "var(--medium)";
  return "var(--low)";
}

export default function Results() {
  const { state } = useLocation();
  const navigate = useNavigate();
  const result = state?.result;

  if (!result) {
    return (
      <div className="empty">
        <div className="empty-icon">◎</div>
        <p>No scan result found.</p>
        <button className="btn btn-primary" style={{ marginTop: "1rem" }} onClick={() => navigate("/scan")}>
          Run a Scan
        </button>
      </div>
    );
  }

  const { score, scanType, severity, findings = [], createdAt } = result;

  return (
    <div>
      <div style={{ display: "flex", alignItems: "center", gap: "1rem", marginBottom: "1.5rem", flexWrap: "wrap" }}>
        <button className="btn btn-outline" style={{ fontSize: "0.8rem" }} onClick={() => navigate("/scan")}>
          ← New Scan
        </button>
        <h2 style={{ fontFamily: "var(--mono)" }}>Scan Results</h2>
        <span className={`tag tag-${(scanType || "code").toLowerCase()}`}>
          {scanType === "API" ? "⌁ API Scan" : "⟨/⟩ Code Scan"}
        </span>
      </div>
      <div className="card" style={{ display: "flex", alignItems: "center", gap: "2rem", marginBottom: "1.5rem", flexWrap: "wrap" }}>
        <div className={`score-ring ${scoreClass(score)}`}>
          <span className="score-number" style={{ color: scoreColor(score) }}>{score}</span>
          <span className="score-label">/ 100</span>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontWeight: 600, fontSize: "1.1rem", marginBottom: "0.25rem" }}>Security Score</div>
          <div style={{ color: "var(--muted)", fontSize: "0.85rem", marginBottom: "0.5rem" }}>
            {score >= 70 ? "No critical issues found." : score >= 40 ? "Some vulnerabilities detected." : "High severity issues detected."}
          </div>
          {severity && <span className={`tag tag-${severity.toLowerCase()}`}>{severity} severity</span>}
          {createdAt && (
            <div style={{ color: "var(--muted)", fontSize: "0.75rem", marginTop: "0.4rem" }}>
              {new Date(createdAt).toLocaleString()}
            </div>
          )}
        </div>
        <button className="btn btn-outline" onClick={() => navigate("/history")} style={{ fontSize: "0.8rem" }}>
          View History
        </button>
      </div>
      <h3 style={{ fontFamily: "var(--mono)", fontSize: "0.95rem", marginBottom: "1rem", color: "var(--muted)" }}>
        FINDINGS ({findings.length})
      </h3>
      {findings.length === 0 ? (
        <div className="card" style={{ textAlign: "center", padding: "2rem", color: "var(--low)" }}>
          ✓ No vulnerabilities detected
        </div>
      ) : (
        <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
          {findings.map((f, i) => (
            <div key={i} className="card" style={{ display: "flex", gap: "1rem", alignItems: "flex-start" }}>
              <span className={`tag tag-${(f.severity || "low").toLowerCase()}`} style={{ marginTop: "2px", whiteSpace: "nowrap" }}>
                {f.severity || "LOW"}
              </span>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 600, fontSize: "0.9rem", marginBottom: "0.2rem" }}>
                  {f.type || f.title || "Vulnerability"}
                </div>
                <div style={{ color: "var(--muted)", fontSize: "0.82rem", lineHeight: 1.5 }}>
                  {f.description || f.message}
                </div>
                {f.line && (
                  <div style={{ fontFamily: "var(--mono)", fontSize: "0.75rem", color: "var(--accent)", marginTop: "0.3rem" }}>
                    Line {f.line}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}