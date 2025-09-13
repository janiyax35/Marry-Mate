package com.MarryMate.services;

import com.MarryMate.models.VendorService;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Type;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Service class for managing vendor services
 * @author IT24102137
 * @version 1.0
 */
public class VendorServiceService {
    private static final String VENDOR_SERVICES_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendorServices.json";
    private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();
    
    /**
     * Gets all services for a specific vendor
     * @param vendorId The vendor ID
     * @return List of vendor services
     */
    public List<VendorService> getVendorServices(String vendorId) {
        List<VendorService> allServices = getAllServices();
        return allServices.stream()
                .filter(service -> service.getVendorId().equals(vendorId))
                .collect(Collectors.toList());
    }
    
    /**
     * Gets all services from the JSON file
     * @return List of all vendor services
     */
    public List<VendorService> getAllServices() {
        try (FileReader reader = new FileReader(VENDOR_SERVICES_FILE_PATH)) {
            Type listType = new TypeToken<ArrayList<VendorService>>(){}.getType();
            List<VendorService> services = gson.fromJson(reader, listType);
            return services != null ? services : new ArrayList<>();
        } catch (IOException e) {
            System.err.println("Error reading vendor services file: " + e.getMessage());
            return new ArrayList<>();
        }
    }
    
    /**
     * Get a service by its ID
     * @param serviceId The service ID
     * @return The vendor service or null if not found
     */
    public VendorService getServiceById(String serviceId) {
        return getAllServices().stream()
                .filter(service -> service.getId().equals(serviceId))
                .findFirst()
                .orElse(null);
    }
    
    /**
     * Add a new vendor service
     * @param service The service to add
     * @return True if successful, false otherwise
     */
    public boolean addService(VendorService service) {
        List<VendorService> services = getAllServices();
        
        // Generate a new ID
        String newId = generateServiceId(services);
        service.setId(newId);
        
        // Set creation and update timestamps
        String timestamp = getCurrentTimestamp();
        service.setCreatedAt(timestamp);
        service.setUpdatedAt(timestamp);
        
        services.add(service);
        return saveAllServices(services);
    }
    
    /**
     * Update an existing vendor service
     * @param service The updated service
     * @return True if successful, false otherwise
     */
    public boolean updateService(VendorService service) {
        List<VendorService> services = getAllServices();
        
        boolean found = false;
        for (int i = 0; i < services.size(); i++) {
            if (services.get(i).getId().equals(service.getId())) {
                // Update the timestamp
                service.setUpdatedAt(getCurrentTimestamp());
                // Preserve creation date
                service.setCreatedAt(services.get(i).getCreatedAt());
                // Replace the service
                services.set(i, service);
                found = true;
                break;
            }
        }
        
        if (!found) {
            return false;
        }
        
        return saveAllServices(services);
    }
    
    /**
     * Delete a service by its ID
     * @param serviceId The service ID
     * @return True if successful, false otherwise
     */
    public boolean deleteService(String serviceId) {
        List<VendorService> services = getAllServices();
        
        boolean removed = services.removeIf(service -> service.getId().equals(serviceId));
        
        if (!removed) {
            return false;
        }
        
        return saveAllServices(services);
    }
    
    /**
     * Update the status of a service
     * @param serviceId The service ID
     * @param status The new status
     * @return True if successful, false otherwise
     */
    public boolean updateServiceStatus(String serviceId, String status) {
        VendorService service = getServiceById(serviceId);
        if (service == null) {
            return false;
        }
        
        service.setStatus(status);
        service.setUpdatedAt(getCurrentTimestamp());
        
        return updateService(service);
    }
    
    /**
     * Save all services to the JSON file
     * @param services The list of services to save
     * @return True if successful, false otherwise
     */
    private boolean saveAllServices(List<VendorService> services) {
        try (FileWriter writer = new FileWriter(VENDOR_SERVICES_FILE_PATH)) {
            gson.toJson(services, writer);
            return true;
        } catch (IOException e) {
            System.err.println("Error writing to vendor services file: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Generate a new service ID
     * @param services The list of existing services
     * @return The new ID
     */
    private String generateServiceId(List<VendorService> services) {
        int maxId = 1000; // Starting ID number
        
        for (VendorService service : services) {
            try {
                String idNumber = service.getId().substring(1); // Remove the 'S' prefix
                int id = Integer.parseInt(idNumber);
                if (id > maxId) {
                    maxId = id;
                }
            } catch (Exception e) {
                // Skip if ID format is invalid
            }
        }
        
        return "S" + (maxId + 1);
    }
    
    /**
     * Get the current timestamp in the required format
     * @return Formatted timestamp string
     */
    private String getCurrentTimestamp() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        return LocalDateTime.now().format(formatter);
    }
}