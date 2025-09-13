package com.MarryMate.services;

import java.text.SimpleDateFormat;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionBindingEvent;
import javax.servlet.http.HttpSessionBindingListener;
import javax.servlet.ServletContext;

/**
 * Session Management service for Marry Mate Wedding Planning System
 * Tracks all active sessions and provides methods to view and manage them
 * 
 * Current Date and Time: 2025-05-03 20:57:01
 * Current User: IT24102137
 */
public class SessionManager {
    
    // Singleton instance
    private static SessionManager instance;
    
    // Track actual HttpSession objects for direct invalidation
    private static final ConcurrentHashMap<String, HttpSession> httpSessions = new ConcurrentHashMap<>();
    
    // ConcurrentHashMap for thread-safe access to session data
    private static final ConcurrentHashMap<String, SessionInfo> activeSessions = new ConcurrentHashMap<>();
    
    /**
     * Inner class to store session information
     */
    public static class SessionInfo {
        public String sessionId;
        public String userId;
        public String username;
        public String role;
        public String fullName;
        public long loginTime;
        public long lastActivityTime;
        public String ipAddress;
        public String userAgent;
        public String deviceType;
        public String browser;
        
        public SessionInfo(String sessionId, String userId, String username,String role, String fullName, long loginTime,String ipAddress, String userAgent) {
        	this.sessionId = sessionId;
        	this.userId = userId;
        	this.username = username;
        	this.role = role;
        	this.fullName = fullName;
        	this.loginTime = loginTime;
        	this.lastActivityTime = loginTime;
        	this.ipAddress = ipAddress;
        	this.userAgent = userAgent;
  
  // Parse user agent for device and browser info
        	parseUserAgent(userAgent);
        }
        
        /**
         * Parse user agent string to determine device type and browser
         */
        private void parseUserAgent(String userAgent) {
            if (userAgent == null) {
                this.deviceType = "Unknown";
                this.browser = "Unknown";
                return;
            }
            
            // Simple device detection
            if (userAgent.contains("Mobile") || userAgent.contains("Android") && userAgent.contains("Mobi")) {
                this.deviceType = "Mobile";
            } else if (userAgent.contains("iPad") || userAgent.contains("Tablet")) {
                this.deviceType = "Tablet";
            } else {
                this.deviceType = "Desktop";
            }
            
            // Simple browser detection
            if (userAgent.contains("Firefox")) {
                this.browser = "Firefox";
            } else if (userAgent.contains("Chrome") && !userAgent.contains("Edg")) {
                this.browser = "Chrome";
            } else if (userAgent.contains("Safari") && !userAgent.contains("Chrome")) {
                this.browser = "Safari";
            } else if (userAgent.contains("Edg")) {
                this.browser = "Edge";
            } else if (userAgent.contains("MSIE") || userAgent.contains("Trident")) {
                this.browser = "Internet Explorer";
            } else {
                this.browser = "Other";
            }
        }
        
        /**
         * Update the last activity time
         * @param time Current time in milliseconds
         */
        public void updateLastActivity(long time) {
            this.lastActivityTime = time;
        }
        
        /**
         * Get formatted login time
         * @return Formatted login time string
         */
        public String getFormattedLoginTime() {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            formatter.setTimeZone(TimeZone.getTimeZone("UTC"));
            return formatter.format(new Date(loginTime));
        }
        
        /**
         * Get formatted last activity time
         * @return Formatted last activity time string
         */
        public String getFormattedLastActivityTime() {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            formatter.setTimeZone(TimeZone.getTimeZone("UTC"));
            return formatter.format(new Date(lastActivityTime));
        }
        
        /**
         * Get session duration as formatted string
         * @return Formatted duration (HH:MM:SS)
         */
        public String getFormattedDuration() {
            long current = System.currentTimeMillis();
            long durationMs = current - loginTime;
            long durationSeconds = durationMs / 1000;
            
            long hours = durationSeconds / 3600;
            long minutes = (durationSeconds % 3600) / 60;
            long seconds = durationSeconds % 60;
            
            return String.format("%02d:%02d:%02d", hours, minutes, seconds);
        }
    }
    
    /**
     * Session listener to handle session binding events
     * Allows automatic tracking of session invalidation
     */
    private static class SessionTracker implements HttpSessionBindingListener {
        private String sessionId;
        
        public SessionTracker(String sessionId) {
            this.sessionId = sessionId;
        }
        
        @Override
        public void valueBound(HttpSessionBindingEvent event) {
            // Session created/bound - nothing to do as registration is done separately
        }
        
        @Override
        public void valueUnbound(HttpSessionBindingEvent event) {
            // Session unbound (invalidated or timeout) - remove from tracking
            removeSession(sessionId);
        }
    }
    
    /**
     * Private constructor to enforce singleton pattern
     */
    private SessionManager() {
    }
    
    /**
     * Get the singleton instance
     * @return SessionManager instance
     */
    public static synchronized SessionManager getInstance() {
        if (instance == null) {
            instance = new SessionManager();
        }
        return instance;
    }
    
