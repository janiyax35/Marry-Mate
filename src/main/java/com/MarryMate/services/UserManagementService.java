package com.MarryMate.services;

import com.MarryMate.models.User;
import com.MarryMate.models.RegularUser;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service class for User Management operations
 * Handles all business logic related to user operations
 * 
 * Current Date and Time: 2025-05-05 12:42:34
 * Current User: IT24102137
 */
public class UserManagementService {
    
    private static final String USERS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\users.json";
    private String realPath=USERS_FILE_PATH;
    
    /**
     * Constructor initializes the service with the application's real path
     * @param realPath The real path to the web application
     */
    public UserManagementService(String realPath) {
        this.realPath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\users.json";
    }
    
    /**
     * Get all users from JSON file
     * @return List of User objects
     * @throws IOException If file cannot be read
     */
    public List<User> getAllUsers() throws IOException {
        return loadUsersFromJson();
    }
    
    /**
     * Get a specific user by ID
     * @param userId User ID to find
     * @return Optional containing the User if found
     * @throws IOException If file cannot be read
     */
    public Optional<User> getUserById(String userId) throws IOException {
        List<User> users = loadUsersFromJson();
        return users.stream()
                .filter(user -> user.getUserId().equals(userId))
                .findFirst();
    }
    
    /**
     * Create a new user
     * @param userData Map containing user data
     * @return The newly created User object
     * @throws IOException If file operations fail
     */
    public User createUser(Map<String, String> userData) throws IOException {
        List<User> users = loadUsersFromJson();
        
        // Generate new user ID
        String userId = generateUserId(users);
        
        // Create User object
        RegularUser newUser = new RegularUser();
        newUser.setUserId(userId);
        updateUserFromMap(newUser, userData);
        
        // Set create-specific fields
        String currentDateTime = getCurrentDateTime();
        newUser.setRegistrationDate(currentDateTime);
        newUser.setLastLogin(currentDateTime);
        newUser.setUpdatedAt(currentDateTime);
        newUser.setUpdatedBy("IT24102137"); // Admin username
        newUser.setFailedLoginAttempts(0);
        
        // Set default profile picture if none provided
        if (newUser.getProfilePictureURL() == null || newUser.getProfilePictureURL().isEmpty()) {
            newUser.setProfilePictureURL("/assets/images/profiles/default-profile.jpg");
        }
        
        // Add to list and save
        users.add(newUser);
        saveUsersToJson(users);
        
        return newUser;
    }
    
    /**
     * Update an existing user
     * @param userId ID of user to update
     * @param userData Map containing updated user data
     * @return Updated User object
     * @throws IOException If file operations fail
     * @throws IllegalArgumentException If user ID is not found
     */
    public User updateUser(String userId, Map<String, String> userData) throws IOException {
        List<User> users = loadUsersFromJson();
        
        // Find the user to update
        Optional<User> optionalUser = users.stream()
                .filter(user -> user.getUserId().equals(userId))
                .findFirst();
                
        if (!optionalUser.isPresent()) {
            throw new IllegalArgumentException("User with ID " + userId + " not found");
        }
        
        User user = optionalUser.get();
        updateUserFromMap(user, userData);
        
        // Set update-specific fields
        user.setUpdatedAt(getCurrentDateTime());
        user.setUpdatedBy("IT24102137"); // Admin username
        
        saveUsersToJson(users);
        
        return user;
    }
    
    /**
     * Delete a user by ID
     * @param userId ID of user to delete
     * @return true if successful, false if user not found
     * @throws IOException If file operations fail
     */
    public boolean deleteUser(String userId) throws IOException {
        List<User> users = loadUsersFromJson();
        int initialSize = users.size();
        
        users = users.stream()
                .filter(user -> !user.getUserId().equals(userId))
                .collect(Collectors.toList());
                
        boolean userRemoved = users.size() < initialSize;
        
        if (userRemoved) {
            saveUsersToJson(users);
        }
        
        return userRemoved;
    }
    
