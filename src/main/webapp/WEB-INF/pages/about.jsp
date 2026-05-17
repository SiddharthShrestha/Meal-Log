<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>MealLog — About</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --green:#3d7a5a; --green-light:#5aab7e; --green-pale:#e8f5ee; --green-dim:#a8d5bc;
      --cream:#faf8f3; --white:#ffffff; --ink:#1a1f1c; --muted:#6b7a72; --border:#d4e0d9;
      --shadow:0 4px 24px rgba(30,50,38,0.10); --radius:14px; --radius-sm:8px;
      --red:#c0392b; --red-pale:#fdecea; --red-dim:#f5c6c2;
    }
    body { font-family:'DM Sans',sans-serif; background:var(--cream); color:var(--ink); }

    /* ── Navbar ── */
    .navbar {
      background:var(--white);
      border-bottom:1.5px solid var(--border);
      padding:0 40px;
      height:62px;
      display:flex;
      align-items:center;
      justify-content:space-between;
      position:sticky; top:0; z-index:100;
    }
    .brand { display:flex; align-items:center; gap:10px; text-decoration:none; }
    .brand-icon { width:34px; height:34px; background:var(--green); border-radius:8px; display:flex; align-items:center; justify-content:center; }
    .brand-icon svg { width:18px; height:18px; stroke:#fff; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
    .brand-name { font-family:'Playfair Display',serif; font-size:1.3rem; color:var(--ink); }
    .brand-name span { color:var(--green); }
    .nav-links { display:flex; align-items:center; gap:12px; }
    .nav-btn {
      padding:8px 18px;
      border-radius:var(--radius-sm);
      font-family:'DM Sans',sans-serif;
      font-size:0.88rem; font-weight:600;
      text-decoration:none; cursor:pointer; border:none;
      transition:background 0.18s, color 0.18s;
    }
    .nav-btn.outline { background:none; color:var(--green); border:1.5px solid var(--green); }
    .nav-btn.outline:hover { background:var(--green-pale); }
    .nav-btn.filled { background:var(--green); color:#fff; }
    .nav-btn.filled:hover { background:var(--green-light); }

    /* ── Hero ── */
    .hero {
      background: linear-gradient(135deg, #2d5e43 0%, #3d7a5a 50%, #4a9068 100%);
      padding: 80px 40px;
      text-align: center;
      color: #fff;
      position: relative;
      overflow: hidden;
    }
    .hero::before {
      content:'';
      position:absolute; top:-60px; right:-60px;
      width:300px; height:300px;
      border-radius:50%;
      background:rgba(255,255,255,0.05);
    }
    .hero::after {
      content:'';
      position:absolute; bottom:-80px; left:-40px;
      width:250px; height:250px;
      border-radius:50%;
      background:rgba(255,255,255,0.04);
    }
    .hero-badge {
      display:inline-block;
      background:rgba(255,255,255,0.15);
      border:1px solid rgba(255,255,255,0.25);
      border-radius:20px;
      padding:6px 16px;
      font-size:0.8rem;
      font-weight:600;
      letter-spacing:0.08em;
      text-transform:uppercase;
      margin-bottom:20px;
    }
    .hero h1 { font-family:'Playfair Display',serif; font-size:2.8rem; font-weight:700; margin-bottom:16px; line-height:1.2; }
    .hero p { font-size:1rem; opacity:0.85; max-width:560px; margin:0 auto; line-height:1.7; }

    /* ── Main content ── */
    .container { max-width:900px; margin:0 auto; padding:60px 40px; }

    .section { margin-bottom:56px; }
    .section-label {
      display:inline-flex; align-items:center; gap:8px;
      background:var(--green-pale);
      color:var(--green);
      font-size:0.75rem; font-weight:700;
      letter-spacing:0.08em; text-transform:uppercase;
      padding:5px 12px; border-radius:20px;
      margin-bottom:14px;
    }
    .section-label svg { width:13px; height:13px; stroke:currentColor; fill:none; stroke-width:2.5; stroke-linecap:round; stroke-linejoin:round; }
    .section h2 { font-family:'Playfair Display',serif; font-size:1.7rem; color:var(--ink); margin-bottom:14px; }
    .section p { font-size:0.93rem; color:var(--muted); line-height:1.8; margin-bottom:12px; }

    /* ── Feature grid ── */
    .feature-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(240px,1fr)); gap:16px; margin-top:20px; }
    .feature-card {
      background:var(--white);
      border:1.5px solid var(--border);
      border-radius:var(--radius);
      padding:22px 20px;
      transition:box-shadow 0.18s, transform 0.18s;
    }
    .feature-card:hover { box-shadow:var(--shadow); transform:translateY(-2px); }
    .feature-icon {
      width:40px; height:40px;
      background:var(--green-pale);
      border-radius:10px;
      display:flex; align-items:center; justify-content:center;
      margin-bottom:12px;
    }
    .feature-icon svg { width:20px; height:20px; stroke:var(--green); fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
    .feature-card h3 { font-size:0.95rem; font-weight:600; color:var(--ink); margin-bottom:6px; }
    .feature-card p { font-size:0.83rem; color:var(--muted); line-height:1.6; }

    /* ── Tech stack ── */
    .tech-grid { display:flex; flex-wrap:wrap; gap:10px; margin-top:16px; }
    .tech-badge {
      background:var(--white);
      border:1.5px solid var(--border);
      border-radius:var(--radius-sm);
      padding:8px 16px;
      font-size:0.83rem; font-weight:600;
      color:var(--ink);
      display:flex; align-items:center; gap:6px;
    }
    .tech-badge span { color:var(--green); font-size:1rem; }

    /* ── Gaza banner ── */
    .gaza-banner {
      background: linear-gradient(135deg, #1a0a0a 0%, #2d0f0f 100%);
      border: 2px solid var(--red);
      border-radius: var(--radius);
      padding: 36px 40px;
      margin-bottom: 56px;
      position: relative;
      overflow: hidden;
    }
    .gaza-banner::before {
      content:'';
      position:absolute; top:0; left:0; right:0; bottom:0;
      background: repeating-linear-gradient(
        45deg,
        transparent,
        transparent 10px,
        rgba(192,57,43,0.03) 10px,
        rgba(192,57,43,0.03) 20px
      );
    }
    .gaza-top {
      display:flex; align-items:center; gap:14px; margin-bottom:16px;
    }
    .gaza-icon {
      width:48px; height:48px; flex-shrink:0;
      background:rgba(192,57,43,0.15);
      border:1.5px solid rgba(192,57,43,0.3);
      border-radius:50%;
      display:flex; align-items:center; justify-content:center;
      font-size:1.4rem;
    }
    .gaza-title { font-family:'Playfair Display',serif; font-size:1.3rem; color:#fff; }
    .gaza-subtitle { font-size:0.8rem; color:rgba(255,255,255,0.5); margin-top:2px; }
    .gaza-body { font-size:0.9rem; color:rgba(255,255,255,0.8); line-height:1.8; position:relative; }
    .gaza-body strong { color:#fff; }
    .gaza-highlight {
      display:inline-block;
      background:rgba(192,57,43,0.2);
      border:1px solid rgba(192,57,43,0.4);
      border-radius:6px;
      padding:2px 10px;
      color:#e74c3c;
      font-weight:700;
      font-size:1rem;
    }
    .gaza-flags { font-size:1.3rem; margin-top:16px; opacity:0.8; }

    /* ── Team ── */
    .team-card {
      background:var(--white);
      border:1.5px solid var(--border);
      border-radius:var(--radius);
      padding:28px;
      display:flex; align-items:center; gap:20px;
      box-shadow:var(--shadow);
    }
    .team-avatar {
      width:64px; height:64px; flex-shrink:0;
      background:var(--green);
      border-radius:50%;
      display:flex; align-items:center; justify-content:center;
      font-family:'Playfair Display',serif;
      font-size:1.5rem; font-weight:700; color:#fff;
    }
    .team-info h3 { font-size:1.05rem; font-weight:600; color:var(--ink); margin-bottom:4px; }
    .team-info p { font-size:0.85rem; color:var(--muted); line-height:1.5; }
    .team-info .role { color:var(--green); font-weight:600; font-size:0.8rem; text-transform:uppercase; letter-spacing:0.05em; margin-bottom:4px; }

    /* ── Footer ── */
    .footer {
      background:var(--white);
      border-top:1.5px solid var(--border);
      padding:24px 40px;
      text-align:center;
      font-size:0.83rem;
      color:var(--muted);
    }
    .footer a { color:var(--green); text-decoration:none; font-weight:600; }
    .footer a:hover { text-decoration:underline; }

    @media (max-width:600px) {
      .hero { padding:50px 20px; }
      .hero h1 { font-size:2rem; }
      .container { padding:40px 20px; }
      .navbar { padding:0 20px; }
      .gaza-banner { padding:24px 20px; }
      .team-card { flex-direction:column; text-align:center; }
      .footer { padding:20px; }
    }
  </style>
</head>
<body>

<%
  boolean loggedIn      = session != null && session.getAttribute("userId")    != null;
  boolean adminLoggedIn = session != null && session.getAttribute("adminLoggedIn") != null;
%>

<!-- Navbar -->
<nav class="navbar">
  <a href="<%= loggedIn ? "dashboard" : adminLoggedIn ? "admin" : "login" %>" class="brand">
    <div class="brand-icon">
      <svg viewBox="0 0 24 24"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg>
    </div>
    <div class="brand-name">Meal<span>Log</span></div>
  </a>
  <div class="nav-links">
    <% if (loggedIn) { %>
      <a href="dashboard" class="nav-btn outline">Dashboard</a>
      <a href="login" class="nav-btn filled">Sign Out</a>
    <% } else if (adminLoggedIn) { %>
      <a href="admin" class="nav-btn outline">Admin Panel</a>
    <% } else { %>
      <a href="login"    class="nav-btn outline">Sign In</a>
      <a href="register" class="nav-btn filled">Get Started</a>
    <% } %>
  </div>
</nav>

<!-- Hero -->
<div class="hero">
  <div class="hero-badge">&#127807; About MealLog</div>
  <h1>Track your meals.<br/>Transform your health.</h1>
  <p>MealLog is a free, privacy-first nutrition tracking platform built to help you understand your food, hit your goals, and live better — one meal at a time.</p>
</div>

<!-- Main content -->
<div class="container">

  <!-- Mission -->
  <div class="section">
    <div class="section-label">
      <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg>
      Our Mission
    </div>
    <h2>Why we built MealLog</h2>
    <p>Nutrition tracking shouldn't be complicated, expensive, or overwhelming. MealLog was built as a simple, clean, and powerful tool that anyone can use — whether you're trying to lose weight, build muscle, or just eat better.</p>
    <p>We believe that understanding what you eat is the first step to a healthier life. MealLog gives you the tools to log meals, track macros, set goals, and monitor your progress — all in one place, completely free.</p>
  </div>

  <!-- Features -->
  <div class="section">
    <div class="section-label">
      <svg viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
      Features
    </div>
    <h2>Everything you need</h2>
    <div class="feature-grid">
      <div class="feature-card">
        <div class="feature-icon"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></div>
        <h3>Meal Logging</h3>
        <p>Log meals from a curated food database with automatic macro calculation.</p>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><svg viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/></svg></div>
        <h3>Macro Tracking</h3>
        <p>Track calories, protein, carbs and fats against your personalised daily goals.</p>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg></div>
        <h3>7-Day Charts</h3>
        <p>Visualise your intake over the past week with interactive bar and stacked charts.</p>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></div>
        <h3>Goal Setting</h3>
        <p>Set calorie and macro targets using our BMR calculator based on your body stats.</p>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg></div>
        <h3>Secure Accounts</h3>
        <p>Session-based authentication, account lockout protection, and OTP password reset.</p>
      </div>
      <div class="feature-card">
        <div class="feature-icon"><svg viewBox="0 0 24 24"><path d="M12 20h9"/><path d="M16.5 3.5a2.121 2.121 0 0 1 3 3L7 19l-4 1 1-4L16.5 3.5z"/></svg></div>
        <h3>Weight Estimation</h3>
        <p>See your estimated weekly weight change based on your calorie deficit or surplus.</p>
      </div>
    </div>
  </div>

  <!-- Tech stack -->
  <div class="section">
    <div class="section-label">
      <svg viewBox="0 0 24 24"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>
      Technology
    </div>
    <h2>Built with</h2>
    <div class="tech-grid">
      <div class="tech-badge"><span>&#9749;</span> Java EE / Jakarta Servlets</div>
      <div class="tech-badge"><span>&#128196;</span> JSP (Java Server Pages)</div>
      <div class="tech-badge"><span>&#127760;</span> MySQL via XAMPP</div>
      <div class="tech-badge"><span>&#127808;</span> Apache Tomcat</div>
      <div class="tech-badge"><span>&#127912;</span> Custom CSS (no frameworks)</div>
      <div class="tech-badge"><span>&#128202;</span> Chart.js</div>
      <div class="tech-badge"><span>&#9749;</span> Eclipse IDE</div>
      <div class="tech-badge"><span>&#128640;</span> MVC Architecture</div>
    </div>
  </div>

  <!-- Gaza donation banner -->
  <div class="gaza-banner">
    <div class="gaza-top">
      <div class="gaza-icon">&#10084;&#65039;</div>
      <div>
        <div class="gaza-title">We Stand With Gaza</div>
        <div class="gaza-subtitle">Our commitment to humanity</div>
      </div>
    </div>
    <div class="gaza-body">
      <p>
        At MealLog, we believe that no one should go hungry. While we help people track and manage their nutrition,
        we are deeply aware that millions of children in Gaza are facing starvation and a devastating humanitarian crisis.
      </p>
      <br/>
      <p>
        That is why <strong>MealLog commits to donating a portion of every rupee of profit</strong> generated by this platform
        directly to humanitarian aid organisations supporting the
        <strong>starving and dying children of Gaza</strong>.
        Every meal you log on MealLog is a step toward a healthier you —
        and a small contribution toward feeding a child who has nothing.
      </p>
      <br/>
      <p>
        Donation amount: <span class="gaza-highlight">40% of all profits</span> go directly to Gaza humanitarian relief.
      </p>
      <div class="gaza-flags">&#127477;&#127480; &nbsp; &#10084;&#65039; &nbsp; Free Palestine</div>
    </div>
  </div>

  <!-- Developer -->
  <div class="section">
    <div class="section-label">
      <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
      The Developer
    </div>
    <h2>Who built this</h2>
    <div class="team-card">
      <div class="team-avatar">S</div>
      <div class="team-info">
        <div class="role">Full Stack Developer</div>
        <h3>Siddharth Nath Shrestha</h3>
        <p>
          MealLog was developed by Siddharth Nath Shrestha as part of a DSA coursework assessment. The project covers full stack web development using Java EE Servlets, JSP, MySQL and Apache Tomcat, following MVC architecture and standard software development practices.
        </p>
      </div>
    </div>
  </div>

</div>

<!-- Footer -->
<div class="footer">
  &copy; 2025 MealLog &mdash; Built with &#10084; by Siddharth &nbsp;|&nbsp;
  <a href="login">Sign In</a> &nbsp;|&nbsp;
  <a href="register">Register</a> &nbsp;|&nbsp;
  <a href="about">About</a>
</div>

</body>
</html>