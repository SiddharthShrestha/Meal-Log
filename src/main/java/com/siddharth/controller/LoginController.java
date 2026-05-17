package com.siddharth.controller;

import com.siddharth.model.User;
import com.siddharth.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;

@WebServlet("/login")
public class LoginController extends HttpServlet {

    private final UserService userService = new UserService();

    // Brute-force protection (in-memory; resets on redeploy)
    private final ConcurrentHashMap<String, Integer> failCount  = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<String, Long>    lockUntil  = new ConcurrentHashMap<>();

    private static final int  MAX_ATTEMPTS = 3;
    private static final long LOCKOUT_MS   = 5 * 60 * 1_000L; // 5 minutes

    // -----------------------------------------------------------------------
    // GET – show login page (or redirect if already logged in)
    // -----------------------------------------------------------------------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession existing = req.getSession(false);
        if (existing != null) {
            if (existing.getAttribute("userId") != null) {
                resp.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
            if (existing.getAttribute("adminId") != null) {
                resp.sendRedirect(req.getContextPath() + "/admin");
                return;
            }
        }
        req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
    }

    // -----------------------------------------------------------------------
    // POST – process login form
    // -----------------------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email    = req.getParameter("email").trim();
        String password = req.getParameter("password");
        String role     = req.getParameter("login_type"); // "user" or "admin"

        if ("admin".equals(role)) {
            handleAdminLogin(req, resp, email, password);
        } else {
            handleUserLogin(req, resp, email, password);
        }
    }

    // -----------------------------------------------------------------------
    // Admin login
    // -----------------------------------------------------------------------
    private void handleAdminLogin(HttpServletRequest req, HttpServletResponse resp,
                                   String email, String password)
            throws IOException, ServletException {

        // Check lockout first
        if (isLockedOut(email)) {
            long remaining = (lockUntil.get(email) - System.currentTimeMillis()) / 1_000;
            req.setAttribute("loginErr",
                "Account locked. Too many failed attempts. Try again in " + remaining + " second(s).");
            req.setAttribute("login_type", "admin");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
            return;
        }

        // Hardcoded admin credentials (replace with DB lookup if needed)
        boolean credentialsMatch = "admin@meallog.com".equals(email)
                                && "admin123".equals(password);

        if (credentialsMatch) {
            // ── Successful admin login ──────────────────────────────────────
            failCount.remove(email);
            lockUntil.remove(email);

            // Invalidate any existing session to prevent session fixation
            HttpSession old = req.getSession(false);
            if (old != null) old.invalidate();

            HttpSession session = req.getSession(true);
            session.setAttribute("adminId", email);

            // ★ FIX: AdminController.isAdminLoggedIn() checks for "adminLoggedIn"
            //        (Boolean.TRUE).  LoginController was setting only "adminId",
            //        so isAdminLoggedIn() always returned false and immediately
            //        redirected back to /login.  Adding this one line fixes it.
            session.setAttribute("adminLoggedIn", Boolean.TRUE);

            session.setMaxInactiveInterval(60 * 60); // 1-hour timeout

            resp.sendRedirect(req.getContextPath() + "/admin");

        } else {
            // ── Failed attempt ──────────────────────────────────────────────
            int attempts = failCount.merge(email, 1, Integer::sum);

            if (attempts >= MAX_ATTEMPTS) {
                lockUntil.put(email, System.currentTimeMillis() + LOCKOUT_MS);
                failCount.remove(email);
                req.setAttribute("loginErr",
                    "Account locked for 5 minutes due to too many failed attempts.");
            } else {
                int left = MAX_ATTEMPTS - attempts;
                if (left == 1) {
                    req.setAttribute("loginErr",
                        "Incorrect email or password. 1 attempt left — warning.");
                } else {
                    req.setAttribute("loginErr",
                        "Incorrect email or password. " + left + " attempt(s) remaining.");
                }
            }

            req.setAttribute("login_type", "admin");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
        }
    }

    // -----------------------------------------------------------------------
    // Regular user login
    // -----------------------------------------------------------------------
    private void handleUserLogin(HttpServletRequest req, HttpServletResponse resp,
                                  String email, String password)
            throws IOException, ServletException {

        if (isLockedOut(email)) {
            long remaining = (lockUntil.get(email) - System.currentTimeMillis()) / 1_000;
            req.setAttribute("loginErr",
                "Account locked. Too many failed attempts. Try again in " + remaining + " second(s).");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
            return;
        }

        try {
            User user = userService.findByEmailAndPassword(email, password);

            if (user != null) {
                failCount.remove(email);
                lockUntil.remove(email);

                HttpSession old = req.getSession(false);
                if (old != null) old.invalidate();

                HttpSession session = req.getSession(true);
                session.setAttribute("userId",    user.getId());
                session.setAttribute("userName",  user.getFullName());
                session.setAttribute("userEmail", user.getEmail());
                session.setMaxInactiveInterval(60 * 60);

                resp.sendRedirect(req.getContextPath() + "/dashboard");

            } else {
                int attempts = failCount.merge(email, 1, Integer::sum);

                if (attempts >= MAX_ATTEMPTS) {
                    lockUntil.put(email, System.currentTimeMillis() + LOCKOUT_MS);
                    failCount.remove(email);
                    req.setAttribute("loginErr",
                        "Account locked for 5 minutes due to too many failed attempts.");
                } else {
                    int left = MAX_ATTEMPTS - attempts;
                    if (left == 1) {
                        req.setAttribute("loginErr",
                            "Incorrect email or password. 1 attempt left — warning.");
                    } else {
                        req.setAttribute("loginErr",
                            "Incorrect email or password. " + left + " attempt(s) remaining.");
                    }
                }
                req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
            }

        } catch (Exception e) {
            req.setAttribute("loginErr", "A server error occurred. Please try again.");
            req.getRequestDispatcher("/WEB-INF/pages/login.jsp").forward(req, resp);
        }
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------
    private boolean isLockedOut(String email) {
        Long until = lockUntil.get(email);
        return until != null && System.currentTimeMillis() < until;
    }
}