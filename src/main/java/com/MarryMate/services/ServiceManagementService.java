package com.MarryMate.services;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Service class to manage service-related operations
 * Current Date and Time: 2025-05-18 11:06:06
 * Current User: IT24102137
 */
public class ServiceManagementService {
    
    // File paths for JSON data storage
    private String servicesFilePath;
    private String categoriesFilePath;
    
    // GSON for JSON serialization/deserialization
    private final Gson gson;
    
    /**
     * Constructor with file paths
     * @param servicesFilePath The path to the services JSON file
     * @param categoriesFilePath The path to the categories JSON file
     */
    public ServiceManagementService(String servicesFilePath, String categoriesFilePath) {
        this.servicesFilePath = servicesFilePath;
        this.categoriesFilePath = categoriesFilePath;
        this.gson = new GsonBuilder().setPrettyPrinting().create();
        
        // Ensure files exist
        ensureFilesExist();
    }
    
    /**
     * Ensure necessary JSON files exist
     */
    private void ensureFilesExist() {
        try {
            // Check services file
            File servicesFile = new File(servicesFilePath);
            if (!servicesFile.exists()) {
                servicesFile.getParentFile().mkdirs();
                JsonArray services = new JsonArray();
                try (FileWriter writer = new FileWriter(servicesFile)) {
                    gson.toJson(services, writer);
                }
            }
            
            // Check categories file
            File categoriesFile = new File(categoriesFilePath);
            if (!categoriesFile.exists()) {
                categoriesFile.getParentFile().mkdirs();
                JsonArray categories = new JsonArray();
                
                // Add default categories
                String[] defaultCategories = {
                    "photography", "videography", "catering", "venues", "decoration", 
                    "entertainment", "planning", "beauty", "transportation", "attire",
                    "jewelry", "invitations", "gifts", "flowers", "rental", "cake", "honeymoon"
                };
                
                for (String category : defaultCategories) {
                    JsonObject categoryObj = new JsonObject();
                    categoryObj.addProperty("name", category);
                    categoryObj.addProperty("active", true);
                    categoryObj.addProperty("serviceCount", 0);
                    categories.add(categoryObj);
                }
                
                try (FileWriter writer = new FileWriter(categoriesFile)) {
                    gson.toJson(categories, writer);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Get all services
     * @return JsonArray containing all services
     */
    public JsonArray getAllServices() {
        try {
            File file = new File(servicesFilePath);
            if (!file.exists()) {
                return new JsonArray();
            }
            
            try (FileReader reader = new FileReader(file)) {
                JsonElement element = JsonParser.parseReader(reader);
                // Check if it's already an array or if it has a services property
                if (element.isJsonArray()) {
                    return element.getAsJsonArray();
                } else if (element.isJsonObject() && element.getAsJsonObject().has("services")) {
                    return element.getAsJsonObject().getAsJsonArray("services");
                } else {
                    return new JsonArray();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            return new JsonArray();
        }
    }
    
    /**
     * Get service by ID
     * @param serviceId The service ID
     * @return Service as JsonObject or null if not found
     */
    public JsonObject getServiceById(String serviceId) {
        JsonArray services = getAllServices();
        
        for (JsonElement element : services) {
            JsonObject service = element.getAsJsonObject();
            if (service.has("serviceId") && service.get("serviceId").getAsString().equals(serviceId)) {
                return service;
            }
        }
        
        return null;
    }
    
    /**
     * Get services by vendor ID
     * @param vendorId The vendor ID
     * @return JsonArray of services for the vendor
     */
    public JsonArray getServicesByVendorId(String vendorId) {
        JsonArray result = new JsonArray();
        JsonArray services = getAllServices();
        
        for (JsonElement element : services) {
            JsonObject service = element.getAsJsonObject();
            if (service.has("vendorId") && service.get("vendorId").getAsString().equals(vendorId)) {
                result.add(service);
            }
        }
        
        return result;
    }
    
    /**
     * Create a new service
     * @param service The service data
     * @return Created service with ID or null if failed
     */
    public JsonObject createService(JsonObject service) {
        try {
            JsonArray services = getAllServices();
            
            // Generate service ID
            String serviceId = generateNextServiceId(services);
            service.addProperty("serviceId", serviceId);
            
            // Set timestamps
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String currentDateTime = sdf.format(new Date());
            service.addProperty("createdAt", currentDateTime);
            service.addProperty("updatedAt", currentDateTime);
            
            // Add to services array
            services.add(service);
            
            // Save to file
            saveServices(services);
            
            // Update category count if applicable
            if (service.has("category")) {
                updateCategoryCount(service.get("category").getAsString(), 1);
            }
            
            return service;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Update an existing service
     * @param serviceId The service ID to update
     * @param updatedService The updated service data
     * @return Updated service or null if failed
     */
    public JsonObject updateService(String serviceId, JsonObject updatedService) {
        try {
            JsonArray services = getAllServices();
            String oldCategory = null;
            
            for (int i = 0; i < services.size(); i++) {
                JsonObject service = services.get(i).getAsJsonObject();
                if (service.has("serviceId") && service.get("serviceId").getAsString().equals(serviceId)) {
                    // Save old category for count update
                    if (service.has("category")) {
                        oldCategory = service.get("category").getAsString();
                    }
                    
                    // Preserve ID and timestamps
                    updatedService.addProperty("serviceId", serviceId);
                    if (service.has("createdAt")) {
                        updatedService.addProperty("createdAt", service.get("createdAt").getAsString());
                    }
                    
                    // Update timestamp
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    updatedService.addProperty("updatedAt", sdf.format(new Date()));
                    
                    // Update the service
                    services.set(i, updatedService);
                    
                    // Save to file
                    saveServices(services);
                    
                    // Update category counts if changed
                    if (oldCategory != null && updatedService.has("category")) {
                        String newCategory = updatedService.get("category").getAsString();
                        if (!oldCategory.equals(newCategory)) {
                            updateCategoryCount(oldCategory, -1);
                            updateCategoryCount(newCategory, 1);
                        }
                    }
                    
                    return updatedService;
                }
            }
            
            return null; // Service not found
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Delete a service
     * @param serviceId The service ID to delete
     * @return true if deleted, false otherwise
     */
    public boolean deleteService(String serviceId) {
        try {
            JsonArray services = getAllServices();
            String category = null;
            
            for (int i = 0; i < services.size(); i++) {
                JsonObject service = services.get(i).getAsJsonObject();
                if (service.has("serviceId") && service.get("serviceId").getAsString().equals(serviceId)) {
                    // Save category for count update
                    if (service.has("category")) {
                        category = service.get("category").getAsString();
                    }
                    
                    // Remove the service
                    services.remove(i);
                    
                    // Save to file
                    saveServices(services);
                    
                    // Update category count
                    if (category != null) {
                        updateCategoryCount(category, -1);
                    }
                    
                    return true;
                }
            }
            
            return false; // Service not found
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Get all service categories
     * @return JsonArray of service categories
     */
    public JsonArray getServiceCategories() {
        try {
            File file = new File(categoriesFilePath);
            if (!file.exists()) {
                return new JsonArray();
            }
            
            try (FileReader reader = new FileReader(file)) {
                return JsonParser.parseReader(reader).getAsJsonArray();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return new JsonArray();
        }
    }
    
    // Helper methods
    
    /**
     * Save services to file
     * @param services JsonArray of services
     * @throws IOException if saving fails
     */
    private void saveServices(JsonArray services) throws IOException {
        try (FileWriter writer = new FileWriter(servicesFilePath)) {
            gson.toJson(services, writer);
        }
    }
    
    /**
     * Generate next service ID
     * @param services JsonArray of current services
     * @return String with next ID in format S1001, S1002, etc.
     */
    private String generateNextServiceId(JsonArray services) {
        int maxId = 1000;
        
        for (JsonElement element : services) {
            JsonObject service = element.getAsJsonObject();
            if (service.has("serviceId")) {
                String serviceId = service.get("serviceId").getAsString();
                if (serviceId.startsWith("S") && serviceId.length() > 1) {
                    try {
                        int id = Integer.parseInt(serviceId.substring(1));
                        if (id > maxId) {
                            maxId = id;
                        }
                    } catch (NumberFormatException e) {
                        // Skip invalid formats
                    }
                }
            }
        }
        
        return "S" + (maxId + 1);
    }
    
    /**
     * Update category count
     * @param categoryName The category name
     * @param delta The change amount (1 for add, -1 for remove)
     */
    private void updateCategoryCount(String categoryName, int delta) {
        try {
            JsonArray categories = getServiceCategories();
            boolean found = false;
            
            for (int i = 0; i < categories.size(); i++) {
                JsonObject category = categories.get(i).getAsJsonObject();
                if (category.has("name") && category.get("name").getAsString().equals(categoryName)) {
                    int count = category.has("serviceCount") ? category.get("serviceCount").getAsInt() : 0;
                    // Ensure count doesn't go below 0
                    count = Math.max(0, count + delta);
                    category.addProperty("serviceCount", count);
                    found = true;
                    break;
                }
            }
            
            // If category doesn't exist and we're adding a service, create it
            if (!found && delta > 0) {
                JsonObject newCategory = new JsonObject();
                newCategory.addProperty("name", categoryName);
                newCategory.addProperty("active", true);
                newCategory.addProperty("serviceCount", 1);
                categories.add(newCategory);
            }
            
            // Save updated categories
            try (FileWriter writer = new FileWriter(categoriesFilePath)) {
                gson.toJson(categories, writer);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}