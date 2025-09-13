package com.MarryMate.servlets;

import com.MarryMate.services.SessionManager;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet for invalidating all sessions except the current one
 * Only admin users should be able to access this functionality
 */
@WebServlet("/InvalidateAllSessionsServlet")
public class InvalidateAllSessionsServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    /**
     * Handle GET requests for invalidating all sessions
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get the current session
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Security check - only admin users can invalidate all sessions
            String userRole = (String) session.getAttribute("role");
            boolean isAdmin = userRole != null && (userRole.contains("admin") || userRole.equals("super_admin"));
            
            if (!isAdmin) {
                // Not an admin - redirect to login with error
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=accessDenied");
                return;
            }
            
            // Admin user - invalidate all other sessions
            String currentSessionId = session.getId();
            int count = SessionManager.invalidateAllSessionsExcept(currentSessionId);
            
            // Redirect to sessions page with success message
            response.sendRedirect(request.getContextPath() + "/sessions.jsp?message=Successfully+invalidated+" + count + "+sessions");
        } else {
            // No session - redirect to login
            response.sendRedirect(request.getContextPath() + "/login.jsp");
        }
    }
    
    /**
     * Handle POST requests - redirect to GET
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}