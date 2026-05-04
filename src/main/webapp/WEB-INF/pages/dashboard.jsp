<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
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

    .navbar {
      background: var(--white); border-bottom: 1px solid var(--border);
      padding: 0 32px; height: 64px; display: flex; align-items: center;
      justify-content: space-between; position: sticky; top: 0; z-index: 200;
      box-shadow: 0 2px 12px rgba(30,50,38,0.07);
    }
    .nav-right { display: flex; align-items: center; gap: 12px; }
    .nav-user  { font-size: 0.86rem; color: var(--muted); }
    .nav-user strong { color: var(--ink); font-weight: 600; }
    .avatar {
      width: 36px; height: 36px; background: var(--green); border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
      color: #fff; font-size: 0.85rem; font-weight: 700;
      cursor: pointer; transition: opacity 0.15s; border: 2px solid var(--green-dim);
    }
    .avatar:hover { opacity: 0.85; }
    .btn-logout {
      padding: 7px 16px; background: none; border: 1.5px solid var(--border);
      border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif;
      font-size: 0.82rem; font-weight: 600; color: var(--muted);
      cursor: pointer; transition: border-color 0.18s, color 0.18s;
    }
    .btn-logout:hover { border-color: var(--error); color: var(--error); }

    .page-body { padding: 32px; max-width: 1340px; margin: 0 auto; }
    .page-title    { font-family: 'Playfair Display', serif; font-size: 1.7rem; font-weight: 500; margin-bottom: 4px; }
    .page-subtitle { font-size: 0.88rem; color: var(--muted); margin-bottom: 28px; }

    .summary-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; flex-wrap: wrap; gap: 10px; }
    .summary-title  { font-size: 0.78rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); }
    .period-toggle  { display: flex; background: #ece9e2; border-radius: 8px; padding: 3px; gap: 3px; }
    .period-btn { padding: 6px 14px; background: none; border: none; font-family: 'DM Sans', sans-serif; font-size: 0.8rem; font-weight: 500; color: var(--muted); border-radius: 6px; cursor: pointer; transition: background 0.18s, color 0.18s; }
    .period-btn.active { background: var(--white); color: var(--green); font-weight: 600; box-shadow: 0 1px 6px rgba(30,50,38,0.10); }

    .summary-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(155px,1fr)); gap: 14px; margin-bottom: 28px; }
    .summary-card { background: var(--white); border-radius: var(--radius); border: 1px solid rgba(212,224,217,0.6); padding: 18px 20px; box-shadow: var(--shadow); transition: transform 0.15s, box-shadow 0.15s; }
    .summary-card:hover { transform: translateY(-2px); box-shadow: var(--shadow-lg); }
    .summary-card .s-label { font-size: 0.71rem; font-weight: 600; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); margin-bottom: 10px; }
    .summary-card .s-value { font-size: 1.75rem; font-weight: 700; color: var(--green); line-height: 1; }
    .summary-card .s-unit  { font-size: 0.74rem; color: var(--muted); margin-top: 5px; }

    .goals-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px,1fr)); gap: 14px; margin-bottom: 28px; }
    .goal-card  { background: var(--white); border-radius: var(--radius); border: 1px solid rgba(212,224,217,0.6); padding: 16px 20px; box-shadow: var(--shadow); }
    .goal-label { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
    .goal-name  { font-size: 0.76rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--muted); }
    .goal-nums  { font-size: 0.8rem; font-weight: 600; color: var(--ink); }
    .goal-nums span { color: var(--green); }
    .progress-track { height: 8px; background: var(--green-pale); border-radius: 99px; overflow: hidden; }
    .progress-fill  { height: 100%; border-radius: 99px; background: var(--green); transition: width 0.6s ease; }
    .progress-fill.over { background: var(--error); }

    .charts-section { margin-bottom: 28px; }
    .section-heading { font-family: 'Playfair Display', serif; font-size: 1.15rem; font-weight: 500; margin-bottom: 16px; display: flex; align-items: center; gap: 10px; }
    .section-heading::after { content: ''; flex: 1; height: 1px; background: var(--border); }
    .charts-grid-2 { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; }
    .chart-card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); border: 1px solid rgba(212,224,217,0.6); padding: 20px 22px; }
    .chart-title  { font-size: 0.78rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--muted); margin-bottom: 14px; }
    .chart-canvas { width: 100% !important; height: 220px !important; }

    .content-grid { display: grid; grid-template-columns: 400px 1fr; gap: 24px; align-items: start; }

    .card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); border: 1px solid rgba(212,224,217,0.6); overflow: hidden; }
    .card-header { padding: 16px 22px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; }
    .card-header h2 { font-family: 'Playfair Display', serif; font-size: 1.1rem; font-weight: 500; }
    .card-body { padding: 20px 22px; }

    .food-group { background: var(--cream); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 13px; margin-bottom: 10px; }
    .food-group-title { font-size: 0.76rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 9px; display: flex; align-items: center; gap: 6px; }
    .food-row { display: flex; gap: 7px; align-items: center; margin-bottom: 7px; }
    .food-row select { flex: 1; font-size: 0.84rem; padding: 8px 10px; }
    .food-row input  { width: 75px; flex-shrink: 0; font-size: 0.84rem; padding: 8px 10px; }
    .gram-label { font-size: 0.73rem; color: var(--muted); flex-shrink: 0; }
    .btn-add-food { background: none; border: 1.5px dashed var(--green-dim); border-radius: var(--radius-sm); color: var(--green); font-family: 'DM Sans', sans-serif; font-size: 0.77rem; font-weight: 600; padding: 6px 12px; cursor: pointer; width: 100%; transition: background 0.15s; margin-top: 3px; }
    .btn-add-food:hover { background: var(--green-pale); }
    .btn-remove-row { background: #fce4ec; border: none; border-radius: 6px; color: #c62828; font-size: 0.73rem; font-weight: 600; padding: 6px 8px; cursor: pointer; flex-shrink: 0; font-family: 'DM Sans', sans-serif; }
    .btn-remove-row:hover { opacity: 0.7; }

    .macro-preview { background: var(--green-pale); border: 1px solid var(--green-dim); border-radius: var(--radius-sm); padding: 13px 16px; margin-bottom: 13px; }
    .macro-preview-title { font-size: 0.72rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 10px; }
    .macro-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 8px; }
    .macro-item { text-align: center; }
    .macro-item .m-val { font-size: 1.15rem; font-weight: 700; color: var(--green); }
    .macro-item .m-lbl { font-size: 0.66rem; color: var(--muted); text-transform: uppercase; letter-spacing: 0.04em; margin-top: 2px; }
    .exercise-row { display: flex; gap: 8px; align-items: center; }
    .exercise-row select { flex: 1; }
    .exercise-row input  { width: 85px; flex-shrink: 0; }
    .exercise-burn { font-size: 0.81rem; color: var(--error); font-weight: 600; margin-top: 5px; min-height: 18px; }
    .section-divider { font-size: 0.71rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); display: flex; align-items: center; gap: 8px; margin: 14px 0 11px; }
    .section-divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }
    .btn-secondary { width: 100%; padding: 10px; background: none; color: var(--green); border: 1.5px solid var(--green-dim); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.88rem; font-weight: 600; cursor: pointer; transition: background 0.18s; margin-top: 6px; }
    .btn-secondary:hover { background: var(--green-pale); }

    .table-toolbar { display: flex; align-items: center; gap: 10px; padding: 14px 22px; border-bottom: 1px solid var(--border); flex-wrap: wrap; }
    .search-input { flex: 1; min-width: 140px; padding: 8px 12px; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.86rem; outline: none; transition: border-color 0.18s; width: auto; }
    .search-input:focus { border-color: var(--green); }
    .date-filter  { padding: 8px 12px; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.86rem; outline: none; background: var(--white); transition: border-color 0.18s; appearance: none; width: auto; }
    .date-filter:focus { border-color: var(--green); }
    .btn-clear-filter { padding: 8px 12px; background: none; border: 1.5px solid var(--border); border-radius: var(--radius-sm); font-family: 'DM Sans', sans-serif; font-size: 0.82rem; font-weight: 600; color: var(--muted); cursor: pointer; white-space: nowrap; transition: border-color 0.18s, color 0.18s; }
    .btn-clear-filter:hover { border-color: var(--green); color: var(--green); }

    .table-wrap { overflow-x: auto; }
    .meal-type-badge { display: inline-block; padding: 3px 9px; border-radius: 12px; font-size: 0.71rem; font-weight: 600; text-transform: capitalize; }
    .badge-breakfast { background: #fff8e1; color: #f57f17; }
    .badge-lunch     { background: #e8f5e9; color: #2e7d32; }
    .badge-dinner    { background: #ede7f6; color: #4527a0; }
    .badge-snack     { background: #fce4ec; color: #880e4f; }

    .pagination { display: flex; align-items: center; justify-content: space-between; padding: 14px 22px; border-top: 1px solid var(--border); flex-wrap: wrap; gap: 10px; }
    .page-info  { font-size: 0.82rem; color: var(--muted); }
    .page-btns  { display: flex; gap: 6px; }
    .page-btn   { padding: 6px 12px; font-size: 0.8rem; font-weight: 600; border: 1.5px solid var(--border); border-radius: 6px; background: var(--white); color: var(--ink); cursor: pointer; font-family: 'DM Sans', sans-serif; transition: all 0.15s; }
    .page-btn:hover    { border-color: var(--green); color: var(--green); }
    .page-btn.active   { background: var(--green); color: #fff; border-color: var(--green); }
    .page-btn:disabled { opacity: 0.4; cursor: not-allowed; }

    /* ── Weight Estimation ── */
    .est-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(160px,1fr)); gap: 14px; margin-bottom: 20px; }
    .est-card { background: var(--white); border-radius: var(--radius); border: 1px solid rgba(212,224,217,0.6); padding: 16px 18px; box-shadow: var(--shadow); }
    .est-card .e-label { font-size: 0.71rem; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: var(--muted); margin-bottom: 8px; }
    .est-card .e-value { font-size: 1.6rem; font-weight: 700; line-height: 1; }
    .est-card .e-unit  { font-size: 0.74rem; color: var(--muted); margin-top: 4px; }
    .e-green  { color: var(--green); }
    .e-red    { color: var(--error); }
    .e-orange { color: #e65100; }

    .advice-box { border-radius: var(--radius-sm); padding: 14px 16px; margin-bottom: 18px; }
    .advice-box.lose     { background: #e3f2fd; border: 1px solid #90caf9; color: #1565c0; }
    .advice-box.gain     { background: var(--success-bg); border: 1px solid #b7e4c7; color: var(--success); }
    .advice-box.maintain { background: var(--green-pale); border: 1px solid var(--green-dim); color: var(--green); }
    .advice-box.warning  { background: #fff8e1; border: 1px solid #ffe082; color: #e65100; }
    .advice-title { font-size: 0.78rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; margin-bottom: 6px; }
    .advice-text  { font-size: 0.86rem; line-height: 1.6; }

    .target-calc { background: var(--cream); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 16px; margin-bottom: 14px; }
    .target-calc-title { font-size: 0.76rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 12px; }
    .target-inputs { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 10px; align-items: end; margin-bottom: 12px; }
    .target-result { border-radius: var(--radius-sm); padding: 12px 14px; font-size: 0.88rem; font-weight: 500; line-height: 1.6; display: none; }
    .target-result.show { display: block; }
    .target-result.positive { background: var(--success-bg); color: var(--success); border: 1px solid #b7e4c7; }
    .target-result.negative { background: var(--error-bg); color: var(--error); border: 1px solid #f5c6c2; }
    .target-result.neutral  { background: var(--green-pale); color: var(--green); border: 1px solid var(--green-dim); }

    .intake-adjuster { background: var(--green-pale); border: 1px solid var(--green-dim); border-radius: var(--radius-sm); padding: 14px 16px; }
    .intake-adjuster-title { font-size: 0.76rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 10px; }
    .slider-row { display: flex; align-items: center; gap: 12px; margin-bottom: 10px; }
    .slider-row input[type="range"] { flex: 1; accent-color: var(--green); }
    .slider-val { font-size: 0.9rem; font-weight: 700; color: var(--green); min-width: 60px; text-align: right; }
    .slider-result { font-size: 0.84rem; color: var(--ink); line-height: 1.6; }

    /* ── Profile modal ── */
    .modal-overlay { position: fixed; inset: 0; background: rgba(20,35,28,0.45); z-index: 500; display: flex; align-items: center; justify-content: center; padding: 20px; backdrop-filter: blur(2px); overflow-y: auto; }
    .modal-overlay.hidden { display: none; }
    .modal { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow-lg); width: 100%; max-width: 500px; overflow: hidden; animation: modalIn 0.2s ease; }
    @keyframes modalIn { from { opacity:0; transform: translateY(-12px); } to { opacity:1; transform: translateY(0); } }
    .modal-header { padding: 20px 24px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; }
    .modal-header h3 { font-family: 'Playfair Display', serif; font-size: 1.15rem; font-weight: 500; }
    .modal-close { background: none; border: none; cursor: pointer; color: var(--muted); font-size: 1.2rem; padding: 4px; line-height: 1; transition: color 0.15s; }
    .modal-close:hover { color: var(--error); }
    .modal-body { padding: 24px; max-height: 80vh; overflow-y: auto; }
    .modal-tabs { display: flex; background: var(--cream); border-radius: var(--radius-sm); padding: 3px; gap: 3px; margin-bottom: 20px; }
    .modal-tab  { flex: 1; padding: 8px; background: none; border: none; font-family: 'DM Sans', sans-serif; font-size: 0.82rem; font-weight: 500; color: var(--muted); border-radius: 6px; cursor: pointer; transition: background 0.18s, color 0.18s; }
    .modal-tab.active { background: var(--white); color: var(--green); font-weight: 600; box-shadow: 0 1px 6px rgba(30,50,38,0.10); }
    .modal-pane { display: none; }
    .modal-pane.active { display: block; }
    .profile-avatar { width: 56px; height: 56px; background: var(--green); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; font-size: 1.3rem; font-weight: 700; margin: 0 auto 18px; border: 3px solid var(--green-dim); }
    .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .auto-calc-box { background: var(--green-pale); border: 1px solid var(--green-dim); border-radius: var(--radius-sm); padding: 14px; margin-bottom: 14px; }
    .auto-calc-title { font-size: 0.74rem; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; color: var(--green); margin-bottom: 10px; }
    .field-hint { font-size: 0.74rem; color: var(--muted); margin-top: 4px; }

    /* ── First-time setup ── */
    .setup-overlay { position: fixed; inset: 0; background: rgba(10,20,15,0.7); z-index: 900; display: flex; align-items: center; justify-content: center; padding: 20px; backdrop-filter: blur(4px); }
    .setup-overlay.hidden { display: none; }
    .setup-modal { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow-lg); width: 100%; max-width: 480px; overflow: hidden; animation: modalIn 0.25s ease; }
    .setup-header { padding: 24px 28px 20px; border-bottom: 1px solid var(--border); }
    .setup-header h2 { font-family: 'Playfair Display', serif; font-size: 1.4rem; font-weight: 500; margin-bottom: 4px; }
    .setup-header p  { font-size: 0.86rem; color: var(--muted); }
    .setup-body  { padding: 24px 28px; }
    .setup-footer { padding: 0 28px 24px; }
    .bmi-box { border-radius: var(--radius-sm); padding: 14px 16px; margin-top: 16px; margin-bottom: 4px; display: none; }
    .bmi-box.show        { display: block; }
    .bmi-box.underweight { background: #e3f2fd; border: 1px solid #90caf9; color: #1565c0; }
    .bmi-box.normal      { background: var(--success-bg); border: 1px solid #b7e4c7; color: var(--success); }
    .bmi-box.overweight  { background: #fff8e1; border: 1px solid #ffe082; color: #e65100; }
    .bmi-box.obese       { background: var(--error-bg); border: 1px solid #f5c6c2; color: var(--error); }
    .bmi-val { font-size: 1.6rem; font-weight: 700; line-height: 1; margin-bottom: 4px; }
    .bmi-cat { font-size: 0.82rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.05em; }
    .bmi-tip { font-size: 0.82rem; margin-top: 8px; line-height: 1.5; }
    .goal-type-grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 8px; margin-top: 14px; }
    .goal-type-btn  { padding: 10px 8px; text-align: center; border: 1.5px solid var(--border); border-radius: var(--radius-sm); cursor: pointer; background: var(--white); font-family: 'DM Sans', sans-serif; font-size: 0.82rem; font-weight: 600; color: var(--muted); transition: all 0.18s; }
    .goal-type-btn:hover    { border-color: var(--green); color: var(--green); }
    .goal-type-btn.selected { background: var(--green-pale); border-color: var(--green); color: var(--green); }
    .goal-type-btn .gt-icon { font-size: 1.3rem; display: block; margin-bottom: 4px; }

    @media (max-width: 1080px) { .content-grid { grid-template-columns: 1fr; } .charts-grid-2 { grid-template-columns: 1fr; } }
    @media (max-width: 600px)  { .navbar { padding: 0 16px; } .page-body { padding: 20px 16px; } .two-col { grid-template-columns: 1fr; } .target-inputs { grid-template-columns: 1fr; } }
  </style>
</head>
<body>

<%
  List<String[]> meals       = (List<String[]>) request.getAttribute("meals");
  String[]       userProfile = (String[])       request.getAttribute("userProfile");
  List<String[]> sevenDay    = (List<String[]>) request.getAttribute("sevenDay");
  boolean        showSetup   = Boolean.TRUE.equals(request.getAttribute("showSetup"));

  int mealCount = (meals != null) ? meals.size() : 0;
  String today  = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());

  int    todayCalories = 0; double todayProtein = 0, todayCarbs = 0, todayFats = 0; int todayMeals = 0;
  int    totalCalories = 0; double totalProtein = 0, totalCarbs = 0, totalFats = 0;

  if (meals != null) {
    for (String[] m : meals) {
      try { totalCalories += Integer.parseInt(m[3]);   } catch (Exception e) {}
      try { totalProtein  += Double.parseDouble(m[4]); } catch (Exception e) {}
      try { totalCarbs    += Double.parseDouble(m[5]); } catch (Exception e) {}
      try { totalFats     += Double.parseDouble(m[6]); } catch (Exception e) {}
      if (m[7].equals(today)) {
        try { todayCalories += Integer.parseInt(m[3]);   } catch (Exception e) {}
        try { todayProtein  += Double.parseDouble(m[4]); } catch (Exception e) {}
        try { todayCarbs    += Double.parseDouble(m[5]); } catch (Exception e) {}
        try { todayFats     += Double.parseDouble(m[6]); } catch (Exception e) {}
        todayMeals++;
      }
    }
  }

  int    goalCal = 2000; double goalProtein = 150, goalCarbs = 250, goalFats = 65;
  String profHeight = "", profWeight = "", profAge = "", profGender = "";
  if (userProfile != null) {
    profHeight = userProfile[0]; profWeight = userProfile[1];
    profAge    = userProfile[2]; profGender = userProfile[3];
    try { goalCal     = Integer.parseInt(userProfile[4]);   } catch (Exception e) {}
    try { goalProtein = Double.parseDouble(userProfile[5]); } catch (Exception e) {}
    try { goalCarbs   = Double.parseDouble(userProfile[6]); } catch (Exception e) {}
    try { goalFats    = Double.parseDouble(userProfile[7]); } catch (Exception e) {}
  }

  int pctCal     = goalCal     > 0 ? Math.min(100,(int)(todayCalories * 100 / goalCal))     : 0;
  int pctProtein = goalProtein > 0 ? Math.min(100,(int)(todayProtein  * 100 / goalProtein)) : 0;
  int pctCarbs   = goalCarbs   > 0 ? Math.min(100,(int)(todayCarbs    * 100 / goalCarbs))   : 0;
  int pctFats    = goalFats    > 0 ? Math.min(100,(int)(todayFats     * 100 / goalFats))    : 0;

  // 7-day average calories
  int sevenDayTotalCal = 0, sevenDayCount = 0;
  StringBuilder chartLabels = new StringBuilder(), chartCal = new StringBuilder();
  StringBuilder chartProtein = new StringBuilder(), chartCarbs = new StringBuilder(), chartFats = new StringBuilder();
  if (sevenDay != null) {
    for (int i = 0; i < sevenDay.size(); i++) {
      String[] d = sevenDay.get(i); String sep = i < sevenDay.size()-1 ? "," : "";
      chartLabels.append("'").append(d[0]).append("'").append(sep);
      chartCal.append(d[1]).append(sep);
      chartProtein.append(d[2]).append(sep);
      chartCarbs.append(d[3]).append(sep);
      chartFats.append(d[4]).append(sep);
      try { sevenDayTotalCal += Integer.parseInt(d[1]); sevenDayCount++; } catch (Exception e) {}
    }
  }
  int avgDailyCalories = sevenDayCount > 0 ? sevenDayTotalCal / sevenDayCount : 0;

  String userName  = (String) session.getAttribute("userName");
  String userEmail = (String) session.getAttribute("userEmail");
  String initials  = (userName != null && !userName.isEmpty()) ? String.valueOf(userName.charAt(0)).toUpperCase() : "U";
  boolean openProfile = Boolean.TRUE.equals(request.getAttribute("openProfile"));
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
<div class="setup-overlay <%= showSetup ? "" : "hidden" %>" id="setupOverlay">
  <div class="setup-modal">
    <div class="setup-header">
      <h2>Welcome to MealLog &#127807;</h2>
      <p>Let's set up your profile so we can personalise your nutrition goals.</p>
    </div>
    <div class="setup-body">
      <% if (request.getAttribute("setupErr") != null) { %>
        <div class="banner error">&#9888; <%= request.getAttribute("setupErr") %></div>
      <% } %>
      <form action="dashboard" method="post" id="setupForm">
        <input type="hidden" name="action"    value="setup"/>
        <input type="hidden" name="goal_type" id="setup-goal-type" value="maintain"/>
        <div class="two-col">
          <div class="field">
            <label>Weight (kg)</label>
            <input type="number" name="weight_kg" id="setup-weight" placeholder="e.g. 70" min="20" max="300" step="0.1" oninput="calcBMI()"/>
          </div>
          <div class="field">
            <label>Height (cm)</label>
            <input type="number" name="height_cm" id="setup-height" placeholder="e.g. 175" min="100" max="250" step="0.1" oninput="calcBMI()"/>
          </div>
        </div>
        <div class="two-col">
          <div class="field">
            <label>Age</label>
            <input type="number" name="age" id="setup-age" placeholder="e.g. 22" min="10" max="100"/>
          </div>
          <div class="field">
            <label>Gender</label>
            <select name="gender" id="setup-gender">
              <option value="male">Male</option>
              <option value="female">Female</option>
            </select>
          </div>
        </div>
        <div class="bmi-box" id="bmi-box">
          <div class="bmi-val" id="bmi-val"></div>
          <div class="bmi-cat" id="bmi-cat"></div>
          <div class="bmi-tip" id="bmi-tip"></div>
        </div>
        <div class="field" style="margin-top:16px;">
          <label>What is your goal?</label>
          <div class="goal-type-grid">
            <div class="goal-type-btn" id="gt-lose"     onclick="selectGoal('lose')"><span class="gt-icon">&#128168;</span>Lose Weight</div>
            <div class="goal-type-btn selected" id="gt-maintain" onclick="selectGoal('maintain')"><span class="gt-icon">&#9889;</span>Maintain</div>
            <div class="goal-type-btn" id="gt-gain"     onclick="selectGoal('gain')"><span class="gt-icon">&#128170;</span>Gain Weight</div>
          </div>
        </div>
      </form>
    </div>
    <div class="setup-footer">
      <button type="button" class="btn-primary" onclick="submitSetup()" style="width:100%;">Set My Goals &amp; Get Started &#10140;</button>
      <button type="button" class="btn-secondary" onclick="skipSetup()" style="margin-top:8px;width:100%;">Skip for now</button>
    </div>
  </div>
</div>

<!-- ══ PROFILE MODAL ══ -->
<div class="modal-overlay <%= openProfile ? "" : "hidden" %>" id="profileModal">
  <div class="modal">
    <div class="modal-header">
      <h3>My Profile</h3>
      <button type="button" class="modal-close" onclick="closeProfile()">&#10005;</button>
    </div>
    <div class="modal-body">
      <div class="profile-avatar"><%= initials %></div>
      <% if (request.getAttribute("profileSuccess") != null) { %><div class="banner success" style="margin-bottom:16px;">&#10003; <%= request.getAttribute("profileSuccess") %></div><% } %>
      <% if (request.getAttribute("profileErr")     != null) { %><div class="banner error"   style="margin-bottom:16px;">&#9888; <%= request.getAttribute("profileErr") %></div><% } %>
      <div class="modal-tabs">
        <button class="modal-tab active" onclick="switchTab('account')">Account</button>
        <button class="modal-tab"        onclick="switchTab('body')">Body &amp; Goals</button>
      </div>
      <!-- Account pane -->
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
          <div class="field"><label>Full Name</label><input type="text"  name="full_name" value="<%= userName != null ? userName : "" %>"/></div>
          <div class="field"><label>Email</label>    <input type="email" name="email"     value="<%= userEmail != null ? userEmail : "" %>"/></div>
          <div class="section-divider">Change Password</div>
          <div class="field"><label>New Password</label>     <input type="password" name="password" placeholder="Leave blank to keep current"/><div class="field-hint">Min 6 characters.</div></div>
          <div class="field"><label>Confirm Password</label> <input type="password" name="confirm"  placeholder="Repeat new password"/></div>
          <button type="submit" class="btn-primary">Save Account</button>
        </form>
      </div>
      <!-- Body pane -->
      <div class="modal-pane" id="pane-body">
        <div class="auto-calc-box">
          <div class="auto-calc-title">&#127919; Auto-Calculate My Goals</div>
          <form action="dashboard" method="post">
            <input type="hidden" name="action" value="auto_goals"/>
            <div class="two-col">
              <div class="field" style="margin-bottom:0;"><label>Weight (kg)</label><input type="number" name="weight_kg" step="0.1" value="<%= profWeight %>"/></div>
              <div class="field" style="margin-bottom:0;"><label>Height (cm)</label><input type="number" name="height_cm" step="0.1" value="<%= profHeight %>"/></div>
            </div>
            <div class="two-col" style="margin-top:10px;">
              <div class="field" style="margin-bottom:0;"><label>Age</label><input type="number" name="age" value="<%= profAge %>"/></div>
              <div class="field" style="margin-bottom:0;"><label>Gender</label>
                <select name="gender">
                  <option value="male"   <%= "male".equals(profGender)   ? "selected":"" %>>Male</option>
                  <option value="female" <%= "female".equals(profGender) ? "selected":"" %>>Female</option>
                </select>
              </div>
            </div>
            <div class="field" style="margin-top:10px;"><label>Goal</label>
              <select name="goal_type">
                <option value="maintain">Maintain Weight</option>
                <option value="lose">Lose Weight</option>
                <option value="gain">Gain Weight</option>
              </select>
            </div>
            <button type="submit" class="btn-secondary" style="margin-top:4px;">&#9889; Calculate &amp; Set Goals</button>
          </form>
        </div>
        <form action="dashboard" method="post">
          <input type="hidden" name="action"    value="update_profile"/>
          <input type="hidden" name="full_name" value="<%= userName != null ? userName : "" %>"/>
          <input type="hidden" name="email"     value="<%= userEmail != null ? userEmail : "" %>"/>
          <input type="hidden" name="password"  value=""/>
          <input type="hidden" name="confirm"   value=""/>
          <div class="section-divider">Manual Goals</div>
          <div class="two-col">
            <div class="field"><label>Height (cm)</label><input type="number" name="height_cm" step="0.1" value="<%= profHeight %>"/></div>
            <div class="field"><label>Weight (kg)</label><input type="number" name="weight_kg" step="0.1" value="<%= profWeight %>"/></div>
          </div>
          <div class="two-col">
            <div class="field"><label>Age</label><input type="number" name="age" value="<%= profAge %>"/></div>
            <div class="field"><label>Gender</label>
              <select name="gender">
                <option value="male"   <%= "male".equals(profGender)   ? "selected":"" %>>Male</option>
                <option value="female" <%= "female".equals(profGender) ? "selected":"" %>>Female</option>
              </select>
            </div>
          </div>
          <div class="section-divider">Daily Targets</div>
          <div class="two-col">
            <div class="field"><label>Calories (kcal)</label><input type="number" name="calorie_goal" value="<%= goalCal %>"/></div>
            <div class="field"><label>Protein (g)</label>    <input type="number" name="protein_goal" step="0.1" value="<%= goalProtein %>"/></div>
          </div>
          <div class="two-col">
            <div class="field"><label>Carbs (g)</label><input type="number" name="carbs_goal" step="0.1" value="<%= goalCarbs %>"/></div>
            <div class="field"><label>Fats (g)</label> <input type="number" name="fats_goal"  step="0.1" value="<%= goalFats %>"/></div>
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
    <span class="nav-user">Hello, <strong><%= userName != null ? userName : "User" %></strong></span>
    <div class="avatar" onclick="openProfileModal()" title="Edit Profile"><%= initials %></div>
    <button class="btn-logout" onclick="document.getElementById('logout-form').submit()">Sign Out</button>
  </div>
</nav>

<div class="page-body">

  <div class="page-title">My Meal Log</div>
  <div class="page-subtitle">Track your daily nutrition and stay on top of your goals</div>

  <% if (request.getAttribute("successMsg") != null) { %><div class="banner success">&#10003; <%= request.getAttribute("successMsg") %></div><% } %>
  <% if (request.getAttribute("errorMsg")   != null) { %><div class="banner error">&#9888; <%= request.getAttribute("errorMsg") %></div><% } %>

  <!-- Summary -->
  <div class="summary-header">
    <div class="summary-title">Nutrition Overview</div>
    <div class="period-toggle">
      <button class="period-btn active" id="btn-today"   onclick="setPeriod('today')">Today</button>
      <button class="period-btn"        id="btn-alltime" onclick="setPeriod('alltime')">All Time</button>
    </div>
  </div>
  <div class="summary-grid">
    <div class="summary-card"><div class="s-label">Meals</div>    <div class="s-value" id="sum-meals"><%= todayMeals %></div>                            <div class="s-unit">logged</div></div>
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
      <div class="progress-track"><div class="progress-fill <%= todayCalories > goalCal ? "over":"" %>" style="width:<%= pctCal %>%"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-label"><span class="goal-name">&#128167; Protein</span><span class="goal-nums"><span><%= String.format("%.1f",todayProtein) %></span> / <%= String.format("%.0f",goalProtein) %>g</span></div>
      <div class="progress-track"><div class="progress-fill <%= todayProtein > goalProtein ? "over":"" %>" style="width:<%= pctProtein %>%"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-label"><span class="goal-name">&#127858; Carbs</span><span class="goal-nums"><span><%= String.format("%.1f",todayCarbs) %></span> / <%= String.format("%.0f",goalCarbs) %>g</span></div>
      <div class="progress-track"><div class="progress-fill <%= todayCarbs > goalCarbs ? "over":"" %>" style="width:<%= pctCarbs %>%"></div></div>
    </div>
    <div class="goal-card">
      <div class="goal-label"><span class="goal-name">&#129368; Fats</span><span class="goal-nums"><span><%= String.format("%.1f",todayFats) %></span> / <%= String.format("%.0f",goalFats) %>g</span></div>
      <div class="progress-track"><div class="progress-fill <%= todayFats > goalFats ? "over":"" %>" style="width:<%= pctFats %>%"></div></div>
    </div>
  </div>

  <!-- 7-day charts -->
  <div class="charts-section">
    <div class="section-heading">Last 7 Days</div>
    <div class="charts-grid-2">
      <div class="chart-card">
        <div class="chart-title">Calorie Intake</div>
        <canvas id="calChart" class="chart-canvas"></canvas>
      </div>
      <div class="chart-card">
        <div class="chart-title">Macros Breakdown</div>
        <canvas id="macroChart" class="chart-canvas"></canvas>
      </div>
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
          <div class="field"><label>Date</label><input type="date" name="meal_date"/></div>
          <div class="food-group"><div class="food-group-title"><span>🍚</span> Carbs &amp; Grains</div><div id="group-carbs"></div><button type="button" class="btn-add-food" onclick="addRow('carbs')">+ Add item</button></div>
          <div class="food-group"><div class="food-group-title"><span>🍗</span> Proteins &amp; Meat</div><div id="group-proteins"></div><button type="button" class="btn-add-food" onclick="addRow('proteins')">+ Add item</button></div>
          <div class="food-group"><div class="food-group-title"><span>🥦</span> Vegetables</div><div id="group-vegetables"></div><button type="button" class="btn-add-food" onclick="addRow('vegetables')">+ Add item</button></div>
          <div class="food-group"><div class="food-group-title"><span>🍎</span> Fruits</div><div id="group-fruits"></div><button type="button" class="btn-add-food" onclick="addRow('fruits')">+ Add item</button></div>
          <div class="food-group"><div class="food-group-title"><span>🥛</span> Dairy</div><div id="group-dairy"></div><button type="button" class="btn-add-food" onclick="addRow('dairy')">+ Add item</button></div>
          <div class="section-divider">Exercise</div>
          <div class="field">
            <label>Activity &amp; Duration</label>
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

    <!-- Meals table -->
    <div class="card">
      <div class="card-header">
        <h2>My Meals</h2>
        <span class="count-badge" id="visible-count"><%= mealCount %> meal<%= mealCount!=1?"s":"" %></span>
      </div>
      <div class="table-toolbar">
        <input type="text" class="search-input" id="search-input" placeholder="&#128269; Search meals..." oninput="filterTable()"/>
        <input type="date" class="date-filter"  id="date-filter"  onchange="filterTable()"/>
        <button class="btn-clear-filter" onclick="clearFilters()">Clear</button>
      </div>
      <% if (meals == null || meals.isEmpty()) { %>
        <div class="no-data">
          <svg viewBox="0 0 24 24"><path d="M3 3h18v18H3z" stroke-dasharray="4 2"/><path d="M12 8v4M12 16h.01"/></svg>
          No meals logged yet. Add your first meal!
        </div>
      <% } else { %>
        <div class="table-wrap">
          <table id="meals-table">
            <thead><tr><th>Type</th><th>Meal</th><th>Kcal</th><th>Protein</th><th>Carbs</th><th>Fats</th><th>Date</th><th>Actions</th></tr></thead>
            <tbody id="meals-tbody">
              <% for (String[] m : meals) {
                   String tl=m[1].toLowerCase(), bc="badge-other";
                   if      (tl.equals("breakfast")) bc="badge-breakfast";
                   else if (tl.equals("lunch"))     bc="badge-lunch";
                   else if (tl.equals("dinner"))    bc="badge-dinner";
                   else if (tl.equals("snack"))     bc="badge-snack";
              %>
              <tr id="row-<%= m[0] %>" data-date="<%= m[7] %>" data-name="<%= m[2].toLowerCase() %>">
                <td><span class="meal-type-badge <%= bc %>"><%= m[1].isEmpty()?"—":m[1] %></span></td>
                <td><strong><%= m[2].length()>40 ? m[2].substring(0,40)+"…":m[2] %></strong></td>
                <td><%= m[3] %></td><td><%= m[4] %>g</td><td><%= m[5] %>g</td><td><%= m[6] %>g</td>
                <td><%= m[7].isEmpty()?"—":m[7] %></td>
                <td>
                  <button class="btn-edit" onclick="startEdit('<%= m[0] %>')">&#9998; Edit</button>
                  <button class="btn-del"  onclick="doDelete('<%= m[0] %>','<%= m[2] %>')">&#128465;</button>
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
  <div style="margin-top:28px;">
    <div class="section-heading">&#9878; Weight Estimation & Progress Forecast</div>

    <% if (profWeight.isEmpty() || profWeight.equals("0.0") || profWeight.equals("0")) { %>
      <div class="card">
        <div class="card-body">
          <div class="no-data" style="padding:30px 0;">
            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><path d="M12 8v4M12 16h.01"/></svg>
            Set your weight and height in your profile to enable weight estimation.
          </div>
        </div>
      </div>
    <% } else { %>

      <!-- Stats row -->
      <div class="est-grid">
        <div class="est-card">
          <div class="e-label">&#128200; Avg Daily Intake</div>
          <div class="e-value e-green"><%= avgDailyCalories %></div>
          <div class="e-unit">kcal / day (7-day avg)</div>
        </div>
        <div class="est-card">
          <div class="e-label">&#128293; Your TDEE</div>
          <div class="e-value e-green"><%= goalCal %></div>
          <div class="e-unit">kcal / day (maintenance goal)</div>
        </div>
        <div class="est-card">
          <div class="e-label">&#9883; Daily Difference</div>
          <%
            int diff = avgDailyCalories - goalCal;
            String diffColor = diff < 0 ? "e-green" : diff > 0 ? "e-red" : "e-orange";
            String diffSign  = diff > 0 ? "+" : "";
          %>
          <div class="e-value <%= diffColor %>"><%= diffSign %><%= diff %></div>
          <div class="e-unit"><%= diff < 0 ? "kcal deficit per day" : diff > 0 ? "kcal surplus per day" : "at maintenance" %></div>
        </div>
        <div class="est-card">
          <div class="e-label">&#9881; Est. Weekly Change</div>
          <%
            double weeklyKg = (diff * 7.0) / 7700.0;
            String wkSign   = weeklyKg > 0 ? "+" : "";
            String wkColor  = weeklyKg < 0 ? "e-green" : weeklyKg > 0 ? "e-red" : "e-orange";
          %>
          <div class="e-value <%= wkColor %>"><%= wkSign %><%= String.format("%.2f", weeklyKg) %> kg</div>
          <div class="e-unit">per week at current intake</div>
        </div>
        <div class="est-card">
          <div class="e-label">&#128170; Current Weight</div>
          <div class="e-value e-green"><%= profWeight %></div>
          <div class="e-unit">kg (from your profile)</div>
        </div>
      </div>

      <!-- Advice box -->
      <%
        String adviceClass, adviceTitle, adviceText;
        if (diff < -100) {
          adviceClass = "lose";
          adviceTitle = "You are in a calorie deficit";
          adviceText  = "At your current average intake of " + avgDailyCalories + " kcal/day, you are consuming " + Math.abs(diff) + " kcal less than your maintenance level. This means you are on track to lose approximately " + String.format("%.2f", Math.abs(weeklyKg)) + " kg per week. Ensure your protein intake remains high to preserve muscle mass while losing fat.";
        } else if (diff > 100) {
          adviceClass = "gain";
          adviceTitle = "You are in a calorie surplus";
          adviceText  = "At your current average intake of " + avgDailyCalories + " kcal/day, you are consuming " + diff + " kcal more than your maintenance level. This means you are on track to gain approximately " + String.format("%.2f", weeklyKg) + " kg per week. If your goal is muscle gain, pair this surplus with resistance training.";
        } else if (avgDailyCalories == 0) {
          adviceClass = "warning";
          adviceTitle = "No recent meal data";
          adviceText  = "You have not logged any meals in the past 7 days. Start logging your meals to get an accurate weight estimation and calorie analysis.";
        } else {
          adviceClass = "maintain";
          adviceTitle = "You are at maintenance";
          adviceText  = "Your average daily intake of " + avgDailyCalories + " kcal is very close to your maintenance level. Your weight is likely to remain stable at this rate. Adjust your intake up or down depending on whether you want to gain or lose weight.";
        }
      %>
      <div class="advice-box <%= adviceClass %>">
        <div class="advice-title">&#128161; <%= adviceTitle %></div>
        <div class="advice-text"><%= adviceText %></div>
      </div>

      <!-- Target weight calculator -->
      <div class="card">
        <div class="card-header"><h2>&#127919; Reach My Target Weight</h2></div>
        <div class="card-body">

          <div class="target-calc">
            <div class="target-calc-title">How long will it take?</div>
            <div class="target-inputs">
              <div class="field" style="margin-bottom:0;">
                <label>Current Weight (kg)</label>
                <input type="number" id="tc-current" placeholder="e.g. 80" step="0.1" value="<%= profWeight %>" oninput="calcTarget()"/>
              </div>
              <div class="field" style="margin-bottom:0;">
                <label>Target Weight (kg)</label>
                <input type="number" id="tc-target" placeholder="e.g. 70" step="0.1" oninput="calcTarget()"/>
              </div>
              <div class="field" style="margin-bottom:0;">
                <label>Daily Calories (kcal)</label>
                <input type="number" id="tc-intake" placeholder="e.g. 1800" value="<%= avgDailyCalories > 0 ? avgDailyCalories : goalCal %>" oninput="calcTarget()"/>
              </div>
            </div>
            <div class="target-result" id="tc-result"></div>
          </div>

          <!-- Calorie slider -->
          <div class="intake-adjuster">
            <div class="intake-adjuster-title">&#127922; What if I adjust my daily intake?</div>
            <div class="slider-row">
              <label style="font-size:0.78rem;font-weight:600;color:var(--muted);white-space:nowrap;">Daily kcal:</label>
              <input type="range" id="slider-cal" min="800" max="4000" step="50" value="<%= avgDailyCalories > 0 ? avgDailyCalories : goalCal %>" oninput="updateSlider()"/>
              <span class="slider-val" id="slider-val"><%= avgDailyCalories > 0 ? avgDailyCalories : goalCal %> kcal</span>
            </div>
            <div class="slider-result" id="slider-result"></div>
          </div>

        </div>
      </div>

    <% } %>
  </div>

</div><!-- end page-body -->

<script>
// ── Summary toggle ──
var DATA = {
  today:   { meals:<%= todayMeals %>, cal:<%= todayCalories %>, protein:'<%= String.format("%.1f",todayProtein) %>', carbs:'<%= String.format("%.1f",todayCarbs) %>', fats:'<%= String.format("%.1f",todayFats) %>' },
  alltime: { meals:<%= mealCount %>,  cal:<%= totalCalories %>, protein:'<%= String.format("%.1f",totalProtein) %>', carbs:'<%= String.format("%.1f",totalCarbs) %>', fats:'<%= String.format("%.1f",totalFats) %>' }
};
function setPeriod(p) {
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
var SEVEN = {
  labels:  [<%= chartLabels %>],
  cal:     [<%= chartCal %>],
  protein: [<%= chartProtein %>],
  carbs:   [<%= chartCarbs %>],
  fats:    [<%= chartFats %>]
};
var GOAL_CAL = <%= goalCal %>;
var TDEE     = <%= goalCal %>;

function initCharts() {
  new Chart(document.getElementById('calChart'), {
    type: 'bar',
    data: {
      labels: SEVEN.labels,
      datasets: [
        { label:'Calories', data: SEVEN.cal, backgroundColor:'rgba(61,122,90,0.7)', borderColor:'#3d7a5a', borderWidth:1, borderRadius:4 },
        { label:'Goal',     data: SEVEN.labels.map(function(){ return GOAL_CAL; }), type:'line', borderColor:'#c0392b', borderWidth:2, borderDash:[5,5], pointRadius:0, fill:false }
      ]
    },
    options: { responsive:true, maintainAspectRatio:false, plugins:{ legend:{ labels:{ font:{ size:11 } } } }, scales:{ x:{ ticks:{ font:{ size:10 } }, grid:{ display:false } }, y:{ ticks:{ font:{ size:10 } }, beginAtZero:true, grid:{ color:'#f0f4f2' } } } }
  });
  new Chart(document.getElementById('macroChart'), {
    type: 'bar',
    data: {
      labels: SEVEN.labels,
      datasets: [
        { label:'Protein', data: SEVEN.protein, backgroundColor:'rgba(69,39,160,0.75)',  borderRadius:3 },
        { label:'Carbs',   data: SEVEN.carbs,   backgroundColor:'rgba(245,127,23,0.75)', borderRadius:3 },
        { label:'Fats',    data: SEVEN.fats,    backgroundColor:'rgba(136,14,79,0.75)',  borderRadius:3 }
      ]
    },
    options: { responsive:true, maintainAspectRatio:false, plugins:{ legend:{ position:'bottom', labels:{ font:{ size:10 }, padding:8 } } }, scales:{ x:{ stacked:true, ticks:{ font:{ size:10 } }, grid:{ display:false } }, y:{ stacked:true, ticks:{ font:{ size:10 } }, beginAtZero:true, grid:{ color:'#f0f4f2' } } } }
  });
}

// ── Target weight calculator ──
function calcTarget() {
  var current = parseFloat(document.getElementById('tc-current').value);
  var target  = parseFloat(document.getElementById('tc-target').value);
  var intake  = parseFloat(document.getElementById('tc-intake').value);
  var el      = document.getElementById('tc-result');

  if (!current || !target || !intake) { el.className='target-result'; return; }

  var diff        = intake - TDEE;               // negative = deficit, positive = surplus
  var weightDiff  = target - current;             // negative = lose, positive = gain
  var weeklyKg    = (diff * 7.0) / 7700.0;        // kg change per week

  if (Math.abs(diff) < 50) {
    el.className   = 'target-result show neutral';
    el.innerHTML   = '&#9888; Your intake is essentially at maintenance (' + intake + ' kcal). You need a caloric deficit or surplus to change your weight.';
    return;
  }
  if ((weightDiff < 0 && diff > 0) || (weightDiff > 0 && diff < 0)) {
    el.className   = 'target-result show neutral';
    el.innerHTML   = '&#9888; Your calorie direction does not match your target. To ' + (weightDiff < 0 ? 'lose' : 'gain') + ' weight, you need a ' + (weightDiff < 0 ? 'deficit' : 'surplus') + '.';
    return;
  }

  var weeksNeeded = Math.abs(weeklyKg) > 0 ? Math.abs(weightDiff / weeklyKg) : 0;
  var daysNeeded  = Math.round(weeksNeeded * 7);
  var months      = Math.floor(daysNeeded / 30);
  var days        = daysNeeded % 30;

  var timeStr = months > 0 ? months + ' month' + (months>1?'s':'') + (days>0?' and '+days+' day'+(days>1?'s':''):'') : days + ' day' + (days>1?'s':'');
  var cls     = weightDiff < 0 ? 'positive' : 'negative';

  el.className = 'target-result show ' + cls;
  el.innerHTML = '&#127919; At ' + intake + ' kcal/day you have a ' + Math.abs(diff) + ' kcal ' + (diff<0?'deficit':'surplus') + ' per day. '
    + 'You will ' + (weightDiff<0?'lose':'gain') + ' approximately ' + String(Math.abs(weeklyKg).toFixed(2)) + ' kg per week. '
    + 'Estimated time to reach ' + target + ' kg: <strong>' + timeStr + '</strong>.';
}

// ── Calorie slider ──
function updateSlider() {
  var intake    = parseInt(document.getElementById('slider-cal').value);
  var diff      = intake - TDEE;
  var weeklyKg  = (diff * 7.0) / 7700.0;
  var sign      = weeklyKg > 0 ? '+' : '';
  document.getElementById('slider-val').textContent = intake + ' kcal';

  var direction, tip;
  if      (diff < -100) { direction = '&#128168; Deficit of ' + Math.abs(diff) + ' kcal/day — you will lose approximately ' + Math.abs(weeklyKg).toFixed(2) + ' kg per week.'; tip = 'Good for weight loss. Make sure you are getting enough protein.'; }
  else if (diff >  100) { direction = '&#128170; Surplus of ' + diff + ' kcal/day — you will gain approximately ' + weeklyKg.toFixed(2) + ' kg per week.'; tip = 'Good for muscle gain. Pair with resistance training for best results.'; }
  else                  { direction = '&#9889; Maintenance — your weight will stay stable at approximately ' + TDEE + ' kcal/day.'; tip = 'Ideal if you are happy with your current weight.'; }

  document.getElementById('slider-result').innerHTML = '<strong>' + direction + '</strong><br/><span style="color:var(--muted);font-size:0.82rem;">' + tip + '</span>';
}

// ── Food database ──
var FOODS = {
  carbs:      { "Rice":{cal:130,protein:2.7,carbs:28.0,fats:0.3},"Bread":{cal:265,protein:9.0,carbs:49.0,fats:3.2},"Pasta":{cal:131,protein:5.0,carbs:25.0,fats:1.1},"Oats":{cal:389,protein:17.0,carbs:66.0,fats:7.0},"Potato":{cal:77,protein:2.0,carbs:17.0,fats:0.1},"Noodles":{cal:138,protein:4.5,carbs:25.0,fats:2.2},"Corn":{cal:86,protein:3.2,carbs:19.0,fats:1.2},"Sweet Potato":{cal:86,protein:1.6,carbs:20.0,fats:0.1} },
  proteins:   { "Chicken Breast":{cal:165,protein:31.0,carbs:0.0,fats:3.6},"Mutton":{cal:294,protein:25.0,carbs:0.0,fats:21.0},"Pork":{cal:242,protein:27.0,carbs:0.0,fats:14.0},"Beef":{cal:250,protein:26.0,carbs:0.0,fats:15.0},"Tuna":{cal:132,protein:28.0,carbs:0.0,fats:1.3},"Salmon":{cal:208,protein:20.0,carbs:0.0,fats:13.0},"Eggs":{cal:155,protein:13.0,carbs:1.1,fats:11.0},"Shrimp":{cal:99,protein:24.0,carbs:0.2,fats:0.3},"Tofu":{cal:76,protein:8.0,carbs:1.9,fats:4.8} },
  vegetables: { "Broccoli":{cal:34,protein:2.8,carbs:7.0,fats:0.4},"Spinach":{cal:23,protein:2.9,carbs:3.6,fats:0.4},"Carrot":{cal:41,protein:0.9,carbs:10.0,fats:0.2},"Tomato":{cal:18,protein:0.9,carbs:3.9,fats:0.2},"Cucumber":{cal:15,protein:0.7,carbs:3.6,fats:0.1},"Cabbage":{cal:25,protein:1.3,carbs:6.0,fats:0.1},"Bell Pepper":{cal:31,protein:1.0,carbs:6.0,fats:0.3},"Onion":{cal:40,protein:1.1,carbs:9.3,fats:0.1},"Mushroom":{cal:22,protein:3.1,carbs:3.3,fats:0.3} },
  fruits:     { "Apple":{cal:52,protein:0.3,carbs:14.0,fats:0.2},"Banana":{cal:89,protein:1.1,carbs:23.0,fats:0.3},"Orange":{cal:47,protein:0.9,carbs:12.0,fats:0.1},"Mango":{cal:60,protein:0.8,carbs:15.0,fats:0.4},"Grapes":{cal:69,protein:0.7,carbs:18.0,fats:0.2},"Strawberry":{cal:32,protein:0.7,carbs:7.7,fats:0.3},"Watermelon":{cal:30,protein:0.6,carbs:7.6,fats:0.2},"Pineapple":{cal:50,protein:0.5,carbs:13.0,fats:0.1} },
  dairy:      { "Milk":{cal:42,protein:3.4,carbs:5.0,fats:1.0},"Cheese":{cal:402,protein:25.0,carbs:1.3,fats:33.0},"Yogurt":{cal:59,protein:10.0,carbs:3.6,fats:0.4},"Butter":{cal:717,protein:0.9,carbs:0.1,fats:81.0},"Cream":{cal:340,protein:2.1,carbs:2.8,fats:36.0} }
};
var rowCounts = { carbs:0, proteins:0, vegetables:0, fruits:0, dairy:0 };

function addRow(group) {
  var c=document.getElementById('group-'+group), idx=rowCounts[group]++, rid=group+'-'+idx;
  var row=document.createElement('div'); row.className='food-row'; row.id='frow-'+rid;
  var opts='<option value="">— Select —</option>';
  for (var n in FOODS[group]) opts+='<option value="'+n+'">'+n+'</option>';
  row.innerHTML='<select onchange="recalculate()" id="sel-'+rid+'">'+opts+'</select><input type="number" id="grm-'+rid+'" placeholder="grams" min="0" step="1" oninput="recalculate()"/><span class="gram-label">g</span><button type="button" class="btn-remove-row" onclick="removeRow(\''+rid+'\')">✕</button>';
  c.appendChild(row);
}
function removeRow(rid) { var r=document.getElementById('frow-'+rid); if(r) r.remove(); recalculate(); }

function recalculate() {
  var totCal=0,totPro=0,totCarb=0,totFat=0,names=[];
  ['carbs','proteins','vegetables','fruits','dairy'].forEach(function(g){
    document.getElementById('group-'+g).querySelectorAll('.food-row').forEach(function(row){
      var sel=row.querySelector('select'),grm=row.querySelector('input[type="number"]');
      if(!sel||!grm) return;
      var food=sel.value,grams=parseFloat(grm.value)||0;
      if(!food||grams<=0) return;
      var m=FOODS[g][food]; if(!m) return;
      var f=grams/100; totCal+=m.cal*f; totPro+=m.protein*f; totCarb+=m.carbs*f; totFat+=m.fats*f;
      names.push(food+'('+grams+'g)');
    });
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
function getBurn() { return (parseFloat(document.getElementById('exercise-type').value)||0)*(parseFloat(document.getElementById('exercise-mins').value)||0); }
function updateBurn() { var b=getBurn(); document.getElementById('burn-display').textContent=b>0?'🔥 '+Math.round(b)+' kcal burned — will be subtracted':''; recalculate(); }
function prepareSubmit() { if(!document.getElementById('hid-meal_name').value.trim()){ alert('Please select at least one food item.'); return false; } return true; }

// ── Pagination + filter ──
var PAGE_SIZE=10,currentPage=1,filteredRows=[];
function getAllDataRows(){ var t=document.getElementById('meals-tbody'); return t?Array.from(t.querySelectorAll('tr[id^="row-"]')):[];}
function filterTable(){
  var search=(document.getElementById('search-input').value||'').toLowerCase();
  var date=document.getElementById('date-filter').value||'';
  filteredRows=getAllDataRows().filter(function(r){ return (!search||(r.getAttribute('data-name')||'').indexOf(search)!==-1)&&(!date||(r.getAttribute('data-date')||'')===date); });
  currentPage=1; renderPage();
}
function renderPage(){
  var rows=getAllDataRows(),total=filteredRows.length,pages=Math.max(1,Math.ceil(total/PAGE_SIZE));
  var start=(currentPage-1)*PAGE_SIZE,end=Math.min(start+PAGE_SIZE,total);
  rows.forEach(function(r){ r.style.display='none'; var er=document.getElementById('edit-row-'+r.id.replace('row-','')); if(er) er.style.display='none'; });
  filteredRows.slice(start,end).forEach(function(r){ r.style.display=''; });
  var info=document.getElementById('page-info'); if(info) info.textContent=total===0?'No meals found':'Showing '+(start+1)+'–'+end+' of '+total;
  var badge=document.getElementById('visible-count'); if(badge) badge.textContent=total+' meal'+(total!==1?'s':'');
  var btns=document.getElementById('page-btns'); if(!btns) return; btns.innerHTML='';
  var prev=document.createElement('button'); prev.className='page-btn'; prev.textContent='← Prev'; prev.disabled=currentPage===1; prev.onclick=function(){ currentPage--; renderPage(); }; btns.appendChild(prev);
  for(var i=Math.max(1,currentPage-2);i<=Math.min(pages,Math.max(1,currentPage-2)+4);i++){ (function(p){ var b=document.createElement('button'); b.className='page-btn'+(p===currentPage?' active':''); b.textContent=p; b.onclick=function(){ currentPage=p; renderPage(); }; btns.appendChild(b); })(i); }
  var next=document.createElement('button'); next.className='page-btn'; next.textContent='Next →'; next.disabled=currentPage===pages; next.onclick=function(){ currentPage++; renderPage(); }; btns.appendChild(next);
}
function clearFilters(){ document.getElementById('search-input').value=''; document.getElementById('date-filter').value=''; filterTable(); }

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
function selectGoal(type){
  selectedGoal=type;
  document.getElementById('setup-goal-type').value=type;
  ['lose','maintain','gain'].forEach(function(t){ document.getElementById('gt-'+t).classList.toggle('selected',t===type); });
}
function calcBMI(){
  var w=parseFloat(document.getElementById('setup-weight').value);
  var h=parseFloat(document.getElementById('setup-height').value)/100;
  var box=document.getElementById('bmi-box');
  if(!w||!h||h<=0){ box.classList.remove('show'); return; }
  var bmi=w/(h*h), val=bmi.toFixed(1), cat,cls,tip;
  if      (bmi<18.5){ cat='Underweight'; cls='underweight'; tip='You are below a healthy weight. A Gain Weight goal is recommended.'; }
  else if (bmi<25.0){ cat='Normal Weight'; cls='normal';    tip='You are within a healthy BMI range. Maintenance or a slight surplus is ideal.'; }
  else if (bmi<30.0){ cat='Overweight';   cls='overweight'; tip='A moderate calorie deficit with regular exercise is recommended.'; }
  else              { cat='Obese';         cls='obese';      tip='A calorie deficit and regular activity are strongly recommended. Consider consulting a professional.'; }
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
function skipSetup(){ document.getElementById('setupOverlay').classList.add('hidden'); }

// ── Inline edit / delete ──
function startEdit(id)  { document.getElementById('row-'+id).style.display='none'; document.getElementById('edit-row-'+id).style.display=''; }
function cancelEdit(id) { document.getElementById('edit-row-'+id).style.display='none'; document.getElementById('row-'+id).style.display=''; }
function saveEdit(id){
  var name=document.getElementById('er-name-'+id).value.trim();
  if(!name){ alert('Meal name cannot be empty.'); return; }
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
function doDelete(id,name){ if(!confirm('Delete "'+name+'"? This cannot be undone.')) return; document.getElementById('delete-id').value=id; document.getElementById('delete-form').submit(); }

window.onload = function(){
  ['carbs','proteins','vegetables','fruits','dairy'].forEach(function(g){ addRow(g); });
  filteredRows=getAllDataRows(); renderPage(); initCharts();
  calcTarget(); updateSlider();
};
</script>
</body>
</html>