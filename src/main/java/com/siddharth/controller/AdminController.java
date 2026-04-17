package com.siddharth.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import com.siddharth.config.DatabaseConfig;

@WebServlet("/admin")
public class AdminController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private List<String[]> loadAllUsers() {
        List<String[]> users = new ArrayList<>();
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, full_name, email FROM users ORDER BY id");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                users.add(new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("full_name") != null ? rs.getString("full_name") : "",
                    rs.getString("email")     != null ? rs.getString("email")     : ""
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return users;
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("users", loadAllUsers());
        request.getRequestDispatcher("/WEB-INF/pages/admin.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action") != null ? request.getParameter("action").trim() : "";

        switch (action) {

            // ── UPDATE ──
            case "update": {
                String id       = request.getParameter("id")        != null ? request.getParameter("id").trim()        : "";
                String fullName = request.getParameter("full_name")  != null ? request.getParameter("full_name").trim()  : "";
                String email    = request.getParameter("email")      != null ? request.getParameter("email").trim()      : "";

                if (id.isEmpty() || fullName.isEmpty() || email.isEmpty()) {
                    request.setAttribute("errorMsg", "All fields are required for update.");
                    break;
                }

                try (Connection conn = DatabaseConfig.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE users SET full_name = ?, email = ? WHERE id = ?");
                    ps.setString(1, fullName);
                    ps.setString(2, email);
                    ps.setInt   (3, Integer.parseInt(id));
                    int rows = ps.executeUpdate();
                    request.setAttribute("successMsg", rows + " user(s) updated successfully.");
                } catch (SQLIntegrityConstraintViolationException e) {
                    request.setAttribute("errorMsg", "That email is already in use by another account.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Update failed: " + e.getMessage());
                }
                break;
            }

            // ── DELETE ──
            case "delete": {
                String id = request.getParameter("id") != null ? request.getParameter("id").trim() : "";

                if (id.isEmpty()) {
                    request.setAttribute("errorMsg", "Missing user ID for delete.");
                    break;
                }

                try (Connection conn = DatabaseConfig.getConnection()) {
                    PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM users WHERE id = ?");
                    ps.setInt(1, Integer.parseInt(id));
                    int rows = ps.executeUpdate();
                    request.setAttribute("successMsg", rows + " user(s) deleted successfully.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("errorMsg", "Delete failed: " + e.getMessage());
                }
                break;
            }

            default:
                request.setAttribute("errorMsg", "Unknown action.");
                break;
        }

        request.setAttribute("users", loadAllUsers());
        request.getRequestDispatcher("/WEB-INF/pages/admin.jsp").forward(request, response);
    }
}