package com.MarryMate.services;

import com.MarryMate.models.Vendor;
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
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * Service class for Vendor Management operations
 * Handles all business logic related to vendor operations
 * 
 * Current Date and Time: 2025-05-18 17:33:28
 * Current User: IT24102137
 */
public class VendorManagementService {
    
    private static final String VENDORS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
    
    /**
     * Constructor initializes the service
     */
    public VendorManagementService() {
        // Default constructor
    }
    
    /**
     * Get all vendors from JSON file
     * @return List of Vendor objects
     * @throws IOException If file cannot be read
     */
    public List<Vendor> getAllVendors() throws IOException {
        return loadVendorsFromJson();
    }
    
    /**
     * Get a specific vendor by ID
     * @param vendorId Vendor ID to find
     * @return Optional containing the Vendor if found
     * @throws IOException If file cannot be read
     */
    public Optional<Vendor> getVendorById(String vendorId) throws IOException {
        List<Vendor> vendors = loadVendorsFromJson();
        return vendors.stream()
                .filter(vendor -> vendor.getUserId().equals(vendorId))
                .findFirst();
    }
    
    /**
     * Create a new vendor
     * @param vendorData Map containing vendor data
     * @return The newly created Vendor object
     * @throws IOException If file operations fail
     */
    public Vendor createVendor(Map<String, Object> vendorData) throws IOException {
        List<Vendor> vendors = loadVendorsFromJson();
        
        // Generate new vendor ID
        String vendorId = generateVendorId(vendors);
        
        // Create Vendor object
        Vendor newVendor = new Vendor();
        newVendor.setUserId(vendorId);
        updateVendorFromMap(newVendor, vendorData);
        
        // Set create-specific fields
        String currentDateTime = getCurrentDateTime();
        newVendor.setRegistrationDate(currentDateTime);
        newVendor.setLastLogin(currentDateTime);
        newVendor.setUpdatedAt(currentDateTime);
        newVendor.setUpdatedBy("IT24102137"); // Admin username
        newVendor.setUpdatedAt(currentDateTime.split(" ")[0]); // Just the date part
        newVendor.setMemberSince(currentDateTime);
        newVendor.setFailedLoginAttempts(0);
        
        // Set default profile picture if none provided
        if (newVendor.getProfilePictureURL() == null || newVendor.getProfilePictureURL().isEmpty()) {
            newVendor.setProfilePictureURL("/assets/images/vendors/default-vendor.jpg");
        }
        
        // Add to list and save
        vendors.add(newVendor);
        saveVendorsToJson(vendors);
        
        return newVendor;
    }
    
    /**
     * Update an existing vendor
     * @param vendorId ID of vendor to update
     * @param vendorData Map containing updated vendor data
     * @return Updated Vendor object
     * @throws IOException If file operations fail
     * @throws IllegalArgumentException If vendor ID is not found
     */
    public Vendor updateVendor(String vendorId, Map<String, Object> vendorData) throws IOException {
        List<Vendor> vendors = loadVendorsFromJson();
        
        // Find the vendor to update
        Optional<Vendor> optionalVendor = vendors.stream()
                .filter(vendor -> vendor.getUserId().equals(vendorId))
                .findFirst();
                
        if (!optionalVendor.isPresent()) {
            throw new IllegalArgumentException("Vendor with ID " + vendorId + " not found");
        }
        
        Vendor vendor = optionalVendor.get();
        updateVendorFromMap(vendor, vendorData);
        
        // Set update-specific fields
        vendor.setUpdatedAt(getCurrentDateTime());
        vendor.setUpdatedBy("IT24102137"); // Admin username
        
        saveVendorsToJson(vendors);
        
        return vendor;
    }
    
