package com.MarryMate.services;

import com.MarryMate.models.User;
import com.MarryMate.models.RegularUser;
import com.MarryMate.models.Vendor;
import com.MarryMate.models.Admin;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.reflect.TypeToken;

import javax.servlet.ServletContext;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Authentication and User Management Service for Marry Mate Wedding Planning System
 * 
 * Handles user authentication, registration, and JSON data operations
 * 
 * Current Date and Time: 2025-05-11 14:06:30
 * Current User: IT24102137
 */
public class AuthService {
    
    // File paths for JSON data storage
    private static final String USERS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\users.json";
    private static final String VENDORS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
    private static final String ADMINS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\admins.json";
    
    // LinkedList for user data storage
    private LinkedList<RegularUser> regularUsers;
    private LinkedList<Vendor> vendors;
    private LinkedList<Admin> admins;
    
    // GSON for JSON serialization/deserialization
    private Gson gson;
    
    // ServletContext for file operations
    private ServletContext servletContext;
    
    // Singleton instance
    private static AuthService instance;
    
    /**
     * Get the singleton instance of AuthService
     * @param servletContext ServletContext for file operations
     * @return AuthService instance
     */
    public static synchronized AuthService getInstance(ServletContext servletContext) {
        if (instance == null) {
            instance = new AuthService(servletContext);
        }
        return instance;
    }
    
    /**
     * Private constructor to enforce singleton pattern
     * @param servletContext ServletContext for file operations
     */
    private AuthService(ServletContext servletContext) {
        this.servletContext = servletContext;
        this.gson = new GsonBuilder().setPrettyPrinting().create();
        
        // Initialize data structures
        regularUsers = new LinkedList<>();
        vendors = new LinkedList<>();
        admins = new LinkedList<>();
        
        // Load data from JSON files
        loadData();
    }
    
    /**
     * Reload all user data from JSON files
     * Use this method to refresh data after external changes to JSON files
     */
    public synchronized void reloadData() {
        // Clear existing data
        regularUsers.clear();
        vendors.clear();
        admins.clear();
        
        // Reload data from JSON files
        loadData();
        
        System.out.println("AuthService: Data reloaded from JSON files at " + getCurrentDateTime());
    }
    
    /**
     * Load all user data from JSON files
     */
    public void loadData() {
        // Load regular users
        regularUsers = loadRegularUsers();
        
        // Load vendors
        vendors = loadVendors();
        
        // Load admins
        admins = loadAdmins();
    }
    
    /**
     * Load regular users from JSON file
     * @return LinkedList of RegularUser objects
     */
    private LinkedList<RegularUser> loadRegularUsers() {
        LinkedList<RegularUser> users = new LinkedList<>();
        
        try {
            // Get the file path
            String fullPath = USERS_FILE_PATH;
            
            // Check if file exists, if not create an empty file
            File file = new File(fullPath);
            if (!file.exists()) {
                System.out.println("File not found, creating empty users file.");
                createEmptyUsersFile(fullPath);
            }
            
            // Read the JSON file
            String content = new String(Files.readAllBytes(Paths.get(fullPath)));
            System.out.println("File content: " + content);
            // Parse JSON file
            JsonObject jsonObject = JsonParser.parseString(content).getAsJsonObject();
            JsonArray usersArray = jsonObject.getAsJsonArray("users");
            
            // Convert each JSON object to RegularUser object
            for (JsonElement element : usersArray) {
                JsonObject userJson = element.getAsJsonObject();
                
                // Only add users with role "user"
                if ("user".equals(userJson.get("role").getAsString())) {
                    RegularUser user = gson.fromJson(userJson, RegularUser.class);
                    users.add(user);
                }
            }
        } catch (Exception e) {
            System.err.println("Error loading users from JSON: " + e.getMessage());
            e.printStackTrace();
            // Create empty list if file not found or error
            users = new LinkedList<>();
        }
        
        return users;
    }
    
    /**
     * Create empty users JSON file with structure
     * @param filePath Path to create the file
     */
    private void createEmptyUsersFile(String filePath) throws IOException {
        File file = new File(filePath);
        file.getParentFile().mkdirs(); // Create parent directories if needed
        
        JsonObject root = new JsonObject();
        root.add("users", new JsonArray());
        
        try (FileWriter writer = new FileWriter(file)) {
            writer.write(gson.toJson(root));
        }
    }
    
