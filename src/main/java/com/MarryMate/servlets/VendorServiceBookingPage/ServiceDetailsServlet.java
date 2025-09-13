package com.MarryMate.servlets.VendorServiceBookingPage;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * Servlet implementation class ServiceDetailsServlet
 * Retrieves and returns detailed service information for the modal popup
 * with enhanced compatibility and price model info
 * 
 * Current Date: 2025-05-16
 * Current User: IT24102137
 */
@WebServlet("/ServiceDetailsServlet")
public class ServiceDetailsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VENDOR_SERVICES_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendorServices.json";
    private static final String VENDORS_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
    private static final String REVIEWS_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\reviews.json";
    private static final String BOOKINGS_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\bookings.json";
    private static final Gson gson = new Gson();
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public ServiceDetailsServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String serviceId = request.getParameter("serviceId");
        
        // Get user ID from session if available (for compatibility info)
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        
        if (serviceId == null || serviceId.isEmpty()) {
            sendErrorResponse(response, "Service ID is required");
            return;
        }
        
        // Get service details
        JsonObject serviceDetails = getServiceDetails(serviceId);
        
        if (serviceDetails == null) {
            sendErrorResponse(response, "Service not found");
            return;
        }
        
        // Get vendor details if available
        if (serviceDetails.has("vendorId")) {
            String vendorId = serviceDetails.get("vendorId").getAsString();
            JsonObject vendorDetails = getVendorDetails(vendorId);
            
            if (vendorDetails != null) {
                serviceDetails.add("vendor", vendorDetails);
            }
        }
        
        // Get reviews for this service
        List<JsonObject> reviews = getServiceReviews(serviceId);
        JsonArray reviewsArray = new JsonArray();
        
        for (JsonObject review : reviews) {
            reviewsArray.add(review);
        }
        
        serviceDetails.add("reviews", reviewsArray);
        
        // Calculate average rating
        double averageRating = calculateAverageRating(reviews);
        serviceDetails.addProperty("averageRating", averageRating);
        
        // Add pricing model details for better UI display
        enhancePricingModelInfo(serviceDetails);
        
        // Add booking compatibility info if user is logged in
        if (userId != null) {
            addServiceCompatibilityInfo(serviceDetails, userId);
        }
        
        // Return the complete service details
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(serviceDetails));
        out.flush();
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Add enhanced pricing model information to the service details
     */
    private void enhancePricingModelInfo(JsonObject serviceDetails) {
        // Create a pricing info object with user-friendly descriptions
        JsonObject pricingInfo = new JsonObject();
        
        String priceModel = serviceDetails.has("priceModel") ? 
                serviceDetails.get("priceModel").getAsString() : "fixed";
        
        double basePrice = serviceDetails.has("basePrice") ? 
                serviceDetails.get("basePrice").getAsDouble() : 0.0;
                
        pricingInfo.addProperty("model", priceModel);
        pricingInfo.addProperty("basePrice", basePrice);
        
        // Add model-specific details
        switch (priceModel) {
            case "hourly":
                double baseDuration = serviceDetails.has("baseDuration") ? 
                        serviceDetails.get("baseDuration").getAsDouble() : 0;
                double hourlyRate = serviceDetails.has("hourlyRate") ? 
                        serviceDetails.get("hourlyRate").getAsDouble() : 0;
                
                pricingInfo.addProperty("baseDuration", baseDuration);
                pricingInfo.addProperty("hourlyRate", hourlyRate);
                pricingInfo.addProperty("description", 
                        String.format("Base price includes %s hours. Additional hours charged at $%.2f per hour.", 
                                baseDuration, hourlyRate));
                break;
                
            case "per_guest":
                int baseGuestCount = serviceDetails.has("baseGuestCount") ? 
                        serviceDetails.get("baseGuestCount").getAsInt() : 0;
                double perGuestRate = serviceDetails.has("perGuestRate") ? 
                        serviceDetails.get("perGuestRate").getAsDouble() : 0;
                
                pricingInfo.addProperty("baseGuestCount", baseGuestCount);
                pricingInfo.addProperty("perGuestRate", perGuestRate);
                pricingInfo.addProperty("description", 
                        String.format("Base price includes up to %d guests. Additional guests charged at $%.2f per person.", 
                                baseGuestCount, perGuestRate));
                break;
                
            case "package":
                pricingInfo.addProperty("description", 
                        "Package price includes all listed services and features.");
                break;
                
            case "fixed":
            default:
                pricingInfo.addProperty("description", 
                        "Fixed price for this service regardless of duration or guest count.");
                break;
        }
        
        // Add pricing info to service details
        serviceDetails.add("pricingInfo", pricingInfo);
    }
    
    /**
     * Add information about compatibility with user's existing bookings
     */
    private void addServiceCompatibilityInfo(JsonObject serviceDetails, String userId) {
        try {
            // Get user's existing bookings to check compatibility
            List<JsonObject> userBookings = getUserActiveBookings(userId);
            JsonArray compatibilityInfo = new JsonArray();
            
            // Service category for compatibility checks
            String serviceCategory = serviceDetails.has("category") ? 
                    serviceDetails.get("category").getAsString() : "";
            
            // Non-compatible categories (can only have one of each)
            String[] exclusiveCategories = {"photography", "videography", "venue"};
            boolean isExclusiveCategory = false;
            
            for (String category : exclusiveCategories) {
                if (category.equalsIgnoreCase(serviceCategory)) {
                    isExclusiveCategory = true;
                    break;
                }
            }
            
            // Check each booking for compatibility
            for (JsonObject booking : userBookings) {
                JsonObject bookingCompatibility = new JsonObject();
                bookingCompatibility.addProperty("bookingId", booking.get("bookingId").getAsString());
                
                // Default to compatible
                boolean isCompatible = true;
                String incompatibilityReason = "";
                
                // Check for category conflicts if this is an exclusive category
                if (isExclusiveCategory && booking.has("bookedServices")) {
                    JsonArray bookedServices = booking.getAsJsonArray("bookedServices");
                    
                    for (JsonElement serviceElement : bookedServices) {
                        JsonObject bookedService = serviceElement.getAsJsonObject();
                        String bookedServiceId = bookedService.get("serviceId").getAsString();
                        
                        // Get category of booked service
                        JsonObject bookedServiceDetails = getServiceDetails(bookedServiceId);
                        if (bookedServiceDetails != null && bookedServiceDetails.has("category")) {
                            String bookedCategory = bookedServiceDetails.get("category").getAsString();
                            
                            // If same category already booked, mark as incompatible
                            if (bookedCategory.equalsIgnoreCase(serviceCategory)) {
                                isCompatible = false;
                                incompatibilityReason = "This booking already has a " + serviceCategory + " service";
                                break;
                            }
                        }
                    }
                }
                
                bookingCompatibility.addProperty("compatible", isCompatible);
                if (!isCompatible) {
                    bookingCompatibility.addProperty("reason", incompatibilityReason);
                }
                
                compatibilityInfo.add(bookingCompatibility);
            }
            
            // Add compatibility info to service details
            serviceDetails.add("bookingCompatibility", compatibilityInfo);
            
        } catch (Exception e) {
            System.err.println("Error adding compatibility info: " + e.getMessage());
        }
    }
    
    /**
     * Get active bookings for a user
     */
    private List<JsonObject> getUserActiveBookings(String userId) {
        List<JsonObject> userBookings = new ArrayList<>();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(BOOKINGS_PATH))) {
            JsonObject bookingsData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray allBookings = bookingsData.getAsJsonArray("bookings");
            
            for (JsonElement bookingElement : allBookings) {
                JsonObject booking = bookingElement.getAsJsonObject();
                
                // Check if booking belongs to user and is active
                if (booking.has("userId") && booking.get("userId").getAsString().equals(userId)) {
                    String status = booking.has("status") ? booking.get("status").getAsString() : "";
                    if ("confirmed".equals(status) || "pending".equals(status)) {
                        userBookings.add(booking);
                    }
                }
            }
        } catch (IOException e) {
            System.err.println("Error loading bookings: " + e.getMessage());
        }
        
        return userBookings;
    }
    
    /**
     * Get service details by service ID
     */
    private JsonObject getServiceDetails(String serviceId) {
        try (BufferedReader reader = new BufferedReader(new FileReader(VENDOR_SERVICES_PATH))) {
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray servicesArray = jsonData.getAsJsonArray("services");
            
            for (JsonElement serviceElement : servicesArray) {
                JsonObject service = serviceElement.getAsJsonObject();
                
                if (service.has("serviceId") && 
                    service.get("serviceId").getAsString().equals(serviceId)) {
                    return service;
                }
            }
            
        } catch (IOException e) {
            System.err.println("Error loading service details: " + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * Get vendor details by vendor ID
     */
    private JsonObject getVendorDetails(String vendorId) {
        try (BufferedReader reader = new BufferedReader(new FileReader(VENDORS_PATH))) {
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray vendorsArray = jsonData.getAsJsonArray("vendors");
            
            for (JsonElement vendorElement : vendorsArray) {
                JsonObject vendor = vendorElement.getAsJsonObject();
                
                if (vendor.has("userId") && 
                    vendor.get("userId").getAsString().equals(vendorId)) {
                    // Create a new object with only the needed properties
                    JsonObject vendorDetails = new JsonObject();
                    vendorDetails.addProperty("userId", vendor.get("userId").getAsString());
                    
                    if (vendor.has("businessName")) {
                        vendorDetails.addProperty("businessName", vendor.get("businessName").getAsString());
                    }
                    
                    if (vendor.has("contactName")) {
                        vendorDetails.addProperty("contactName", vendor.get("contactName").getAsString());
                    }
                    
                    if (vendor.has("description")) {
                        vendorDetails.addProperty("description", vendor.get("description").getAsString());
                    }
                    
                    if (vendor.has("profilePictureUrl")) {
                        vendorDetails.addProperty("profilePictureUrl", vendor.get("profilePictureUrl").getAsString());
                    }
                    
                    if (vendor.has("rating")) {
                        vendorDetails.addProperty("rating", vendor.get("rating").getAsDouble());
                    }
                    
                    if (vendor.has("reviewCount")) {
                        vendorDetails.addProperty("reviewCount", vendor.get("reviewCount").getAsInt());
                    }
                    
                    if (vendor.has("phone")) {
                        vendorDetails.addProperty("phone", vendor.get("phone").getAsString());
                    }
                    
                    if (vendor.has("email")) {
                        vendorDetails.addProperty("email", vendor.get("email").getAsString());
                    }
                    
                    if (vendor.has("websiteUrl")) {
                        vendorDetails.addProperty("websiteUrl", vendor.get("websiteUrl").getAsString());
                    }
                    
                    return vendorDetails;
                }
            }
            
        } catch (IOException e) {
            System.err.println("Error loading vendor details: " + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * Get reviews for a specific service
     */
    private List<JsonObject> getServiceReviews(String serviceId) {
        List<JsonObject> serviceReviews = new ArrayList<>();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(REVIEWS_PATH))) {
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray reviewsArray = jsonData.getAsJsonArray("reviews");
            
            for (JsonElement reviewElement : reviewsArray) {
                JsonObject review = reviewElement.getAsJsonObject();
                
                if (review.has("serviceId") && 
                    review.get("serviceId").getAsString().equals(serviceId) &&
                    review.has("status") && 
                    review.get("status").getAsString().equalsIgnoreCase("published")) {
                    serviceReviews.add(review);
                }
            }
            
        } catch (IOException e) {
            System.err.println("Error loading service reviews: " + e.getMessage());
        }
        
        return serviceReviews;
    }
    
    /**
     * Calculate average rating from reviews
     */
    private double calculateAverageRating(List<JsonObject> reviews) {
        if (reviews == null || reviews.isEmpty()) {
            return 0.0;
        }
        
        double totalRating = 0.0;
        
        for (JsonObject review : reviews) {
            if (review.has("rating")) {
                totalRating += review.get("rating").getAsDouble();
            }
        }
        
        return totalRating / reviews.size();
    }
    
    /**
     * Send error response to client
     */
    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        
        JsonObject errorResponse = new JsonObject();
        errorResponse.addProperty("error", true);
        errorResponse.addProperty("message", message);
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(errorResponse));
        out.flush();
    }
}