package com.siddharth.controller;

import com.siddharth.config.DatabaseConfig;
import com.siddharth.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.Instant;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.ConcurrentHashMap;

@WebServlet({"/forgot-password", "/reset-password"})
public class ForgotPasswordController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final long OTP_TTL_MS = 10 * 60 * 1000L; // 10 minutes

    // email -> OTP
    private static final Map<String, String> emailToOtp  = new ConcurrentHashMap<>();
    // email -> creation time
    private static final Map<String, Long>   otpTime     = new ConcurrentHashMap<>();
    // email -> verified (allowed to access reset page)
    private static final Map<String, Boolean> otpVerified = new ConcurrentHashMap<>();

    private String generateOtp(String email) {
        String otp = String.format("%06d", new Random().nextInt(999999));
        emailToOtp.put(email, otp);
        otpTime.put(email, Instant.now().toEpochMilli());
        otpVerified.put(email, false);
        return otp;
    }

    private boolean isOtpValid(String email, String otp) {
        if (email == null || otp == null) return false;
        Long created = otpTime.get(email);
        if (created == null) return false;
        if (Instant.now().toEpochMilli() - created > OTP_TTL_MS) {
            emailToOtp.remove(email);
            otpTime.remove(email);
            return false;
        }
        return otp.equals(emailToOtp.get(email));
    }

    private boolean isOtpExpired(String email) {
        Long created = otpTime.get(email);
        if (created == null) return true;
        return Instant.now().toEpochMilli() - created > OTP_TTL_MS;
    }

    private boolean emailExists(String email) throws Exception {
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT id FROM users WHERE email = ?")) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    private void updatePassword(String email, String newPassword) throws Exception {
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE users SET password = ? WHERE email = ?")) {
            ps.setString(1, newPassword);
            ps.setString(2, email);
            ps.executeUpdate();
        }
    }

    private static String nvl(String s) { return s == null ? "" : s.trim(); }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if ("/reset-password".equals(request.getServletPath())) {
            String email = nvl(request.getParameter("email"));
            if (email.isEmpty() || !Boolean.TRUE.equals(otpVerified.get(email)) || isOtpExpired(email)) {
                request.setAttribute("tokenErr", "Invalid or expired session. Please request a new code.");
                request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp")
                       .forward(request, response);
                return;
            }
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/reset_password.jsp")
                   .forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp")
                   .forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = nvl(request.getParameter("action"));

        if ("verify_otp".equals(action)) {
            handleVerifyOtp(request, response);
        } else if ("/reset-password".equals(request.getServletPath())) {
            handleResetPassword(request, response);
        } else {
            handleForgotPassword(request, response);
        }
    }

    // Step 1 — user submits email, we send OTP
    private void handleForgotPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = nvl(request.getParameter("email"));

        if (!email.matches("\\S+@\\S+\\.\\S+")) {
            request.setAttribute("emailErr", "Please enter a valid email address.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp")
                   .forward(request, response);
            return;
        }

        try {
            if (!emailExists(email)) {
                request.setAttribute("otpSent", Boolean.TRUE);
                request.setAttribute("email", email);
                request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp")
                       .forward(request, response);
                return;
            }

            String otp = generateOtp(email);

            try {
                EmailUtil.sendOtpEmail(email, otp);
            } catch (Exception mailEx) {
                mailEx.printStackTrace();
            }

            request.setAttribute("otpSent", Boolean.TRUE);
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp")
                   .forward(request, response);

        } catch (Exception e) {
            request.setAttribute("emailErr", "Something went wrong. Please try again.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp")
                   .forward(request, response);
        }
    }

    // Step 2 — user submits the OTP
    private void handleVerifyOtp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = nvl(request.getParameter("email"));
        String otp   = nvl(request.getParameter("otp"));

        if (isOtpExpired(email)) {
            request.setAttribute("otpErr", "Your code has expired. Please request a new one.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp")
                   .forward(request, response);
            return;
        }

        if (!isOtpValid(email, otp)) {
            request.setAttribute("otpSent", Boolean.TRUE);
            request.setAttribute("otpErr", "Incorrect code. Please try again.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp")
                   .forward(request, response);
            return;
        }

        // OTP is correct — mark as verified and go to reset page
        otpVerified.put(email, true);
        request.setAttribute("email", email);
        request.getRequestDispatcher("/WEB-INF/pages/reset_password.jsp")
               .forward(request, response);
    }

    // Step 3 — user submits new password
    private void handleResetPassword(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email       = nvl(request.getParameter("email"));
        String newPassword = nvl(request.getParameter("password"));
        String confirmPass = nvl(request.getParameter("confirmPassword"));

        if (!Boolean.TRUE.equals(otpVerified.get(email))) {
            request.setAttribute("tokenErr", "Invalid session. Please request a new code.");
            request.getRequestDispatcher("/WEB-INF/pages/forgot_password.jsp")
                   .forward(request, response);
            return;
        }
        if (newPassword.length() < 6) {
            request.setAttribute("passErr", "Password must be at least 6 characters.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/reset_password.jsp")
                   .forward(request, response);
            return;
        }
        if (!newPassword.equals(confirmPass)) {
            request.setAttribute("passErr", "Passwords do not match.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/reset_password.jsp")
                   .forward(request, response);
            return;
        }

        try {
            updatePassword(email, newPassword);
            // Clean up
            emailToOtp.remove(email);
            otpTime.remove(email);
            otpVerified.remove(email);
            response.sendRedirect(request.getContextPath() + "/login?passwordReset=true");
        } catch (Exception e) {
            request.setAttribute("passErr", "Failed to update password. Please try again.");
            request.setAttribute("email", email);
            request.getRequestDispatcher("/WEB-INF/pages/reset_password.jsp")
                   .forward(request, response);
        }
    }
}