package com.MarryMate.servlets.Vendor;

import com.MarryMate.models.Vendor;
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
 * Servlet to handle vendor profile operations
 * - Load vendor profile data
 * - Update vendor profile data
 * - Update profile and cover images
 * 
 * Current Date and Time: 2025-05-18 13:54:36
 * Current User: IT24102083
 */
@WebServlet("/VendorProfileServlet")
public class VendorProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VENDOR_DATA_FILE = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
    
    public VendorProfileServlet() {
        super();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String role = (String) session.getAttribute("role");
        
        // Redirect if not logged in as vendor
        if (userId == null || !"vendor".equals(role)) {
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
        
        // Redirect if not logged in as vendor
        if (userId == null || !"vendor".equals(role)) {
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
            case "updateCoverImage":
                updateCoverImage(request, response, userId);
                break;
            default:
                viewProfile(request, response, userId);
                break;
        }
    }
    
    private void viewProfile(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        JsonObject vendor = getVendorById(userId);
        
        if (vendor != null) {
            request.setAttribute("vendorProfile", vendor);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vendor/vendorprofile.jsp");
            dispatcher.forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalidVendor");
        }
    }
    
    private void prepareEditProfile(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        JsonObject vendor = getVendorById(userId);
        
        if (vendor != null) {
            request.setAttribute("vendorProfile", vendor);
            request.setAttribute("editMode", true);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/vendor/vendorprofile.jsp");
            dispatcher.forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalidVendor");
        }
    }
    
    private void updateProfile(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        // Get the vendor data from the form
        String businessName = request.getParameter("businessName");
        String contactName = request.getParameter("contactName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String description = request.getParameter("description");
        String servicesOffered = request.getParameter("servicesOffered");
        String priceRange = request.getParameter("priceRange");
        String websiteUrl = request.getParameter("websiteUrl");
        String profilePictureUrl = request.getParameter("profilePictureUrl");
        String coverPhotoUrl = request.getParameter("coverPhotoUrl");
        String categories = request.getParameter("categories"); // Comma-separated list
        
        // Validate required fields
        if (businessName == null || businessName.trim().isEmpty() || 
            email == null || email.trim().isEmpty() || 
            contactName == null || contactName.trim().isEmpty()) {
            
            request.setAttribute("error", "Required fields cannot be empty");
            prepareEditProfile(request, response, userId);
            return;
        }
        
        // Load all vendors
        List<JsonObject> vendors = getAllVendors();
        boolean vendorUpdated = false;
        
        // Find and update the vendor
        for (int i = 0; i < vendors.size(); i++) {
            JsonObject vendor = vendors.get(i);
            
            if (vendor.get("userId").getAsString().equals(userId)) {
                vendor.addProperty("businessName", businessName);
                vendor.addProperty("contactName", contactName);
                vendor.addProperty("email", email);
                vendor.addProperty("phone", phone);
                vendor.addProperty("address", address);
                vendor.addProperty("description", description);
                vendor.addProperty("servicesOffered", servicesOffered);
                vendor.addProperty("priceRange", priceRange);
                vendor.addProperty("websiteUrl", websiteUrl);
                
                // Update images if provided
                if (profilePictureUrl != null && !profilePictureUrl.trim().isEmpty()) {
                    vendor.addProperty("profilePictureUrl", profilePictureUrl);
                }
                
                if (coverPhotoUrl != null && !coverPhotoUrl.trim().isEmpty()) {
                    vendor.addProperty("coverPhotoUrl", coverPhotoUrl);
                }
                
                // Update categories if provided
                if (categories != null && !categories.trim().isEmpty()) {
                    String[] categoryArray = categories.split(",");
                    JsonArray categoryJsonArray = new JsonArray();
                    for (String category : categoryArray) {
                        categoryJsonArray.add(category.trim());
                    }
                    vendor.add("categories", categoryJsonArray);
                }
                
                // Update timestamp and updater info
                vendor.addProperty("updatedAt", getCurrentDateTime());
                
                vendorUpdated = true;
                break;
            }
        }
        
        if (vendorUpdated) {
            // Save updated vendors back to the JSON file
            saveVendors(vendors);
            
            // Update session attributes if needed
            HttpSession session = request.getSession();
            session.setAttribute("businessName", businessName);
            
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
        
        // Load all vendors
        List<JsonObject> vendors = getAllVendors();
        boolean passwordChanged = false;
        
        // Find the vendor and check current password
        for (int i = 0; i < vendors.size(); i++) {
            JsonObject vendor = vendors.get(i).getAsJsonObject();
            
            if (vendor.get("userId").getAsString().equals(userId)) {
                String storedPassword = vendor.get("password").getAsString();
                
                if (storedPassword.equals(currentPassword)) {
                    // Update password
                    vendor.addProperty("password", newPassword);
                    vendor.addProperty("updatedAt", getCurrentDateTime());
                    
                    passwordChanged = true;
                } else {
                    request.setAttribute("passwordError", "Current password is incorrect");
                }
                
                break;
            }
        }
        
        if (passwordChanged) {
            // Save updated vendors back to the JSON file
            saveVendors(vendors);
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
        
        // Load all vendors
        List<JsonObject> vendors = getAllVendors();
        boolean imageUpdated = false;
        
        // Find and update the vendor's profile image URL
        for (int i = 0; i < vendors.size(); i++) {
            JsonObject vendor = vendors.get(i).getAsJsonObject();
            
            if (vendor.get("userId").getAsString().equals(userId)) {
                vendor.addProperty("profilePictureUrl", profileImageUrl);
                vendor.addProperty("updatedAt", getCurrentDateTime());
                
                imageUpdated = true;
                break;
            }
        }
        
        if (imageUpdated) {
            // Save updated vendors back to the JSON file
            saveVendors(vendors);
            
            // Update session attribute if needed
            HttpSession session = request.getSession();
            session.setAttribute("profilePictureUrl", profileImageUrl);
            
            request.setAttribute("imageMessage", "Profile picture updated successfully");
        } else {
            request.setAttribute("imageError", "Failed to update profile picture");
        }
        
        viewProfile(request, response, userId);
    }
    
    private void updateCoverImage(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws ServletException, IOException {
        String coverImageUrl = request.getParameter("coverImageUrl");
        
        // Validate URL
        if (coverImageUrl == null || coverImageUrl.trim().isEmpty()) {
            request.setAttribute("coverImageError", "Cover image URL cannot be empty");
            viewProfile(request, response, userId);
            return;
        }
        
        // Load all vendors
        List<JsonObject> vendors = getAllVendors();
        boolean imageUpdated = false;
        
        // Find and update the vendor's cover image URL
        for (int i = 0; i < vendors.size(); i++) {
            JsonObject vendor = vendors.get(i).getAsJsonObject();
            
            if (vendor.get("userId").getAsString().equals(userId)) {
                vendor.addProperty("coverPhotoUrl", coverImageUrl);
                vendor.addProperty("updatedAt", getCurrentDateTime());
                
                imageUpdated = true;
                break;
            }
        }
        
        if (imageUpdated) {
            // Save updated vendors back to the JSON file
            saveVendors(vendors);
            request.setAttribute("coverImageMessage", "Cover image updated successfully");
        } else {
            request.setAttribute("coverImageError", "Failed to update cover image");
        }
        
        viewProfile(request, response, userId);
    }
    
    // Helper method to get vendor by ID
    private JsonObject getVendorById(String userId) {
        List<JsonObject> vendors = getAllVendors();
        
        for (JsonObject vendor : vendors) {
            if (vendor.get("userId").getAsString().equals(userId)) {
                return vendor;
            }
        }
        
        return null;
    }
    
    // Helper method to get all vendors from JSON file
    private List<JsonObject> getAllVendors() {
        List<JsonObject> vendorsList = new ArrayList<>();
        
        try {
            String realPath = VENDOR_DATA_FILE;
            FileReader reader = new FileReader(realPath);
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray vendorsArray = jsonData.getAsJsonArray("vendors");
            
            for (int i = 0; i < vendorsArray.size(); i++) {
                vendorsList.add(vendorsArray.get(i).getAsJsonObject());
            }
            
            reader.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return vendorsList;
    }
    
    // Helper method to save all vendors to JSON file
    private void saveVendors(List<JsonObject> vendors) {
        try {
            String realPath = VENDOR_DATA_FILE;
            JsonObject rootObject = new JsonObject();
            JsonArray vendorsArray = new JsonArray();
            
            for (JsonObject vendor : vendors) {
                vendorsArray.add(vendor);
            }
            
            rootObject.add("vendors", vendorsArray);
            
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