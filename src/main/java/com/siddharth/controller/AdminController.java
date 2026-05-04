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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.siddharth.config.DatabaseConfig;

@WebServlet("/admin")
public class AdminController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // ── Auth guard ──
    private boolean isAdminLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || !Boolean.TRUE.equals(session.getAttribute("adminLoggedIn"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    // ── Load all users ──
    private List<String[]> loadAllUsers() {
        List<String[]> users = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, full_name, email, created_at FROM users ORDER BY id");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                users.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("full_name")  != null ? rs.getString("full_name")  : "",
                    rs.getString("email")      != null ? rs.getString("email")      : "",
                    rs.getString("created_at") != null ? rs.getString("created_at") : ""
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return users;
    }

    // ── Load meals per user ──
    private Map<String, List<String[]>> loadMealsByUser() {
        Map<String, List<String[]>> map = new LinkedHashMap<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT m.id, m.user_id, u.full_name, m.meal_type, m.meal_name, " +
                "m.calories, m.protein, m.carbs, m.fats, m.meal_date " +
                "FROM meals m LEFT JOIN users u ON m.user_id = u.id " +
                "ORDER BY m.user_id, m.meal_date DESC, m.id DESC");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String userId = String.valueOf(rs.getInt("user_id"));
                map.computeIfAbsent(userId, k -> new ArrayList<>()).add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    userId,
                    rs.getString("full_name")  != null ? rs.getString("full_name")  : "",
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
        return map;
    }

    // ── Registrations per day (last 30 days) ──
    private List<String[]> loadRegistrationsPerDay() {
        List<String[]> data = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT DATE(created_at) as reg_date, COUNT(*) as count " +
                "FROM users WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
                "GROUP BY DATE(created_at) ORDER BY reg_date ASC");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                data.add(new String[]{
                    rs.getString("reg_date"),
                    String.valueOf(rs.getInt("count"))
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return data;
    }

    // ── Registrations per month (all time) ──
    private List<String[]> loadRegistrationsPerMonth() {
        List<String[]> data = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT DATE_FORMAT(created_at, '%Y-%m') as reg_month, COUNT(*) as count " +
                "FROM users GROUP BY reg_month ORDER BY reg_month ASC");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                data.add(new String[]{
                    rs.getString("reg_month"),
                    String.valueOf(rs.getInt("count"))
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return data;
    }

    // ── Meals logged per day (last 30 days) ──
    private List<String[]> loadMealsPerDay() {
        List<String[]> data = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT meal_date, COUNT(*) as count FROM meals " +
                "WHERE meal_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) " +
                "GROUP BY meal_date ORDER BY meal_date ASC");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                data.add(new String[]{
                    rs.getString("meal_date"),
                    String.valueOf(rs.getInt("count"))
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return data;
    }

    // ── Meals logged per month (all time) ──
    private List<String[]> loadMealsPerMonth() {
        List<String[]> data = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT DATE_FORMAT(meal_date, '%Y-%m') as meal_month, COUNT(*) as count " +
                "FROM meals GROUP BY meal_month ORDER BY meal_month ASC");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                data.add(new String[]{
                    rs.getString("meal_month"),
                    String.valueOf(rs.getInt("count"))
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return data;
    }

    // ── Meal type distribution ──
    private List<String[]> loadMealTypeDistribution() {
        List<String[]> data = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT meal_type, COUNT(*) as count FROM meals " +
                "GROUP BY meal_type ORDER BY count DESC");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                data.add(new String[]{
                    rs.getString("meal_type") != null ? rs.getString("meal_type") : "Other",
                    String.valueOf(rs.getInt("count"))
                });
            }
        } catch (Exception e) { e.printStackTrace(); }
        return data;
    }

    private void loadAllData(HttpServletRequest request) {
        request.setAttribute("users",             loadAllUsers());
        request.setAttribute("mealsByUser",       loadMealsByUser());
        request.setAttribute("regPerDay",         loadRegistrationsPerDay());
        request.setAttribute("regPerMonth",       loadRegistrationsPerMonth());
        request.setAttribute("mealsPerDay",       loadMealsPerDay());
        request.setAttribute("mealsPerMonth",     loadMealsPerMonth());
        request.setAttribute("mealTypeDistrib",   loadMealTypeDistribution());
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminLoggedIn(request, response)) return;
        loadAllData(request);
        request.getRequestDispatcher("/WEB-INF/pages/admin.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdminLoggedIn(request, response)) return;

        String action = request.getParameter("action") != null ? request.getParameter("action").trim() : "";

        switch (action) {

            case "update": {
                String id       = request.getParameter("id")       != null ? request.getParameter("id").trim()       : "";
                String fullName = request.getParameter("full_name") != null ? request.getParameter("full_name").trim() : "";
                String email    = request.getParameter("email")     != null ? request.getParameter("email").trim()     : "";

                if (id.isEmpty() || fullName.isEmpty() || email.isEmpty()) {
                    request.setAttribute("errorMsg", "All fields are required for update.");
                    break;
                }
                try (Connection conn = DatabaseConfig.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE users SET full_name=?, email=? WHERE id=?");
                    ps.setString(1, fullName);
                    ps.setString(2, email);
                    ps.setInt   (3, Integer.parseInt(id));
                    int rows = ps.executeUpdate();
                    request.setAttribute("successMsg", rows + " user(s) updated successfully.");
                } catch (SQLIntegrityConstraintViolationException e) {
                    request.setAttribute("errorMsg", "That email is already in use.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Update failed: " + e.getMessage());
                }
                break;
            }

            case "delete": {
                String id = request.getParameter("id") != null ? request.getParameter("id").trim() : "";
                if (id.isEmpty()) {
                    request.setAttribute("errorMsg", "Missing user ID.");
                    break;
                }
                try (Connection conn = DatabaseConfig.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id=?");
                    ps.setInt(1, Integer.parseInt(id));
                    int rows = ps.executeUpdate();
                    request.setAttribute("successMsg", rows + " user(s) deleted. All their meals were removed automatically.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Delete failed: " + e.getMessage());
                }
                break;
            }

            case "logout": {
                request.getSession().invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            default:
                request.setAttribute("errorMsg", "Unknown action.");
                break;
        }

        loadAllData(request);
        request.getRequestDispatcher("/WEB-INF/pages/admin.jsp").forward(request, response);
    }
}