    /**
     * Register a new session
     * @param session HttpSession to register
     * @param userId User ID (can be null for non-logged in sessions)
     * @param username Username (can be null)
     * @param role User role (can be null)
     * @param fullName User's full name (can be null)
     * @param ipAddress Client IP address
     * @param userAgent Client User-Agent
     */
    public static void registerSession(HttpSession session, String userId, String username,String role, String fullName, String ipAddress, String userAgent) {
    	if (session != null) {
    			String sessionId = session.getId();
    			long loginTime = System.currentTimeMillis();

    			// Create session info object
    			SessionInfo info = new SessionInfo(sessionId, userId, username, role, fullName,loginTime, ipAddress, userAgent);

    			// Store in maps
    			activeSessions.put(sessionId, info);
    			httpSessions.put(sessionId, session);

    			// Add listener to track session lifecycle
    			session.setAttribute("SESSION_TRACKER", new SessionTracker(sessionId));

    			// Debug output
    			System.out.println("Registered session: " + sessionId + " for user: " + (username != null ? username : "anonymous") + " with ID: " + userId + "role: " + role);
    			System.out.println("UserId: " + userId);
    	}
}
    
    /**
     * Remove a session from tracking
     * @param sessionId Session ID to remove
     */
    public static void removeSession(String sessionId) {
        if (sessionId != null) {
            SessionInfo removedInfo = activeSessions.remove(sessionId);
            httpSessions.remove(sessionId);
            
            if (removedInfo != null) {
                System.out.println("Removed session: " + sessionId + " for user: " + 
                                  (removedInfo.username != null ? removedInfo.username : "anonymous"));
            }
        }
    }
    
    /**
     * Update a session's last activity time
     * @param sessionId Session ID to update
     * @param time Current time in milliseconds
     */
    public static void updateSessionActivity(String sessionId, long time) {
        if (sessionId != null) {
            SessionInfo info = activeSessions.get(sessionId);
            if (info != null) {
                info.updateLastActivity(time);
            }
        }
    }
    
    /**
     * Get information about a specific session
     * @param sessionId Session ID to look up
     * @return SessionInfo object if found, null otherwise
     */
    public static SessionInfo getSessionInfo(String sessionId) {
        return activeSessions.get(sessionId);
    }
    
    /**
     * Get all active sessions
     * @return Map of all active sessions (session ID to SessionInfo)
     */
    public static Map<String, SessionInfo> getActiveSessions() {
        return Collections.unmodifiableMap(activeSessions);
    }
    
    /**
     * Invalidate a session
     * @param sessionId Session ID to invalidate
     * @return true if session was found and invalidated, false otherwise
     */
    public static boolean invalidateSession(String sessionId) {
        SessionInfo info = activeSessions.get(sessionId);
        HttpSession session = httpSessions.get(sessionId);
        
        if (info != null) {
            // Remove from tracking
            activeSessions.remove(sessionId);
            httpSessions.remove(sessionId);
            
            // Actually invalidate the session if we have access to it
            if (session != null) {
                try {
                    session.invalidate();
                    System.out.println("Successfully invalidated HTTP session: " + sessionId);
                } catch (IllegalStateException e) {
                    // Session was already invalidated
                    System.out.println("Session was already invalidated: " + sessionId);
                }
            }
            
            // Log invalidation
            System.out.println("Invalidated session: " + sessionId + " for user: " + 
                              (info.username != null ? info.username : "anonymous"));
            return true;
        }
        
        return false;
    }
    
    /**
     * Invalidate all sessions except the current one
     * @param currentSessionId Current session ID to exclude from invalidation
     * @return Number of sessions invalidated
     */
    public static int invalidateAllSessionsExcept(String currentSessionId) {
        int count = 0;
        
        // Create a copy of the keys to avoid concurrent modification
        List<String> sessionIds = new ArrayList<>(activeSessions.keySet());
        
        for (String sessionId : sessionIds) {
            if (!sessionId.equals(currentSessionId)) {
                if (invalidateSession(sessionId)) {
                    count++;
                }
            }
        }
        
        System.out.println("Invalidated " + count + " sessions (kept session: " + currentSessionId + ")");
        return count;
    }
    
    /**
     * Get total count of active sessions
     * @return Number of active sessions
     */
    public static int getActiveSessionCount() {
        return activeSessions.size();
    }
    
    /**
     * Find the real HttpSession for a session ID via ServletContext
     * Used when the session is not in our local cache
     * 
     * @param sessionId Session ID to find
     * @param context ServletContext to use for finding the session
     * @return HttpSession if found, null otherwise
     */
    public static HttpSession findHttpSession(String sessionId, ServletContext context) {
        // First check our cache
        HttpSession session = httpSessions.get(sessionId);
        if (session != null) {
            return session;
        }
        
        // If not in cache, this is a more complex operation that may not be supported
        // by all servlet containers, but we'll attempt it
        try {
            // This is implementation-specific and may not work in all servers
            // For Tomcat, trying to access session through reflection:
            Object manager = context.getAttribute("org.apache.catalina.session.SessionManager");
            if (manager != null) {
                java.lang.reflect.Method findSession = manager.getClass().getMethod("findSession", String.class);
                Object httpSession = findSession.invoke(manager, sessionId);
                if (httpSession instanceof HttpSession) {
                    return (HttpSession) httpSession;
                }
            }
        } catch (Exception e) {
            // This is expected to fail in many environments, so just log
            System.out.println("Could not find session using reflection: " + e.getMessage());
        }
        
        return null;
    }
}