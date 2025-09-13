package com.MarryMate.servlets;

import com.MarryMate.services.SessionManager;
import com.MarryMate.services.SessionManager.SessionInfo;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.text.SimpleDateFormat;
import java.util.TimeZone;

/**
 * Servlet for retrieving detailed session information
 * Used by AJAX calls from session management page
 * 
 * Current Date and Time: 2025-05-03 20:57:01
 * Current User: IT24102137
 */
@WebServlet("/ViewSessionDetailsServlet")
public class ViewSessionDetailsServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private Gson gson = new GsonBuilder().setPrettyPrinting().create();
    
    /**
     * Handle GET requests for session details
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response content type
        response.setContentType("application/json");
        Map<String, Object> responseMap = new HashMap<>();
        
        // Get the current session for security check
        HttpSession currentSession = request.getSession(false);
        
        if (currentSession == null) {
            // No session - return error
            responseMap.put("success", false);
            responseMap.put("message", "No active session. Please log in.");
            response.getWriter().write(gson.toJson(responseMap));
            return;
        }
        
        // Security check - only admin users can view session details
        String userRole = (String) currentSession.getAttribute("role");
        boolean isAdmin = userRole != null && (userRole.contains("admin") || userRole.equals("super_admin"));
        
        if (!isAdmin) {
            // Not an admin - return error
            responseMap.put("success", false);
            responseMap.put("message", "Access denied. Admin privileges required.");
            response.getWriter().write(gson.toJson(responseMap));
            return;
        }
        
        // Get session ID parameter
        String sessionId = request.getParameter("sessionId");
        
        if (sessionId == null || sessionId.trim().isEmpty()) {
            // No session ID - return error
            responseMap.put("success", false);
            responseMap.put("message", "Session ID is required.");
            response.getWriter().write(gson.toJson(responseMap));
            return;
        }
        
        // Get session info
        SessionInfo sessionInfo = SessionManager.getSessionInfo(sessionId);
        
        if (sessionInfo == null) {
            // Session not found - return error
            responseMap.put("success", false);
            responseMap.put("message", "Session not found or expired.");
            response.getWriter().write(gson.toJson(responseMap));
            return;
        }
        
        // Create a details map with formatted values
        Map<String, Object> detailsMap = new HashMap<>();
        
        // Basic session info
        detailsMap.put("sessionId", sessionInfo.sessionId);
        detailsMap.put("userId", sessionInfo.userId);
        detailsMap.put("username", sessionInfo.username);
        detailsMap.put("role", sessionInfo.role);
        detailsMap.put("fullName", sessionInfo.fullName);
        detailsMap.put("ipAddress", sessionInfo.ipAddress);
        detailsMap.put("userAgent", sessionInfo.userAgent);
        
        // Device and browser info
        detailsMap.put("deviceType", sessionInfo.deviceType);
        detailsMap.put("browser", sessionInfo.browser);
        
        // Time-related info with proper formatting
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        
        detailsMap.put("loginTime", sessionInfo.loginTime);  // Raw value for calculations
        detailsMap.put("lastActivityTime", sessionInfo.lastActivityTime); // Raw value for calculations
        detailsMap.put("loginTimeFormatted", dateFormat.format(new Date(sessionInfo.loginTime)));
        detailsMap.put("lastActivityFormatted", dateFormat.format(new Date(sessionInfo.lastActivityTime)));
        
        // Calculate duration
        long currentTime = System.currentTimeMillis();
        long durationMs = currentTime - sessionInfo.loginTime;
        long durationSeconds = durationMs / 1000;
        
        long hours = durationSeconds / 3600;
        long minutes = (durationSeconds % 3600) / 60;
        long seconds = durationSeconds % 60;
        
        String durationText = String.format("%02d:%02d:%02d", hours, minutes, seconds);
        detailsMap.put("duration", durationText);
        
        // Return success with detailed info
        responseMap.put("success", true);
        responseMap.put("sessionInfo", detailsMap);
        response.getWriter().write(gson.toJson(responseMap));
    }
}