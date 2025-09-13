package com.MarryMate.servlets;

import com.MarryMate.models.User;
import com.MarryMate.services.AuthService;
import com.MarryMate.services.SessionManager;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Servlet for handling user login requests
 * 
 * Current Date and Time: 2025-05-05 05:57:17
 * Current User: IT24102137
 */
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
	
    
    private static final long serialVersionUID = 1L;
    private Gson gson = new Gson();
    
    /**
     * Handle POST requests for user login
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response content type
        response.setContentType("application/json");
        Map<String, Object> responseMap = new HashMap<>();
        
        try {
            // Get parameters from request
            String usernameOrEmail = request.getParameter("username");
            String password = request.getParameter("password");
            boolean rememberMe = "on".equals(request.getParameter("rememberMe"));
            
            // Validate required fields
            if (isEmpty(usernameOrEmail) || isEmpty(password)) {
                responseMap.put("success", false);
                responseMap.put("message", "Username/Email and password are required");
                response.getWriter().write(gson.toJson(responseMap));
                return;
            }
            
            // Get AuthService instance
            AuthService authService = AuthService.getInstance(getServletContext());
            authService.reloadData();
            authService.loadData();
            // First check if the account exists and what its status is
            String accountStatus = authService.checkAccountStatus(usernameOrEmail);
            if (accountStatus != null && !"active".equals(accountStatus)) {
                // Account exists but is not active
                responseMap.put("success", false);
                responseMap.put("message", authService.getAccountStatusMessage(accountStatus));
                response.getWriter().write(gson.toJson(responseMap));
                
                // Set error message in session for non-AJAX fallback
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", authService.getAccountStatusMessage(accountStatus));
                return;
            }
            
            // Attempt to authenticate
            Optional<User> authenticatedUser = authService.authenticateUser(usernameOrEmail, password);
            
            if (authenticatedUser.isPresent()) {
                // User found - create session
                User user = authenticatedUser.get();
                HttpSession session = request.getSession();
                
                // Get client information
                String ipAddress = getClientIpAddress(request);
                String userAgent = request.getHeader("User-Agent");
                
                // Store user info in session
                session.setAttribute("user", user);
                session.setAttribute("userId", user.getUserId());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("role", user.getRole());
                session.setAttribute("fullName", user.getFullName());
             
                
                // Store login time
                long loginTime = System.currentTimeMillis();
                session.setAttribute("loginTime", loginTime);
                
                // Register with SessionManager
              
                
                
                SessionManager.registerSession(
                	    session, 
                	    user.getUserId(),  
                	    user.getUsername(),
                	    user.getRole(),
                	    user.getFullName(),
                	    ipAddress,
                	    userAgent
                	);
                
                // Set session timeout - 30 minutes default, 7 days if remember me
                if (rememberMe) {
                    // 7 days in seconds
                    session.setMaxInactiveInterval(7 * 24 * 60 * 60);
                } else {
                    // 30 minutes in seconds
                    session.setMaxInactiveInterval(30 * 60);
                }
                
                // Determine redirect based on role
                String redirectUrl = determineRedirectByRole(user.getRole());
                
                // Return success response with redirect URL
                responseMap.put("success", true);
                responseMap.put("message", "Login successful!");
                responseMap.put("redirect", redirectUrl);
                responseMap.put("role", user.getRole());
                response.getWriter().write(gson.toJson(responseMap));
                
            } else {
                // Invalid credentials or inactive account
                String errorMessage = "Invalid username/email or password";
                
                // Check if account exists but is in a non-active state
                String status = authService.checkAccountStatus(usernameOrEmail);
                if (status != null && !"active".equals(status)) {
                    errorMessage = authService.getAccountStatusMessage(status);
                }
                
                responseMap.put("success", false);
                responseMap.put("message", errorMessage);
                response.getWriter().write(gson.toJson(responseMap));
                
                // Set error message in session for non-AJAX fallback
                HttpSession session = request.getSession();
                session.setAttribute("errorMessage", errorMessage);
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
     * Handle GET requests - redirect to login page
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }
    
    /**
     * Determine the redirect URL based on user role
     * @param role User role (admin, vendor, user)
     * @return String containing the redirect URL
     */
    private String determineRedirectByRole(String role) {
        switch (role.toLowerCase()) {
            case "admin":
                return "admin/dashboard.jsp";
            case "super_admin":
                return "admin/dashboard.jsp";
            case "vendor":
                return "vendor/dashboard.jsp";
            case "user":
                return "user/dashboard.jsp";
            default:
                return "index.jsp";
        }
    }
    
    /**
     * Check if a string is null or empty
     * @param str String to check
     * @return True if string is null or empty, false otherwise
     */
    private boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }
    
    /**
     * Get client's IP address
     * @param request HttpServletRequest object
     * @return String containing client IP address
     */
    private String getClientIpAddress(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (isEmpty(ip) || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (isEmpty(ip) || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (isEmpty(ip) || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (isEmpty(ip) || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (isEmpty(ip) || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        return ip;
    }
}