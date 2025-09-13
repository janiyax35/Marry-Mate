<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.google.gson.JsonObject, com.google.gson.JsonArray, com.google.gson.JsonElement" %>
<%
    // Get service details from request
    JsonObject service = (JsonObject) request.getAttribute("service");
    
    if (service == null) {
        // If service is not found, show an error message
%>
<div class="modal-header">
    <h5 class="modal-title">Service Details</h5>
    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
</div>
<div class="modal-body">
    <div class="alert alert-danger">
        <i class="fas fa-exclamation-circle me-2"></i> Service details could not be loaded.
    </div>
</div>
<div class="modal-footer">
    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
</div>
<%
        return;
    }
    
    // Extract service data
    String serviceId = service.has("serviceId") ? service.get("serviceId").getAsString() : "";
    String name = service.has("name") ? service.get("name").getAsString() : "Unnamed Service";
    String description = service.has("description") ? service.get("description").getAsString() : "No description available.";
    double basePrice = service.has("basePrice") ? service.get("basePrice").getAsDouble() : 0.0;
    String category = service.has("category") ? service.get("category").getAsString() : "";
    String priceModel = service.has("priceModel") ? service.get("priceModel").getAsString() : "fixed";
    int baseDuration = service.has("baseDuration") ? service.get("baseDuration").getAsInt() : 0;
    
    // Get image URL
    String imageUrl = "/resources/vendor/serviceImages/default.jpg";
    if (service.has("images") && service.getAsJsonObject("images").has("icon")) {
        imageUrl = service.getAsJsonObject("images").get("icon").getAsString();
    }
    
    // Get vendor details if available
    String vendorName = "Unknown Vendor";
    double vendorRating = 0.0;
    int vendorReviewCount = 0;
    String vendorDescription = "No information available about this vendor.";
    String vendorImageUrl = "/resources/vendor/profileImages/default.jpg";
    String vendorPhone = "";
    String vendorEmail = "";
    String vendorWebsite = "";
    String vendorId = "";
    
    if (service.has("vendor")) {
        JsonObject vendor = service.getAsJsonObject("vendor");
        vendorName = vendor.has("businessName") ? vendor.get("businessName").getAsString() : vendorName;
        vendorRating = vendor.has("rating") ? vendor.get("rating").getAsDouble() : vendorRating;
        vendorReviewCount = vendor.has("reviewCount") ? vendor.get("reviewCount").getAsInt() : vendorReviewCount;
        vendorDescription = vendor.has("description") ? vendor.get("description").getAsString() : vendorDescription;
        vendorId = vendor.has("userId") ? vendor.get("userId").getAsString() : "";
        
        if (vendor.has("profilePictureUrl")) {
            vendorImageUrl = vendor.get("profilePictureUrl").getAsString();
        }
        
        if (vendor.has("phone")) {
            vendorPhone = vendor.get("phone").getAsString();
        }
        
        if (vendor.has("email")) {
            vendorEmail = vendor.get("email").getAsString();
        }
        
        if (vendor.has("websiteUrl")) {
            vendorWebsite = vendor.get("websiteUrl").getAsString();
        }
    }
    
    // Get additional options if available
    JsonArray additionalOptions = new JsonArray();
    if (service.has("additionalOptions")) {
        additionalOptions = service.getAsJsonArray("additionalOptions");
    }
    
    // Get reviews if available
    JsonArray reviews = new JsonArray();
    if (service.has("reviews")) {
        reviews = service.getAsJsonArray("reviews");
    }
    
    // Calculate average rating
    double averageRating = service.has("averageRating") ? service.get("averageRating").getAsDouble() : 0.0;
    
    // Helper function to generate star display for ratings
    String generateStars(double rating) {
        StringBuilder stars = new StringBuilder();
        for (int i = 1; i <= 5; i++) {
            if (i <= Math.floor(rating)) {
                stars.append("<i class=\"fas fa-star\"></i>");
            } else if (i - 0.5 <= rating) {
                stars.append("<i class=\"fas fa-star-half-alt\"></i>");
            } else {
                stars.append("<i class=\"far fa-star\"></i>");
            }
        }
        return stars.toString();
    }
    
    // Format price model text for display
    String getPriceModelText(String model) {
        switch (model) {
            case "hourly": return "per hour";
            case "per_guest": return "per guest";
            case "package": return "package price";
            case "fixed": return "fixed price";
            default: return "";
        }
    }
    
    // Current date and time for documentation
    String currentDateTime = "2025-05-15 14:23:12";
    String currentUser = "IT24102137";
%>

<div class="modal-header">
    <h5 class="modal-title"><%= name %></h5>
    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
</div>

