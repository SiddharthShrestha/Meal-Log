<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>MealLog — Reset Password</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after { box-sizing:border-box; margin:0; padding:0; }
    :root {
      --green:#3d7a5a; --green-light:#5aab7e; --green-pale:#e8f5ee;
      --cream:#faf8f3; --white:#ffffff; --ink:#1a1f1c; --muted:#6b7a72; --border:#d4e0d9;
      --error:#c0392b; --error-bg:#fdecea;
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
    .banner.error { background:var(--error-bg); color:var(--error); border:1px solid #f5c6c2; border-radius:var(--radius-sm); padding:11px 14px; font-size:0.88rem; font-weight:500; margin-bottom:20px; display:flex; align-items:center; gap:8px; }
    .field { margin-bottom:18px; }
    label { display:block; font-size:0.78rem; font-weight:600; letter-spacing:0.05em; text-transform:uppercase; color:var(--muted); margin-bottom:6px; }
    .pass-wrap { position:relative; }
    .pass-wrap input { width:100%; padding:12px 44px 12px 14px; border:1.5px solid var(--border); border-radius:var(--radius-sm); font-family:'DM Sans',sans-serif; font-size:0.93rem; background:var(--white); color:var(--ink); outline:none; transition:border-color .18s,box-shadow .18s; }
    .pass-wrap input:focus { border-color:var(--green); box-shadow:0 0 0 3px rgba(61,122,90,0.10); }
    .pass-wrap input.invalid { border-color:var(--error); box-shadow:0 0 0 3px rgba(192,57,43,0.08); }
    .toggle-pass { position:absolute; right:12px; top:50%; transform:translateY(-50%); background:none; border:none; cursor:pointer; padding:4px; color:var(--muted); display:flex; align-items:center; }
    .toggle-pass:hover { color:var(--green); }
    .toggle-pass svg { width:18px; height:18px; stroke:currentColor; fill:none; stroke-width:2; stroke-linecap:round; stroke-linejoin:round; pointer-events:none; }
    .strength-bar { height:4px; border-radius:2px; background:#e2e8e4; margin-top:8px; overflow:hidden; }
    .strength-fill { height:100%; width:0; border-radius:2px; transition:width .3s,background .3s; }
    .strength-label { font-size:0.73rem; color:var(--muted); margin-top:4px; min-height:1em; }
    .btn-primary { width:100%; padding:13px; background:var(--green); color:#fff; border:none; border-radius:var(--radius-sm); font-family:'DM Sans',sans-serif; font-size:0.95rem; font-weight:600; cursor:pointer; transition:background .18s,transform .1s; letter-spacing:0.02em; margin-top:4px; }
    .btn-primary:hover  { background:var(--green-light); }
    .btn-primary:active { transform:scale(0.99); }
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
    <div class="card-icon">
      <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
    </div>
    <div class="card-title">Set new password</div>
    <div class="card-subtitle">Choose a strong password — at least 6 characters.</div>

    <% if (request.getAttribute("passErr") != null) { %>
      <div class="banner error">&#9888; <%= request.getAttribute("passErr") %></div>
    <% } %>

    <form action="reset-password" method="post">
      <input type="hidden" name="email" value="<%= request.getAttribute("email") %>"/>

      <div class="field">
        <label for="password">New Password</label>
        <div class="pass-wrap">
          <input type="password" id="password" name="password"
            placeholder="At least 6 characters"
            class="<%= request.getAttribute("passErr") != null ? "invalid" : "" %>"
            autocomplete="new-password" autofocus
            oninput="checkStrength(this.value)"/>
          <button type="button" class="toggle-pass" onclick="togglePass('password','eye1')">
            <svg id="eye1" viewBox="0 0 24 24">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
              <circle cx="12" cy="12" r="3"/>
            </svg>
          </button>
        </div>
        <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
        <div class="strength-label" id="strengthLabel"></div>
      </div>

      <div class="field">
        <label for="confirmPassword">Confirm Password</label>
        <div class="pass-wrap">
          <input type="password" id="confirmPassword" name="confirmPassword"
            placeholder="Repeat your password"
            autocomplete="new-password"/>
          <button type="button" class="toggle-pass" onclick="togglePass('confirmPassword','eye2')">
            <svg id="eye2" viewBox="0 0 24 24">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
              <circle cx="12" cy="12" r="3"/>
            </svg>
          </button>
        </div>
      </div>

      <button type="submit" class="btn-primary">Reset Password</button>
    </form>
  </div>

  <div class="footer-link"><a href="login">&#8592; Back to Sign In</a></div>

</div>

<script>
  function togglePass(inputId, iconId) {
    var input = document.getElementById(inputId);
    var icon  = document.getElementById(iconId);
    if (input.type === 'password') {
      input.type = 'text';
      icon.innerHTML = '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/>';
    } else {
      input.type = 'password';
      icon.innerHTML = '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>';
    }
  }

  function checkStrength(val) {
    var fill  = document.getElementById('strengthFill');
    var label = document.getElementById('strengthLabel');
    var score = 0;
    if (val.length >= 6)  score++;
    if (val.length >= 10) score++;
    if (/[A-Z]/.test(val) && /[a-z]/.test(val)) score++;
    if (/\d/.test(val))   score++;
    if (/[^A-Za-z0-9]/.test(val)) score++;
    var levels = [
      { pct:'0%',   color:'transparent', text:'' },
      { pct:'25%',  color:'#e74c3c',     text:'Weak' },
      { pct:'50%',  color:'#e67e22',     text:'Fair' },
      { pct:'75%',  color:'#f1c40f',     text:'Good' },
      { pct:'100%', color:'#27ae60',     text:'Strong' }
    ];
    var s = val.length === 0 ? 0 : Math.min(score, 4);
    fill.style.width      = levels[s].pct;
    fill.style.background = levels[s].color;
    label.textContent     = val.length === 0 ? '' : levels[s].text;
    label.style.color     = levels[s].color;
  }
</script>
</body>
</html>