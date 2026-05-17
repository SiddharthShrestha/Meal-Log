package com.siddharth.service;

import com.siddharth.config.DatabaseConfig;
import com.siddharth.model.Meal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * MealService - Encapsulates all business logic and database
 * operations related to the Meal entity.
 */
public class MealService {

    /**
     * Returns all meals for a specific user, ordered by date descending.
     */
    public List<Meal> getMealsByUser(int userId) throws Exception {
        List<Meal> meals = new ArrayList<>();
        String sql = "SELECT * FROM meals WHERE user_id = ? ORDER BY meal_date DESC, created_at DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    meals.add(mapRow(rs));
                }
            }
        }
        return meals;
    }

    /**
     * Returns today's meals for a specific user.
     */
    public List<Meal> getTodaysMeals(int userId) throws Exception {
        List<Meal> meals = new ArrayList<>();
        String sql = "SELECT * FROM meals WHERE user_id = ? AND meal_date = CURDATE() ORDER BY created_at DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    meals.add(mapRow(rs));
                }
            }
        }
        return meals;
    }

    /**
     * Inserts a new meal record into the database.
     */
    public void createMeal(int userId, String mealType, String mealName,
                           int calories, double protein,
                           double carbs, double fats, String mealDate) throws Exception {
        String sql = "INSERT INTO meals (user_id, meal_type, meal_name, calories, protein, carbs, fats, meal_date) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, mealType);
            ps.setString(3, mealName);
            ps.setInt(4, calories);
            ps.setDouble(5, protein);
            ps.setDouble(6, carbs);
            ps.setDouble(7, fats);
            ps.setString(8, mealDate);
            ps.executeUpdate();
        }
    }

    /**
     * Updates an existing meal — scoped to the logged-in user for security.
     */
    public void updateMeal(int mealId, int userId, String mealType, String mealName,
                           int calories, double protein,
                           double carbs, double fats, String mealDate) throws Exception {
        String sql = "UPDATE meals SET meal_type=?, meal_name=?, calories=?, protein=?, " +
                     "carbs=?, fats=?, meal_date=? WHERE id=? AND user_id=?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, mealType);
            ps.setString(2, mealName);
            ps.setInt(3, calories);
            ps.setDouble(4, protein);
            ps.setDouble(5, carbs);
            ps.setDouble(6, fats);
            ps.setString(7, mealDate);
            ps.setInt(8, mealId);
            ps.setInt(9, userId);
            ps.executeUpdate();
        }
    }

    /**
     * Deletes a meal — scoped to the logged-in user for security.
     */
    public void deleteMeal(int mealId, int userId) throws Exception {
        String sql = "DELETE FROM meals WHERE id = ? AND user_id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, mealId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    /**
     * Maps a ResultSet row to a Meal object.
     */
    private Meal mapRow(ResultSet rs) throws SQLException {
        return new Meal(
            rs.getInt("id"),
            rs.getInt("user_id"),
            rs.getString("meal_type"),
            rs.getString("meal_name"),
            rs.getInt("calories"),
            rs.getDouble("protein"),
            rs.getDouble("carbs"),
            rs.getDouble("fats"),
            rs.getString("meal_date")
        );
    }
}