package com.MarryMate.servlets;

import com.MarryMate.models.RegularUser;
import com.MarryMate.models.Vendor;
import com.MarryMate.models.User;
import com.MarryMate.services.AuthService;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Servlet for handling user registration requests
 * 
 * Current Date and Time: 2025-05-03 09:27:34
 * Current User: IT24102137
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private Gson gson = new Gson();
    
    /**
     * Handle POST requests for user registration
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response content type
        response.setContentType("application/json");
        Map<String, Object> responseMap = new HashMap<>();
        
        try {
            // Get parameters from request
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String confirmPassword = request.getParameter("confirmPassword");
            String email = request.getParameter("email");
            String fullName = request.getParameter("fullName");
            String phoneNumber = request.getParameter("phone");
            String address = request.getParameter("address");
            String role = request.getParameter("role");
            
            // Validate required fields
            if (isEmpty(username) || isEmpty(password) || isEmpty(email) || 
                    isEmpty(fullName) || isEmpty(role)) {
                responseMap.put("success", false);
                responseMap.put("message", "All required fields must be filled");
                response.getWriter().write(gson.toJson(responseMap));
                return;
            }
            
            // Validate password match
            if (!password.equals(confirmPassword)) {
                responseMap.put("success", false);
                responseMap.put("message", "Passwords do not match");
                response.getWriter().write(gson.toJson(responseMap));
                return;
            }
            
            // Get AuthService instance
            AuthService authService = AuthService.getInstance(getServletContext());
            
            // Check if username already exists
            if (authService.isUsernameExists(username)) {
                responseMap.put("success", false);
                responseMap.put("message", "Username already exists. Please choose another.");
                response.getWriter().write(gson.toJson(responseMap));
                return;
            }
            
            // Check if email already exists
            if (authService.isEmailExists(email)) {
                responseMap.put("success", false);
                responseMap.put("message", "Email already registered. Please use another email or try logging in.");
                response.getWriter().write(gson.toJson(responseMap));
                return;
            }
            
            // Create user based on role
            Optional<? extends User> newUser;
            
            if ("vendor".equals(role)) {
                // For vendor, use business name and full name as contact person
                newUser = authService.registerVendor(username, password, email, fullName, fullName, phoneNumber);
            } else {
                // Default to regular user registration
                newUser = authService.registerUser(username, password, email, fullName, phoneNumber, address);
            }
            
            // Check if registration successful
            if (newUser.isPresent()) {
                // Success - store success message in session
                HttpSession session = request.getSession();
                session.setAttribute("successMessage", "Registration successful! You can now log in.");
                
                // Return success response
                responseMap.put("success", true);
                responseMap.put("message", "Registration successful! You can now log in.");
                responseMap.put("redirect", "login.jsp");
                response.getWriter().write(gson.toJson(responseMap));
            } else {
                // Failed to register - generic error
                responseMap.put("success", false);
                responseMap.put("message", "Registration failed. Please try again later.");
                response.getWriter().write(gson.toJson(responseMap));
            }
            
        } catch (Exception e) {
            // Handle any errors
            e.printStackTrace();
            responseMap.put("success", false);
            responseMap.put("message", "An error occurred. Please try again later.");
            response.getWriter().write(gson.toJson(responseMap));
        }
    }
    
    /**
     * Handle GET requests - redirect to registration page
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("/signup.jsp");
    }
    
    /**
     * Check if a string is null or empty
     * @param str String to check
     * @return True if string is null or empty, false otherwise
     */
    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
}