    /**
     * Load vendors from JSON file
     * @return LinkedList of Vendor objects
     */
    private LinkedList<Vendor> loadVendors() {
        LinkedList<Vendor> vendorList = new LinkedList<>();
        
        try {
            // Get the file path
            String fullPath = VENDORS_FILE_PATH;
            System.out.println("Loading vendors from: " + fullPath);
            
            // Check if file exists, if not create it
            File file = new File(fullPath);
            if (!file.exists()) {
            	System.out.println("File not found, creating empty vendors file.");
                file.getParentFile().mkdirs();
                JsonObject root = new JsonObject();
                root.add("vendors", new JsonArray());
                
                try (FileWriter writer = new FileWriter(file)) {
                    writer.write(gson.toJson(root));
                }
            }else {
				System.out.println("File found, loading vendors.");
			}
            
            // Read the JSON file
            String content = new String(Files.readAllBytes(Paths.get(fullPath)));
            
            // Parse JSON file
            JsonObject jsonObject = JsonParser.parseString(content).getAsJsonObject();
            JsonArray vendorsArray = jsonObject.getAsJsonArray("vendors");
            
            // Convert each JSON object to Vendor object
            for (JsonElement element : vendorsArray) {
                JsonObject vendorJson = element.getAsJsonObject();
                
                // Create a new Vendor object
                Vendor vendor = new Vendor();
                
                // Set basic User properties
                vendor.setUserId(getAsStringOrEmpty(vendorJson, "userId"));
                vendor.setUsername(getAsStringOrEmpty(vendorJson, "username"));
                vendor.setPassword(getAsStringOrEmpty(vendorJson, "password"));
                vendor.setEmail(getAsStringOrEmpty(vendorJson, "email"));
                vendor.setFullName(getAsStringOrEmpty(vendorJson, "contactName")); // map contactName to fullName
                vendor.setPhoneNumber(getAsStringOrEmpty(vendorJson, "phone")); // map phone to phoneNumber
                vendor.setAddress(getAsStringOrEmpty(vendorJson, "address"));
                vendor.setProfilePictureURL(getAsStringOrEmpty(vendorJson, "profilePictureUrl"));
                vendor.setRole("vendor");
                vendor.setAccountStatus(getAsStringOrEmpty(vendorJson, "status")); // map status to accountStatus
                vendor.setRegistrationDate(getAsStringOrEmpty(vendorJson, "memberSince"));
                vendor.setLastLogin(getAsStringOrEmpty(vendorJson, "lastLogin"));
                
                // Set Vendor-specific properties
                vendor.setBusinessName(getAsStringOrEmpty(vendorJson, "businessName"));
                vendor.setContactName(getAsStringOrEmpty(vendorJson, "contactName"));
                vendor.setDescription(getAsStringOrEmpty(vendorJson, "description"));
                vendor.setServicesOffered(getAsStringOrEmpty(vendorJson, "servicesOffered"));
                vendor.setPriceRange(getAsStringOrEmpty(vendorJson, "priceRange"));
                vendor.setWebsiteUrl(getAsStringOrEmpty(vendorJson, "websiteUrl"));
                vendor.setCoverPhotoUrl(getAsStringOrEmpty(vendorJson, "coverPhotoUrl"));
                vendor.setMemberSince(getAsStringOrEmpty(vendorJson, "memberSince"));
                
                // Handle numeric values
                if (vendorJson.has("rating")) {
                    vendor.setRating(vendorJson.get("rating").getAsDouble());
                }
                if (vendorJson.has("reviewCount")) {
                    vendor.setReviewCount(vendorJson.get("reviewCount").getAsInt());
                }
                if (vendorJson.has("featured")) {
                    vendor.setFeatured(vendorJson.get("featured").getAsBoolean());
                }
                
                // Handle array values
                if (vendorJson.has("serviceIds") && vendorJson.get("serviceIds").isJsonArray()) {
                    List<String> serviceIds = new ArrayList<>();
                    JsonArray serviceIdsArray = vendorJson.getAsJsonArray("serviceIds");
                    for (JsonElement serviceElement : serviceIdsArray) {
                        serviceIds.add(serviceElement.getAsString());
                    }
                    vendor.setServiceIds(serviceIds);
                }
                
                if (vendorJson.has("categories") && vendorJson.get("categories").isJsonArray()) {
                    List<String> categories = new ArrayList<>();
                    JsonArray categoriesArray = vendorJson.getAsJsonArray("categories");
                    for (JsonElement categoryElement : categoriesArray) {
                        categories.add(categoryElement.getAsString());
                    }
                    vendor.setCategories(categories);
                }
                
                vendorList.add(vendor);
            }
        } catch (Exception e) {
            System.err.println("Error loading vendors from JSON: " + e.getMessage());
            e.printStackTrace();
            // Create empty list if file not found or error
            vendorList = new LinkedList<>();
        }
        
        return vendorList;
    }
    
