package com.MarryMate.servlets.Admin;

import com.MarryMate.models.Admin;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
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
import java.util.Arrays;
import java.util.List;

/**
 * Servlet to handle admin profile operations
 * - Load admin profile data
 * - Update admin profile data
 * - Update profile image
 * 
 * Current Date and Time: 2025-05-18 14:23:18
 * Current User: IT24102083
 */
@WebServlet("/AdminProfileServlet")
public class AdminProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String ADMIN_DATA_FILE = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\admins.json";
    
    public AdminProfileServlet() {
        super();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");
        
        // Redirect if not logged in as admin
        if (userId == null || !(role.equals("admin") || role.equals("super_admin"))) {
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
        String role = (String) session.getAttribute("role");
        
        // Redirect if not logged in as admin
        if (userId == null || !(role.equals("admin") || role.equals("super_admin"))) {
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
        JsonObject admin = getAdminById(userId);
        
        if (admin != null) {
            request.setAttribute("adminProfile", admin);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/admin/adminprofile.jsp");
            dispatcher.forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalidAdmin");
        }
    }
    
    private void prepareEditProfile(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        JsonObject admin = getAdminById(userId);
        
        if (admin != null) {
            request.setAttribute("adminProfile", admin);
            request.setAttribute("editMode", true);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/admin/adminprofile.jsp");
            dispatcher.forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalidAdmin");
        }
    }
    
    private void updateProfile(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        // Get the admin data from the form
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");
        String phoneNumber = request.getParameter("phoneNumber");
        String department = request.getParameter("department");
        String position = request.getParameter("position");
        String profilePictureURL = request.getParameter("profilePictureURL");
        String[] permissions = request.getParameterValues("permissions");
        
        // Validate required fields
        if (username == null || username.trim().isEmpty() || 
            email == null || email.trim().isEmpty() || 
            fullName == null || fullName.trim().isEmpty()) {
            
            request.setAttribute("error", "Required fields cannot be empty");
            prepareEditProfile(request, response, userId);
            return;
        }
        
        // Load all admins
        List<JsonObject> admins = getAllAdmins();
        boolean adminUpdated = false;
        
        // Find and update the admin
        for (int i = 0; i < admins.size(); i++) {
            JsonObject admin = admins.get(i);
            
            if (admin.get("userId").getAsString().equals(userId)) {
                admin.addProperty("username", username);
                admin.addProperty("email", email);
                admin.addProperty("fullName", fullName);
                
                // Update optional fields if provided
                if (phoneNumber != null && !phoneNumber.trim().isEmpty()) {
                    admin.addProperty("phoneNumber", phoneNumber);
                }
                
                if (department != null && !department.trim().isEmpty()) {
                    admin.addProperty("department", department);
                }
                
                if (position != null && !position.trim().isEmpty()) {
                    admin.addProperty("position", position);
                }
                
                // Update profile picture URL if provided
                if (profilePictureURL != null && !profilePictureURL.trim().isEmpty()) {
                    admin.addProperty("profilePictureURL", profilePictureURL);
                }
                
                // Update permissions if user is a super admin and permissions were provided
                // Only super admins can modify permissions
                HttpSession session = request.getSession();
                boolean isSuperAdmin = "super_admin".equals(session.getAttribute("role"));
                
                if (isSuperAdmin && permissions != null && permissions.length > 0) {
                    JsonArray permissionsArray = new JsonArray();
                    for (String permission : permissions) {
                        permissionsArray.add(permission);
                    }
                    admin.add("permissions", permissionsArray);
                }
                
                // Update timestamp and updater info
                admin.addProperty("updatedAt", getCurrentDateTime());
                admin.addProperty("updatedBy", "IT24102083");
                
                adminUpdated = true;
                break;
            }
        }
        
        if (adminUpdated) {
            // Save updated admins back to the JSON file
            saveAdmins(admins);
            
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
        
        // Load all admins
        List<JsonObject> admins = getAllAdmins();
        boolean passwordChanged = false;
        
        // Find the admin and check current password
        for (int i = 0; i < admins.size(); i++) {
            JsonObject admin = admins.get(i).getAsJsonObject();
            
            if (admin.get("userId").getAsString().equals(userId)) {
                String storedPassword = admin.get("password").getAsString();
                
                if (storedPassword.equals(currentPassword)) {
                    // Update password
                    admin.addProperty("password", newPassword);
                    admin.addProperty("updatedAt", getCurrentDateTime());
                    admin.addProperty("updatedBy", "IT24102083");
                    
                    passwordChanged = true;
                } else {
                    request.setAttribute("passwordError", "Current password is incorrect");
                }
                
                break;
            }
        }
        
        if (passwordChanged) {
            // Save updated admins back to the JSON file
            saveAdmins(admins);
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
        
        // Load all admins
        List<JsonObject> admins = getAllAdmins();
        boolean imageUpdated = false;
        
        // Find and update the admin's profile image URL
        for (int i = 0; i < admins.size(); i++) {
            JsonObject admin = admins.get(i).getAsJsonObject();
            
            if (admin.get("userId").getAsString().equals(userId)) {
                admin.addProperty("profilePictureURL", profileImageUrl);
                admin.addProperty("updatedAt", getCurrentDateTime());
                admin.addProperty("updatedBy", "IT24102083");
                
                imageUpdated = true;
                break;
            }
        }
        
        if (imageUpdated) {
            // Save updated admins back to the JSON file
            saveAdmins(admins);
            
            // Update session attribute if needed
            HttpSession session = request.getSession();
            session.setAttribute("profilePictureURL", profileImageUrl);
            
            request.setAttribute("imageMessage", "Profile picture updated successfully");
        } else {
            request.setAttribute("imageError", "Failed to update profile picture");
        }
        
        viewProfile(request, response, userId);
    }
    
    // Helper method to get admin by ID
    private JsonObject getAdminById(String userId) {
        List<JsonObject> admins = getAllAdmins();
        
        for (JsonObject admin : admins) {
            if (admin.get("userId").getAsString().equals(userId)) {
                return admin;
            }
        }
        
        return null;
    }
    
    // Helper method to get all admins from JSON file
    private List<JsonObject> getAllAdmins() {
        List<JsonObject> adminsList = new ArrayList<>();
        
        try {
            String realPath = ADMIN_DATA_FILE ;
            FileReader reader = new FileReader(realPath);
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray adminsArray = jsonData.getAsJsonArray("admins");
            
            for (int i = 0; i < adminsArray.size(); i++) {
                adminsList.add(adminsArray.get(i).getAsJsonObject());
            }
            
            reader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return adminsList;
    }
    
    // Helper method to save all admins to JSON file
    private void saveAdmins(List<JsonObject> admins) {
        try {
            String realPath = ADMIN_DATA_FILE ;
            JsonObject rootObject = new JsonObject();
            JsonArray adminsArray = new JsonArray();
            
            for (JsonObject admin : admins) {
                adminsArray.add(admin);
            }
            
            rootObject.add("admins", adminsArray);
            
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
        return "2025-05-18 14:23:18";
    }
}