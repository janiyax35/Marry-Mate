<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.google.gson.JsonObject, com.google.gson.JsonArray, com.google.gson.JsonElement, java.time.LocalDate, java.time.format.DateTimeFormatter" %>
<%
    // Get current session information
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String userId = (String) session.getAttribute("userId");
    boolean isLoggedIn = (username != null && !username.isEmpty());
    
    // If user is not logged in, redirect to login page
    if (!isLoggedIn) {
        response.sendRedirect(request.getContextPath() + "/login.jsp?redirect=BookServiceServlet");
        return;
    }
    
    // Get service details from request attributes or parameters
    String serviceId = request.getParameter("serviceId");
    String bookingId = request.getParameter("bookingId");
    String bookingAction = request.getParameter("bookingAction");
    
    // Check if we have the necessary parameters
    if (serviceId == null || serviceId.isEmpty()) {
        response.sendRedirect(request.getContextPath() + "/VendorServicesServlet");
        return;
    }
    
    // Get service and booking info from request attributes (set by servlet)
    JsonObject serviceDetails = (JsonObject) request.getAttribute("serviceDetails");
    JsonObject bookingDetails = (JsonObject) request.getAttribute("bookingDetails");
    JsonObject vendorDetails = (JsonObject) request.getAttribute("vendorDetails");
    
    // If service details not found, show error
    boolean hasServiceDetails = (serviceDetails != null);
    
    // Current date for min date in date picker (cannot book in the past)
    LocalDate today = LocalDate.now();
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    String todayFormatted = today.format(dateFormatter);
    
    // Calculate one year from now for max date in date picker
    LocalDate oneYearFromNow = today.plusYears(1);
    String oneYearFromNowFormatted = oneYearFromNow.format(dateFormatter);
    
    // Current date and time for documentation
    String currentDateTime = "2025-05-15 14:18:03";
    String currentUser = "IT24102137";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Marry Mate - Book your wedding service">
    <title>Book Service | Marry Mate</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- AOS - Animate On Scroll -->
    <link rel="stylesheet" href="https://unpkg.com/aos@next/dist/aos.css" />
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Flatpickr for Date/Time Picker -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/flatpickr/dist/flatpickr.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/others/vendor-services.css">
    <style>
        /* Additional booking form styles */
        .booking-form-section {
            padding: 100px 0;
            background-color: #f8f9fa;
        }
        
        .booking-form-container {
            background: white;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.05);
            padding: 30px;
        }
        
        .booking-form-header {
            margin-bottom: 25px;
            text-align: center;
        }
        
        .booking-form-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 2.2rem;
            margin-bottom: 10px;
            color: var(--primary);
        }
        
        .booking-form-header p {
            color: var(--text-medium);
            margin-bottom: 0;
        }
        
        .service-summary {
            background-color: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 25px;
        }
        
        .service-summary-header {
            display: flex;
            align-items: flex-start;
            margin-bottom: 15px;
        }
        
        .service-image {
            width: 80px;
            height: 80px;
            border-radius: 10px;
            overflow: hidden;
            margin-right: 15px;
            flex-shrink: 0;
        }
        
        .service-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .service-details h3 {
            font-size: 1.3rem;
            margin-bottom: 5px;
        }
        
        .service-details .vendor-name {
            color: var(--text-medium);
            font-size: 0.9rem;
            margin-bottom: 5px;
            display: block;
        }
        
        .service-details .service-category {
            display: inline-block;
            background: var(--accent);
            color: white;
            padding: 2px 8px;
            font-size: 0.75rem;
            border-radius: 20px;
            margin-top: 5px;
        }
        
        .form-section {
            margin-bottom: 30px;
        }
        
        .form-section-title {
            font-family: 'Playfair Display', serif;
            font-size: 1.4rem;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
            color: var(--primary);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-label {
            font-weight: 500;
            margin-bottom: 8px;
        }
        
        .form-control {
            border-radius: 8px;
            border: 1px solid #ced4da;
            padding: 10px 15px;
        }
        
        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 0.25rem rgba(26, 54, 93, 0.1);
        }
        
        .option-item {
            background: #f9f9f9;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        
        .option-info {
            flex: 1;
        }
        
        .option-name {
            font-weight: 500;
            margin-bottom: 5px;
        }
        
        .option-description {
            font-size: 0.85rem;
            color: var(--text-medium);
        }
        
        .option-price {
            font-weight: 600;
            color: var(--primary);
            margin-left: 15px;
        }
        
        .booking-summary {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
        }
        
        .booking-summary h4 {
            font-size: 1.2rem;
            margin-bottom: 15px;
        }
        
        .summary-item {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        
        .summary-item:last-child {
            border-bottom: none;
        }
        
        .summary-label {
            color: var(--text-medium);
        }
        
        .summary-total {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--primary);
            padding-top: 15px;
            margin-top: 15px;
            border-top: 2px solid #ddd;
        }
        
        .btn-booking {
            padding: 12px 25px;
            font-size: 1rem;
            border-radius: 50px;
        }
        
        /* For time inputs */
        .time-inputs {
            display: flex;
            gap: 10px;
        }
        
        .time-inputs .form-control {
            width: 100%;
        }
        
        /* Time inputs */
        input[type="time"]::-webkit-calendar-picker-indicator {
            filter: invert(0.5);
        }
        
        /* Guest counter */
        .guest-counter {
            display: flex;
            align-items: center;
            border: 1px solid #ced4da;
            border-radius: 8px;
            overflow: hidden;
        }
        
        .guest-counter-btn {
            background: #f1f3f5;
            border: none;
            padding: 10px 15px;
            font-size: 1.2rem;
            cursor: pointer;
            transition: background 0.2s;
        }
        
        .guest-counter-btn:hover {
            background: #e9ecef;
        }
        
        .guest-counter-value {
            flex: 1;
            text-align: center;
            font-size: 1rem;
            font-weight: 500;
            padding: 10px;
        }
    </style>
</head>

<body>
    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-light fixed-top">
        <div class="container">
            <!-- Logo -->
            <a class="navbar-brand" href="${pageContext.request.contextPath}/">
                <div class="logo-container">
                    <i class="fas fa-heart"></i>
                    <i class="fas fa-ring"></i>
                </div>
                <span>Marry Mate</span>
            </a>
            
            <!-- Mobile Toggle Button -->
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <!-- Navigation Links -->
            <div class="collapse navbar-collapse" id="navbarContent">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/VendorServicesServlet">Vendors</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/views/wedding-guides.jsp">Wedding Guides</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/views/about.jsp">About Us</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/views/contact.jsp">Contact</a>
                    </li>
                </ul>
                
                <!-- Authentication Buttons -->
                <div class="auth-buttons">
                    <% if (isLoggedIn) { %>
                        <div class="dropdown">
                            <button class="btn btn-outline-primary dropdown-toggle" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-user-circle me-1"></i> <%= username %>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                                <% if ("admin".equals(role)) { %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard.jsp">Admin Dashboard</a></li>
                                <% } else if ("super_admin".equals(role)) { %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard.jsp">Admin Dashboard</a></li>
                                <% } else if ("vendor".equals(role)) { %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/vendor/dashboard.jsp">Vendor Dashboard</a></li>
                                <% } else { %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/user/dashboard.jsp">My Dashboard</a></li>
                                <% } %>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/user/profile.jsp">Profile Settings</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/LogoutServlet">Sign Out</a></li>
                            </ul>
                        </div>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline-primary me-2">Sign In</a>
                        <a href="${pageContext.request.contextPath}/signup.jsp" class="btn btn-primary">Join Now</a>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <section class="booking-form-section">
        <div class="container">
            <% if (!hasServiceDetails) { %>
                <div class="row">
                    <div class="col-12">
                        <div class="alert alert-danger text-center" role="alert">
                            <i class="fas fa-exclamation-circle fa-2x mb-3"></i>
                            <h3>Service Not Found</h3>
                            <p>We couldn't retrieve the details for the service you're trying to book.</p>
                            <a href="${pageContext.request.contextPath}/VendorServicesServlet" class="btn btn-primary mt-3">
                                <i class="fas fa-arrow-left me-2"></i> Back to Services
                            </a>
                        </div>
                    </div>
                </div>
            <% } else { 
                // Extract service information for easier usage
                String serviceName = serviceDetails.has("name") ? serviceDetails.get("name").getAsString() : "Unnamed Service";
                String category = serviceDetails.has("category") ? serviceDetails.get("category").getAsString() : "";
                String description = serviceDetails.has("description") ? serviceDetails.get("description").getAsString() : "";
                double basePrice = serviceDetails.has("basePrice") ? serviceDetails.get("basePrice").getAsDouble() : 0.0;
                String priceModel = serviceDetails.has("priceModel") ? serviceDetails.get("priceModel").getAsString() : "fixed";
                double hourlyRate = serviceDetails.has("hourlyRate") ? serviceDetails.get("hourlyRate").getAsDouble() : 0.0;
                double perGuestRate = serviceDetails.has("perGuestRate") ? serviceDetails.get("perGuestRate").getAsDouble() : 0.0;
                int baseDuration = serviceDetails.has("baseDuration") ? serviceDetails.get("baseDuration").getAsInt() : 0;
                int baseGuestCount = serviceDetails.has("baseGuestCount") ? serviceDetails.get("baseGuestCount").getAsInt() : 0;
                String imageUrl = serviceDetails.has("images") && serviceDetails.getAsJsonObject("images").has("icon") ? 
                                  serviceDetails.getAsJsonObject("images").get("icon").getAsString() : "/resources/vendor/serviceImages/default.jpg";
                
                String vendorName = "Unknown Vendor";
                if (vendorDetails != null && vendorDetails.has("businessName")) {
                    vendorName = vendorDetails.get("businessName").getAsString();
                } else if (serviceDetails.has("vendorName")) {
                    vendorName = serviceDetails.get("vendorName").getAsString();
                }
                
                // Determine if we have additional options
                boolean hasOptions = serviceDetails.has("additionalOptions") && 
                                     serviceDetails.getAsJsonArray("additionalOptions").size() > 0;
            %>
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="booking-form-container" data-aos="fade-up">
                        <div class="booking-form-header">
                            <h1>Book Your Wedding Service</h1>
                            <p>Please provide your wedding details and service preferences</p>
                        </div>
                        
                        <!-- Service Summary -->
                        <div class="service-summary">
                            <div class="service-summary-header">
                                <div class="service-image">
                                    <img src="${pageContext.request.contextPath}<%= imageUrl %>" alt="<%= serviceName %>">
                                </div>
                                <div class="service-details">
                                    <h3><%= serviceName %></h3>
                                    <span class="vendor-name">by <%= vendorName %></span>
                                    <span class="service-category"><%= category %></span>
                                </div>
                            </div>
                            
                            <div class="service-description">
                                <p><%= description %></p>
                            </div>
                        </div>
                        
                        <!-- Booking Form -->
                        <form id="bookingForm" action="${pageContext.request.contextPath}/BookServiceServlet" method="post">
                            <!-- Hidden fields -->
                            <input type="hidden" name="serviceId" value="<%= serviceId %>">
                            <% if (bookingId != null && !bookingId.isEmpty()) { %>
                                <input type="hidden" name="bookingId" value="<%= bookingId %>">
                            <% } %>
                            <% if (bookingAction != null && !bookingAction.isEmpty()) { %>
                                <input type="hidden" name="bookingAction" value="<%= bookingAction %>">
                            <% } else { %>
                                <input type="hidden" name="bookingAction" value="create_new">
                            <% } %>
                            <input type="hidden" name="basePrice" value="<%= basePrice %>">
                            <input type="hidden" name="priceModel" value="<%= priceModel %>">
                            <input type="hidden" name="hourlyRate" value="<%= hourlyRate %>">
                            <input type="hidden" name="perGuestRate" value="<%= perGuestRate %>">
                            
                            <!-- Wedding Details Section -->
                            <div class="form-section">
                                <h2 class="form-section-title">Wedding Details</h2>
                                
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="weddingDate" class="form-label">Wedding Date</label>
                                            <input type="date" class="form-control" id="weddingDate" name="weddingDate" 
                                                   min="<%= todayFormatted %>" max="<%= oneYearFromNowFormatted %>" required>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="eventLocation" class="form-label">Event Location</label>
                                            <input type="text" class="form-control" id="eventLocation" name="eventLocation" 
                                                   placeholder="Enter your venue or event location" required>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="form-label">Event Time</label>
                                            <div class="time-inputs">
                                                <input type="time" class="form-control" id="eventStartTime" name="eventStartTime" required>
                                                <span class="align-self-center">to</span>
                                                <input type="time" class="form-control" id="eventEndTime" name="eventEndTime" required>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="form-label">Guest Count</label>
                                            <div class="guest-counter">
                                                <button type="button" class="guest-counter-btn" id="decreaseGuests">-</button>
                                                <span class="guest-counter-value" id="guestCountDisplay">50</span>
                                                <button type="button" class="guest-counter-btn" id="increaseGuests">+</button>
                                            </div>
                                            <input type="hidden" id="guestCount" name="guestCount" value="50">
                                        </div>
                                    </div>
                                </div>
                                
                                <% if (priceModel.equals("hourly")) { %>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label class="form-label">Service Hours</label>
                                            <div class="guest-counter">
                                                <button type="button" class="guest-counter-btn" id="decreaseHours">-</button>
                                                <span class="guest-counter-value" id="hoursCountDisplay"><%= baseDuration %></span>
                                                <button type="button" class="guest-counter-btn" id="increaseHours">+</button>
                                            </div>
                                            <input type="hidden" id="hours" name="hours" value="<%= baseDuration %>">
                                            <small class="text-muted">Base package includes <%= baseDuration %> hours</small>
                                        </div>
                                    </div>
                                </div>
                                <% } %>
                                
                                <div class="form-group">
                                    <label for="specialRequirements" class="form-label">Special Requirements</label>
                                    <textarea class="form-control" id="specialRequirements" name="specialRequirements" 
                                              rows="4" placeholder="Any special requests or requirements for the vendor?"></textarea>
                                </div>
                            </div>
                            
                            <!-- Additional Options Section -->
                            <% if (hasOptions) {
                                JsonArray options = serviceDetails.getAsJsonArray("additionalOptions");
                            %>
                            <div class="form-section">
                                <h2 class="form-section-title">Additional Options</h2>
                                
                                <div class="options-list">
                                    <% for (int i = 0; i < options.size(); i++) {
                                        JsonObject option = options.get(i).getAsJsonObject();
                                        String optionId = option.has("optionId") ? option.get("optionId").getAsString() : "";
                                        String optionName = option.has("name") ? option.get("name").getAsString() : "";
                                        String optionDescription = option.has("description") ? option.get("description").getAsString() : "";
                                        double optionPrice = option.has("price") ? option.get("price").getAsDouble() : 0.0;
                                    %>
                                    <div class="option-item">
                                        <div class="form-check option-info">
                                            <input class="form-check-input option-checkbox" type="checkbox" 
                                                   name="selectedOptions" value="<%= optionId %>" 
                                                   id="option-<%= optionId %>" data-price="<%= optionPrice %>">
                                            <label class="form-check-label" for="option-<%= optionId %>">
                                                <div class="option-name"><%= optionName %></div>
                                                <div class="option-description"><%= optionDescription %></div>
                                            </label>
                                        </div>
                                        <div class="option-price">+$<%= String.format("%.2f", optionPrice) %></div>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                            <% } %>
                            
                            <!-- Booking Summary -->
                            <div class="form-section">
                                <h2 class="form-section-title">Booking Summary</h2>
                                
                                <div class="booking-summary">
                                    <div class="summary-item">
                                        <div class="summary-label">Base Price</div>
                                        <div class="summary-value">$<%= String.format("%.2f", basePrice) %></div>
                                    </div>
                                    
                                    <% if (priceModel.equals("hourly")) { %>
                                    <div class="summary-item" id="additionalHoursCost" style="display: none;">
                                        <div class="summary-label">Additional Hours</div>
                                        <div class="summary-value">$0.00</div>
                                    </div>
                                    <% } %>
                                    
                                    <% if (priceModel.equals("per_guest")) { %>
                                    <div class="summary-item" id="additionalGuestsCost" style="display: none;">
                                        <div class="summary-label">Additional Guests</div>
                                        <div class="summary-value">$0.00</div>
                                    </div>
                                    <% } %>
                                    
                                    <div class="summary-item" id="optionsCost" style="display: none;">
                                        <div class="summary-label">Additional Options</div>
                                        <div class="summary-value">$0.00</div>
                                    </div>
                                    
                                    <div class="summary-item summary-total">
                                        <div class="summary-label">Total</div>
                                        <div class="summary-value" id="totalPrice">$<%= String.format("%.2f", basePrice) %></div>
                                    </div>
                                </div>
                                
                                <!-- Hidden input for total price -->
                                <input type="hidden" name="totalPrice" id="totalPriceInput" value="<%= basePrice %>">
                            </div>
                            
                            <!-- Form Actions -->
                            <div class="form-actions d-flex justify-content-between mt-4">
                                <a href="${pageContext.request.contextPath}/VendorServicesServlet" class="btn btn-outline-secondary">
                                    Cancel
                                </a>
                                <button type="submit" class="btn btn-primary btn-booking">
                                    Complete Booking
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            <% } %>
        </div>
    </section>

    <!-- Footer -->
    <footer class="main-footer">
        <div class="container">
            <div class="footer-content">
                <div class="row">
                    <div class="col-md-4 mb-4">
                        <div class="footer-logo">
                            <div class="logo-icon">
                                <i class="fas fa-heart"></i>
                                <i class="fas fa-ring"></i>
                            </div>
                            <h3>Marry Mate</h3>
                        </div>
                        <p>Your complete wedding planning and vendor booking platform. Making dream weddings come true since 2023.</p>
                        <div class="social-icons">
                            <a href="#"><i class="fab fa-facebook-f"></i></a>
                            <a href="#"><i class="fab fa-instagram"></i></a>
                            <a href="#"><i class="fab fa-pinterest-p"></i></a>
                            <a href="#"><i class="fab fa-twitter"></i></a>
                        </div>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>Quick Links</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/views/vendor-categories.jsp">Find Vendors</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/wedding-guides.jsp">Wedding Guides</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/about.jsp">About Us</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/contact.jsp">Contact</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/blog.jsp">Blog</a></li>
                        </ul>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>For Couples</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/signup.jsp">Sign Up</a></li>
                            <li><a href="${pageContext.request.contextPath}/user/dashboard.jsp">Wedding Dashboard</a></li>
                            <li><a href="${pageContext.request.contextPath}/user/checklist.jsp">Planning Checklist</a></li>
                            <li><a href="${pageContext.request.contextPath}/user/budget.jsp">Budget Planner</a></li>
                            <li><a href="${pageContext.request.contextPath}/user/guest-list.jsp">Guest List</a></li>
                        </ul>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>For Vendors</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/signup.jsp?role=vendor">Join as Vendor</a></li>
                            <li><a href="${pageContext.request.contextPath}/vendor/dashboard.jsp">Vendor Dashboard</a></li>
                            <li><a href="${pageContext.request.contextPath}/vendor/pricing.jsp">Pricing</a></li>
                            <li><a href="${pageContext.request.contextPath}/vendor/success-stories.jsp">Success Stories</a></li>
                            <li><a href="${pageContext.request.contextPath}/vendor/faq.jsp">Vendor FAQ</a></li>
                        </ul>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>Support</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/views/help-center.jsp">Help Center</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/faq.jsp">FAQ</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/terms.jsp">Terms of Service</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/privacy.jsp">Privacy Policy</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/contact.jsp">Contact Support</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <div class="footer-bottom">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <p>&copy; 2025 Marry Mate. All rights reserved. | Current Date: <%= currentDateTime %> | Developer: <%= currentUser %></p>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <ul class="footer-bottom-links">
                            <li><a href="${pageContext.request.contextPath}/views/terms.jsp">Terms</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/privacy.jsp">Privacy</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/cookies.jsp">Cookies</a></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </footer>

    <!-- Back to Top Button -->
    <button id="back-to-top" class="back-to-top">
        <i class="fas fa-arrow-up"></i>
    </button>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- AOS - Animate On Scroll -->
    <script src="https://unpkg.com/aos@next/dist/aos.js"></script>
    
    <!-- Flatpickr for Date/Time Picker -->
    <script src="https://cdn.jsdelivr.net/npm/flatpickr"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/index.js"></script>
    
    <script>
        // Initialize AOS
        AOS.init({
            duration: 800,
            easing: 'ease-out',
            once: true,
            offset: 50
        });
        
        // Calculate the service end time based on start time and hours
        function calculateEndTime() {
            const startTime = document.getElementById('eventStartTime').value;
            const hours = parseInt(document.getElementById('hours')?.value || 0);
            
            if (startTime && hours > 0) {
                const startTimeParts = startTime.split(':');
                const startHours = parseInt(startTimeParts[0]);
                const startMinutes = parseInt(startTimeParts[1]);
                
                const endDate = new Date();
                endDate.setHours(startHours + hours);
                endDate.setMinutes(startMinutes);
                
                const endHours = ('0' + endDate.getHours()).slice(-2);
                const endMinutes = ('0' + endDate.getMinutes()).slice(-2);
                
                document.getElementById('eventEndTime').value = `${endHours}:${endMinutes}`;
            }
        }
        
        // Guest counter functionality
        document.getElementById('decreaseGuests').addEventListener('click', function() {
            const currentValue = parseInt(document.getElementById('guestCount').value);
            if (currentValue > 10) {
                const newValue = currentValue - 10;
                document.getElementById('guestCount').value = newValue;
                document.getElementById('guestCountDisplay').textContent = newValue;
                updatePrice();
            }
        });
        
        document.getElementById('increaseGuests').addEventListener('click', function() {
            const currentValue = parseInt(document.getElementById('guestCount').value);
            const newValue = currentValue + 10;
            document.getElementById('guestCount').value = newValue;
            document.getElementById('guestCountDisplay').textContent = newValue;
            updatePrice();
        });
        
        <% if (priceModel.equals("hourly")) { %>
        // Hours counter functionality
        document.getElementById('decreaseHours').addEventListener('click', function() {
            const currentValue = parseInt(document.getElementById('hours').value);
            if (currentValue > <%= baseDuration %>) {
                const newValue = currentValue - 1;
                document.getElementById('hours').value = newValue;
                document.getElementById('hoursCountDisplay').textContent = newValue;
                updatePrice();
                calculateEndTime();
            }
        });
        
        document.getElementById('increaseHours').addEventListener('click', function() {
            const currentValue = parseInt(document.getElementById('hours').value);
            const newValue = currentValue + 1;
            document.getElementById('hours').value = newValue;
            document.getElementById('hoursCountDisplay').textContent = newValue;
            updatePrice();
            calculateEndTime();
        });
        <% } %>
        
        // Update price when options are selected
        const optionCheckboxes = document.querySelectorAll('.option-checkbox');
        optionCheckboxes.forEach(checkbox => {
            checkbox.addEventListener('change', updatePrice);
        });
        
        // Update total price based on selections
        function updatePrice() {
            // Get base price
            let basePrice = parseFloat(document.getElementById('basePrice').value);
            let totalPrice = basePrice;
            let priceModel = document.getElementById('priceModel').value;
            
            // Additional hours cost
            <% if (priceModel.equals("hourly")) { %>
            const hours = parseInt(document.getElementById('hours').value);
            const baseDuration = <%= baseDuration %>;
            const hourlyRate = parseFloat(document.getElementById('hourlyRate').value);
            
            if (hours > baseDuration) {
                const additionalHours = hours - baseDuration;
                const additionalHoursCost = additionalHours * hourlyRate;
                totalPrice += additionalHoursCost;
                
                // Show additional hours in summary
                document.getElementById('additionalHoursCost').style.display = 'flex';
                document.getElementById('additionalHoursCost').querySelector('.summary-value').textContent = 
                    '$' + additionalHoursCost.toFixed(2);
            } else {
                document.getElementById('additionalHoursCost').style.display = 'none';
            }
            <% } %>
            
            // Additional guests cost
            <% if (priceModel.equals("per_guest")) { %>
            const guestCount = parseInt(document.getElementById('guestCount').value);
            const baseGuestCount = <%= baseGuestCount %>;
            const perGuestRate = parseFloat(document.getElementById('perGuestRate').value);
            
            if (guestCount > baseGuestCount) {
                const additionalGuests = guestCount - baseGuestCount;
                const additionalGuestsCost = additionalGuests * perGuestRate;
                totalPrice += additionalGuestsCost;
                
                // Show additional guests in summary
                document.getElementById('additionalGuestsCost').style.display = 'flex';
                document.getElementById('additionalGuestsCost').querySelector('.summary-value').textContent = 
                    '$' + additionalGuestsCost.toFixed(2);
            } else {
                document.getElementById('additionalGuestsCost').style.display = 'none';
            }
            <% } %>
            
            // Additional options cost
            let optionsCost = 0;
            optionCheckboxes.forEach(checkbox => {
                if (checkbox.checked) {
                    optionsCost += parseFloat(checkbox.dataset.price);
                }
            });
            
            if (optionsCost > 0) {
                totalPrice += optionsCost;
                document.getElementById('optionsCost').style.display = 'flex';
                document.getElementById('optionsCost').querySelector('.summary-value').textContent = 
                    '$' + optionsCost.toFixed(2);
            } else {
                document.getElementById('optionsCost').style.display = 'none';
            }
            
            // Update total price display and hidden input
            document.getElementById('totalPrice').textContent = '$' + totalPrice.toFixed(2);
            document.getElementById('totalPriceInput').value = totalPrice;
        }
        
        // Form validation and submission
        document.getElementById('bookingForm').addEventListener('submit', function(e) {
            const weddingDate = document.getElementById('weddingDate').value;
            const eventLocation = document.getElementById('eventLocation').value;
            const eventStartTime = document.getElementById('eventStartTime').value;
            const eventEndTime = document.getElementById('eventEndTime').value;
            
            if (!weddingDate || !eventLocation || !eventStartTime || !eventEndTime) {
                e.preventDefault();
                alert('Please fill all required fields.');
                return;
            }
            
            // Additional validations could be added here
        });
        
        // Initialize event listeners
        document.addEventListener('DOMContentLoaded', function() {
            // Initialize date picker with flatpickr
            flatpickr("#weddingDate", {
                dateFormat: "Y-m-d",
                minDate: "<%= todayFormatted %>",
                maxDate: "<%= oneYearFromNowFormatted %>"
            });
            
            // Set up eventStartTime change listener
            document.getElementById('eventStartTime').addEventListener('change', calculateEndTime);
        });
    </script>
</body>
</html>