    /**
     * Utility method to safely get string value from JsonObject
     * @param jsonObject The JsonObject to extract from
     * @param key The key to look for
     * @return The string value or empty string if not found
     */
    private String getAsStringOrEmpty(JsonObject jsonObject, String key) {
        if (jsonObject.has(key) && !jsonObject.get(key).isJsonNull()) {
            return jsonObject.get(key).getAsString();
        }
        return "";
    }
    
    /**
     * Load admins from JSON file
     * @return LinkedList of Admin objects
     */
    private LinkedList<Admin> loadAdmins() {
        LinkedList<Admin> adminList = new LinkedList<>();
        
        try {
            // Get the file path
            String fullPath = ADMINS_FILE_PATH;
            
            // Check if file exists, if not create it
            File file = new File(fullPath);
            if (!file.exists()) {
                JsonObject root = new JsonObject();
                root.add("admins", new JsonArray());
                
                try (FileWriter writer = new FileWriter(file)) {
                    writer.write(gson.toJson(root));
                }
            }
            
            // Read the JSON file
            String content = new String(Files.readAllBytes(Paths.get(fullPath)));
            
            // Parse JSON file
            JsonObject jsonObject = JsonParser.parseString(content).getAsJsonObject();
            JsonArray adminsArray = jsonObject.getAsJsonArray("admins");
            
            // Convert each JSON object to Admin object
            for (JsonElement element : adminsArray) {
                Admin admin = gson.fromJson(element, Admin.class);
                adminList.add(admin);
            }
        } catch (Exception e) {
            System.err.println("Error loading admins from JSON: " + e.getMessage());
            e.printStackTrace();
            // Create empty list if file not found or error
            adminList = new LinkedList<>();
        }
        
        return adminList;
    }
    