    /**
     * Delete a vendor by ID
     * @param vendorId ID of vendor to delete
     * @return true if successful, false if vendor not found
     * @throws IOException If file operations fail
     */
    public boolean deleteVendor(String vendorId) throws IOException {
        List<Vendor> vendors = loadVendorsFromJson();
        int initialSize = vendors.size();
        
        vendors = vendors.stream()
                .filter(vendor -> !vendor.getUserId().equals(vendorId))
                .collect(Collectors.toList());
                
        boolean vendorRemoved = vendors.size() < initialSize;
        
        if (vendorRemoved) {
            saveVendorsToJson(vendors);
        }
        
        return vendorRemoved;
    }
    
    /**
     * Change a vendor's account status
     * @param vendorId ID of vendor to update
     * @param status New account status
     * @return Updated Vendor object
     * @throws IOException If file operations fail
     * @throws IllegalArgumentException If vendor ID is not found
     */
    public Vendor changeVendorStatus(String vendorId, String status) throws IOException {
        List<Vendor> vendors = loadVendorsFromJson();
        
        Optional<Vendor> optionalVendor = vendors.stream()
                .filter(vendor -> vendor.getUserId().equals(vendorId))
                .findFirst();
                
        if (!optionalVendor.isPresent()) {
            throw new IllegalArgumentException("Vendor with ID " + vendorId + " not found");
        }
        
        Vendor vendor = optionalVendor.get();
        vendor.setStatus(status);
        vendor.setUpdatedAt(getCurrentDateTime());
        vendor.setUpdatedBy("IT24102137");
        
        saveVendorsToJson(vendors);
        
        return vendor;
    }
    
    /**
     * Search for vendors based on keyword
     * @param keyword Text to search for
     * @return List of matching Vendor objects
     * @throws IOException If file operations fail
     */
    public List<Vendor> searchVendors(String keyword) throws IOException {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllVendors();
        }
        
        String searchTerm = keyword.toLowerCase();
        List<Vendor> vendors = loadVendorsFromJson();
        
