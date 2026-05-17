package com.siddharth.service;

import com.siddharth.config.DatabaseConfig;
import com.siddharth.model.User;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * UserService - Encapsulates all business logic and database
 * operations related to the User entity.
 * Controllers call this class instead of writing SQL directly.
 */
public class UserService {

    /**
     * Finds a user by email and password.
     * Returns the User object if found, null otherwise.
     */
    public User findByEmailAndPassword(String email, String password) throws Exception {
        String sql = "SELECT id, full_name, email FROM users WHERE email = ? AND password = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new User(rs.getInt("id"), rs.getString("full_name"), rs.getString("email"), null);
                }
            }
        }
        return null;
    }

    /**
     * Checks if an email address is already registered.
     */
    public boolean emailExists(String email) throws Exception {
        String sql = "SELECT id FROM users WHERE email = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * Registers a new user. Returns true if successful, false if email already exists.
     */
    public boolean registerUser(String fullName, String email, String password) throws Exception {
        String sql = "INSERT INTO users (full_name, email, password) VALUES (?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.executeUpdate();
            return true;
        } catch (SQLIntegrityConstraintViolationException e) {
            return false; // Duplicate email
        }
    }

    /**
     * Updates a user's password in the database.
     */
    public void updatePassword(String email, String newPassword) throws Exception {
        String sql = "UPDATE users SET password = ? WHERE email = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setString(2, email);
            ps.executeUpdate();
        }
    }

    /**
     * Updates a user's basic profile info (name, email, optional password).
     */
    public void updateProfile(int userId, String fullName, String email,
                              String newPassword) throws Exception {
        String sql;
        if (newPassword != null && !newPassword.isEmpty()) {
            sql = "UPDATE users SET full_name = ?, email = ?, password = ? WHERE id = ?";
        } else {
            sql = "UPDATE users SET full_name = ?, email = ? WHERE id = ?";
        }
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            if (newPassword != null && !newPassword.isEmpty()) {
                ps.setString(3, newPassword);
                ps.setInt(4, userId);
            } else {
                ps.setInt(3, userId);
            }
            ps.executeUpdate();
        }
    }

    /**
     * Loads all users for the admin panel.
     */
    public List<User> getAllUsers() throws Exception {
        List<User> users = new ArrayList<>();
        String sql = "SELECT id, full_name, email FROM users ORDER BY id";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                users.add(new User(rs.getInt("id"), rs.getString("full_name"), rs.getString("email"), null));
            }
        }
        return users;
    }

    /**
     * Deletes a user by ID. Meals are removed automatically via CASCADE.
     */
    public void deleteUser(int userId) throws Exception {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
}