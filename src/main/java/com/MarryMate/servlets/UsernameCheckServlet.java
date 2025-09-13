package com.MarryMate.servlets;

import com.MarryMate.services.AuthService;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Servlet for checking username availability via AJAX
 * 
 * Current Date and Time: 2025-05-03 09:30:49
 * Current User: IT24102137
 */
@WebServlet("/UsernameCheckServlet")
public class UsernameCheckServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private Gson gson = new Gson();
    
    /**
     * Handle GET requests for username availability check
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response content type
        response.setContentType("application/json");
        Map<String, Object> responseMap = new HashMap<>();
        
        try {
            // Get username parameter
            String username = request.getParameter("username");
            
            // Validate username
            if (username == null || username.trim().isEmpty()) {
                responseMap.put("available", false);
                responseMap.put("message", "Username cannot be empty");
                response.getWriter().write(gson.toJson(responseMap));
                return;
            }
            
            // Validate username format (3-20 characters, alphanumeric and underscore/hyphen)
            if (!username.matches("^[a-zA-Z0-9_-]{3,20}$")) {
                responseMap.put("available", false);
                responseMap.put("message", "Username must be 3-20 characters and can only contain letters, numbers, underscores, and hyphens");
                response.getWriter().write(gson.toJson(responseMap));
                return;
            }
            
            // Get AuthService instance
            AuthService authService = AuthService.getInstance(getServletContext());
            
            // Check if username exists
            boolean isExists = authService.isUsernameExists(username);
            
            // Return result
            responseMap.put("available", !isExists);
            
            if (isExists) {
                responseMap.put("message", "Username is already taken");
            } else {
                responseMap.put("message", "Username is available");
            }
            
            response.getWriter().write(gson.toJson(responseMap));
            
        } catch (Exception e) {
            e.printStackTrace();
            responseMap.put("available", false);
            responseMap.put("message", "Error checking username availability");
            response.getWriter().write(gson.toJson(responseMap));
        }
    }
}