import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { fetchHistory } from "../services/api";

export default function History() {
  const navigate = useNavigate();
  const [scans, setScans] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [filter, setFilter] = useState("ALL");

  useEffect(() => {
    fetchHistory()
      .then(setScans)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  const filtered = filter === "ALL" ? scans : scans.filter((s) => s.scanType === filter);

  function scoreColor(score) {
    if (score < 40) return "var(--high)";
    if (score < 70) return "var(--medium)";
    return "var(--low)";
  }

  return (
    <div>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "1.5rem", flexWrap: "wrap", gap: "1rem" }}>
        <div>
          <h2 style={{ fontFamily: "var(--mono)", marginBottom: "0.2rem" }}>Scan History</h2>
          <p style={{ color: "var(--muted)", fontSize: "0.85rem" }}>{scans.length} total scans</p>
        </div>
        <button className="btn btn-primary" onClick={() => navigate("/scan")}>+ New Scan</button>
      </div>
      <div style={{ display: "flex", gap: "0.5rem", marginBottom: "1.25rem" }}>
        {[
          { value: "ALL", label: "All" },
          { value: "SAST", label: "⟨/⟩ Code" },
          { value: "PENTEST", label: "⌁ API" },
        ].map(({ value, label }) => (
          <button
            key={value}
            onClick={() => setFilter(value)}
            className={`btn ${filter === value ? "btn-primary" : "btn-outline"}`}
            style={{ fontSize: "0.78rem", padding: "0.35rem 0.9rem" }}
          >
            {label}
          </button>
        ))}
      </div>
      {loading && (
        <div style={{ textAlign: "center", padding: "3rem" }}>
          <span className="spinner" style={{ width: 28, height: 28, borderWidth: 3 }} />
        </div>
      )}
      {error && <div className="error-box">{error}</div>}
      {!loading && !error && filtered.length === 0 && (
        <div className="empty">
          <div className="empty-icon">◎</div>
          <p>No scans yet.</p>
          <button className="btn btn-primary" style={{ marginTop: "1rem" }} onClick={() => navigate("/scan")}>
            Run Your First Scan
          </button>
        </div>
      )}
      {!loading && !error && filtered.length > 0 && (
        <div style={{ display: "flex", flexDirection: "column", gap: "0.75rem" }}>
          {filtered.map((scan) => (
            <div
              key={scan.scanId}
              className="card"
              style={{ display: "flex", alignItems: "center", gap: "1.25rem", cursor: "pointer" }}
              onClick={() => navigate("/results", { state: { result: scan } })}
              onMouseEnter={(e) => e.currentTarget.style.borderColor = "var(--accent)"}
              onMouseLeave={(e) => e.currentTarget.style.borderColor = "var(--border)"}
            >
              <div style={{
                fontFamily: "var(--mono)",
                fontSize: "1.4rem",
                fontWeight: 700,
                color: scoreColor(scan.score),
                minWidth: 48,
                textAlign: "center"
              }}>
                {scan.score}
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ display: "flex", gap: "0.5rem", alignItems: "center", marginBottom: "0.3rem", flexWrap: "wrap" }}>
                  <span className={`tag tag-${scan.scanType === "PENTEST" ? "api" : "code"}`}>
                    {scan.scanType === "PENTEST" ? "⌁ API" : "⟨/⟩ Code"}
                  </span>
                  {scan.severity && <span className={`tag tag-${scan.severity.toLowerCase()}`}>{scan.severity}</span>}
                </div>
                <div style={{
                  fontFamily: "var(--mono)",
                  fontSize: "0.78rem",
                  color: "var(--muted)",
                  overflow: "hidden",
                  textOverflow: "ellipsis",
                  whiteSpace: "nowrap",
                  maxWidth: 400,
                }}>
                  {scan.target || scan.scanId}
                </div>
              </div>
              <div style={{ color: "var(--muted)", fontSize: "0.78rem", whiteSpace: "nowrap" }}>
                {scan.createdAt ? new Date(scan.createdAt).toLocaleDateString() : "—"}
              </div>
              <span style={{ color: "var(--muted)" }}>→</span>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}