package com.MarryMate.servlets.User;

import com.MarryMate.models.User;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Servlet to handle user profile operations
 * - Load user profile data
 * - Update user profile data
 * - Update profile picture URL
 * 
 * Current Date and Time: 2025-05-18 13:23:08
 * Current User: IT24102083
 */
@WebServlet("/UserProfileServlet")
public class UserProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String USER_DATA_FILE = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\users.json";
    
    public UserProfileServlet() {
        super();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        
        // Redirect if not logged in
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "viewProfile";
        }
        
        switch (action) {
            case "viewProfile":
                viewProfile(request, response, userId);
                break;
            case "editProfile":
                prepareEditProfile(request, response, userId);
                break;
            default:
                viewProfile(request, response, userId);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        
        // Redirect if not logged in
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null) {
            action = "updateProfile";
        }
        
        switch (action) {
            case "updateProfile":
                updateProfile(request, response, userId);
                break;
            case "changePassword":
                changePassword(request, response, userId);
                break;
            case "updateProfileImage":
                updateProfileImage(request, response, userId);
                break;
            default:
                viewProfile(request, response, userId);
                break;
        }
    }
    
    private void viewProfile(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        JsonObject user = getUserById(userId);
        
        if (user != null) {
            request.setAttribute("userProfile", user);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/user/profile.jsp");
            dispatcher.forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalidUser");
        }
    }
    
    private void prepareEditProfile(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        JsonObject user = getUserById(userId);
        
        if (user != null) {
            request.setAttribute("userProfile", user);
            request.setAttribute("editMode", true);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/user/profile.jsp");
            dispatcher.forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalidUser");
        }
    }
    
    private void updateProfile(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        // Get the user data from the form
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String phoneNumber = request.getParameter("phoneNumber");
        String address = request.getParameter("address");
        String profilePictureURL = request.getParameter("profilePictureURL");
        
        // Validate required fields
        if (username == null || username.trim().isEmpty() || 
            email == null || email.trim().isEmpty() || 
            fullName == null || fullName.trim().isEmpty()) {
            
            request.setAttribute("error", "Required fields cannot be empty");
            prepareEditProfile(request, response, userId);
            return;
        }
        
        // Load all users
        List<JsonObject> users = getAllUsers();
        boolean userUpdated = false;
        
        // Find and update the user
        for (int i = 0; i < users.size(); i++) {
            JsonObject user = users.get(i);
            
            if (user.get("userId").getAsString().equals(userId)) {
                user.addProperty("username", username);
                user.addProperty("email", email);
                user.addProperty("fullName", fullName);
                user.addProperty("phoneNumber", phoneNumber);
                user.addProperty("address", address);
                
                // Update profile picture URL if provided
                if (profilePictureURL != null && !profilePictureURL.trim().isEmpty()) {
                    user.addProperty("profilePictureURL", profilePictureURL);
                }
                
                // Update timestamp and updater info
                user.addProperty("updatedAt", getCurrentDateTime());
                user.addProperty("updatedBy", "IT24102083");
                
                userUpdated = true;
                break;
            }
        }
        
        if (userUpdated) {
            // Save updated users back to the JSON file
            saveUsers(users);
            
            // Update session attributes
            HttpSession session = request.getSession();
            session.setAttribute("username", username);
            session.setAttribute("fullName", fullName);
            
            request.setAttribute("message", "Profile updated successfully");
        } else {
            request.setAttribute("error", "Unable to update profile");
        }
        
        viewProfile(request, response, userId);
    }
    
    private void changePassword(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        String currentPassword = request.getParameter("currentPassword");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");
        
        // Validate input
        if (currentPassword == null || currentPassword.trim().isEmpty() || 
            newPassword == null || newPassword.trim().isEmpty() || 
            confirmPassword == null || confirmPassword.trim().isEmpty()) {
            
            request.setAttribute("passwordError", "All password fields are required");
            viewProfile(request, response, userId);
            return;
        }
        
        if (!newPassword.equals(confirmPassword)) {
            request.setAttribute("passwordError", "New password and confirmation do not match");
            viewProfile(request, response, userId);
            return;
        }
        
        // Load all users
        List<JsonObject> users = getAllUsers();
        boolean passwordChanged = false;
        
        // Find the user and check current password
        for (int i = 0; i < users.size(); i++) {
            JsonObject user = users.get(i).getAsJsonObject();
            
            if (user.get("userId").getAsString().equals(userId)) {
                String storedPassword = user.get("password").getAsString();
                
                if (storedPassword.equals(currentPassword)) {
                    // Update password
                    user.addProperty("password", newPassword);
                    user.addProperty("updatedAt", getCurrentDateTime());
                    user.addProperty("updatedBy", "IT24102083");
                    
                    passwordChanged = true;
                } else {
                    request.setAttribute("passwordError", "Current password is incorrect");
                }
                
                break;
            }
        }
        
        if (passwordChanged) {
            // Save updated users back to the JSON file
            saveUsers(users);
            request.setAttribute("passwordMessage", "Password changed successfully");
        }
        
        viewProfile(request, response, userId);
    }
    
    private void updateProfileImage(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        String profileImageUrl = request.getParameter("profileImageUrl");
        
        // Validate URL
        if (profileImageUrl == null || profileImageUrl.trim().isEmpty()) {
            request.setAttribute("imageError", "Image URL cannot be empty");
            viewProfile(request, response, userId);
            return;
        }
        
        // Load all users
        List<JsonObject> users = getAllUsers();
        boolean imageUpdated = false;
        
        // Find and update the user's profile image URL
        for (int i = 0; i < users.size(); i++) {
            JsonObject user = users.get(i).getAsJsonObject();
            
            if (user.get("userId").getAsString().equals(userId)) {
                user.addProperty("profilePictureURL", profileImageUrl);
                user.addProperty("updatedAt", getCurrentDateTime());
                user.addProperty("updatedBy", "IT24102083");
                
                imageUpdated = true;
                break;
            }
        }
        
        if (imageUpdated) {
            // Save updated users back to the JSON file
            saveUsers(users);
            
            // Update session attribute if needed
            HttpSession session = request.getSession();
            session.setAttribute("profilePictureURL", profileImageUrl);
            
            request.setAttribute("imageMessage", "Profile picture updated successfully");
        } else {
            request.setAttribute("imageError", "Failed to update profile picture");
        }
        
        viewProfile(request, response, userId);
    }
    
    // Helper method to get user by ID
    private JsonObject getUserById(String userId) {
        List<JsonObject> users = getAllUsers();
        
        for (JsonObject user : users) {
            if (user.get("userId").getAsString().equals(userId)) {
                return user;
            }
        }
        
        return null;
    }
    
    // Helper method to get all users from JSON file
    private List<JsonObject> getAllUsers() {
        List<JsonObject> usersList = new ArrayList<>();
        
        try {
            String realPath = USER_DATA_FILE;
            FileReader reader = new FileReader(realPath);
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray usersArray = jsonData.getAsJsonArray("users");
            
            for (int i = 0; i < usersArray.size(); i++) {
                usersList.add(usersArray.get(i).getAsJsonObject());
            }
            
            reader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return usersList;
    }
    
    // Helper method to save all users to JSON file
    private void saveUsers(List<JsonObject> users) {
        try {
            String realPath = USER_DATA_FILE;
            JsonObject rootObject = new JsonObject();
            JsonArray usersArray = new JsonArray();
            
            for (JsonObject user : users) {
                usersArray.add(user);
            }
            
            rootObject.add("users", usersArray);
            
            Gson gson = new GsonBuilder().setPrettyPrinting().create();
            String jsonOutput = gson.toJson(rootObject);
            
            FileWriter writer = new FileWriter(realPath);
            writer.write(jsonOutput);
            writer.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    // Helper method to get current date time string
    private String getCurrentDateTime() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
}