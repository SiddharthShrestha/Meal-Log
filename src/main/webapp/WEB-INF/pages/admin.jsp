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
  <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --green:       #3d7a5a;
      --green-light: #5aab7e;
      --green-pale:  #e8f5ee;
      --green-dim:   #a8d5bc;
      --cream:       #faf8f3;
      --white:       #ffffff;
      --ink:         #1a1f1c;
      --muted:       #6b7a72;
      --border:      #d4e0d9;
      --error:       #c0392b;
      --error-bg:    #fdecea;
      --success:     #27ae60;
      --success-bg:  #f0fff4;
      --admin:       #2c3e7a;
      --admin-pale:  #eef0fa;
      --admin-dim:   #b0bae8;
      --shadow:      0 4px 24px rgba(30,50,38,0.10);
      --shadow-lg:   0 8px 40px rgba(30,50,38,0.16);
      --radius:      14px;
      --radius-sm:   8px;
    }

    body { font-family: 'DM Sans', sans-serif; background: var(--cream); min-height: 100vh; color: var(--ink); }

    /* ── Navbar ── */
    .navbar {
      background: var(--white); border-bottom: 1px solid var(--border);
      padding: 0 32px; height: 64px;
      display: flex; align-items: center; justify-content: space-between;
      position: sticky; top: 0; z-index: 200;
      box-shadow: 0 2px 12px rgba(30,50,38,0.07);
    }
    .brand-bar { display: flex; align-items: center; gap: 10px; }
    .brand-icon {
      width: 36px; height: 36px; background: var(--admin); border-radius: 9px;
      display: flex; align-items: center; justify-content: center;
    }
    .brand-icon svg { width: 18px; height: 18px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .brand-name { font-family: 'Playfair Display', serif; font-size: 1.3rem; color: var(--ink); }
    .brand-name span { color: var(--admin); }
    .admin-badge {
      background: var(--admin-pale); color: var(--admin);
      font-size: 0.72rem; font-weight: 600; padding: 4px 10px;
      border-radius: 20px; border: 1px solid var(--admin-dim);
      letter-spacing: 0.05em; text-transform: uppercase;
    }
    .btn-logout {
      padding: 7px 16px; background: none;
      border: 1.5px solid var(--border); border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif; font-size: 0.82rem; font-weight: 600;
      color: var(--muted); cursor: pointer; transition: border-color 0.18s, color 0.18s;
    }
    .btn-logout:hover { border-color: var(--error); color: var(--error); }

    /* ── Page ── */
    .page-body { padding: 32px; max-width: 1400px; margin: 0 auto; }
    .page-title    { font-family: 'Playfair Display', serif; font-size: 1.7rem; font-weight: 500; margin-bottom: 4px; }
    .page-subtitle { font-size: 0.88rem; color: var(--muted); margin-bottom: 28px; }

    /* ── Banner ── */
    .banner {
      border-radius: var(--radius-sm); padding: 11px 16px;
      font-size: 0.87rem; font-weight: 500; margin-bottom: 22px;
      display: flex; align-items: center; gap: 8px;
    }
    .banner.success { background: var(--success-bg); color: var(--success); border: 1px solid #b7e4c7; }
    .banner.error   { background: var(--error-bg);   color: var(--error);   border: 1px solid #f5c6c2; }

    /* ── Stat cards ── */
    .stat-grid {
      display: grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
      gap: 16px; margin-bottom: 32px;
    }
    .stat-card {
      background: var(--white); border-radius: var(--radius);
      border: 1px solid rgba(212,224,217,0.6); padding: 20px 22px;
      box-shadow: var(--shadow); transition: transform 0.15s, box-shadow 0.15s;
    }
    .stat-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
    .stat-card .s-label { font-size: 0.71rem; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); margin-bottom: 10px; }
    .stat-card .s-value { font-size: 1.9rem; font-weight: 700; color: var(--admin); line-height: 1; }
    .stat-card .s-unit  { font-size: 0.74rem; color: var(--muted); margin-top: 5px; }

    /* ── Section title ── */
    .section-title {
      font-family: 'Playfair Display', serif; font-size: 1.2rem;
      font-weight: 500; margin-bottom: 18px;
      display: flex; align-items: center; gap: 10px;
    }
    .section-title::after { content: ''; flex: 1; height: 1px; background: var(--border); }

    /* ── Period toggle ── */
    .period-toggle { display: flex; background: #ece9e2; border-radius: 8px; padding: 3px; gap: 3px; }
    .period-btn {
      padding: 6px 16px; background: none; border: none;
      font-family: 'DM Sans', sans-serif; font-size: 0.8rem; font-weight: 500;
      color: var(--muted); border-radius: 6px; cursor: pointer;
      transition: background 0.18s, color 0.18s;
    }
    .period-btn.active { background: var(--white); color: var(--admin); font-weight: 600; box-shadow: 0 1px 6px rgba(44,62,122,0.12); }

    /* ── Charts grid ── */
    .charts-grid { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; margin-bottom: 32px; }
    .chart-card {
      background: var(--white); border-radius: var(--radius);
      box-shadow: var(--shadow); border: 1px solid rgba(212,224,217,0.6);
      padding: 20px 22px;
    }
    .chart-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; flex-wrap: wrap; gap: 8px; }
    .chart-title  { font-size: 0.82rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--muted); }
    .chart-canvas { width: 100% !important; height: 200px !important; }

    /* ── Card ── */
    .card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); border: 1px solid rgba(212,224,217,0.6); overflow: hidden; margin-bottom: 24px; }
    .card-header {
      padding: 16px 22px; border-bottom: 1px solid var(--border);
      display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 10px;
    }
    .card-header h2 { font-family: 'Playfair Display', serif; font-size: 1.1rem; font-weight: 500; }
    .count-badge { background: var(--admin-pale); color: var(--admin); font-size: 0.74rem; font-weight: 600; padding: 3px 10px; border-radius: 20px; border: 1px solid var(--admin-dim); }

    /* ── Table toolbar ── */
    .table-toolbar { display: flex; align-items: center; gap: 10px; padding: 12px 22px; border-bottom: 1px solid var(--border); flex-wrap: wrap; }
    .search-input {
      flex: 1; min-width: 160px; padding: 8px 12px;
      border: 1.5px solid var(--border); border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif; font-size: 0.86rem; outline: none;
      transition: border-color 0.18s; width: auto;
    }
    .search-input:focus { border-color: var(--admin); }

    /* ── Table ── */
    .table-wrap { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; font-size: 0.85rem; }
    thead th {
      background: var(--admin); color: #fff; padding: 11px 14px;
      text-align: left; font-size: 0.71rem; font-weight: 600;
      letter-spacing: 0.05em; text-transform: uppercase; white-space: nowrap;
    }
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
      border: 1.5px solid var(--green-dim); border-radius: 6px;
      font-family: 'DM Sans', sans-serif; outline: none; min-width: 100px; appearance: none;
    }
    .edit-row input:focus, .edit-row select:focus { border-color: var(--admin); }
    .btn-save   { padding: 4px 10px; font-size: 0.74rem; font-weight: 600; border: 1px solid var(--admin-dim); border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: var(--admin-pale); color: var(--admin); margin-right: 4px; }
    .btn-cancel { padding: 4px 10px; font-size: 0.74rem; font-weight: 600; border: 1px solid #ddd; border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: #f0f0f0; color: #555; }
    .btn-save:hover   { background: #d8dcf5; }
    .btn-cancel:hover { background: #e0e0e0; }

    /* ── Expandable meals row ── */
    .meals-expand-row td { padding: 0 !important; border-bottom: 2px solid var(--admin-dim) !important; background: var(--admin-pale) !important; }
    .meals-expand-inner  { padding: 16px 20px; }
    .meals-expand-title  { font-size: 0.76rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--admin); margin-bottom: 12px; display: flex; align-items: center; gap: 6px; }

    .meals-sub-table { width: 100%; border-collapse: collapse; font-size: 0.82rem; }
    .meals-sub-table thead th { background: var(--admin); color: #fff; padding: 8px 12px; font-size: 0.69rem; font-weight: 600; letter-spacing: 0.04em; text-transform: uppercase; }
    .meals-sub-table tbody td { padding: 8px 12px; border-bottom: 1px solid #e8ecf8; }
    .meals-sub-table tbody tr:last-child td { border-bottom: none; }
    .meals-sub-table tbody tr:hover td { background: #dde2f5; }

    .meal-type-badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 0.69rem; font-weight: 600; text-transform: capitalize; }
    .badge-breakfast { background: #fff8e1; color: #f57f17; }
    .badge-lunch     { background: #e8f5e9; color: #2e7d32; }
    .badge-dinner    { background: #ede7f6; color: #4527a0; }
    .badge-snack     { background: #fce4ec; color: #880e4f; }
    .badge-other     { background: #f5f5f5; color: #555; }

    .no-meals { color: var(--muted); font-size: 0.84rem; font-style: italic; padding: 8px 0; }
    .no-data  { text-align: center; color: var(--muted); padding: 50px 0; font-size: 0.92rem; }
    .no-data svg { width: 36px; height: 36px; stroke: var(--border); fill: none; stroke-width: 1.5; display: block; margin: 0 auto 10px; }

    .hidden-form { display: none; }

    @media (max-width: 1100px) { .charts-grid { grid-template-columns: 1fr 1fr; } }
    @media (max-width: 700px)  { .charts-grid { grid-template-columns: 1fr; } .navbar { padding: 0 16px; } .page-body { padding: 20px 16px; } }
  </style>
</head>
<body>

<%
  List<String[]>              users           = (List<String[]>)              request.getAttribute("users");
  Map<String, List<String[]>> mealsByUser     = (Map<String, List<String[]>>) request.getAttribute("mealsByUser");
  List<String[]>              regPerDay       = (List<String[]>)              request.getAttribute("regPerDay");
  List<String[]>              regPerMonth     = (List<String[]>)              request.getAttribute("regPerMonth");
  List<String[]>              mealsPerDay     = (List<String[]>)              request.getAttribute("mealsPerDay");
  List<String[]>              mealsPerMonth   = (List<String[]>)              request.getAttribute("mealsPerMonth");
  List<String[]>              mealTypeDistrib = (List<String[]>)              request.getAttribute("mealTypeDistrib");

  int userCount  = (users != null) ? users.size() : 0;
  int totalMeals = 0;
  if (mealsByUser != null) {
      for (List<String[]> ml : mealsByUser.values()) {
          totalMeals += ml.size();
      }
  }

  // Build JS arrays for charts
  StringBuilder regDayLabels   = new StringBuilder();
  StringBuilder regDayData     = new StringBuilder();
  StringBuilder regMonthLabels = new StringBuilder();
  StringBuilder regMonthData   = new StringBuilder();
  StringBuilder mDayLabels     = new StringBuilder();
  StringBuilder mDayData       = new StringBuilder();
  StringBuilder mMonthLabels   = new StringBuilder();
  StringBuilder mMonthData     = new StringBuilder();
  StringBuilder distLabels     = new StringBuilder();
  StringBuilder distData       = new StringBuilder();

  if (regPerDay != null) {
      for (int i = 0; i < regPerDay.size(); i++) {
          regDayLabels.append("'").append(regPerDay.get(i)[0]).append("'").append(i < regPerDay.size()-1 ? "," : "");
          regDayData.append(regPerDay.get(i)[1]).append(i < regPerDay.size()-1 ? "," : "");
      }
  }
  if (regPerMonth != null) {
      for (int i = 0; i < regPerMonth.size(); i++) {
          regMonthLabels.append("'").append(regPerMonth.get(i)[0]).append("'").append(i < regPerMonth.size()-1 ? "," : "");
          regMonthData.append(regPerMonth.get(i)[1]).append(i < regPerMonth.size()-1 ? "," : "");
      }
  }
  if (mealsPerDay != null) {
      for (int i = 0; i < mealsPerDay.size(); i++) {
          mDayLabels.append("'").append(mealsPerDay.get(i)[0]).append("'").append(i < mealsPerDay.size()-1 ? "," : "");
          mDayData.append(mealsPerDay.get(i)[1]).append(i < mealsPerDay.size()-1 ? "," : "");
      }
  }
  if (mealsPerMonth != null) {
      for (int i = 0; i < mealsPerMonth.size(); i++) {
          mMonthLabels.append("'").append(mealsPerMonth.get(i)[0]).append("'").append(i < mealsPerMonth.size()-1 ? "," : "");
          mMonthData.append(mealsPerMonth.get(i)[1]).append(i < mealsPerMonth.size()-1 ? "," : "");
      }
  }
  if (mealTypeDistrib != null) {
      for (int i = 0; i < mealTypeDistrib.size(); i++) {
          distLabels.append("'").append(mealTypeDistrib.get(i)[0]).append("'").append(i < mealTypeDistrib.size()-1 ? "," : "");
          distData.append(mealTypeDistrib.get(i)[1]).append(i < mealTypeDistrib.size()-1 ? "," : "");
      }
  }
%>

<!-- Hidden forms -->
<form class="hidden-form" id="delete-form" action="admin" method="post">
  <input type="hidden" name="action" value="delete"/>
  <input type="hidden" name="id"    id="delete-id"/>
</form>
<form class="hidden-form" id="update-form" action="admin" method="post">
  <input type="hidden" name="action"    value="update"/>
  <input type="hidden" name="id"        id="update-id"/>
  <input type="hidden" name="full_name" id="update-full_name"/>
  <input type="hidden" name="email"     id="update-email"/>
</form>
<form class="hidden-form" id="logout-form" action="admin" method="post">
  <input type="hidden" name="action" value="logout"/>
</form>

<!-- Navbar -->
<nav class="navbar">
  <div class="brand-bar">
    <div class="brand-icon">
      <svg viewBox="0 0 24 24"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
    </div>
    <div class="brand-name">Meal<span>Log</span></div>
  </div>
  <div style="display:flex;align-items:center;gap:12px;">
    <span class="admin-badge">Admin Panel</span>
    <button class="btn-logout" onclick="document.getElementById('logout-form').submit()">Sign Out</button>
  </div>
</nav>

<div class="page-body">

  <div class="page-title">Admin Dashboard</div>
  <div class="page-subtitle">Overview of users, meals and platform activity</div>

  <% if (request.getAttribute("successMsg") != null) { %>
    <div class="banner success">&#10003; <%= request.getAttribute("successMsg") %></div>
  <% } %>
  <% if (request.getAttribute("errorMsg") != null) { %>
    <div class="banner error">&#9888; <%= request.getAttribute("errorMsg") %></div>
  <% } %>

  <!-- Stat cards -->
  <div class="stat-grid">
    <div class="stat-card">
      <div class="s-label">Total Users</div>
      <div class="s-value"><%= userCount %></div>
      <div class="s-unit">registered</div>
    </div>
    <div class="stat-card">
      <div class="s-label">Total Meals</div>
      <div class="s-value"><%= totalMeals %></div>
      <div class="s-unit">logged across all users</div>
    </div>
    <div class="stat-card">
      <div class="s-label">Avg Meals</div>
      <div class="s-value"><%= userCount > 0 ? String.format("%.1f", (double) totalMeals / userCount) : "0" %></div>
      <div class="s-unit">per user</div>
    </div>
    <div class="stat-card">
      <div class="s-label">New Today</div>
      <div class="s-value" id="stat-new-today">—</div>
      <div class="s-unit">registrations</div>
    </div>
  </div>

  <!-- Charts header -->
  <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:18px;flex-wrap:wrap;gap:10px;">
    <div class="section-title" style="margin:0;flex:1;">Analytics</div>
    <div class="period-toggle">
      <button class="period-btn active" id="btn-30"  onclick="setPeriod('30')">Last 30 Days</button>
      <button class="period-btn"        id="btn-all" onclick="setPeriod('all')">All Time</button>
    </div>
  </div>

  <!-- Charts -->
  <div class="charts-grid">
    <div class="chart-card">
      <div class="chart-header"><div class="chart-title">User Registrations</div></div>
      <canvas id="regChart"   class="chart-canvas"></canvas>
    </div>
    <div class="chart-card">
      <div class="chart-header"><div class="chart-title">Meals Logged</div></div>
      <canvas id="mealsChart" class="chart-canvas"></canvas>
    </div>
    <div class="chart-card">
      <div class="chart-header"><div class="chart-title">Meal Type Distribution</div></div>
      <canvas id="typeChart"  class="chart-canvas"></canvas>
    </div>
  </div>

  <!-- Users table -->
  <div class="card">
    <div class="card-header">
      <h2>All Users</h2>
      <span class="count-badge"><%= userCount %> user<%= userCount != 1 ? "s" : "" %></span>
    </div>
    <div class="table-toolbar">
      <input type="text" class="search-input" id="user-search" placeholder="&#128269; Search by name or email..." oninput="filterUsers()"/>
    </div>

    <% if (users == null || users.isEmpty()) { %>
      <div class="no-data">
        <svg viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
        No users found.
      </div>
    <% } else { %>
      <div class="table-wrap">
        <table id="users-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Full Name</th>
              <th>Email</th>
              <th>Registered</th>
              <th>Meals</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <%
              for (String[] u : users) {
                  List<String[]> uMeals = new ArrayList<String[]>();
                  if (mealsByUser != null && mealsByUser.containsKey(u[0])) {
                      uMeals = mealsByUser.get(u[0]);
                  }
                  int uMealCount = uMeals.size();
            %>
            <!-- Normal row -->
            <tr id="row-<%= u[0] %>" data-name="<%= u[1].toLowerCase() %>" data-email="<%= u[2].toLowerCase() %>">
              <td><strong>#<%= u[0] %></strong></td>
              <td><%= u[1] %></td>
              <td><%= u[2] %></td>
              <td><%= u[3].isEmpty() ? "—" : u[3].substring(0, 10) %></td>
              <td><span class="count-badge"><%= uMealCount %></span></td>
              <td>
                <button class="btn-expand" onclick="toggleMeals('<%= u[0] %>')">&#9660; Meals</button>
                <button class="btn-edit"   onclick="startEdit('<%= u[0] %>')">&#9998; Edit</button>
                <button class="btn-del"    onclick="doDelete('<%= u[0] %>', '<%= u[1] %>')">&#128465;</button>
              </td>
            </tr>
            <!-- Inline edit row -->
            <tr class="edit-row" id="edit-row-<%= u[0] %>" style="display:none;">
              <td><strong>#<%= u[0] %></strong></td>
              <td><input type="text"  id="er-name-<%= u[0] %>"  value="<%= u[1] %>"/></td>
              <td><input type="email" id="er-email-<%= u[0] %>" value="<%= u[2] %>"/></td>
              <td><%= u[3].isEmpty() ? "—" : u[3].substring(0, 10) %></td>
              <td><span class="count-badge"><%= uMealCount %></span></td>
              <td>
                <button class="btn-save"   onclick="saveEdit('<%= u[0] %>')">&#10003; Save</button>
                <button class="btn-cancel" onclick="cancelEdit('<%= u[0] %>')">&#10005; Cancel</button>
              </td>
            </tr>
            <!-- Expandable meals row -->
            <tr class="meals-expand-row" id="meals-row-<%= u[0] %>" style="display:none;">
              <td colspan="6">
                <div class="meals-expand-inner">
                  <div class="meals-expand-title">
                    &#127374; Meals logged by <%= u[1] %>
                    <span class="count-badge" style="text-transform:none;letter-spacing:0;"><%= uMealCount %> meal<%= uMealCount != 1 ? "s" : "" %></span>
                  </div>
                  <% if (uMeals.isEmpty()) { %>
                    <div class="no-meals">No meals logged by this user yet.</div>
                  <% } else { %>
                    <table class="meals-sub-table">
                      <thead>
                        <tr>
                          <th>ID</th>
                          <th>Type</th>
                          <th>Meal Name</th>
                          <th>Calories</th>
                          <th>Protein</th>
                          <th>Carbs</th>
                          <th>Fats</th>
                          <th>Date</th>
                        </tr>
                      </thead>
                      <tbody>
                        <%
                          for (String[] ml : uMeals) {
                              String tl = ml[3].toLowerCase();
                              String bc = "badge-other";
                              if      (tl.equals("breakfast")) bc = "badge-breakfast";
                              else if (tl.equals("lunch"))     bc = "badge-lunch";
                              else if (tl.equals("dinner"))    bc = "badge-dinner";
                              else if (tl.equals("snack"))     bc = "badge-snack";
                        %>
                        <tr>
                          <td>#<%= ml[0] %></td>
                          <td><span class="meal-type-badge <%= bc %>"><%= ml[3].isEmpty() ? "—" : ml[3] %></span></td>
                          <td><%= ml[4] %></td>
                          <td><%= ml[5] %></td>
                          <td><%= ml[6] %>g</td>
                          <td><%= ml[7] %>g</td>
                          <td><%= ml[8] %>g</td>
                          <td><%= ml[9].isEmpty() ? "—" : ml[9] %></td>
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

<script>
// ── Chart data ──
var CHART_DATA = {
  reg: {
    '30':  { labels: [<%= regDayLabels %>],   data: [<%= regDayData %>]   },
    'all': { labels: [<%= regMonthLabels %>], data: [<%= regMonthData %>] }
  },
  meals: {
    '30':  { labels: [<%= mDayLabels %>],   data: [<%= mDayData %>]   },
    'all': { labels: [<%= mMonthLabels %>], data: [<%= mMonthData %>] }
  },
  type: {
    labels: [<%= distLabels %>],
    data:   [<%= distData %>]
  }
};

var currentPeriod = '30';
var regChart, mealsChart, typeChart;

function makeLineChart(ctx, labels, data, label, color) {
  return new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels,
      datasets: [{
        label: label, data: data,
        borderColor: color, backgroundColor: color + '22',
        borderWidth: 2, pointRadius: 3, fill: true, tension: 0.4
      }]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { font: { size: 10 }, maxRotation: 45 }, grid: { display: false } },
        y: { ticks: { font: { size: 10 } }, beginAtZero: true, grid: { color: '#f0f4f2' } }
      }
    }
  });
}

function makeDoughnutChart(ctx, labels, data) {
  return new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: labels,
      datasets: [{
        data: data,
        backgroundColor: ['#f57f17','#2e7d32','#4527a0','#880e4f','#6b7a72'],
        borderWidth: 2, borderColor: '#fff'
      }]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: 'bottom', labels: { font: { size: 11 }, padding: 10 } } }
    }
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
  regChart.data.labels           = CHART_DATA.reg[p].labels;
  regChart.data.datasets[0].data = CHART_DATA.reg[p].data;
  regChart.update();
  mealsChart.data.labels           = CHART_DATA.meals[p].labels;
  mealsChart.data.datasets[0].data = CHART_DATA.meals[p].data;
  mealsChart.update();
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

function toggleMeals(userId) {
  var row = document.getElementById('meals-row-' + userId);
  var btn = document.querySelector('#row-' + userId + ' .btn-expand');
  if (row.style.display === 'none') {
    row.style.display = '';
    btn.innerHTML = '&#9650; Meals';
  } else {
    row.style.display = 'none';
    btn.innerHTML = '&#9660; Meals';
  }
}

function filterUsers() {
  var q = document.getElementById('user-search').value.toLowerCase();
  document.querySelectorAll('#users-table tbody tr[id^="row-"]').forEach(function(row) {
    var name  = row.getAttribute('data-name')  || '';
    var email = row.getAttribute('data-email') || '';
    var show  = !q || name.indexOf(q) !== -1 || email.indexOf(q) !== -1;
    var id    = row.id.replace('row-', '');
    row.style.display = show ? '' : 'none';
    var er = document.getElementById('edit-row-'  + id);
    var mr = document.getElementById('meals-row-' + id);
    if (er) er.style.display = 'none';
    if (mr) mr.style.display = 'none';
  });
}

function startEdit(id) {
  document.getElementById('row-'      + id).style.display = 'none';
  document.getElementById('edit-row-' + id).style.display = '';
  var mr = document.getElementById('meals-row-' + id);
  if (mr) mr.style.display = 'none';
}
function cancelEdit(id) {
  document.getElementById('edit-row-' + id).style.display = 'none';
  document.getElementById('row-'      + id).style.display = '';
}
function saveEdit(id) {
  var name  = document.getElementById('er-name-'  + id).value.trim();
  var email = document.getElementById('er-email-' + id).value.trim();
  if (!name || !email) { alert('Name and email cannot be empty.'); return; }
  document.getElementById('update-id').value        = id;
  document.getElementById('update-full_name').value = name;
  document.getElementById('update-email').value     = email;
  document.getElementById('update-form').submit();
}
function doDelete(id, name) {
  if (!confirm('Delete user "' + name + '" (ID #' + id + ')?\n\nAll their meals will also be permanently deleted.')) return;
  document.getElementById('delete-id').value = id;
  document.getElementById('delete-form').submit();
}

window.onload = function() {
  initCharts();
  calcNewToday();
};
</script>

</body>
</html>