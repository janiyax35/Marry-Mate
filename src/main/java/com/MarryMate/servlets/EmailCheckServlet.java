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
import java.util.regex.Pattern;

/**
 * Servlet for checking email availability via AJAX
 * 
 * Current Date and Time: 2025-05-03 09:30:49
 * Current User: IT24102137
 */
@WebServlet("/EmailCheckServlet")
public class EmailCheckServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private Gson gson = new Gson();
    
    // Email validation pattern
    private static final Pattern EMAIL_PATTERN = 
            Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$");
    
    /**
     * Handle GET requests for email availability check
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response content type
        response.setContentType("application/json");
        Map<String, Object> responseMap = new HashMap<>();
        
        try {
            // Get email parameter
            String email = request.getParameter("email");
            
            // Validate email
            if (email == null || email.trim().isEmpty()) {
                responseMap.put("available", false);
                responseMap.put("message", "Email cannot be empty");
                response.getWriter().write(gson.toJson(responseMap));
                return;
            }
            
            // Validate email format
            if (!isValidEmail(email)) {
                responseMap.put("available", false);
                responseMap.put("message", "Invalid email format");
                response.getWriter().write(gson.toJson(responseMap));
                return;
            }
            
            // Get AuthService instance
            AuthService authService = AuthService.getInstance(getServletContext());
            
            // Check if email exists
            boolean isExists = authService.isEmailExists(email);
            
            // Return result
            responseMap.put("available", !isExists);
            
            if (isExists) {
                responseMap.put("message", "Email is already registered");
            } else {
                responseMap.put("message", "Email is available");
            }
            
            response.getWriter().write(gson.toJson(responseMap));
            
        } catch (Exception e) {
            e.printStackTrace();
            responseMap.put("available", false);
            responseMap.put("message", "Error checking email availability");
            response.getWriter().write(gson.toJson(responseMap));
        }
    }
    
    /**
     * Validate email format using regex pattern
     * @param email Email to validate
     * @return True if email format is valid, false otherwise
     */
    private boolean isValidEmail(String email) {
        if (email == null) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email).matches();
    }
}