<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.util.ArrayList, com.google.gson.JsonObject, com.google.gson.JsonArray" %>
<%
    // Get current session information
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    boolean isLoggedIn = (username != null && !username.isEmpty());
    
    // Get services data from servlet request attributes
    List<JsonObject> services = (List<JsonObject>) request.getAttribute("services");
    if (services == null) {
        services = new ArrayList<>();
    }
    
    // Get categories for filtering
    List<JsonObject> categories = (List<JsonObject>) request.getAttribute("categories");
    if (categories == null) {
        categories = new ArrayList<>();
    }
    
    // Get selected filters
    String selectedCategory = (String) request.getAttribute("selectedCategory");
    if (selectedCategory == null) selectedCategory = "all";
    
    String selectedPriceRange = (String) request.getAttribute("selectedPriceRange");
    if (selectedPriceRange == null) selectedPriceRange = "";
    
    String sortOrder = (String) request.getAttribute("sortOrder");
    boolean isAscending = sortOrder == null || !sortOrder.equals("desc");
    
    // Current date and time for documentation
    String currentDateTime = "2025-05-15 15:55:07";
    String currentUser = "IT24102137";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Marry Mate - Find the perfect wedding vendors for your special day">
    <title>Wedding Vendors | Marry Mate</title>
    
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
    
    <!-- Nouislider - for price range slider -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/noUiSlider/15.6.1/nouislider.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/others/vendor-services.css">
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

    <!-- Page Banner -->
    <section class="page-banner">
        <div class="overlay"></div>
        <div class="container">
            <div class="row">
                <div class="col-12 text-center" data-aos="fade-up">
                    <h1>Wedding Vendors</h1>
                    <p class="lead">Find the perfect vendors for your dream wedding</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Main Content -->
    <section class="vendor-services-section section-padding">
        <div class="container">
            <div class="row">
                <!-- Sidebar Filters -->
                <div class="col-lg-3 mb-4" data-aos="fade-right">
                    <div class="filters-panel">
                        <h3>Filters</h3>
                        <form id="filterForm" action="${pageContext.request.contextPath}/FilterServicesServlet" method="post">
                            <!-- Category Filter -->
                            <div class="filter-group">
                                <h4>Categories</h4>
                                <div class="category-list">
                                    <div class="form-check">
                                        <input class="form-check-input category-filter" type="radio" name="category" id="category-all" value="all" <%= selectedCategory.equals("all") ? "checked" : "" %>>
                                        <label class="form-check-label" for="category-all">All Categories</label>
                                    </div>
                                    
                                    <% for (JsonObject category : categories) { 
                                        String catName = category.get("name").getAsString();
                                        String catDisplayName = catName.substring(0, 1).toUpperCase() + catName.substring(1);
                                        int count = category.get("serviceCount").getAsInt();
                                    %>
                                    <div class="form-check">
                                        <input class="form-check-input category-filter" type="radio" name="category" id="category-<%= catName %>" 
                                               value="<%= catName %>" <%= selectedCategory.equals(catName) ? "checked" : "" %>>
                                        <label class="form-check-label" for="category-<%= catName %>">
                                            <%= catDisplayName %> <span class="count">(<%= count %>)</span>
                                        </label>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                            
                            <!-- Price Range Filter -->
                            <div class="filter-group">
                                <h4>Price Range</h4>
                                <div class="price-slider-container">
                                    <div id="price-range"></div>
                                    <div class="price-inputs">
                                        <div class="price-input">
                                            <span>$</span>
                                            <input type="number" id="price-min" min="0" max="20000" value="0">
                                        </div>
                                        <div class="separator">to</div>
                                        <div class="price-input">
                                            <span>$</span>
                                            <input type="number" id="price-max" min="0" max="20000" value="20000">
                                        </div>
                                    </div>
                                    <input type="hidden" name="priceRange" id="price-range-hidden" value="<%= selectedPriceRange %>">
                                </div>
                            </div>
                            
                            <!-- Rating Filter -->
                            <div class="filter-group">
                                <h4>Rating</h4>
                                <div class="rating-list">
                                    <div class="form-check">
                                        <input class="form-check-input rating-filter" type="radio" name="minRating" id="rating-any" value="0" checked>
                                        <label class="form-check-label" for="rating-any">Any Rating</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input rating-filter" type="radio" name="minRating" id="rating-4" value="4">
                                        <label class="form-check-label" for="rating-4">
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="far fa-star"></i> & Up
                                        </label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input rating-filter" type="radio" name="minRating" id="rating-3" value="3">
                                        <label class="form-check-label" for="rating-3">
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="far fa-star"></i>
                                            <i class="far fa-star"></i> & Up
                                        </label>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Apply Filters Button -->
                            <button type="submit" class="btn btn-primary btn-block mt-4">Apply Filters</button>
                            <button type="button" id="resetFilters" class="btn btn-outline-secondary btn-block mt-2">Reset Filters</button>
                        </form>
                    </div>
                </div>
                
                <!-- Services Content -->
                <div class="col-lg-9" data-aos="fade-left">
                    <!-- Sort and View Controls -->
                    <div class="services-controls mb-4">
                        <div class="row align-items-center">
                            <div class="col-md-6 mb-3 mb-md-0">
                                <h2>Wedding Services</h2>
                                <p class="results-count"><%= services.size() %> services found</p>
                            </div>
                            <div class="col-md-6">
                                <div class="controls-wrapper d-flex justify-content-md-end">
                                    <div class="sort-control">
                                        <label for="sort-by">Sort by:</label>
                                        <select id="sort-by" class="form-select">
                                            <option value="price-asc" <%= (isAscending) ? "selected" : "" %>>Price: Low to High</option>
                                            <option value="price-desc" <%= (!isAscending) ? "selected" : "" %>>Price: High to Low</option>
                                            <option value="rating-desc">Rating: High to Low</option>
                                        </select>
                                    </div>
                                    <div class="view-control ms-2">
                                        <button class="btn btn-outline-secondary btn-sm active" data-view="grid"><i class="fas fa-th"></i></button>
                                        <button class="btn btn-outline-secondary btn-sm" data-view="list"><i class="fas fa-list"></i></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Services Grid -->
                    <div id="services-grid" class="row g-4">
                    <% if (services.size() == 0) { %>
                        <div class="col-12 text-center py-5">
                            <div class="no-results">
                                <i class="fas fa-search fa-3x mb-3"></i>
                                <h3>No services found</h3>
                                <p>Try adjusting your filters or searching for different terms.</p>
                            </div>
                        </div>
                    <% } else { 
                        for (JsonObject service : services) {
                            String serviceId = service.has("serviceId") ? service.get("serviceId").getAsString() : "";
                            String serviceName = service.has("name") ? service.get("name").getAsString() : "Unnamed Service";
                            String description = service.has("description") ? service.get("description").getAsString() : "";
                            double basePrice = service.has("basePrice") ? service.get("basePrice").getAsDouble() : 0.0;
                            String category = service.has("category") ? service.get("category").getAsString() : "";
                            String vendorName = service.has("vendorName") ? service.get("vendorName").getAsString() : "Unknown Vendor";
                            double vendorRating = service.has("vendorRating") ? service.get("vendorRating").getAsDouble() : 0.0;
                            String imageUrl = service.has("images") && service.getAsJsonObject("images").has("icon") ? 
                                        service.getAsJsonObject("images").get("icon").getAsString() : "/resources/vendor/serviceImages/default.jpg";
                            
                            // Limit description length
                            if (description.length() > 100) {
                                description = description.substring(0, 100) + "...";
                            }
                    %>
                        <div class="col-md-6 col-lg-4 service-card-container">
                            <div class="service-card">
                                <div class="service-image">
                                    <img src="${pageContext.request.contextPath}<%= imageUrl %>" alt="<%= serviceName %>">
                                    <span class="service-category"><%= category %></span>
                                </div>
                                <div class="service-info">
                                    <div class="vendor-info">
                                        <span class="vendor-name"><%= vendorName %></span>
                                        <div class="vendor-rating">
                                            <% for (int i = 1; i <= 5; i++) { %>
                                                <i class="<%= (i <= Math.round(vendorRating)) ? "fas" : "far" %> fa-star"></i>
                                            <% } %>
                                            <span><%= String.format("%.1f", vendorRating) %></span>
                                        </div>
                                    </div>
                                    <h3><%= serviceName %></h3>
                                    <p class="service-description"><%= description %></p>
                                    <div class="service-price">
                                        <span>Starting from</span>
                                        <div class="price">$<%= String.format("%.2f", basePrice) %></div>
                                    </div>
                                    <div class="service-actions">
                                        <button class="btn btn-outline-primary view-details" data-service-id="<%= serviceId %>">View Details</button>
                                        <button class="btn btn-primary book-now" data-service-id="<%= serviceId %>">Book Now</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <% } 
                    } %>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Service Details Modal -->
    <div class="modal fade" id="serviceDetailsModal" tabindex="-1" aria-labelledby="serviceDetailsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="serviceDetailsModalLabel">Service Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="text-center loading-spinner">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Loading service details...</p>
                    </div>
                    <div id="serviceDetailsContent" class="d-none">
                        <!-- Content will be loaded via AJAX -->
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Booking Options Modal -->
    <div class="modal fade" id="bookingOptionsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Booking Options</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>You already have active bookings. Would you like to:</p>
                    <div id="existingBookingsList" class="mb-4">
                        <!-- Existing bookings will be loaded here -->
                    </div>
                    <div class="d-flex justify-content-between">
                        <button class="btn btn-outline-primary" id="addToExistingBtn">Add to Existing Booking</button>
                        <button class="btn btn-primary" id="createNewBookingBtn">Create New Booking</button>
                    </div>
                </div>
            </div>
        </div>
    </div>

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
                        <p>Your complete wedding planning and vendor booking platform. Making dream weddings come true since 2020.</p>
                        <div class="social-icons">
                            <a href="https://www.facebook.com/janith.deshan.186"><i class="fab fa-facebook-f"></i></a>
                            <a href="https://www.instagram.com/janith_deshan11/"><i class="fab fa-instagram"></i></a>
                            <a href="https://www.linkedin.com/in/janith-deshan-60089a194/"><i class="fab fa-linkedin-in"></i></a>
                        </div>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>Quick Links</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/VendorServicesServlet">Find Vendors</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/wedding-guides.jsp">Wedding Guides</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/about.jsp">About Us</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/contact.jsp">Contact</a></li>
                            
                        </ul>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>For Couples</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/signup.jsp">Sign Up</a></li>
                            <li><a href="${pageContext.request.contextPath}/user/dashboard.jsp">Wedding Dashboard</a></li>
                        </ul>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>For Vendors</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/signup.jsp">Join now</a></li>
                            <li><a href="${pageContext.request.contextPath}/vendor/dashboard.jsp">Vendor Dashboard</a></li>

                        </ul>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>Support</h4>
                        <ul class="footer-links">
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
                        <p>&copy; 2025 Marry Mate. All rights reserved. | Developer: IT24102137</p>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <ul class="footer-bottom-links">
                            <li><a href="${pageContext.request.contextPath}/views/terms.jsp">Terms</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/privacy.jsp">Privacy
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
    
    <!-- noUiSlider for range sliders -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/noUiSlider/15.6.1/nouislider.min.js"></script>
    
    <!-- Custom JS -->
    <script>
        // Define the context path for JavaScript to use
        const contextPath = "${pageContext.request.contextPath}";
        // Pass isLoggedIn to JavaScript
        const isLoggedIn = <%= isLoggedIn %>;
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/index.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/others/vendor-services.js"></script>
</body>
</html>