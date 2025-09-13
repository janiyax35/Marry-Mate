package com.MarryMate.servlets.VendorServiceBookingPage;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * Servlet implementation class BookServiceServlet
 * Processes service booking requests and handles adding services to existing bookings
 * or creating new bookings with enhanced guest pricing and booking details features
 * 
 * Current Date: 2025-05-16
 * Current User: IT24102137
 */
@WebServlet("/BookServiceServlet")
public class BookServiceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String BOOKINGS_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\bookings.json";
    private static final String SERVICES_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendorServices.json";
    private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public BookServiceServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        // Get the booking ID from request parameter
        String bookingId = request.getParameter("bookingId");
        String action = request.getParameter("action");
        
        // Get the session and check if the user is logged in
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        
        // If not logged in, return error response
        if (userId == null || username == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "You must be logged in to access booking details");
            jsonResponse.addProperty("redirect", "login.jsp");
            out.print(gson.toJson(jsonResponse));
            out.flush();
            return;
        }
        
        // If action is "getBookingDetails", fetch and return the booking details
        if ("getBookingDetails".equals(action) && bookingId != null && !bookingId.isEmpty()) {
            JsonObject bookingDetails = getBookingDetails(bookingId, userId);
            
            if (bookingDetails != null) {
                jsonResponse.addProperty("success", true);
                jsonResponse.add("bookingDetails", bookingDetails);
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Booking not found or you don't have access to it");
            }
            
            out.print(gson.toJson(jsonResponse));
            out.flush();
            return;
        }
        
        // Default action - redirect to vendor services page
        response.sendRedirect(request.getContextPath() + "/VendorServicesServlet");
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();
        
        // Get the session and check if the user is logged in
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        String username = (String) session.getAttribute("username");
        
        // If not logged in, return error response
        if (userId == null || username == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "You must be logged in to book a service");
            jsonResponse.addProperty("redirect", "login.jsp");
            out.print(gson.toJson(jsonResponse));
            out.flush();
            return;
        }
        
        // Get request parameters
        String serviceId = request.getParameter("serviceId");
        String bookingAction = request.getParameter("bookingAction"); // "add_to_existing" or "create_new"
        String existingBookingId = request.getParameter("existingBookingId");
        
        // Get additional booking details from the form
        String weddingDate = request.getParameter("weddingDate");
        String eventLocation = request.getParameter("eventLocation");
        String eventStartTime = request.getParameter("eventStartTime");
        String eventEndTime = request.getParameter("eventEndTime");
        int guestCount = 0;
        int hours = 0;
        double totalPrice = 0.0;
        
        try {
            String guestCountParam = request.getParameter("guestCount");
            if (guestCountParam != null && !guestCountParam.isEmpty()) {
                guestCount = Integer.parseInt(guestCountParam);
            }
            
            String hoursParam = request.getParameter("hours");
            if (hoursParam != null && !hoursParam.isEmpty()) {
                hours = Integer.parseInt(hoursParam);
            }
            
            String totalPriceParam = request.getParameter("totalPrice");
            if (totalPriceParam != null && !totalPriceParam.isEmpty()) {
                totalPrice = Double.parseDouble(totalPriceParam);
            }
        } catch (NumberFormatException e) {
            // Handle parsing errors
            System.err.println("Error parsing numeric fields: " + e.getMessage());
        }
        
        String specialRequirements = request.getParameter("specialRequirements");
        String selectedOptionsJson = request.getParameter("selectedOptionsJson");
        JsonArray selectedOptions = new JsonArray();
        
        if (selectedOptionsJson != null && !selectedOptionsJson.isEmpty()) {
            try {
                // Parse the JSON array of selected options
                selectedOptions = JsonParser.parseString(selectedOptionsJson).getAsJsonArray();
            } catch (Exception e) {
                System.err.println("Error parsing selected options: " + e.getMessage());
            }
        }
        
        // Validate service ID
        if (serviceId == null || serviceId.isEmpty()) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Invalid service ID");
            out.print(gson.toJson(jsonResponse));
            out.flush();
            return;
        }
        
        // Get service details
        JsonObject serviceData = getServiceById(serviceId);
        if (serviceData == null) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Service not found");
            out.print(gson.toJson(jsonResponse));
            out.flush();
            return;
        }
        
        // Check if the user has existing bookings
        if (bookingAction == null) {
            JsonArray existingBookings = getUserBookings(userId);
            
            if (existingBookings.size() > 0) {
                // User has existing bookings, return them to let user choose
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("hasExistingBookings", true);
                jsonResponse.add("existingBookings", existingBookings);
                out.print(gson.toJson(jsonResponse));
                out.flush();
                return;
            } else {
                // No existing bookings, proceed with creating a new booking
                bookingAction = "create_new";
            }
        }
        
        try {
            // Process based on booking action
            if ("add_to_existing".equals(bookingAction) && existingBookingId != null) {
                // Check if the service is compatible with the existing booking
                JsonObject existingBooking = getBookingDetails(existingBookingId, userId);
                if (existingBooking == null) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Booking not found or you don't have access to it");
                    out.print(gson.toJson(jsonResponse));
                    out.flush();
                    return;
                }
                
                // Check for service conflicts
                if (hasServiceConflict(existingBooking, serviceData)) {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "This service conflicts with services already in your booking");
                    out.print(gson.toJson(jsonResponse));
                    out.flush();
                    return;
                }
                
                // Create service booking object with form data and calculate price with guest count
                JsonObject serviceBooking = createServiceBookingObjectWithFormData(
                    serviceId, 
                    serviceData,
                    hours,
                    guestCount,
                    specialRequirements,
                    selectedOptions,
                    totalPrice
                );
                
                // Add service to existing booking
                boolean added = addServiceToExistingBookingWithDetails(
                    existingBookingId, 
                    userId, 
                    serviceBooking, 
                    weddingDate, 
                    eventLocation, 
                    eventStartTime, 
                    eventEndTime, 
                    guestCount
                );
                
                if (added) {
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("message", "Service successfully added to your existing booking");
                    jsonResponse.addProperty("bookingId", existingBookingId);
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Failed to add service to booking");
                }
            } else {
                // Create new booking with this service and form data
                String newBookingId = createNewBookingWithServiceAndDetails(
                    userId, 
                    serviceId, 
                    serviceData, 
                    weddingDate, 
                    eventLocation, 
                    eventStartTime, 
                    eventEndTime, 
                    guestCount, 
                    hours, 
                    specialRequirements, 
                    selectedOptions,
                    totalPrice
                );
                
                if (newBookingId != null) {
                    jsonResponse.addProperty("success", true);
                    jsonResponse.addProperty("message", "New booking created with your service");
                    jsonResponse.addProperty("bookingId", newBookingId);
                } else {
                    jsonResponse.addProperty("success", false);
                    jsonResponse.addProperty("message", "Failed to create new booking");
                }
            }
        } catch (Exception e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Error processing booking: " + e.getMessage());
            e.printStackTrace();
        }
        
        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
    
    /**
     * Check if a service conflicts with existing services in a booking
     * For example, can't have two photography services in one booking
     */
    private boolean hasServiceConflict(JsonObject booking, JsonObject newService) {
        // Example implementation - check for category conflicts
        // In a real implementation, this would be more sophisticated
        if (booking.has("bookedServices") && newService.has("category")) {
            JsonArray bookedServices = booking.getAsJsonArray("bookedServices");
            String newCategory = newService.get("category").getAsString();
            
            // Categories that should be unique per booking
            String[] uniqueCategories = {"photography", "videography", "venue"};
            
            // Check if new service category is in the unique categories list
            boolean isUniqueCategory = false;
            for (String category : uniqueCategories) {
                if (category.equalsIgnoreCase(newCategory)) {
                    isUniqueCategory = true;
                    break;
                }
            }
            
            // If it's a unique category, check if it already exists in the booking
            if (isUniqueCategory) {
                for (JsonElement serviceElement : bookedServices) {
                    JsonObject service = serviceElement.getAsJsonObject();
                    
                    // Get the service details to check category
                    if (service.has("serviceId")) {
                        String existingServiceId = service.get("serviceId").getAsString();
                        JsonObject existingServiceDetails = getServiceById(existingServiceId);
                        
                        if (existingServiceDetails != null && existingServiceDetails.has("category")) {
                            String existingCategory = existingServiceDetails.get("category").getAsString();
                            
                            // If same category already exists, it's a conflict
                            if (existingCategory.equalsIgnoreCase(newCategory)) {
                                return true;
                            }
                        }
                    }
                }
            }
        }
        
        return false;
    }
    
    /**
     * Get full booking details by ID, ensuring the user has access
     */
    private JsonObject getBookingDetails(String bookingId, String userId) {
        try (BufferedReader reader = new BufferedReader(new FileReader(BOOKINGS_PATH))) {
            JsonObject bookingsData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray bookings = bookingsData.getAsJsonArray("bookings");
            
            for (JsonElement bookingElement : bookings) {
                JsonObject booking = bookingElement.getAsJsonObject();
                
                // Check if this is the requested booking and belongs to the user
                if (booking.has("bookingId") && booking.get("bookingId").getAsString().equals(bookingId) &&
                    booking.has("userId") && booking.get("userId").getAsString().equals(userId)) {
                    return booking;
                }
            }
        } catch (Exception e) {
            System.err.println("Error getting booking details: " + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * Get service information by ID
     */
    private JsonObject getServiceById(String serviceId) {
        try (BufferedReader reader = new BufferedReader(new FileReader(SERVICES_PATH))) {
            JsonObject servicesData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray services = servicesData.getAsJsonArray("services");
            
            for (JsonElement serviceElement : services) {
                JsonObject service = serviceElement.getAsJsonObject();
                if (service.has("serviceId") && service.get("serviceId").getAsString().equals(serviceId)) {
                    return service;
                }
            }
        } catch (Exception e) {
            System.err.println("Error reading service data: " + e.getMessage());
        }
        
        return null;
    }
    
    /**
     * Get existing bookings for a user
     */
    private JsonArray getUserBookings(String userId) {
        JsonArray userBookings = new JsonArray();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(BOOKINGS_PATH))) {
            JsonObject bookingsData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray allBookings = bookingsData.getAsJsonArray("bookings");
            
            for (JsonElement bookingElement : allBookings) {
                JsonObject booking = bookingElement.getAsJsonObject();
                if (booking.has("userId") && booking.get("userId").getAsString().equals(userId)) {
                    // Only include active bookings
                    if (booking.has("status") && 
                        (booking.get("status").getAsString().equals("confirmed") || 
                         booking.get("status").getAsString().equals("pending"))) {
                        
                        // Create a simplified booking object for the response
                        JsonObject simpleBooking = new JsonObject();
                        simpleBooking.addProperty("bookingId", booking.get("bookingId").getAsString());
                        simpleBooking.addProperty("weddingDate", booking.has("weddingDate") ? 
                                                booking.get("weddingDate").getAsString() : "");
                        simpleBooking.addProperty("eventLocation", booking.has("eventLocation") ? 
                                                booking.get("eventLocation").getAsString() : "");
                        simpleBooking.addProperty("totalBookingPrice", booking.has("totalBookingPrice") ? 
                                                 booking.get("totalBookingPrice").getAsDouble() : 0.0);
                        
                        // Add additional fields for pre-populating forms
                        simpleBooking.addProperty("eventStartTime", booking.has("eventStartTime") ? 
                                                 booking.get("eventStartTime").getAsString() : "");
                        simpleBooking.addProperty("eventEndTime", booking.has("eventEndTime") ? 
                                                 booking.get("eventEndTime").getAsString() : "");
                        simpleBooking.addProperty("totalGuestCount", booking.has("totalGuestCount") ? 
                                                 booking.get("totalGuestCount").getAsInt() : 0);
                        
                        // Count services in this booking
                        if (booking.has("bookedServices")) {
                            JsonArray bookedServices = booking.getAsJsonArray("bookedServices");
                            simpleBooking.addProperty("serviceCount", bookedServices.size());
                        } else {
                            simpleBooking.addProperty("serviceCount", 0);
                        }
                        
                        userBookings.add(simpleBooking);
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error reading bookings data: " + e.getMessage());
        }
        
        return userBookings;
    }
    
    /**
     * Create a service booking object from service data and form inputs
     * with improved guest-based pricing
     */
    private JsonObject createServiceBookingObjectWithFormData(
            String serviceId, 
            JsonObject serviceData,
            int hours,
            int guestCount,
            String specialRequirements,
            JsonArray selectedOptions,
            double totalPrice) {
        
        JsonObject serviceBooking = new JsonObject();
        
        // Generate unique service booking ID
        serviceBooking.addProperty("serviceBookingId", "SB" + String.valueOf((long)(Math.random() * 90000) + 10000));
        serviceBooking.addProperty("serviceId", serviceId);
        
        // Add vendor ID if available
        if (serviceData.has("vendorId")) {
            serviceBooking.addProperty("vendorId", serviceData.get("vendorId").getAsString());
        }
        
        // Add service name
        if (serviceData.has("name")) {
            serviceBooking.addProperty("serviceName", serviceData.get("name").getAsString());
        } else {
            serviceBooking.addProperty("serviceName", "Unknown Service");
        }
        
        // Add base price
        if (serviceData.has("basePrice")) {
            serviceBooking.addProperty("basePrice", serviceData.get("basePrice").getAsDouble());
        } else {
            serviceBooking.addProperty("basePrice", 0.0);
        }
        
        // Set values from the form
        serviceBooking.addProperty("hours", hours);
        
        // Handle hours calculation based on price model
        String priceModel = serviceData.has("priceModel") ? serviceData.get("priceModel").getAsString() : "fixed";
        double baseDuration = serviceData.has("baseDuration") ? serviceData.get("baseDuration").getAsDouble() : 0;
        
        if ("hourly".equals(priceModel) && hours > 0) {
            serviceBooking.addProperty("baseHours", baseDuration);
            
            // Calculate additional hours
            double additionalHours = Math.max(0, hours - baseDuration);
            serviceBooking.addProperty("additionalHours", additionalHours);
            
            // Calculate additional hours price
            double hourlyRate = serviceData.has("hourlyRate") ? serviceData.get("hourlyRate").getAsDouble() : 0;
            double additionalHoursPrice = additionalHours * hourlyRate;
            serviceBooking.addProperty("additionalHoursPrice", additionalHoursPrice);
        } else {
            serviceBooking.addProperty("baseHours", baseDuration);
            serviceBooking.addProperty("additionalHours", 0);
            serviceBooking.addProperty("additionalHoursPrice", 0.0);
        }
        
        // Handle per-guest pricing
        int baseGuestCount = serviceData.has("baseGuestCount") ? serviceData.get("baseGuestCount").getAsInt() : 0;
        double perGuestRate = serviceData.has("perGuestRate") ? serviceData.get("perGuestRate").getAsDouble() : 0.0;
        
        serviceBooking.addProperty("guestCount", guestCount);
        serviceBooking.addProperty("baseGuestCount", baseGuestCount);
        
        if ("per_guest".equals(priceModel) && guestCount > baseGuestCount && perGuestRate > 0) {
            int additionalGuests = guestCount - baseGuestCount;
            double additionalGuestPrice = additionalGuests * perGuestRate;
            
            // Add these fields to track guest-based pricing
            serviceBooking.addProperty("additionalGuests", additionalGuests);
            serviceBooking.addProperty("additionalGuestPrice", additionalGuestPrice);
        } else {
            serviceBooking.addProperty("additionalGuests", 0);
            serviceBooking.addProperty("additionalGuestPrice", 0.0);
        }
        
        serviceBooking.addProperty("priceModel", priceModel);
        serviceBooking.addProperty("status", "pending");
        serviceBooking.addProperty("lastUpdated", getCurrentTimestamp());
        
        // Add selected options
        serviceBooking.add("selectedOptions", selectedOptions);
        
        // Set service total price from the form
        serviceBooking.addProperty("serviceTotal", totalPrice);
        
        // Add special notes if provided
        serviceBooking.addProperty("specialNotes", specialRequirements != null ? specialRequirements : "");
        
        return serviceBooking;
    }
    
    /**
     * Add a service to an existing booking with additional details
     */
    private boolean addServiceToExistingBookingWithDetails(
            String bookingId, 
            String userId, 
            JsonObject serviceBooking, 
            String weddingDate, 
            String eventLocation, 
            String eventStartTime, 
            String eventEndTime, 
            int guestCount) {
        
        try {
            // Read existing bookings file
            BufferedReader reader = new BufferedReader(new FileReader(BOOKINGS_PATH));
            JsonObject bookingsData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray bookings = bookingsData.getAsJsonArray("bookings");
            reader.close();
            
            boolean bookingFound = false;
            
            // Find the booking to update
            for (int i = 0; i < bookings.size(); i++) {
                JsonObject booking = bookings.get(i).getAsJsonObject();
                
                if (booking.get("bookingId").getAsString().equals(bookingId) && 
                    booking.get("userId").getAsString().equals(userId)) {
                    
                    bookingFound = true;
                    
                    // Update booking details if provided
                    if (weddingDate != null && !weddingDate.isEmpty()) {
                        booking.addProperty("weddingDate", weddingDate);
                    }
                    
                    if (eventLocation != null && !eventLocation.isEmpty()) {
                        booking.addProperty("eventLocation", eventLocation);
                    }
                    
                    if (eventStartTime != null && !eventStartTime.isEmpty()) {
                        booking.addProperty("eventStartTime", eventStartTime);
                    }
                    
                    if (eventEndTime != null && !eventEndTime.isEmpty()) {
                        booking.addProperty("eventEndTime", eventEndTime);
                    }
                    
                    if (guestCount > 0) {
                        booking.addProperty("totalGuestCount", guestCount);
                    }
                    
                    // Check if this service already exists in the booking
                    if (booking.has("bookedServices")) {
                        JsonArray bookedServices = booking.getAsJsonArray("bookedServices");
                        for (JsonElement serviceElement : bookedServices) {
                            JsonObject bookedService = serviceElement.getAsJsonObject();
                            if (bookedService.has("serviceId") && 
                                bookedService.get("serviceId").getAsString().equals(serviceBooking.get("serviceId").getAsString())) {
                                
                                // Service already booked
                                return false;
                            }
                        }
                        
                        // Add the new service booking
                        bookedServices.add(serviceBooking);
                        
                        // Recalculate total price
                        double totalPrice = calculateTotalBookingPrice(booking);
                        booking.addProperty("totalBookingPrice", totalPrice);
                        
                        // Update last updated timestamp
                        booking.addProperty("lastUpdated", getCurrentTimestamp());
                    } else {
                        // No booked services array yet, create one
                        JsonArray newServices = new JsonArray();
                        newServices.add(serviceBooking);
                        booking.add("bookedServices", newServices);
                        
                        // Set total price to this service's price
                        double servicePrice = serviceBooking.get("serviceTotal").getAsDouble();
                        booking.addProperty("totalBookingPrice", servicePrice);
                        
                        // Update last updated timestamp
                        booking.addProperty("lastUpdated", getCurrentTimestamp());
                    }
                    
                    break;
                }
            }
            
            if (!bookingFound) {
                return false;
            }
            
            // Write back to the bookings file
            BufferedWriter writer = new BufferedWriter(new FileWriter(BOOKINGS_PATH));
            writer.write(gson.toJson(bookingsData));
            writer.close();
            
            return true;
        } catch (Exception e) {
            System.err.println("Error adding service to booking: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Create a new booking with a service and additional details
     */
    private String createNewBookingWithServiceAndDetails(
            String userId, 
            String serviceId, 
            JsonObject serviceData, 
            String weddingDate, 
            String eventLocation, 
            String eventStartTime, 
            String eventEndTime, 
            int guestCount, 
            int hours, 
            String specialRequirements, 
            JsonArray selectedOptions,
            double totalPrice) {
        
        try {
            // Read existing bookings file
            BufferedReader reader = new BufferedReader(new FileReader(BOOKINGS_PATH));
            JsonObject bookingsData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray bookings = bookingsData.getAsJsonArray("bookings");
            reader.close();
            
            // Create a new booking
            String newBookingId = generateBookingId();
            JsonObject newBooking = new JsonObject();
            newBooking.addProperty("bookingId", newBookingId);
            newBooking.addProperty("userId", userId);
            newBooking.addProperty("weddingDate", weddingDate != null ? weddingDate : "");
            newBooking.addProperty("bookingDate", getCurrentTimestamp());
            newBooking.addProperty("eventLocation", eventLocation != null ? eventLocation : "");
            newBooking.addProperty("eventStartTime", eventStartTime != null ? eventStartTime : "");
            newBooking.addProperty("eventEndTime", eventEndTime != null ? eventEndTime : "");
            newBooking.addProperty("totalGuestCount", guestCount);
            newBooking.addProperty("totalHours", hours);
            newBooking.addProperty("specialRequirements", specialRequirements != null ? specialRequirements : "");
            newBooking.addProperty("status", "pending");
            
            // Create service booking
            JsonObject serviceBooking = createServiceBookingObjectWithFormData(
                serviceId, 
                serviceData, 
                hours, 
                guestCount, 
                specialRequirements, 
                selectedOptions,
                totalPrice
            );
            
            // Add service booking to new booking
            JsonArray bookedServices = new JsonArray();
            bookedServices.add(serviceBooking);
            newBooking.add("bookedServices", bookedServices);
            
            // Set initial booking price to service price
            newBooking.addProperty("totalBookingPrice", serviceBooking.get("serviceTotal").getAsDouble());
            
            // Set other booking fields
            newBooking.addProperty("depositPaid", false);
            newBooking.addProperty("depositAmount", 0.0);
            newBooking.addProperty("paymentStatus", "unpaid");
            newBooking.addProperty("contractSigned", false);
            newBooking.addProperty("createdBy", "IT24102137");
            newBooking.addProperty("lastUpdated", getCurrentTimestamp());
            
            // Add new booking to bookings array
            bookings.add(newBooking);
            
            // Write back to the bookings file
            BufferedWriter writer = new BufferedWriter(new FileWriter(BOOKINGS_PATH));
            writer.write(gson.toJson(bookingsData));
            writer.close();
            
            return newBookingId;
        } catch (Exception e) {
            System.err.println("Error creating new booking: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Create a service booking object from service data
     */
    private JsonObject createServiceBookingObject(String serviceId, JsonObject serviceData) {
        JsonObject serviceBooking = new JsonObject();
        
        // Generate unique service booking ID
        serviceBooking.addProperty("serviceBookingId", "SB" + String.valueOf((long)(Math.random() * 90000) + 10000));
        serviceBooking.addProperty("serviceId", serviceId);
        
        // Add vendor ID if available
        if (serviceData.has("vendorId")) {
            serviceBooking.addProperty("vendorId", serviceData.get("vendorId").getAsString());
        }
        
        // Add service name
        if (serviceData.has("name")) {
            serviceBooking.addProperty("serviceName", serviceData.get("name").getAsString());
        } else {
            serviceBooking.addProperty("serviceName", "Unknown Service");
        }
        
        // Add base price
        if (serviceData.has("basePrice")) {
            serviceBooking.addProperty("basePrice", serviceData.get("basePrice").getAsDouble());
        } else {
            serviceBooking.addProperty("basePrice", 0.0);
        }
        
        // Set default values
        serviceBooking.addProperty("hours", 0);
        serviceBooking.addProperty("baseHours", 0);
        serviceBooking.addProperty("additionalHours", 0);
        serviceBooking.addProperty("additionalHoursPrice", 0.0);
        serviceBooking.addProperty("guestCount", 0);
        serviceBooking.addProperty("baseGuestCount", 0);
        serviceBooking.addProperty("additionalGuests", 0);
        serviceBooking.addProperty("additionalGuestPrice", 0.0);
        
        // Add price model
        if (serviceData.has("priceModel")) {
            serviceBooking.addProperty("priceModel", serviceData.get("priceModel").getAsString());
        } else {
            serviceBooking.addProperty("priceModel", "fixed");
        }
        
        serviceBooking.addProperty("status", "pending");
        serviceBooking.addProperty("lastUpdated", getCurrentTimestamp());
        
        // Add empty selected options array
        JsonArray selectedOptions = new JsonArray();
        serviceBooking.add("selectedOptions", selectedOptions);
        
        // Set service total price (initially just the base price)
        double basePrice = serviceData.has("basePrice") ? serviceData.get("basePrice").getAsDouble() : 0.0;
        serviceBooking.addProperty("serviceTotal", basePrice);
        
        serviceBooking.addProperty("specialNotes", "");
        
        return serviceBooking;
    }
    
    /**
     * Add a service to an existing booking
     */
    private boolean addServiceToExistingBooking(String bookingId, String serviceId, String userId, JsonObject serviceData) {
        try {
            // Read existing bookings file
            BufferedReader reader = new BufferedReader(new FileReader(BOOKINGS_PATH));
            JsonObject bookingsData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray bookings = bookingsData.getAsJsonArray("bookings");
            reader.close();
            
            boolean bookingFound = false;
            
            // Find the booking to update
            for (int i = 0; i < bookings.size(); i++) {
                JsonObject booking = bookings.get(i).getAsJsonObject();
                
                if (booking.get("bookingId").getAsString().equals(bookingId) && 
                    booking.get("userId").getAsString().equals(userId)) {
                    
                    bookingFound = true;
                    
                    // Check if this service already exists in the booking
                    if (booking.has("bookedServices")) {
                        JsonArray bookedServices = booking.getAsJsonArray("bookedServices");
                        for (JsonElement serviceElement : bookedServices) {
                            JsonObject bookedService = serviceElement.getAsJsonObject();
                            if (bookedService.has("serviceId") && 
                                bookedService.get("serviceId").getAsString().equals(serviceId)) {
                                
                                // Service already booked
                                return false;
                            }
                        }
                        
                        // Add the new service booking
                        JsonObject newServiceBooking = createServiceBookingObject(serviceId, serviceData);
                        bookedServices.add(newServiceBooking);
                        
                        // Recalculate total price
                        double totalPrice = calculateTotalBookingPrice(booking);
                        booking.addProperty("totalBookingPrice", totalPrice);
                        
                        // Update last updated timestamp
                        booking.addProperty("lastUpdated", getCurrentTimestamp());
                    } else {
                        // No booked services array yet, create one
                        JsonArray newServices = new JsonArray();
                        JsonObject newServiceBooking = createServiceBookingObject(serviceId, serviceData);
                        newServices.add(newServiceBooking);
                        booking.add("bookedServices", newServices);
                        
                        // Set total price to this service's price
                        double servicePrice = newServiceBooking.get("serviceTotal").getAsDouble();
                        booking.addProperty("totalBookingPrice", servicePrice);
                        
                        // Update last updated timestamp
                        booking.addProperty("lastUpdated", getCurrentTimestamp());
                    }
                    
                    break;
                }
            }
            
            if (!bookingFound) {
                return false;
            }
            
            // Write back to the bookings file
            BufferedWriter writer = new BufferedWriter(new FileWriter(BOOKINGS_PATH));
            writer.write(gson.toJson(bookingsData));
            writer.close();
            
            return true;
        } catch (Exception e) {
            System.err.println("Error adding service to booking: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Calculate the total price of a booking
     */
    private double calculateTotalBookingPrice(JsonObject booking) {
        double totalPrice = 0.0;
        
        if (booking.has("bookedServices")) {
            JsonArray bookedServices = booking.getAsJsonArray("bookedServices");
            
            for (JsonElement serviceElement : bookedServices) {
                JsonObject service = serviceElement.getAsJsonObject();
                if (service.has("serviceTotal")) {
                    totalPrice += service.get("serviceTotal").getAsDouble();
                }
            }
        }
        
        return totalPrice;
    }
    
    /**
     * Generate a new booking ID
     */
    private String generateBookingId() {
        // Use a simple format: B + random 4-digit number
        return "B" + String.valueOf((long)(Math.random() * 9000) + 1000);
    }
    
    /**
     * Get the current timestamp in formatted string
     */
    private String getCurrentTimestamp() {
        LocalDateTime now = LocalDateTime.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
        return now.format(formatter);
    }
}