<div class="modal-body">
    <div class="service-details-container">
        <div class="service-details-header">
            <div class="vendor-badge">
                By: <%= vendorName %>
                <div class="rating">
                    <%= generateStars(vendorRating) %>
                    <span><%= String.format("%.1f", vendorRating) %></span>
                </div>
            </div>
        </div>
        
        <ul class="nav nav-tabs" id="serviceDetailsTabs" role="tablist">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="details-tab" data-bs-toggle="tab" data-bs-target="#details" type="button" role="tab" aria-controls="details" aria-selected="true">Details</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="reviews-tab" data-bs-toggle="tab" data-bs-target="#reviews" type="button" role="tab" aria-controls="reviews" aria-selected="false">Reviews</button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="vendor-tab" data-bs-toggle="tab" data-bs-target="#vendor" type="button" role="tab" aria-controls="vendor" aria-selected="false">Vendor</button>
            </li>
        </ul>
        
        <div class="tab-content p-4" id="serviceDetailsTabsContent">
            <!-- Details Tab -->
            <div class="tab-pane fade show active" id="details" role="tabpanel" aria-labelledby="details-tab">
                <div class="row">
                    <div class="col-md-8">
                        <div class="service-image-large">
                            <img src="${pageContext.request.contextPath}<%= imageUrl %>" alt="<%= name %>">
                        </div>
                        <div class="service-description mt-4">
                            <h4>Service Description</h4>
                            <p><%= description %></p>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="service-info-card">
                            <div class="price-info">
                                <span class="price-label">Starting from</span>
                                <div class="price">$<%= String.format("%.2f", basePrice) %></div>
                                <span class="price-model"><%= getPriceModelText(priceModel) %></span>
                            </div>
                            
                            <div class="service-meta mt-3">
                                <div class="meta-item">
                                    <i class="fas fa-tag"></i>
                                    <span>Category: <%= category %></span>
                                </div>
                                <% if (baseDuration > 0) { %>
                                <div class="meta-item">
                                    <i class="fas fa-clock"></i>
                                    <span>Duration: <%= baseDuration %> <%= baseDuration > 1 ? "hours" : "hour" %></span>
                                </div>
                                <% } %>
                            </div>
                            
                            <% if (additionalOptions.size() > 0) { %>
                            <div class="additional-options mt-4">
                                <h5>Additional Options</h5>
                                <ul class="options-list">
                                    <% for (int i = 0; i < additionalOptions.size(); i++) {
                                        JsonObject option = additionalOptions.get(i).getAsJsonObject();
                                        String optionName = option.has("name") ? option.get("name").getAsString() : "";
                                        double optionPrice = option.has("price") ? option.get("price").getAsDouble() : 0.0;
                                    %>
                                    <li>
                                        <div class="option-name"><%= optionName %></div>
                                        <div class="option-price">$<%= String.format("%.2f", optionPrice) %></div>
                                    </li>
                                    <% } %>
                                </ul>
                            </div>
                            <% } else { %>
                            <div class="additional-options mt-4">
                                <h5>Additional Options</h5>
                                <p>No additional options available.</p>
                            </div>
                            <% } %>
                            
                            <button class="btn btn-primary btn-lg w-100 mt-4 book-now-btn" data-service-id="<%= serviceId %>">
                                Book This Service
                            </button>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Reviews Tab -->
            <div class="tab-pane fade" id="reviews" role="tabpanel" aria-labelledby="reviews-tab">
                <% if (reviews.size() > 0) { %>
                <div class="reviews-summary mb-4">
                    <div class="average-rating">
                        <div class="rating-number"><%= String.format("%.1f", averageRating) %></div>
                        <div class="stars">
                            <%= generateStars(averageRating) %>
                        </div>
                        <div class="review-count"><%= reviews.size() %> review<%= reviews.size() != 1 ? "s" : "" %></div>
                    </div>
                </div>
                
                <div class="reviews-list">
                    <% for (int i = 0; i < reviews.size(); i++) {
                        JsonObject review = reviews.get(i).getAsJsonObject();
                        String userName = review.has("userName") ? review.get("userName").getAsString() : "Anonymous";
                        String userPhotoUrl = review.has("userPhotoUrl") ? review.get("userPhotoUrl").getAsString() : "/assets/images/default-avatar.jpg";
                        String reviewDate = review.has("reviewDate") ? review.get("reviewDate").getAsString() : "";
                        double rating = review.has("rating") ? review.get("rating").getAsDouble() : 0.0;
                        String comment = review.has("comment") ? review.get("comment").getAsString() : "No comment provided.";
                        int helpfulCount = review.has("helpfulCount") ? review.get("helpfulCount").getAsInt() : 0;
                    %>
                    <div class="review-item">
                        <div class="review-header">
                            <div class="reviewer-info">
                                <img src="${pageContext.request.contextPath}<%= userPhotoUrl %>" alt="<%= userName %>">
                                <div>
                                    <h5><%= userName %></h5>
                                    <div class="review-date"><%= reviewDate %></div>
                                </div>
                            </div>
                            <div class="review-rating">
                                <%= generateStars(rating) %>
                                <span><%= String.format("%.1f", rating) %></span>
                            </div>
                        </div>
                        
                        <div class="review-content">
                            <p><%= comment %></p>
                            
                            <% 
                            // Show review photos if available
                            if (review.has("photoUrls")) {
                                JsonArray photoUrls = review.getAsJsonArray("photoUrls");
                                if (photoUrls.size() > 0) { 
                            %>
                            <div class="review-photos">
                                <% for (int j = 0; j < photoUrls.size(); j++) { 
                                    String photoUrl = photoUrls.get(j).getAsString();
                                %>
                                <img src="${pageContext.request.contextPath}<%= photoUrl %>" alt="Review photo <%= j+1 %>">
                                <% } %>
                            </div>
                            <% 
                                }
                            } 
                            
                            // Show vendor response if available
                            if (review.has("vendorResponse")) {
                                JsonObject response = review.getAsJsonObject("vendorResponse");
                                String responseText = response.has("text") ? response.get("text").getAsString() : "";
                                String responseDate = response.has("responseDate") ? response.get("responseDate").getAsString() : "";
                                if (!responseText.isEmpty()) {
                            %>
                            <div class="vendor-response">
                                <h6><i class="fas fa-reply"></i> Vendor Response</h6>
                                <p><%= responseText %></p>
                                <div class="response-date"><%= responseDate %></div>
                            </div>
                            <% 
                                }
                            } 
                            %>
                            
                            <div class="review-footer">
                                <div class="helpful-count">
                                    <i class="far fa-thumbs-up"></i>
                                    <span><%= helpfulCount %> found helpful</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% } else { %>
                <div class="no-reviews text-center py-4">
                    <i class="far fa-comment-alt fa-3x mb-3"></i>
                    <h4>No Reviews Yet</h4>
                    <p>Be the first to review this service after your booking.</p>
                </div>
                <% } %>
            </div>
            
            <!-- Vendor Tab -->
            <div class="tab-pane fade" id="vendor" role="tabpanel" aria-labelledby="vendor-tab">
                <div class="vendor-profile">
                    <div class="vendor-profile-header">
                        <div class="vendor-avatar">
                            <img src="${pageContext.request.contextPath}<%= vendorImageUrl %>" alt="<%= vendorName %>">
                        </div>
                        <div class="vendor-info">
                            <h3><%= vendorName %></h3>
                            <div class="vendor-meta">
                                <div class="vendor-rating">
                                    <%= generateStars(vendorRating) %>
                                    <span><%= String.format("%.1f", vendorRating) %></span>
                                    <span class="review-count">(<%= vendorReviewCount %> reviews)</span>
                                </div>
                                <div class="vendor-contact">
                                    <% if (!vendorPhone.isEmpty()) { %>
                                    <div><i class="fas fa-phone"></i> <%= vendorPhone %></div>
                                    <% } %>
                                    <% if (!vendorEmail.isEmpty()) { %>
                                    <div><i class="fas fa-envelope"></i> <%= vendorEmail %></div>
                                    <% } %>
                                    <% if (!vendorWebsite.isEmpty()) { %>
                                    <div><i class="fas fa-globe"></i> <a href="<%= vendorWebsite %>" target="_blank">Visit Website</a></div>
                                    <% } %>
                                    <% if (!vendorId.isEmpty()) { %>
                                    <div class="mt-2">
                                        <a href="${pageContext.request.contextPath}/VendorProfileServlet?id=<%= vendorId %>" class="btn btn-outline-primary btn-sm">
                                            <i class="fas fa-store me-1"></i> View Full Profile
                                        </a>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="vendor-description mt-4">
                        <h4>About the Vendor</h4>
                        <p><%= vendorDescription %></p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal-footer">
    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
    <button type="button" class="btn btn-primary book-now-btn" data-service-id="<%= serviceId %>">Book Now</button>
</div>

<script>
    // Script to handle "Book Now" button clicks
    document.querySelectorAll('.book-now-btn').forEach(button => {
        button.addEventListener('click', function() {
            const serviceId = this.getAttribute('data-service-id');
            
            // Close the modal
            const modal = bootstrap.Modal.getInstance(document.getElementById('serviceDetailsModal'));
            modal.hide();
            
            // Trigger the booking flow
            setTimeout(() => {
                const bookNowBtn = document.querySelector(`.book-now[data-service-id="${serviceId}"]`);
                if (bookNowBtn) {
                    bookNowBtn.click();
                } else {
                    window.location.href = '${pageContext.request.contextPath}/BookServiceServlet?serviceId=' + serviceId;
                }
            }, 300);
        });
    });
</script>