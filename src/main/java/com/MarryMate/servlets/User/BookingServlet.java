package com.MarryMate.servlets.User;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import com.MarryMate.models.Booking;
import com.MarryMate.models.ServiceBooking;

/**
 * Servlet to handle booking operations
 * Current Date and Time: 2025-05-14 21:07:37
 * Current User: IT24102083
 */
@WebServlet("/user/bookingservlet")
public class BookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Hardcoded specific file path
    private static final String BOOKINGS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\bookings.json";
    
    // Constants
    private static final String CURRENT_DATETIME = "2025-05-14 21:07:37";
    private static final String CURRENT_USER = "IT24103137";
    
    /**
     * Default constructor
     */
    public BookingServlet() {
        super();
    }

    /**
     * Handles GET requests - retrieves booking data
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        
        // For development/testing purposes
        if (userId == null) {
            userId = "U1005"; // Default test user
        }
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        try {
            // Read all bookings from the JSON file
            List<Booking> allBookings = readBookingsFromJson();
            
            // Filter bookings for current user
            List<Booking> userBookings = new ArrayList<>();
            for (Booking booking : allBookings) {
                if (booking.getUserId().equals(userId)) {
                    userBookings.add(booking);
                }
            }
            
            // Convert to JSON and return
            out.print(new Gson().toJson(userBookings));
            
        } catch (Exception e) {
            // In case of error, return error response
            JsonObject errorJson = new JsonObject();
            errorJson.addProperty("error", true);
            errorJson.addProperty("message", "Error retrieving booking data: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print(errorJson.toString());
            e.printStackTrace();
        }
    }

    /**
     * Handles POST requests - processes booking actions (cancel, etc.)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("userId");
        
        // For development/testing purposes
        if (userId == null) {
            userId = "U1005"; // Default test user
        }
        
        String action = request.getParameter("action");
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        if (action == null) {
            JsonObject errorJson = new JsonObject();
            errorJson.addProperty("status", "error");
            errorJson.addProperty("message", "Action parameter is required");
            out.print(errorJson.toString());
            return;
        }
        
        switch (action) {
            case "cancel":
                handleCancelAction(request, response, userId, out);
                break;
            case "getServiceDetails":
                handleGetServiceDetails(request, response, userId, out);
                break;
            default:
                JsonObject errorJson = new JsonObject();
                errorJson.addProperty("status", "error");
                errorJson.addProperty("message", "Unknown action: " + action);
                out.print(errorJson.toString());
        }
    }
    
    /**
     * Handle cancel action for bookings or service bookings
     */
    private void handleCancelAction(HttpServletRequest request, HttpServletResponse response, String userId, PrintWriter out) throws IOException {
        String bookingId = request.getParameter("bookingId");
        String serviceBookingId = request.getParameter("serviceBookingId");
        
        if (bookingId == null) {
            JsonObject errorJson = new JsonObject();
            errorJson.addProperty("status", "error");
            errorJson.addProperty("message", "Booking ID is required");
            out.print(errorJson.toString());
            return;
        }
        
        // Read all bookings from the JSON file
        List<Booking> bookings = readBookingsFromJson();
        
        boolean isUpdated = false;
        
        // Find and update the booking
        for (Booking booking : bookings) {
            if (booking.getBookingId().equals(bookingId)) {
                // Check if this is the current user's booking
                if (!booking.getUserId().equals(userId)) {
                    JsonObject errorJson = new JsonObject();
                    errorJson.addProperty("status", "error");
                    errorJson.addProperty("message", "Unauthorized to modify this booking");
                    out.print(errorJson.toString());
                    return;
                }
                
                if (serviceBookingId != null && !serviceBookingId.isEmpty()) {
                    // Cancel a specific service booking
                    for (ServiceBooking service : booking.getBookedServices()) {
                        if (service.getServiceBookingId().equals(serviceBookingId)) {
                            // Update service status to cancelled
                            service.setStatus("cancelled");
                            isUpdated = true;
                            break;
                        }
                    }
                    
                    // Update last updated timestamp
                    booking.setLastUpdated(CURRENT_DATETIME);
                } else {
                    // Cancel entire booking
                    booking.setStatus("cancelled");
                    
                    // Also update all services to cancelled
                    for (ServiceBooking service : booking.getBookedServices()) {
                        service.setStatus("cancelled");
                    }
                    
                    booking.setLastUpdated(CURRENT_DATETIME);
                    isUpdated = true;
                }
                break;
            }
        }
        
        if (isUpdated) {
            // Write updated data back to file
            writeBookingsToJson(bookings);
            
            JsonObject successJson = new JsonObject();
            successJson.addProperty("status", "success");
            successJson.addProperty("message", serviceBookingId != null ? 
                    "Service booking cancelled successfully" : "Booking cancelled successfully");
            out.print(successJson.toString());
        } else {
            JsonObject errorJson = new JsonObject();
            errorJson.addProperty("status", "error");
            errorJson.addProperty("message", "Booking or service not found");
            out.print(errorJson.toString());
        }
    }
    
    /**
     * Handle getting detailed service information
     */
    private void handleGetServiceDetails(HttpServletRequest request, HttpServletResponse response, String userId, PrintWriter out) throws IOException {
        String bookingId = request.getParameter("bookingId");
        String serviceBookingId = request.getParameter("serviceBookingId");
        
        if (bookingId == null || serviceBookingId == null) {
            JsonObject errorJson = new JsonObject();
            errorJson.addProperty("status", "error");
            errorJson.addProperty("message", "Booking ID and Service Booking ID are required");
            out.print(errorJson.toString());
            return;
        }
        
        // Read all bookings from the JSON file
        List<Booking> bookings = readBookingsFromJson();
        
        // Find the booking and service
        for (Booking booking : bookings) {
            if (booking.getBookingId().equals(bookingId)) {
                // Check if this is the current user's booking
                if (!booking.getUserId().equals(userId)) {
                    JsonObject errorJson = new JsonObject();
                    errorJson.addProperty("status", "error");
                    errorJson.addProperty("message", "Unauthorized to access this booking");
                    out.print(errorJson.toString());
                    return;
                }
                
                for (ServiceBooking service : booking.getBookedServices()) {
                    if (service.getServiceBookingId().equals(serviceBookingId)) {
                        // Return the service details
                        JsonObject resultJson = new JsonObject();
                        resultJson.addProperty("status", "success");
                        resultJson.add("service", new Gson().toJsonTree(service));
                        out.print(resultJson.toString());
                        return;
                    }
                }
                
                // Service not found in booking
                JsonObject errorJson = new JsonObject();
                errorJson.addProperty("status", "error");
                errorJson.addProperty("message", "Service not found in booking");
                out.print(errorJson.toString());
                return;
            }
        }
        
        // Booking not found
        JsonObject errorJson = new JsonObject();
        errorJson.addProperty("status", "error");
        errorJson.addProperty("message", "Booking not found");
        out.print(errorJson.toString());
    }
    
    /**
     * Read bookings from JSON file
     * This function directly reads the JSON file and returns a list of Booking objects
     */
    private List<Booking> readBookingsFromJson() throws IOException {
        // Read file content
        String content = new String(Files.readAllBytes(Paths.get(BOOKINGS_FILE_PATH)));
        
        // Parse JSON
        Gson gson = new Gson();
        JsonObject rootObject = gson.fromJson(content, JsonObject.class);
        
        // Convert JSON array to list of Booking objects
        List<Booking> bookings = new ArrayList<>();
        if (rootObject.has("bookings")) {
            TypeToken<List<Booking>> token = new TypeToken<List<Booking>>() {};
            bookings = gson.fromJson(rootObject.get("bookings"), token.getType());
        }
        
        return bookings;
    }
    
    /**
     * Write bookings to JSON file
     * This function directly writes a list of Booking objects to the JSON file
     */
    private void writeBookingsToJson(List<Booking> bookings) throws IOException {
        // Create JSON object to hold bookings array
        JsonObject rootObject = new JsonObject();
        
        // Convert bookings list to JSON and add to root object
        Gson gson = new GsonBuilder().setPrettyPrinting().create();
        rootObject.add("bookings", gson.toJsonTree(bookings));
        
        // Write to file without comment lines
        try (FileWriter writer = new FileWriter(BOOKINGS_FILE_PATH)) {
            writer.write(gson.toJson(rootObject));
        }
        
        System.out.println("Bookings data successfully written to " + BOOKINGS_FILE_PATH);
    }
}