package com.siddharth.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * AuthFilter
 *
 * Intercepts EVERY request to this application (mapped to "/*").
 *
 * This is the gatekeeper — it runs before any servlet or JSP.
 * Its only job is to check if the request has a valid session.
 * If not, it redirects to login. If yes, it lets the request through.
 *
 * Think of it as a bouncer at the door of every room in the app.
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest  req = (HttpServletRequest)  request;
        HttpServletResponse res = (HttpServletResponse) response;

        String path = req.getServletPath(); // e.g. "/dashboard", "/login", "/css/style.css"

        // ════════════════════════════════════════════════════════════════════
        //  STEP 1 — Let static resources and public pages through immediately.
        //           No session check needed for these.
        // ════════════════════════════════════════════════════════════════════
        if (isPublicResource(path)) {
            chain.doFilter(request, response); // pass through, no check
            return;
        }

        // ════════════════════════════════════════════════════════════════════
        //  STEP 2 — Read the session.
        //
        //  getSession(false) is critical here.
        //  - false = do NOT create a new session if one doesn't exist.
        //    We just want to read what's already there.
        //  - If we used getSession() (no argument / true), it would create
        //    a blank session for every visitor, which defeats the purpose.
        // ════════════════════════════════════════════════════════════════════
        HttpSession session = req.getSession(false);

        boolean hasUserSession  = session != null && session.getAttribute("userId")  != null;
        boolean hasAdminSession = session != null && session.getAttribute("adminId") != null;

        // ════════════════════════════════════════════════════════════════════
        //  STEP 3 — Route rules
        // ════════════════════════════════════════════════════════════════════

        // Admin routes — need an admin session
        if (path.startsWith("/admin")) {
            if (hasAdminSession) {
                chain.doFilter(request, response); // admin is valid, let through
            } else {
                res.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        // Dashboard routes — need a user session
        if (path.startsWith("/dashboard")) {
            if (hasUserSession) {
                chain.doFilter(request, response); // user is valid, let through
            } else {
                res.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }

        // Login / register pages — if already logged in, redirect away
        // (no point showing login to someone already logged in)
        if (path.equals("/login") || path.equals("/register")) {
            if (hasUserSession) {
                res.sendRedirect(req.getContextPath() + "/dashboard");
                return;
            }
            if (hasAdminSession) {
                res.sendRedirect(req.getContextPath() + "/admin");
                return;
            }
        }

        // Anything else — just let it through
        chain.doFilter(request, response);
    }

    /**
     * Returns true for paths that never need a session check.
     * CSS, JS, images, fonts, and fully public pages.
     */
    private boolean isPublicResource(String path) {
        return path.startsWith("/css/")
            || path.startsWith("/js/")
            || path.startsWith("/images/")
            || path.startsWith("/fonts/")
            || path.equals("/login")
            || path.equals("/register")
            || path.equals("/forgot-password")
            || path.equals("/reset-password")
            || path.equals("/about")
            || path.equals("/error_404")
            || path.equals("/error_500");
    }

    @Override public void init(FilterConfig filterConfig) {}
    @Override public void destroy() {}
}