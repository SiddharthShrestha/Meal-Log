package com.siddharth.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.*;

import com.siddharth.config.DatabaseConfig;

@WebServlet("/login")
public class LoginController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String ADMIN_EMAIL    = "siddharth@gmail.com";
    private static final String ADMIN_PASSWORD = "siddharth1488";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String loginType = request.getParameter("login_type") != null ? request.getParameter("login_type").trim() : "user";
        String email     = request.getParameter("email")      != null ? request.getParameter("email").trim()      : "";
        String password  = request.getParameter("password")   != null ? request.getParameter("password")          : "";

        boolean valid = true;

        if (email.isEmpty() || !email.matches("\\S+@\\S+\\.\\S+")) {
            request.setAttribute("emailErr", "Please enter a valid email.");
            valid = false;
        }
        if (password.length() < 6) {
            request.setAttribute("passErr", "Password must be at least 6 characters.");
            valid = false;
        }

        if (!valid) {
            request.setAttribute("email",      email);
            request.setAttribute("login_type", loginType);
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            return;
        }

        // ── ADMIN LOGIN ──
        if ("admin".equals(loginType)) {
            if (email.equals(ADMIN_EMAIL) && password.equals(ADMIN_PASSWORD)) {
                HttpSession session = request.getSession();
                session.setAttribute("adminLoggedIn", true);
                session.setAttribute("adminEmail",    email);
                response.sendRedirect(request.getContextPath() + "/admin");
            } else {
                request.setAttribute("loginErr",   "Invalid admin credentials.");
                request.setAttribute("email",      email);
                request.setAttribute("login_type", "admin");
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            }
            return;
        }

        // ── USER LOGIN ──
        try (Connection conn = DatabaseConfig.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, full_name, email FROM users WHERE email = ? AND password = ?");
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("userId",    rs.getInt("id"));
                session.setAttribute("userName",  rs.getString("full_name"));
                session.setAttribute("userEmail", rs.getString("email"));
                response.sendRedirect(request.getContextPath() + "/dashboard");
            } else {
                request.setAttribute("loginErr",   "Invalid email or password.");
                request.setAttribute("email",      email);
                request.setAttribute("login_type", "user");
                request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("loginErr",   "Something went wrong. Please try again.");
            request.setAttribute("email",      email);
            request.setAttribute("login_type", loginType);
            request.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(request, response);
        }
    }
}