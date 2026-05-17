<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.util.LinkedHashMap"%>
<%@ page import="java.util.ArrayList"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>MealLog — Dashboard</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@500;700&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet"/>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css"/>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
  <style>
    :root { --shadow-lg: 0 8px 40px rgba(30,50,38,0.16); }

    /* ── Navbar ── */
    .navbar {
      background: var(--white); border-bottom: 1px solid var(--border);
      padding: 0 48px; height: 68px; display: flex; align-items: center;
      justify-content: space-between; position: sticky; top: 0; z-index: 200;
      box-shadow: 0 2px 12px rgba(30,50,38,0.07);
    }
    .brand-bar { display: flex; align-items: center; gap: 12px; }
    .brand-icon { width: 40px; height: 40px; background: var(--green); border-radius: 10px; display: flex; align-items: center; justify-content: center; }
    .brand-icon svg { width: 20px; height: 20px; stroke: #fff; fill: none; stroke-width: 2; stroke-linecap: round; stroke-linejoin: round; }
    .brand-name { font-family: 'Playfair Display', serif; font-size: 1.5rem; color: var(--ink); }
    .brand-name span { color: var(--green); }
    .nav-right { display: flex; align-items: center; gap: 16px; }
    .nav-user  { font-size: 0.9rem; color: var(--muted); }
    .nav-user strong { color: var(--ink); font-weight: 600; }
    .avatar {
      width: 40px; height: 40px; background: var(--green); border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      color: #fff; font-size: 0.9rem; font-weight: 700; cursor: pointer;
      transition: opacity 0.15s; border: 2px solid var(--green-dim);
    }
    .avatar:hover { opacity: 0.85; }
    .btn-logout {
      padding: 8px 20px; background: none; border: 1.5px solid var(--border);
      border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif;
      font-size: 0.86rem; font-weight: 600; color: var(--muted);
      cursor: pointer; transition: border-color 0.18s, color 0.18s;
    }
    .btn-logout:hover { border-color: var(--error); color: var(--error); }
    /* ── Session Timer ── */
    .session-timer {
      display: flex; align-items: center; gap: 7px;
      padding: 7px 14px; border-radius: var(--radius-sm);
      font-family: 'DM Sans', sans-serif; font-size: 0.84rem; font-weight: 700;
      border: 1.5px solid var(--green-dim); color: var(--green);
      background: var(--green-pale); letter-spacing: 0.02em;
      transition: background 0.4s, color 0.4s, border-color 0.4s;
      min-width: 90px; justify-content: center;
    }
    .session-timer.warn  { background: #fff8e1; border-color: #ffe082; color: #e65100; }
    .session-timer.danger{ background: #fdecea; border-color: #f5c6c2; color: #c0392b; }
    .timer-icon { font-size: 0.95rem; }

    /* ── Page ── */
    .page-body { padding: 40px 48px; max-width: 2400px; margin: 0 auto; }
    .page-title    { font-family: 'Playfair Display', serif; font-size: 2rem; font-weight: 500; margin-bottom: 6px; }
    .page-subtitle { font-size: 0.95rem; color: var(--muted); margin-bottom: 36px; }

    /* ── Period toggle ── */
    .summary-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; flex-wrap: wrap; gap: 12px; }
    .summary-title  { font-size: 0.82rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); }
    .period-toggle  { display: flex; background: #ece9e2; border-radius: 9px; padding: 4px; gap: 4px; }
    .period-btn { padding: 7px 18px; background: none; border: none; font-family: 'DM Sans', sans-serif; font-size: 0.84rem; font-weight: 500; color: var(--muted); border-radius: 7px; cursor: pointer; transition: background 0.18s, color 0.18s; }
    .period-btn.active { background: var(--white); color: var(--green); font-weight: 600; box-shadow: 0 1px 6px rgba(30,50,38,0.10); }

    /* ── Summary cards ── */
    .summary-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 18px; margin-bottom: 32px; }
    .summary-card { background: var(--white); border-radius: var(--radius); border: 1px solid rgba(212,224,217,0.6); padding: 22px 24px; box-shadow: var(--shadow); transition: transform 0.15s, box-shadow 0.15s; }
    .summary-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
    .summary-card .s-label { font-size: 0.76rem; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); margin-bottom: 12px; }
    .summary-card .s-value { font-size: 2rem; font-weight: 700; color: var(--green); line-height: 1; }
    .summary-card .s-unit  { font-size: 0.78rem; color: var(--muted); margin-top: 6px; }

    /* ── Goal progress ── */
    .goals-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 18px; margin-bottom: 32px; }
    .goal-card  { background: var(--white); border-radius: var(--radius); border: 1px solid rgba(212,224,217,0.6); padding: 18px 22px; box-shadow: var(--shadow); }
    .goal-label { display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px; }
    .goal-name  { font-size: 0.78rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--muted); }
    .goal-nums  { font-size: 0.85rem; font-weight: 600; color: var(--ink); }
    .goal-nums span { color: var(--green); }
    .progress-track { height: 9px; background: var(--green-pale); border-radius: 99px; overflow: hidden; }
    .progress-fill  { height: 100%; border-radius: 99px; background: var(--green); transition: width 0.6s ease; }
    .progress-fill.over { background: var(--error); }

    /* ── Charts ── */
    .charts-section { margin-bottom: 32px; }
    .section-heading { font-family: 'Playfair Display', serif; font-size: 1.3rem; font-weight: 500; margin-bottom: 18px; display: flex; align-items: center; gap: 12px; }
    .section-heading::after { content: ''; flex: 1; height: 1px; background: var(--border); }
    .charts-grid-2 { display: grid; grid-template-columns: 2fr 1fr; gap: 22px; }
    .chart-card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); border: 1px solid rgba(212,224,217,0.6); padding: 24px 26px; }
    .chart-title  { font-size: 0.82rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--muted); margin-bottom: 16px; }
    .chart-canvas { width: 100% !important; height: 260px !important; }

    /* ── Main content grid ── */
    .content-grid { display: grid; grid-template-columns: 560px 1fr; gap: 26px; align-items: start; }

    /* ── Cards ── */
    .card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); border: 1px solid rgba(212,224,217,0.6); overflow: hidden; }
    .card-header { padding: 18px 26px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; }
    .card-header h2 { font-family: 'Playfair Display', serif; font-size: 1.2rem; font-weight: 500; }
    .count-badge { background: var(--green-pale); color: var(--green); font-size: 0.76rem; font-weight: 600; padding: 4px 12px; border-radius: 20px; border: 1px solid var(--green-dim); }
    .card-body { padding: 22px 26px; }

    /* ── Form elements ── */
    .field { margin-bottom: 14px; }
    .field-label { display: block; font-size: 0.76rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; color: var(--muted); margin-bottom: 6px; }
    .field-hint  { font-size: 0.76rem; color: var(--muted); margin-top: 4px; }

    /* ── Food groups ── */
    .food-group { background: var(--cream); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 14px; margin-bottom: 10px; }
    .food-group-title { font-size: 0.78rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 10px; display: flex; align-items: center; gap: 7px; }
    .food-row { display: flex; gap: 8px; align-items: center; margin-bottom: 8px; }
    .food-row select { flex: 1; font-size: 0.86rem; padding: 9px 11px; }
    .food-row input  { width: 85px; flex-shrink: 0; font-size: 0.86rem; padding: 9px 11px; }
    .gram-label { font-size: 0.76rem; color: var(--muted); flex-shrink: 0; }
    .btn-add-food { background: none; border: 1.5px dashed var(--green-dim); border-radius: var(--radius-sm); color: var(--green); font-family: 'DM Sans', sans-serif; font-size: 0.8rem; font-weight: 600; padding: 7px 14px; cursor: pointer; width: 100%; transition: background 0.15s; margin-top: 4px; }
    .btn-add-food:hover { background: var(--green-pale); }
    .btn-remove-row { background: #fce4ec; border: none; border-radius: 6px; color: #c62828; font-size: 0.76rem; font-weight: 600; padding: 7px 9px; cursor: pointer; flex-shrink: 0; font-family: 'DM Sans', sans-serif; }
    .btn-remove-row:hover { opacity: 0.7; }

    /* ── Macro preview ── */
    .macro-preview { background: var(--green-pale); border: 1px solid var(--green-dim); border-radius: var(--radius-sm); padding: 14px 18px; margin-bottom: 14px; }
    .macro-preview-title { font-size: 0.74rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 12px; }
    .macro-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 10px; }
    .macro-item { text-align: center; }
    .macro-item .m-val { font-size: 1.3rem; font-weight: 700; color: var(--green); }
    .macro-item .m-lbl { font-size: 0.68rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.04em; margin-top: 3px; }
    .exercise-row { display: flex; gap: 9px; align-items: center; }
    .exercise-row select { flex: 1; }
    .exercise-row input  { width: 90px; flex-shrink: 0; }
    .exercise-burn { font-size: 0.84rem; color: var(--error); font-weight: 600; margin-top: 6px; min-height: 20px; }
    .section-divider { font-size: 0.73rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); display: flex; align-items: center; gap: 8px; margin: 16px 0 12px; }
    .section-divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }
    .btn-primary { width: 100%; padding: 13px; background: var(--green); color: #fff; border: none; border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.96rem; font-weight: 600; cursor: pointer; transition: background 0.18s, transform 0.1s; margin-top: 6px; letter-spacing: 0.02em; }
    .btn-primary:hover  { background: var(--green-light); }
    .btn-primary:active { transform: scale(0.99); }
    .btn-secondary { width: 100%; padding: 11px; background: none; color: var(--green); border: 1.5px solid var(--green-dim); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: background 0.18s; margin-top: 6px; }
    .btn-secondary:hover { background: var(--green-pale); }

    /* ── Table toolbar ── */
    .table-toolbar { display: flex; align-items: center; gap: 12px; padding: 16px 26px; border-bottom: 1px solid var(--border); flex-wrap: wrap; }
    .search-input { flex: 1; min-width: 160px; padding: 9px 14px; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.9rem; outline: none; transition: border-color 0.18s; width: auto; }
    .search-input:focus { border-color: var(--green); }
    .date-filter  { padding: 9px 14px; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.9rem; outline: none; background: var(--white); transition: border-color 0.18s; appearance: none; width: auto; }
    .date-filter:focus { border-color: var(--green); }
    .btn-filter-submit { padding: 9px 18px; background: var(--green); border: none; border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.86rem; font-weight: 600; color: #fff; cursor: pointer; white-space: nowrap; transition: background 0.18s; }
    .btn-filter-submit:hover { background: var(--green-light); }
    .btn-clear-filter { padding: 9px 14px; background: none; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.86rem; font-weight: 600; color: var(--muted); cursor: pointer; white-space: nowrap; transition: border-color 0.18s, color 0.18s; }
    .btn-clear-filter:hover { border-color: var(--green); color: var(--green); }

    /* ── Active filter indicator ── */
    .filter-active-bar { display: flex; align-items: center; gap: 8px; padding: 8px 26px; background: #f0fff4; border-bottom: 1px solid var(--green-dim); font-size: 0.82rem; color: var(--green); font-weight: 500; flex-wrap: wrap; }
    .filter-tag { display: inline-flex; align-items: center; gap: 5px; background: var(--green-pale); border: 1px solid var(--green-dim); border-radius: 20px; padding: 3px 10px; font-size: 0.78rem; font-weight: 600; color: var(--green); }

    /* ── Table ── */
    .table-wrap { overflow-x: auto; }
    table { width: 100%; border-collapse: collapse; font-size: 0.9rem; }
    thead th { background: var(--green); color: #fff; padding: 13px 16px; text-align: left; font-size: 0.74rem; font-weight: 600; letter-spacing: 0.05em; text-transform: uppercase; white-space: nowrap; }
    /* ── Sortable column headers ── */
    thead th.sortable { cursor: pointer; user-select: none; transition: background 0.15s; position: relative; padding-right: 28px; }
    thead th.sortable:hover { background: #2f6147; }
    thead th.sortable .sort-arrow { position: absolute; right: 10px; top: 50%; transform: translateY(-50%); font-size: 0.7rem; opacity: 0.45; }
    thead th.sortable.sort-active { background: #2a5740; }
    thead th.sortable.sort-active .sort-arrow { opacity: 1; }
    tbody td { padding: 13px 16px; border-bottom: 1px solid #f0f4f2; color: var(--ink); vertical-align: middle; white-space: nowrap; }
    tbody tr:last-child td { border-bottom: none; }
    tbody tr:nth-child(even) td { background: #f9fbfa; }
    tbody tr:hover td { background: var(--green-pale); transition: background 0.15s; }
    tbody .edit-row td { background: #fffdf5 !important; }

    .meal-type-badge { display: inline-block; padding: 4px 11px; border-radius: 12px; font-size: 0.74rem; font-weight: 600; text-transform: capitalize; }
    .badge-breakfast { background: #fff8e1; color: #f57f17; }
    .badge-lunch     { background: #e8f5e9; color: #2e7d32; }
    .badge-dinner    { background: #ede7f6; color: #4527a0; }
    .badge-snack     { background: #fce4ec; color: #880e4f; }

    .btn-edit { padding: 5px 12px; font-size: 0.78rem; font-weight: 600; border: none; border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: #fff3e0; color: #e65100; margin-right: 6px; transition: opacity 0.15s; }
    .btn-del  { padding: 5px 12px; font-size: 0.78rem; font-weight: 600; border: none; border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: #fce4ec; color: #c62828; transition: opacity 0.15s; }
    .btn-edit:hover, .btn-del:hover { opacity: 0.7; }

    .edit-row input, .edit-row select { width: 100%; padding: 6px 9px; font-size: 0.84rem; border: 1.5px solid var(--green-dim); border-radius: 6px; font-family: 'DM Sans', sans-serif; outline: none; min-width: 75px; appearance: none; }
    .edit-row select { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='%236b7a72' stroke-width='2.5'%3E%3Cpolyline points='6 9 12 15 18 9'/%3E%3C/svg%3E"); background-repeat: no-repeat; background-position: right 8px center; padding-right: 24px; }
    .edit-row input:focus, .edit-row select:focus { border-color: var(--green); }
    .btn-save   { padding: 5px 12px; font-size: 0.78rem; font-weight: 600; border: 1px solid var(--green-dim); border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: var(--green-pale); color: var(--green); margin-right: 4px; }
    .btn-cancel { padding: 5px 12px; font-size: 0.78rem; font-weight: 600; border: 1px solid #ddd; border-radius: 6px; cursor: pointer; font-family: 'DM Sans', sans-serif; background: #f0f0f0; color: #555; }
    .btn-save:hover   { background: #d2eddf; }
    .btn-cancel:hover { background: #e0e0e0; }

    /* ── Pagination ── */
    .pagination { display: flex; align-items: center; justify-content: space-between; padding: 16px 26px; border-top: 1px solid var(--border); flex-wrap: wrap; gap: 10px; }
    .page-info  { font-size: 0.86rem; color: var(--muted); }
    .page-btns  { display: flex; gap: 7px; }
    .page-btn   { padding: 7px 14px; font-size: 0.84rem; font-weight: 600; border: 1.5px solid var(--border); border-radius: 6px; background: var(--white); color: var(--ink); cursor: pointer; font-family: 'DM Sans', sans-serif; transition: all 0.15s; }
    .page-btn:hover    { border-color: var(--green); color: var(--green); }
    .page-btn.active   { background: var(--green); color: #fff; border-color: var(--green); }
    .page-btn:disabled { opacity: 0.4; cursor: not-allowed; }

    /* ── Weight Estimation ── */
    .est-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 18px; margin-bottom: 22px; }
    .est-card { background: var(--white); border-radius: var(--radius); border: 1px solid rgba(212,224,217,0.6); padding: 18px 22px; box-shadow: var(--shadow); }
    .est-card .e-label { font-size: 0.74rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); margin-bottom: 10px; }
    .est-card .e-value { font-size: 1.7rem; font-weight: 700; line-height: 1; }
    .est-card .e-unit  { font-size: 0.76rem; color: var(--muted); margin-top: 5px; }
    .e-green  { color: var(--green); }
    .e-red    { color: var(--error); }
    .e-orange { color: #e65100; }

    .advice-box { border-radius: var(--radius-sm); padding: 16px 20px; margin-bottom: 22px; }
    .advice-box.lose     { background: #e3f2fd; border: 1px solid #90caf9; color: #1565c0; }
    .advice-box.gain     { background: var(--success-bg); border: 1px solid #b7e4c7; color: var(--success); }
    .advice-box.maintain { background: var(--green-pale); border: 1px solid var(--green-dim); color: var(--green); }
    .advice-box.warning  { background: #fff8e1; border: 1px solid #ffe082; color: #e65100; }
    .advice-title { font-size: 0.82rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; margin-bottom: 7px; }
    .advice-text  { font-size: 0.9rem; line-height: 1.6; }

    .est-bottom-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 22px; }
    .target-calc { background: var(--cream); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 18px; margin-bottom: 16px; }
    .target-calc-title { font-size: 0.78rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 14px; }
    .target-inputs { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; align-items: end; margin-bottom: 14px; }
    .target-result { border-radius: var(--radius-sm); padding: 13px 16px; font-size: 0.9rem; font-weight: 500; line-height: 1.6; display: none; }
    .target-result.show { display: block; }
    .target-result.positive { background: var(--success-bg); color: var(--success); border: 1px solid #b7e4c7; }
    .target-result.negative { background: var(--error-bg); color: var(--error); border: 1px solid #f5c6c2; }
    .target-result.neutral  { background: var(--green-pale); color: var(--green); border: 1px solid var(--green-dim); }

    .intake-adjuster { background: var(--green-pale); border: 1px solid var(--green-dim); border-radius: var(--radius-sm); padding: 16px 18px; }
    .intake-adjuster-title { font-size: 0.78rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 12px; }
    .slider-row { display: flex; align-items: center; gap: 14px; margin-bottom: 12px; }
    .slider-row input[type="range"] { flex: 1; accent-color: var(--green); }
    .slider-val { font-size: 0.94rem; font-weight: 700; color: var(--green); min-width: 75px; text-align: right; }
    .slider-result { font-size: 0.88rem; color: var(--ink); line-height: 1.6; }

    /* ── Profile modal ── */
    .modal-overlay { position: fixed; inset: 0; background: rgba(20,35,28,0.45); z-index: 500; display: flex; align-items: center; justify-content: center; padding: 24px; backdrop-filter: blur(2px); overflow-y: auto; }
    .modal-overlay.hidden { display: none; }
    .modal { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow-lg); width: 100%; max-width: 560px; overflow: hidden; animation: modalIn 0.2s ease; }
    @keyframes modalIn { from { opacity:0; transform: translateY(-14px); } to { opacity:1; transform: translateY(0); } }
    .modal-header { padding: 22px 28px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; }
    .modal-header h3 { font-family: 'Playfair Display', serif; font-size: 1.25rem; font-weight: 500; }
    .modal-close { background: none; border: none; cursor: pointer; color: var(--muted); font-size: 1.3rem; padding: 4px; line-height: 1; transition: color 0.15s; }
    .modal-close:hover { color: var(--error); }
    .modal-body { padding: 26px 28px; max-height: 80vh; overflow-y: auto; }
    .modal-tabs { display: flex; background: var(--cream); border-radius: var(--radius-sm); padding: 4px; gap: 4px; margin-bottom: 22px; }
    .modal-tab  { flex: 1; padding: 9px; background: none; border: none; font-family: 'DM Sans', sans-serif; font-size: 0.86rem; font-weight: 500; color: var(--muted); border-radius: 6px; cursor: pointer; transition: background 0.18s, color 0.18s; }
    .modal-tab.active { background: var(--white); color: var(--green); font-weight: 600; box-shadow: 0 1px 6px rgba(30,50,38,0.10); }
    .modal-pane { display: none; }
    .modal-pane.active { display: block; }
    .profile-avatar { width: 64px; height: 64px; background: var(--green); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 1.5rem; font-weight: 700; margin: 0 auto 20px; border: 3px solid var(--green-dim); }
    .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
    .auto-calc-box { background: var(--green-pale); border: 1px solid var(--green-dim); border-radius: var(--radius-sm); padding: 16px; margin-bottom: 16px; }
    .auto-calc-title { font-size: 0.76rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 12px; }

    /* ── Setup modal ── */
    .setup-overlay { position: fixed; inset: 0; background: rgba(10,20,15,0.72); z-index: 900; display: flex; align-items: center; justify-content: center; padding: 24px; backdrop-filter: blur(4px); }
    .setup-overlay.hidden { display: none; }
    .setup-modal { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow-lg); width: 100%; max-width: 520px; overflow: hidden; animation: modalIn 0.25s ease; }
    .setup-header { padding: 26px 30px 22px; border-bottom: 1px solid var(--border); }
    .setup-header h2 { font-family: 'Playfair Display', serif; font-size: 1.5rem; font-weight: 500; margin-bottom: 5px; }
    .setup-header p  { font-size: 0.9rem; color: var(--muted); }
    .setup-body  { padding: 24px 30px; }
    .setup-footer { padding: 0 30px 26px; }
    .bmi-box { border-radius: var(--radius-sm); padding: 16px 18px; margin-top: 18px; display: none; }
    .bmi-box.show        { display: block; }
    .bmi-box.underweight { background: #e3f2fd; border: 1px solid #90caf9; color: #1565c0; }
    .bmi-box.normal      { background: var(--success-bg); border: 1px solid #b7e4c7; color: var(--success); }
    .bmi-box.overweight  { background: #fff8e1; border: 1px solid #ffe082; color: #e65100; }
    .bmi-box.obese       { background: var(--error-bg); border: 1px solid #f5c6c2; color: var(--error); }
    .bmi-val { font-size: 1.7rem; font-weight: 700; line-height: 1; margin-bottom: 4px; }
    .bmi-cat { font-size: 0.84rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
    .bmi-tip { font-size: 0.86rem; margin-top: 9px; line-height: 1.5; }
    .goal-type-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 10px; margin-top: 16px; }
    .goal-type-btn  { padding: 12px 10px; text-align: center; border: 1.5px solid var(--border); border-radius: var(--radius-sm); cursor: pointer; background: var(--white); font-family: 'DM Sans', sans-serif; font-size: 0.86rem; font-weight: 600; color: var(--muted); transition: all 0.18s; }
    .goal-type-btn:hover    { border-color: var(--green); color: var(--green); }
    .goal-type-btn.selected { background: var(--green-pale); border-color: var(--green); color: var(--green); }
    .goal-type-btn .gt-icon { font-size: 1.4rem; display: block; margin-bottom: 5px; }

    .no-data { text-align: center; color: var(--muted); padding: 60px 0; font-size: 0.96rem; }
    .no-data svg { width: 40px; height: 40px; stroke: var(--border); fill: none; stroke-width: 1.5; display: block; margin: 0 auto 12px; }

    /* ── Responsive ── */
    @media (max-width: 1600px) { .content-grid { grid-template-columns: 480px 1fr; } .est-grid { grid-template-columns: repeat(3,1fr); } }
    @media (max-width: 1280px) { .content-grid { grid-template-columns: 1fr; } .charts-grid-2 { grid-template-columns: 1fr; } .summary-grid { grid-template-columns: repeat(3,1fr); } .goals-grid { grid-template-columns: repeat(2,1fr); } .est-bottom-grid { grid-template-columns: 1fr; } }
    @media (max-width: 900px)  { .navbar { padding: 0 20px; } .page-body { padding: 24px 20px; } .two-col { grid-template-columns: 1fr; } .target-inputs { grid-template-columns: 1fr; } .goal-type-grid { grid-template-columns: 1fr; } .summary-grid { grid-template-columns: repeat(2,1fr); } .est-grid { grid-template-columns: repeat(2,1fr); } }
  </style>
</head>
<body>

<%
  List<String[]> meals       = (List<String[]>) request.getAttribute("meals");
  String[]       userProfile = (String[])       request.getAttribute("userProfile");
  List<String[]> sevenDay    = (List<String[]>) request.getAttribute("sevenDay");
  List<String[]> foods       = (List<String[]>) request.getAttribute("foods");
  boolean        showSetup   = Boolean.TRUE.equals(request.getAttribute("showSetup"));

  // ── DSA state from controller (for retaining toolbar values) ──────
  String currentSortBy  = request.getAttribute("currentSortBy")  != null ? (String) request.getAttribute("currentSortBy")  : "";
  String currentSortDir = request.getAttribute("currentSortDir") != null ? (String) request.getAttribute("currentSortDir") : "desc";
  String currentSearch  = request.getAttribute("currentSearch")  != null ? (String) request.getAttribute("currentSearch")  : "";
  String currentDate    = request.getAttribute("currentDate")    != null ? (String) request.getAttribute("currentDate")    : "";

  // Helper: compute the next sort direction for a column link
  // If clicking the currently-active column → flip; otherwise → asc
  // (used below to build sort URLs)

  int mealCount = (meals != null) ? meals.size() : 0;
  String today  = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());

  int todayCalories=0; double todayProtein=0,todayCarbs=0,todayFats=0; int todayMeals=0;
  int totalCalories=0; double totalProtein=0,totalCarbs=0,totalFats=0;
  if (meals != null) {
    for (String[] m : meals) {
      try{totalCalories+=Integer.parseInt(m[3]);}catch(Exception e){}
      try{totalProtein+=Double.parseDouble(m[4]);}catch(Exception e){}
      try{totalCarbs+=Double.parseDouble(m[5]);}catch(Exception e){}
      try{totalFats+=Double.parseDouble(m[6]);}catch(Exception e){}
      if (m[7].equals(today)) {
        try{todayCalories+=Integer.parseInt(m[3]);}catch(Exception e){}
        try{todayProtein+=Double.parseDouble(m[4]);}catch(Exception e){}
        try{todayCarbs+=Double.parseDouble(m[5]);}catch(Exception e){}
        try{todayFats+=Double.parseDouble(m[6]);}catch(Exception e){}
        todayMeals++;
      }
    }
  }

  int goalCal=2000; double goalProtein=150,goalCarbs=250,goalFats=65;
  String profHeight="",profWeight="",profAge="",profGender="";
  if (userProfile!=null){
    profHeight=userProfile[0]; profWeight=userProfile[1]; profAge=userProfile[2]; profGender=userProfile[3];
    try{goalCal=Integer.parseInt(userProfile[4]);}catch(Exception e){}
    try{goalProtein=Double.parseDouble(userProfile[5]);}catch(Exception e){}
    try{goalCarbs=Double.parseDouble(userProfile[6]);}catch(Exception e){}
    try{goalFats=Double.parseDouble(userProfile[7]);}catch(Exception e){}
  }

  int pctCal     = goalCal>0     ? Math.min(100,(int)(todayCalories*100/goalCal))     : 0;
  int pctProtein = goalProtein>0 ? Math.min(100,(int)(todayProtein *100/goalProtein)) : 0;
  int pctCarbs   = goalCarbs>0   ? Math.min(100,(int)(todayCarbs   *100/goalCarbs))   : 0;
  int pctFats    = goalFats>0    ? Math.min(100,(int)(todayFats    *100/goalFats))    : 0;

  int sevenDayTotalCal=0, sevenDayCount=0;
  StringBuilder chartLabels=new StringBuilder(),chartCal=new StringBuilder();
  StringBuilder chartProtein=new StringBuilder(),chartCarbs=new StringBuilder(),chartFats=new StringBuilder();
  if (sevenDay!=null){
    for (int i=0;i<sevenDay.size();i++){
      String[] d=sevenDay.get(i); String sep=i<sevenDay.size()-1?",":"";
      chartLabels.append("'").append(d[0]).append("'").append(sep);
      chartCal.append(d[1]).append(sep); chartProtein.append(d[2]).append(sep);
      chartCarbs.append(d[3]).append(sep); chartFats.append(d[4]).append(sep);
      try{sevenDayTotalCal+=Integer.parseInt(d[1]);sevenDayCount++;}catch(Exception e){}
    }
  }
  int avgDailyCalories = sevenDayCount>0 ? sevenDayTotalCal/sevenDayCount : 0;

  // Group foods by category
  Map<String, List<String[]>> foodsByCategory = new LinkedHashMap<>();
  Map<String, String> catIcons = new LinkedHashMap<>();
  catIcons.put("Carbs & Grains",  "🍚");
  catIcons.put("Proteins & Meat", "🍗");
  catIcons.put("Vegetables",      "🥦");
  catIcons.put("Fruits",          "🍎");
  catIcons.put("Dairy",           "🥛");
  if (foods!=null){
    for (String[] f : foods){
      String cat=f[1];
      if (!foodsByCategory.containsKey(cat)) foodsByCategory.put(cat, new ArrayList<String[]>());
      foodsByCategory.get(cat).add(f);
    }
  }

  String userName  = (String) session.getAttribute("userName");
  String userEmail = (String) session.getAttribute("userEmail");
  String initials  = (userName!=null&&!userName.isEmpty()) ? String.valueOf(userName.charAt(0)).toUpperCase() : "U";
  boolean openProfile = Boolean.TRUE.equals(request.getAttribute("openProfile"));

  int diff = avgDailyCalories - goalCal;
  double weeklyKg = (diff * 7.0) / 7700.0;
  String diffColor = diff<0?"e-green":diff>0?"e-red":"e-orange";
  String diffSign  = diff>0?"+":"";
  String wkSign    = weeklyKg>0?"+":"";
  String wkColor   = weeklyKg<0?"e-green":weeklyKg>0?"e-red":"e-orange";

  String adviceClass, adviceTitle, adviceText;
  if (diff<-100){
    adviceClass="lose"; adviceTitle="You are in a calorie deficit";
    adviceText="At your current average intake of "+avgDailyCalories+" kcal/day, you are consuming "+Math.abs(diff)+" kcal less than your maintenance. You are on track to lose approximately "+String.format("%.2f",Math.abs(weeklyKg))+" kg per week. Keep your protein intake high to preserve muscle mass.";
  } else if (diff>100){
    adviceClass="gain"; adviceTitle="You are in a calorie surplus";
    adviceText="At your current average intake of "+avgDailyCalories+" kcal/day, you are consuming "+diff+" kcal more than your maintenance. You are on track to gain approximately "+String.format("%.2f",weeklyKg)+" kg per week. Pair this with resistance training for lean muscle gain.";
  } else if (avgDailyCalories==0){
    adviceClass="warning"; adviceTitle="No recent meal data";
    adviceText="You have not logged any meals in the past 7 days. Start logging your meals to get an accurate weight estimation and calorie analysis.";
  } else {
    adviceClass="maintain"; adviceTitle="You are at maintenance";
    adviceText="Your average daily intake of "+avgDailyCalories+" kcal is close to your maintenance level. Your weight is likely to remain stable. Adjust your intake up or down depending on your goal.";
  }

  // Build valid food names list for JS validation
  StringBuilder validFoodNamesJs = new StringBuilder();
  if (foods != null) {
    for (int i = 0; i < foods.size(); i++) {
      validFoodNamesJs.append("\"").append(foods.get(i)[0].toLowerCase().replace("\"","\\\"")).append("\"");
      if (i < foods.size() - 1) validFoodNamesJs.append(",");
    }
  }

  // ── Helper: build sort URL preserving current search/date filters ──
  // flipDir(col): if col == currentSortBy → flip currentSortDir, else "asc"
  java.util.function.Function<String,String> flipDir = col -> {
    if (col.equals(currentSortBy)) {
      return "desc".equals(currentSortDir) ? "asc" : "desc";
    }
    return "asc";
  };
  // base URL fragment reused for each sort link
  String filterFragment = "search=" + java.net.URLEncoder.encode(currentSearch,"UTF-8")
                        + "&dateFilter=" + java.net.URLEncoder.encode(currentDate,"UTF-8");
  String ctx = request.getContextPath();

  // Arrow chars for currently sorted column
  java.util.function.Function<String,String> arrowFor = col -> {
    if (!col.equals(currentSortBy)) return "↕";
    return "desc".equals(currentSortDir) ? "↓" : "↑";
  };
%>

<!-- Hidden forms -->
<form class="hidden-form" id="delete-form" action="dashboard" method="post">
  <input type="hidden" name="action" value="delete"/>
  <input type="hidden" name="id"     id="delete-id"/>
</form>
<form class="hidden-form" id="update-form" action="dashboard" method="post">
  <input type="hidden" name="action"    value="update"/>
  <input type="hidden" name="id"        id="update-id"/>
  <input type="hidden" name="meal_type" id="update-meal_type"/>
  <input type="hidden" name="meal_name" id="update-meal_name"/>
  <input type="hidden" name="calories"  id="update-calories"/>
  <input type="hidden" name="protein"   id="update-protein"/>
  <input type="hidden" name="carbs"     id="update-carbs"/>
  <input type="hidden" name="fats"      id="update-fats"/>
  <input type="hidden" name="meal_date" id="update-meal_date"/>
</form>
<form class="hidden-form" id="logout-form" action="dashboard" method="post">
  <input type="hidden" name="action" value="logout"/>
</form>

<!-- ══ SETUP MODAL ══ -->
<div class="setup-overlay <%= showSetup?"":"hidden" %>" id="setupOverlay">
  <div class="setup-modal">
    <div class="setup-header">
      <h2>Welcome to MealLog &#127807;</h2>
      <p>Let's personalise your nutrition goals before you get started.</p>
    </div>
    <div class="setup-body">
      <% if (request.getAttribute("setupErr")!=null){ %><div class="banner error">&#9888; <%= request.getAttribute("setupErr") %></div><% } %>
      <form action="dashboard" method="post" id="setupForm">
        <input type="hidden" name="action"    value="setup"/>
        <input type="hidden" name="goal_type" id="setup-goal-type" value="maintain"/>
        <div class="two-col">
          <div class="field"><label class="field-label">Weight (kg)</label><input type="number" name="weight_kg" id="setup-weight" placeholder="e.g. 70" min="20" max="300" step="0.1" oninput="calcBMI()"/></div>
          <div class="field"><label class="field-label">Height (cm)</label><input type="number" name="height_cm" id="setup-height" placeholder="e.g. 175" min="100" max="250" step="0.1" oninput="calcBMI()"/></div>
        </div>
        <div class="two-col">
          <div class="field"><label class="field-label">Age</label><input type="number" name="age" id="setup-age" placeholder="e.g. 22" min="10" max="100"/></div>
          <div class="field"><label class="field-label">Gender</label><select name="gender" id="setup-gender"><option value="male">Male</option><option value="female">Female</option></select></div>
        </div>
        <div class="bmi-box" id="bmi-box">
          <div class="bmi-val" id="bmi-val"></div>
          <div class="bmi-cat" id="bmi-cat"></div>
          <div class="bmi-tip" id="bmi-tip"></div>
        </div>
        <div class="field" style="margin-top:18px;">
          <label class="field-label">What is your goal?</label>
          <div class="goal-type-grid">
            <div class="goal-type-btn" id="gt-lose"     onclick="selectGoal('lose')"><span class="gt-icon">&#128168;</span>Lose Weight</div>
            <div class="goal-type-btn selected" id="gt-maintain" onclick="selectGoal('maintain')"><span class="gt-icon">&#9889;</span>Maintain</div>
            <div class="goal-type-btn" id="gt-gain"     onclick="selectGoal('gain')"><span class="gt-icon">&#128170;</span>Gain Weight</div>
          </div>
        </div>
      </form>
    </div>
    <div class="setup-footer">
      <button type="button" class="btn-primary" onclick="submitSetup()">Set My Goals &amp; Get Started &#10140;</button>
      <button type="button" class="btn-secondary" onclick="document.getElementById('setupOverlay').classList.add('hidden')" style="margin-top:10px;">Skip for now</button>
    </div>
  </div>
</div>

<!-- ══ PROFILE MODAL ══ -->
<div class="modal-overlay <%= openProfile?"":"hidden" %>" id="profileModal">
  <div class="modal">
    <div class="modal-header">
      <h3>My Profile</h3>
      <button type="button" class="modal-close" onclick="closeProfile()">&#10005;</button>
    </div>
    <div class="modal-body">
      <div class="profile-avatar"><%= initials %></div>
      <% if (request.getAttribute("profileSuccess")!=null){ %><div class="banner success" style="margin-bottom:16px;">&#10003; <%= request.getAttribute("profileSuccess") %></div><% } %>
      <% if (request.getAttribute("profileErr")!=null){     %><div class="banner error"   style="margin-bottom:16px;">&#9888; <%= request.getAttribute("profileErr") %></div><% } %>
      <div class="modal-tabs">
        <button class="modal-tab active" onclick="switchTab('account')">Account</button>
        <button class="modal-tab"        onclick="switchTab('body')">Body &amp; Goals</button>
      </div>
      <div class="modal-pane active" id="pane-account">
        <form action="dashboard" method="post">
          <input type="hidden" name="action"       value="update_profile"/>
          <input type="hidden" name="height_cm"    value="<%= profHeight %>"/>
          <input type="hidden" name="weight_kg"    value="<%= profWeight %>"/>
          <input type="hidden" name="age"          value="<%= profAge %>"/>
          <input type="hidden" name="gender"       value="<%= profGender %>"/>
          <input type="hidden" name="calorie_goal" value="<%= goalCal %>"/>
          <input type="hidden" name="protein_goal" value="<%= goalProtein %>"/>
          <input type="hidden" name="carbs_goal"   value="<%= goalCarbs %>"/>
          <input type="hidden" name="fats_goal"    value="<%= goalFats %>"/>
          <div class="field"><label class="field-label">Full Name</label><input type="text"  name="full_name" value="<%= userName!=null?userName:"" %>"/></div>
          <div class="field"><label class="field-label">Email</label>    <input type="email" name="email"     value="<%= userEmail!=null?userEmail:"" %>"/></div>
          <div class="section-divider">Change Password</div>
          <div class="field"><label class="field-label">New Password</label><input type="password" name="password" placeholder="Leave blank to keep current"/><div class="field-hint">Min 6 characters.</div></div>
          <div class="field"><label class="field-label">Confirm</label>     <input type="password" name="confirm"  placeholder="Repeat new password"/></div>
          <button type="submit" class="btn-primary">Save Account</button>
        </form>
      </div>
      <div class="modal-pane" id="pane-body">
        <div class="auto-calc-box">
          <div class="auto-calc-title">&#127919; Auto-Calculate Goals</div>
          <form action="dashboard" method="post">
            <input type="hidden" name="action" value="auto_goals"/>
            <div class="two-col">
              <div class="field" style="margin-bottom:0;"><label class="field-label">Weight (kg)</label><input type="number" name="weight_kg" step="0.1" value="<%= profWeight %>"/></div>
              <div class="field" style="margin-bottom:0;"><label class="field-label">Height (cm)</label><input type="number" name="height_cm" step="0.1" value="<%= profHeight %>"/></div>
            </div>
            <div class="two-col" style="margin-top:12px;">
              <div class="field" style="margin-bottom:0;"><label class="field-label">Age</label><input type="number" name="age" value="<%= profAge %>"/></div>
              <div class="field" style="margin-bottom:0;"><label class="field-label">Gender</label><select name="gender"><option value="male" <%= "male".equals(profGender)?"selected":"" %>>Male</option><option value="female" <%= "female".equals(profGender)?"selected":"" %>>Female</option></select></div>
            </div>
            <div class="field" style="margin-top:12px;"><label class="field-label">Goal</label><select name="goal_type"><option value="maintain">Maintain</option><option value="lose">Lose Weight</option><option value="gain">Gain Weight</option></select></div>
            <button type="submit" class="btn-secondary" style="margin-top:6px;">&#9889; Calculate &amp; Set Goals</button>
          </form>
        </div>
        <form action="dashboard" method="post">
          <input type="hidden" name="action"    value="update_profile"/>
          <input type="hidden" name="full_name" value="<%= userName!=null?userName:"" %>"/>
          <input type="hidden" name="email"     value="<%= userEmail!=null?userEmail:"" %>"/>
          <input type="hidden" name="password"  value=""/>
          <input type="hidden" name="confirm"   value=""/>
          <div class="section-divider">Body Stats</div>
          <div class="two-col">
            <div class="field"><label class="field-label">Height (cm)</label><input type="number" name="height_cm" step="0.1" value="<%= profHeight %>"/></div>
            <div class="field"><label class="field-label">Weight (kg)</label><input type="number" name="weight_kg" step="0.1" value="<%= profWeight %>"/></div>
          </div>
          <div class="two-col">
            <div class="field"><label class="field-label">Age</label><input type="number" name="age" value="<%= profAge %>"/></div>
            <div class="field"><label class="field-label">Gender</label><select name="gender"><option value="male" <%= "male".equals(profGender)?"selected":"" %>>Male</option><option value="female" <%= "female".equals(profGender)?"selected":"" %>>Female</option></select></div>
          </div>
          <div class="section-divider">Daily Targets</div>
          <div class="two-col">
            <div class="field"><label class="field-label">Calories (kcal)</label><input type="number" name="calorie_goal" value="<%= goalCal %>"/></div>
            <div class="field"><label class="field-label">Protein (g)</label>    <input type="number" name="protein_goal" step="0.1" value="<%= goalProtein %>"/></div>
          </div>
          <div class="two-col">
            <div class="field"><label class="field-label">Carbs (g)</label><input type="number" name="carbs_goal" step="0.1" value="<%= goalCarbs %>"/></div>
            <div class="field"><label class="field-label">Fats (g)</label> <input type="number" name="fats_goal"  step="0.1" value="<%= goalFats %>"/></div>
          </div>
          <button type="submit" class="btn-primary">Save Body &amp; Goals</button>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Navbar -->
<nav class="navbar">
  <div class="brand-bar">
    <div class="brand-icon"><svg viewBox="0 0 24 24"><path d="M3 11l19-9-9 19-2-8-8-2z"/></svg></div>
    <div class="brand-name">Meal<span>Log</span></div>
  </div>
  <div class="nav-right">
    <span class="nav-user">Hello, <strong><%= userName!=null?userName:"User" %></strong></span>
    <div class="session-timer" id="session-timer">
      <span class="timer-icon">&#9201;</span>
      <span id="timer-display">5:00</span>
    </div>
    <a href="about" style="font-size:0.86rem;font-weight:600;color:var(--green);text-decoration:none;padding:8px 14px;border:1.5px solid var(--green-dim);border-radius:var(--radius-sm);transition:background 0.18s;" onmouseover="this.style.background='var(--green-pale)'" onmouseout="this.style.background='none'">About</a>
    <div class="avatar" onclick="openProfileModal()" title="Edit Profile"><%= initials %></div>
    <button class="btn-logout" onclick="document.getElementById('logout-form').submit()">Sign Out</button>
  </div>
</nav>

<div class="page-body">

  <div class="page-title">My Meal Log</div>
  <div class="page-subtitle">Track your daily nutrition and stay on top of your goals</div>

  <% if (request.getAttribute("successMsg")!=null){ %><div class="banner success">&#10003; <%= request.getAttribute("successMsg") %></div><% } %>
  <% if (request.getAttribute("errorMsg")!=null){   %><div class="banner error">&#9888; <%= request.getAttribute("errorMsg") %></div><% } %>

  <!-- Summary -->
  <div class="summary-header">
    <div class="summary-title">Nutrition Overview</div>
    <div class="period-toggle">
      <button class="period-btn active" id="btn-today"   onclick="setPeriod('today')">Today</button>
      <button class="period-btn"        id="btn-alltime" onclick="setPeriod('alltime')">All Time</button>
    </div>
  </div>
  <div class="summary-grid">
    <div class="summary-card"><div class="s-label">Meals</div>    <div class="s-value" id="sum-meals"><%= todayMeals %></div>                            <div class="s-unit">logged today</div></div>
    <div class="summary-card"><div class="s-label">Calories</div> <div class="s-value" id="sum-cal"><%= todayCalories %></div>                           <div class="s-unit">kcal</div></div>
    <div class="summary-card"><div class="s-label">Protein</div>  <div class="s-value" id="sum-protein"><%= String.format("%.1f",todayProtein) %></div> <div class="s-unit">grams</div></div>
    <div class="summary-card"><div class="s-label">Carbs</div>    <div class="s-value" id="sum-carbs"><%= String.format("%.1f",todayCarbs) %></div>     <div class="s-unit">grams</div></div>
    <div class="summary-card"><div class="s-label">Fats</div>     <div class="s-value" id="sum-fats"><%= String.format("%.1f",todayFats) %></div>       <div class="s-unit">grams</div></div>
  </div>

  <!-- Goal progress -->
  <div class="section-heading">Today's Goal Progress</div>
  <div class="goals-grid">
    <div class="goal-card">
      <div class="goal-label"><span class="goal-name">&#128293; Calories</span><span class="goal-nums"><span><%= todayCalories %></span> / <%= goalCal %> kcal</span></div>
      <div class="progress-track"><div class="progress-fill <%= todayCalories>goalCal?"over":"" %>" style="width:<%= pctCal %>%"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-label"><span class="goal-name">&#128167; Protein</span><span class="goal-nums"><span><%= String.format("%.1f",todayProtein) %></span> / <%= String.format("%.0f",goalProtein) %>g</span></div>
      <div class="progress-track"><div class="progress-fill <%= todayProtein>goalProtein?"over":"" %>" style="width:<%= pctProtein %>%"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-label"><span class="goal-name">&#127858; Carbs</span><span class="goal-nums"><span><%= String.format("%.1f",todayCarbs) %></span> / <%= String.format("%.0f",goalCarbs) %>g</span></div>
      <div class="progress-track"><div class="progress-fill <%= todayCarbs>goalCarbs?"over":"" %>" style="width:<%= pctCarbs %>%"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-label"><span class="goal-name">&#129368; Fats</span><span class="goal-nums"><span><%= String.format("%.1f",todayFats) %></span> / <%= String.format("%.0f",goalFats) %>g</span></div>
      <div class="progress-track"><div class="progress-fill <%= todayFats>goalFats?"over":"" %>" style="width:<%= pctFats %>%"></div></div>
    </div>
  </div>

  <!-- 7-day charts -->
  <div class="charts-section">
    <div class="section-heading">Last 7 Days</div>
    <div class="charts-grid-2">
      <div class="chart-card"><div class="chart-title">Calorie Intake vs Goal</div><canvas id="calChart" class="chart-canvas"></canvas></div>
      <div class="chart-card"><div class="chart-title">Macros Breakdown</div>      <canvas id="macroChart" class="chart-canvas"></canvas></div>
    </div>
  </div>

  <!-- Main content grid -->
  <div class="content-grid">

    <!-- Log meal form -->
    <div class="card">
      <div class="card-header"><h2>Log a Meal</h2></div>
      <div class="card-body">
        <form action="dashboard" method="post" id="mealForm" onsubmit="return prepareSubmit()">
          <input type="hidden" name="action"    value="create"/>
          <input type="hidden" name="meal_name" id="hid-meal_name"/>
          <input type="hidden" name="calories"  id="hid-calories"/>
          <input type="hidden" name="protein"   id="hid-protein"/>
          <input type="hidden" name="carbs"     id="hid-carbs"/>
          <input type="hidden" name="fats"      id="hid-fats"/>

          <div class="field">
            <label class="field-label">Meal Type</label>
            <select name="meal_type">
              <option value="">— Select type —</option>
              <option value="Breakfast">Breakfast</option>
              <option value="Lunch">Lunch</option>
              <option value="Dinner">Dinner</option>
              <option value="Snack">Snack</option>
              <option value="Other">Other</option>
            </select>
          </div>
          <div class="field"><label class="field-label">Date</label><input type="date" name="meal_date"/></div>

          <%-- Dynamic food groups from DB --%>
          <%
            for (Map.Entry<String, List<String[]>> entry : foodsByCategory.entrySet()) {
              String cat    = entry.getKey();
              String catKey = cat.replaceAll("[^a-zA-Z0-9]","_");
              String icon   = catIcons.containsKey(cat) ? catIcons.get(cat) : "🍴";
          %>
          <div class="food-group">
            <div class="food-group-title"><span><%= icon %></span> <%= cat.replace("&","&amp;") %></div>
            <div id="group-<%= catKey %>"></div>
            <button type="button" class="btn-add-food" onclick="addRow('<%= catKey %>','<%= cat.replace("'","\\'").replace("\"","&quot;") %>')">+ Add item</button>
          </div>
          <% } %>

          <% if (foodsByCategory.isEmpty()) { %>
          <div class="banner error" style="margin-bottom:14px;">&#9888; No food items in the database. Ask your admin to add some.</div>
          <% } %>

          <div class="section-divider">Exercise</div>
          <div class="field">
            <label class="field-label">Activity &amp; Duration</label>
            <div class="exercise-row">
              <select id="exercise-type" onchange="updateBurn()">
                <option value="0">— No exercise —</option>
                <option value="10">Running</option>
                <option value="8">Cycling</option>
                <option value="4">Walking</option>
                <option value="9">Swimming</option>
                <option value="12">HIIT</option>
                <option value="6">Gym / Weights</option>
                <option value="8">Football</option>
                <option value="3">Yoga</option>
              </select>
              <input type="number" id="exercise-mins" placeholder="mins" min="0" oninput="updateBurn()"/>
              <span class="gram-label">min</span>
            </div>
            <div class="exercise-burn" id="burn-display"></div>
          </div>

          <div class="section-divider">Nutrition Summary</div>
          <div class="macro-preview">
            <div class="macro-preview-title">Calculated Totals (after exercise)</div>
            <div class="macro-grid">
              <div class="macro-item"><div class="m-val" id="prev-cal">0</div><div class="m-lbl">kcal</div></div>
              <div class="macro-item"><div class="m-val" id="prev-protein">0</div><div class="m-lbl">protein g</div></div>
              <div class="macro-item"><div class="m-val" id="prev-carbs">0</div><div class="m-lbl">carbs g</div></div>
              <div class="macro-item"><div class="m-val" id="prev-fats">0</div><div class="m-lbl">fats g</div></div>
            </div>
          </div>
          <button type="submit" class="btn-primary">+ Log Meal</button>
        </form>
      </div>
    </div>

    <!-- ══ MEALS TABLE CARD ══ -->
    <div class="card">
      <div class="card-header">
        <h2>My Meals</h2>
        <span class="count-badge" id="visible-count"><%= mealCount %> meal<%= mealCount!=1?"s":"" %></span>
      </div>

      <%-- ── Server-side search + date filter form ── --%>
      <form method="get" action="dashboard" id="filter-form">
        <%-- Preserve current sort when re-filtering --%>
        <input type="hidden" name="sortBy"  value="<%= currentSortBy %>"/>
        <input type="hidden" name="sortDir" value="<%= currentSortDir %>"/>
        <div class="table-toolbar">
          <input  type="text"
                  class="search-input"
                  name="search"
                  id="search-input"
                  placeholder="&#128269; Search meals..."
                  value="<%= currentSearch.replace("\"","&quot;") %>"/>
          <input  type="date"
                  class="date-filter"
                  name="dateFilter"
                  id="date-filter"
                  value="<%= currentDate %>"/>
          <button type="submit" class="btn-filter-submit">Search</button>
          <button type="button" class="btn-clear-filter" onclick="clearFilters()">Clear</button>
        </div>
      </form>

      <%-- Active-filter indicator bar --%>
      <% boolean hasActiveFilter = !currentSearch.isEmpty() || !currentDate.isEmpty() || !currentSortBy.isEmpty(); %>
      <% if (hasActiveFilter) { %>
      <div class="filter-active-bar">
        <span style="font-weight:700;">Active:</span>
        <% if (!currentSearch.isEmpty()) { %>
          <span class="filter-tag">&#128269; "<%= currentSearch %>"</span>
        <% } %>
        <% if (!currentDate.isEmpty()) { %>
          <span class="filter-tag">&#128197; <%= currentDate %></span>
        <% } %>
        <% if (!currentSortBy.isEmpty()) { %>
          <span class="filter-tag">&#8645; <%= currentSortBy %> (<%= currentSortDir %>)</span>
        <% } %>
      </div>
      <% } %>

      <% if (meals==null||meals.isEmpty()) { %>
        <div class="no-data">
          <svg viewBox="0 0 24 24"><path d="M3 3h18v18H3z" stroke-dasharray="4 2"/><path d="M12 8v4M12 16h.01"/></svg>
          <% if (!currentSearch.isEmpty() || !currentDate.isEmpty()) { %>
            No meals match your search. <a href="dashboard" style="color:var(--green);">Clear filters</a>
          <% } else { %>
            No meals logged yet. Add your first meal!
          <% } %>
        </div>
      <% } else { %>
        <div class="table-wrap">
          <table id="meals-table">
            <thead>
              <tr>
                <th>Type</th>
                <%-- Sortable: Meal Name --%>
                <th class="sortable <%= "date".equals(currentSortBy)?"":"" %>"
                    onclick="sortBy('date','<%= "date".equals(currentSortBy)?("desc".equals(currentSortDir)?"asc":"desc"):"asc" %>')">
                  Meal <span class="sort-arrow">↕</span>
                </th>
                <%-- Sortable: Calories --%>
                <th class="sortable <%= "cal".equals(currentSortBy)?"sort-active":"" %>"
                    onclick="sortBy('cal','<%= "cal".equals(currentSortBy)?("desc".equals(currentSortDir)?"asc":"desc"):"desc" %>')">
                  Kcal <span class="sort-arrow"><%= arrowFor.apply("cal") %></span>
                </th>
                <%-- Sortable: Protein --%>
                <th class="sortable <%= "protein".equals(currentSortBy)?"sort-active":"" %>"
                    onclick="sortBy('protein','<%= "protein".equals(currentSortBy)?("desc".equals(currentSortDir)?"asc":"desc"):"desc" %>')">
                  Protein <span class="sort-arrow"><%= arrowFor.apply("protein") %></span>
                </th>
                <%-- Sortable: Carbs --%>
                <th class="sortable <%= "carbs".equals(currentSortBy)?"sort-active":"" %>"
                    onclick="sortBy('carbs','<%= "carbs".equals(currentSortBy)?("desc".equals(currentSortDir)?"asc":"desc"):"desc" %>')">
                  Carbs <span class="sort-arrow"><%= arrowFor.apply("carbs") %></span>
                </th>
                <%-- Sortable: Fats --%>
                <th class="sortable <%= "fats".equals(currentSortBy)?"sort-active":"" %>"
                    onclick="sortBy('fats','<%= "fats".equals(currentSortBy)?("desc".equals(currentSortDir)?"asc":"desc"):"desc" %>')">
                  Fats <span class="sort-arrow"><%= arrowFor.apply("fats") %></span>
                </th>
                <%-- Sortable: Date --%>
                <th class="sortable <%= "date".equals(currentSortBy)?"sort-active":"" %>"
                    onclick="sortBy('date','<%= "date".equals(currentSortBy)?("desc".equals(currentSortDir)?"asc":"desc"):"desc" %>')">
                  Date <span class="sort-arrow"><%= arrowFor.apply("date") %></span>
                </th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody id="meals-tbody">
              <% for (String[] m : meals) {
                   String tl=m[1].toLowerCase(),bc="badge-other";
                   if(tl.equals("breakfast")) bc="badge-breakfast";
                   else if(tl.equals("lunch")) bc="badge-lunch";
                   else if(tl.equals("dinner")) bc="badge-dinner";
                   else if(tl.equals("snack")) bc="badge-snack";
              %>
              <tr id="row-<%= m[0] %>" data-date="<%= m[7] %>" data-name="<%= m[2].toLowerCase() %>">
                <td><span class="meal-type-badge <%= bc %>"><%= m[1].isEmpty()?"—":m[1] %></span></td>
                <td><strong><%= m[2].length()>45?m[2].substring(0,45)+"…":m[2] %></strong></td>
                <td><%= m[3] %></td><td><%= m[4] %>g</td><td><%= m[5] %>g</td><td><%= m[6] %>g</td>
                <td><%= m[7].isEmpty()?"—":m[7] %></td>
                <td>
                  <button class="btn-edit" onclick="startEdit('<%= m[0] %>')">&#9998; Edit</button>
                  <button class="btn-del"  onclick="doDelete('<%= m[0] %>','<%= m[2].replace("'","\\'") %>')">&#128465;</button>
                </td>
              </tr>
              <tr class="edit-row" id="edit-row-<%= m[0] %>" style="display:none;">
                <td><select id="er-type-<%= m[0] %>"><option value="Breakfast" <%= m[1].equals("Breakfast")?"selected":"" %>>Breakfast</option><option value="Lunch" <%= m[1].equals("Lunch")?"selected":"" %>>Lunch</option><option value="Dinner" <%= m[1].equals("Dinner")?"selected":"" %>>Dinner</option><option value="Snack" <%= m[1].equals("Snack")?"selected":"" %>>Snack</option><option value="Other" <%= m[1].equals("Other")?"selected":"" %>>Other</option></select></td>
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
        <div class="pagination">
          <div class="page-info" id="page-info">Showing 1–10 of <%= mealCount %></div>
          <div class="page-btns" id="page-btns"></div>
        </div>
      <% } %>
    </div>

  </div>

  <!-- ══ WEIGHT ESTIMATION ══ -->
  <div style="margin-top:32px;">
    <div class="section-heading">&#9878; Weight Estimation &amp; Progress Forecast</div>
    <% if (profWeight.isEmpty()||profWeight.equals("0.0")||profWeight.equals("0")) { %>
      <div class="card"><div class="card-body"><div class="no-data" style="padding:36px 0;"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>Set your weight and height in your profile to enable weight estimation.</div></div></div>
    <% } else { %>
      <div class="est-grid">
        <div class="est-card"><div class="e-label">&#128200; Avg Daily Intake</div><div class="e-value e-green"><%= avgDailyCalories %></div><div class="e-unit">kcal / day (7-day avg)</div></div>
        <div class="est-card"><div class="e-label">&#128293; Your TDEE</div><div class="e-value e-green"><%= goalCal %></div><div class="e-unit">kcal / day (maintenance)</div></div>
        <div class="est-card"><div class="e-label">&#9883; Daily Difference</div><div class="e-value <%= diffColor %>"><%= diffSign %><%= diff %></div><div class="e-unit"><%= diff<0?"kcal deficit per day":diff>0?"kcal surplus per day":"at maintenance" %></div></div>
        <div class="est-card"><div class="e-label">&#9881; Est. Weekly Change</div><div class="e-value <%= wkColor %>"><%= wkSign %><%= String.format("%.2f",weeklyKg) %> kg</div><div class="e-unit">per week at current intake</div></div>
        <div class="est-card"><div class="e-label">&#128170; Current Weight</div><div class="e-value e-green"><%= profWeight %></div><div class="e-unit">kg (from your profile)</div></div>
      </div>
      <div class="advice-box <%= adviceClass %>">
        <div class="advice-title">&#128161; <%= adviceTitle %></div>
        <div class="advice-text"><%= adviceText %></div>
      </div>
      <div class="est-bottom-grid">
        <div class="card">
          <div class="card-header"><h2>&#127919; Reach My Target Weight</h2></div>
          <div class="card-body">
            <div class="target-calc">
              <div class="target-calc-title">How long will it take?</div>
              <div class="target-inputs">
                <div class="field" style="margin-bottom:0;"><label class="field-label">Current Weight (kg)</label><input type="number" id="tc-current" step="0.1" value="<%= profWeight %>" oninput="calcTarget()"/></div>
                <div class="field" style="margin-bottom:0;"><label class="field-label">Target Weight (kg)</label> <input type="number" id="tc-target"  step="0.1" placeholder="e.g. 70" oninput="calcTarget()"/></div>
                <div class="field" style="margin-bottom:0;"><label class="field-label">Daily Calories (kcal)</label><input type="number" id="tc-intake" value="<%= avgDailyCalories>0?avgDailyCalories:goalCal %>" oninput="calcTarget()"/></div>
              </div>
              <div class="target-result" id="tc-result"></div>
            </div>
          </div>
        </div>
        <div class="card">
          <div class="card-header"><h2>&#127922; What If I Adjust My Intake?</h2></div>
          <div class="card-body">
            <div class="intake-adjuster">
              <div class="intake-adjuster-title">Drag to simulate different calorie intakes</div>
              <div class="slider-row">
                <label style="font-size:0.8rem;font-weight:600;color:var(--muted);white-space:nowrap;">Daily kcal:</label>
                <input type="range" id="slider-cal" min="800" max="4000" step="50" value="<%= avgDailyCalories>0?avgDailyCalories:goalCal %>" oninput="updateSlider()"/>
                <span class="slider-val" id="slider-val"><%= avgDailyCalories>0?avgDailyCalories:goalCal %> kcal</span>
              </div>
              <div class="slider-result" id="slider-result"></div>
            </div>
          </div>
        </div>
      </div>
    <% } %>
  </div>

</div><!-- /page-body -->

<script>
// ══════════════════════════════════════════════════════════════════
// VALID FOOD NAMES — built from DB food names (index [0]) via Java
// ══════════════════════════════════════════════════════════════════
var validFoodNames = [<%= validFoodNamesJs %>];

// ── Food data from DB ──
var FOODS = {};
<%
  if (foods!=null){
    for (String[] f : foods){
      String cat  = f[1].replace("'","\\'");
      String name = f[0].replace("'","\\'");
%>
if (!FOODS['<%= cat %>']) FOODS['<%= cat %>'] = {};
FOODS['<%= cat %>']['<%= name %>'] = {cal:<%= f[2] %>,protein:<%= f[3] %>,carbs:<%= f[4] %>,fats:<%= f[5] %>};
<%
    }
  }
%>

// ── Context path for sort/filter navigation ──
var CTX = '<%= ctx %>';

// ══════════════════════════════════════════════════════════════════
// SERVER-SIDE SORT — submits a GET request preserving search/date
// ══════════════════════════════════════════════════════════════════
function sortBy(col, dir) {
  var search = document.getElementById('search-input') ? document.getElementById('search-input').value : '';
  var date   = document.getElementById('date-filter')  ? document.getElementById('date-filter').value  : '';
  var url = CTX + '/dashboard?sortBy=' + encodeURIComponent(col)
          + '&sortDir=' + encodeURIComponent(dir)
          + '&search='  + encodeURIComponent(search)
          + '&dateFilter=' + encodeURIComponent(date);
  window.location.href = url;
}

// ── Clear all filters and sort ──
function clearFilters() {
  window.location.href = CTX + '/dashboard';
}

// ── Summary toggle ──
var DATA = {
  today:   {meals:<%= todayMeals %>,  cal:<%= todayCalories %>,  protein:'<%= String.format("%.1f",todayProtein) %>',  carbs:'<%= String.format("%.1f",todayCarbs) %>',  fats:'<%= String.format("%.1f",todayFats) %>'},
  alltime: {meals:<%= mealCount %>,   cal:<%= totalCalories %>,  protein:'<%= String.format("%.1f",totalProtein) %>', carbs:'<%= String.format("%.1f",totalCarbs) %>', fats:'<%= String.format("%.1f",totalFats) %>'}
};
function setPeriod(p){
  document.getElementById('btn-today').classList.toggle('active',   p==='today');
  document.getElementById('btn-alltime').classList.toggle('active', p==='alltime');
  var d=DATA[p];
  document.getElementById('sum-meals').textContent   = d.meals;
  document.getElementById('sum-cal').textContent     = d.cal;
  document.getElementById('sum-protein').textContent = d.protein;
  document.getElementById('sum-carbs').textContent   = d.carbs;
  document.getElementById('sum-fats').textContent    = d.fats;
}

// ── Charts ──
var SEVEN={labels:[<%= chartLabels %>],cal:[<%= chartCal %>],protein:[<%= chartProtein %>],carbs:[<%= chartCarbs %>],fats:[<%= chartFats %>]};
var GOAL_CAL=<%= goalCal %>, TDEE=<%= goalCal %>;
function initCharts(){
  new Chart(document.getElementById('calChart'),{
    type:'bar',
    data:{ labels:SEVEN.labels, datasets:[
      {label:'Calories',data:SEVEN.cal,backgroundColor:'rgba(61,122,90,0.7)',borderColor:'#3d7a5a',borderWidth:1,borderRadius:5},
      {label:'Goal',data:SEVEN.labels.map(function(){return GOAL_CAL;}),type:'line',borderColor:'#c0392b',borderWidth:2,borderDash:[6,4],pointRadius:0,fill:false}
    ]},
    options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{labels:{font:{size:12}}}},scales:{x:{ticks:{font:{size:11}},grid:{display:false}},y:{ticks:{font:{size:11}},beginAtZero:true,grid:{color:'#f0f4f2'}}}}
  });
  new Chart(document.getElementById('macroChart'),{
    type:'bar',
    data:{labels:SEVEN.labels,datasets:[
      {label:'Protein',data:SEVEN.protein,backgroundColor:'rgba(69,39,160,0.75)',borderRadius:4},
      {label:'Carbs',  data:SEVEN.carbs,  backgroundColor:'rgba(245,127,23,0.75)',borderRadius:4},
      {label:'Fats',   data:SEVEN.fats,   backgroundColor:'rgba(136,14,79,0.75)', borderRadius:4}
    ]},
    options:{responsive:true,maintainAspectRatio:false,plugins:{legend:{position:'bottom',labels:{font:{size:11},padding:10}}},scales:{x:{stacked:true,ticks:{font:{size:11}},grid:{display:false}},y:{stacked:true,ticks:{font:{size:11}},beginAtZero:true,grid:{color:'#f0f4f2'}}}}
  });
}

// ── Food rows ──
var rowCounts = {};
function addRow(groupKey, catName) {
  if (!rowCounts[groupKey]) rowCounts[groupKey] = 0;
  var idx = rowCounts[groupKey]++;
  var rowId = groupKey + '_' + idx;
  var container = document.getElementById('group-' + groupKey);
  if (!container) return;
  var row = document.createElement('div');
  row.className = 'food-row'; row.id = 'frow-' + rowId;
  var foodsInGroup = FOODS[catName] || {};
  var opts = '<option value="">— Select —</option>';
  for (var name in foodsInGroup) opts += '<option value="' + name + '">' + name + '</option>';
  row.innerHTML =
    '<select onchange="recalculate()" data-cat="' + catName + '" id="sel-' + rowId + '">' + opts + '</select>' +
    '<input type="number" id="grm-' + rowId + '" placeholder="grams" min="0" step="1" oninput="recalculate()"/>' +
    '<span class="gram-label">g</span>' +
    '<button type="button" class="btn-remove-row" onclick="removeRow(\'' + rowId + '\')">✕</button>';
  container.appendChild(row);
}
function removeRow(rowId){ var r=document.getElementById('frow-'+rowId); if(r) r.remove(); recalculate(); }

function recalculate(){
  var totCal=0,totPro=0,totCarb=0,totFat=0,names=[];
  document.querySelectorAll('.food-row').forEach(function(row){
    var sel=row.querySelector('select'), grm=row.querySelector('input[type="number"]');
    if(!sel||!grm) return;
    var food=sel.value, grams=parseFloat(grm.value)||0, cat=sel.getAttribute('data-cat');
    if(!food||grams<=0||!cat) return;
    var macro=FOODS[cat]&&FOODS[cat][food]; if(!macro) return;
    var f=grams/100;
    totCal+=macro.cal*f; totPro+=macro.protein*f; totCarb+=macro.carbs*f; totFat+=macro.fats*f;
    names.push(food+'('+grams+'g)');
  });
  var burn=getBurn(), netCal=Math.max(0,totCal-burn);
  document.getElementById('prev-cal').textContent     = Math.round(netCal);
  document.getElementById('prev-protein').textContent = totPro.toFixed(1);
  document.getElementById('prev-carbs').textContent   = totCarb.toFixed(1);
  document.getElementById('prev-fats').textContent    = totFat.toFixed(1);
  document.getElementById('hid-meal_name').value = names.join(', ');
  document.getElementById('hid-calories').value  = Math.round(netCal);
  document.getElementById('hid-protein').value   = totPro.toFixed(2);
  document.getElementById('hid-carbs').value     = totCarb.toFixed(2);
  document.getElementById('hid-fats').value      = totFat.toFixed(2);
}
function getBurn(){ return (parseFloat(document.getElementById('exercise-type').value)||0)*(parseFloat(document.getElementById('exercise-mins').value)||0); }
function updateBurn(){ var b=getBurn(); document.getElementById('burn-display').textContent=b>0?'🔥 '+Math.round(b)+' kcal burned — will be subtracted':''; recalculate(); }
function prepareSubmit(){ if(!document.getElementById('hid-meal_name').value.trim()){ alert('Please select at least one food item.'); return false; } return true; }

// ── Weight estimation ──
function calcTarget(){
  var current=parseFloat(document.getElementById('tc-current').value);
  var target =parseFloat(document.getElementById('tc-target').value);
  var intake =parseFloat(document.getElementById('tc-intake').value);
  var el=document.getElementById('tc-result');
  if(!current||!target||!intake){ el.className='target-result'; return; }
  var diff=intake-TDEE, weightDiff=target-current, weeklyKg=(diff*7.0)/7700.0;
  if(Math.abs(diff)<50){ el.className='target-result show neutral'; el.innerHTML='&#9888; Your intake is at maintenance. Adjust it to change your weight.'; return; }
  if((weightDiff<0&&diff>0)||(weightDiff>0&&diff<0)){ el.className='target-result show neutral'; el.innerHTML='&#9888; Your calorie direction doesn\'t match your target. To '+(weightDiff<0?'lose':'gain')+' weight, you need a '+(weightDiff<0?'deficit':'surplus')+'.'; return; }
  var weeksNeeded=Math.abs(weeklyKg)>0?Math.abs(weightDiff/weeklyKg):0;
  var daysNeeded=Math.round(weeksNeeded*7), months=Math.floor(daysNeeded/30), days=daysNeeded%30;
  var timeStr=months>0?months+' month'+(months>1?'s':'')+(days>0?' and '+days+' day'+(days>1?'s':''):''):days+' day'+(days>1?'s':'');
  el.className='target-result show '+(weightDiff<0?'positive':'negative');
  el.innerHTML='&#127919; At '+intake+' kcal/day you have a '+Math.abs(diff)+' kcal '+(diff<0?'deficit':'surplus')+'/day — losing approximately '+Math.abs(weeklyKg).toFixed(2)+'kg/week. Estimated time to reach '+target+'kg: <strong>'+timeStr+'</strong>.';
}
function updateSlider(){
  var intake=parseInt(document.getElementById('slider-cal').value);
  var diff=intake-TDEE, weeklyKg=(diff*7.0)/7700.0;
  document.getElementById('slider-val').textContent=intake+' kcal';
  var direction,tip;
  if(diff<-100){ direction='&#128168; Deficit of '+Math.abs(diff)+' kcal/day — lose ~'+Math.abs(weeklyKg).toFixed(2)+' kg/week.'; tip='Good for weight loss. Keep protein intake high.'; }
  else if(diff>100){ direction='&#128170; Surplus of '+diff+' kcal/day — gain ~'+weeklyKg.toFixed(2)+' kg/week.'; tip='Good for muscle gain. Pair with resistance training.'; }
  else{ direction='&#9889; Maintenance — weight stays stable at ~'+TDEE+' kcal/day.'; tip='Ideal if you\'re happy with your current weight.'; }
  document.getElementById('slider-result').innerHTML='<strong>'+direction+'</strong><br/><span style="color:var(--muted);font-size:0.86rem;">'+tip+'</span>';
}

// ── Pagination (client-side over server-returned rows) ──
var PAGE_SIZE=10, currentPage=1, filteredRows=[];
function getAllDataRows(){ var t=document.getElementById('meals-tbody'); return t?Array.from(t.querySelectorAll('tr[id^="row-"]')):[];}
function renderPage(){
  var rows=getAllDataRows(), total=rows.length, pages=Math.max(1,Math.ceil(total/PAGE_SIZE));
  if (currentPage > pages) currentPage = 1;
  var start=(currentPage-1)*PAGE_SIZE, end=Math.min(start+PAGE_SIZE,total);
  rows.forEach(function(r){ r.style.display='none'; var er=document.getElementById('edit-row-'+r.id.replace('row-','')); if(er) er.style.display='none'; });
  rows.slice(start,end).forEach(function(r){ r.style.display=''; });
  var info=document.getElementById('page-info'); if(info) info.textContent=total===0?'No meals found':'Showing '+(start+1)+'–'+end+' of '+total;
  var badge=document.getElementById('visible-count'); if(badge) badge.textContent=total+' meal'+(total!==1?'s':'');
  var btns=document.getElementById('page-btns'); if(!btns) return; btns.innerHTML='';
  var prev=document.createElement('button'); prev.className='page-btn'; prev.textContent='← Prev'; prev.disabled=currentPage===1; prev.onclick=function(){currentPage--;renderPage();}; btns.appendChild(prev);
  for(var i=Math.max(1,currentPage-2);i<=Math.min(pages,Math.max(1,currentPage-2)+4);i++){(function(p){var b=document.createElement('button');b.className='page-btn'+(p===currentPage?' active':'');b.textContent=p;b.onclick=function(){currentPage=p;renderPage();};btns.appendChild(b);})(i);}
  var next=document.createElement('button'); next.className='page-btn'; next.textContent='Next →'; next.disabled=currentPage===pages; next.onclick=function(){currentPage++;renderPage();}; btns.appendChild(next);
}

// ── Profile modal ──
function openProfileModal(){ document.getElementById('profileModal').classList.remove('hidden'); }
function closeProfile()    { document.getElementById('profileModal').classList.add('hidden'); }
document.getElementById('profileModal').addEventListener('click',function(e){ if(e.target===this) closeProfile(); });
function switchTab(t){
  document.querySelectorAll('.modal-tab').forEach(function(b,i){ b.classList.toggle('active',(i===0&&t==='account')||(i===1&&t==='body')); });
  document.getElementById('pane-account').classList.toggle('active',t==='account');
  document.getElementById('pane-body').classList.toggle('active',   t==='body');
}

// ── Setup modal ──
var selectedGoal='maintain';
function selectGoal(type){ selectedGoal=type; document.getElementById('setup-goal-type').value=type; ['lose','maintain','gain'].forEach(function(t){ document.getElementById('gt-'+t).classList.toggle('selected',t===type); }); }
function calcBMI(){
  var w=parseFloat(document.getElementById('setup-weight').value);
  var h=parseFloat(document.getElementById('setup-height').value)/100;
  var box=document.getElementById('bmi-box');
  if(!w||!h||h<=0){ box.classList.remove('show'); return; }
  var bmi=w/(h*h),val=bmi.toFixed(1),cat,cls,tip;
  if(bmi<18.5){cat='Underweight';cls='underweight';tip='Below healthy weight. A Gain Weight goal is recommended.';}
  else if(bmi<25.0){cat='Normal Weight';cls='normal';tip='Within a healthy BMI range. Maintenance or slight surplus is ideal.';}
  else if(bmi<30.0){cat='Overweight';cls='overweight';tip='A moderate calorie deficit with regular exercise is recommended.';}
  else{cat='Obese';cls='obese';tip='A calorie deficit and regular activity are strongly recommended.';}
  document.getElementById('bmi-val').textContent=val+' BMI';
  document.getElementById('bmi-cat').textContent=cat;
  document.getElementById('bmi-tip').textContent=tip;
  box.className='bmi-box show '+cls;
  if(bmi<18.5) selectGoal('gain'); else if(bmi<25.0) selectGoal('maintain'); else selectGoal('lose');
}
function submitSetup(){
  if(!document.getElementById('setup-weight').value||!document.getElementById('setup-height').value||!document.getElementById('setup-age').value){ alert('Please fill in weight, height and age.'); return; }
  document.getElementById('setupForm').submit();
}

// ══════════════════════════════════════════════════════════════════
// POPUP SYSTEM
// ══════════════════════════════════════════════════════════════════
function showPopup(type, title, message, redirectUrl) {
  var existing = document.getElementById('ml-popup-overlay');
  if (existing) existing.remove();
  var color     = type==='error' ? '#c0392b' : type==='warning' ? '#e67e22' : '#3d7a5a';
  var bgColor   = type==='error' ? '#fdecea' : type==='warning' ? '#fef9e7' : '#f0fff4';
  var borderCol = type==='error' ? '#f5c6c2' : type==='warning' ? '#fdebd0' : '#b7e4c7';
  var overlay = document.createElement('div');
  overlay.id = 'ml-popup-overlay';
  overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.45);z-index:99999;display:flex;align-items:center;justify-content:center;font-family:DM Sans,sans-serif;';
  var box = document.createElement('div');
  box.style.cssText = 'background:#fff;border-radius:14px;padding:32px 32px 28px;max-width:420px;width:90%;box-shadow:0 8px 40px rgba(0,0,0,0.18);border:1.5px solid '+borderCol+';text-align:center;';
  var iconEl = document.createElement('div');
  iconEl.style.cssText = 'width:52px;height:52px;border-radius:50%;background:'+bgColor+';display:flex;align-items:center;justify-content:center;margin:0 auto 16px;font-size:1.4rem;';
  iconEl.innerHTML = type==='error' ? '&#9888;' : type==='warning' ? '&#9201;' : '&#10003;';
  var titleEl = document.createElement('div');
  titleEl.style.cssText = 'font-family:Playfair Display,serif;font-size:1.2rem;font-weight:600;color:#1a1f1c;margin-bottom:10px;';
  titleEl.innerHTML = title;
  var msgEl = document.createElement('div');
  msgEl.style.cssText = 'font-size:0.88rem;color:#6b7a72;line-height:1.6;margin-bottom:24px;';
  msgEl.innerHTML = message;
  var btn = document.createElement('button');
  btn.style.cssText = 'padding:11px 28px;background:'+color+';color:#fff;border:none;border-radius:8px;font-family:DM Sans,sans-serif;font-size:0.92rem;font-weight:600;cursor:pointer;';
  btn.textContent = redirectUrl ? 'Go to Login' : 'OK';
  btn.onclick = function(){ overlay.remove(); if(redirectUrl) window.location.href=redirectUrl; };
  box.appendChild(iconEl); box.appendChild(titleEl); box.appendChild(msgEl); box.appendChild(btn);
  overlay.appendChild(box);
  if (!redirectUrl) { overlay.onclick = function(e){ if(e.target===overlay) overlay.remove(); }; }
  document.body.appendChild(overlay);
}

// ══════════════════════════════════════════════════════════════════
// FOOD NAME VALIDATION FOR EDIT
// ══════════════════════════════════════════════════════════════════
function validateMealNameForEdit(mealNameValue) {
  if (!mealNameValue || mealNameValue.trim() === '') return true;
  if (validFoodNames.length === 0) return true;
  var parts = mealNameValue.split(',');
  var invalidFoods = [];
  for (var i = 0; i < parts.length; i++) {
    var part = parts[i].trim();
    var match = part.match(/^([a-zA-Z\s&'-]+)\s*\(/);
    if (match) {
      var foodName = match[1].trim().toLowerCase();
      if (validFoodNames.indexOf(foodName) === -1) {
        invalidFoods.push(match[1].trim());
      }
    }
  }
  if (invalidFoods.length > 0) {
    showPopup('error',
      '&#9888; Food Not Found',
      'The following food item(s) do not exist in the database: <strong>' +
      invalidFoods.join(', ') +
      '</strong>.<br/>Please only use food names from the meal logging form, or ask your admin to add them to the database.'
    );
    return false;
  }
  return true;
}

// ══════════════════════════════════════════════════════════════════
// INLINE EDIT / DELETE
// ══════════════════════════════════════════════════════════════════
function startEdit(id) {
  document.getElementById('row-'+id).style.display='none';
  document.getElementById('edit-row-'+id).style.display='';
}
function cancelEdit(id){
  document.getElementById('edit-row-'+id).style.display='none';
  document.getElementById('row-'+id).style.display='';
}
function saveEdit(id){
  var nameInput = document.getElementById('er-name-'+id);
  var name = nameInput.value.trim();
  if (!name) { showPopup('error', '&#9888; Empty Name', 'Meal name cannot be empty.'); return; }
  if (!validateMealNameForEdit(name)) { return; }
  document.getElementById('update-id').value        = id;
  document.getElementById('update-meal_type').value = document.getElementById('er-type-'+id).value;
  document.getElementById('update-meal_name').value = name;
  document.getElementById('update-calories').value  = document.getElementById('er-calories-'+id).value;
  document.getElementById('update-protein').value   = document.getElementById('er-protein-'+id).value;
  document.getElementById('update-carbs').value     = document.getElementById('er-carbs-'+id).value;
  document.getElementById('update-fats').value      = document.getElementById('er-fats-'+id).value;
  document.getElementById('update-meal_date').value = document.getElementById('er-date-'+id).value;
  document.getElementById('update-form').submit();
}
function doDelete(id,name){
  if(!confirm('Delete "'+name+'"? This cannot be undone.')) return;
  document.getElementById('delete-id').value=id;
  document.getElementById('delete-form').submit();
}

// ══════════════════════════════════════════════════════════════════
// SESSION TIMEOUT — 3 minutes inactivity, direct redirect, no warning
// ══════════════════════════════════════════════════════════════════
(function() {
  var TIMEOUT_MS   = 3 * 60 * 1000;
  var loginUrl     = '<%= request.getContextPath() %>/login';
  var deadlineTime = Date.now() + TIMEOUT_MS;
  var logoutTimeout, countdownInterval;

  countdownInterval = setInterval(function() {
    var remaining = Math.max(0, deadlineTime - Date.now());
    var totalSecs = Math.ceil(remaining / 1000);
    var mins = Math.floor(totalSecs / 60);
    var secs = totalSecs % 60;
    var displayEl = document.getElementById('timer-display');
    if (displayEl) displayEl.textContent = mins + ':' + (secs < 10 ? '0' : '') + secs;
    var timerEl = document.getElementById('session-timer');
    if (timerEl) {
      timerEl.classList.remove('warn', 'danger');
      if (remaining <= 30 * 1000)      timerEl.classList.add('danger');
      else if (remaining <= 60 * 1000) timerEl.classList.add('warn');
    }
  }, 1000);

  function scheduleLogout() {
    clearTimeout(logoutTimeout);
    logoutTimeout = setTimeout(function() {
      clearInterval(countdownInterval);
      fetch('<%= request.getContextPath() %>/dashboard', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'action=logout'
      }).finally(function() { showTimeoutPopup(loginUrl); });
    }, TIMEOUT_MS);
  }

  function showTimeoutPopup(redirectUrl) {
    var existing = document.getElementById('ml-popup-overlay');
    if (existing) existing.remove();
    var overlay = document.createElement('div');
    overlay.id = 'ml-popup-overlay';
    overlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.55);z-index:99999;display:flex;align-items:center;justify-content:center;font-family:DM Sans,sans-serif;';
    var box = document.createElement('div');
    box.style.cssText = 'background:#fff;border-radius:14px;padding:36px 32px 30px;max-width:400px;width:90%;box-shadow:0 8px 40px rgba(0,0,0,0.2);border:1.5px solid #f5c6c2;text-align:center;';
    var icon = document.createElement('div');
    icon.style.cssText = 'width:56px;height:56px;border-radius:50%;background:#fdecea;display:flex;align-items:center;justify-content:center;margin:0 auto 18px;font-size:1.6rem;';
    icon.textContent = '⏱';
    var title = document.createElement('div');
    title.style.cssText = 'font-family:Playfair Display,serif;font-size:1.25rem;font-weight:600;color:#1a1f1c;margin-bottom:10px;';
    title.textContent = 'Session Timed Out';
    var msg = document.createElement('div');
    msg.style.cssText = 'font-size:0.9rem;color:#6b7a72;line-height:1.65;margin-bottom:26px;';
    msg.textContent = 'You were logged out after 3 minutes of inactivity. Please sign in again to continue.';
    var btn = document.createElement('button');
    btn.style.cssText = 'padding:12px 36px;background:#c0392b;color:#fff;border:none;border-radius:8px;font-family:DM Sans,sans-serif;font-size:0.95rem;font-weight:600;cursor:pointer;letter-spacing:0.02em;';
    btn.textContent = 'OK — Go to Login';
    btn.onclick = function() { overlay.remove(); window.location.href = redirectUrl; };
    box.appendChild(icon); box.appendChild(title); box.appendChild(msg); box.appendChild(btn);
    overlay.appendChild(box);
    document.body.appendChild(overlay);
  }

  function onActivity() {
    deadlineTime = Date.now() + TIMEOUT_MS;
    scheduleLogout();
    var timerEl = document.getElementById('session-timer');
    if (timerEl) timerEl.classList.remove('warn', 'danger');
  }

  ['mousemove','mousedown','keydown','touchstart','scroll','click'].forEach(function(evt) {
    document.addEventListener(evt, onActivity, { passive: true });
  });

  scheduleLogout();
})();

// ── Init ──
window.onload = function(){
  document.querySelectorAll('.btn-add-food').forEach(function(btn){ btn.click(); });
  renderPage();
  initCharts();
  calcTarget();
  updateSlider();
};
</script>
</body>
</html>
