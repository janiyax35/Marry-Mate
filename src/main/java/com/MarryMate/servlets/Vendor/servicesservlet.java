package com.MarryMate.servlets.Vendor;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.annotation.MultipartConfig;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonElement;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.servlet.http.Part;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

@WebServlet("/vendor/servicesservlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,  // 1 MB
    maxFileSize = 1024 * 1024 * 10,   // 10 MB
    maxRequestSize = 1024 * 1024 * 50  // 50 MB
)
public class servicesservlet extends HttpServlet {
    
    private String vendorServicesJsonPath;
    private String vendorsJsonPath;
    private String serviceCategoriesJsonPath;
    private String iconsBasePath;
    private String backgroundsBasePath;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        // Initialize Gson instance
        gson = new GsonBuilder().setPrettyPrinting().create();
        
        // Set paths for data files - using exact paths as specified
        vendorServicesJsonPath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendorServices.json";
        vendorsJsonPath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
        serviceCategoriesJsonPath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\service-categories.json";
        
        System.out.println("vendorServicesJsonPath: " + vendorServicesJsonPath);
        System.out.println("vendorsJsonPath: " + vendorsJsonPath);
        System.out.println("serviceCategoriesJsonPath: " + serviceCategoriesJsonPath);
        
        // Set the base paths for storing service images
        String webappPath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp";
        iconsBasePath = new File(webappPath, "resources\\vendor\\serviceImages").getAbsolutePath();
        backgroundsBasePath = new File(webappPath, "resources\\vendor\\backgroundImages").getAbsolutePath();
        
        // Create directories if they don't exist
        new File(iconsBasePath).mkdirs();
        new File(backgroundsBasePath).mkdirs();
        
        // Create the vendorServices.json file with an empty structure if it doesn't exist
        File jsonFile = new File(vendorServicesJsonPath);
        if (!jsonFile.exists()) {
            try {
                // Ensure parent directories exist
                jsonFile.getParentFile().mkdirs();
                
                try (FileWriter writer = new FileWriter(jsonFile)) {
                    // Create the expected structure with an empty services array
                    JsonObject root = new JsonObject();
                    root.add("services", new JsonArray());
                    writer.write(gson.toJson(root));
                    writer.flush();
                    System.out.println("Created empty vendorServices.json file at: " + jsonFile.getAbsolutePath());
                }
            } catch (IOException e) {
                System.err.println("Failed to create vendorServices.json: " + e.getMessage());
                throw new ServletException("Failed to create vendorServices.json file", e);
            }
        } else {
            System.out.println("vendorServices.json exists with size: " + jsonFile.length() + " bytes");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Get the vendor ID from the session or request
        HttpSession session = request.getSession();
        String vendorId = (String) session.getAttribute("userId");
        System.out.println("Vendor ID from session: " + vendorId);
        
        // If no vendorId in session, try to get from request parameter
        if (vendorId == null || vendorId.isEmpty()) {
            vendorId = request.getParameter("vendorId");
            // For testing - use a default vendorId if none provided
            if (vendorId == null || vendorId.isEmpty()) {
                vendorId = "V1007"; // Default for testing
                System.out.println("Using default vendor ID: " + vendorId);
            }
        }
        
        // Read vendorServices.json file
        JsonObject servicesData = readVendorServices();
        JsonArray allServices = servicesData.getAsJsonArray("services");
        System.out.println("Total services read from file: " + allServices.size());
        
        // Filter services by vendorId
        JsonArray vendorServices = new JsonArray();
        for (int i = 0; i < allServices.size(); i++) {
            JsonObject service = allServices.get(i).getAsJsonObject();
            
            // Only include services for this vendor
            if (service.has("vendorId") && service.get("vendorId").getAsString().equals(vendorId)) {
                vendorServices.add(service);
            }
        }
        
        System.out.println("Services for vendor " + vendorId + ": " + vendorServices.size());
        
        // Send response to client
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(gson.toJson(vendorServices));
            out.flush();
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "add"; // Default action
        }
        
        System.out.println("POST request received with action: " + action);
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject responseJson = new JsonObject();
        
        // Get the vendor ID from the session
        HttpSession session = request.getSession();
        String vendorId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        
        // For testing or direct API calls - use parameter if available
        if (vendorId == null || vendorId.isEmpty()) {
            vendorId = request.getParameter("vendorId");
            if (vendorId == null || vendorId.isEmpty()) {
                vendorId = "V1007"; // Default for testing
            }
            System.out.println("Using vendorId from parameter or default: " + vendorId);
        }
        
