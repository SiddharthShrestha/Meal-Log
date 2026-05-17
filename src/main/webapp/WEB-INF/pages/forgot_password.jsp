<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>MealLog — Forgot Password</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --green:#3d7a5a; --green-light:#5aab7e; --green-pale:#e8f5ee; --green-dim:#a8d5bc;
      --cream:#faf8f3; --white:#ffffff; --ink:#1a1f1c; --muted:#6b7a72; --border:#d4e0d9;
      --error:#c0392b; --error-bg:#fdecea; --success:#27ae60; --success-bg:#f0fff4;
      --shadow:0 4px 24px rgba(30,50,38,0.10); --radius:14px; --radius-sm:8px;
    }
    body { font-family:'DM Sans',sans-serif; background:var(--cream); min-height:100vh; display:flex; align-items:center; justify-content:center; padding:40px 20px; color:var(--ink); }
    .wrapper { width:100%; max-width:420px; display:flex; flex-direction:column; gap:20px; }
    .brand-bar { display:flex; align-items:center; gap:10px; justify-content:center; }
    .brand-icon { width:38px; height:38px; background:var(--green); border-radius:10px; display:flex; align-items:center; justify-content:center; }
    .brand-icon svg { width:20px; height:20px; stroke:#fff; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
    .brand-name { font-family:'Playfair Display',serif; font-size:1.5rem; color:var(--ink); }
    .brand-name span { color:var(--green); }
    .card { background:var(--white); border-radius:var(--radius); box-shadow:var(--shadow); padding:32px 32px 28px; border:1.5px solid rgba(212,224,217,0.6); }
    .card-icon { width:52px; height:52px; background:var(--green-pale); border-radius:50%; display:flex; align-items:center; justify-content:center; margin-bottom:18px; }
    .card-icon svg { width:24px; height:24px; stroke:var(--green); fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
    .card-title { font-family:'Playfair Display',serif; font-size:1.35rem; font-weight:500; color:var(--ink); margin-bottom:6px; }
    .card-subtitle { font-size:0.85rem; color:var(--muted); margin-bottom:26px; line-height:1.5; }
    .banner { border-radius:var(--radius-sm); padding:11px 14px; font-size:0.88rem; font-weight:500; margin-bottom:20px; display:flex; align-items:flex-start; gap:8px; line-height:1.5; }
    .banner.success { background:var(--success-bg); color:var(--success); border:1px solid #b7e4c7; }
    .banner.error   { background:var(--error-bg);   color:var(--error);   border:1px solid #f5c6c2; }
    .field { margin-bottom:18px; }
    label { display:block; font-size:0.78rem; font-weight:600; letter-spacing:0.05em; text-transform:uppercase; color:var(--muted); margin-bottom:6px; }
    input[type="email"],
    input[type="text"] { width:100%; padding:12px 14px; border:1.5px solid var(--border); border-radius:var(--radius-sm); font-family:'DM Sans',sans-serif; font-size:0.93rem; background:var(--white); color:var(--ink); outline:none; transition:border-color .18s,box-shadow .18s; }
    input:focus { border-color:var(--green); box-shadow:0 0 0 3px rgba(61,122,90,0.10); }
    input.invalid { border-color:var(--error); box-shadow:0 0 0 3px rgba(192,57,43,0.08); }
    .err { color:var(--error); font-size:0.76rem; margin-top:5px; display:flex; align-items:center; gap:4px; }
    .err::before { content:'⚠'; font-size:0.7rem; }
    .otp-input { text-align:center; font-size:1.8rem; font-weight:700; letter-spacing:12px; color:var(--green); }
    .btn-primary { width:100%; padding:13px; background:var(--green); color:#fff; border:none; border-radius:var(--radius-sm); font-family:'DM Sans',sans-serif; font-size:0.95rem; font-weight:600; cursor:pointer; transition:background .18s,transform .1s; letter-spacing:0.02em; margin-top:4px; }
    .btn-primary:hover  { background:var(--green-light); }
    .btn-primary:active { transform:scale(0.99); }
    .resend-link { text-align:center; margin-top:14px; font-size:0.83rem; color:var(--muted); }
    .resend-link a { color:var(--green); text-decoration:none; font-weight:600; }
    .resend-link a:hover { text-decoration:underline; }
    .footer-link { text-align:center; font-size:0.84rem; color:var(--muted); }
    .footer-link a { color:var(--green); text-decoration:none; font-weight:600; }
    .footer-link a:hover { text-decoration:underline; }
    @media (max-width:480px) { .card { padding:24px 20px 22px; } }
  </style>
</head>
<body>
<div class="wrapper">

  <div class="brand-bar">
    <div class="brand-icon">
      <svg viewBox="0 0 24 24"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg>
    </div>
    <div class="brand-name">Meal<span>Log</span></div>
  </div>

  <div class="card">

    <%-- Token/session expired error --%>
    <% if (request.getAttribute("tokenErr") != null) { %>
      <div class="banner error">&#9888; <%= request.getAttribute("tokenErr") %></div>
    <% } %>

    <% if (Boolean.TRUE.equals(request.getAttribute("otpSent"))) { %>
      <%-- STEP 2: OTP entry form --%>
      <div class="card-icon">
        <svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.41 2 2 0 0 1 3.6 1.24h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L7.91 8.91a16 16 0 0 0 6.06 6.06l.91-.91a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 21.73 16.92z"/></svg>
      </div>
      <div class="card-title">Check your email</div>
      <div class="card-subtitle">
        We sent a 6-digit code to <strong><%= request.getAttribute("email") %></strong>. Enter it below.
      </div>

      <% if (request.getAttribute("otpErr") != null) { %>
        <div class="banner error">&#9888; <%= request.getAttribute("otpErr") %></div>
      <% } %>

      <form action="forgot-password" method="post">
        <input type="hidden" name="action" value="verify_otp"/>
        <input type="hidden" name="email" value="<%= request.getAttribute("email") %>"/>
        <div class="field">
          <label for="otp">6-Digit Code</label>
          <input type="text" id="otp" name="otp" class="otp-input"
            placeholder="000000" maxlength="6" autocomplete="one-time-code" autofocus/>
        </div>
        <button type="submit" class="btn-primary">Verify Code</button>
      </form>

      <div class="resend-link">
        Didn't get it? <a href="forgot-password">Resend code</a>
      </div>

    <% } else { %>
      <%-- STEP 1: Email entry form --%>
      <div class="card-icon">
        <svg viewBox="0 0 24 24"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
      </div>
      <div class="card-title">Forgot password?</div>
      <div class="card-subtitle">Enter your registered email and we'll send you a reset code.</div>

      <form action="forgot-password" method="post">
        <div class="field">
          <label for="email">Email Address</label>
          <input type="email" id="email" name="email" placeholder="you@example.com"
            value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>"
            class="<%= request.getAttribute("emailErr") != null ? "invalid" : "" %>"
            autocomplete="email" autofocus/>
          <% if (request.getAttribute("emailErr") != null) { %>
            <div class="err"><%= request.getAttribute("emailErr") %></div>
          <% } %>
        </div>
        <button type="submit" class="btn-primary">Send Code</button>
      </form>
    <% } %>

  </div>

  <div class="footer-link"><a href="login">&#8592; Back to Sign In</a></div>

</div>
</body>
</html>