        return vendors.stream()
                .filter(vendor -> 
                    vendor.getUsername().toLowerCase().contains(searchTerm) ||
                    vendor.getEmail().toLowerCase().contains(searchTerm) ||
                    vendor.getBusinessName().toLowerCase().contains(searchTerm) ||
                    vendor.getContactName().toLowerCase().contains(searchTerm) ||
                    vendor.getUserId().toLowerCase().contains(searchTerm) ||
                    (vendor.getDescription() != null && vendor.getDescription().toLowerCase().contains(searchTerm)) ||
                    (vendor.getPhoneNumber() != null && vendor.getPhoneNumber().toLowerCase().contains(searchTerm))
                )
                .collect(Collectors.toList());
    }
    
    /**
     * Filter vendors by account status
     * @param status Account status to filter by
     * @return List of matching Vendor objects
     * @throws IOException If file operations fail
     */
    public List<Vendor> filterVendorsByStatus(String status) throws IOException {
        if (status == null || status.trim().isEmpty()) {
            return getAllVendors();
        }
        
        List<Vendor> vendors = loadVendorsFromJson();
        
        return vendors.stream()
                .filter(vendor -> status.equalsIgnoreCase(vendor.getStatus()))
                .collect(Collectors.toList());
    }
    
    /**
     * Filter vendors by category
     * @param category Category to filter by
     * @return List of matching Vendor objects
     * @throws IOException If file operations fail
     */
    public List<Vendor> filterVendorsByCategory(String category) throws IOException {
        if (category == null || category.trim().isEmpty()) {
            return getAllVendors();
        }
        
        List<Vendor> vendors = loadVendorsFromJson();
        
        return vendors.stream()
                .filter(vendor -> vendor.getCategories() != null && 
                                  vendor.getCategories().stream()
                                         .anyMatch(cat -> category.equalsIgnoreCase(cat)))
                .collect(Collectors.toList());
    }
    
    /**
     * Filter vendors by registration date range
     * @param startDate Start date in YYYY-MM-DD format
     * @param endDate End date in YYYY-MM-DD format
     * @return List of matching Vendor objects
     * @throws IOException If file operations fail
     */
    public List<Vendor> filterVendorsByRegistrationDate(String startDate, String endDate) throws IOException {
        if (startDate == null || endDate == null) {
            return getAllVendors();
        }
        
        List<Vendor> vendors = loadVendorsFromJson();
        
        return vendors.stream()
                .filter(vendor -> isDateInRange(vendor.getMemberSince(), startDate, endDate))
                .collect(Collectors.toList());
    }
    
    /**
     * Combine multiple filter criteria
     * @param status Account status (optional)
     * @param category Vendor category (optional)
     * @param dateRange Date range string "YYYY-MM-DD to YYYY-MM-DD" (optional)
     * @param searchTerm Search keyword (optional)
     * @return List of matching Vendor objects
     * @throws IOException If file operations fail
     */
    public List<Vendor> filterVendors(String status, String category, String dateRange, String searchTerm) throws IOException {
        List<Vendor> filteredVendors = getAllVendors();
        
        // Apply status filter
        if (status != null && !status.trim().isEmpty()) {
            filteredVendors = filteredVendors.stream()
                    .filter(vendor -> status.equalsIgnoreCase(vendor.getStatus()))
                    .collect(Collectors.toList());
        }
        
        // Apply category filter
        if (category != null && !category.trim().isEmpty()) {
            filteredVendors = filteredVendors.stream()
                    .filter(vendor -> vendor.getCategories() != null && 
                                      vendor.getCategories().stream()
                                             .anyMatch(cat -> category.equalsIgnoreCase(cat)))
                    .collect(Collectors.toList());
        }
        
        // Apply date range filter
        if (dateRange != null && !dateRange.trim().isEmpty() && dateRange.contains("to")) {
            String[] dates = dateRange.split("to");
            if (dates.length == 2) {
                String startDate = dates[0].trim();
                String endDate = dates[1].trim();
                
                filteredVendors = filteredVendors.stream()
                        .filter(vendor -> isDateInRange(vendor.getMemberSince(), startDate, endDate))
                        .collect(Collectors.toList());
            }
        }
        
        // Apply search term
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            String term = searchTerm.toLowerCase();
            filteredVendors = filteredVendors.stream()
                    .filter(vendor -> 
                        vendor.getUsername().toLowerCase().contains(term) ||
                        vendor.getEmail().toLowerCase().contains(term) ||
                        vendor.getBusinessName().toLowerCase().contains(term) ||
                        vendor.getContactName().toLowerCase().contains(term) ||
                        vendor.getUserId().toLowerCase().contains(term) ||
                        (vendor.getDescription() != null && vendor.getDescription().toLowerCase().contains(term)) ||
                        (vendor.getPhoneNumber() != null && vendor.getPhoneNumber().toLowerCase().contains(term))
                    )
                    .collect(Collectors.toList());
        }
        
        return filteredVendors;
    }
    
    /**
     * Export vendors data to Excel format
     * @param vendors List of vendors to export
     * @param outputStream Output stream to write to
     * @throws IOException If write fails
     */
    public void exportVendorsToExcel(List<Vendor> vendors, OutputStream outputStream) throws IOException {
        // This is a placeholder - in a real application you'd use a library
        // like Apache POI to generate Excel files
        StringBuilder csv = new StringBuilder();
        
        // Header
        csv.append("Vendor ID,Business Name,Contact Name,Email,Phone Number,Categories,Rating,Status,Member Since\n");
        
        // Data rows
        for (Vendor vendor : vendors) {
            csv.append(vendor.getUserId()).append(",");
            csv.append(escapeCsvField(vendor.getBusinessName())).append(",");
            csv.append(escapeCsvField(vendor.getContactName())).append(",");
            csv.append(vendor.getEmail()).append(",");
            csv.append(vendor.getPhone() != null ? vendor.getPhone() : "").append(",");
            csv.append(vendor.getCategories() != null ? 
                      escapeCsvField(String.join(", ", vendor.getCategories())) : "").append(",");
            csv.append(vendor.getRating()).append(",");
            csv.append(vendor.getStatus()).append(",");
            csv.append(vendor.getMemberSince()).append("\n");
        }
        
        outputStream.write(csv.toString().getBytes());
    }
    
    /**
     * Export vendors data to CSV format
     * @param vendors List of vendors to export
     * @param outputStream Output stream to write to
     * @throws IOException If write fails
     */
    public void exportVendorsToCSV(List<Vendor> vendors, OutputStream outputStream) throws IOException {
        StringBuilder csv = new StringBuilder();
        
        // Header
        csv.append("Vendor ID,Business Name,Contact Name,Email,Phone Number,Categories,Rating,Status,Member Since\n");
        
        // Data rows
        for (Vendor vendor : vendors) {
            csv.append(vendor.getUserId()).append(",");
            csv.append(escapeCsvField(vendor.getBusinessName())).append(",");
            csv.append(escapeCsvField(vendor.getContactName())).append(",");
            csv.append(vendor.getEmail()).append(",");
            csv.append(vendor.getPhone() != null ? vendor.getPhone() : "").append(",");
            csv.append(vendor.getCategories() != null ? 
                      escapeCsvField(String.join(", ", vendor.getCategories())) : "").append(",");
            csv.append(vendor.getRating()).append(",");
            csv.append(vendor.getStatus()).append(",");
            csv.append(vendor.getMemberSince()).append("\n");
        }
        
        outputStream.write(csv.toString().getBytes());
    }
    
    /**
     * Export vendors data to PDF format
     * @param vendors List of vendors to export
     * @param outputStream Output stream to write to
     * @throws IOException If write fails
     */
    public void exportVendorsToPDF(List<Vendor> vendors, OutputStream outputStream) throws IOException {
        // This is a placeholder - in a real application you'd use a library
        // like iText or Apache PDFBox to generate PDF files
        StringBuilder text = new StringBuilder();
        text.append("Vendor Management Report\n");
        text.append("Generated on: ").append(getCurrentDateTime()).append("\n\n");
        
        for (Vendor vendor : vendors) {
            text.append("Vendor ID: ").append(vendor.getUserId()).append("\n");
            text.append("Business Name: ").append(vendor.getBusinessName()).append("\n");
            text.append("Contact Name: ").append(vendor.getContactName()).append("\n");
            text.append("Email: ").append(vendor.getEmail()).append("\n");
            text.append("Phone: ").append(vendor.getPhone()).append("\n");
            text.append("Status: ").append(vendor.getStatus()).append("\n");
            text.append("Rating: ").append(vendor.getRating()).append("\n");
            text.append("Member Since: ").append(vendor.getMemberSince()).append("\n");
            text.append("Categories: ").append(vendor.getCategories() != null ? 
                                             String.join(", ", vendor.getCategories()) : "").append("\n\n");
        }
        
        outputStream.write(text.toString().getBytes());
    }
    
    /**
     * Get featured vendors
     * @return List of featured vendors
     * @throws IOException If file operations fail
     */
    public List<Vendor> getFeaturedVendors() throws IOException {
        List<Vendor> vendors = loadVendorsFromJson();
        return vendors.stream()
                .filter(Vendor::isFeatured)
                .collect(Collectors.toList());
    }
    
    /**
     * Get top rated vendors
     * @param limit Number of vendors to return
     * @return List of top rated vendors
     * @throws IOException If file operations fail
     */
    public List<Vendor> getTopRatedVendors(int limit) throws IOException {
        List<Vendor> vendors = loadVendorsFromJson();
        return vendors.stream()
                .filter(vendor -> "active".equals(vendor.getStatus()))
                .filter(vendor -> vendor.getRating() > 0)
                .sorted((v1, v2) -> Double.compare(v2.getRating(), v1.getRating()))
                .limit(limit)
                .collect(Collectors.toList());
    }
    
    /**
     * Get vendors by service ID
     * @param serviceId The service ID to search for
     * @return List of vendors offering the service
     * @throws IOException If file operations fail
     */
    public List<Vendor> getVendorsByServiceId(String serviceId) throws IOException {
        List<Vendor> vendors = loadVendorsFromJson();
        return vendors.stream()
                .filter(vendor -> vendor.getServiceIds() != null && 
                                  vendor.getServiceIds().contains(serviceId))
                .collect(Collectors.toList());
    }
    
    /**
     * Load vendors from JSON file
     * @return List of Vendor objects
     * @throws IOException If file cannot be read
     */
    private List<Vendor> loadVendorsFromJson() throws IOException {
        File file = new File(VENDORS_FILE_PATH);
        
        if (!file.exists()) {
            throw new IOException("Vendors file not found at " + VENDORS_FILE_PATH);
        }
        
        try (FileReader reader = new FileReader(file)) {
            Gson gson = new Gson();
            JsonObject jsonObject = gson.fromJson(reader, JsonObject.class);
            JsonArray vendorsArray = jsonObject.getAsJsonArray("vendors");
            
            List<Vendor> vendorsList = new ArrayList<>();
            
            for (int i = 0; i < vendorsArray.size(); i++) {
                JsonObject vendorJson = vendorsArray.get(i).getAsJsonObject();
                Vendor vendor = gson.fromJson(vendorJson, Vendor.class);
                vendorsList.add(vendor);
            }
            
            return vendorsList;
        }
    }
    
    /**
     * Save vendors list to JSON file
     * @param vendors List of vendors to save
     * @throws IOException If file cannot be written
     */
    private void saveVendorsToJson(List<Vendor> vendors) throws IOException {
        File file = new File(VENDORS_FILE_PATH);
        
        // Create parent directories if they don't exist
        File parentDir = file.getParentFile();
        if (!parentDir.exists()) {
            parentDir.mkdirs();
        }
        
        // Create JSON structure
        JsonObject rootObject = new JsonObject();
        JsonArray vendorsArray = new JsonArray();
        
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        
        for (Vendor vendor : vendors) {
            JsonObject vendorObject = gson.toJsonTree(vendor).getAsJsonObject();
            vendorsArray.add(vendorObject);
        }
        
        rootObject.add("vendors", vendorsArray);
        
        // Write to file
        try (FileWriter writer = new FileWriter(file)) {
            gson.toJson(rootObject, writer);
        }
    }
    
    /**
     * Generate a new unique vendor ID
     * @param existingVendors List of existing vendors
     * @return New vendor ID
     */
    private String generateVendorId(List<Vendor> existingVendors) {
        String prefix = "V";
        int maxId = 1000; // Starting ID if no vendors exist
        
        // Find the highest existing ID
        for (Vendor vendor : existingVendors) {
            String vendorId = vendor.getUserId();
            if (vendorId != null && vendorId.startsWith(prefix)) {
                try {
                    int id = Integer.parseInt(vendorId.substring(prefix.length()));
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
     * Update Vendor object fields from a data map
     * @param vendor Vendor to update
     * @param vendorData Map containing vendor data
     */
    @SuppressWarnings("unchecked")
    private void updateVendorFromMap(Vendor vendor, Map<String, Object> vendorData) {
        if (vendorData.containsKey("username")) vendor.setUsername((String) vendorData.get("username"));
        if (vendorData.containsKey("password")) vendor.setPassword((String) vendorData.get("password"));
        if (vendorData.containsKey("email")) vendor.setEmail((String) vendorData.get("email"));
        if (vendorData.containsKey("businessName")) vendor.setBusinessName((String) vendorData.get("businessName"));
        if (vendorData.containsKey("contactName")) vendor.setContactName((String) vendorData.get("contactName"));
        if (vendorData.containsKey("phone")) vendor.setPhone((String) vendorData.get("phone"));
        if (vendorData.containsKey("address")) vendor.setAddress((String) vendorData.get("address"));
        if (vendorData.containsKey("description")) vendor.setDescription((String) vendorData.get("description"));
        if (vendorData.containsKey("servicesOffered")) vendor.setServicesOffered((String) vendorData.get("servicesOffered"));
        if (vendorData.containsKey("priceRange")) vendor.setPriceRange((String) vendorData.get("priceRange"));
        if (vendorData.containsKey("websiteUrl")) vendor.setWebsiteUrl((String) vendorData.get("websiteUrl"));
        if (vendorData.containsKey("profilePictureUrl")) vendor.setProfilePictureUrl((String) vendorData.get("profilePictureUrl"));
        if (vendorData.containsKey("coverPhotoUrl")) vendor.setCoverPhotoUrl((String) vendorData.get("coverPhotoUrl"));
        if (vendorData.containsKey("status")) vendor.setStatus((String) vendorData.get("status"));
        
        if (vendorData.containsKey("rating") && vendorData.get("rating") != null) {
            if (vendorData.get("rating") instanceof Double) {
                vendor.setRating((Double) vendorData.get("rating"));
            } else if (vendorData.get("rating") instanceof String) {
                try {
                    vendor.setRating(Double.parseDouble((String) vendorData.get("rating")));
                } catch (NumberFormatException e) {
                    vendor.setRating(0.0);
                }
            }
        }
        
        if (vendorData.containsKey("reviewCount") && vendorData.get("reviewCount") != null) {
            if (vendorData.get("reviewCount") instanceof Integer) {
                vendor.setReviewCount((Integer) vendorData.get("reviewCount"));
            } else if (vendorData.get("reviewCount") instanceof String) {
                try {
                    vendor.setReviewCount(Integer.parseInt((String) vendorData.get("reviewCount")));
                } catch (NumberFormatException e) {
                    vendor.setReviewCount(0);
                }
            }
        }
        
        if (vendorData.containsKey("featured") && vendorData.get("featured") != null) {
            if (vendorData.get("featured") instanceof Boolean) {
                vendor.setFeatured((Boolean) vendorData.get("featured"));
            } else if (vendorData.get("featured") instanceof String) {
                vendor.setFeatured(Boolean.parseBoolean((String) vendorData.get("featured")));
            }
        }
        
        // Handle categories - could be a List or comma-separated String
        if (vendorData.containsKey("categories")) {
            if (vendorData.get("categories") instanceof List) {
                vendor.setCategories((List<String>) vendorData.get("categories"));
            } else if (vendorData.get("categories") instanceof String) {
                String categoriesStr = (String) vendorData.get("categories");
                if (!categoriesStr.isEmpty()) {
                    vendor.setCategories(Arrays.asList(categoriesStr.split("\\s*,\\s*")));
                } else {
                    vendor.setCategories(new ArrayList<>());
                }
            }
        }
        
        // Handle serviceIds - could be a List or comma-separated String
        if (vendorData.containsKey("serviceIds")) {
            if (vendorData.get("serviceIds") instanceof List) {
                vendor.setServiceIds((List<String>) vendorData.get("serviceIds"));
            } else if (vendorData.get("serviceIds") instanceof String) {
                String serviceIdsStr = (String) vendorData.get("serviceIds");
                if (!serviceIdsStr.isEmpty()) {
                    vendor.setServiceIds(Arrays.asList(serviceIdsStr.split("\\s*,\\s*")));
                } else {
                    vendor.setServiceIds(new ArrayList<>());
                }
            }
        }
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
            // Extract date part if it includes time
            String datePart = dateStr.split(" ")[0];
            
            // Assume format YYYY-MM-DD
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
            Date date = formatter.parse(datePart);
            Date startDate = formatter.parse(startDateStr);
            Date endDate = formatter.parse(endDateStr);
            
            // Add one day to end date to include it fully
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(endDate);
            calendar.add(Calendar.DATE, 1);
            endDate = calendar.getTime();
            
            return !date.before(startDate) && date.before(endDate);
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
    
    /**
     * Escape CSV field to handle commas and quotes
     * @param field The field to escape
     * @return Escaped field
     */
    private String escapeCsvField(String field) {
        if (field == null) return "";
        if (field.contains(",") || field.contains("\"") || field.contains("\n")) {
            return "\"" + field.replace("\"", "\"\"") + "\"";
        }
        return field;
    }
}