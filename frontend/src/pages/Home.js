import React from "react";
import { useNavigate } from "react-router-dom";

export default function Home() {
  const navigate = useNavigate();

  return (
    <div style={{ maxWidth: 700, margin: "4rem auto", textAlign: "center" }}>
      <div style={{ marginBottom: "2rem" }}>
        <span style={{ fontSize: "3.5rem" }}>⬡</span>
      </div>
      <h1 style={{
        fontFamily: "var(--mono)",
        fontSize: "3rem",
        fontWeight: 700,
        color: "var(--accent)",
        letterSpacing: "-0.02em",
        marginBottom: "0.75rem"
      }}>
        SecureScan
      </h1>
      <p style={{ color: "var(--muted)", fontSize: "1.1rem", marginBottom: "0.5rem" }}>
        Paste. Scan. Secure.
      </p>
      <p style={{
        color: "var(--muted)",
        fontSize: "0.9rem",
        maxWidth: 480,
        margin: "0 auto 2.5rem",
        lineHeight: 1.6
      }}>
        A cloud-native security platform. Scan JavaScript code for vulnerabilities
        or probe a live API for security weaknesses — no setup required.
      </p>
      <div style={{ display: "flex", gap: "1rem", justifyContent: "center", flexWrap: "wrap" }}>
        <button className="btn btn-primary" onClick={() => navigate("/scan")}>
          Start Scanning →
        </button>
        <button className="btn btn-outline" onClick={() => navigate("/history")}>
          View History
        </button>
      </div>
      <div style={{
        display: "grid",
        gridTemplateColumns: "repeat(3, 1fr)",
        gap: "1rem",
        marginTop: "4rem"
      }}>
        {[
          { icon: "⟨/⟩", label: "Code Scan (SAST)", desc: "10 vulnerability types detected" },
          { icon: "⌁", label: "API Pentest", desc: "6 live security checks per scan" },
          { icon: "◎", label: "Security Score", desc: "0–100 score for every scan" },
        ].map(({ icon, label, desc }) => (
          <div key={label} className="card" style={{ textAlign: "left" }}>
            <div style={{ fontSize: "1.5rem", marginBottom: "0.75rem", color: "var(--accent)" }}>
              {icon}
            </div>
            <div style={{ fontWeight: 600, marginBottom: "0.25rem", fontSize: "0.9rem" }}>{label}</div>
            <div style={{ color: "var(--muted)", fontSize: "0.8rem" }}>{desc}</div>
          </div>
        ))}
      </div>
    </div>
  );
}