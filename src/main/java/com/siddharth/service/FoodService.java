package com.siddharth.service;

import com.siddharth.config.DatabaseConfig;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * FoodService - Encapsulates all business logic and database
 * operations related to the Food database.
 */
public class FoodService {

    /**
     * Returns all foods grouped by category.
     */
    public Map<String, List<Map<String, Object>>> getFoodsGrouped() throws Exception {
        Map<String, List<Map<String, Object>>> grouped = new LinkedHashMap<>();
        String sql = "SELECT * FROM foods ORDER BY category, food_name";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String category = rs.getString("category");
                grouped.computeIfAbsent(category, k -> new ArrayList<>());
                Map<String, Object> food = new LinkedHashMap<>();
                food.put("id",               rs.getInt("id"));
                food.put("food_name",         rs.getString("food_name"));
                food.put("category",          category);
                food.put("calories_per_100g", rs.getDouble("calories_per_100g"));
                food.put("protein_per_100g",  rs.getDouble("protein_per_100g"));
                food.put("carbs_per_100g",    rs.getDouble("carbs_per_100g"));
                food.put("fats_per_100g",     rs.getDouble("fats_per_100g"));
                grouped.get(category).add(food);
            }
        }
        return grouped;
    }

    /**
     * Returns all foods as a flat list for the admin table.
     */
    public List<Map<String, Object>> getAllFoods() throws Exception {
        List<Map<String, Object>> foods = new ArrayList<>();
        String sql = "SELECT * FROM foods ORDER BY category, food_name";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> food = new LinkedHashMap<>();
                food.put("id",               rs.getInt("id"));
                food.put("food_name",         rs.getString("food_name"));
                food.put("category",          rs.getString("category"));
                food.put("calories_per_100g", rs.getDouble("calories_per_100g"));
                food.put("protein_per_100g",  rs.getDouble("protein_per_100g"));
                food.put("carbs_per_100g",    rs.getDouble("carbs_per_100g"));
                food.put("fats_per_100g",     rs.getDouble("fats_per_100g"));
                foods.add(food);
            }
        }
        return foods;
    }

    /**
     * Inserts a new food item into the database.
     */
    public void createFood(String foodName, String category, double calories,
                           double protein, double carbs, double fats) throws Exception {
        String sql = "INSERT INTO foods (food_name, category, calories_per_100g, protein_per_100g, " +
                     "carbs_per_100g, fats_per_100g) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, foodName);
            ps.setString(2, category);
            ps.setDouble(3, calories);
            ps.setDouble(4, protein);
            ps.setDouble(5, carbs);
            ps.setDouble(6, fats);
            ps.executeUpdate();
        }
    }

    /**
     * Updates an existing food item.
     */
    public void updateFood(int foodId, String foodName, String category, double calories,
                           double protein, double carbs, double fats) throws Exception {
        String sql = "UPDATE foods SET food_name=?, category=?, calories_per_100g=?, " +
                     "protein_per_100g=?, carbs_per_100g=?, fats_per_100g=? WHERE id=?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, foodName);
            ps.setString(2, category);
            ps.setDouble(3, calories);
            ps.setDouble(4, protein);
            ps.setDouble(5, carbs);
            ps.setDouble(6, fats);
            ps.setInt(7, foodId);
            ps.executeUpdate();
        }
    }

    /**
     * Deletes a food item by ID.
     */
    public void deleteFood(int foodId) throws Exception {
        String sql = "DELETE FROM foods WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, foodId);
            ps.executeUpdate();
        }
    }
}