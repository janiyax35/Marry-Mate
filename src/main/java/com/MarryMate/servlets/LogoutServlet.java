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
 * Servlet for handling user logout
 * 
 * Current Date and Time: 2025-05-03 09:30:49
 * Current User: IT24102137
 */
@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    
    /**
     * Handle GET requests for user logout
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get the current session
        HttpSession session = request.getSession(false);
        
        // If session exists, invalidate it
        if (session != null) {
            // Store username for message (optional)
            String username = (String) session.getAttribute("username");
            
            // Remove from SessionManager first
            String sessionId = session.getId();
            SessionManager.removeSession(sessionId);
            
            // Invalidate session - removes all attributes and creates a new session ID
            session.invalidate();
            
            // Create new session for messages
            session = request.getSession();
            
            // Add logout success message
            if (username != null && !username.isEmpty()) {
                session.setAttribute("successMessage", "You have been logged out successfully. Goodbye, " + username + "!");
            } else {
                session.setAttribute("successMessage", "You have been logged out successfully!");
            }
        }
        
        // Redirect to login page
        response.sendRedirect("login.jsp");
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