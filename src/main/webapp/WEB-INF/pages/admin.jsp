<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.ArrayList"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>MealLog — Admin</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
  <style>
    :root {
      --admin:      #2c3e7a;
      --admin-pale: #eef0fa;
      --admin-dim:  #b0bae8;
      --shadow-lg:  0 8px 40px rgba(30,50,38,0.16);
    }

    body { background: var(--cream); min-height: 100vh; color: var(--ink); }

    .navbar {
      background: var(--white); border-bottom: 1px solid var(--border);
      padding: 0 40px; height: 64px; display: flex; align-items: center;
      justify-content: space-between; position: sticky; top: 0; z-index: 200;
      box-shadow: 0 2px 12px rgba(30,50,38,0.07);
    }
    .brand-bar { display: flex; align-items: center; gap: 10px; }
    .brand-icon { width: 36px; height: 36px; background: var(--admin); border-radius: 9px; display: flex; align-items: center; justify-content: center; }
    .brand-icon svg { width: 18px; height: 18px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .brand-name { font-family: 'Playfair Display', serif; font-size: 1.3rem; color: var(--ink); }
    .brand-name span { color: var(--admin); }
    .admin-badge { background: var(--admin-pale); color: var(--admin); font-size: 0.72rem; font-weight: 600; padding: 4px 10px; border-radius: 20px; border: 1px solid var(--admin-dim); letter-spacing: 0.05em; text-transform: uppercase; }
    .btn-logout { padding: 7px 16px; background: none; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.82rem; font-weight: 600; color: var(--muted); cursor: pointer; transition: border-color 0.18s, color 0.18s; }
    .btn-logout:hover { border-color: var(--error); color: var(--error); }

    .page-body { padding: 32px 40px; max-width: 1600px; margin: 0 auto; }
    .page-title    { font-family: 'Playfair Display', serif; font-size: 1.7rem; font-weight: 500; margin-bottom: 4px; }
    .page-subtitle { font-size: 0.88rem; color: var(--muted); margin-bottom: 28px; }

    /* ── Page tabs ── */
    .page-tabs { display: flex; gap: 4px; margin-bottom: 28px; background: #ece9e2; border-radius: var(--radius-sm); padding: 4px; width: fit-content; }
    .page-tab  { padding: 9px 22px; background: none; border: none; font-family: 'DM Sans', sans-serif; font-size: 0.88rem; font-weight: 500; color: var(--muted); border-radius: 6px; cursor: pointer; transition: background 0.18s, color 0.18s; }
    .page-tab.active { background: var(--white); color: var(--admin); font-weight: 600; box-shadow: 0 1px 6px rgba(44,62,122,0.12); }

    .tab-section { display: none; }
    .tab-section.active { display: block; }

    /* ── Stat cards ── */
    .stat-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(180px,1fr)); gap: 16px; margin-bottom: 32px; }
    .stat-card { background: var(--white); border-radius: var(--radius); border: 1px solid rgba(212,224,217,0.6); padding: 20px 22px; box-shadow: var(--shadow); transition: transform 0.15s, box-shadow 0.15s; }
    .stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
    .stat-card .s-label { font-size: 0.71rem; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); margin-bottom: 10px; }
    .stat-card .s-value { font-size: 1.9rem; font-weight: 700; color: var(--admin); line-height: 1; }
    .stat-card .s-unit  { font-size: 0.74rem; color: var(--muted); margin-top: 5px; }

    /* ── Charts ── */
    .charts-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 18px; flex-wrap: wrap; gap: 10px; }
    .section-title { font-family: 'Playfair Display', serif; font-size: 1.2rem; font-weight: 500; flex: 1; }
    .period-toggle { display: flex; background: #ece9e2; border-radius: 8px; padding: 3px; gap: 3px; }
    .period-btn { padding: 6px 16px; background: none; border: none; font-family: 'DM Sans', sans-serif; font-size: 0.8rem; font-weight: 500; color: var(--muted); border-radius: 6px; cursor: pointer; transition: background 0.18s, color 0.18s; }
    .period-btn.active { background: var(--white); color: var(--admin); font-weight: 600; box-shadow: 0 1px 6px rgba(44,62,122,0.12); }
    .charts-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; margin-bottom: 32px; }
    .chart-card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); border: 1px solid rgba(212,224,217,0.6); padding: 20px 22px; }
    .chart-title  { font-size: 0.82rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--muted); margin-bottom: 14px; }
    .chart-canvas { width: 100% !important; height: 200px !important; }

    /* ── Cards ── */
    .card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); border: 1px solid rgba(212,224,217,0.6); overflow: hidden; margin-bottom: 24px; }
    .card-header { padding: 16px 22px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px; }
    .card-header h2 { font-family: 'Playfair Display', serif; font-size: 1.1rem; font-weight: 500; }
    .count-badge { background: var(--admin-pale); color: var(--admin); font-size: 0.74rem; font-weight: 600; padding: 3px 10px; border-radius: 20px; border: 1px solid var(--admin-dim); }
    .card-body { padding: 22px; }

    /* ── Form fields ── */
    .field { margin-bottom: 14px; }
    .field label { display: block; font-size: 0.74rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; color: var(--muted); margin-bottom: 5px; }
    .add-food-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
    .macro-inputs  { display: grid; grid-template-columns: repeat(4,1fr); gap: 10px; margin-bottom: 16px; }

    /* ── Table toolbar ── */
    .table-toolbar { display: flex; align-items: center; gap: 10px; padding: 12px 22px; border-bottom: 1px solid var(--border); flex-wrap: wrap; }
    .search-input { flex: 1; min-width: 160px; padding: 8px 12px; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.86rem; outline: none; transition: border-color 0.18s; width: auto; }
    .search-input:focus { border-color: var(--admin); }
    .cat-filter { padding: 8px 28px 8px 12px; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.86rem; outline: none; background: var(--white); width: auto; appearance: none; background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%236b7a72' stroke-width='2.5'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 10px center; transition: border-color 0.18s; }
    .cat-filter:focus { border-color: var(--admin); }
    .btn-clear { padding: 8px 12px; background: none; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.82rem; font-weight: 600; color: var(--muted); cursor: pointer; transition: border-color 0.18s, color 0.18s; }
    .btn-clear:hover { border-color: var(--admin); color: var(--admin); }

    /* ── Tables ── */
    .table-wrap { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
    thead th { background: var(--admin); color: #fff; padding: 11px 14px; text-align: left; font-size: 0.71rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; white-space: nowrap; }
    tbody td { padding: 11px 14px; border-bottom: 1px solid #f0f4f2; color: var(--ink); vertical-align: middle; white-space: nowrap; }
    tbody tr:last-child td { border-bottom: none; }
    tbody tr:nth-child(even) td { background: #f9fbfa; }
    tbody tr:hover td { background: var(--admin-pale); transition: background 0.15s; }
    tbody .edit-row td { background: #fffdf5 !important; }

    .btn-edit   { padding: 4px 10px; font-size: 0.74rem; font-weight: 600; border: none; border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: #fff3e0; color: #e65100; margin-right: 5px; transition: opacity 0.15s; }
    .btn-del    { padding: 4px 10px; font-size: 0.74rem; font-weight: 600; border: none; border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: #fce4ec; color: #c62828; transition: opacity 0.15s; }
    .btn-expand { padding: 4px 10px; font-size: 0.74rem; font-weight: 600; border: 1px solid var(--admin-dim); border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: var(--admin-pale); color: var(--admin); margin-right: 5px; transition: opacity 0.15s; }
    .btn-edit:hover, .btn-del:hover, .btn-expand:hover { opacity: 0.7; }

    .edit-row input, .edit-row select {
      width: 100%; padding: 5px 8px; font-size: 0.8rem;
      border: 1.5px solid var(--admin-dim); border-radius: 6px;
      font-family: 'DM Sans', sans-serif; outline: none; min-width: 80px; appearance: none;
    }
    .edit-row input:focus, .edit-row select:focus { border-color: var(--admin); }
    .btn-save   { padding: 4px 10px; font-size: 0.74rem; font-weight: 600; border: 1px solid var(--admin-dim); border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: var(--admin-pale); color: var(--admin); margin-right: 4px; }
    .btn-cancel { padding: 4px 10px; font-size: 0.74rem; font-weight: 600; border: 1px solid #ddd; border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: #f0f0f0; color: #555; }
    .btn-save:hover   { background: #d8dcf5; }
    .btn-cancel:hover { background: #e0e0e0; }

    /* ── Expandable meal rows ── */
    .meals-expand-row td { padding: 0 !important; border-bottom: 2px solid var(--admin-dim) !important; background: var(--admin-pale) !important; }
    .meals-expand-inner  { padding: 16px 20px; }
    .meals-expand-title  { font-size: 0.76rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--admin); margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }
    .meals-sub-table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
    .meals-sub-table thead th { background: var(--admin); color: #fff; padding: 8px 12px; font-size: 0.69rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; }
    .meals-sub-table tbody td { padding: 8px 12px; border-bottom: 1px solid #e8ecf8; }
    .meals-sub-table tbody tr:last-child td { border-bottom: none; }
    .meals-sub-table tbody tr:hover td { background: #dde2f5; }

    .meal-type-badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 0.69rem; font-weight: 600; text-transform: capitalize; }
    .badge-breakfast { background: #fff8e1; color: #f57f17; }
    .badge-lunch     { background: #e8f5e9; color: #2e7d32; }
    .badge-dinner    { background: #ede7f6; color: #4527a0; }
    .badge-snack     { background: #fce4ec; color: #880e4f; }
    .badge-other     { background: #f5f5f5; color: #555; }

    /* ── Category badges ── */
    .cat-badge    { display: inline-block; padding: 3px 9px; border-radius: 12px; font-size: 0.71rem; font-weight: 600; }
    .cat-carbs    { background: #fff8e1; color: #f57f17; }
    .cat-proteins { background: #fce4ec; color: #c62828; }
    .cat-veg      { background: #e8f5e9; color: #2e7d32; }
    .cat-fruits   { background: #f3e5f5; color: #6a1b9a; }
    .cat-dairy    { background: #e3f2fd; color: #1565c0; }
    .cat-other    { background: #f5f5f5; color: #555; }

    /* ── Add food button ── */
    .btn-add-food-submit {
      padding: 12px 28px; background: var(--admin); color: #fff; border: none;
      border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif;
      font-size: 0.93rem; font-weight: 600; cursor: pointer;
      transition: background 0.18s; margin-top: 6px;
    }
    .btn-add-food-submit:hover { background: #3d54a8; }

    .no-data { text-align: center; color: var(--muted); padding: 50px 0; font-size: 0.92rem; }
    .no-data svg { width: 36px; height: 36px; stroke: var(--border); fill: none; stroke-width: 1.5; display: block; margin: 0 auto 10px; }

    .hidden-form { display: none; }

    @media (max-width: 1100px) { .charts-grid { grid-template-columns: 1fr 1fr; } }
    @media (max-width: 700px)  { .charts-grid { grid-template-columns: 1fr; } .navbar { padding: 0 16px; } .page-body { padding: 20px 16px; } .add-food-grid { grid-template-columns: 1fr; } .macro-inputs { grid-template-columns: 1fr 1fr; } }
  </style>
</head>
<body>

<%
  List<String[]>              users           = (List<String[]>)              request.getAttribute("users");
  Map<String, List<String[]>> mealsByUser     = (Map<String, List<String[]>>) request.getAttribute("mealsByUser");
  List<String[]>              foods           = (List<String[]>)              request.getAttribute("foods");
  List<String[]>              regPerDay       = (List<String[]>)              request.getAttribute("regPerDay");
  List<String[]>              regPerMonth     = (List<String[]>)              request.getAttribute("regPerMonth");
  List<String[]>              mealsPerDay     = (List<String[]>)              request.getAttribute("mealsPerDay");
  List<String[]>              mealsPerMonth   = (List<String[]>)              request.getAttribute("mealsPerMonth");
  List<String[]>              mealTypeDistrib = (List<String[]>)              request.getAttribute("mealTypeDistrib");

  int userCount  = (users != null) ? users.size() : 0;
  int foodCount  = (foods != null) ? foods.size() : 0;
  int totalMeals = 0;
  if (mealsByUser != null) for (List<String[]> ml : mealsByUser.values()) totalMeals += ml.size();

  String openTab = (String) request.getAttribute("openTab");
  if (openTab == null) openTab = "analytics";

  // Build chart JS arrays
  StringBuilder regDayLabels=new StringBuilder(),   regDayData=new StringBuilder();
  StringBuilder regMonthLabels=new StringBuilder(), regMonthData=new StringBuilder();
  StringBuilder mDayLabels=new StringBuilder(),     mDayData=new StringBuilder();
  StringBuilder mMonthLabels=new StringBuilder(),   mMonthData=new StringBuilder();
  StringBuilder distLabels=new StringBuilder(),     distData=new StringBuilder();

  if (regPerDay     != null) for (int i=0;i<regPerDay.size();i++)     { regDayLabels.append("'").append(regPerDay.get(i)[0]).append("'").append(i<regPerDay.size()-1?",":""); regDayData.append(regPerDay.get(i)[1]).append(i<regPerDay.size()-1?",":""); }
  if (regPerMonth   != null) for (int i=0;i<regPerMonth.size();i++)   { regMonthLabels.append("'").append(regPerMonth.get(i)[0]).append("'").append(i<regPerMonth.size()-1?",":""); regMonthData.append(regPerMonth.get(i)[1]).append(i<regPerMonth.size()-1?",":""); }
  if (mealsPerDay   != null) for (int i=0;i<mealsPerDay.size();i++)   { mDayLabels.append("'").append(mealsPerDay.get(i)[0]).append("'").append(i<mealsPerDay.size()-1?",":""); mDayData.append(mealsPerDay.get(i)[1]).append(i<mealsPerDay.size()-1?",":""); }
  if (mealsPerMonth != null) for (int i=0;i<mealsPerMonth.size();i++) { mMonthLabels.append("'").append(mealsPerMonth.get(i)[0]).append("'").append(i<mealsPerMonth.size()-1?",":""); mMonthData.append(mealsPerMonth.get(i)[1]).append(i<mealsPerMonth.size()-1?",":""); }
  if (mealTypeDistrib != null) for (int i=0;i<mealTypeDistrib.size();i++) { distLabels.append("'").append(mealTypeDistrib.get(i)[0]).append("'").append(i<mealTypeDistrib.size()-1?",":""); distData.append(mealTypeDistrib.get(i)[1]).append(i<mealTypeDistrib.size()-1?",":""); }
%>

<!-- Hidden forms -->
<form class="hidden-form" id="del-user-form" action="admin" method="post">
  <input type="hidden" name="action" value="delete"/>
  <input type="hidden" name="id"     id="del-user-id"/>
</form>
<%-- BUG FIX #3: was name="full_name" — controller reads getParameter("fullName").
     Changed to name="fullName" so the parameter actually arrives. --%>
<form class="hidden-form" id="upd-user-form" action="admin" method="post">
  <input type="hidden" name="action"   value="update"/>
  <input type="hidden" name="id"       id="upd-user-id"/>
  <input type="hidden" name="fullName" id="upd-user-name"/>
  <input type="hidden" name="email"    id="upd-user-email"/>
</form>
<form class="hidden-form" id="del-food-form" action="admin" method="post">
  <input type="hidden" name="action" value="delete_food"/>
  <input type="hidden" name="id"     id="del-food-id"/>
</form>
<form class="hidden-form" id="upd-food-form" action="admin" method="post">
  <input type="hidden" name="action"            value="update_food"/>
  <input type="hidden" name="id"                id="upd-food-id"/>
  <input type="hidden" name="foodName"           id="upd-food-name"/>
  <input type="hidden" name="category"          id="upd-food-cat"/>
  <input type="hidden" name="calories_per_100g" id="upd-food-cal"/>
  <input type="hidden" name="protein_per_100g"  id="upd-food-pro"/>
  <input type="hidden" name="carbs_per_100g"    id="upd-food-carb"/>
  <input type="hidden" name="fats_per_100g"     id="upd-food-fat"/>
</form>
<form class="hidden-form" id="logout-form" action="admin" method="post">
  <input type="hidden" name="action" value="logout"/>
</form>

<!-- Navbar -->
<nav class="navbar">
  <div class="brand-bar">
    <div class="brand-icon"><svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg></div>
    <div class="brand-name">Meal<span>Log</span></div>
  </div>
  <div style="display:flex;align-items:center;gap:12px;">
    <span class="admin-badge">Admin Panel</span>
    <button class="btn-logout" onclick="document.getElementById('logout-form').submit()">Sign Out</button>
  </div>
</nav>

<div class="page-body">

  <div class="page-title">Admin Dashboard</div>
  <div class="page-subtitle">Manage users, meals, food database and platform analytics</div>

  <!-- Global banners -->
  <% if (request.getAttribute("successMsg") != null) { %>
    <div class="banner success" style="margin-bottom:20px;">&#10003; <%= request.getAttribute("successMsg") %></div>
  <% } %>
  <% if (request.getAttribute("errorMsg") != null) { %>
    <div class="banner error" style="margin-bottom:20px;">&#9888; <%= request.getAttribute("errorMsg") %></div>
  <% } %>

  <!-- Page tabs -->
  <div class="page-tabs">
    <button class="page-tab" id="tab-btn-analytics" onclick="switchPageTab('analytics')">&#128200; Analytics</button>
    <button class="page-tab" id="tab-btn-users"     onclick="switchPageTab('users')">&#128101; Users</button>
    <button class="page-tab" id="tab-btn-foods"     onclick="switchPageTab('foods')">&#127869; Food Database</button>
  </div>

  <!-- ══ ANALYTICS ══ -->
  <div class="tab-section" id="tab-analytics">
    <div class="stat-grid">
      <div class="stat-card"><div class="s-label">Total Users</div>  <div class="s-value"><%= userCount %></div>  <div class="s-unit">registered</div></div>
      <div class="stat-card"><div class="s-label">Total Meals</div>  <div class="s-value"><%= totalMeals %></div> <div class="s-unit">logged across all users</div></div>
      <div class="stat-card"><div class="s-label">Avg Meals</div>    <div class="s-value"><%= userCount>0?String.format("%.1f",(double)totalMeals/userCount):"0" %></div><div class="s-unit">per user</div></div>
      <div class="stat-card"><div class="s-label">Food Items</div>   <div class="s-value"><%= foodCount %></div>  <div class="s-unit">in database</div></div>
      <div class="stat-card"><div class="s-label">New Today</div>    <div class="s-value" id="stat-new-today">—</div><div class="s-unit">registrations</div></div>
    </div>
    <div class="charts-header">
      <div class="section-title">Analytics</div>
      <div class="period-toggle">
        <button class="period-btn active" id="btn-30"  onclick="setPeriod('30')">Last 30 Days</button>
        <button class="period-btn"        id="btn-all" onclick="setPeriod('all')">All Time</button>
      </div>
    </div>
    <div class="charts-grid">
      <div class="chart-card"><div class="chart-title">User Registrations</div>   <canvas id="regChart"   class="chart-canvas"></canvas></div>
      <div class="chart-card"><div class="chart-title">Meals Logged</div>          <canvas id="mealsChart" class="chart-canvas"></canvas></div>
      <div class="chart-card"><div class="chart-title">Meal Type Distribution</div><canvas id="typeChart"  class="chart-canvas"></canvas></div>
    </div>
  </div>

  <!-- ══ USERS ══ -->
  <div class="tab-section" id="tab-users">
    <div class="card">
      <div class="card-header">
        <h2>All Users</h2>
        <span class="count-badge"><%= userCount %> user<%= userCount!=1?"s":"" %></span>
      </div>
      <div class="table-toolbar">
        <input type="text" class="search-input" id="user-search" placeholder="&#128269; Search by name or email..." oninput="filterUsers()"/>
      </div>
      <% if (users==null||users.isEmpty()) { %>
        <div class="no-data"><svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>No users found.</div>
      <% } else { %>
        <div class="table-wrap">
          <table id="users-table">
            <thead><tr><th>ID</th><th>Full Name</th><th>Email</th><th>Registered</th><th>Meals</th><th>Actions</th></tr></thead>
            <tbody>
              <%
                for (String[] u : users) {
                  List<String[]> uMeals = new ArrayList<String[]>();
                  if (mealsByUser!=null&&mealsByUser.containsKey(u[0])) uMeals=mealsByUser.get(u[0]);
                  int uMealCount=uMeals.size();

                  // FIX #2: null-safe date handling — u[3] (created_at) can be null from DB
                  String createdAt = (u[3] != null && u[3].length() >= 10) ? u[3].substring(0,10) : "—";

                  // Escape name for use in JS onclick attributes
                  String escapedName = (u[1] != null) ? u[1].replace("\\","\\\\").replace("'","\\'") : "";
              %>
              <tr id="urow-<%= u[0] %>" data-name="<%= (u[1]!=null?u[1]:"").toLowerCase() %>" data-email="<%= (u[2]!=null?u[2]:"").toLowerCase() %>">
                <td><strong>#<%= u[0] %></strong></td>
                <td><%= u[1] != null ? u[1] : "—" %></td>
                <td><%= u[2] != null ? u[2] : "—" %></td>
                <td><%= createdAt %></td>
                <td><span class="count-badge"><%= uMealCount %></span></td>
                <td>
                  <button class="btn-expand" onclick="toggleMeals('<%= u[0] %>')">&#9660; Meals</button>
                  <button class="btn-edit"   onclick="startUserEdit('<%= u[0] %>')">&#9998; Edit</button>
                  <button class="btn-del"    onclick="deleteUser('<%= u[0] %>','<%= escapedName %>')">&#128465;</button>
                </td>
              </tr>
              <tr class="edit-row" id="uedit-<%= u[0] %>" style="display:none;">
                <td><strong>#<%= u[0] %></strong></td>
                <td><input type="text"  id="uer-name-<%= u[0] %>"  value="<%= u[1] != null ? u[1] : "" %>"/></td>
                <td><input type="email" id="uer-email-<%= u[0] %>" value="<%= u[2] != null ? u[2] : "" %>"/></td>
                <td><%= createdAt %></td>
                <td><span class="count-badge"><%= uMealCount %></span></td>
                <td>
                  <button class="btn-save"   onclick="saveUserEdit('<%= u[0] %>')">&#10003; Save</button>
                  <button class="btn-cancel" onclick="cancelUserEdit('<%= u[0] %>')">&#10005; Cancel</button>
                </td>
              </tr>
              <tr class="meals-expand-row" id="umealrow-<%= u[0] %>" style="display:none;">
                <td colspan="6">
                  <div class="meals-expand-inner">
                    <div class="meals-expand-title">&#127374; Meals by <%= u[1] != null ? u[1] : "—" %> <span class="count-badge" style="text-transform:none;letter-spacing:0;"><%= uMealCount %> meal<%= uMealCount!=1?"s":"" %></span></div>
                    <% if (uMeals.isEmpty()) { %><div style="color:var(--muted);font-style:italic;font-size:0.84rem;padding:8px 0;">No meals logged yet.</div>
                    <% } else { %>
                      <table class="meals-sub-table">
                        <thead><tr><th>ID</th><th>Type</th><th>Meal</th><th>Kcal</th><th>Protein</th><th>Carbs</th><th>Fats</th><th>Date</th></tr></thead>
                        <tbody>
                          <% for (String[] ml:uMeals) {
                               // FIX #2: null-safe meal_type — ml[3] can be null
                               String mealType = (ml[3] != null) ? ml[3] : "";
                               String tl = mealType.toLowerCase();
                               String bc = "badge-other";
                               if(tl.equals("breakfast"))      bc="badge-breakfast";
                               else if(tl.equals("lunch"))     bc="badge-lunch";
                               else if(tl.equals("dinner"))    bc="badge-dinner";
                               else if(tl.equals("snack"))     bc="badge-snack";

                               // FIX #2: null-safe meal_date — ml[9] can be null
                               String mealDate = (ml[9] != null && !ml[9].isEmpty()) ? ml[9] : "—";
                          %>
                          <tr>
                            <td>#<%= ml[0] %></td>
                            <td><span class="meal-type-badge <%= bc %>"><%= mealType.isEmpty() ? "—" : mealType %></span></td>
                            <td><%= ml[4] != null ? ml[4] : "—" %></td>
                            <td><%= ml[5] != null ? ml[5] : "—" %></td>
                            <td><%= ml[6] != null ? ml[6] : "—" %>g</td>
                            <td><%= ml[7] != null ? ml[7] : "—" %>g</td>
                            <td><%= ml[8] != null ? ml[8] : "—" %>g</td>
                            <td><%= mealDate %></td>
                          </tr>
                          <% } %>
                        </tbody>
                      </table>
                    <% } %>
                  </div>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      <% } %>
    </div>
  </div>

  <!-- ══ FOOD DATABASE ══ -->
  <div class="tab-section" id="tab-foods">

    <!-- Food banners — shown only in this tab -->
    <% if (request.getAttribute("foodSuccess") != null) { %>
      <div class="banner success" style="margin-bottom:20px;">&#10003; <%= request.getAttribute("foodSuccess") %></div>
    <% } %>
    <% if (request.getAttribute("foodErr") != null) { %>
      <div class="banner error" style="margin-bottom:20px;">&#9888; <%= request.getAttribute("foodErr") %></div>
    <% } %>

    <!-- Add food form -->
    <div class="card" style="margin-bottom:24px;">
      <div class="card-header"><h2>&#10133; Add New Food Item</h2></div>
      <div class="card-body">
        <form action="admin" method="post" id="addFoodForm">
          <input type="hidden" name="action" value="create_food"/>

          <div class="add-food-grid">
            <div class="field">
              <label for="new-food-name">Food Name *</label>
              <input type="text" id="new-food-name" name="foodName" placeholder="e.g. Brown Rice" autocomplete="off"/>
            </div>
            <div class="field">
              <label for="new-food-cat">Category *</label>
              <select id="new-food-cat" name="category">
                <option value="">— Select category —</option>
                <option value="Carbs &amp; Grains">Carbs &amp; Grains</option>
                <option value="Proteins &amp; Meat">Proteins &amp; Meat</option>
                <option value="Vegetables">Vegetables</option>
                <option value="Fruits">Fruits</option>
                <option value="Dairy">Dairy</option>
                <option value="Other">Other</option>
              </select>
            </div>
          </div>

          <label style="display:block;font-size:0.74rem;font-weight:700;letter-spacing:0.05em;text-transform:uppercase;color:var(--muted);margin-bottom:10px;">
            Macros per 100g
          </label>
          <div class="macro-inputs">
            <div class="field" style="margin-bottom:0;">
              <label for="new-cal">Calories (kcal)</label>
              <input type="number" id="new-cal"  name="calories_per_100g" placeholder="e.g. 130" min="0" step="0.01"/>
            </div>
            <div class="field" style="margin-bottom:0;">
              <label for="new-pro">Protein (g)</label>
              <input type="number" id="new-pro"  name="protein_per_100g"  placeholder="e.g. 2.7"  min="0" step="0.01"/>
            </div>
            <div class="field" style="margin-bottom:0;">
              <label for="new-carb">Carbs (g)</label>
              <input type="number" id="new-carb" name="carbs_per_100g"    placeholder="e.g. 28.0" min="0" step="0.01"/>
            </div>
            <div class="field" style="margin-bottom:0;">
              <label for="new-fat">Fats (g)</label>
              <input type="number" id="new-fat"  name="fats_per_100g"     placeholder="e.g. 0.3"  min="0" step="0.01"/>
            </div>
          </div>

          <button type="submit" class="btn-add-food-submit">&#10133; Add to Database</button>
        </form>
      </div>
    </div>

    <!-- Foods table -->
    <div class="card">
      <div class="card-header">
        <h2>All Food Items</h2>
        <span class="count-badge"><%= foodCount %> item<%= foodCount!=1?"s":"" %></span>
      </div>
      <div class="table-toolbar">
        <input type="text" class="search-input" id="food-search" placeholder="&#128269; Search food items..." oninput="filterFoods()"/>
        <select class="cat-filter" id="food-cat-filter" onchange="filterFoods()">
          <option value="">All Categories</option>
          <option value="Carbs &amp; Grains">Carbs &amp; Grains</option>
          <option value="Proteins &amp; Meat">Proteins &amp; Meat</option>
          <option value="Vegetables">Vegetables</option>
          <option value="Fruits">Fruits</option>
          <option value="Dairy">Dairy</option>
          <option value="Other">Other</option>
        </select>
        <button class="btn-clear" onclick="clearFoodFilters()">Clear</button>
      </div>

      <% if (foods==null||foods.isEmpty()) { %>
        <div class="no-data"><svg viewBox="0 0 24 24"><path d="M3 3h18v18H3z" stroke-dasharray="4 2"/><path d="M12 8v4M12 16h.01"/></svg>No food items yet. Add one above.</div>
      <% } else { %>
        <div class="table-wrap">
          <table id="foods-table">
            <thead>
              <tr><th>ID</th><th>Food Name</th><th>Category</th><th>Cal/100g</th><th>Protein/100g</th><th>Carbs/100g</th><th>Fats/100g</th><th>Actions</th></tr>
            </thead>
            <tbody>
              <% for (String[] f : foods) {
                   String cat = (f[2] != null) ? f[2] : "";
                   String catCls = "cat-other";
                   if(cat.equals("Carbs & Grains"))      catCls="cat-carbs";
                   else if(cat.equals("Proteins & Meat")) catCls="cat-proteins";
                   else if(cat.equals("Vegetables"))      catCls="cat-veg";
                   else if(cat.equals("Fruits"))          catCls="cat-fruits";
                   else if(cat.equals("Dairy"))           catCls="cat-dairy";

                   String escapedFoodName = (f[1] != null) ? f[1].replace("\\","\\\\").replace("'","\\'") : "";
              %>
              <tr id="frow-<%= f[0] %>" data-name="<%= (f[1]!=null?f[1]:"").toLowerCase() %>" data-cat="<%= cat %>">
                <td><strong>#<%= f[0] %></strong></td>
                <td><strong><%= f[1] != null ? f[1] : "—" %></strong></td>
                <td><span class="cat-badge <%= catCls %>"><%= cat.isEmpty() ? "—" : cat %></span></td>
                <td><%= f[3] != null ? f[3] : "—" %> kcal</td>
                <td><%= f[4] != null ? f[4] : "—" %>g</td>
                <td><%= f[5] != null ? f[5] : "—" %>g</td>
                <td><%= f[6] != null ? f[6] : "—" %>g</td>
                <td>
                  <button class="btn-edit" onclick="startFoodEdit('<%= f[0] %>')">&#9998; Edit</button>
                  <button class="btn-del"  onclick="deleteFood('<%= f[0] %>','<%= escapedFoodName %>')">&#128465;</button>
                </td>
              </tr>
              <tr class="edit-row" id="fedit-<%= f[0] %>" style="display:none;">
                <td><strong>#<%= f[0] %></strong></td>
                <td><input type="text" id="fer-name-<%= f[0] %>" value="<%= f[1] != null ? f[1] : "" %>"/></td>
                <td>
                  <select id="fer-cat-<%= f[0] %>">
                    <option value="Carbs &amp; Grains"  <%= cat.equals("Carbs & Grains")   ? "selected" : "" %>>Carbs &amp; Grains</option>
                    <option value="Proteins &amp; Meat" <%= cat.equals("Proteins & Meat")  ? "selected" : "" %>>Proteins &amp; Meat</option>
                    <option value="Vegetables"          <%= cat.equals("Vegetables")        ? "selected" : "" %>>Vegetables</option>
                    <option value="Fruits"              <%= cat.equals("Fruits")            ? "selected" : "" %>>Fruits</option>
                    <option value="Dairy"               <%= cat.equals("Dairy")             ? "selected" : "" %>>Dairy</option>
                    <option value="Other"               <%= cat.equals("Other")             ? "selected" : "" %>>Other</option>
                  </select>
                </td>
                <td><input type="number" id="fer-cal-<%= f[0] %>"  value="<%= f[3] != null ? f[3] : "0" %>" step="0.01" min="0"/></td>
                <td><input type="number" id="fer-pro-<%= f[0] %>"  value="<%= f[4] != null ? f[4] : "0" %>" step="0.01" min="0"/></td>
                <td><input type="number" id="fer-carb-<%= f[0] %>" value="<%= f[5] != null ? f[5] : "0" %>" step="0.01" min="0"/></td>
                <td><input type="number" id="fer-fat-<%= f[0] %>"  value="<%= f[6] != null ? f[6] : "0" %>" step="0.01" min="0"/></td>
                <td>
                  <button class="btn-save"   onclick="saveFoodEdit('<%= f[0] %>')">&#10003; Save</button>
                  <button class="btn-cancel" onclick="cancelFoodEdit('<%= f[0] %>')">&#10005;</button>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      <% } %>
    </div>

  </div>
</div>

<script>
// ── Open correct tab on load ──
var INITIAL_TAB = '<%= openTab %>';

// ── Charts state ──
var CHART_DATA = {
  reg:   {'30':{labels:[<%= regDayLabels %>],   data:[<%= regDayData %>]},   'all':{labels:[<%= regMonthLabels %>], data:[<%= regMonthData %>]}},
  meals: {'30':{labels:[<%= mDayLabels %>],     data:[<%= mDayData %>]},     'all':{labels:[<%= mMonthLabels %>],   data:[<%= mMonthData %>]}},
  type:  {labels:[<%= distLabels %>], data:[<%= distData %>]}
};
var currentPeriod = '30';
var regChart, mealsChart, typeChart;
var chartsInitialized = false;

// ── Page tabs ──
// FIX #1: Charts were initialized in window.onload after switchPageTab() already
// hid the analytics tab. Chart.js reads canvas dimensions as 0×0 on a hidden
// element, producing blank/broken charts that never recover.
// Fix: defer initCharts() to the first time the analytics tab actually becomes
// visible, so Chart.js always measures a live canvas.
function switchPageTab(tab) {
  ['analytics','users','foods'].forEach(function(t) {
    document.getElementById('tab-btn-' + t).classList.toggle('active', t === tab);
    document.getElementById('tab-' + t).classList.toggle('active', t === tab);
  });

  // Lazy-init charts the first time the analytics tab is shown
  if (tab === 'analytics' && !chartsInitialized) {
    chartsInitialized = true;
    initCharts();
    calcNewToday();
  }
}

// ── Charts ──
function makeLineChart(ctx, labels, data, label, color) {
  return new Chart(ctx, {
    type: 'line',
    data: { labels: labels, datasets: [{ label: label, data: data, borderColor: color, backgroundColor: color + '22', borderWidth: 2, pointRadius: 3, fill: true, tension: 0.4 }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { display: false } }, scales: { x: { ticks: { font: { size: 10 } }, grid: { display: false } }, y: { ticks: { font: { size: 10 } }, beginAtZero: true, grid: { color: '#f0f4f2' } } } }
  });
}
function makeDoughnutChart(ctx, labels, data) {
  return new Chart(ctx, {
    type: 'doughnut',
    data: { labels: labels, datasets: [{ data: data, backgroundColor: ['#f57f17','#2e7d32','#4527a0','#880e4f','#6b7a72'], borderWidth: 2, borderColor: '#fff' }] },
    options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom', labels: { font: { size: 11 }, padding: 10 } } } }
  });
}
function initCharts() {
  var p = currentPeriod;
  regChart   = makeLineChart(document.getElementById('regChart'),   CHART_DATA.reg[p].labels,   CHART_DATA.reg[p].data,   'Registrations', '#2c3e7a');
  mealsChart = makeLineChart(document.getElementById('mealsChart'), CHART_DATA.meals[p].labels, CHART_DATA.meals[p].data, 'Meals Logged',  '#3d7a5a');
  typeChart  = makeDoughnutChart(document.getElementById('typeChart'), CHART_DATA.type.labels, CHART_DATA.type.data);
}
function setPeriod(p) {
  currentPeriod = p;
  document.getElementById('btn-30').classList.toggle('active',  p === '30');
  document.getElementById('btn-all').classList.toggle('active', p === 'all');
  if (!chartsInitialized) return;
  regChart.data.labels = CHART_DATA.reg[p].labels;   regChart.data.datasets[0].data = CHART_DATA.reg[p].data;     regChart.update();
  mealsChart.data.labels = CHART_DATA.meals[p].labels; mealsChart.data.datasets[0].data = CHART_DATA.meals[p].data; mealsChart.update();
}
function calcNewToday() {
  var today  = new Date().toISOString().split('T')[0];
  var labels = CHART_DATA.reg['30'].labels;
  var data   = CHART_DATA.reg['30'].data;
  var count  = 0;
  for (var i = 0; i < labels.length; i++) {
    if (labels[i] === today) { count = data[i]; break; }
  }
  document.getElementById('stat-new-today').textContent = count;
}

// ── User table ──
function filterUsers() {
  var q = document.getElementById('user-search').value.toLowerCase();
  document.querySelectorAll('#users-table tbody tr[id^="urow-"]').forEach(function(row) {
    var show = !q || (row.getAttribute('data-name') || '').indexOf(q) !== -1 || (row.getAttribute('data-email') || '').indexOf(q) !== -1;
    var id = row.id.replace('urow-', '');
    row.style.display = show ? '' : 'none';
    var er = document.getElementById('uedit-' + id), mr = document.getElementById('umealrow-' + id);
    if (er) er.style.display = 'none';
    if (mr) mr.style.display = 'none';
  });
}
function toggleMeals(id) {
  var row = document.getElementById('umealrow-' + id);
  var btn = document.querySelector('#urow-' + id + ' .btn-expand');
  if (row.style.display === 'none') { row.style.display = ''; btn.innerHTML = '&#9650; Meals'; }
  else                              { row.style.display = 'none'; btn.innerHTML = '&#9660; Meals'; }
}
function startUserEdit(id)  { document.getElementById('urow-' + id).style.display = 'none'; document.getElementById('uedit-' + id).style.display = ''; var mr = document.getElementById('umealrow-' + id); if (mr) mr.style.display = 'none'; }
function cancelUserEdit(id) { document.getElementById('uedit-' + id).style.display = 'none'; document.getElementById('urow-' + id).style.display = ''; }
function saveUserEdit(id) {
  var name  = document.getElementById('uer-name-'  + id).value.trim();
  var email = document.getElementById('uer-email-' + id).value.trim();
  if (!name || !email) { alert('Name and email cannot be empty.'); return; }
  document.getElementById('upd-user-id').value    = id;
  document.getElementById('upd-user-name').value  = name;
  document.getElementById('upd-user-email').value = email;
  document.getElementById('upd-user-form').submit();
}
function deleteUser(id, name) {
  if (!confirm('Delete user "' + name + '"?\n\nAll their meals will also be permanently deleted.')) return;
  document.getElementById('del-user-id').value = id;
  document.getElementById('del-user-form').submit();
}

// ── Food table ──
function filterFoods() {
  var q   = (document.getElementById('food-search').value || '').toLowerCase();
  var cat = document.getElementById('food-cat-filter').value || '';
  var catDecoded = cat.replace('&amp;', '&');
  document.querySelectorAll('#foods-table tbody tr[id^="frow-"]').forEach(function(row) {
    var name   = (row.getAttribute('data-name') || '');
    var rowCat = (row.getAttribute('data-cat')  || '');
    var show   = (!q || name.indexOf(q) !== -1) && (!catDecoded || rowCat === catDecoded);
    var id = row.id.replace('frow-', '');
    row.style.display = show ? '' : 'none';
    var er = document.getElementById('fedit-' + id);
    if (er) er.style.display = 'none';
  });
}
function clearFoodFilters() { document.getElementById('food-search').value = ''; document.getElementById('food-cat-filter').value = ''; filterFoods(); }
function startFoodEdit(id)  { document.getElementById('frow-'  + id).style.display = 'none'; document.getElementById('fedit-' + id).style.display = ''; }
function cancelFoodEdit(id) { document.getElementById('fedit-' + id).style.display = 'none'; document.getElementById('frow-'  + id).style.display = ''; }
function saveFoodEdit(id) {
  var name = document.getElementById('fer-name-' + id).value.trim();
  if (!name) { alert('Food name cannot be empty.'); return; }
  var catEl = document.getElementById('fer-cat-' + id);
  document.getElementById('upd-food-id').value   = id;
  document.getElementById('upd-food-name').value = name;
  document.getElementById('upd-food-cat').value  = catEl.options[catEl.selectedIndex].value;
  document.getElementById('upd-food-cal').value  = document.getElementById('fer-cal-'  + id).value;
  document.getElementById('upd-food-pro').value  = document.getElementById('fer-pro-'  + id).value;
  document.getElementById('upd-food-carb').value = document.getElementById('fer-carb-' + id).value;
  document.getElementById('upd-food-fat').value  = document.getElementById('fer-fat-'  + id).value;
  document.getElementById('upd-food-form').submit();
}
function deleteFood(id, name) {
  if (!confirm('Delete "' + name + '" from the food database?')) return;
  document.getElementById('del-food-id').value = id;
  document.getElementById('del-food-form').submit();
}

// FIX #1 (continued): window.onload only sets the active tab.
// Charts are now lazy-initialized inside switchPageTab() when analytics tab
// becomes visible for the first time, guaranteeing a non-zero canvas size.
window.onload = function() {
  switchPageTab(INITIAL_TAB);
};
</script>

</body>
</html>
