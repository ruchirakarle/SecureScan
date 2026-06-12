const BASE_URL = process.env.REACT_APP_API_URL || "http://localhost:3001";

async function request(path, options = {}) {
  const res = await fetch(`${BASE_URL}${path}`, {
    headers: { "Content-Type": "application/json" },
    ...options,
  });
  if (!res.ok) {
    const err = await res.json().catch(() => ({ message: res.statusText }));
    throw new Error(err.message || "Request failed");
  }
  return res.json();
}

export function runCodeScan(code) {
  return request("/api/scans/code", {
    method: "POST",
    body: JSON.stringify({ code }),
  });
}

export function runApiScan(url) {
  return request("/api/scans/url", {
    method: "POST",
    body: JSON.stringify({ targetUrl: url }),
  });
}

export function fetchScan(scanId) {
  return request(`/api/scans/${scanId}`);
}

export function fetchHistory() {
  return request("/api/history").then((data) => data.scans || []);
}