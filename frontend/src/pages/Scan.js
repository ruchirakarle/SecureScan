import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { runCodeScan, runApiScan } from "../services/api";

export default function Scan() {
  const navigate = useNavigate();
  const [tab, setTab] = useState("CODE");
  const [code, setCode] = useState("");
  const [apiUrl, setApiUrl] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  async function handleSubmit() {
    setError(null);
    setLoading(true);
    try {
      let result;
      if (tab === "CODE") {
        if (!code.trim()) throw new Error("Please paste some JavaScript code.");
        result = await runCodeScan(code);
      } else {
        if (!apiUrl.trim()) throw new Error("Please enter an API URL.");
        result = await runApiScan(apiUrl);
      }
      navigate("/results", { state: { result } });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div>
      <h2 style={{ fontFamily: "var(--mono)", marginBottom: "0.25rem" }}>New Scan</h2>
      <p style={{ color: "var(--muted)", fontSize: "0.9rem", marginBottom: "1.5rem" }}>
        Choose a scan type and submit your target.
      </p>
      <div style={{ display: "flex", gap: "0.5rem", marginBottom: "1.5rem" }}>
        {["CODE", "API"].map((t) => (
          <button
            key={t}
            onClick={() => { setTab(t); setError(null); }}
            className={`btn ${tab === t ? "btn-primary" : "btn-outline"}`}
            style={{ fontSize: "0.8rem", padding: "0.4rem 1rem" }}
          >
            {t === "CODE" ? "⟨/⟩ Code Scan" : "⌁ API Scan"}
          </button>
        ))}
      </div>
      <div className="card">
        {tab === "CODE" ? (
          <>
            <label style={{ display: "block", fontSize: "0.85rem", color: "var(--muted)", marginBottom: "0.5rem" }}>
              Paste JavaScript code to scan
            </label>
            <textarea
              value={code}
              onChange={(e) => setCode(e.target.value)}
              placeholder={`// Paste your JavaScript code here\nconst query = "SELECT * FROM users WHERE id = " + userId;`}
              rows={16}
              style={{
                width: "100%",
                background: "var(--bg3)",
                border: "1px solid var(--border)",
                borderRadius: "8px",
                padding: "1rem",
                color: "var(--text)",
                fontFamily: "var(--mono)",
                fontSize: "0.8rem",
                resize: "vertical",
                lineHeight: 1.6,
                outline: "none",
              }}
            />
          </>
        ) : (
          <>
            <label style={{ display: "block", fontSize: "0.85rem", color: "var(--muted)", marginBottom: "0.5rem" }}>
              Enter API URL to probe
            </label>
            <input
              type="url"
              value={apiUrl}
              onChange={(e) => setApiUrl(e.target.value)}
              placeholder="https://api.example.com"
              style={{
                width: "100%",
                background: "var(--bg3)",
                border: "1px solid var(--border)",
                borderRadius: "8px",
                padding: "0.75rem 1rem",
                color: "var(--text)",
                fontFamily: "var(--mono)",
                fontSize: "0.9rem",
                outline: "none",
              }}
            />
            <p style={{ fontSize: "0.78rem", color: "var(--muted)", marginTop: "0.75rem" }}>
              Runs 6 security checks: HTTPS enforcement, CORS policy, auth headers, rate limiting, error exposure, and injection probes.
            </p>
          </>
        )}
        {error && <div className="error-box">{error}</div>}
        <div style={{ marginTop: "1.25rem", display: "flex", gap: "0.75rem", alignItems: "center" }}>
          <button className="btn btn-primary" onClick={handleSubmit} disabled={loading}>
            {loading ? <><span className="spinner" /> Scanning…</> : "Run Scan →"}
          </button>
          {loading && (
            <span style={{ fontSize: "0.8rem", color: "var(--muted)" }}>This may take a few seconds</span>
          )}
        </div>
      </div>
    </div>
  );
}