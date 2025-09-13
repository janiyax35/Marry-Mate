package com.MarryMate.servlets.Vendor;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.MarryMate.models.Booking;
import com.MarryMate.models.ServiceBooking;

/**
 * Servlet for managing bookings in Marry Mate Wedding Planning System
 * Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-13 11:31:11
 * Current User's Login: IT24102083
 */
@WebServlet("/vendor/bookingservlet")
public class BookingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String BOOKINGS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\bookings.json";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    // GSON instance for JSON processing
    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();
    
    /**
     * Handle GET requests - Returns list of bookings for the vendor
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set content type and character encoding
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Get vendor ID from session - this is the primary source
        HttpSession session = request.getSession();
        String vendorIdFromSession = (String) session.getAttribute("UserId");
        
        // If not in session, try from request parameter (for testing)
        String vendorIdFromRequest = request.getParameter("UserId");
        
        // Use the session value if available, otherwise use the request parameter
        final String finalVendorId = (vendorIdFromSession != null && !vendorIdFromSession.trim().isEmpty()) ? 
                                     vendorIdFromSession : vendorIdFromRequest;
        
        // Log vendor ID for debugging
        log("Loading bookings for vendor ID: " + finalVendorId);
        
        if (finalVendorId == null || finalVendorId.trim().isEmpty()) {
            log("No vendor ID found in session or request parameters");
            sendErrorResponse(response, "Vendor ID not found. Please login again.");
            return;
        }
        
        try {
            // Load all bookings from JSON file
            List<Booking> allBookings = loadBookingsFromJSON(request);
            
            // Filter bookings to include only those with services from this vendor
            List<Booking> vendorBookings = allBookings.stream()
                .filter(booking -> hasVendorService(booking, finalVendorId))
                .collect(Collectors.toList());
            
            log("Found " + vendorBookings.size() + " bookings for vendor ID: " + finalVendorId);
            
            // Convert bookings to JSON and send response
            PrintWriter out = response.getWriter();
            out.print(GSON.toJson(vendorBookings));
            out.flush();
            
        } catch (Exception e) {
            log("Error retrieving bookings data", e);
            sendErrorResponse(response, "Failed to load bookings data: " + e.getMessage());
        }
    }

    /**
     * Handle POST requests for booking actions (approve/reject/add/update)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set content type and character encoding
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Get vendor ID from session - this is required for security
        HttpSession session = request.getSession();
        String vendorId = (String) session.getAttribute("UserId");
        System.out.println("Vendor ID from session: " + vendorId);
        
        if (vendorId == null || vendorId.trim().isEmpty()) {
            sendErrorResponse(response, "Unauthorized: Vendor ID not found. Please login again.");
            return;
        }
        
        String action = request.getParameter("action");
        if (action == null || action.trim().isEmpty()) {
            sendErrorResponse(response, "No action specified");
            return;
        }
        
        try {
            String bookingId = request.getParameter("bookingId");
            String serviceBookingId = request.getParameter("serviceBookingId");
            Map<String, String> result = new HashMap<>();
            
            switch (action.toLowerCase()) {
                case "approve":
                    result = approveService(request, bookingId, serviceBookingId, vendorId);
                    break;
                case "reject":
                    result = rejectService(request, bookingId, serviceBookingId, vendorId);
                    break;
                default:
                    result.put("status", "error");
                    result.put("message", "Invalid action specified");
            }
            
            // Send response
            PrintWriter out = response.getWriter();
            out.print(GSON.toJson(result));
            out.flush();
            
        } catch (Exception e) {
            log("Error processing booking action", e);
            sendErrorResponse(response, "Failed to process action: " + e.getMessage());
        }
    }
    
    /**
     * Approve a specific service in a booking
     */
    private Map<String, String> approveService(HttpServletRequest request, String bookingId, 
                                               String serviceBookingId, String vendorId) throws Exception {
        Map<String, String> result = new HashMap<>();
        
        if (bookingId == null || bookingId.trim().isEmpty()) {
            result.put("status", "error");
            result.put("message", "Booking ID is required");
            return result;
        }
        
        if (serviceBookingId == null || serviceBookingId.trim().isEmpty()) {
            result.put("status", "error");
            result.put("message", "Service Booking ID is required");
            return result;
        }
        
        // Load all bookings
        List<Booking> allBookings = loadBookingsFromJSON(request);
        
        // Find booking by ID
        Booking booking = null;
        for (Booking b : allBookings) {
            if (bookingId.equals(b.getBookingId())) {
                booking = b;
                break;
            }
        }
        
        if (booking == null) {
            result.put("status", "error");
            result.put("message", "Booking not found: " + bookingId);
            return result;
        }
        
        // Find the service and verify it belongs to this vendor
        ServiceBooking serviceToApprove = null;
        for (ServiceBooking service : booking.getBookedServices()) {
            if (serviceBookingId.equals(service.getServiceBookingId())) {
                if (!vendorId.equals(service.getVendorId())) {
                    result.put("status", "error");
                    result.put("message", "Unauthorized: You do not have permission to modify this service");
                    return result;
                }
                serviceToApprove = service;
                break;
            }
        }
        
        if (serviceToApprove == null) {
            result.put("status", "error");
            result.put("message", "Service not found in booking: " + serviceBookingId);
            return result;
        }
        
        // Update service status
        serviceToApprove.setStatus("confirmed");
        serviceToApprove.setLastUpdated(LocalDateTime.now().format(DATE_FORMATTER));
        
        // Check if all services are now confirmed or cancelled
        boolean allServicesProcessed = booking.getBookedServices().stream()
            .allMatch(s -> "confirmed".equals(s.getStatus()) || "cancelled".equals(s.getStatus()));
            
        if (allServicesProcessed) {
            // If all services are confirmed, set booking status to confirmed
            boolean anyConfirmed = booking.getBookedServices().stream()
                .anyMatch(s -> "confirmed".equals(s.getStatus()));
                
            if (anyConfirmed) {
                booking.setStatus("confirmed");
            } else {
                booking.setStatus("cancelled"); // All services cancelled
            }
        }
        
        // Update the last updated timestamp for the booking
        booking.setLastUpdated(LocalDateTime.now().format(DATE_FORMATTER));
        
        // Save updated bookings back to file
        saveBookingsToJSON(request, allBookings);
        
        result.put("status", "success");
        result.put("message", "Service approved successfully");
        return result;
    }
    
    /**
     * Reject a specific service in a booking
     */
    private Map<String, String> rejectService(HttpServletRequest request, String bookingId, 
                                             String serviceBookingId, String vendorId) throws Exception {
        Map<String, String> result = new HashMap<>();
        
        if (bookingId == null || bookingId.trim().isEmpty()) {
            result.put("status", "error");
            result.put("message", "Booking ID is required");
            return result;
        }
        
        if (serviceBookingId == null || serviceBookingId.trim().isEmpty()) {
            result.put("status", "error");
            result.put("message", "Service Booking ID is required");
            return result;
        }
        
        // Load all bookings
        List<Booking> allBookings = loadBookingsFromJSON(request);
        
        // Find booking by ID
        Booking booking = null;
        for (Booking b : allBookings) {
            if (bookingId.equals(b.getBookingId())) {
                booking = b;
                break;
            }
        }
        
        if (booking == null) {
            result.put("status", "error");
            result.put("message", "Booking not found: " + bookingId);
            return result;
        }
        
        // Find the service and verify it belongs to this vendor
        ServiceBooking serviceToReject = null;
        for (ServiceBooking service : booking.getBookedServices()) {
            if (serviceBookingId.equals(service.getServiceBookingId())) {
                if (!vendorId.equals(service.getVendorId())) {
                    result.put("status", "error");
                    result.put("message", "Unauthorized: You do not have permission to modify this service");
                    return result;
                }
                serviceToReject = service;
                break;
            }
        }
        
        if (serviceToReject == null) {
            result.put("status", "error");
            result.put("message", "Service not found in booking: " + serviceBookingId);
            return result;
        }
        
        // Update service status
        serviceToReject.setStatus("cancelled");
        serviceToReject.setLastUpdated(LocalDateTime.now().format(DATE_FORMATTER));
        
        // Check if all services are now confirmed or cancelled
        boolean allServicesProcessed = booking.getBookedServices().stream()
            .allMatch(s -> "confirmed".equals(s.getStatus()) || "cancelled".equals(s.getStatus()));
            
        if (allServicesProcessed) {
            // If all services are cancelled, set booking status to cancelled
            boolean anyConfirmed = booking.getBookedServices().stream()
                .anyMatch(s -> "confirmed".equals(s.getStatus()));
                
            if (anyConfirmed) {
                booking.setStatus("confirmed"); // At least one service is confirmed
            } else {
                booking.setStatus("cancelled"); // All services cancelled
            }
        }
        
        // Update the last updated timestamp for the booking
        booking.setLastUpdated(LocalDateTime.now().format(DATE_FORMATTER));
        
        // Save updated bookings back to file
        saveBookingsToJSON(request, allBookings);
        
        result.put("status", "success");
        result.put("message", "Service rejected successfully");
        return result;
    }
    
    /**
     * Load bookings from JSON file
     */
    private List<Booking> loadBookingsFromJSON(HttpServletRequest request) throws Exception {
        // Get JSON file path
        String filePath = (BOOKINGS_FILE_PATH);
        File bookingsFile = new File(filePath);
        
        if (!bookingsFile.exists()) {
            log("Bookings file not found at: " + filePath);
            return new ArrayList<>();
        }
        
        System.out.println("Loading bookings from file: " + filePath);
        
        // Read JSON file
        StringBuilder fileContent = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new FileReader(bookingsFile))) {
            String line;
            while ((line = reader.readLine()) != null) {
                fileContent.append(line);
            }
        }
        
        // Parse JSON into BookingData object
        BookingData bookingData = GSON.fromJson(fileContent.toString(), BookingData.class);
        
        // If bookingData is null or has no bookings list, return empty list
        if (bookingData == null || bookingData.getBookings() == null) {
            return new ArrayList<>();
        }
        
        return bookingData.getBookings();
    }
    
    /**
     * Save bookings back to JSON file
     */
    private void saveBookingsToJSON(HttpServletRequest request, List<Booking> bookings) throws Exception {
        // Create BookingData object
        BookingData bookingData = new BookingData();
        bookingData.setBookings(bookings);
        
        // Convert to JSON
        String jsonContent = GSON.toJson(bookingData);
        
        // Write to file
        String filePath = (BOOKINGS_FILE_PATH);
        try (FileWriter writer = new FileWriter(filePath)) {
            writer.write(jsonContent);
        }
    }
    
    /**
     * Check if booking contains services from a specific vendor
     * This is a critical function to ensure vendor-specific filtering
     */
    private boolean hasVendorService(Booking booking, String vendorId) {
        if (booking.getBookedServices() == null || booking.getBookedServices().isEmpty()) {
            return false;
        }
        
        for (ServiceBooking service : booking.getBookedServices()) {
            if (vendorId.equals(service.getVendorId())) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Send error response to client
     */
    private void sendErrorResponse(HttpServletResponse response, String errorMessage) throws IOException {
        Map<String, String> errorMap = new HashMap<>();
        errorMap.put("status", "error");
        errorMap.put("message", errorMessage);
        
        PrintWriter out = response.getWriter();
        out.print(GSON.toJson(errorMap));
        out.flush();
    }
    
    /**
     * Inner class to match the JSON structure for deserialization
     */
    private static class BookingData {
        private List<Booking> bookings;
        
        public List<Booking> getBookings() {
            return bookings;
        }
        
        public void setBookings(List<Booking> bookings) {
            this.bookings = bookings;
        }
    }
}