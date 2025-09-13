package com.MarryMate.servlets.User;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * Servlet implementation class ReviewServlet
 * Handles user review operations: create, read, update, delete
 * Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-18 10:21:52
 * Current User's Login: IT24102137
 */
@WebServlet("/user/reviewservlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 5 * 1024 * 1024,   // 5 MB
    maxRequestSize = 20 * 1024 * 1024 // 20 MB
)
public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // File paths for JSON data
    private static final String REVIEWS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\reviews.json";
    private static final String BOOKINGS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\bookings.json";
    private static final String VENDORS_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
    private static final String SERVICES_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendorServices.json";
    private static final String REVIEW_PHOTOS_DIR = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\resources\\user\\reviews";
    
    // Gson instance for JSON serialization/deserialization
    private final Gson gson = new GsonBuilder().setPrettyPrinting().create();
    
    /**
     * Constructor for ReviewServlet
     */
    public ReviewServlet() {
        super();
    }
    
    /**
     * Handle GET requests to retrieve review data
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Get current user ID from session
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("UserId");
        
        if (userId == null) {
            // Handle case when user is not logged in
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("status", "error");
            errorResponse.addProperty("message", "User is not logged in");
            out.print(errorResponse.toString());
            return;
        }
        
        // Check action parameter
        String action = request.getParameter("action");
        
        if ("pendingServices".equals(action)) {
            // Get services eligible for review
            out.print(getPendingServices(request, userId));
        } else if ("getReview".equals(action)) {
            // Get a specific review for editing
            String reviewId = request.getParameter("reviewId");
            out.print(getReviewById(request, userId, reviewId));
        } else if ("getServiceDetails".equals(action)) {
            // Get service details for review creation
            out.print(getServiceDetails(request, userId));
        } else {
            // Default action is to get user's reviews
            out.print(getUserReviews(request, userId));
        }
    }
    
    /**
     * Handle POST requests to create or update review data
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Set response type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Get current user ID from session
        HttpSession session = request.getSession();
        String userId = (String) session.getAttribute("UserId");
        
        if (userId == null) {
            // Handle case when user is not logged in
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("status", "error");
            errorResponse.addProperty("message", "User is not logged in");
            out.print(errorResponse.toString());
            return;
        }
        
        // Get action from request
        String action = request.getParameter("action");
        
        // Handle different actions
        JsonObject result; // Changed from 'response' to 'result' to avoid duplicate variable name
        if ("edit".equals(action)) {
            result = saveReview(request, userId, true);
        } else if ("delete".equals(action)) {
            result = deleteReview(request, userId);
        } else {
            // Default action is to add a new review
            result = saveReview(request, userId, false);
        }
        
        out.print(result.toString());
    }

    /**
     * Get user's reviews
     */
    private String getUserReviews(HttpServletRequest request, String userId) throws IOException {
        // Read reviews from file
        String reviewsJson = readFile(REVIEWS_FILE_PATH);
        JsonObject reviewsObject = JsonParser.parseString(reviewsJson).getAsJsonObject();
        JsonArray reviewsArray = reviewsObject.getAsJsonArray("reviews");
        
        // Get services data for service names
        String servicesJson = readFile(SERVICES_FILE_PATH);
        JsonObject servicesObject = JsonParser.parseString(servicesJson).getAsJsonObject();
        JsonArray servicesArray = servicesObject.getAsJsonArray("services");
        
        // Get vendors data for vendor names
        String vendorsJson = readFile(VENDORS_FILE_PATH);
        JsonObject vendorsObject = JsonParser.parseString(vendorsJson).getAsJsonObject();
        JsonArray vendorsArray = vendorsObject.getAsJsonArray("vendors");
        
        // Create a new array for the user's reviews
        JsonArray userReviewsArray = new JsonArray();
        
        // Find all reviews for the user
        for (JsonElement element : reviewsArray) {
            JsonObject review = element.getAsJsonObject();
            
            // Check if this review belongs to the user
            if (userId.equals(review.get("userId").getAsString())) {
                // Add vendor and service information
                String vendorId = review.get("vendorId").getAsString();
                String serviceId = review.get("serviceId").getAsString();
                
                // Find vendor name and photo
                for (JsonElement vendorElement : vendorsArray) {
                    JsonObject vendor = vendorElement.getAsJsonObject();
                    if (vendorId.equals(vendor.get("userId").getAsString())) {
                        review.addProperty("vendorName", vendor.get("businessName").getAsString());
                        if (vendor.has("profilePictureUrl")) {
                            review.addProperty("vendorPhotoUrl", vendor.get("profilePictureUrl").getAsString());
                        }
                        break;
                    }
                }
                
                // Find service name
                for (JsonElement serviceElement : servicesArray) {
                    JsonObject service = serviceElement.getAsJsonObject();
                    if (serviceId.equals(service.get("serviceId").getAsString())) {
                        review.addProperty("serviceName", service.get("name").getAsString());
                        break;
                    }
                }
                
                // Add to user's reviews array
                userReviewsArray.add(review);
            }
        }
        
        // Return the user's reviews as JSON
        return userReviewsArray.toString();
    }
    
    /**
     * Get services that the user can review
     */
    private String getPendingServices(HttpServletRequest request, String userId) throws IOException {
        // Read bookings from file
        String bookingsJson = readFile(BOOKINGS_FILE_PATH);
        JsonObject bookingsObject = JsonParser.parseString(bookingsJson).getAsJsonObject();
        JsonArray bookingsArray = bookingsObject.getAsJsonArray("bookings");
        
        // Get existing reviews
        String reviewsJson = readFile(REVIEWS_FILE_PATH);
        JsonObject reviewsObject = JsonParser.parseString(reviewsJson).getAsJsonObject();
        JsonArray reviewsArray = reviewsObject.getAsJsonArray("reviews");
        
        // Get services data
        String servicesJson = readFile(SERVICES_FILE_PATH);
        JsonObject servicesObject = JsonParser.parseString(servicesJson).getAsJsonObject();
        JsonArray servicesArray = servicesObject.getAsJsonArray("services");
        
        // Get vendors data
        String vendorsJson = readFile(VENDORS_FILE_PATH);
        JsonObject vendorsObject = JsonParser.parseString(vendorsJson).getAsJsonObject();
        JsonArray vendorsArray = vendorsObject.getAsJsonArray("vendors");
        
        // Create a new array for the pending services
        JsonArray pendingServicesArray = new JsonArray();
        
        // List to track services already reviewed
        List<String> reviewedServices = new ArrayList<>();
        
        // Find all reviews by this user
        for (JsonElement reviewElement : reviewsArray) {
            JsonObject review = reviewElement.getAsJsonObject();
            if (userId.equals(review.get("userId").getAsString())) {
                // Build a key with service and booking ID to prevent duplicate reviews
                String key = review.get("serviceId").getAsString() + "_" + review.get("bookingId").getAsString();
                reviewedServices.add(key);
            }
        }
        
        // Find completed bookings that can be reviewed
        for (JsonElement bookingElement : bookingsArray) {
            JsonObject booking = bookingElement.getAsJsonObject();
            
            // Check if this booking belongs to the user
            if (userId.equals(booking.get("userId").getAsString())) {
                // Check if booking has services
                if (booking.has("bookedServices") && booking.get("bookedServices").isJsonArray()) {
                    JsonArray bookedServices = booking.getAsJsonArray("bookedServices");
                    
                    // Check each service
                    for (JsonElement serviceElement : bookedServices) {
                        JsonObject bookedService = serviceElement.getAsJsonObject();
                        
                        // Only completed services can be reviewed
                        String serviceStatus = bookedService.has("status") ? 
                            bookedService.get("status").getAsString() : "pending";
                        
                        if ("completed".equals(serviceStatus) || "confirmed".equals(serviceStatus)) {
                            String serviceId = bookedService.get("serviceId").getAsString();
                            String bookingId = booking.get("bookingId").getAsString();
                            String vendorId = bookedService.get("vendorId").getAsString();
                            
                            // Check if already reviewed
                            String key = serviceId + "_" + bookingId;
                            if (!reviewedServices.contains(key)) {
                                // Create pending service entry
                                JsonObject pendingService = new JsonObject();
                                pendingService.addProperty("serviceId", serviceId);
                                pendingService.addProperty("bookingId", bookingId);
                                pendingService.addProperty("vendorId", vendorId);
                                
                                // Add service name
                                for (JsonElement svcElement : servicesArray) {
                                    JsonObject service = svcElement.getAsJsonObject();
                                    if (serviceId.equals(service.get("serviceId").getAsString())) {
                                        pendingService.addProperty("serviceName", service.get("name").getAsString());
                                        break;
                                    }
                                }
                                
                                // Add vendor info
                                for (JsonElement vendorElement : vendorsArray) {
                                    JsonObject vendor = vendorElement.getAsJsonObject();
                                    if (vendorId.equals(vendor.get("userId").getAsString())) {
                                        pendingService.addProperty("vendorName", vendor.get("businessName").getAsString());
                                        if (vendor.has("profilePictureUrl")) {
                                            pendingService.addProperty("vendorPhotoUrl", vendor.get("profilePictureUrl").getAsString());
                                        }
                                        break;
                                    }
                                }
                                
                                // Add service date from booking
                                pendingService.addProperty("serviceDate", booking.get("weddingDate").getAsString());
                                
                                // Add to pending services array
                                pendingServicesArray.add(pendingService);
                            }
                        }
                    }
                }
            }
        }
        
        // Return the pending services as JSON
        return pendingServicesArray.toString();
    }
    
    /**
     * Get a specific review by ID
     */
    private String getReviewById(HttpServletRequest request, String userId, String reviewId) throws IOException {
        JsonObject result = new JsonObject();
        
        if (reviewId == null || reviewId.isEmpty()) {
            result.addProperty("status", "error");
            result.addProperty("message", "Review ID is required");
            return result.toString();
        }
        
        // Read reviews from file
        String reviewsJson = readFile(REVIEWS_FILE_PATH);
        JsonObject reviewsObject = JsonParser.parseString(reviewsJson).getAsJsonObject();
        JsonArray reviewsArray = reviewsObject.getAsJsonArray("reviews");
        
        // Get services data
        String servicesJson = readFile(SERVICES_FILE_PATH);
        JsonObject servicesObject = JsonParser.parseString(servicesJson).getAsJsonObject();
        JsonArray servicesArray = servicesObject.getAsJsonArray("services");
        
        // Get vendors data
        String vendorsJson = readFile(VENDORS_FILE_PATH);
        JsonObject vendorsObject = JsonParser.parseString(vendorsJson).getAsJsonObject();
        JsonArray vendorsArray = vendorsObject.getAsJsonArray("vendors");
        
        // Find the review
        JsonObject reviewData = null;
        for (JsonElement element : reviewsArray) {
            JsonObject review = element.getAsJsonObject();
            if (reviewId.equals(review.get("reviewId").getAsString())) {
                // Verify ownership
                if (!userId.equals(review.get("userId").getAsString())) {
                    result.addProperty("status", "error");
                    result.addProperty("message", "You do not have permission to access this review");
                    return result.toString();
                }
                reviewData = review;
                break;
            }
        }
        
        if (reviewData == null) {
            result.addProperty("status", "error");
            result.addProperty("message", "Review not found");
            return result.toString();
        }
        
        // Add vendor and service information
        String vendorId = reviewData.get("vendorId").getAsString();
        String serviceId = reviewData.get("serviceId").getAsString();
        
        // Find vendor name
        for (JsonElement vendorElement : vendorsArray) {
            JsonObject vendor = vendorElement.getAsJsonObject();
            if (vendorId.equals(vendor.get("userId").getAsString())) {
                reviewData.addProperty("vendorName", vendor.get("businessName").getAsString());
                if (vendor.has("profilePictureUrl")) {
                    reviewData.addProperty("vendorPhotoUrl", vendor.get("profilePictureUrl").getAsString());
                }
                break;
            }
        }
        
        // Find service name
        for (JsonElement serviceElement : servicesArray) {
            JsonObject service = serviceElement.getAsJsonObject();
            if (serviceId.equals(service.get("serviceId").getAsString())) {
                reviewData.addProperty("serviceName", service.get("name").getAsString());
                break;
            }
        }
        
        // Create response
        result.addProperty("status", "success");
        result.add("review", reviewData);
        
        return result.toString();
    }
    
    /**
     * Get service details for review creation
     */
    private String getServiceDetails(HttpServletRequest request, String userId) throws IOException {
        String vendorId = request.getParameter("vendorId");
        String serviceId = request.getParameter("serviceId");
        
        // Validate required parameters
        if (vendorId == null || serviceId == null) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("status", "error");
            errorResponse.addProperty("message", "Vendor ID and Service ID are required");
            return errorResponse.toString();
        }
        
        try {
            // Get vendors data
            String vendorsJson = readFile(VENDORS_FILE_PATH);
            JsonObject vendorsObject = JsonParser.parseString(vendorsJson).getAsJsonObject();
            JsonArray vendorsArray = vendorsObject.getAsJsonArray("vendors");
            
            // Get services data
            String servicesJson = readFile(SERVICES_FILE_PATH);
            JsonObject servicesObject = JsonParser.parseString(servicesJson).getAsJsonObject();
            JsonArray servicesArray = servicesObject.getAsJsonArray("services");
            
            // Find vendor info
            String vendorName = "Unknown Vendor";
            String vendorPhotoUrl = "/assets/images/vendors/default.jpg";
            
            for (JsonElement vendorElement : vendorsArray) {
                JsonObject vendor = vendorElement.getAsJsonObject();
                if (vendorId.equals(vendor.get("userId").getAsString())) {
                    vendorName = vendor.get("businessName").getAsString();
                    if (vendor.has("profilePictureUrl")) {
                        vendorPhotoUrl = vendor.get("profilePictureUrl").getAsString();
                    }
                    break;
                }
            }
            
            // Find service info
            String serviceName = "Unknown Service";
            for (JsonElement serviceElement : servicesArray) {
                JsonObject service = serviceElement.getAsJsonObject();
                if (serviceId.equals(service.get("serviceId").getAsString())) {
                    serviceName = service.get("name").getAsString();
                    break;
                }
            }
            
            // Build response
            JsonObject response = new JsonObject();
            response.addProperty("status", "success");
            response.addProperty("vendorName", vendorName);
            response.addProperty("vendorPhotoUrl", vendorPhotoUrl);
            response.addProperty("serviceName", serviceName);
            
            return response.toString();
            
        } catch (Exception e) {
            JsonObject errorResponse = new JsonObject();
            errorResponse.addProperty("status", "error");
            errorResponse.addProperty("message", "Error retrieving service details: " + e.getMessage());
            return errorResponse.toString();
        }
    }
    
    /**
     * Save a new review or update an existing one
     */
    private JsonObject saveReview(HttpServletRequest request, String userId, boolean isEdit) throws IOException, ServletException {
        JsonObject result = new JsonObject();
        
        try {
            // Get review data from request
            String reviewId = request.getParameter("reviewId");
            String serviceId = request.getParameter("serviceId");
            String vendorId = request.getParameter("vendorId");
            String bookingId = request.getParameter("bookingId");
            String rating = request.getParameter("rating");
            String comment = request.getParameter("comment");
            String status = request.getParameter("status");
            
            // Get detailed ratings
            String qualityRating = request.getParameter("qualityRating");
            String valueRating = request.getParameter("valueRating");
            String responsivenessRating = request.getParameter("responsivenessRating");
            String professionalismRating = request.getParameter("professionalismRating");
            
            // Validate required fields
            if (serviceId == null || vendorId == null || bookingId == null || rating == null || comment == null) {
                result.addProperty("status", "error");
                result.addProperty("message", "Missing required fields");
                return result;
            }
            
            // Get the reviews JSON file
            String reviewsJson = readFile(REVIEWS_FILE_PATH);
            JsonObject reviewsObject = JsonParser.parseString(reviewsJson).getAsJsonObject();
            JsonArray reviewsArray = reviewsObject.getAsJsonArray("reviews");
            
            // Get user and vendor data
            String vendorsJson = readFile(VENDORS_FILE_PATH);
            JsonObject vendorsObject = JsonParser.parseString(vendorsJson).getAsJsonObject();
            JsonArray vendorsArray = vendorsObject.getAsJsonArray("vendors");
            
            // Find user name
            String userName = "User";
            
            // Get the current date and time
            SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            String currentDate = dateFormat.format(new Date());
            
            // Create or update review
            JsonObject reviewObject;
            boolean isNewReview = (reviewId == null || reviewId.isEmpty());
            
            if (isNewReview && isEdit) {
                result.addProperty("status", "error");
                result.addProperty("message", "Cannot edit a non-existent review");
                return result;
            }
            
            if (isNewReview) {
                // Create new review
                reviewObject = new JsonObject();
                
                // Generate sequential review ID starting with R1001
                int nextId = 1001;
                for (JsonElement element : reviewsArray) {
                    JsonObject review = element.getAsJsonObject();
                    String existingId = review.get("reviewId").getAsString();
                    if (existingId.startsWith("R")) {
                        try {
                            int idNum = Integer.parseInt(existingId.substring(1));
                            if (idNum >= nextId) {
                                nextId = idNum + 1;
                            }
                        } catch (NumberFormatException e) {
                            // Skip if not a valid number format
                        }
                    }
                }
                reviewId = "R" + nextId;
                
                reviewObject.addProperty("reviewId", reviewId);
                reviewObject.addProperty("userId", userId);
                reviewObject.addProperty("userName", userName);
                reviewObject.addProperty("vendorId", vendorId);
                reviewObject.addProperty("serviceId", serviceId);
                reviewObject.addProperty("bookingId", bookingId);
                reviewObject.addProperty("reviewDate", currentDate);
            } else {
                // Update existing review
                reviewObject = null;
                
                // Find the review to update
                for (JsonElement element : reviewsArray) {
                    JsonObject review = element.getAsJsonObject();
                    if (reviewId.equals(review.get("reviewId").getAsString())) {
                        // Verify ownership
                        if (!userId.equals(review.get("userId").getAsString())) {
                            result.addProperty("status", "error");
                            result.addProperty("message", "You do not have permission to edit this review");
                            return result;
                        }
                        reviewObject = review;
                        break;
                    }
                }
                
                if (reviewObject == null) {
                    result.addProperty("status", "error");
                    result.addProperty("message", "Review not found");
                    return result;
                }
            }
            
            // Update review data
            reviewObject.addProperty("rating", Float.parseFloat(rating));
            reviewObject.addProperty("comment", comment);
            reviewObject.addProperty("status", status);
            reviewObject.addProperty("lastUpdated", currentDate);
            
            // For published reviews being edited or new reviews being published
            if (("published".equals(status) && !isNewReview && isEdit) || 
                (isNewReview && "published".equals(status))) {
                reviewObject.addProperty("reviewDate", currentDate);
            }
            
            // Handle detailed ratings
            JsonObject detailedRatings = new JsonObject();
            float qualityRatingValue = Float.parseFloat(qualityRating);
            float valueRatingValue = Float.parseFloat(valueRating);
            float responsivenessRatingValue = Float.parseFloat(responsivenessRating);
            float professionalismRatingValue = Float.parseFloat(professionalismRating);
            
            detailedRatings.addProperty("quality", qualityRatingValue);
            detailedRatings.addProperty("value", valueRatingValue);
            detailedRatings.addProperty("responsiveness", responsivenessRatingValue);
            detailedRatings.addProperty("professionalism", professionalismRatingValue);
            
            // Add flexibility with average of other ratings
            float flexibilityRating = (qualityRatingValue + responsivenessRatingValue + professionalismRatingValue) / 3;
            detailedRatings.addProperty("flexibility", Math.round(flexibilityRating * 10) / 10f);
            
            reviewObject.add("detailedRatings", detailedRatings);
            
            // Calculate helpful count based on detailed ratings
            // Formula: (sum of all detailed ratings / 25) * 10
            // This way, higher ratings will have higher helpful counts
            float totalDetailedRating = qualityRatingValue + valueRatingValue + 
                responsivenessRatingValue + professionalismRatingValue + flexibilityRating;
            int helpfulCount = Math.round((totalDetailedRating / 25) * 10);
            
            // Initialize other fields for new reviews
            if (isNewReview) {
                reviewObject.addProperty("helpfulCount", helpfulCount);
                reviewObject.addProperty("flagged", false);
                reviewObject.addProperty("verifiedBooking", true);
                reviewObject.add("photoUrls", new JsonArray());
            } else {
                // Update helpful count for existing review
                reviewObject.addProperty("helpfulCount", helpfulCount);
            }
            
            // Handle photo uploads
            Collection<Part> parts = request.getParts();
            JsonArray photoUrls;
            
            if (isNewReview) {
                photoUrls = new JsonArray();
            } else {
                photoUrls = reviewObject.getAsJsonArray("photoUrls");
            }
            
            // Process existing photos if provided
            String existingPhotosJson = request.getParameter("existingPhotos");
            if (existingPhotosJson != null && !existingPhotosJson.isEmpty()) {
                // Parse existing photos
                try {
                    JsonArray existingPhotos = JsonParser.parseString(existingPhotosJson).getAsJsonArray();
                    
                    // Create new array to replace the old one
                    photoUrls = existingPhotos;
                } catch (Exception e) {
                    // If JSON parsing fails, log the error but continue
                    System.err.println("Error parsing existing photos: " + e.getMessage());
                }
            }
            
            // Process new photo uploads
            for (Part part : parts) {
                if (part != null && part.getName().equals("reviewPhotos") && 
                    part.getContentType() != null && part.getContentType().startsWith("image/") && 
                    part.getSize() > 0) {
                    
                    // Create directory if it doesn't exist
                    File uploadDir = new File(REVIEW_PHOTOS_DIR);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }
                    
                    // Generate unique filename
                    String fileName = "review_" + reviewId + "_" + System.currentTimeMillis() + getFileExtension(part);
                    String filePath = REVIEW_PHOTOS_DIR + File.separator + fileName;
                    
                    // Save file
                    part.write(filePath);
                    
                    // Add file URL to photoUrls
                    String photoUrl = "/resources/user/reviews/" + fileName;
                    photoUrls.add(photoUrl);
                }
            }
            
            // Update photoUrls in review object
            reviewObject.add("photoUrls", photoUrls);
            
            // Add new review to array if needed
            if (isNewReview) {
                reviewsArray.add(reviewObject);
            }
            
            // Save updated reviews to file
            reviewsObject.add("reviews", reviewsArray);
            writeFile(REVIEWS_FILE_PATH, gson.toJson(reviewsObject));
            
            result.addProperty("status", "success");
            if (isEdit) {
                result.addProperty("message", "Review updated successfully");
            } else {
                result.addProperty("message", isNewReview ? "Review created successfully" : "Review updated successfully");
            }
            
        } catch (Exception e) {
            result.addProperty("status", "error");
            result.addProperty("message", "Error processing review: " + e.getMessage());
            e.printStackTrace();
        }
        
        return result;
    }
    
    /**
     * Delete a review
     */
    private JsonObject deleteReview(HttpServletRequest request, String userId) throws IOException {
        JsonObject result = new JsonObject();
        
        // Get review ID from request
        String reviewId = request.getParameter("reviewId");
        
        if (reviewId == null || reviewId.isEmpty()) {
            result.addProperty("status", "error");
            result.addProperty("message", "Review ID is required");
            return result;
        }
        
        // Get the reviews JSON file
        String reviewsJson = readFile(REVIEWS_FILE_PATH);
        JsonObject reviewsObject = JsonParser.parseString(reviewsJson).getAsJsonObject();
        JsonArray reviewsArray = reviewsObject.getAsJsonArray("reviews");
        
        // Find the review to delete
        boolean found = false;
        int indexToRemove = -1;
        
        for (int i = 0; i < reviewsArray.size(); i++) {
            JsonObject review = reviewsArray.get(i).getAsJsonObject();
            if (reviewId.equals(review.get("reviewId").getAsString())) {
                // Verify ownership
                if (!userId.equals(review.get("userId").getAsString())) {
                    result.addProperty("status", "error");
                    result.addProperty("message", "You do not have permission to delete this review");
                    return result;
                }
                found = true;
                indexToRemove = i;
                break;
            }
        }
        
        if (!found) {
            result.addProperty("status", "error");
            result.addProperty("message", "Review not found");
            return result;
        }
        
        // Remove review from array
        reviewsArray.remove(indexToRemove);
        
        // Save updated reviews to file
        reviewsObject.add("reviews", reviewsArray);
        writeFile(REVIEWS_FILE_PATH, gson.toJson(reviewsObject));
        
        result.addProperty("status", "success");
        result.addProperty("message", "Review deleted successfully");
        
        return result;
    }
    
    /**
     * Helper method to read file content
     */
    private String readFile(String filePath) throws IOException {
        byte[] encoded = Files.readAllBytes(Paths.get(filePath));
        return new String(encoded);
    }
    
    /**
     * Helper method to write content to file
     */
    private void writeFile(String filePath, String content) throws IOException {
        Files.write(Paths.get(filePath), content.getBytes());
    }
    
    /**
     * Helper method to get file extension from Part
     */
    private String getFileExtension(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                String filename = token.substring(token.indexOf("=") + 2, token.length() - 1);
                int dotIndex = filename.lastIndexOf(".");
                return dotIndex > 0 ? filename.substring(dotIndex) : "";
            }
        }
        
        return "";
    }
}