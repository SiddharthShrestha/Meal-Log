<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>MealLog — Dashboard</title>
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
      --success:      #27ae60;
      --success-bg:   #f0fff4;
      --shadow:       0 4px 24px rgba(30,50,38,0.10);
      --radius:       14px;
      --radius-sm:    8px;
    }

    body {
      font-family: 'DM Sans', sans-serif;
      background: var(--cream);
      min-height: 100vh;
      color: var(--ink);
    }

    /* ── Navbar ── */
    .navbar {
      background: var(--white);
      border-bottom: 1px solid var(--border);
      padding: 0 32px;
      height: 60px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      position: sticky;
      top: 0;
      z-index: 100;
      box-shadow: 0 2px 8px rgba(30,50,38,0.06);
    }
    .brand-bar {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .brand-icon {
      width: 34px; height: 34px;
      background: var(--green);
      border-radius: 8px;
      display: flex; align-items: center; justify-content: center;
    }
    .brand-icon svg {
      width: 18px; height: 18px;
      stroke: #fff; fill: none;
      stroke-width: 2; stroke-linecap: round; stroke-linejoin: round;
    }
    .brand-name {
      font-family: 'Playfair Display', serif;
      font-size: 1.3rem;
      color: var(--ink);
    }
    .brand-name span { color: var(--green); }

    .nav-right {
      display: flex;
      align-items: center;
      gap: 16px;
    }
    .nav-user {
      font-size: 0.88rem;
      color: var(--muted);
    }
    .nav-user strong {
      color: var(--ink);
      font-weight: 600;
    }
    .btn-logout {
      padding: 7px 16px;
      background: none;
      border: 1.5px solid var(--border);
      border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif;
      font-size: 0.82rem;
      font-weight: 600;
      color: var(--muted);
      cursor: pointer;
      transition: border-color 0.18s, color 0.18s;
    }
    .btn-logout:hover { border-color: var(--error); color: var(--error); }

    /* ── Page body ── */
    .page-body {
      padding: 32px 32px;
      max-width: 1200px;
      margin: 0 auto;
    }

    .page-title {
      font-family: 'Playfair Display', serif;
      font-size: 1.6rem;
      font-weight: 500;
      margin-bottom: 6px;
    }
    .page-subtitle {
      font-size: 0.88rem;
      color: var(--muted);
      margin-bottom: 28px;
    }

    /* ── Summary cards ── */
    .summary-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
      gap: 16px;
      margin-bottom: 32px;
    }
    .summary-card {
      background: var(--white);
      border-radius: var(--radius);
      border: 1px solid rgba(212,224,217,0.6);
      padding: 18px 20px;
      box-shadow: var(--shadow);
    }
    .summary-card .label {
      font-size: 0.74rem;
      font-weight: 600;
      letter-spacing: 0.06em;
      text-transform: uppercase;
      color: var(--muted);
      margin-bottom: 8px;
    }
    .summary-card .value {
      font-size: 1.7rem;
      font-weight: 600;
      color: var(--green);
      line-height: 1;
    }
    .summary-card .unit {
      font-size: 0.78rem;
      color: var(--muted);
      margin-top: 4px;
    }

    /* ── Layout: form + table side by side ── */
    .content-grid {
      display: grid;
      grid-template-columns: 340px 1fr;
      gap: 24px;
      align-items: start;
    }

    /* ── Card ── */
    .card {
      background: var(--white);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      border: 1px solid rgba(212,224,217,0.6);
      overflow: hidden;
    }
    .card-header {
      padding: 18px 22px;
      border-bottom: 1px solid var(--border);
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .card-header h2 {
      font-family: 'Playfair Display', serif;
      font-size: 1.1rem;
      font-weight: 500;
    }
    .count-badge {
      background: var(--green-pale);
      color: var(--green);
      font-size: 0.75rem;
      font-weight: 600;
      padding: 3px 10px;
      border-radius: 20px;
      border: 1px solid var(--green-dim);
    }
    .card-body { padding: 22px; }

    /* ── Banner ── */
    .banner {
      border-radius: var(--radius-sm);
      padding: 10px 14px;
      font-size: 0.86rem;
      font-weight: 500;
      margin-bottom: 20px;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .banner.success { background: var(--success-bg); color: var(--success); border: 1px solid #b7e4c7; }
    .banner.error   { background: var(--error-bg);   color: var(--error);   border: 1px solid #f5c6c2; }

    /* ── Form ── */
    .field { margin-bottom: 14px; }
    label {
      display: block;
      font-size: 0.75rem;
      font-weight: 600;
      letter-spacing: 0.05em;
      text-transform: uppercase;
      color: var(--muted);
      margin-bottom: 5px;
    }
    input[type="text"],
    input[type="number"],
    input[type="date"],
    select {
      width: 100%;
      padding: 10px 12px;
      border: 1.5px solid var(--border);
      border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif;
      font-size: 0.9rem;
      background: var(--white);
      color: var(--ink);
      outline: none;
      transition: border-color 0.18s, box-shadow 0.18s;
      appearance: none;
    }
    input:focus, select:focus {
      border-color: var(--green);
      box-shadow: 0 0 0 3px rgba(61,122,90,0.10);
    }
    select {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 24 24' fill='none' stroke='%236b7a72' stroke-width='2.5'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 12px center;
      padding-right: 32px;
    }

    .macro-row {
      display: grid;
      grid-template-columns: 1fr 1fr 1fr;
      gap: 10px;
    }

    .btn-primary {
      width: 100%;
      padding: 11px;
      background: var(--green);
      color: #fff;
      border: none;
      border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif;
      font-size: 0.92rem;
      font-weight: 600;
      cursor: pointer;
      transition: background 0.18s, transform 0.1s;
      margin-top: 6px;
    }
    .btn-primary:hover  { background: var(--green-light); }
    .btn-primary:active { transform: scale(0.99); }

    /* ── Table ── */
    .table-wrap { overflow-x: auto; }

    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 0.85rem;
    }
    thead th {
      background: var(--green);
      color: #fff;
      padding: 11px 14px;
      text-align: left;
      font-size: 0.73rem;
      font-weight: 600;
      letter-spacing: 0.05em;
      text-transform: uppercase;
      white-space: nowrap;
    }
    tbody td {
      padding: 11px 14px;
      border-bottom: 1px solid #f0f4f2;
      color: var(--ink);
      vertical-align: middle;
      white-space: nowrap;
    }
    tbody tr:last-child td { border-bottom: none; }
    tbody tr:nth-child(even) td { background: #f9fbfa; }
    tbody tr:hover td { background: var(--green-pale); transition: background 0.15s; }
    tbody .edit-row td { background: #fffdf5 !important; }

    .meal-type-badge {
      display: inline-block;
      padding: 3px 9px;
      border-radius: 12px;
      font-size: 0.73rem;
      font-weight: 600;
      text-transform: capitalize;
    }
    .badge-breakfast { background: #fff8e1; color: #f57f17; }
    .badge-lunch     { background: #e8f5e9; color: #2e7d32; }
    .badge-dinner    { background: #ede7f6; color: #4527a0; }
    .badge-snack     { background: #fce4ec; color: #880e4f; }
    .badge-other     { background: #f5f5f5; color: #555; }

    .btn-edit {
      padding: 4px 10px;
      font-size: 0.75rem;
      font-weight: 600;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-family: 'DM Sans', sans-serif;
      background: #fff3e0;
      color: #e65100;
      margin-right: 5px;
      transition: opacity 0.15s;
    }
    .btn-del {
      padding: 4px 10px;
      font-size: 0.75rem;
      font-weight: 600;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-family: 'DM Sans', sans-serif;
      background: #fce4ec;
      color: #c62828;
      transition: opacity 0.15s;
    }
    .btn-edit:hover, .btn-del:hover { opacity: 0.7; }

    /* Inline edit */
    .edit-row input[type="text"],
    .edit-row input[type="number"],
    .edit-row input[type="date"],
    .edit-row select {
      width: 100%;
      padding: 5px 8px;
      font-size: 0.8rem;
      border: 1.5px solid var(--green-dim);
      border-radius: 6px;
      font-family: 'DM Sans', sans-serif;
      outline: none;
      min-width: 80px;
    }
    .edit-row select {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%236b7a72' stroke-width='2.5'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E");
      background-repeat: no-repeat;
      background-position: right 8px center;
      padding-right: 24px;
      appearance: none;
    }
    .edit-row input:focus, .edit-row select:focus { border-color: var(--green); }

    .btn-save {
      padding: 4px 10px; font-size: 0.75rem; font-weight: 600;
      border: 1px solid var(--green-dim); border-radius: 6px;
      cursor: pointer; font-family: 'DM Sans', sans-serif;
      background: var(--green-pale); color: var(--green); margin-right: 4px;
    }
    .btn-cancel {
      padding: 4px 10px; font-size: 0.75rem; font-weight: 600;
      border: 1px solid #ddd; border-radius: 6px;
      cursor: pointer; font-family: 'DM Sans', sans-serif;
      background: #f0f0f0; color: #555;
    }
    .btn-save:hover   { background: #d2eddf; }
    .btn-cancel:hover { background: #e0e0e0; }

    .no-data {
      text-align: center;
      color: var(--muted);
      padding: 50px 0;
      font-size: 0.92rem;
    }
    .no-data svg {
      width: 36px; height: 36px;
      stroke: var(--border); fill: none; stroke-width: 1.5;
      display: block; margin: 0 auto 10px;
    }

    .hidden-form { display: none; }

    @media (max-width: 960px) {
      .content-grid { grid-template-columns: 1fr; }
    }
    @media (max-width: 600px) {
      .navbar { padding: 0 16px; }
      .page-body { padding: 20px 16px; }
    }
  </style>
</head>
<body>

<%
  List<String[]> meals = (List<String[]>) request.getAttribute("meals");
  int mealCount = (meals != null) ? meals.size() : 0;

  // Totals for summary cards
  int    totalCalories = 0;
  double totalProtein  = 0;
  double totalCarbs    = 0;
  double totalFats     = 0;
  if (meals != null) {
    for (String[] m : meals) {
      try { totalCalories += Integer.parseInt(m[3]);        } catch (Exception e) {}
      try { totalProtein  += Double.parseDouble(m[4]);      } catch (Exception e) {}
      try { totalCarbs    += Double.parseDouble(m[5]);      } catch (Exception e) {}
      try { totalFats     += Double.parseDouble(m[6]);      } catch (Exception e) {}
    }
  }

  String userName = (String) session.getAttribute("userName");
%>

<!-- Hidden forms -->
<form class="hidden-form" id="delete-form" action="dashboard" method="post">
  <input type="hidden" name="action" value="delete"/>
  <input type="hidden" name="id"     id="delete-id"/>
</form>

<form class="hidden-form" id="update-form" action="dashboard" method="post">
  <input type="hidden" name="action"     value="update"/>
  <input type="hidden" name="id"         id="update-id"/>
  <input type="hidden" name="meal_type"  id="update-meal_type"/>
  <input type="hidden" name="meal_name"  id="update-meal_name"/>
  <input type="hidden" name="calories"   id="update-calories"/>
  <input type="hidden" name="protein"    id="update-protein"/>
  <input type="hidden" name="carbs"      id="update-carbs"/>
  <input type="hidden" name="fats"       id="update-fats"/>
  <input type="hidden" name="meal_date"  id="update-meal_date"/>
</form>

<form class="hidden-form" id="logout-form" action="dashboard" method="post">
  <input type="hidden" name="action" value="logout"/>
</form>

<!-- Navbar -->
<nav class="navbar">
  <div class="brand-bar">
    <div class="brand-icon">
      <svg viewBox="0 0 24 24"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg>
    </div>
    <div class="brand-name">Meal<span>Log</span></div>
  </div>
  <div class="nav-right">
    <span class="nav-user">Hello, <strong><%= userName != null ? userName : "User" %></strong></span>
    <button class="btn-logout" onclick="document.getElementById('logout-form').submit()">Sign Out</button>
  </div>
</nav>

<!-- Page body -->
<div class="page-body">

  <div class="page-title">My Meal Log</div>
  <div class="page-subtitle">Track your daily nutrition across all meals</div>

  <!-- Banners -->
  <% if (request.getAttribute("successMsg") != null) { %>
    <div class="banner success">&#10003; <%= request.getAttribute("successMsg") %></div>
  <% } %>
  <% if (request.getAttribute("errorMsg") != null) { %>
    <div class="banner error">&#9888; <%= request.getAttribute("errorMsg") %></div>
  <% } %>

  <!-- Summary cards -->
  <div class="summary-grid">
    <div class="summary-card">
      <div class="label">Total Meals</div>
      <div class="value"><%= mealCount %></div>
      <div class="unit">logged</div>
    </div>
    <div class="summary-card">
      <div class="label">Calories</div>
      <div class="value"><%= totalCalories %></div>
      <div class="unit">kcal total</div>
    </div>
    <div class="summary-card">
      <div class="label">Protein</div>
      <div class="value"><%= String.format("%.1f", totalProtein) %></div>
      <div class="unit">grams total</div>
    </div>
    <div class="summary-card">
      <div class="label">Carbs</div>
      <div class="value"><%= String.format("%.1f", totalCarbs) %></div>
      <div class="unit">grams total</div>
    </div>
    <div class="summary-card">
      <div class="label">Fats</div>
      <div class="value"><%= String.format("%.1f", totalFats) %></div>
      <div class="unit">grams total</div>
    </div>
  </div>

  <!-- Content grid -->
  <div class="content-grid">

    <!-- Add meal form -->
    <div class="card">
      <div class="card-header">
        <h2>Log a Meal</h2>
      </div>
      <div class="card-body">
        <form action="dashboard" method="post">
          <input type="hidden" name="action" value="create"/>

          <div class="field">
            <label>Meal Type</label>
            <select name="meal_type">
              <option value="">— Select type —</option>
              <option value="Breakfast">Breakfast</option>
              <option value="Lunch">Lunch</option>
              <option value="Dinner">Dinner</option>
              <option value="Snack">Snack</option>
              <option value="Other">Other</option>
            </select>
          </div>

          <div class="field">
            <label>Meal Name *</label>
            <input type="text" name="meal_name" placeholder="e.g. Grilled chicken salad"/>
          </div>

          <div class="field">
            <label>Calories (kcal)</label>
            <input type="number" name="calories" placeholder="e.g. 450" min="0"/>
          </div>

          <div class="field">
            <label>Macros (g)</label>
            <div class="macro-row">
              <input type="number" name="protein" placeholder="Protein" min="0" step="0.1"/>
              <input type="number" name="carbs"   placeholder="Carbs"   min="0" step="0.1"/>
              <input type="number" name="fats"    placeholder="Fats"    min="0" step="0.1"/>
            </div>
          </div>

          <div class="field">
            <label>Date</label>
            <input type="date" name="meal_date"/>
          </div>

          <button type="submit" class="btn-primary">+ Add Meal</button>
        </form>
      </div>
    </div>

    <!-- Meals table -->
    <div class="card">
      <div class="card-header">
        <h2>My Meals</h2>
        <span class="count-badge"><%= mealCount %> meal<%= mealCount != 1 ? "s" : "" %></span>
      </div>

      <% if (meals == null || meals.isEmpty()) { %>
        <div class="no-data">
          <svg viewBox="0 0 24 24">
            <path d="M3 3h18v18H3z" stroke-dasharray="4 2"/>
            <path d="M12 8v4M12 16h.01"/>
          </svg>
          No meals logged yet. Add your first meal!
        </div>
      <% } else { %>
        <div class="table-wrap">
          <table>
            <thead>
              <tr>
                <th>Type</th>
                <th>Meal</th>
                <th>Kcal</th>
                <th>Protein</th>
                <th>Carbs</th>
                <th>Fats</th>
                <th>Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% for (String[] m : meals) {
                   // m[0]=id, m[1]=meal_type, m[2]=meal_name, m[3]=calories,
                   // m[4]=protein, m[5]=carbs, m[6]=fats, m[7]=meal_date
                   String typeLower = m[1].toLowerCase();
                   String badgeClass = "badge-other";
                   if (typeLower.equals("breakfast"))     badgeClass = "badge-breakfast";
                   else if (typeLower.equals("lunch"))    badgeClass = "badge-lunch";
                   else if (typeLower.equals("dinner"))   badgeClass = "badge-dinner";
                   else if (typeLower.equals("snack"))    badgeClass = "badge-snack";
              %>
              <!-- Normal row -->
              <tr id="row-<%= m[0] %>">
                <td><span class="meal-type-badge <%= badgeClass %>"><%= m[1].isEmpty() ? "—" : m[1] %></span></td>
                <td><strong><%= m[2] %></strong></td>
                <td><%= m[3] %></td>
                <td><%= m[4] %>g</td>
                <td><%= m[5] %>g</td>
                <td><%= m[6] %>g</td>
                <td><%= m[7].isEmpty() ? "—" : m[7] %></td>
                <td>
                  <button class="btn-edit" onclick="startEdit('<%= m[0] %>')">&#9998; Edit</button>
                  <button class="btn-del"  onclick="doDelete('<%= m[0] %>', '<%= m[2] %>')">&#128465;</button>
                </td>
              </tr>
              <!-- Inline edit row -->
              <tr class="edit-row" id="edit-row-<%= m[0] %>" style="display:none;">
                <td>
                  <select id="er-type-<%= m[0] %>">
                    <option value="Breakfast" <%= m[1].equals("Breakfast") ? "selected" : "" %>>Breakfast</option>
                    <option value="Lunch"     <%= m[1].equals("Lunch")     ? "selected" : "" %>>Lunch</option>
                    <option value="Dinner"    <%= m[1].equals("Dinner")    ? "selected" : "" %>>Dinner</option>
                    <option value="Snack"     <%= m[1].equals("Snack")     ? "selected" : "" %>>Snack</option>
                    <option value="Other"     <%= m[1].equals("Other")     ? "selected" : "" %>>Other</option>
                  </select>
                </td>
                <td><input type="text"   id="er-name-<%= m[0] %>"     value="<%= m[2] %>"/></td>
                <td><input type="number" id="er-calories-<%= m[0] %>" value="<%= m[3] %>" min="0"/></td>
                <td><input type="number" id="er-protein-<%= m[0] %>"  value="<%= m[4] %>" min="0" step="0.1"/></td>
                <td><input type="number" id="er-carbs-<%= m[0] %>"    value="<%= m[5] %>" min="0" step="0.1"/></td>
                <td><input type="number" id="er-fats-<%= m[0] %>"     value="<%= m[6] %>" min="0" step="0.1"/></td>
                <td><input type="date"   id="er-date-<%= m[0] %>"     value="<%= m[7] %>"/></td>
                <td>
                  <button class="btn-save"   onclick="saveEdit('<%= m[0] %>')">&#10003; Save</button>
                  <button class="btn-cancel" onclick="cancelEdit('<%= m[0] %>')">&#10005;</button>
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
  function startEdit(id) {
    document.getElementById('row-'      + id).style.display = 'none';
    document.getElementById('edit-row-' + id).style.display = '';
  }

  function cancelEdit(id) {
    document.getElementById('edit-row-' + id).style.display = 'none';
    document.getElementById('row-'      + id).style.display = '';
  }

  function saveEdit(id) {
    var name = document.getElementById('er-name-' + id).value.trim();
    if (!name) { alert('Meal name cannot be empty.'); return; }
    document.getElementById('update-id').value        = id;
    document.getElementById('update-meal_type').value = document.getElementById('er-type-'     + id).value;
    document.getElementById('update-meal_name').value = name;
    document.getElementById('update-calories').value  = document.getElementById('er-calories-' + id).value;
    document.getElementById('update-protein').value   = document.getElementById('er-protein-'  + id).value;
    document.getElementById('update-carbs').value     = document.getElementById('er-carbs-'    + id).value;
    document.getElementById('update-fats').value      = document.getElementById('er-fats-'     + id).value;
    document.getElementById('update-meal_date').value = document.getElementById('er-date-'     + id).value;
    document.getElementById('update-form').submit();
  }

  function doDelete(id, name) {
    if (!confirm('Delete "' + name + '"? This cannot be undone.')) return;
    document.getElementById('delete-id').value = id;
    document.getElementById('delete-form').submit();
  }
</script>

</body>
</html>