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
import java.util.List;

import com.siddharth.config.DatabaseConfig;

@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {
    private static final long serialVersionUID = 1L;

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
                    rs.getString("meal_type") != null ? rs.getString("meal_type") : "",
                    rs.getString("meal_name") != null ? rs.getString("meal_name") : "",
                    String.valueOf(rs.getInt("calories")),
                    String.valueOf(rs.getDouble("protein")),
                    String.valueOf(rs.getDouble("carbs")),
                    String.valueOf(rs.getDouble("fats")),
                    rs.getString("meal_date") != null ? rs.getString("meal_date") : ""
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return meals;
    }

    private boolean isLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isLoggedIn(request, response)) return;

        HttpSession session = request.getSession();
        int userId = (int) session.getAttribute("userId");

        request.setAttribute("meals", loadUserMeals(userId));
        request.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isLoggedIn(request, response)) return;

        HttpSession session = request.getSession();
        int userId = (int) session.getAttribute("userId");
        String action = request.getParameter("action") != null ? request.getParameter("action").trim() : "";

        switch (action) {

            // ── ADD MEAL ──
            case "create": {
                String mealType   = request.getParameter("meal_type")  != null ? request.getParameter("meal_type").trim()  : "";
                String mealName   = request.getParameter("meal_name")  != null ? request.getParameter("meal_name").trim()  : "";
                String calStr     = request.getParameter("calories")   != null ? request.getParameter("calories").trim()   : "";
                String proteinStr = request.getParameter("protein")    != null ? request.getParameter("protein").trim()    : "";
                String carbsStr   = request.getParameter("carbs")      != null ? request.getParameter("carbs").trim()      : "";
                String fatsStr    = request.getParameter("fats")       != null ? request.getParameter("fats").trim()       : "";
                String mealDate   = request.getParameter("meal_date")  != null ? request.getParameter("meal_date").trim()  : "";

                if (mealName.isEmpty()) {
                    request.setAttribute("errorMsg", "Meal name is required.");
                    break;
                }

                try (Connection conn = DatabaseConfig.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO meals (user_id, meal_type, meal_name, calories, protein, carbs, fats, meal_date) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                    ps.setInt   (1, userId);
                    ps.setString(2, mealType);
                    ps.setString(3, mealName);
                    ps.setInt   (4, calStr.isEmpty()     ? 0 : Integer.parseInt(calStr));
                    ps.setDouble(5, proteinStr.isEmpty() ? 0 : Double.parseDouble(proteinStr));
                    ps.setDouble(6, carbsStr.isEmpty()   ? 0 : Double.parseDouble(carbsStr));
                    ps.setDouble(7, fatsStr.isEmpty()    ? 0 : Double.parseDouble(fatsStr));
                    ps.setString(8, mealDate.isEmpty()   ? null : mealDate);
                    ps.executeUpdate();
                    request.setAttribute("successMsg", "Meal \"" + mealName + "\" added successfully.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Failed to add meal: " + e.getMessage());
                }
                break;
            }

            // ── UPDATE MEAL ──
            case "update": {
                String id         = request.getParameter("id")         != null ? request.getParameter("id").trim()         : "";
                String mealType   = request.getParameter("meal_type")  != null ? request.getParameter("meal_type").trim()  : "";
                String mealName   = request.getParameter("meal_name")  != null ? request.getParameter("meal_name").trim()  : "";
                String calStr     = request.getParameter("calories")   != null ? request.getParameter("calories").trim()   : "";
                String proteinStr = request.getParameter("protein")    != null ? request.getParameter("protein").trim()    : "";
                String carbsStr   = request.getParameter("carbs")      != null ? request.getParameter("carbs").trim()      : "";
                String fatsStr    = request.getParameter("fats")       != null ? request.getParameter("fats").trim()       : "";
                String mealDate   = request.getParameter("meal_date")  != null ? request.getParameter("meal_date").trim()  : "";

                if (id.isEmpty() || mealName.isEmpty()) {
                    request.setAttribute("errorMsg", "Meal ID and name are required for update.");
                    break;
                }

                try (Connection conn = DatabaseConfig.getConnection()) {
                    // Ensure the meal belongs to this user
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE meals SET meal_type=?, meal_name=?, calories=?, protein=?, carbs=?, fats=?, meal_date=? " +
                        "WHERE id=? AND user_id=?");
                    ps.setString(1, mealType);
                    ps.setString(2, mealName);
                    ps.setInt   (3, calStr.isEmpty()     ? 0 : Integer.parseInt(calStr));
                    ps.setDouble(4, proteinStr.isEmpty() ? 0 : Double.parseDouble(proteinStr));
                    ps.setDouble(5, carbsStr.isEmpty()   ? 0 : Double.parseDouble(carbsStr));
                    ps.setDouble(6, fatsStr.isEmpty()    ? 0 : Double.parseDouble(fatsStr));
                    ps.setString(7, mealDate.isEmpty()   ? null : mealDate);
                    ps.setInt   (8, Integer.parseInt(id));
                    ps.setInt   (9, userId);
                    int rows = ps.executeUpdate();
                    request.setAttribute("successMsg", rows + " meal(s) updated successfully.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Update failed: " + e.getMessage());
                }
                break;
            }

            // ── DELETE MEAL ──
            case "delete": {
                String id = request.getParameter("id") != null ? request.getParameter("id").trim() : "";

                if (id.isEmpty()) {
                    request.setAttribute("errorMsg", "Missing meal ID.");
                    break;
                }

                try (Connection conn = DatabaseConfig.getConnection()) {
                    // Ensure the meal belongs to this user
                    PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM meals WHERE id=? AND user_id=?");
                    ps.setInt(1, Integer.parseInt(id));
                    ps.setInt(2, userId);
                    int rows = ps.executeUpdate();
                    request.setAttribute("successMsg", rows + " meal(s) deleted.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Delete failed: " + e.getMessage());
                }
                break;
            }

            // ── LOGOUT ──
            case "logout": {
                session.invalidate();
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }

            default:
                request.setAttribute("errorMsg", "Unknown action.");
                break;
        }

        request.setAttribute("meals", loadUserMeals(userId));
        request.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(request, response);
    }
}