package com.MarryMate.servlets;

import com.MarryMate.models.User;
import com.MarryMate.services.UserManagementService;
import com.MarryMate.services.AuthService;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Servlet handling User Management operations
 * Maps to /UserManagementServlet endpoint
 * 
 * Current Date and Time: 2025-05-05 18:27:32
 * Current User: IT24102137
 */
@WebServlet("/UserManagementServlet/*")
public class UserManagementServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private UserManagementService userService;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        super.init();
        String realPath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\users.json";
        userService = new UserManagementService(realPath);
        gson = new Gson();
    }
    
    /**
     * Handle GET requests for retrieving user data
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        // Handle export requests
        if (pathInfo != null && pathInfo.equals("/export")) {
            processExportUsers(request, response);
            return;
        }
        
        // Get a specific user by ID
        String userId = request.getParameter("userId");
        if (userId != null && !userId.trim().isEmpty()) {
            processGetUserById(userId, response);
            return;
        }
        
        // Handle filtering and search
        String status = request.getParameter("status");
        String dateRange = request.getParameter("dateRange");
        String search = request.getParameter("search");
        
        if (status != null || dateRange != null || search != null) {
            processFilterUsers(status, dateRange, search, response);
        } else {
            // Get all users
            processGetAllUsers(response);
        }
    }
    
    /**
     * Handle POST requests for creating new users
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Read the request body to get JSON data
        String requestBody = readRequestBody(request);
        
        try {
            // Convert JSON to a map of user data
            Map<String, String> userData = parseJsonToMap(requestBody);
            
            // Create the user
            User newUser = userService.createUser(userData);
            
            // Reload data in AuthService to synchronize changes
            try {
                AuthService authService = AuthService.getInstance(getServletContext());
                authService.reloadData();
                System.out.println("UserManagementServlet: AuthService data reloaded after user creation");
            } catch (Exception e) {
                // Log the error but continue with the response
                System.err.println("Error reloading AuthService data: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Send success response
            sendJsonResponse(response, HttpServletResponse.SC_CREATED, 
                    createSuccessResponse("User created successfully", newUser));
                    
        } catch (Exception e) {
            // Handle errors
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, 
                    "Failed to create user: " + e.getMessage());
        }
    }
    
    /**
     * Handle PUT requests for updating existing users
     */
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Read the request body to get JSON data
        String requestBody = readRequestBody(request);
        
        try {
            // Convert JSON to a map of user data
            Map<String, String> userData = parseJsonToMap(requestBody);
            
            // Extract userId from the data
            String userId = userData.get("userId");
            if (userId == null || userId.trim().isEmpty()) {
                throw new IllegalArgumentException("User ID is required");
            }
            
            // Update the user
            User updatedUser = userService.updateUser(userId, userData);
            
            // Reload data in AuthService to synchronize changes
            try {
                AuthService authService = AuthService.getInstance(getServletContext());
                authService.reloadData();
                System.out.println("UserManagementServlet: AuthService data reloaded after user update");
            } catch (Exception e) {
                // Log the error but continue with the response
                System.err.println("Error reloading AuthService data: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Send success response
            sendJsonResponse(response, HttpServletResponse.SC_OK, 
                    createSuccessResponse("User updated successfully", updatedUser));
                    
        } catch (Exception e) {
            // Handle errors
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, 
                    "Failed to update user: " + e.getMessage());
        }
    }
    
    /**
     * Handle DELETE requests for removing users
     */
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get the user ID from the request
        String userId = request.getParameter("userId");
        
        if (userId == null || userId.trim().isEmpty()) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, 
                    "User ID is required");
            return;
        }
        
        try {
            // Delete the user
            boolean deleted = userService.deleteUser(userId);
            
            if (deleted) {
                // Reload data in AuthService to synchronize changes
                try {
                    AuthService authService = AuthService.getInstance(getServletContext());
                    authService.reloadData();
                    System.out.println("UserManagementServlet: AuthService data reloaded after user deletion");
                } catch (Exception e) {
                    // Log the error but continue with the response
                    System.err.println("Error reloading AuthService data: " + e.getMessage());
                    e.printStackTrace();
                }
                
                // Send success response
                sendJsonResponse(response, HttpServletResponse.SC_OK, 
                        createSuccessResponse("User deleted successfully", null));
            } else {
                // User not found
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, 
                        "User with ID " + userId + " not found");
            }
            
        } catch (Exception e) {
            // Handle errors
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    "Failed to delete user: " + e.getMessage());
        }
    }
    
    /**
     * Process a request to get all users
     * @param response HTTP response
     * @throws IOException If an I/O error occurs
     */
    private void processGetAllUsers(HttpServletResponse response) throws IOException {
        try {
            List<User> users = userService.getAllUsers();
            sendJsonResponse(response, HttpServletResponse.SC_OK, users);
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    "Failed to retrieve users: " + e.getMessage());
        }
    }
    
    /**
     * Process a request to get a specific user by ID
     * @param userId User ID to retrieve
     * @param response HTTP response
     * @throws IOException If an I/O error occurs
     */
    private void processGetUserById(String userId, HttpServletResponse response) throws IOException {
        try {
            Optional<User> user = userService.getUserById(userId);
            
            if (user.isPresent()) {
                sendJsonResponse(response, HttpServletResponse.SC_OK, user.get());
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, 
                        "User with ID " + userId + " not found");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    "Failed to retrieve user: " + e.getMessage());
        }
    }
    
    /**
     * Process a request to filter users
     * @param status Status filter criteria
     * @param dateRange Date range filter criteria
     * @param search Search term filter criteria
     * @param response HTTP response
     * @throws IOException If an I/O error occurs
     */
    private void processFilterUsers(String status, String dateRange, String search, 
            HttpServletResponse response) throws IOException {
        try {
            List<User> filteredUsers = userService.filterUsers(status, dateRange, search);
            sendJsonResponse(response, HttpServletResponse.SC_OK, filteredUsers);
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    "Failed to filter users: " + e.getMessage());
        }
    }
    
    /**
     * Process a request to export users
     * @param request HTTP request
     * @param response HTTP response
     * @throws IOException If an I/O error occurs
     */
    private void processExportUsers(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String format = request.getParameter("format");
        String status = request.getParameter("status");
        String dateRange = request.getParameter("dateRange");
        String search = request.getParameter("search");
        
        if (format == null || format.trim().isEmpty()) {
            format = "csv"; // Default format
        }
        
        try {
            // Get filtered users
            List<User> users = userService.filterUsers(status, dateRange, search);
            
            // Set response headers based on format
            switch (format.toLowerCase()) {
                case "excel":
                    response.setContentType("application/vnd.ms-excel");
                    response.setHeader("Content-Disposition", "attachment; filename=users.xls");
                    userService.exportUsersToExcel(users, response.getOutputStream());
                    break;
                    
                case "pdf":
                    response.setContentType("application/pdf");
                    response.setHeader("Content-Disposition", "attachment; filename=users.pdf");
                    userService.exportUsersToPDF(users, response.getOutputStream());
                    break;
                    
                case "csv":
                default:
                    response.setContentType("text/csv");
                    response.setHeader("Content-Disposition", "attachment; filename=users.csv");
                    userService.exportUsersToCSV(users, response.getOutputStream());
                    break;
            }
            
        } catch (Exception e) {
            response.setContentType("text/plain");
            PrintWriter out = response.getWriter();
            out.println("Error exporting users: " + e.getMessage());
        }
    }
    
    /**
     * Read the request body into a string
     * @param request HTTP request
     * @return Request body as string
     * @throws IOException If an I/O error occurs
     */
    private String readRequestBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        String line;
        
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        
        return sb.toString();
    }
    
    /**
     * Parse JSON string to a map of strings
     * @param json JSON string
     * @return Map of key-value pairs
     */
    private Map<String, String> parseJsonToMap(String json) {
        Map<String, String> map = new HashMap<>();
        
        JsonObject jsonObject = JsonParser.parseString(json).getAsJsonObject();
        
        for (String key : jsonObject.keySet()) {
            if (!jsonObject.get(key).isJsonNull()) {
                map.put(key, jsonObject.get(key).getAsString());
            }
        }
        
        return map;
    }
    
    /**
     * Send a JSON response
     * @param response HTTP response
     * @param status HTTP status code
     * @param data Data object to convert to JSON
     * @throws IOException If an I/O error occurs
     */
    private void sendJsonResponse(HttpServletResponse response, int status, Object data) 
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(status);
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }
    
    /**
     * Send an error response
     * @param response HTTP response
     * @param status HTTP status code
     * @param message Error message
     * @throws IOException If an I/O error occurs
     */
    private void sendErrorResponse(HttpServletResponse response, int status, String message) 
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(status);
        
        JsonObject errorJson = new JsonObject();
        errorJson.addProperty("success", false);
        errorJson.addProperty("message", message);
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(errorJson));
        out.flush();
    }
    
    /**
     * Create a success response object
     * @param message Success message
     * @param data Data to include (optional)
     * @return Map representing the response
     */
    private Map<String, Object> createSuccessResponse(String message, Object data) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", message);
        
        if (data != null) {
            response.put("data", data);
        }
        
        return response;
    }
}