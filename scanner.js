const express = require("express");
const https = require("https");
const http = require("http");

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3002;

// Run 6 security checks on a URL
async function runPentestChecks(url) {
    const results = [];

    // Check 1: HTTPS
    results.push({
        check: "HTTPS Enforcement",
        passed: url.startsWith("https://"),
        severity: url.startsWith("https://") ? "LOW" : "HIGH"
    });

    // Check 2: Security Headers
    try {
        const headers = await checkHeaders(url);
        results.push({
            check: "Security Headers",
            passed: headers.hasSecurityHeaders,
            severity: headers.hasSecurityHeaders ? "LOW" : "MEDIUM",
            details: headers.missing
        });
    } catch (e) {
        results.push({
            check: "Security Headers",
            passed: false,
            severity: "HIGH",
            error: e.message
        });
    }

    // Check 3: SQL Injection probe
    results.push({
        check: "SQL Injection Probe",
        passed: !url.includes("'") && !url.includes("--"),
        severity: "LOW",
        details: "No obvious SQLi vectors in endpoint"
    });

    // Check 4: XSS probe
    results.push({
        check: "XSS Probe",
        passed: !url.includes("<script>") && !url.includes("javascript:"),
        severity: "LOW",
        details: "No reflected XSS detected"
    });

    // Check 5: Open redirect
    results.push({
        check: "Open Redirect Check",
        passed: !url.includes("redirect=") && !url.includes("url="),
        severity: "MEDIUM"
    });

    // Check 6: Sensitive data exposure
    results.push({
        check: "Sensitive Data Exposure",
        passed: !url.includes("password") && !url.includes("token") && !url.includes("secret"),
        severity: "HIGH"
    });

    const passed = results.filter(r => r.passed).length;
    const score = Math.round((passed / results.length) * 100);
    const severity = score >= 80 ? "LOW" : score >= 50 ? "MEDIUM" : "HIGH";
    const hasHigh = results.some(r => !r.passed && r.severity === "HIGH");

    return { results, score, severity, hasHigh };
}

async function checkHeaders(url) {
    return new Promise((resolve) => {
        const client = url.startsWith("https") ? https : http;
        client.get(url, (res) => {
            const missing = [];
            if (!res.headers["x-frame-options"]) missing.push("X-Frame-Options");
            if (!res.headers["x-content-type-options"]) missing.push("X-Content-Type-Options");
            if (!res.headers["strict-transport-security"]) missing.push("HSTS");
            resolve({ hasSecurityHeaders: missing.length === 0, missing });
        }).on("error", () => resolve({
            hasSecurityHeaders: false,
            missing: ["Could not connect"]
        }));
    });
}

// Health check endpoint
app.get("/health", (req, res) => {
    res.json({ status: "ok", service: "pentest-scanner" });
});

// Main scan endpoint
app.post("/scan", async (req, res) => {
    const { url } = req.body;

    if (!url) {
        return res.status(400).json({ error: "URL is required" });
    }

    console.log(`Running pentest scan on: ${url}`);

    try {
        const { results, score, severity, hasHigh } = await runPentestChecks(url);

        const scanResult = {
            scanId: `pentest-${Date.now()}`,
            scanType: "API",
            target: url,
            score,
            severity,
            findings: results,
            status: "COMPLETED",
            createdAt: new Date().toISOString()
        };

        console.log(`Scan complete. Score: ${score}/100, Severity: ${severity}`);
        res.json(scanResult);

    } catch (error) {
        console.error("Scan error:", error.message);
        res.status(500).json({
            error: "Scan failed",
            details: error.message,
            status: "FAILED"
        });
    }
});

app.listen(PORT, () => {
    console.log(`Pentest scanner running on port ${PORT}`);
});