    /**
     * Change a user's account status
     * @param userId ID of user to update
     * @param status New account status
     * @return Updated User object
     * @throws IOException If file operations fail
     * @throws IllegalArgumentException If user ID is not found
     */
    public User changeUserStatus(String userId, String status) throws IOException {
        List<User> users = loadUsersFromJson();
        
        Optional<User> optionalUser = users.stream()
                .filter(user -> user.getUserId().equals(userId))
                .findFirst();
                
        if (!optionalUser.isPresent()) {
            throw new IllegalArgumentException("User with ID " + userId + " not found");
        }
        
        User user = optionalUser.get();
        user.setAccountStatus(status);
        user.setUpdatedAt(getCurrentDateTime());
        user.setUpdatedBy("IT24102137");
        
        saveUsersToJson(users);
        
        return user;
    }
    
    /**
     * Search for users based on keyword
     * @param keyword Text to search for
     * @return List of matching User objects
     * @throws IOException If file operations fail
     */
    public List<User> searchUsers(String keyword) throws IOException {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllUsers();
        }
        
        String searchTerm = keyword.toLowerCase();
        List<User> users = loadUsersFromJson();
        
        return users.stream()
                .filter(user -> 
                    user.getUsername().toLowerCase().contains(searchTerm) ||
                    user.getEmail().toLowerCase().contains(searchTerm) ||
                    user.getFullName().toLowerCase().contains(searchTerm) ||
                    user.getUserId().toLowerCase().contains(searchTerm) ||
                    (user.getPhoneNumber() != null && user.getPhoneNumber().toLowerCase().contains(searchTerm))
                )
                .collect(Collectors.toList());
    }
    
    /**
     * Filter users by account status
     * @param status Account status to filter by
     * @return List of matching User objects
     * @throws IOException If file operations fail
     */
    public List<User> filterUsersByStatus(String status) throws IOException {
        if (status == null || status.trim().isEmpty()) {
            return getAllUsers();
        }
        
        List<User> users = loadUsersFromJson();
        
        return users.stream()
                .filter(user -> status.equalsIgnoreCase(user.getAccountStatus()))
                .collect(Collectors.toList());
    }
    
    /**
     * Filter users by registration date range
     * @param startDate Start date in YYYY-MM-DD format
     * @param endDate End date in YYYY-MM-DD format
     * @return List of matching User objects
     * @throws IOException If file operations fail
     */
    public List<User> filterUsersByRegistrationDate(String startDate, String endDate) throws IOException {
        if (startDate == null || endDate == null) {
            return getAllUsers();
        }
        
        List<User> users = loadUsersFromJson();
        
        return users.stream()
                .filter(user -> isDateInRange(user.getRegistrationDate(), startDate, endDate))
                .collect(Collectors.toList());
    }
    
    /**
     * Combine multiple filter criteria
     * @param status Account status (optional)
     * @param dateRange Date range string "YYYY-MM-DD to YYYY-MM-DD" (optional)
     * @param searchTerm Search keyword (optional)
     * @return List of matching User objects
     * @throws IOException If file operations fail
     */
    public List<User> filterUsers(String status, String dateRange, String searchTerm) throws IOException {
        List<User> filteredUsers = getAllUsers();
        
        // Apply status filter
        if (status != null && !status.trim().isEmpty()) {
            filteredUsers = filteredUsers.stream()
                    .filter(user -> status.equalsIgnoreCase(user.getAccountStatus()))
                    .collect(Collectors.toList());
        }
        
        // Apply date range filter
        if (dateRange != null && !dateRange.trim().isEmpty() && dateRange.contains("to")) {
            String[] dates = dateRange.split("to");
            if (dates.length == 2) {
                String startDate = dates[0].trim();
                String endDate = dates[1].trim();
                
                filteredUsers = filteredUsers.stream()
                        .filter(user -> isDateInRange(user.getRegistrationDate(), startDate, endDate))
                        .collect(Collectors.toList());
            }
        }
        
        // Apply search term
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            String term = searchTerm.toLowerCase();
            filteredUsers = filteredUsers.stream()
                    .filter(user -> 
                        user.getUsername().toLowerCase().contains(term) ||
                        user.getEmail().toLowerCase().contains(term) ||
                        user.getFullName().toLowerCase().contains(term) ||
                        user.getUserId().toLowerCase().contains(term) ||
                        (user.getPhoneNumber() != null && user.getPhoneNumber().toLowerCase().contains(term))
                    )
                    .collect(Collectors.toList());
        }
        
        return filteredUsers;
    }
    
    /**
     * Export users data to Excel format
     * @param users List of users to export
     * @param outputStream Output stream to write to
     * @throws IOException If write fails
     */
    public void exportUsersToExcel(List<User> users, OutputStream outputStream) throws IOException {
        // This is a placeholder - in a real application you'd use a library
        // like Apache POI to generate Excel files
        StringBuilder csv = new StringBuilder();
        
        // Header
        csv.append("User ID,Username,Full Name,Email,Phone Number,Role,Status,Registration Date,Last Login\n");
        
        // Data rows
        for (User user : users) {
            csv.append(user.getUserId()).append(",");
            csv.append(user.getUsername()).append(",");
            csv.append(user.getFullName()).append(",");
            csv.append(user.getEmail()).append(",");
            csv.append(user.getPhoneNumber() != null ? user.getPhoneNumber() : "").append(",");
            csv.append(user.getRole()).append(",");
            csv.append(user.getAccountStatus()).append(",");
            csv.append(user.getRegistrationDate()).append(",");
            csv.append(user.getLastLogin()).append("\n");
        }
        
        outputStream.write(csv.toString().getBytes());
    }
    
    /**
     * Export users data to CSV format
     * @param users List of users to export
     * @param outputStream Output stream to write to
     * @throws IOException If write fails
     */
    public void exportUsersToCSV(List<User> users, OutputStream outputStream) throws IOException {
        StringBuilder csv = new StringBuilder();
        
        // Header
        csv.append("User ID,Username,Full Name,Email,Phone Number,Role,Status,Registration Date,Last Login\n");
        
        // Data rows
        for (User user : users) {
            csv.append(user.getUserId()).append(",");
            csv.append(user.getUsername()).append(",");
            csv.append(user.getFullName()).append(",");
            csv.append(user.getEmail()).append(",");
            csv.append(user.getPhoneNumber() != null ? user.getPhoneNumber() : "").append(",");
            csv.append(user.getRole()).append(",");
            csv.append(user.getAccountStatus()).append(",");
            csv.append(user.getRegistrationDate()).append(",");
            csv.append(user.getLastLogin()).append("\n");
        }
        
        outputStream.write(csv.toString().getBytes());
    }
    
    /**
     * Export users data to PDF format
     * @param users List of users to export
     * @param outputStream Output stream to write to
     * @throws IOException If write fails
     */
    public void exportUsersToPDF(List<User> users, OutputStream outputStream) throws IOException {
        // This is a placeholder - in a real application you'd use a library
        // like iText or Apache PDFBox to generate PDF files
        StringBuilder text = new StringBuilder();
        text.append("User Management Report\n");
        text.append("Generated on: ").append(getCurrentDateTime()).append("\n\n");
        
        for (User user : users) {
            text.append("User ID: ").append(user.getUserId()).append("\n");
            text.append("Name: ").append(user.getFullName()).append("\n");
            text.append("Username: ").append(user.getUsername()).append("\n");
            text.append("Email: ").append(user.getEmail()).append("\n");
            text.append("Status: ").append(user.getAccountStatus()).append("\n");
            text.append("Registration Date: ").append(user.getRegistrationDate()).append("\n\n");
        }
        
        outputStream.write(text.toString().getBytes());
    }
    
    /**
     * Load users from JSON file
     * @return List of User objects
     * @throws IOException If file cannot be read
     */
    private List<User> loadUsersFromJson() throws IOException {
        String filePath = USERS_FILE_PATH;
        File file = new File(filePath);
        
        if (!file.exists()) {
            throw new IOException("Users file not found at " + filePath);
        }else {
			System.out.println("Users file found at " + filePath);
		}
        
        try (FileReader reader = new FileReader(file)) {
            Gson gson = new Gson();
            JsonObject jsonObject = gson.fromJson(reader, JsonObject.class);
            JsonArray usersArray = jsonObject.getAsJsonArray("users");
            
            List<User> usersList = new ArrayList<>();
            
            for (int i = 0; i < usersArray.size(); i++) {
                JsonObject userJson = usersArray.get(i).getAsJsonObject();
                
                // Determine user type based on role
                String role = userJson.get("role").getAsString();
                User user;
                
                if ("user".equalsIgnoreCase(role)) {
                    user = gson.fromJson(userJson, RegularUser.class);
                } else {
                    // For now, use the base User class for other roles
                    user = gson.fromJson(userJson, User.class);
                }
                
                usersList.add(user);
            }
            
            return usersList;
        }
    }
    
    /**
     * Save users list to JSON file
     * @param users List of users to save
     * @throws IOException If file cannot be written
     */
    private void saveUsersToJson(List<User> users) throws IOException {
        String filePath = USERS_FILE_PATH;
        File file = new File(filePath);
        
        // Create parent directories if they don't exist
        File parentDir = file.getParentFile();
        if (!parentDir.exists()) {
            parentDir.mkdirs();
        }
        
        // Create JSON structure
        JsonObject rootObject = new JsonObject();
        JsonArray usersArray = new JsonArray();
        
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        
        for (User user : users) {
            JsonObject userObject = gson.toJsonTree(user).getAsJsonObject();
            usersArray.add(userObject);
        }
        
        rootObject.add("users", usersArray);
        
        // Write to file
        try (FileWriter writer = new FileWriter(file)) {
            gson.toJson(rootObject, writer);
        }
    }
    
    /**
     * Generate a new unique user ID
     * @param existingUsers List of existing users
     * @return New user ID
     */
    private String generateUserId(List<User> existingUsers) {
        String prefix = "U";
        int maxId = 1000; // Starting ID if no users exist
        
        // Find the highest existing ID
        for (User user : existingUsers) {
            String userId = user.getUserId();
            if (userId != null && userId.startsWith(prefix)) {
                try {
                    int id = Integer.parseInt(userId.substring(prefix.length()));
                    maxId = Math.max(maxId, id);
                } catch (NumberFormatException e) {
                    // Skip if ID format is invalid
                }
            }
        }
        
        // Generate new ID (increment highest existing)
        return prefix + (maxId + 1);
    }
    
    /**
     * Update User object fields from a data map
     * @param user User to update
     * @param userData Map containing user data
     */
    private void updateUserFromMap(User user, Map<String, String> userData) {
        if (userData.containsKey("username")) user.setUsername(userData.get("username"));
        if (userData.containsKey("password")) user.setPassword(userData.get("password"));
        if (userData.containsKey("email")) user.setEmail(userData.get("email"));
        if (userData.containsKey("fullName")) user.setFullName(userData.get("fullName"));
        if (userData.containsKey("phoneNumber")) user.setPhoneNumber(userData.get("phoneNumber"));
        if (userData.containsKey("address")) user.setAddress(userData.get("address"));
        if (userData.containsKey("profilePictureURL")) user.setProfilePictureURL(userData.get("profilePictureURL"));
        if (userData.containsKey("role")) user.setRole(userData.get("role"));
        if (userData.containsKey("accountStatus")) user.setAccountStatus(userData.get("accountStatus"));
    }
    
    /**
     * Check if a date is within a specified range
     * @param dateStr Date string to check
     * @param startDateStr Start date string
     * @param endDateStr End date string
     * @return true if date is in range
     */
    private boolean isDateInRange(String dateStr, String startDateStr, String endDateStr) {
        if (dateStr == null) return false;
        
        try {
            // Assume format YYYY-MM-DD HH:mm:ss
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            Date date = formatter.parse(dateStr);
            Date startDate = formatter.parse(startDateStr + " 00:00:00");
            Date endDate = formatter.parse(endDateStr + " 23:59:59");
            
            return !date.before(startDate) && !date.after(endDate);
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Get the current date and time as a formatted string
     * @return Current date/time string
     */
    private String getCurrentDateTime() {
        return DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss").format(LocalDateTime.now());
    }
}