<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>MealLog — Server Error</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --green: #3d7a5a; --green-light: #5aab7e; --green-pale: #e8f5ee;
      --cream: #faf8f3; --white: #ffffff; --ink: #1a1f1c; --muted: #6b7a72;
      --border: #d4e0d9; --shadow: 0 4px 24px rgba(30,50,38,0.10);
      --radius: 14px; --radius-sm: 8px;
      --error: #c0392b; --error-bg: #fdecea; --error-pale: #fdf0ef;
    }
    body {
      font-family: 'DM Sans', sans-serif;
      background: var(--cream);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 40px 20px;
      color: var(--ink);
    }
    .wrapper { width: 100%; max-width: 480px; text-align: center; display: flex; flex-direction: column; align-items: center; gap: 24px; }
    .brand-bar { display: flex; align-items: center; gap: 10px; justify-content: center; }
    .brand-icon { width: 38px; height: 38px; background: var(--green); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .brand-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .brand-name { font-family: 'Playfair Display', serif; font-size: 1.5rem; color: var(--ink); }
    .brand-name span { color: var(--green); }
    .card {
      background: var(--white);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      padding: 48px 40px;
      border: 1.5px solid rgba(212,224,217,0.6);
      width: 100%;
    }
    .error-code {
      font-family: 'Playfair Display', serif;
      font-size: 5rem;
      font-weight: 700;
      color: var(--error);
      line-height: 1;
      margin-bottom: 8px;
    }
    .error-icon {
      width: 64px; height: 64px;
      background: var(--error-pale);
      border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto 20px;
    }
    .error-icon svg { width: 30px; height: 30px; stroke: var(--error); fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .error-title { font-family: 'Playfair Display', serif; font-size: 1.5rem; color: var(--ink); margin-bottom: 10px; }
    .error-msg { font-size: 0.9rem; color: var(--muted); line-height: 1.6; margin-bottom: 32px; }
    .btn-group { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
    .btn-primary {
      padding: 12px 24px;
      background: var(--green); color: #fff;
      border: none; border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif; font-size: 0.92rem; font-weight: 600;
      cursor: pointer; text-decoration: none;
      transition: background 0.18s;
      display: inline-block;
    }
    .btn-primary:hover { background: var(--green-light); }
    .btn-secondary {
      padding: 12px 24px;
      background: var(--white); color: var(--green);
      border: 1.5px solid var(--green); border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif; font-size: 0.92rem; font-weight: 600;
      cursor: pointer; text-decoration: none;
      transition: background 0.18s;
      display: inline-block;
    }
    .btn-secondary:hover { background: var(--green-pale); }
    @media (max-width: 480px) { .card { padding: 32px 24px; } .error-code { font-size: 4rem; } }
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
    <div class="error-code">500</div>
    <div class="error-icon">
      <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    </div>
    <div class="error-title">Something Went Wrong</div>
    <div class="error-msg">
      An unexpected error occurred on our server.<br/>
      Please try again or return to the application.
    </div>
    <div class="btn-group">
      <a href="javascript:history.back()" class="btn-secondary">&#8592; Go Back</a>
      <a href="${pageContext.request.contextPath}/login" class="btn-primary">Go to Login</a>
    </div>
  </div>

</div>
</body>
</html>