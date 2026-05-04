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

    // ── Auth guard ──
    private boolean isLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        return true;
    }

    // ── Load user meals ──
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
        } catch (Exception e) { e.printStackTrace(); }
        return meals;
    }

    // ── Load user profile ──
    private String[] loadUserProfile(int userId) {
        String[] profile = {"","","","","2000","150.0","250.0","65.0","0"};
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT height_cm, weight_kg, age, gender, calorie_goal, protein_goal, " +
                "carbs_goal, fats_goal, profile_setup_done FROM users WHERE id = ?");
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                profile[0] = rs.getString("height_cm")          != null ? rs.getString("height_cm")          : "";
                profile[1] = rs.getString("weight_kg")          != null ? rs.getString("weight_kg")          : "";
                profile[2] = rs.getString("age")                != null ? rs.getString("age")                : "";
                profile[3] = rs.getString("gender")             != null ? rs.getString("gender")             : "";
                profile[4] = rs.getString("calorie_goal")       != null ? rs.getString("calorie_goal")       : "2000";
                profile[5] = rs.getString("protein_goal")       != null ? rs.getString("protein_goal")       : "150.0";
                profile[6] = rs.getString("carbs_goal")         != null ? rs.getString("carbs_goal")         : "250.0";
                profile[7] = rs.getString("fats_goal")          != null ? rs.getString("fats_goal")          : "65.0";
                profile[8] = String.valueOf(rs.getInt("profile_setup_done"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return profile;
    }

    // ── Load 7-day macro data ──
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

    // ── BMR / TDEE goal calculator (Mifflin-St Jeor) ──
    private int[] calculateGoals(double weightKg, double heightCm, int age, String gender, String goalType) {
        double bmr = "male".equalsIgnoreCase(gender)
            ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
            : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
        int tdee     = (int) Math.round(bmr * 1.55);
        int calories = "lose".equals(goalType) ? tdee - 500 : "gain".equals(goalType) ? tdee + 500 : tdee;
        calories     = Math.max(1200, calories);
        int protein  = (int) Math.round(weightKg * ("lose".equals(goalType) ? 2.2 : 1.8));
        int carbs    = (int) Math.round((calories * 0.45) / 4);
        int fats     = (int) Math.round((calories * 0.25) / 9);
        return new int[]{ calories, protein, carbs, fats };
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isLoggedIn(request, response)) return;
        HttpSession session = request.getSession();
        int userId = (int) session.getAttribute("userId");
        String[] profile = loadUserProfile(userId);
        if ("0".equals(profile[8])) request.setAttribute("showSetup", true);
        request.setAttribute("meals",       loadUserMeals(userId));
        request.setAttribute("userProfile", profile);
        request.setAttribute("sevenDay",    load7DayData(userId));
        request.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isLoggedIn(request, response)) return;

        HttpSession session = request.getSession();
        int    userId = (int) session.getAttribute("userId");
        String action = request.getParameter("action") != null ? request.getParameter("action").trim() : "";

        switch (action) {

            // ── FIRST TIME SETUP ──
            case "setup": {
                String weightStr = request.getParameter("weight_kg") != null ? request.getParameter("weight_kg").trim() : "";
                String heightStr = request.getParameter("height_cm") != null ? request.getParameter("height_cm").trim() : "";
                String ageStr    = request.getParameter("age")       != null ? request.getParameter("age").trim()       : "";
                String gender    = request.getParameter("gender")    != null ? request.getParameter("gender").trim()    : "male";
                String goalType  = request.getParameter("goal_type") != null ? request.getParameter("goal_type").trim() : "maintain";

                if (weightStr.isEmpty() || heightStr.isEmpty() || ageStr.isEmpty()) {
                    request.setAttribute("setupErr", "Please fill in all fields.");
                    request.setAttribute("showSetup", true);
                    break;
                }
                try {
                    double weight = Double.parseDouble(weightStr);
                    double height = Double.parseDouble(heightStr);
                    int    age    = Integer.parseInt(ageStr);
                    int[]  goals  = calculateGoals(weight, height, age, gender, goalType);
                    try (Connection conn = DatabaseConfig.getConnection()) {
                        PreparedStatement ps = conn.prepareStatement(
                            "UPDATE users SET weight_kg=?, height_cm=?, age=?, gender=?, " +
                            "calorie_goal=?, protein_goal=?, carbs_goal=?, fats_goal=?, " +
                            "profile_setup_done=1 WHERE id=?");
                        ps.setDouble(1, weight); ps.setDouble(2, height);
                        ps.setInt   (3, age);    ps.setString(4, gender);
                        ps.setInt   (5, goals[0]); ps.setDouble(6, goals[1]);
                        ps.setDouble(7, goals[2]); ps.setDouble(8, goals[3]);
                        ps.setInt   (9, userId);
                        ps.executeUpdate();
                    }
                    request.setAttribute("successMsg", "Profile set up! Your goals have been calculated.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("setupErr", "Setup failed: " + e.getMessage());
                    request.setAttribute("showSetup", true);
                }
                break;
            }

            // ── ADD MEAL ──
            case "create": {
                String mealType   = request.getParameter("meal_type")  != null ? request.getParameter("meal_type").trim()  : "";
                String mealName   = request.getParameter("meal_name")  != null ? request.getParameter("meal_name").trim()  : "";
                String calStr     = request.getParameter("calories")   != null ? request.getParameter("calories").trim()   : "0";
                String proteinStr = request.getParameter("protein")    != null ? request.getParameter("protein").trim()    : "0";
                String carbsStr   = request.getParameter("carbs")      != null ? request.getParameter("carbs").trim()      : "0";
                String fatsStr    = request.getParameter("fats")       != null ? request.getParameter("fats").trim()       : "0";
                String mealDate   = request.getParameter("meal_date")  != null ? request.getParameter("meal_date").trim()  : "";

                if (mealName.isEmpty()) { request.setAttribute("errorMsg", "Please select at least one food item."); break; }
                try (Connection conn = DatabaseConfig.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "INSERT INTO meals (user_id, meal_type, meal_name, calories, protein, carbs, fats, meal_date) VALUES (?,?,?,?,?,?,?,?)");
                    ps.setInt   (1, userId);    ps.setString(2, mealType); ps.setString(3, mealName);
                    ps.setInt   (4, calStr.isEmpty()     ? 0 : (int) Double.parseDouble(calStr));
                    ps.setDouble(5, proteinStr.isEmpty() ? 0 : Double.parseDouble(proteinStr));
                    ps.setDouble(6, carbsStr.isEmpty()   ? 0 : Double.parseDouble(carbsStr));
                    ps.setDouble(7, fatsStr.isEmpty()    ? 0 : Double.parseDouble(fatsStr));
                    ps.setString(8, mealDate.isEmpty()   ? null : mealDate);
                    ps.executeUpdate();
                    request.setAttribute("successMsg", "Meal logged successfully.");
                } catch (Exception e) { e.printStackTrace(); request.setAttribute("errorMsg", "Failed: " + e.getMessage()); }
                break;
            }

            // ── UPDATE MEAL ──
            case "update": {
                String id         = request.getParameter("id")         != null ? request.getParameter("id").trim()         : "";
                String mealType   = request.getParameter("meal_type")  != null ? request.getParameter("meal_type").trim()  : "";
                String mealName   = request.getParameter("meal_name")  != null ? request.getParameter("meal_name").trim()  : "";
                String calStr     = request.getParameter("calories")   != null ? request.getParameter("calories").trim()   : "0";
                String proteinStr = request.getParameter("protein")    != null ? request.getParameter("protein").trim()    : "0";
                String carbsStr   = request.getParameter("carbs")      != null ? request.getParameter("carbs").trim()      : "0";
                String fatsStr    = request.getParameter("fats")       != null ? request.getParameter("fats").trim()       : "0";
                String mealDate   = request.getParameter("meal_date")  != null ? request.getParameter("meal_date").trim()  : "";

                if (id.isEmpty() || mealName.isEmpty()) { request.setAttribute("errorMsg", "Meal ID and name are required."); break; }
                try (Connection conn = DatabaseConfig.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE meals SET meal_type=?,meal_name=?,calories=?,protein=?,carbs=?,fats=?,meal_date=? WHERE id=? AND user_id=?");
                    ps.setString(1, mealType); ps.setString(2, mealName);
                    ps.setInt   (3, calStr.isEmpty()     ? 0 : (int) Double.parseDouble(calStr));
                    ps.setDouble(4, proteinStr.isEmpty() ? 0 : Double.parseDouble(proteinStr));
                    ps.setDouble(5, carbsStr.isEmpty()   ? 0 : Double.parseDouble(carbsStr));
                    ps.setDouble(6, fatsStr.isEmpty()    ? 0 : Double.parseDouble(fatsStr));
                    ps.setString(7, mealDate.isEmpty()   ? null : mealDate);
                    ps.setInt   (8, Integer.parseInt(id)); ps.setInt(9, userId);
                    request.setAttribute("successMsg", ps.executeUpdate() + " meal(s) updated.");
                } catch (Exception e) { e.printStackTrace(); request.setAttribute("errorMsg", "Update failed: " + e.getMessage()); }
                break;
            }

            // ── DELETE MEAL ──
            case "delete": {
                String id = request.getParameter("id") != null ? request.getParameter("id").trim() : "";
                if (id.isEmpty()) { request.setAttribute("errorMsg", "Missing meal ID."); break; }
                try (Connection conn = DatabaseConfig.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement("DELETE FROM meals WHERE id=? AND user_id=?");
                    ps.setInt(1, Integer.parseInt(id)); ps.setInt(2, userId);
                    request.setAttribute("successMsg", ps.executeUpdate() + " meal(s) deleted.");
                } catch (Exception e) { e.printStackTrace(); request.setAttribute("errorMsg", "Delete failed: " + e.getMessage()); }
                break;
            }

            // ── UPDATE PROFILE ──
            case "update_profile": {
                String fullName    = request.getParameter("full_name")     != null ? request.getParameter("full_name").trim()     : "";
                String email       = request.getParameter("email")         != null ? request.getParameter("email").trim()         : "";
                String password    = request.getParameter("password")      != null ? request.getParameter("password")             : "";
                String confirm     = request.getParameter("confirm")       != null ? request.getParameter("confirm")              : "";
                String heightStr   = request.getParameter("height_cm")     != null ? request.getParameter("height_cm").trim()     : "";
                String weightStr   = request.getParameter("weight_kg")     != null ? request.getParameter("weight_kg").trim()     : "";
                String ageStr      = request.getParameter("age")           != null ? request.getParameter("age").trim()           : "";
                String gender      = request.getParameter("gender")        != null ? request.getParameter("gender").trim()        : "";
                String calGoalStr  = request.getParameter("calorie_goal")  != null ? request.getParameter("calorie_goal").trim()  : "";
                String proGoalStr  = request.getParameter("protein_goal")  != null ? request.getParameter("protein_goal").trim()  : "";
                String carbGoalStr = request.getParameter("carbs_goal")    != null ? request.getParameter("carbs_goal").trim()    : "";
                String fatGoalStr  = request.getParameter("fats_goal")     != null ? request.getParameter("fats_goal").trim()     : "";

                boolean valid = true;
                if (fullName.isEmpty())                                     { request.setAttribute("profileErr", "Full name cannot be empty.");        valid = false; }
                if (email.isEmpty() || !email.matches("\\S+@\\S+\\.\\S+")) { request.setAttribute("profileErr", "Please enter a valid email.");        valid = false; }
                if (!password.isEmpty() && password.length() < 6)          { request.setAttribute("profileErr", "Password must be at least 6 chars."); valid = false; }
                if (!password.isEmpty() && !password.equals(confirm))      { request.setAttribute("profileErr", "Passwords do not match.");            valid = false; }

                if (valid) {
                    try (Connection conn = DatabaseConfig.getConnection()) {
                        String sql = !password.isEmpty()
                            ? "UPDATE users SET full_name=?,email=?,password=?,height_cm=?,weight_kg=?,age=?,gender=?,calorie_goal=?,protein_goal=?,carbs_goal=?,fats_goal=? WHERE id=?"
                            : "UPDATE users SET full_name=?,email=?,height_cm=?,weight_kg=?,age=?,gender=?,calorie_goal=?,protein_goal=?,carbs_goal=?,fats_goal=? WHERE id=?";
                        PreparedStatement ps = conn.prepareStatement(sql);
                        int i = 1;
                        ps.setString(i++, fullName); ps.setString(i++, email);
                        if (!password.isEmpty()) ps.setString(i++, password);
                        if (heightStr.isEmpty())   ps.setNull(i++, Types.DECIMAL); else ps.setDouble(i++, Double.parseDouble(heightStr));
                        if (weightStr.isEmpty())   ps.setNull(i++, Types.DECIMAL); else ps.setDouble(i++, Double.parseDouble(weightStr));
                        if (ageStr.isEmpty())      ps.setNull(i++, Types.INTEGER); else ps.setInt   (i++, Integer.parseInt(ageStr));
                        ps.setString(i++, gender.isEmpty() ? null : gender);
                        if (calGoalStr.isEmpty())  ps.setNull(i++, Types.INTEGER); else ps.setInt   (i++, Integer.parseInt(calGoalStr));
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

            // ── AUTO GOALS ──
            case "auto_goals": {
                String weightStr = request.getParameter("weight_kg") != null ? request.getParameter("weight_kg").trim() : "";
                String heightStr = request.getParameter("height_cm") != null ? request.getParameter("height_cm").trim() : "";
                String ageStr    = request.getParameter("age")       != null ? request.getParameter("age").trim()       : "";
                String gender    = request.getParameter("gender")    != null ? request.getParameter("gender").trim()    : "male";
                String goalType  = request.getParameter("goal_type") != null ? request.getParameter("goal_type").trim() : "maintain";

                if (!weightStr.isEmpty() && !heightStr.isEmpty() && !ageStr.isEmpty()) {
                    int[] goals = calculateGoals(Double.parseDouble(weightStr), Double.parseDouble(heightStr), Integer.parseInt(ageStr), gender, goalType);
                    try (Connection conn = DatabaseConfig.getConnection()) {
                        PreparedStatement ps = conn.prepareStatement(
                            "UPDATE users SET height_cm=?,weight_kg=?,age=?,gender=?,calorie_goal=?,protein_goal=?,carbs_goal=?,fats_goal=? WHERE id=?");
                        ps.setDouble(1, Double.parseDouble(heightStr)); ps.setDouble(2, Double.parseDouble(weightStr));
                        ps.setInt   (3, Integer.parseInt(ageStr));      ps.setString(4, gender);
                        ps.setInt   (5, goals[0]); ps.setDouble(6, goals[1]); ps.setDouble(7, goals[2]); ps.setDouble(8, goals[3]);
                        ps.setInt   (9, userId);
                        ps.executeUpdate();
                        request.setAttribute("profileSuccess", "Goals set — " + goals[0] + " kcal, " + goals[1] + "g protein, " + goals[2] + "g carbs, " + goals[3] + "g fats");
                    } catch (Exception e) { e.printStackTrace(); request.setAttribute("profileErr", "Failed: " + e.getMessage()); }
                } else {
                    request.setAttribute("profileErr", "Please fill in weight, height, age and gender.");
                }
                request.setAttribute("openProfile", true);
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

        String[] profile = loadUserProfile(userId);
        if ("0".equals(profile[8])) request.setAttribute("showSetup", true);
        request.setAttribute("meals",       loadUserMeals(userId));
        request.setAttribute("userProfile", profile);
        request.setAttribute("sevenDay",    load7DayData(userId));
        request.getRequestDispatcher("/WEB-INF/pages/dashboard.jsp").forward(request, response);
    }
}