        if (username == null || username.isEmpty()) {
            username = "IT24102083"; // Default username
        }
        
        try {
            switch (action) {
                case "add":
                    addService(request, response, out, vendorId, username);
                    break;
                case "edit":
                    editService(request, response, out, vendorId, username);
                    break;
                case "delete":
                    deleteService(request, response, out, vendorId);
                    break;
                default:
                    responseJson.addProperty("status", "error");
                    responseJson.addProperty("message", "Unknown action: " + action);
                    out.print(gson.toJson(responseJson));
            }
        } catch (Exception e) {
            System.err.println("Error processing request: " + e.getMessage());
            e.printStackTrace();
            responseJson.addProperty("status", "error");
            responseJson.addProperty("message", e.getMessage());
            out.print(gson.toJson(responseJson));
        }
    }
    
    private void addService(HttpServletRequest request, HttpServletResponse response, PrintWriter out, 
                            String vendorId, String username) throws Exception {
        System.out.println("Adding new service for vendorId: " + vendorId);
        
        // Read existing services
        JsonObject servicesData = readVendorServices();
        JsonArray services = servicesData.getAsJsonArray("services");
        System.out.println("Existing services count: " + services.size());
        
        // Generate the next service ID (S1001, S1002, etc.)
        String nextServiceId = generateNextServiceId(services);
        System.out.println("Generated serviceId: " + nextServiceId);
        
        // Extract form data
        String serviceName = request.getParameter("serviceName");
        String serviceCategory = request.getParameter("serviceCategory");
        String serviceDescription = request.getParameter("serviceDescription");
        double serviceBasePrice = Double.parseDouble(request.getParameter("serviceBasePrice"));
        
        // Get the new pricing fields
        double serviceDuration = 0;
        int serviceGuestCount = 0;
        String servicePriceModel = "fixed";
        double serviceHourlyRate = 0;
        double servicePerGuestRate = 0;
        
        try {
            if (request.getParameter("serviceDuration") != null && !request.getParameter("serviceDuration").isEmpty()) {
                serviceDuration = Double.parseDouble(request.getParameter("serviceDuration"));
            }
        } catch (Exception e) {
            // Use default if parsing fails
            System.out.println("Failed to parse duration, using default");
        }
        
        try {
            if (request.getParameter("serviceGuestCount") != null && !request.getParameter("serviceGuestCount").isEmpty()) {
                serviceGuestCount = Integer.parseInt(request.getParameter("serviceGuestCount"));
            }
        } catch (Exception e) {
            // Use default if parsing fails
            System.out.println("Failed to parse guest count, using default");
        }
        
        if (request.getParameter("servicePriceModel") != null) {
            servicePriceModel = request.getParameter("servicePriceModel");
        }
        
        try {
            if (request.getParameter("serviceHourlyRate") != null && !request.getParameter("serviceHourlyRate").isEmpty()) {
                serviceHourlyRate = Double.parseDouble(request.getParameter("serviceHourlyRate"));
            }
        } catch (Exception e) {
            // Use default if parsing fails
            System.out.println("Failed to parse hourly rate, using default");
        }
        
        try {
            if (request.getParameter("servicePerGuestRate") != null && !request.getParameter("servicePerGuestRate").isEmpty()) {
                servicePerGuestRate = Double.parseDouble(request.getParameter("servicePerGuestRate"));
            }
        } catch (Exception e) {
            // Use default if parsing fails
            System.out.println("Failed to parse per guest rate, using default");
        }
        
        boolean serviceActive = "active".equals(request.getParameter("serviceStatus"));
        String serviceSeoKeywords = request.getParameter("serviceSeoKeywords");
        boolean serviceFeatured = request.getParameter("serviceFeatured") != null;
        
        System.out.println("Service details: Name: " + serviceName + ", Category: " + serviceCategory + 
                          ", BasePrice: " + serviceBasePrice + ", Active: " + serviceActive);
        
        // Create new service object matching the existing format
        JsonObject newService = new JsonObject();
        newService.addProperty("serviceId", nextServiceId);
        newService.addProperty("vendorId", vendorId);
        newService.addProperty("name", serviceName);
        newService.addProperty("category", serviceCategory);
        newService.addProperty("description", serviceDescription);
        newService.addProperty("basePrice", serviceBasePrice);
        
        // Add new pricing fields
        newService.addProperty("baseDuration", serviceDuration);
        newService.addProperty("baseGuestCount", serviceGuestCount);
        newService.addProperty("priceModel", servicePriceModel);
        newService.addProperty("hourlyRate", serviceHourlyRate);
        newService.addProperty("perGuestRate", servicePerGuestRate);
        
        newService.addProperty("status", serviceActive ? "active" : "inactive");
        newService.addProperty("isFeatured", serviceFeatured);
        
        if (serviceSeoKeywords != null && !serviceSeoKeywords.trim().isEmpty()) {
            newService.addProperty("seoKeywords", serviceSeoKeywords);
        }
        
        // Handle customization options with new enhanced fields
        String[] optionNames = request.getParameterValues("customizationOptionsName[]");
        String[] optionDescs = request.getParameterValues("customizationOptionsDesc[]");
        String[] optionPrices = request.getParameterValues("customizationOptionsPrice[]");
        
        if (optionNames != null && optionNames.length > 0) {
            JsonArray options = new JsonArray();
            
            for (int i = 0; i < optionNames.length; i++) {
                String name = optionNames[i];
                
                if (name != null && !name.trim().isEmpty()) {
                    JsonObject optionObj = new JsonObject();
                    optionObj.addProperty("optionId", "OPT" + nextServiceId.substring(1) + (i+1));
                    optionObj.addProperty("name", name);
                    
                    // Add description if available
                    String desc = (optionDescs != null && i < optionDescs.length) ? optionDescs[i] : "";
                    optionObj.addProperty("description", desc);
                    
                    // Add price if available
                    double price = 0;
                    if (optionPrices != null && i < optionPrices.length) {
                        try {
                            price = Double.parseDouble(optionPrices[i]);
                        } catch (NumberFormatException e) {
                            // Use default if parsing fails
                        }
                    }
                    optionObj.addProperty("price", price);
                    
                    options.add(optionObj);
                }
            }
            
            if (options.size() > 0) {
                newService.add("additionalOptions", options);
            }
        }
        
        // Handle image uploads - name them with just the serviceId as requested
        String iconPath = null;
        String backgroundPath = null;
        
        try {
            // Process icon image
            Part iconImagePart = request.getPart("serviceIconImage");
            if (iconImagePart != null && iconImagePart.getSize() > 0) {
                String fileName = nextServiceId + getFileExtension(iconImagePart); // Just serviceId
                String filePath = new File(iconsBasePath, fileName).getAbsolutePath();
                
                // Save the file to disk
                try (InputStream input = iconImagePart.getInputStream()) {
                    Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                    System.out.println("Icon image saved to: " + filePath);
                }
                
                // Set the relative path for the web application
                iconPath = "/resources/vendor/serviceImages/" + fileName;
            }
            
            // Process background image
            Part backgroundImagePart = request.getPart("serviceBackgroundImage");
            if (backgroundImagePart != null && backgroundImagePart.getSize() > 0) {
                String fileName = nextServiceId + "_bg" + getFileExtension(backgroundImagePart); // serviceId_bg
                String filePath = new File(backgroundsBasePath, fileName).getAbsolutePath();
                
                // Save the file to disk
                try (InputStream input = backgroundImagePart.getInputStream()) {
                    Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                    System.out.println("Background image saved to: " + filePath);
                }
                
                // Set the relative path for the web application
                backgroundPath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\resources\\resources\\vendor\\backgroundImages" + fileName;
            }
        } catch (Exception e) {
            // Log error but continue processing
            System.err.println("Error handling image uploads: " + e.getMessage());
            e.printStackTrace();
        }
        
        // Set default image paths if uploads failed
        if (iconPath == null) {
            iconPath = "/assets/images/services/icons/default-profile.jpg";
        }
        if (backgroundPath == null) {
            backgroundPath = "/assets/images/services/backgrounds/default-background.jpg";
        }
        
        // Create images object to match the existing format
        JsonObject images = new JsonObject();
        images.addProperty("icon", iconPath);
        images.addProperty("background", backgroundPath);
        newService.add("images", images);
        
        // Add creation timestamp
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String currentDateTime = sdf.format(new Date());
        newService.addProperty("createdAt", currentDateTime);
        newService.addProperty("updatedAt", currentDateTime);
        
        // Add new service to the array
        services.add(newService);
        System.out.println("New service added to the array. Services count: " + services.size());
        
        // IMPORTANT: Write updated data back to vendorServices.json
        boolean writeSuccess = writeVendorServices(servicesData);
        if (!writeSuccess) {
            throw new IOException("Failed to write services to file");
        }
        
        // Update the service category count in service-categories.json
        updateServiceCategoryCount(serviceCategory, 1);
        
        // Update the vendor's serviceIds in vendors.json
        updateVendorServiceIds(vendorId, nextServiceId, true);
        
        // Send success response
        JsonObject responseJson = new JsonObject();
        responseJson.addProperty("status", "success");
        responseJson.addProperty("message", "Service added successfully");
        responseJson.add("service", newService);
        out.print(gson.toJson(responseJson));
    }
    
    private String generateNextServiceId(JsonArray services) {
        int maxId = 1000; // Start with S1001
        
        // Find the highest existing service ID
        for (int i = 0; i < services.size(); i++) {
            JsonObject service = services.get(i).getAsJsonObject();
            if (service.has("serviceId")) {
                String serviceId = service.get("serviceId").getAsString();
                if (serviceId.startsWith("S") && serviceId.length() > 1) {
                    try {
                        int idNum = Integer.parseInt(serviceId.substring(1));
                        if (idNum > maxId) {
                            maxId = idNum;
                        }
                    } catch (NumberFormatException e) {
                        // Ignore non-numeric IDs
                    }
                }
            }
        }
        
        // Create the next service ID by incrementing by 1
        return "S" + (maxId + 1);
    }
    
    private void editService(HttpServletRequest request, HttpServletResponse response, PrintWriter out,
                            String vendorId, String username) throws Exception {
        String serviceId = request.getParameter("serviceId");
        System.out.println("Editing service: " + serviceId + " for vendor: " + vendorId);
        
        // Read existing services
        JsonObject servicesData = readVendorServices();
        JsonArray services = servicesData.getAsJsonArray("services");
        JsonObject updatedService = null;
        
        // Store the old category to update counts later
        String oldCategory = null;
        
        // Find and update the service
        for (int i = 0; i < services.size(); i++) {
            JsonObject service = services.get(i).getAsJsonObject();
            
            if (service.has("serviceId") && service.get("serviceId").getAsString().equals(serviceId)) {
                // Make sure this service belongs to the vendor
                if (service.has("vendorId") && !service.get("vendorId").getAsString().equals(vendorId)) {
                    // This service doesn't belong to this vendor
                    JsonObject responseJson = new JsonObject();
                    responseJson.addProperty("status", "error");
                    responseJson.addProperty("message", "You don't have permission to edit this service");
                    out.print(gson.toJson(responseJson));
                    return;
                }
                
                // Save the old category
                if (service.has("category")) {
                    oldCategory = service.get("category").getAsString();
                }
                
                // Update service fields
                service.addProperty("name", request.getParameter("serviceName"));
                
                // Check if category has changed
                String newCategory = request.getParameter("serviceCategory");
                boolean categoryChanged = (oldCategory != null && !oldCategory.equals(newCategory));
                service.addProperty("category", newCategory);
                
                service.addProperty("description", request.getParameter("serviceDescription"));
                service.addProperty("basePrice", Double.parseDouble(request.getParameter("serviceBasePrice")));
                service.addProperty("status", "active".equals(request.getParameter("serviceStatus")) ? "active" : "inactive");
                service.addProperty("isFeatured", request.getParameter("serviceFeatured") != null);
                
                // Update pricing fields
                try {
                    if (request.getParameter("serviceDuration") != null && !request.getParameter("serviceDuration").isEmpty()) {
                        service.addProperty("baseDuration", Double.parseDouble(request.getParameter("serviceDuration")));
                    } else {
                        service.addProperty("baseDuration", 0);
                    }
                } catch (Exception e) {
                    service.addProperty("baseDuration", 0);
                }
                
                try {
                    if (request.getParameter("serviceGuestCount") != null && !request.getParameter("serviceGuestCount").isEmpty()) {
                        service.addProperty("baseGuestCount", Integer.parseInt(request.getParameter("serviceGuestCount")));
                    } else {
                        service.addProperty("baseGuestCount", 0);
                    }
                } catch (Exception e) {
                    service.addProperty("baseGuestCount", 0);
                }
                
                // Set price model
                if (request.getParameter("servicePriceModel") != null) {
                    service.addProperty("priceModel", request.getParameter("servicePriceModel"));
                } else {
                    service.addProperty("priceModel", "fixed");
                }
                
                // Add hourly rate
                try {
                    if (request.getParameter("serviceHourlyRate") != null && !request.getParameter("serviceHourlyRate").isEmpty()) {
                        service.addProperty("hourlyRate", Double.parseDouble(request.getParameter("serviceHourlyRate")));
                    } else {
                        service.addProperty("hourlyRate", 0);
                    }
                } catch (Exception e) {
                    service.addProperty("hourlyRate", 0);
                }
                
                // Add per guest rate
                try {
                    if (request.getParameter("servicePerGuestRate") != null && !request.getParameter("servicePerGuestRate").isEmpty()) {
                        service.addProperty("perGuestRate", Double.parseDouble(request.getParameter("servicePerGuestRate")));
                    } else {
                        service.addProperty("perGuestRate", 0);
                    }
                } catch (Exception e) {
                    service.addProperty("perGuestRate", 0);
                }
                
                String serviceSeoKeywords = request.getParameter("serviceSeoKeywords");
                if (serviceSeoKeywords != null && !serviceSeoKeywords.trim().isEmpty()) {
                    service.addProperty("seoKeywords", serviceSeoKeywords);
                } else if (service.has("seoKeywords")) {
                    service.remove("seoKeywords");
                }
                
                // Handle enhanced customization options
                String[] optionNames = request.getParameterValues("customizationOptionsName[]");
                String[] optionDescs = request.getParameterValues("customizationOptionsDesc[]");
                String[] optionPrices = request.getParameterValues("customizationOptionsPrice[]");
                
                if (optionNames != null && optionNames.length > 0) {
                    JsonArray options = new JsonArray();
                    
                    for (int j = 0; j < optionNames.length; j++) {
                        String name = optionNames[j];
                        
                        if (name != null && !name.trim().isEmpty()) {
                            JsonObject optionObj = new JsonObject();
                            optionObj.addProperty("optionId", "OPT" + serviceId.substring(1) + (j+1));
                            optionObj.addProperty("name", name);
                            
                            // Add description if available
                            String desc = (optionDescs != null && j < optionDescs.length) ? optionDescs[j] : "";
                            optionObj.addProperty("description", desc);
                            
                            // Add price if available
                            double price = 0;
                            if (optionPrices != null && j < optionPrices.length) {
                                try {
                                    price = Double.parseDouble(optionPrices[j]);
                                } catch (NumberFormatException e) {
                                    // Use default if parsing fails
                                }
                            }
                            optionObj.addProperty("price", price);
                            
                            options.add(optionObj);
                        }
                    }
                    
                    if (options.size() > 0) {
                        service.add("additionalOptions", options);
                    } else if (service.has("additionalOptions")) {
                        service.remove("additionalOptions");
                    }
                } else if (service.has("additionalOptions")) {
                    // Keep existing additionalOptions if present and no new ones provided
                }
                
                // Handle image uploads - use serviceId as filename
                try {
                    // Process icon image
                    Part iconImagePart = request.getPart("serviceIconImage");
                    if (iconImagePart != null && iconImagePart.getSize() > 0) {
                        String fileName = serviceId + getFileExtension(iconImagePart); // Just serviceId
                        String filePath = new File(iconsBasePath, fileName).getAbsolutePath();
                        
                        // Save the file to disk
                        try (InputStream input = iconImagePart.getInputStream()) {
                            Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                        }
                        
                        // Update the image paths
                        JsonObject images = service.has("images") ? 
                                service.getAsJsonObject("images") : new JsonObject();
                        images.addProperty("icon", "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\resources\\resources\\vendor\\serviceImages" + fileName);
                        service.add("images", images);
                    }
                    
                    // Process background image
                    Part backgroundImagePart = request.getPart("serviceBackgroundImage");
                    if (backgroundImagePart != null && backgroundImagePart.getSize() > 0) {
                        String fileName = serviceId + "_bg" + getFileExtension(backgroundImagePart); // serviceId_bg
                        String filePath = new File(backgroundsBasePath, fileName).getAbsolutePath();
                        
                        // Save the file to disk
                        try (InputStream input = backgroundImagePart.getInputStream()) {
                            Files.copy(input, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                        }
                        
                        // Update the image paths
                        JsonObject images = service.has("images") ? 
                                service.getAsJsonObject("images") : new JsonObject();
                        images.addProperty("background", "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\resources\\resources\\vendor\\backgroundImages" + fileName);
                        service.add("images", images);
                    }
                } catch (Exception e) {
                    // Log error but continue processing
                    System.err.println("Error processing image uploads: " + e.getMessage());
                    e.printStackTrace();
                }
                
                // Update timestamp
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                service.addProperty("updatedAt", sdf.format(new Date()));
                
                updatedService = service;
                
                // If category changed, update service category counts
                if (categoryChanged) {
                    updateServiceCategoryCount(oldCategory, -1); // Decrement old category
                    updateServiceCategoryCount(newCategory, 1);  // Increment new category
                }
                
                break;
            }
        }
        
        JsonObject responseJson = new JsonObject();
        if (updatedService != null) {
            // Write updated data back to vendorServices.json
            boolean writeSuccess = writeVendorServices(servicesData);
            if (!writeSuccess) {
                responseJson.addProperty("status", "error");
                responseJson.addProperty("message", "Failed to save service update to file");
                out.print(gson.toJson(responseJson));
                return;
            }
            
            // Send success response
            responseJson.addProperty("status", "success");
            responseJson.addProperty("message", "Service updated successfully");
            responseJson.add("service", updatedService);
        } else {
            // Service not found
            responseJson.addProperty("status", "error");
            responseJson.addProperty("message", "Service not found");
        }
        out.print(gson.toJson(responseJson));
    }
    
    private void deleteService(HttpServletRequest request, HttpServletResponse response, PrintWriter out, 
                              String vendorId) throws Exception {
        String serviceId = request.getParameter("serviceId");
        System.out.println("Deleting service: " + serviceId + " for vendor: " + vendorId);
        
        // Read existing services
        JsonObject servicesData = readVendorServices();
        JsonArray services = servicesData.getAsJsonArray("services");
        boolean serviceFound = false;
        String serviceCategory = null;
        
        // Find and remove the service
        for (int i = 0; i < services.size(); i++) {
            JsonObject service = services.get(i).getAsJsonObject();
            if (service.has("serviceId") && service.get("serviceId").getAsString().equals(serviceId)) {
                // Make sure this service belongs to the vendor
                if (service.has("vendorId") && !service.get("vendorId").getAsString().equals(vendorId)) {
                    // This service doesn't belong to this vendor
                    JsonObject responseJson = new JsonObject();
                    responseJson.addProperty("status", "error");
                    responseJson.addProperty("message", "You don't have permission to delete this service");
                    out.print(gson.toJson(responseJson));
                    return;
                }
                
                // Save the category before removing
                if (service.has("category")) {
                    serviceCategory = service.get("category").getAsString();
                }
                
                services.remove(i);
                serviceFound = true;
                break;
            }
        }
        
        JsonObject responseJson = new JsonObject();
        if (serviceFound) {
            // Write updated data back to vendorServices.json
            boolean writeSuccess = writeVendorServices(servicesData);
            if (!writeSuccess) {
                responseJson.addProperty("status", "error");
                responseJson.addProperty("message", "Failed to save service deletion to file");
                out.print(gson.toJson(responseJson));
                return;
            }
            
            // Update service category count
            if (serviceCategory != null) {
                updateServiceCategoryCount(serviceCategory, -1);
            }
            
            // Remove serviceId from vendor
            updateVendorServiceIds(vendorId, serviceId, false);
            
            // Send success response
            responseJson.addProperty("status", "success");
            responseJson.addProperty("message", "Service deleted successfully");
        } else {
            // Service not found
            responseJson.addProperty("status", "error");
            responseJson.addProperty("message", "Service not found");
        }
        out.print(gson.toJson(responseJson));
    }
    
    // Helper method to get file extension from a Part
    private String getFileExtension(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        
        for (String item : items) {
            if (item.trim().startsWith("filename")) {
                String fileName = item.substring(item.indexOf("=") + 2, item.length() - 1);
                int dotIndex = fileName.lastIndexOf(".");
                if (dotIndex > 0) {
                    return fileName.substring(dotIndex);
                }
            }
        }
        
        // Default extension based on content type
        String contentType = part.getContentType();
        if (contentType != null) {
            if (contentType.contains("image/jpeg") || contentType.contains("image/jpg")) {
                return ".jpg";
            } else if (contentType.contains("image/png")) {
                return ".png";
            } else if (contentType.contains("image/gif")) {
                return ".gif";
            }
        }
        
        // Default extension if none found
        return ".jpg";
    }
    
    // Helper method to read data from vendorServices.json - FIXED METHOD
    private JsonObject readVendorServices() {
        JsonObject servicesData = new JsonObject();
        File jsonFile = new File(vendorServicesJsonPath);
        
        if (jsonFile.exists()) {
            try {
                // Read the entire file content into a string first
                String fileContent = new String(Files.readAllBytes(jsonFile.toPath()));
                
                // Check if the file is empty
                if (fileContent.trim().isEmpty()) {
                    // File is empty, return an empty object with services array
                    System.out.println("vendorServices.json is empty");
                    servicesData.add("services", new JsonArray());
                    return servicesData;
                }
                
                // Parse JSON string
                JsonElement parsed = JsonParser.parseString(fileContent);
                if (parsed.isJsonObject()) {
                    servicesData = parsed.getAsJsonObject();
                    
                    // Ensure it has a services array
                    if (!servicesData.has("services")) {
                        servicesData.add("services", new JsonArray());
                    }
                } else if (parsed.isJsonArray()) {
                    // If it's an array, wrap it in an object
                    servicesData = new JsonObject();
                    servicesData.add("services", parsed.getAsJsonArray());
                }
                
                System.out.println("Read " + servicesData.getAsJsonArray("services").size() + 
                                  " services from vendorServices.json");
            } catch (Exception e) {
                System.err.println("Error reading vendorServices.json: " + e.getMessage());
                e.printStackTrace();
                // Return empty object on error
                servicesData = new JsonObject();
                servicesData.add("services", new JsonArray());
            }
        } else {
            System.out.println("vendorServices.json does not exist at path: " + vendorServicesJsonPath);
            // Create an empty services structure
            servicesData = new JsonObject();
            servicesData.add("services", new JsonArray());
            
            // Try to create an empty file
            try {
                jsonFile.getParentFile().mkdirs();
                try (FileWriter writer = new FileWriter(jsonFile)) {
                    writer.write(gson.toJson(servicesData));
                }
                System.out.println("Created new empty vendorServices.json");
            } catch (IOException e) {
                System.err.println("Failed to create vendorServices.json: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        return servicesData;
    }
    
    // Helper method to write data to vendorServices.json
    private boolean writeVendorServices(JsonObject servicesData) {
        System.out.println("Writing " + servicesData.getAsJsonArray("services").size() + 
                          " services to file: " + vendorServicesJsonPath);
        
        try {
            // Ensure directory exists
            File file = new File(vendorServicesJsonPath);
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            
            // Direct write to the file
            try (FileWriter writer = new FileWriter(file)) {
                gson.toJson(servicesData, writer);
                writer.flush();
                
                System.out.println("Successfully wrote " + servicesData.getAsJsonArray("services").size() + 
                                  " services to file. Size: " + file.length() + " bytes");
                return true;
            }
        } catch (IOException e) {
            System.err.println("Error writing services to file: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Update the service count for a category in service-categories.json
     * @param category The category name
     * @param increment The amount to increment by (1 for add, -1 for delete)
     */
    private void updateServiceCategoryCount(String category, int increment) {
        if (category == null || category.isEmpty()) {
            return;
        }
        
        System.out.println("Updating category count for '" + category + "' by " + increment);
        
        try {
            // Read the service-categories.json file
            JsonArray categories = new JsonArray();
            File file = new File(serviceCategoriesJsonPath);
            
            if (file.exists()) {
                try {
                    // Read the entire file content
                    String fileContent = new String(Files.readAllBytes(file.toPath()));
                    if (!fileContent.trim().isEmpty()) {
                        categories = JsonParser.parseString(fileContent).getAsJsonArray();
                    }
                } catch (Exception e) {
                    System.err.println("Error reading categories file: " + e.getMessage());
                    e.printStackTrace();
                    // If parsing fails, create a new array
                    categories = new JsonArray();
                }
            }
            
            // Find the category and update its count
            boolean categoryExists = false;
            
            for (int i = 0; i < categories.size(); i++) {
                JsonObject categoryObj = categories.get(i).getAsJsonObject();
                if (categoryObj.has("name") && categoryObj.get("name").getAsString().equals(category)) {
                    int currentCount = categoryObj.has("serviceCount") ? 
                            categoryObj.get("serviceCount").getAsInt() : 0;
                    
                    // Update count (ensure it doesn't go below 0)
                    int newCount = Math.max(0, currentCount + increment);
                    categoryObj.addProperty("serviceCount", newCount);
                    
                    categoryExists = true;
                    break;
                }
            }
            
            // If category doesn't exist, add it (only for new services)
            if (!categoryExists && increment > 0) {
                JsonObject newCategory = new JsonObject();
                newCategory.addProperty("name", category);
                newCategory.addProperty("active", true);
                newCategory.addProperty("serviceCount", 1);
                categories.add(newCategory);
            }
            
            // Write updated data back to service-categories.json
            try (FileWriter writer = new FileWriter(file)) {
                gson.toJson(categories, writer);
                writer.flush();
            }
            
        } catch (Exception e) {
            System.err.println("Error updating service category count: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Update the serviceIds array for a vendor in vendors.json
     * @param vendorId The vendor ID
     * @param serviceId The service ID
     * @param add True to add, false to remove
     */
    private void updateVendorServiceIds(String vendorId, String serviceId, boolean add) {
        if (vendorId == null || vendorId.isEmpty() || serviceId == null || serviceId.isEmpty()) {
            return;
        }
        
        System.out.println((add ? "Adding" : "Removing") + " service " + serviceId + " " + 
                          (add ? "to" : "from") + " vendor " + vendorId);
        
        try {
            // Read the vendors.json file
            JsonObject vendorsJson = new JsonObject();
            JsonArray vendors = new JsonArray();
            File file = new File(vendorsJsonPath);
            
            if (file.exists()) {
                try {
                    // Read the file content
                    String fileContent = new String(Files.readAllBytes(file.toPath()));
                    if (!fileContent.trim().isEmpty()) {
                        vendorsJson = JsonParser.parseString(fileContent).getAsJsonObject();
                        if (vendorsJson.has("vendors")) {
                            vendors = vendorsJson.getAsJsonArray("vendors");
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error reading vendors file: " + e.getMessage());
                    e.printStackTrace();
                    // If parsing fails, create new structure
                    vendorsJson = new JsonObject();
                    vendors = new JsonArray();
                    vendorsJson.add("vendors", vendors);
                }
            } else {
                vendorsJson.add("vendors", vendors);
            }
            
            // Find the vendor and update serviceIds
            boolean vendorFound = false;
            
            for (int i = 0; i < vendors.size(); i++) {
                JsonObject vendor = vendors.get(i).getAsJsonObject();
                if (vendor.has("userId") && vendor.get("userId").getAsString().equals(vendorId)) {
                    JsonArray serviceIds;
                    
                    // Get existing serviceIds or create new array
                    if (vendor.has("serviceIds")) {
                        serviceIds = vendor.getAsJsonArray("serviceIds");
                    } else {
                        serviceIds = new JsonArray();
                    }
                    
                    if (add) {
                        // Add serviceId if it doesn't already exist
                        boolean exists = false;
                        for (int j = 0; j < serviceIds.size(); j++) {
                            if (serviceIds.get(j).getAsString().equals(serviceId)) {
                                exists = true;
                                break;
                            }
                        }
                        
                        if (!exists) {
                            serviceIds.add(serviceId);
                        }
                    } else {
                        // Remove serviceId if it exists
                        JsonArray updatedServiceIds = new JsonArray();
                        for (int j = 0; j < serviceIds.size(); j++) {
                            if (!serviceIds.get(j).getAsString().equals(serviceId)) {
                                updatedServiceIds.add(serviceIds.get(j));
                            }
                        }
                        serviceIds = updatedServiceIds;
                    }
                    
                    // Update vendor with new serviceIds array
                    vendor.add("serviceIds", serviceIds);
                    
                    // Update timestamp
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    vendor.addProperty("updatedAt", sdf.format(new Date()));
                    
                    vendorFound = true;
                    break;
                }
            }
            
            if (!vendorFound) {
                System.out.println("Vendor " + vendorId + " not found in vendors.json");
                return;
            }
            
            // Write updated data back to vendors.json
            try (FileWriter writer = new FileWriter(file)) {
                gson.toJson(vendorsJson, writer);
                writer.flush();
                System.out.println("Successfully updated vendor serviceIds in vendors.json");
            }
            
        } catch (Exception e) {
            System.err.println("Error updating vendor serviceIds: " + e.getMessage());
            e.printStackTrace();
        }
    }
}