    /**
     * Save regular users to JSON file
     */
    private void saveRegularUsers() {
        try {
            // Get the file path
            String fullPath = USERS_FILE_PATH;
            
            File file = new File(fullPath);
            if (!file.exists()) {
                createEmptyUsersFile(fullPath);
            }
            
            // Read the current file to preserve structure
            String content = new String(Files.readAllBytes(Paths.get(fullPath)));
            JsonObject jsonObject;
            try {
                jsonObject = JsonParser.parseString(content).getAsJsonObject();
            } catch (Exception e) {
                // If parsing fails, create new structure
                jsonObject = new JsonObject();
            }
            
            // Create a new users array
            JsonArray usersArray = new JsonArray();
            
            // Add regular users
            for (RegularUser user : regularUsers) {
                JsonElement userJson = gson.toJsonTree(user);
                usersArray.add(userJson);
            }
            
            // Replace users array in the root object
            jsonObject.add("users", usersArray);
            
            // Write updated JSON back to file
            try (FileWriter writer = new FileWriter(fullPath)) {
                writer.write(gson.toJson(jsonObject));
            }
        } catch (Exception e) {
            System.err.println("Error saving users to JSON: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Save vendors to JSON file
     */
    private void saveVendors() {
        try {
            // Get the file path
            String fullPath = VENDORS_FILE_PATH;
            
            File file = new File(fullPath);
            if (!file.exists()) {
                file.getParentFile().mkdirs();
                JsonObject root = new JsonObject();
                root.add("vendors", new JsonArray());
                
                try (FileWriter writer = new FileWriter(file)) {
                    writer.write(gson.toJson(root));
                }
            }
            
            // Create a new vendors array
            JsonArray vendorsArray = new JsonArray();
            
            // Add vendors - custom serialization to match expected format
            for (Vendor vendor : vendors) {
                // Create vendor JSON object with correct property names
                JsonObject vendorJson = new JsonObject();
                
                // User properties
                vendorJson.addProperty("userId", vendor.getUserId());
                vendorJson.addProperty("username", vendor.getUsername());
                vendorJson.addProperty("password", vendor.getPassword());
                vendorJson.addProperty("email", vendor.getEmail());
                vendorJson.addProperty("role", "vendor");
                vendorJson.addProperty("phone", vendor.getPhoneNumber());
                vendorJson.addProperty("address", vendor.getAddress());
                vendorJson.addProperty("profilePictureUrl", vendor.getProfilePictureURL());
                vendorJson.addProperty("status", vendor.getAccountStatus());
                vendorJson.addProperty("lastLogin", vendor.getLastLogin());
                vendorJson.addProperty("createdAt", vendor.getRegistrationDate());
                vendorJson.addProperty("updatedAt", vendor.getUpdatedAt());
                
                // Vendor-specific properties
                vendorJson.addProperty("businessName", vendor.getBusinessName());
                vendorJson.addProperty("contactName", vendor.getContactName());
                vendorJson.addProperty("description", vendor.getDescription());
                vendorJson.addProperty("servicesOffered", vendor.getServicesOffered());
                vendorJson.addProperty("priceRange", vendor.getPriceRange());
                vendorJson.addProperty("websiteUrl", vendor.getWebsiteUrl());
                vendorJson.addProperty("coverPhotoUrl", vendor.getCoverPhotoUrl());
                vendorJson.addProperty("rating", vendor.getRating());
                vendorJson.addProperty("reviewCount", vendor.getReviewCount());
                vendorJson.addProperty("featured", vendor.isFeatured());
                vendorJson.addProperty("memberSince", vendor.getMemberSince());
                
                // Arrays
                if (vendor.getServiceIds() != null) {
                    JsonArray serviceIdsArray = new JsonArray();
                    for (String serviceId : vendor.getServiceIds()) {
                        serviceIdsArray.add(serviceId);
                    }
                    vendorJson.add("serviceIds", serviceIdsArray);
                }
                
                if (vendor.getCategories() != null) {
                    JsonArray categoriesArray = new JsonArray();
                    for (String category : vendor.getCategories()) {
                        categoriesArray.add(category);
                    }
                    vendorJson.add("categories", categoriesArray);
                }
                
                vendorsArray.add(vendorJson);
            }
            
            // Create root object
            JsonObject jsonObject = new JsonObject();
            jsonObject.add("vendors", vendorsArray);
            
            // Write updated JSON back to file
            try (FileWriter writer = new FileWriter(fullPath)) {
                writer.write(gson.toJson(jsonObject));
            }
        } catch (Exception e) {
            System.err.println("Error saving vendors to JSON: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Authenticate a user by username/email and password
     * @param usernameOrEmail Username or email to check
     * @param password Password to check
     * @return Optional containing the authenticated User object if successful, empty otherwise
     */
    public Optional<User> authenticateUser(String usernameOrEmail, String password) {
        // Check regular users
        for (RegularUser user : regularUsers) {
            if ((user.getUsername().equals(usernameOrEmail) || user.getEmail().equals(usernameOrEmail))) {
                // Check if password is correct
                if (user.authenticate(password)) {
                    // Check account status
                    if ("active".equals(user.getAccountStatus())) {
                        // Reset failed login attempts
                        user.resetFailedLoginAttempts();
                        // Update last login
                        user.setLastLogin(getCurrentDateTime());
                        // Save updates
                        saveRegularUsers();
                        return Optional.of(user);
                    }
                } else {
                    // Incorrect password - increment failed attempts
                    user.incrementFailedLoginAttempts();
                    
                    // If too many failed attempts, lock the account
                    if (user.getFailedLoginAttempts() >= 5) {
                        user.setAccountStatus("suspended");
                    }
                    
                    saveRegularUsers();
                }
                
                // Return empty for non-active accounts or wrong password
                return Optional.empty();
            }
        }
        
        // Check vendors
        for (Vendor vendor : vendors) {
            if ((vendor.getUsername().equals(usernameOrEmail) || vendor.getEmail().equals(usernameOrEmail))) {
                if (vendor.authenticate(password)) {
                    if ("active".equals(vendor.getAccountStatus())) {
                        vendor.resetFailedLoginAttempts();
                        vendor.setLastLogin(getCurrentDateTime());
                        saveVendors();
                        return Optional.of(vendor);
                    }
                } else {
                    vendor.incrementFailedLoginAttempts();
                    if (vendor.getFailedLoginAttempts() >= 5) {
                        vendor.setAccountStatus("suspended");
                    }
                    saveVendors();
                }
                
                return Optional.empty();
            }
        }
        
        // Check admins
        for (Admin admin : admins) {
            if ((admin.getUsername().equals(usernameOrEmail) || admin.getEmail().equals(usernameOrEmail))) {
                if (admin.authenticate(password)) {
                    if ("active".equals(admin.getAccountStatus())) {
                        admin.resetFailedLoginAttempts();
                        admin.setLastLogin(getCurrentDateTime());
                        return Optional.of(admin);
                    }
                }
                
                return Optional.empty();
            }
        }
        
        // No matching user found
        return Optional.empty();
    }
    
    /**
     * Get account status message based on status
     * @param accountStatus The account status string
     * @return Message to display to the user
     */
    public String getAccountStatusMessage(String accountStatus) {
        switch (accountStatus) {
            case "inactive":
                return "Your account is inactive. Please complete your registration or contact support.";
            case "suspended":
                return "Your account has been suspended. Please contact support for assistance.";
            case "pending":
                return "Your account is awaiting admin approval. Please check back later.";
            default:
                return "Invalid username or password. Please try again.";
        }
    }
    
    /**
     * Check account status without authentication
     * @param usernameOrEmail Username or email to check
     * @return Account status or null if user not found
     */
    public String checkAccountStatus(String usernameOrEmail) {
        // Check regular users
        for (RegularUser user : regularUsers) {
            if (user.getUsername().equals(usernameOrEmail) || user.getEmail().equals(usernameOrEmail)) {
                return user.getAccountStatus();
            }
        }
        
        // Check vendors
        for (Vendor vendor : vendors) {
            if (vendor.getUsername().equals(usernameOrEmail) || vendor.getEmail().equals(usernameOrEmail)) {
                return vendor.getAccountStatus();
            }
        }
        
        // Check admins
        for (Admin admin : admins) {
            if (admin.getUsername().equals(usernameOrEmail) || admin.getEmail().equals(usernameOrEmail)) {
                return admin.getAccountStatus();
            }
        }
        
        // No matching user found
        return null;
    }
    
    /**
     * Register a new regular user with all fields
     * @param username Username for new user
     * @param password Password for new user
     * @param email Email for new user
     * @param fullName Full name for new user
     * @param phoneNumber Phone number for new user
     * @param address Address for new user
     * @return Optional containing the new RegularUser if registration successful, empty otherwise
     */
    public Optional<RegularUser> registerUser(String username, String password, String email, 
                                             String fullName, String phoneNumber, String address) {
        // Check if username or email already exists
        if (isUsernameExists(username)) {
            return Optional.empty();
        }
        
        if (isEmailExists(email)) {
            return Optional.empty();
        }
        
        // Generate new user ID
        String userId = generateNextUserId();
        
        // Create new user with all fields
        RegularUser newUser = new RegularUser(userId, username, password, email, fullName, phoneNumber, address);
        newUser.setRegistrationDate(getCurrentDateTime());
        newUser.setLastLogin(getCurrentDateTime());
        newUser.setAccountStatus("active");
        
        // Add to list
        regularUsers.add(newUser);
        
        // Save to file
        saveRegularUsers();
        
        return Optional.of(newUser);
    }
    
    /**
     * Register a new regular user with basic fields
     * @param username Username for new user
     * @param password Password for new user
     * @param email Email for new user
     * @param fullName Full name for new user
     * @param phoneNumber Phone number for new user
     * @return Optional containing the new RegularUser if registration successful, empty otherwise
     */
    public Optional<RegularUser> registerUser(String username, String password, String email, 
                                             String fullName, String phoneNumber) {
        // Use the full method with empty address
        return registerUser(username, password, email, fullName, phoneNumber, "");
    }
    
    /**
     * Register a new vendor with basic fields
     * @param username Username for new vendor
     * @param password Password for new vendor
     * @param email Email for new vendor
     * @param businessName Business name for new vendor
     * @param contactName Contact name for new vendor
     * @param phoneNumber Phone number for new vendor
     * @param address Address for the vendor
     * @return Optional containing the new Vendor if registration successful, empty otherwise
     */
    public Optional<Vendor> registerVendor(String username, String password, String email, 
                                          String businessName, String contactName, String phoneNumber, 
                                          String address) {
        // Check if username or email already exists
        if (isUsernameExists(username)) {
            return Optional.empty();
        }
        
        if (isEmailExists(email)) {
            return Optional.empty();
        }
        
        // Generate new vendor ID
        String vendorId = generateNextVendorId();
        
        // Create new vendor
        Vendor newVendor = new Vendor();
        newVendor.setUserId(vendorId);
        newVendor.setUsername(username);
        newVendor.setPassword(password);
        newVendor.setEmail(email);
        newVendor.setRole("vendor");
        newVendor.setBusinessName(businessName);
        newVendor.setContactName(contactName);
        newVendor.setFullName(contactName); // Set fullName same as contactName
        newVendor.setPhoneNumber(phoneNumber);
        newVendor.setAddress(address);
        
        // Initialize collections
        newVendor.setServiceIds(new ArrayList<>());
        newVendor.setCategories(new ArrayList<>());
        
        // Set default values
        newVendor.setRating(0.0);
        newVendor.setReviewCount(0);
        newVendor.setFeatured(false);
        
        // Set timestamps
        String currentTime = getCurrentDateTime();
        newVendor.setRegistrationDate(currentTime);
        newVendor.setLastLogin(currentTime);
        newVendor.setAccountStatus("pending"); // Vendors need approval
        newVendor.setMemberSince(currentTime);
        newVendor.setUpdatedAt(currentTime);
        
        // Set default URLs
        newVendor.setProfilePictureURL("/assets/images/vendors/default-vendor.jpg");
        
        // Add to list
        vendors.add(newVendor);
        
        // Save to file
        saveVendors();
        
        return Optional.of(newVendor);
    }
    
    /**
     * Register a new vendor with minimal fields
     * @param username Username for new vendor
     * @param password Password for new vendor
     * @param email Email for new vendor
     * @param businessName Business name for new vendor
     * @param contactName Contact name for new vendor
     * @param phoneNumber Phone number for new vendor
     * @return Optional containing the new Vendor if registration successful, empty otherwise
     */
    public Optional<Vendor> registerVendor(String username, String password, String email, 
                                          String businessName, String contactName, String phoneNumber) {
        // Use the full method with empty address
        return registerVendor(username, password, email, businessName, contactName, phoneNumber, "");
    }
    
    /**
     * Add a category to a vendor
     * @param vendorId The ID of the vendor
     * @param category The category to add
     * @return true if successful, false otherwise
     */
    public boolean addVendorCategory(String vendorId, String category) {
        for (Vendor vendor : vendors) {
            if (vendor.getUserId().equals(vendorId)) {
                vendor.addCategory(category);
                saveVendors();
                return true;
            }
        }
        return false;
    }
    
    /**
     * Add a service ID to a vendor
     * @param vendorId The ID of the vendor
     * @param serviceId The service ID to add
     * @return true if successful, false otherwise
     */
    public boolean addVendorServiceId(String vendorId, String serviceId) {
        for (Vendor vendor : vendors) {
            if (vendor.getUserId().equals(vendorId)) {
                vendor.addServiceId(serviceId);
                saveVendors();
                return true;
            }
        }
        return false;
    }
    
    /**
     * Update vendor details
     * @param vendor The updated vendor object
     * @return true if successful, false otherwise
     */
    public boolean updateVendor(Vendor updatedVendor) {
        for (int i = 0; i < vendors.size(); i++) {
            Vendor vendor = vendors.get(i);
            if (vendor.getUserId().equals(updatedVendor.getUserId())) {
                // Update the vendor
                updatedVendor.setUpdatedAt(getCurrentDateTime());
                vendors.set(i, updatedVendor);
                saveVendors();
                return true;
            }
        }
        return false;
    }
    
    /**
     * Get a vendor by ID
     * @param vendorId The ID of the vendor
     * @return Optional containing the vendor if found, empty otherwise
     */
    public Optional<Vendor> getVendorById(String vendorId) {
        for (Vendor vendor : vendors) {
            if (vendor.getUserId().equals(vendorId)) {
                return Optional.of(vendor);
            }
        }
        return Optional.empty();
    }
    
    /**
     * Get all vendors
     * @return List of all vendors
     */
    public List<Vendor> getAllVendors() {
        return new ArrayList<>(vendors);
    }
    
    /**
     * Get vendors by category
     * @param category The category to filter by
     * @return List of vendors in the specified category
     */
    public List<Vendor> getVendorsByCategory(String category) {
        List<Vendor> result = new ArrayList<>();
        for (Vendor vendor : vendors) {
            if (vendor.hasCategory(category) && "active".equals(vendor.getAccountStatus())) {
                result.add(vendor);
            }
        }
        return result;
    }
    
    /**
     * Get featured vendors
     * @param limit Maximum number of vendors to return
     * @return List of featured vendors
     */
    public List<Vendor> getFeaturedVendors(int limit) {
        List<Vendor> featuredVendors = new ArrayList<>();
        for (Vendor vendor : vendors) {
            if (vendor.isFeatured() && "active".equals(vendor.getAccountStatus())) {
                featuredVendors.add(vendor);
                if (featuredVendors.size() >= limit) {
                    break;
                }
            }
        }
        return featuredVendors;
    }
    
    /**
     * Check if username already exists across all user types
     * @param username Username to check
     * @return true if username exists, false otherwise
     */
    public boolean isUsernameExists(String username) {
        // Check regular users
        for (RegularUser user : regularUsers) {
            if (user.getUsername().equals(username)) {
                return true;
            }
        }
        
        // Check vendors
        for (Vendor vendor : vendors) {
            if (vendor.getUsername().equals(username)) {
                return true;
            }
        }
        
        // Check admins
        for (Admin admin : admins) {
            if (admin.getUsername().equals(username)) {
                return true;
            }
        }
        
        // Username not found
        return false;
    }
    
    /**
     * Check if email already exists across all user types
     * @param email Email to check
     * @return true if email exists, false otherwise
     */
    public boolean isEmailExists(String email) {
        // Check regular users
        for (RegularUser user : regularUsers) {
            if (user.getEmail().equals(email)) {
                return true;
            }
        }
        
        // Check vendors
        for (Vendor vendor : vendors) {
            if (vendor.getEmail().equals(email)) {
                return true;
            }
        }
        
        // Check admins
        for (Admin admin : admins) {
            if (admin.getEmail().equals(email)) {
                return true;
            }
        }
        
        // Email not found
        return false;
    }
    
    /**
     * Generate next user ID
     * @return String containing the next user ID (e.g. U1006)
     */
    private String generateNextUserId() {
        // Find the highest user ID
        int maxId = 1000;
        
        for (RegularUser user : regularUsers) {
            String userId = user.getUserId();
            if (userId != null && userId.startsWith("U")) {
                try {
                    int id = Integer.parseInt(userId.substring(1));
                    if (id > maxId) {
                        maxId = id;
                    }
                } catch (NumberFormatException e) {
                    // Ignore and continue
                }
            }
        }
        
        // Return next ID
        return "U" + (maxId + 1);
    }
    
    /**
     * Generate next vendor ID
     * @return String containing the next vendor ID (e.g. V1006)
     */
    private String generateNextVendorId() {
        // Find the highest vendor ID
        int maxId = 1000;
        
        for (Vendor vendor : vendors) {
            String vendorId = vendor.getUserId();
            if (vendorId != null && vendorId.startsWith("V")) {
                try {
                    int id = Integer.parseInt(vendorId.substring(1));
                    if (id > maxId) {
                        maxId = id;
                    }
                } catch (NumberFormatException e) {
                    // Ignore and continue
                }
            }
        }
        
        // Return next ID
        return "V" + (maxId + 1);
    }
    
    /**
     * Get current date and time in the specified format
     * @return String containing formatted date and time
     */
    private String getCurrentDateTime() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
    
    /**
     * Get count of regular users
     * @return Number of regular users
     */
    public int getUserCount() {
        return regularUsers.size();
    }
    
    /**
     * Get count of vendors
     * @return Number of vendors
     */
    public int getVendorCount() {
        return vendors.size();
    }
    
    /**
     * Get count of admins
     * @return Number of admins
     */
    public int getAdminCount() {
        return admins.size();
    }
    
    /**
     * Get total user count across all user types
     * @return Total number of users
     */
    public int getTotalUserCount() {
        return regularUsers.size() + vendors.size() + admins.size();
    }
    
    /**
     * Get most recent regular users
     * @param limit Number of users to return
     * @return List of most recent regular users as Map objects
     */
    public List<Map<String, Object>> getRecentUsers(int limit) {
        // Sort users by registration date (most recent first)
        List<RegularUser> sortedUsers = new ArrayList<>(regularUsers);
        sortedUsers.sort((u1, u2) -> {
            if (u1.getRegistrationDate() == null) return 1;
            if (u2.getRegistrationDate() == null) return -1;
            return u2.getRegistrationDate().compareTo(u1.getRegistrationDate());
        });
        
        // Take only the requested number of users
        List<RegularUser> limitedUsers = sortedUsers.stream()
            .limit(limit)
            .collect(Collectors.toList());
        
        // Convert to Maps with only necessary fields
        List<Map<String, Object>> result = new ArrayList<>();
        for (RegularUser user : limitedUsers) {
            Map<String, Object> userMap = new HashMap<>();
            userMap.put("userId", user.getUserId());
            userMap.put("username", user.getUsername());
            userMap.put("fullName", user.getFullName());
            userMap.put("email", user.getEmail());
            userMap.put("registrationDate", user.getRegistrationDate());
            userMap.put("accountStatus", user.getAccountStatus());
            result.add(userMap);
        }
        
        return result;
    }
    
    /**
     * Get most recent vendors
     * @param limit Number of vendors to return
     * @return List of most recent vendors as Map objects
     */
    public List<Map<String, Object>> getRecentVendors(int limit) {
        // Sort vendors by registration date (most recent first)
        List<Vendor> sortedVendors = new ArrayList<>(vendors);
        sortedVendors.sort((v1, v2) -> {
            if (v1.getRegistrationDate() == null) return 1;
            if (v2.getRegistrationDate() == null) return -1;
            return v2.getRegistrationDate().compareTo(v1.getRegistrationDate());
        });
        
        // Take only the requested number of vendors
        List<Vendor> limitedVendors = sortedVendors.stream()
            .limit(limit)
            .collect(Collectors.toList());
        
        // Convert to Maps with only necessary fields
        List<Map<String, Object>> result = new ArrayList<>();
        for (Vendor vendor : limitedVendors) {
            Map<String, Object> vendorMap = new HashMap<>();
            vendorMap.put("userId", vendor.getUserId());
            vendorMap.put("username", vendor.getUsername());
            vendorMap.put("businessName", vendor.getBusinessName());
            vendorMap.put("contactName", vendor.getContactName());
            vendorMap.put("email", vendor.getEmail());
            vendorMap.put("registrationDate", vendor.getRegistrationDate());
            vendorMap.put("accountStatus", vendor.getAccountStatus());
            vendorMap.put("categories", vendor.getCategories());
            vendorMap.put("rating", vendor.getRating());
            vendorMap.put("featured", vendor.isFeatured());
            result.add(vendorMap);
        }
        
        return result;
    }
    
    /**
     * Get most recent admins
     * @param limit Number of admins to return
     * @return List of most recent admins as Map objects
     */
    public List<Map<String, Object>> getRecentAdmins(int limit) {
        // Sort admins by registration date (most recent first)
        List<Admin> sortedAdmins = new ArrayList<>(admins);
        sortedAdmins.sort((a1, a2) -> {
            if (a1.getRegistrationDate() == null) return 1;
            if (a2.getRegistrationDate() == null) return -1;
            return a2.getRegistrationDate().compareTo(a1.getRegistrationDate());
        });
        
        // Take only the requested number of admins
        List<Admin> limitedAdmins = sortedAdmins.stream()
            .limit(limit)
            .collect(Collectors.toList());
        
        // Convert to Maps with only necessary fields
        List<Map<String, Object>> result = new ArrayList<>();
        for (Admin admin : limitedAdmins) {
            Map<String, Object> adminMap = new HashMap<>();
            adminMap.put("userId", admin.getUserId());
            adminMap.put("username", admin.getUsername());
            adminMap.put("fullName", admin.getFullName());
            adminMap.put("email", admin.getEmail());
            adminMap.put("registrationDate", admin.getRegistrationDate());
            adminMap.put("accountStatus", admin.getAccountStatus());
            adminMap.put("isSuperAdmin", admin.isSuperAdmin());
            result.add(adminMap);
        }
        
        return result;
    }
}