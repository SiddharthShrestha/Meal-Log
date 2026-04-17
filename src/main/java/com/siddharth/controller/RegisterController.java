package com.siddharth.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

import com.siddharth.config.DatabaseConfig;

@WebServlet("/register")
public class RegisterController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name     = request.getParameter("name")     != null ? request.getParameter("name").trim()     : "";
        String email    = request.getParameter("email")    != null ? request.getParameter("email").trim()    : "";
        String password = request.getParameter("password") != null ? request.getParameter("password")        : "";
        String confirm  = request.getParameter("confirm")  != null ? request.getParameter("confirm")         : "";

        boolean valid = true;

        if (name.isEmpty()) {
            request.setAttribute("nameErr", "Please enter your name.");
            valid = false;
        }
        if (email.isEmpty() || !email.matches("\\S+@\\S+\\.\\S+")) {
            request.setAttribute("emailErr", "Please enter a valid email.");
            valid = false;
        }
        if (password.length() < 6) {
            request.setAttribute("passErr", "Password must be at least 6 characters.");
            valid = false;
        }
        if (!password.equals(confirm)) {
            request.setAttribute("confirmErr", "Passwords do not match.");
            valid = false;
        }

        if (!valid) {
            // Re-populate fields so user doesn't retype everything
            request.setAttribute("name",  name);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
            return;
        }

        // Insert into DB
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users (full_name, email, password) VALUES (?, ?, ?)");
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.executeUpdate();
            // Redirect to login with a success flag in the query string
            response.sendRedirect(request.getContextPath() + "/login?registered=true");
        } catch (SQLIntegrityConstraintViolationException e) {
            request.setAttribute("emailErr", "That email is already registered.");
            request.setAttribute("name",  name);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("generalErr", "Something went wrong. Please try again.");
            request.setAttribute("name",  name);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/register.jsp").forward(request, response);
        }
    }
}