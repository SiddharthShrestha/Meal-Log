<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>MealLog — Admin</title>
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
      padding: 36px 24px;
      color: var(--ink);
    }

    .page-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 28px;
      flex-wrap: wrap;
      gap: 12px;
    }

    .brand-bar {
      display: flex;
      align-items: center;
      gap: 10px;
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

    .admin-badge {
      background: var(--green-pale);
      color: var(--green);
      font-size: 0.75rem;
      font-weight: 600;
      padding: 4px 10px;
      border-radius: 20px;
      border: 1px solid var(--green-dim);
      letter-spacing: 0.05em;
      text-transform: uppercase;
    }

    .card {
      background: var(--white);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      border: 1px solid rgba(212,224,217,0.6);
      overflow: hidden;
    }

    .card-header {
      padding: 20px 24px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      border-bottom: 1px solid var(--border);
      flex-wrap: wrap;
      gap: 10px;
    }
    .card-header h2 {
      font-family: 'Playfair Display', serif;
      font-size: 1.2rem;
      font-weight: 500;
    }
    .count-badge {
      background: var(--green-pale);
      color: var(--green);
      font-size: 0.78rem;
      font-weight: 600;
      padding: 4px 12px;
      border-radius: 20px;
      border: 1px solid var(--green-dim);
    }

    .banner {
      margin: 16px 24px 0;
      border-radius: var(--radius-sm);
      padding: 11px 14px;
      font-size: 0.88rem;
      font-weight: 500;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .banner.success { background: var(--success-bg); color: var(--success); border: 1px solid #b7e4c7; }
    .banner.error   { background: var(--error-bg);   color: var(--error);   border: 1px solid #f5c6c2; }

    .table-wrap { overflow-x: auto; }

    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 0.88rem;
    }

    thead th {
      background: var(--green);
      color: #fff;
      padding: 12px 16px;
      text-align: left;
      font-size: 0.76rem;
      font-weight: 600;
      letter-spacing: 0.05em;
      text-transform: uppercase;
      white-space: nowrap;
    }

    tbody td {
      padding: 12px 16px;
      border-bottom: 1px solid #f0f4f2;
      color: var(--ink);
      vertical-align: middle;
    }
    tbody tr:last-child td { border-bottom: none; }
    tbody tr:nth-child(even) td { background: #f9fbfa; }
    tbody tr:hover td { background: var(--green-pale); transition: background 0.15s; }
    tbody .edit-row td { background: #fffdf5 !important; }

    /* Normal row action buttons */
    .btn-edit {
      padding: 5px 12px;
      font-size: 0.78rem;
      font-weight: 600;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-family: 'DM Sans', sans-serif;
      background: #fff3e0;
      color: #e65100;
      margin-right: 6px;
      transition: opacity 0.15s;
    }
    .btn-del {
      padding: 5px 12px;
      font-size: 0.78rem;
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

    /* Inline edit inputs */
    .edit-row input[type="text"],
    .edit-row input[type="email"] {
      width: 100%;
      padding: 6px 10px;
      font-size: 0.85rem;
      border: 1.5px solid var(--green-dim);
      border-radius: 6px;
      font-family: 'DM Sans', sans-serif;
      outline: none;
      background: var(--white);
      color: var(--ink);
      transition: border-color 0.18s;
    }
    .edit-row input:focus { border-color: var(--green); }

    .btn-save {
      padding: 5px 12px;
      font-size: 0.78rem;
      font-weight: 600;
      border: 1px solid var(--green-dim);
      border-radius: 6px;
      cursor: pointer;
      font-family: 'DM Sans', sans-serif;
      background: var(--green-pale);
      color: var(--green);
      margin-right: 6px;
      transition: background 0.15s;
    }
    .btn-cancel {
      padding: 5px 12px;
      font-size: 0.78rem;
      font-weight: 600;
      border: 1px solid #ddd;
      border-radius: 6px;
      cursor: pointer;
      font-family: 'DM Sans', sans-serif;
      background: #f0f0f0;
      color: #555;
      transition: background 0.15s;
    }
    .btn-save:hover   { background: #d2eddf; }
    .btn-cancel:hover { background: #e0e0e0; }

    .no-data {
      text-align: center;
      color: var(--muted);
      padding: 60px 0;
      font-size: 0.95rem;
    }
    .no-data svg {
      width: 40px; height: 40px;
      stroke: var(--border); fill: none; stroke-width: 1.5;
      display: block; margin: 0 auto 12px;
    }

    /* Hidden forms for submit */
    .hidden-form { display: none; }

    @media (max-width: 600px) {
      body { padding: 20px 12px; }
      .card-header { padding: 16px; }
      tbody td, thead th { padding: 10px 12px; }
    }
  </style>
</head>
<body>

<%
  List<String[]> users = (List<String[]>) request.getAttribute("users");
  int userCount = (users != null) ? users.size() : 0;
%>

<!-- Hidden delete form -->
<form class="hidden-form" id="delete-form" action="admin" method="post">
  <input type="hidden" name="action" value="delete"/>
  <input type="hidden" name="id"     id="delete-id"/>
</form>

<!-- Hidden update form -->
<form class="hidden-form" id="update-form" action="admin" method="post">
  <input type="hidden" name="action"     value="update"/>
  <input type="hidden" name="id"         id="update-id"/>
  <input type="hidden" name="full_name"  id="update-full_name"/>
  <input type="hidden" name="email"      id="update-email"/>
</form>

<!-- Page header -->
<div class="page-header">
  <div class="brand-bar">
    <div class="brand-icon">
      <svg viewBox="0 0 24 24"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg>
    </div>
    <div class="brand-name">Meal<span>Log</span></div>
  </div>
  <span class="admin-badge">Admin Panel</span>
</div>

<!-- Banners -->
<% if (request.getAttribute("successMsg") != null) { %>
  <div class="banner success" style="margin-bottom: 20px;">&#10003; <%= request.getAttribute("successMsg") %></div>
<% } %>
<% if (request.getAttribute("errorMsg") != null) { %>
  <div class="banner error" style="margin-bottom: 20px;">&#9888; <%= request.getAttribute("errorMsg") %></div>
<% } %>

<!-- Table card -->
<div class="card">
  <div class="card-header">
    <h2>All Users</h2>
    <span class="count-badge"><%= userCount %> user<%= userCount != 1 ? "s" : "" %></span>
  </div>

  <% if (users == null || users.isEmpty()) { %>
    <div class="no-data">
      <svg viewBox="0 0 24 24">
        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
        <circle cx="9" cy="7" r="4"/>
        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
      </svg>
      No users found in the database.
    </div>
  <% } else { %>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Full Name</th>
            <th>Email</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <% for (String[] u : users) {
               // u[0] = id, u[1] = full_name, u[2] = email
          %>
          <!-- Normal row -->
          <tr id="row-<%= u[0] %>">
            <td><strong>#<%= u[0] %></strong></td>
            <td><%= u[1] %></td>
            <td><%= u[2] %></td>
            <td>
              <button class="btn-edit" onclick="startEdit('<%= u[0] %>')">&#9998; Edit</button>
              <button class="btn-del"  onclick="doDelete('<%= u[0] %>', '<%= u[1] %>')">&#128465; Delete</button>
            </td>
          </tr>
          <!-- Inline edit row -->
          <tr class="edit-row" id="edit-row-<%= u[0] %>" style="display:none;">
            <td><strong>#<%= u[0] %></strong></td>
            <td><input type="text"  id="er-name-<%= u[0] %>"  value="<%= u[1] %>"/></td>
            <td><input type="email" id="er-email-<%= u[0] %>" value="<%= u[2] %>"/></td>
            <td>
              <button class="btn-save"   onclick="saveEdit('<%= u[0] %>')">&#10003; Save</button>
              <button class="btn-cancel" onclick="cancelEdit('<%= u[0] %>')">&#10005; Cancel</button>
            </td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>
  <% } %>
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
    var name  = document.getElementById('er-name-'  + id).value.trim();
    var email = document.getElementById('er-email-' + id).value.trim();
    if (!name || !email) {
      alert('Name and email cannot be empty.');
      return;
    }
    document.getElementById('update-id').value        = id;
    document.getElementById('update-full_name').value = name;
    document.getElementById('update-email').value     = email;
    document.getElementById('update-form').submit();
  }

  function doDelete(id, name) {
    if (!confirm('Delete user "' + name + '" (ID #' + id + ')? This cannot be undone.')) return;
    document.getElementById('delete-id').value = id;
    document.getElementById('delete-form').submit();
  }
</script>

</body>
</html>