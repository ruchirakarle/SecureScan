import React, { useState } from "react";
import { BrowserRouter, Routes, Route, NavLink } from "react-router-dom";
import Home from "./pages/Home";
import Scan from "./pages/Scan";
import Results from "./pages/Results";
import History from "./pages/History";
import "./App.css";

export default function App() {
  const [dark, setDark] = useState(false);

  return (
    <div data-theme={dark ? "dark" : "light"} style={{ minHeight: "100vh", background: "var(--bg)" }}>
      <BrowserRouter>
        <nav className="nav">
          <NavLink to="/" className="nav-logo">
            <span className="shield">⬡</span> SecureScan
          </NavLink>
          <div className="nav-links">
            <NavLink to="/scan" className={({ isActive }) => isActive ? "active" : ""}>Scan</NavLink>
            <NavLink to="/history" className={({ isActive }) => isActive ? "active" : ""}>History</NavLink>
            <button
              onClick={() => setDark(!dark)}
              className="btn btn-outline"
              style={{ fontSize: "0.8rem", padding: "0.3rem 0.8rem" }}
            >
              {dark ? "☀ Light" : "☾ Dark"}
            </button>
          </div>
        </nav>
        <main className="main">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/scan" element={<Scan />} />
            <Route path="/results" element={<Results />} />
            <Route path="/history" element={<History />} />
          </Routes>
        </main>
      </BrowserRouter>
    </div>
  );
}