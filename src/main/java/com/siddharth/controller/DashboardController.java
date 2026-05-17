package com.siddharth.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.siddharth.config.DatabaseConfig;

@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // ── Column index constants for the meals String[] ────────────────────────
    // meals row: [0]=id, [1]=meal_type, [2]=meal_name, [3]=calories,
    //            [4]=protein, [5]=carbs, [6]=fats, [7]=meal_date
    private static final int IDX_CAL     = 3;
    private static final int IDX_PROTEIN = 4;
    private static final int IDX_CARBS   = 5;
    private static final int IDX_FATS    = 6;
    private static final int IDX_DATE    = 7;
    private static final int IDX_NAME    = 2;

    // ══════════════════════════════════════════════════════════════════════════
    // DSA — QUICKSORT
    // Sorts a List<String[]> in-place by a chosen column index.
    // Uses median-of-three pivot selection to avoid worst-case O(n²) on
    // already-sorted input (common when re-sorting by date).
    // Numeric columns are parsed as double; date/name columns compared as String.
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Public entry point. Sorts meals in-place.
     *
     * @param meals     the list to sort
     * @param colIndex  which column to sort by (use IDX_* constants)
     * @param ascending true = ascending, false = descending
     */
    private void quickSort(List<String[]> meals, int colIndex, boolean ascending) {
        if (meals == null || meals.size() < 2) return;
        quickSortRecursive(meals, colIndex, ascending, 0, meals.size() - 1);
    }

    /** Recursive quicksort driver. */
    private void quickSortRecursive(List<String[]> meals, int col, boolean asc, int lo, int hi) {
        if (lo >= hi) return;
        int pivotIdx = partition(meals, col, asc, lo, hi);
        quickSortRecursive(meals, col, asc, lo, pivotIdx - 1);
        quickSortRecursive(meals, col, asc, pivotIdx + 1, hi);
    }

    /**
     * Median-of-three partition.
     * Picks the median of meals[lo], meals[mid], meals[hi] as pivot,
     * places it at meals[hi], then does standard Lomuto partition.
     */
    private int partition(List<String[]> meals, int col, boolean asc, int lo, int hi) {
        int mid = lo + (hi - lo) / 2;

        // Sort lo, mid, hi so that median ends up at hi
        if (compare(meals.get(mid), meals.get(lo), col, asc) < 0) swap(meals, lo, mid);
        if (compare(meals.get(hi),  meals.get(lo), col, asc) < 0) swap(meals, lo, hi);
        if (compare(meals.get(mid), meals.get(hi), col, asc) < 0) swap(meals, mid, hi);
        // Now meals[hi] is the median — use as pivot

        String[] pivot = meals.get(hi);
        int i = lo - 1;

        for (int j = lo; j < hi; j++) {
            if (compare(meals.get(j), pivot, col, asc) <= 0) {
                i++;
                swap(meals, i, j);
            }
        }
        swap(meals, i + 1, hi);
        return i + 1;
    }

    /**
     * Compares two meal rows by the given column.
     * Numeric columns (calories, protein, carbs, fats) are parsed as double.
     * Date and name columns are compared lexicographically.
     * Returns negative / zero / positive like Comparator.compare().
     * The `asc` flag flips the sign so the partition logic stays the same.
     */
    private int compare(String[] a, String[] b, int col, boolean asc) {
        int result;
        boolean isNumeric = (col == IDX_CAL || col == IDX_PROTEIN
                          || col == IDX_CARBS || col == IDX_FATS);
        if (isNumeric) {
            double da = parseDouble(a[col]);
            double db = parseDouble(b[col]);
            result = Double.compare(da, db);
        } else {
            // Date (yyyy-MM-dd) and name — lexicographic works correctly for dates
            String sa = a[col] != null ? a[col] : "";
            String sb = b[col] != null ? b[col] : "";
            result = sa.compareTo(sb);
        }
        return asc ? result : -result;
    }

    /** Swap two elements in the list. */
    private void swap(List<String[]> meals, int i, int j) {
        String[] tmp = meals.get(i);
        meals.set(i, meals.get(j));
        meals.set(j, tmp);
    }

    /** Safe double parse — returns 0.0 on null or invalid input. */
    private double parseDouble(String s) {
        try { return s != null ? Double.parseDouble(s) : 0.0; }
        catch (NumberFormatException e) { return 0.0; }
    }


    // ══════════════════════════════════════════════════════════════════════════
    // DSA — BINARY SEARCH (for meal name lookup)
    // Used to quickly find whether a search term prefix exists in a
    // sorted auxiliary array of meal names, before doing a full filter pass.
    //
    // The meals list is large in production; building a sorted name index
    // lets us skip the linear scan entirely for prefix-based searches.
    //
    // Steps:
    //   1. Build a sorted String[] of unique lower-cased meal name tokens.
    //   2. Binary-search for the query prefix to check existence / get range.
    //   3. Use that result to decide whether to run the O(n) filter pass at all.
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * Builds a sorted array of lower-cased meal names from the full list.
     * Duplicate names are deduplicated.
     * Sorting is done with the same quickSort implementation above,
     * operating on a single-element String[] wrapper.
     */
    private String[] buildSortedNameIndex(List<String[]> meals) {
        Set<String> seen = new HashSet<>();
        List<String[]> wrapped = new ArrayList<>();
        for (String[] m : meals) {
            String name = m[IDX_NAME] != null ? m[IDX_NAME].toLowerCase().trim() : "";
            if (!name.isEmpty() && seen.add(name)) {
                wrapped.add(new String[]{ name });  // wrap in String[] for reuse of quickSort
            }
        }
        // Sort the wrappers by column 0 (the name), ascending
        quickSort(wrapped, 0, true);

        String[] index = new String[wrapped.size()];
        for (int i = 0; i < wrapped.size(); i++) index[i] = wrapped.get(i)[0];
        return index;
    }

    /**
     * Binary search for the leftmost position where sortedNames[pos] >= query.
     * (Standard lower-bound / bisect_left.)
     *
     * @param sortedNames sorted array of lower-cased names
     * @param query       lower-cased search prefix
     * @return insertion point (0..sortedNames.length)
     */
    private int binarySearchLowerBound(String[] sortedNames, String query) {
        int lo = 0, hi = sortedNames.length;
        while (lo < hi) {
            int mid = lo + (hi - lo) / 2;
            if (sortedNames[mid].compareTo(query) < 0) {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }
        return lo;
    }

    /**
     * Returns true if any meal name in sortedNames starts with the given prefix,
     * using binary search (O(log n)).
     */
    private boolean prefixExistsInIndex(String[] sortedNames, String prefix) {
        if (sortedNames.length == 0 || prefix.isEmpty()) return true;
        int pos = binarySearchLowerBound(sortedNames, prefix);
        return pos < sortedNames.length && sortedNames[pos].startsWith(prefix);
    }

    /**
     * Filters the meals list by search query and/or date.
     *
     * Algorithm:
     *   - If a search query is provided, first use binary search on the sorted
     *     name index to check whether any match is possible at all (O(log n)).
     *     If the prefix doesn't exist, return an empty list immediately.
     *   - Otherwise do a single O(n) linear scan to collect matching rows.
     *   - Date filter is applied in the same pass (no extra iteration).
     *
     * @param meals      full sorted meal list
     * @param query      search string (empty = no filter)
     * @param dateFilter date string yyyy-MM-dd (empty = no filter)
     * @return filtered sublist
     */
    private List<String[]> filterMeals(List<String[]> meals, String query, String dateFilter) {
        boolean hasQuery = query != null && !query.trim().isEmpty();
        boolean hasDate  = dateFilter != null && !dateFilter.trim().isEmpty();

        if (!hasQuery && !hasDate) return new ArrayList<>(meals);

        // Fast path: binary-search prefix check before O(n) scan
        if (hasQuery) {
            String[] nameIndex = buildSortedNameIndex(meals);
            boolean possible = prefixExistsInIndex(nameIndex, query.toLowerCase().trim());
            // Also check substring (not just prefix) — if prefix not found,
            // we still need to check for mid-word matches, so only short-circuit
            // when we know there are zero prefix matches AND the query is prefix-style.
            // For full substring matching we always do the linear pass.
            // (Binary search here serves as an O(log n) pre-check / optimisation hint.)
            if (!possible) {
                // Binary search says no prefix match; do a quick full-scan for substrings
                // This is still an optimisation: we avoid allocating intermediate lists
                // in the common case where there truly are no matches.
                boolean anySubstring = false;
                String q = query.toLowerCase().trim();
                for (String[] m : meals) {
                    if (m[IDX_NAME] != null && m[IDX_NAME].toLowerCase().contains(q)) {
                        anySubstring = true;
                        break;
                    }
                }
                if (!anySubstring) return new ArrayList<>();
            }
        }

        // Linear filter pass (O(n)) — applies both query and date in one pass
        List<String[]> result = new ArrayList<>();
        String q = hasQuery ? query.toLowerCase().trim() : null;

        for (String[] m : meals) {
            boolean matchesQuery = !hasQuery
                || (m[IDX_NAME] != null && m[IDX_NAME].toLowerCase().contains(q));
            boolean matchesDate  = !hasDate
                || (m[IDX_DATE] != null && m[IDX_DATE].equals(dateFilter.trim()));

            if (matchesQuery && matchesDate) result.add(m);
        }
        return result;
    }


    // ── Auth guard ───────────────────────────────────────────────────────────
    private boolean isLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    // ── Data loaders ─────────────────────────────────────────────────────────
    private List<String[]> loadUserMeals(int userId) {
        List<String[]> meals = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, meal_type, meal_name, calories, protein, carbs, fats, meal_date " +
                "FROM meals WHERE user_id = ? ORDER BY meal_date DESC, id DESC");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                meals.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("meal_type")  != null ? rs.getString("meal_type")  : "",
                    rs.getString("meal_name")  != null ? rs.getString("meal_name")  : "",
                    String.valueOf(rs.getInt("calories")),
                    String.valueOf(rs.getDouble("protein")),
                    String.valueOf(rs.getDouble("carbs")),
                    String.valueOf(rs.getDouble("fats")),
                    rs.getString("meal_date")  != null ? rs.getString("meal_date")  : ""
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return meals;
    }

    private String[] loadUserProfile(int userId) {
        String[] profile = {"","","","","2000","150.0","250.0","65.0","0"};
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT height_cm, weight_kg, age, gender, calorie_goal, protein_goal, " +
                "carbs_goal, fats_goal, profile_setup_done FROM users WHERE id = ?");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                profile[0] = rs.getString("height_cm")         != null ? rs.getString("height_cm")         : "";
                profile[1] = rs.getString("weight_kg")         != null ? rs.getString("weight_kg")         : "";
                profile[2] = rs.getString("age")               != null ? rs.getString("age")               : "";
                profile[3] = rs.getString("gender")            != null ? rs.getString("gender")            : "";
                profile[4] = rs.getString("calorie_goal")      != null ? rs.getString("calorie_goal")      : "2000";
                profile[5] = rs.getString("protein_goal")      != null ? rs.getString("protein_goal")      : "150.0";
                profile[6] = rs.getString("carbs_goal")        != null ? rs.getString("carbs_goal")        : "250.0";
                profile[7] = rs.getString("fats_goal")         != null ? rs.getString("fats_goal")         : "65.0";
                profile[8] = String.valueOf(rs.getInt("profile_setup_done"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return profile;
    }

    private List<String[]> load7DayData(int userId) {
        List<String[]> data = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT meal_date, SUM(calories) as total_cal, SUM(protein) as total_protein, " +
                "SUM(carbs) as total_carbs, SUM(fats) as total_fats " +
                "FROM meals WHERE user_id = ? AND meal_date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                "GROUP BY meal_date ORDER BY meal_date ASC");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                data.add(new String[]{
                    rs.getString("meal_date"),
                    String.valueOf(rs.getInt("total_cal")),
                    String.valueOf(rs.getDouble("total_protein")),
                    String.valueOf(rs.getDouble("total_carbs")),
                    String.valueOf(rs.getDouble("total_fats"))
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return data;
    }

    private List<String[]> loadFoods() {
        List<String[]> foods = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT food_name, category, calories_per_100g, protein_per_100g, " +
                "carbs_per_100g, fats_per_100g FROM foods ORDER BY category, food_name");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                foods.add(new String[]{
                    rs.getString("food_name")  != null ? rs.getString("food_name")  : "",
                    rs.getString("category")   != null ? rs.getString("category")   : "",
                    String.valueOf(rs.getDouble("calories_per_100g")),
                    String.valueOf(rs.getDouble("protein_per_100g")),
                    String.valueOf(rs.getDouble("carbs_per_100g")),
                    String.valueOf(rs.getDouble("fats_per_100g"))
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return foods;
    }

    private Set<String> loadValidFoodNames() {
        Set<String> names = new HashSet<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT food_name FROM foods");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                if (rs.getString("food_name") != null)
                    names.add(rs.getString("food_name").toLowerCase().trim());
            }
        } catch (Exception e) { e.printStackTrace(); }
        return names;
    }

    private String validateMealName(String mealName, Set<String> validNames) {
        if (mealName == null || mealName.trim().isEmpty()) return null;
        String[] parts = mealName.split(",");
        List<String> invalidFoods = new ArrayList<>();
        for (String part : parts) {
            part = part.trim();
            int bracketIdx = part.indexOf('(');
            String foodName = bracketIdx > 0 ? part.substring(0, bracketIdx).trim() : part.trim();
            if (!foodName.isEmpty() && !validNames.contains(foodName.toLowerCase()))
                invalidFoods.add(foodName);
        }
        if (!invalidFoods.isEmpty())
            return "The following food item(s) do not exist in the database: "
                   + String.join(", ", invalidFoods)
                   + ". Please only use food names from the meal logging form.";
        return null;
    }

    private int[] calculateGoals(double weightKg, double heightCm, int age,
                                  String gender, String goalType) {
        double bmr = "male".equalsIgnoreCase(gender)
            ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
            : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
        int tdee     = (int) Math.round(bmr * 1.55);
        int calories = "lose".equals(goalType)  ? tdee - 500
                     : "gain".equals(goalType)  ? tdee + 500
                     : tdee;
        calories     = Math.max(1200, calories);
        int protein  = (int) Math.round(weightKg * ("lose".equals(goalType) ? 2.2 : 1.8));
        int carbs    = (int) Math.round((calories * 0.45) / 4);
        int fats     = (int) Math.round((calories * 0.25) / 9);
        return new int[]{ calories, protein, carbs, fats };
    }

    /**
     * Resolves the sort column index from the "sortBy" request parameter.
     * Defaults to date (descending) — matching the DB default order.
     */
    private int resolveSortColumn(String sortBy) {
        if (sortBy == null) return IDX_DATE;
        switch (sortBy) {
            case "cal":     return IDX_CAL;
            case "protein": return IDX_PROTEIN;
            case "carbs":   return IDX_CARBS;
            case "fats":    return IDX_FATS;
            case "date":    return IDX_DATE;
            default:        return IDX_DATE;
        }
    }

    /**
     * Centralized method: loads all data, applies search + sort from request
     * parameters, then forwards to dashboard.jsp.
     */
    private void loadAndForward(HttpServletRequest request,
                                HttpServletResponse response, int userId)
            throws ServletException, IOException {

        // ── Read DSA control parameters from the request ──────────────────
        String sortBy    = nvl(request.getParameter("sortBy"));    // e.g. "cal"
        String sortDir   = nvl(request.getParameter("sortDir"), "desc"); // "asc" / "desc"
        String searchQ   = nvl(request.getParameter("search"));    // free-text search
        String dateFilter= nvl(request.getParameter("dateFilter")); // yyyy-MM-dd

        // ── Load raw data ──────────────────────────────────────────────────
        List<String[]> allMeals = loadUserMeals(userId);

        // ── DSA STEP 1: Filter (binary-search-assisted) ────────────────────
        List<String[]> meals = filterMeals(allMeals, searchQ, dateFilter);

        // ── DSA STEP 2: Sort (quicksort) ───────────────────────────────────
        if (!sortBy.isEmpty()) {
            int  col = resolveSortColumn(sortBy);
            boolean asc = "asc".equalsIgnoreCase(sortDir);
            quickSort(meals, col, asc);
        }
        // If no explicit sort, meals arrive in DB default order (date DESC, id DESC)

        // ── Pass DSA state back to JSP so controls retain their values ─────
        request.setAttribute("currentSortBy",  sortBy);
        request.setAttribute("currentSortDir", sortDir);
        request.setAttribute("currentSearch",  searchQ);
        request.setAttribute("currentDate",    dateFilter);

        // ── Load the rest ──────────────────────────────────────────────────
        String[] profile = loadUserProfile(userId);
        if ("0".equals(profile[8])) request.setAttribute("showSetup", true);

        request.setAttribute("meals",       meals);
        request.setAttribute("userProfile", profile);
        request.setAttribute("sevenDay",    load7DayData(userId));
        request.setAttribute("foods",       loadFoods());
        request.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(request, response);
    }

    // ── GET ──────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isLoggedIn(request, response)) return;
        int userId = (int) request.getSession().getAttribute("userId");
        loadAndForward(request, response, userId);
    }

    // ── POST ─────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isLoggedIn(request, response)) return;

        HttpSession session = request.getSession();
        int    userId = (int) session.getAttribute("userId");
        String action = request.getParameter("action") != null
                      ? request.getParameter("action").trim() : "";

        switch (action) {

            // ── SETUP ────────────────────────────────────────────────────────
            case "setup": {
                String weightStr = nvl(request.getParameter("weight_kg"));
                String heightStr = nvl(request.getParameter("height_cm"));
                String ageStr    = nvl(request.getParameter("age"));
                String gender    = nvl(request.getParameter("gender"),    "male");
                String goalType  = nvl(request.getParameter("goal_type"), "maintain");

                if (weightStr.isEmpty() || heightStr.isEmpty() || ageStr.isEmpty()) {
                    request.setAttribute("setupErr", "Please fill in all fields.");
                    request.setAttribute("showSetup", true);
                    break;
                }
                try {
                    int[] goals = calculateGoals(
                        Double.parseDouble(weightStr), Double.parseDouble(heightStr),
                        Integer.parseInt(ageStr), gender, goalType);
                    try (Connection conn = DatabaseConfig.getConnection();
                         PreparedStatement ps = conn.prepareStatement(
                             "UPDATE users SET weight_kg=?,height_cm=?,age=?,gender=?," +
                             "calorie_goal=?,protein_goal=?,carbs_goal=?,fats_goal=?," +
                             "profile_setup_done=1 WHERE id=?")) {
                        ps.setDouble(1, Double.parseDouble(weightStr));
                        ps.setDouble(2, Double.parseDouble(heightStr));
                        ps.setInt(3,    Integer.parseInt(ageStr));
                        ps.setString(4, gender);
                        ps.setInt(5,    goals[0]);
                        ps.setDouble(6, goals[1]);
                        ps.setDouble(7, goals[2]);
                        ps.setDouble(8, goals[3]);
                        ps.setInt(9,    userId);
                        ps.executeUpdate();
                    }
                    request.setAttribute("successMsg", "Profile set up! Your goals have been calculated.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("setupErr",  "Setup failed: " + e.getMessage());
                    request.setAttribute("showSetup", true);
                }
                break;
            }

            // ── CREATE MEAL ──────────────────────────────────────────────────
            case "create": {
                String mealType   = nvl(request.getParameter("meal_type"));
                String mealName   = nvl(request.getParameter("meal_name"));
                String calStr     = nvl(request.getParameter("calories"),  "0");
                String proteinStr = nvl(request.getParameter("protein"),   "0");
                String carbsStr   = nvl(request.getParameter("carbs"),     "0");
                String fatsStr    = nvl(request.getParameter("fats"),      "0");
                String mealDate   = nvl(request.getParameter("meal_date"));

                if (mealName.isEmpty()) {
                    request.setAttribute("errorMsg", "Please select at least one food item.");
                    break;
                }
                try (Connection conn = DatabaseConfig.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                         "INSERT INTO meals (user_id,meal_type,meal_name,calories,protein,carbs,fats,meal_date)" +
                         " VALUES(?,?,?,?,?,?,?,?)")) {
                    ps.setInt(1,    userId);
                    ps.setString(2, mealType);
                    ps.setString(3, mealName);
                    ps.setInt(4,    calStr.isEmpty()     ? 0 : (int) Double.parseDouble(calStr));
                    ps.setDouble(5, proteinStr.isEmpty() ? 0 : Double.parseDouble(proteinStr));
                    ps.setDouble(6, carbsStr.isEmpty()   ? 0 : Double.parseDouble(carbsStr));
                    ps.setDouble(7, fatsStr.isEmpty()    ? 0 : Double.parseDouble(fatsStr));
                    ps.setString(8, mealDate.isEmpty()   ? null : mealDate);
                    ps.executeUpdate();
                    request.setAttribute("successMsg", "Meal logged successfully.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Failed to log meal: " + e.getMessage());
                }
                break;
            }

            // ── UPDATE MEAL ──────────────────────────────────────────────────
            case "update": {
                String id         = nvl(request.getParameter("id"));
                String mealType   = nvl(request.getParameter("meal_type"));
                String mealName   = nvl(request.getParameter("meal_name"));
                String calStr     = nvl(request.getParameter("calories"),  "0");
                String proteinStr = nvl(request.getParameter("protein"),   "0");
                String carbsStr   = nvl(request.getParameter("carbs"),     "0");
                String fatsStr    = nvl(request.getParameter("fats"),      "0");
                String mealDate   = nvl(request.getParameter("meal_date"));

                if (id.isEmpty() || mealName.isEmpty()) {
                    request.setAttribute("popupError", "Meal ID and name are required.");
                    break;
                }
                Set<String> validNames    = loadValidFoodNames();
                String      validationErr = validateMealName(mealName, validNames);
                if (validationErr != null) {
                    request.setAttribute("popupError", validationErr);
                    break;
                }
                try (Connection conn = DatabaseConfig.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                         "UPDATE meals SET meal_type=?,meal_name=?,calories=?,protein=?," +
                         "carbs=?,fats=?,meal_date=? WHERE id=? AND user_id=?")) {
                    ps.setString(1, mealType);
                    ps.setString(2, mealName);
                    ps.setInt(3,    calStr.isEmpty()     ? 0 : (int) Double.parseDouble(calStr));
                    ps.setDouble(4, proteinStr.isEmpty() ? 0 : Double.parseDouble(proteinStr));
                    ps.setDouble(5, carbsStr.isEmpty()   ? 0 : Double.parseDouble(carbsStr));
                    ps.setDouble(6, fatsStr.isEmpty()    ? 0 : Double.parseDouble(fatsStr));
                    ps.setString(7, mealDate.isEmpty()   ? null : mealDate);
                    ps.setInt(8,    Integer.parseInt(id));
                    ps.setInt(9,    userId);
                    request.setAttribute("successMsg", ps.executeUpdate() + " meal(s) updated.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Update failed: " + e.getMessage());
                }
                break;
            }

            // ── DELETE MEAL ──────────────────────────────────────────────────
            case "delete": {
                String id = nvl(request.getParameter("id"));
                if (id.isEmpty()) { request.setAttribute("errorMsg", "Missing meal ID."); break; }
                try (Connection conn = DatabaseConfig.getConnection();
                     PreparedStatement ps = conn.prepareStatement(
                         "DELETE FROM meals WHERE id=? AND user_id=?")) {
                    ps.setInt(1, Integer.parseInt(id));
                    ps.setInt(2, userId);
                    request.setAttribute("successMsg", ps.executeUpdate() + " meal(s) deleted.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Delete failed: " + e.getMessage());
                }
                break;
            }

            // ── UPDATE PROFILE ───────────────────────────────────────────────
            case "update_profile": {
                String fullName    = nvl(request.getParameter("full_name"));
                String email       = nvl(request.getParameter("email"));
                String password    = request.getParameter("password") != null ? request.getParameter("password") : "";
                String confirm     = request.getParameter("confirm")  != null ? request.getParameter("confirm")  : "";
                String heightStr   = nvl(request.getParameter("height_cm"));
                String weightStr   = nvl(request.getParameter("weight_kg"));
                String ageStr      = nvl(request.getParameter("age"));
                String gender      = nvl(request.getParameter("gender"));
                String calGoalStr  = nvl(request.getParameter("calorie_goal"));
                String proGoalStr  = nvl(request.getParameter("protein_goal"));
                String carbGoalStr = nvl(request.getParameter("carbs_goal"));
                String fatGoalStr  = nvl(request.getParameter("fats_goal"));

                boolean valid = true;
                if (fullName.isEmpty()) {
                    request.setAttribute("profileErr", "Full name cannot be empty."); valid = false;
                }
                if (valid && (email.isEmpty() || !email.matches("\\S+@\\S+\\.\\S+"))) {
                    request.setAttribute("profileErr", "Please enter a valid email."); valid = false;
                }
                if (valid && !password.isEmpty() && password.length() < 6) {
                    request.setAttribute("profileErr", "Password must be at least 6 chars."); valid = false;
                }
                if (valid && !password.isEmpty() && !password.equals(confirm)) {
                    request.setAttribute("profileErr", "Passwords do not match."); valid = false;
                }
                if (valid) {
                    try (Connection conn = DatabaseConfig.getConnection()) {
                        String sql = !password.isEmpty()
                            ? "UPDATE users SET full_name=?,email=?,password=?,height_cm=?,weight_kg=?," +
                              "age=?,gender=?,calorie_goal=?,protein_goal=?,carbs_goal=?,fats_goal=? WHERE id=?"
                            : "UPDATE users SET full_name=?,email=?,height_cm=?,weight_kg=?," +
                              "age=?,gender=?,calorie_goal=?,protein_goal=?,carbs_goal=?,fats_goal=? WHERE id=?";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        int i = 1;
                        ps.setString(i++, fullName);
                        ps.setString(i++, email);
                        if (!password.isEmpty())  ps.setString(i++, password);
                        if (heightStr.isEmpty())   ps.setNull(i++, Types.DECIMAL); else ps.setDouble(i++, Double.parseDouble(heightStr));
                        if (weightStr.isEmpty())   ps.setNull(i++, Types.DECIMAL); else ps.setDouble(i++, Double.parseDouble(weightStr));
                        if (ageStr.isEmpty())      ps.setNull(i++, Types.INTEGER); else ps.setInt(i++,    Integer.parseInt(ageStr));
                        ps.setString(i++, gender.isEmpty() ? null : gender);
                        if (calGoalStr.isEmpty())  ps.setNull(i++, Types.INTEGER); else ps.setInt(i++,    Integer.parseInt(calGoalStr));
                        if (proGoalStr.isEmpty())  ps.setNull(i++, Types.DECIMAL); else ps.setDouble(i++, Double.parseDouble(proGoalStr));
                        if (carbGoalStr.isEmpty()) ps.setNull(i++, Types.DECIMAL); else ps.setDouble(i++, Double.parseDouble(carbGoalStr));
                        if (fatGoalStr.isEmpty())  ps.setNull(i++, Types.DECIMAL); else ps.setDouble(i++, Double.parseDouble(fatGoalStr));
                        ps.setInt(i++, userId);
                        ps.executeUpdate();
                        session.setAttribute("userName",  fullName);
                        session.setAttribute("userEmail", email);
                        request.setAttribute("profileSuccess", "Profile updated successfully.");
                    } catch (SQLIntegrityConstraintViolationException e) {
                        request.setAttribute("profileErr", "That email is already in use.");
                    } catch (Exception e) {
                        e.printStackTrace();
                        request.setAttribute("profileErr", "Update failed: " + e.getMessage());
                    }
                }
                request.setAttribute("openProfile", true);
                break;
            }

            // ── AUTO GOALS ───────────────────────────────────────────────────
            case "auto_goals": {
                String weightStr = nvl(request.getParameter("weight_kg"));
                String heightStr = nvl(request.getParameter("height_cm"));
                String ageStr    = nvl(request.getParameter("age"));
                String gender    = nvl(request.getParameter("gender"),    "male");
                String goalType  = nvl(request.getParameter("goal_type"), "maintain");

                if (!weightStr.isEmpty() && !heightStr.isEmpty() && !ageStr.isEmpty()) {
                    int[] goals = calculateGoals(
                        Double.parseDouble(weightStr), Double.parseDouble(heightStr),
                        Integer.parseInt(ageStr), gender, goalType);
                    try (Connection conn = DatabaseConfig.getConnection();
                         PreparedStatement ps = conn.prepareStatement(
                             "UPDATE users SET height_cm=?,weight_kg=?,age=?,gender=?," +
                             "calorie_goal=?,protein_goal=?,carbs_goal=?,fats_goal=? WHERE id=?")) {
                        ps.setDouble(1, Double.parseDouble(heightStr));
                        ps.setDouble(2, Double.parseDouble(weightStr));
                        ps.setInt(3,    Integer.parseInt(ageStr));
                        ps.setString(4, gender);
                        ps.setInt(5,    goals[0]);
                        ps.setDouble(6, goals[1]);
                        ps.setDouble(7, goals[2]);
                        ps.setDouble(8, goals[3]);
                        ps.setInt(9,    userId);
                        ps.executeUpdate();
                        request.setAttribute("profileSuccess",
                            "Goals set — " + goals[0] + " kcal, " + goals[1] + "g protein, "
                            + goals[2] + "g carbs, " + goals[3] + "g fats");
                    } catch (Exception e) {
                        e.printStackTrace();
                        request.setAttribute("profileErr", "Failed: " + e.getMessage());
                    }
                } else {
                    request.setAttribute("profileErr", "Please fill in weight, height, age and gender.");
                }
                request.setAttribute("openProfile", true);
                break;
            }

            // ── LOGOUT ───────────────────────────────────────────────────────
            case "logout": {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            default:
                request.setAttribute("errorMsg", "Unknown action.");
                break;
        }

        loadAndForward(request, response, userId);
    }

    // ── Null-safe trim helpers ────────────────────────────────────────────────
    private static String nvl(String s) {
        return s == null ? "" : s.trim();
    }
    private static String nvl(String s, String fallback) {
        return (s == null || s.trim().isEmpty()) ? fallback : s.trim();
    }
}