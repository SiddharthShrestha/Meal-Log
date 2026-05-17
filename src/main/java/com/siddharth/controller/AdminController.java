package com.siddharth.controller;

import com.siddharth.config.DatabaseConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin")
public class AdminController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // -----------------------------------------------------------------------
    // Auth guard
    // -----------------------------------------------------------------------

    /**
     * Returns true if an admin is logged in; otherwise redirects to /login
     * and returns false.
     *
     * NOTE: The session attribute checked here is "adminLoggedIn" (Boolean.TRUE).
     *       LoginController.handleAdminLogin() must set this attribute on success.
     *       The original bug: LoginController only set "adminId" but never set
     *       "adminLoggedIn", so this guard always failed and bounced the admin
     *       back to the login page even after correct credentials.
     */
    private boolean isAdminLoggedIn(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null && Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {
            return true;
        }
        resp.sendRedirect(req.getContextPath() + "/login");
        return false;
    }

    // -----------------------------------------------------------------------
    // GET – show admin panel
    // -----------------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdminLoggedIn(req, resp)) return;
        loadAllData(req);
        req.getRequestDispatcher("/WEB-INF/pages/admin.jsp").forward(req, resp);
    }

    // -----------------------------------------------------------------------
    // POST – handle admin actions
    // -----------------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!isAdminLoggedIn(req, resp)) return;

        String action = req.getParameter("action") == null
                ? "" : req.getParameter("action").trim();

        switch (action) {

            // ── User management ──────────────────────────────────────────────
            case "update": {
                String idStr    = req.getParameter("id");
                String fullName = req.getParameter("fullName");
                String email    = req.getParameter("email");

                if (idStr == null || idStr.isEmpty()
                        || fullName == null || fullName.isEmpty()
                        || email    == null || email.isEmpty()) {
                    req.setAttribute("errorMsg", "All fields are required.");
                } else {
                    try (Connection conn = DatabaseConfig.getConnection();
                         PreparedStatement ps = conn.prepareStatement(
                             "UPDATE users SET full_name=?, email=? WHERE id=?")) {
                        ps.setString(1, fullName.trim());
                        ps.setString(2, email.trim());
                        ps.setInt(3, Integer.parseInt(idStr));
                        int rows = ps.executeUpdate();
                        req.setAttribute("successMsg", rows + " user(s) updated.");
                    } catch (SQLIntegrityConstraintViolationException e) {
                        req.setAttribute("errorMsg", "That email is already in use.");
                    } catch (Exception e) {
                        req.setAttribute("errorMsg", "Update failed: " + e.getMessage());
                    }
                }
                req.setAttribute("openTab", "users");
                break;
            }

            case "delete": {
                String idStr = req.getParameter("id");
                if (idStr == null || idStr.isEmpty()) {
                    req.setAttribute("errorMsg", "Missing user ID.");
                } else {
                    try (Connection conn = DatabaseConfig.getConnection();
                         PreparedStatement ps = conn.prepareStatement(
                             "DELETE FROM users WHERE id=?")) {
                        ps.setInt(1, Integer.parseInt(idStr));
                        int rows = ps.executeUpdate();
                        req.setAttribute("successMsg",
                            rows + " user(s) and all their meals deleted.");
                    } catch (Exception e) {
                        req.setAttribute("errorMsg", "Delete failed: " + e.getMessage());
                    }
                }
                req.setAttribute("openTab", "users");
                break;
            }

            // ── Food management ──────────────────────────────────────────────
            case "create_food": {
                String foodName = req.getParameter("foodName");
                String category = req.getParameter("category");
                String calStr   = req.getParameter("calories_per_100g");
                String proStr   = req.getParameter("protein_per_100g");
                String carbStr  = req.getParameter("carbs_per_100g");
                String fatStr   = req.getParameter("fats_per_100g");

                if (foodName == null || foodName.trim().isEmpty()) {
                    req.setAttribute("foodErr", "Food name is required.");
                } else if (category == null || category.trim().isEmpty()) {
                    req.setAttribute("foodErr", "Category is required.");
                } else {
                    try {
                        double cal  = Double.parseDouble(calStr);
                        double pro  = Double.parseDouble(proStr);
                        double carb = Double.parseDouble(carbStr);
                        double fat  = Double.parseDouble(fatStr);

                        try (Connection conn = DatabaseConfig.getConnection();
                             PreparedStatement ps = conn.prepareStatement(
                                 "INSERT INTO foods (food_name, category, calories_per_100g, " +
                                 "protein_per_100g, carbs_per_100g, fats_per_100g) " +
                                 "VALUES (?,?,?,?,?,?)")) {
                            ps.setString(1, foodName.trim());
                            ps.setString(2, category.trim());
                            ps.setDouble(3, cal);
                            ps.setDouble(4, pro);
                            ps.setDouble(5, carb);
                            ps.setDouble(6, fat);
                            int rows = ps.executeUpdate();
                            if (rows == 0) {
                                req.setAttribute("foodErr", "Insert returned 0 rows. Please try again.");
                            } else {
                                req.setAttribute("foodSuccess",
                                    foodName.trim() + " added to the food database successfully.");
                            }
                        }
                    } catch (NumberFormatException e) {
                        req.setAttribute("foodErr",
                            "Invalid number format in macro fields. Please enter valid numbers.");
                    } catch (Exception e) {
                        req.setAttribute("foodErr", "Failed to add food: " + e.getMessage());
                    }
                }
                req.setAttribute("openTab", "foods");
                break;
            }

            case "update_food": {
                String idStr    = req.getParameter("id");
                String foodName = req.getParameter("foodName");
                String category = req.getParameter("category");
                String calStr   = req.getParameter("calories_per_100g");
                String proStr   = req.getParameter("protein_per_100g");
                String carbStr  = req.getParameter("carbs_per_100g");
                String fatStr   = req.getParameter("fats_per_100g");

                if (idStr == null || idStr.isEmpty()
                        || foodName == null || foodName.trim().isEmpty()
                        || category == null || category.trim().isEmpty()) {
                    req.setAttribute("foodErr", "ID, name and category are required.");
                } else {
                    try {
                        double cal  = Double.parseDouble(calStr);
                        double pro  = Double.parseDouble(proStr);
                        double carb = Double.parseDouble(carbStr);
                        double fat  = Double.parseDouble(fatStr);

                        try (Connection conn = DatabaseConfig.getConnection();
                             PreparedStatement ps = conn.prepareStatement(
                                 "UPDATE foods SET food_name=?, category=?, " +
                                 "calories_per_100g=?, protein_per_100g=?, " +
                                 "carbs_per_100g=?, fats_per_100g=? WHERE id=?")) {
                            ps.setString(1, foodName.trim());
                            ps.setString(2, category.trim());
                            ps.setDouble(3, cal);
                            ps.setDouble(4, pro);
                            ps.setDouble(5, carb);
                            ps.setDouble(6, fat);
                            ps.setInt(7, Integer.parseInt(idStr));
                            int rows = ps.executeUpdate();
                            req.setAttribute("foodSuccess", rows + " food item(s) updated.");
                        }
                    } catch (NumberFormatException e) {
                        req.setAttribute("foodErr", "Invalid number format in macro fields.");
                    } catch (Exception e) {
                        req.setAttribute("foodErr", "Update failed: " + e.getMessage());
                    }
                }
                req.setAttribute("openTab", "foods");
                break;
            }

            case "delete_food": {
                String idStr = req.getParameter("id");
                if (idStr == null || idStr.isEmpty()) {
                    req.setAttribute("foodErr", "Missing food ID.");
                } else {
                    try (Connection conn = DatabaseConfig.getConnection();
                         PreparedStatement ps = conn.prepareStatement(
                             "DELETE FROM foods WHERE id=?")) {
                        ps.setInt(1, Integer.parseInt(idStr));
                        int rows = ps.executeUpdate();
                        req.setAttribute("foodSuccess", rows + " food item(s) deleted.");
                    } catch (Exception e) {
                        req.setAttribute("foodErr", "Delete failed: " + e.getMessage());
                    }
                }
                req.setAttribute("openTab", "foods");
                break;
            }

            // ── Session ──────────────────────────────────────────────────────
            case "logout": {
                HttpSession session = req.getSession(false);
                if (session != null) session.invalidate();
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }

            default:
                req.setAttribute("errorMsg", "Unknown action.");
                break;
        }

        // Re-load data and re-display the panel after any POST action
        loadAllData(req);
        req.getRequestDispatcher("/WEB-INF/pages/admin.jsp").forward(req, resp);
    }

    // -----------------------------------------------------------------------
    // Data loaders
    // -----------------------------------------------------------------------

    private void loadAllData(HttpServletRequest req) {
        req.setAttribute("users",           loadAllUsers());
        req.setAttribute("mealsByUser",     loadMealsByUser());
        req.setAttribute("foods",           loadAllFoods());
        req.setAttribute("regPerDay",       loadRegistrationsPerDay());
        req.setAttribute("regPerMonth",     loadRegistrationsPerMonth());
        req.setAttribute("mealsPerDay",     loadMealsPerDay());
        req.setAttribute("mealsPerMonth",   loadMealsPerMonth());
        req.setAttribute("mealTypeDistrib", loadMealTypeDistribution());
    }

    private List<String[]> loadAllUsers() {
        List<String[]> users = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                 "SELECT id, full_name, email, created_at FROM users ORDER BY id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("full_name"),
                    rs.getString("email"),
                    rs.getString("created_at")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    private Map<String, List<String[]>> loadMealsByUser() {
        Map<String, List<String[]>> mealsByUser = new LinkedHashMap<>();
        String sql =
            "SELECT m.id, m.user_id, u.full_name, m.meal_type, m.meal_name, " +
            "m.calories, m.protein, m.carbs, m.fats, m.meal_date " +
            "FROM meals m LEFT JOIN users u ON m.user_id = u.id " +
            "ORDER BY m.user_id, m.meal_date DESC, m.id DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String userId = rs.getString("user_id");
                mealsByUser.computeIfAbsent(userId, k -> new ArrayList<>()).add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    userId,
                    rs.getString("full_name"),
                    rs.getString("meal_type"),
                    rs.getString("meal_name"),
                    String.valueOf(rs.getDouble("calories")),
                    String.valueOf(rs.getDouble("protein")),
                    String.valueOf(rs.getDouble("carbs")),
                    String.valueOf(rs.getDouble("fats")),
                    rs.getString("meal_date")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return mealsByUser;
    }

    private List<String[]> loadAllFoods() {
        List<String[]> foods = new ArrayList<>();
        String sql =
            "SELECT id, food_name, category, calories_per_100g, protein_per_100g, " +
            "carbs_per_100g, fats_per_100g FROM foods ORDER BY category, food_name";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                foods.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("food_name"),
                    rs.getString("category"),
                    String.valueOf(rs.getDouble("calories_per_100g")),
                    String.valueOf(rs.getDouble("protein_per_100g")),
                    String.valueOf(rs.getDouble("carbs_per_100g")),
                    String.valueOf(rs.getDouble("fats_per_100g"))
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return foods;
    }

    private List<String[]> loadRegistrationsPerDay() {
        return loadStats(
            "SELECT DATE(created_at) as reg_date, COUNT(*) as count " +
            "FROM users WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
            "GROUP BY DATE(created_at) ORDER BY reg_date ASC",
            "reg_date", "count");
    }

    private List<String[]> loadRegistrationsPerMonth() {
        return loadStats(
            "SELECT DATE_FORMAT(created_at,'%Y-%m') as reg_month, COUNT(*) as count " +
            "FROM users GROUP BY reg_month ORDER BY reg_month ASC",
            "reg_month", "count");
    }

    private List<String[]> loadMealsPerDay() {
        return loadStats(
            "SELECT meal_date, COUNT(*) as count FROM meals " +
            "WHERE meal_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
            "GROUP BY meal_date ORDER BY meal_date ASC",
            "meal_date", "count");
    }

    private List<String[]> loadMealsPerMonth() {
        return loadStats(
            "SELECT DATE_FORMAT(meal_date,'%Y-%m') as meal_month, COUNT(*) as count " +
            "FROM meals GROUP BY meal_month ORDER BY meal_month ASC",
            "meal_month", "count");
    }

    private List<String[]> loadMealTypeDistribution() {
        return loadStats(
            "SELECT COALESCE(meal_type,'Other') as meal_type, COUNT(*) as count " +
            "FROM meals GROUP BY meal_type ORDER BY count DESC",
            "meal_type", "count");
    }

    /** Generic helper to load two-column (label, count) stats queries. */
    private List<String[]> loadStats(String sql, String labelCol, String countCol) {
        List<String[]> data = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                data.add(new String[]{ rs.getString(labelCol), rs.getString(countCol) });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return data;
    }
}