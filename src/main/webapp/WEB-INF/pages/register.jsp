<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>MealLog — Register</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --green:        #3d7a5a;
      --green-light:  #5aab7e;
      --green-pale:   #e8f5ee;
      --green-dim:    #a8d5bc;
      --cream:        #faf8f3;
      --white:        #ffffff;
      --ink:          #1a1f1c;
      --muted:        #6b7a72;
      --border:       #d4e0d9;
      --error:        #c0392b;
      --error-bg:     #fdecea;
      --shadow:       0 4px 24px rgba(30,50,38,0.10);
      --radius:       14px;
      --radius-sm:    8px;
    }

    body {
      font-family: 'DM Sans', sans-serif;
      background: var(--cream);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 40px 20px;
      color: var(--ink);
    }

    .wrapper {
      width: 100%;
      max-width: 420px;
      display: flex;
      flex-direction: column;
      gap: 20px;
    }

    .brand-bar {
      display: flex;
      align-items: center;
      gap: 10px;
      justify-content: center;
    }
    .brand-icon {
      width: 38px; height: 38px;
      background: var(--green);
      border-radius: 10px;
      display: flex; align-items: center; justify-content: center;
    }
    .brand-icon svg {
      width: 20px; height: 20px;
      stroke: #fff; fill: none;
      stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .brand-name {
      font-family: 'Playfair Display', serif;
      font-size: 1.5rem;
      color: var(--ink);
    }
    .brand-name span { color: var(--green); }

    .card {
      background: var(--white);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      padding: 32px 32px 28px;
      border: 1px solid rgba(212,224,217,0.6);
      position: relative;
    }

    .card-deco {
      position: absolute; top: 0; right: 0;
      width: 80px; height: 80px;
      pointer-events: none; overflow: hidden;
      border-radius: 0 var(--radius) 0 0;
    }

    .card-title {
      font-family: 'Playfair Display', serif;
      font-size: 1.35rem;
      font-weight: 500;
      color: var(--ink);
      margin-bottom: 6px;
    }
    .card-subtitle {
      font-size: 0.85rem;
      color: var(--muted);
      margin-bottom: 26px;
    }

    .banner {
      border-radius: var(--radius-sm);
      padding: 11px 14px;
      font-size: 0.88rem;
      font-weight: 500;
      margin-bottom: 20px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .banner.error { background: var(--error-bg); color: var(--error); border: 1px solid #f5c6c2; }

    .field { margin-bottom: 18px; }

    label {
      display: block;
      font-size: 0.78rem;
      font-weight: 600;
      letter-spacing: 0.05em;
      text-transform: uppercase;
      color: var(--muted);
      margin-bottom: 6px;
    }

    input[type="text"],
    input[type="email"],
    input[type="password"] {
      width: 100%;
      padding: 12px 14px;
      border: 1.5px solid var(--border);
      border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif;
      font-size: 0.93rem;
      background: var(--white);
      color: var(--ink);
      outline: none;
      transition: border-color 0.18s, box-shadow 0.18s;
    }
    input:focus {
      border-color: var(--green);
      box-shadow: 0 0 0 3px rgba(61,122,90,0.10);
    }
    input.invalid {
      border-color: var(--error);
      box-shadow: 0 0 0 3px rgba(192,57,43,0.08);
    }

    .err {
      color: var(--error);
      font-size: 0.76rem;
      margin-top: 5px;
      display: flex;
      align-items: center;
      gap: 4px;
    }
    .err::before { content: '⚠'; font-size: 0.7rem; }

    .field-hint {
      font-size: 0.74rem;
      color: var(--muted);
      margin-top: 5px;
    }

    .pass-wrap { position: relative; }
    .pass-wrap input { padding-right: 44px; }
    .toggle-pass {
      position: absolute;
      right: 12px; top: 50%;
      transform: translateY(-50%);
      background: none; border: none;
      cursor: pointer; padding: 4px;
      color: var(--muted);
      display: flex; align-items: center;
    }
    .toggle-pass:hover { color: var(--green); }
    .toggle-pass svg {
      width: 18px; height: 18px;
      stroke: currentColor; fill: none;
      stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
      pointer-events: none;
    }

    .btn-primary {
      width: 100%;
      padding: 13px;
      background: var(--green);
      color: #fff;
      border: none;
      border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif;
      font-size: 0.95rem;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.18s, transform 0.1s;
      letter-spacing: 0.02em;
      margin-top: 4px;
    }
    .btn-primary:hover  { background: var(--green-light); }
    .btn-primary:active { transform: scale(0.99); }

    .divider {
      display: flex;
      align-items: center;
      gap: 10px;
      margin: 22px 0 18px;
    }
    .divider::before,
    .divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }
    .divider span { color: var(--muted); font-size: 0.78rem; white-space: nowrap; }

    .footer-link {
      text-align: center;
      font-size: 0.84rem;
      color: var(--muted);
    }
    .footer-link a {
      color: var(--green);
      text-decoration: none;
      font-weight: 600;
    }
    .footer-link a:hover { text-decoration: underline; }

    @media (max-width: 480px) {
      .card { padding: 24px 20px 22px; }
    }
  </style>
</head>
<body>

<div class="wrapper">

  <!-- Brand -->
  <div class="brand-bar">
    <div class="brand-icon">
      <svg viewBox="0 0 24 24"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg>
    </div>
    <div class="brand-name">Meal<span>Log</span></div>
  </div>

  <!-- Card -->
  <div class="card">

    <div class="card-deco">
      <svg viewBox="0 0 80 80" xmlns="http://www.w3.org/2000/svg">
        <circle cx="60" cy="20" r="28" fill="none" stroke="#e8f5ee" stroke-width="20"/>
      </svg>
    </div>

    <div class="card-title">Create an account</div>
    <div class="card-subtitle">Start logging your meals today</div>

    <%-- General error banner --%>
    <% if (request.getAttribute("generalErr") != null) { %>
      <div class="banner error">&#9888; <%= request.getAttribute("generalErr") %></div>
    <% } %>

    <form action="register" method="post" id="registerForm">

      <!-- Full Name -->
      <div class="field">
        <label for="name">Full Name</label>
        <input
          type="text"
          id="name"
          name="name"
          placeholder="Jane Doe"
          value="<%= request.getAttribute("name") != null ? request.getAttribute("name") : "" %>"
          class="<%= request.getAttribute("nameErr") != null ? "invalid" : "" %>"
          autofocus
          oninput="blockNumbers(this)"
        />
        <div class="field-hint">Letters and spaces only — no numbers.</div>
        <% if (request.getAttribute("nameErr") != null) { %>
          <div class="err"><%= request.getAttribute("nameErr") %></div>
        <% } %>
      </div>

      <!-- Email -->
      <div class="field">
        <label for="email">Email Address</label>
        <input
          type="email"
          id="email"
          name="email"
          placeholder="you@example.com"
          value="<%= request.getAttribute("email") != null ? request.getAttribute("email") : "" %>"
          class="<%= request.getAttribute("emailErr") != null ? "invalid" : "" %>"
          autocomplete="email"
        />
        <% if (request.getAttribute("emailErr") != null) { %>
          <div class="err"><%= request.getAttribute("emailErr") %></div>
        <% } %>
      </div>

      <!-- Password -->
      <div class="field">
        <label for="password">Password</label>
        <div class="pass-wrap">
          <input
            type="password"
            id="password"
            name="password"
            placeholder="At least 6 characters"
            class="<%= request.getAttribute("passErr") != null ? "invalid" : "" %>"
            autocomplete="new-password"
          />
          <button type="button" class="toggle-pass" onclick="togglePass('password','eye1')" aria-label="Show/hide password">
            <svg id="eye1" viewBox="0 0 24 24">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
              <circle cx="12" cy="12" r="3"/>
            </svg>
          </button>
        </div>
        <% if (request.getAttribute("passErr") != null) { %>
          <div class="err"><%= request.getAttribute("passErr") %></div>
        <% } %>
      </div>

      <!-- Confirm Password -->
      <div class="field">
        <label for="confirm">Confirm Password</label>
        <div class="pass-wrap">
          <input
            type="password"
            id="confirm"
            name="confirm"
            placeholder="Repeat your password"
            class="<%= request.getAttribute("confirmErr") != null ? "invalid" : "" %>"
            autocomplete="new-password"
          />
          <button type="button" class="toggle-pass" onclick="togglePass('confirm','eye2')" aria-label="Show/hide password">
            <svg id="eye2" viewBox="0 0 24 24">
              <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
              <circle cx="12" cy="12" r="3"/>
            </svg>
          </button>
        </div>
        <% if (request.getAttribute("confirmErr") != null) { %>
          <div class="err"><%= request.getAttribute("confirmErr") %></div>
        <% } %>
      </div>

      <button type="submit" class="btn-primary">Create Account</button>
    </form>

    <div class="divider"><span>already have an account?</span></div>
    <div class="footer-link"><a href="login">Sign in instead</a></div>

  </div>
</div>

<script>
  // ── Block numbers and special characters from name field in real time ──
  function blockNumbers(input) {
    // Remove anything that is not a letter or space as the user types
    var pos = input.selectionStart;
    var cleaned = input.value.replace(/[^a-zA-Z\s]/g, '');
    if (cleaned !== input.value) {
      input.value = cleaned;
      // Restore cursor position
      input.setSelectionRange(pos - 1, pos - 1);
    }
  }

  // Also block on keydown so numbers never even appear
  document.getElementById('name').addEventListener('keydown', function(e) {
    // Allow: backspace, delete, tab, escape, enter, arrows, home, end
    var allowed = [8, 9, 13, 27, 35, 36, 37, 38, 39, 40, 46];
    if (allowed.indexOf(e.keyCode) !== -1) return;
    // Allow Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
    if (e.ctrlKey || e.metaKey) return;
    // Block digits
    if (e.key >= '0' && e.key <= '9') {
      e.preventDefault();
      return;
    }
    // Block special characters — only allow letters and space
    if (!/^[a-zA-Z\s]$/.test(e.key)) {
      e.preventDefault();
    }
  });

  // Handle paste — strip numbers and special characters from pasted text
  document.getElementById('name').addEventListener('paste', function(e) {
    e.preventDefault();
    var pasted = (e.clipboardData || window.clipboardData).getData('text');
    var cleaned = pasted.replace(/[^a-zA-Z\s]/g, '');
    document.execCommand('insertText', false, cleaned);
  });

  // ── Show/hide password toggle ──
  function togglePass(inputId, iconId) {
    var input = document.getElementById(inputId);
    var icon  = document.getElementById(iconId);
    if (input.type === 'password') {
      input.type = 'text';
      icon.innerHTML =
        '<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>' +
        '<path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>' +
        '<line x1="1" y1="1" x2="23" y2="23"/>';
    } else {
      input.type = 'password';
      icon.innerHTML =
        '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>' +
        '<circle cx="12" cy="12" r="3"/>';
    }
  }
</script>

</body>
</html>