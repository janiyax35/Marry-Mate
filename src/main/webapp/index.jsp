<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter, java.io.*, java.util.*, com.google.gson.Gson, com.google.gson.JsonObject, com.google.gson.JsonArray, com.google.gson.JsonElement" %>
<%
    // Get current session information
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    boolean isLoggedIn = (username != null && !username.isEmpty());
    
    // Generate timestamp for analytics
    String accessTimestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    
    // Current date and time for documentation
    String currentDateTime = "2025-05-18 12:43:21";
    String currentUser = "IT24100905";
    
    // Initialize data
    List<Map<String, Object>> featuredVendors = new ArrayList<>();
    List<Map<String, Object>> testimonials = new ArrayList<>();
    List<Map<String, Object>> categories = new ArrayList<>();
    int userCount = 0;
    int vendorCount = 0;
    
    // Read vendor data
    try {
        // Hard-coded file path as requested
        String vendorFilePath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
        BufferedReader vendorReader = new BufferedReader(new FileReader(vendorFilePath));
        Gson gson = new Gson();
        JsonObject vendorData = gson.fromJson(vendorReader, JsonObject.class);
        
        // Get vendor count
        JsonArray vendors = vendorData.getAsJsonArray("vendors");
        vendorCount = vendors.size();
        
        // Extract featured vendors
        for (JsonElement element : vendors) {
            JsonObject vendor = element.getAsJsonObject();
            if (vendor.has("featured") && vendor.get("featured").getAsBoolean()) {
                Map<String, Object> vendorMap = new HashMap<>();
                vendorMap.put("id", vendor.get("userId").getAsString());
                vendorMap.put("name", vendor.get("businessName").getAsString());
                
                // Get location (city from address)
                String address = vendor.get("address").getAsString();
                String location = "Location Varies";
                if (address != null && !address.isEmpty() && address.contains(",")) {
                    String[] parts = address.split(",");
                    if (parts.length > 1) {
                        location = parts[1].trim();
                    }
                }
                vendorMap.put("location", location);
                
                vendorMap.put("priceRange", vendor.get("priceRange").getAsString());
                vendorMap.put("rating", vendor.get("rating").getAsDouble());
                vendorMap.put("reviewCount", vendor.get("reviewCount").getAsInt());
                
                // Get primary category
                JsonArray vendorCategories = vendor.getAsJsonArray("categories");
                String category = vendorCategories.size() > 0 ? vendorCategories.get(0).getAsString() : "general";
                vendorMap.put("category", category);
                
                // For image, we'll use a placeholder since actual images might not be accessible
                vendorMap.put("image", "https://images.unsplash.com/photo-1519225421980-715cb0215aed?ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80");
                
                featuredVendors.add(vendorMap);
                
                // Limit to 4 featured vendors
                if (featuredVendors.size() >= 4) break;
            }
        }
        
        vendorReader.close();
    } catch (Exception e) {
        // If error, set default values
        vendorCount = 7;
    }
    
    // Read user data
    try {
        // Hard-coded file path as requested
        String userFilePath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\users.json";
        BufferedReader userReader = new BufferedReader(new FileReader(userFilePath));
        Gson gson = new Gson();
        JsonObject userData = gson.fromJson(userReader, JsonObject.class);
        
        // Get user count
        JsonArray users = userData.getAsJsonArray("users");
        userCount = users.size();
        
        userReader.close();
    } catch (Exception e) {
        // If error, set default value
        userCount = 8;
    }
    
    // Read reviews for testimonials
    try {
        // Hard-coded file path as requested
        String reviewFilePath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\reviews.json";
        BufferedReader reviewReader = new BufferedReader(new FileReader(reviewFilePath));
        Gson gson = new Gson();
        JsonObject reviewData = gson.fromJson(reviewReader, JsonObject.class);
        
        // Get reviews
        JsonArray reviews = reviewData.getAsJsonArray("reviews");
        
        for (JsonElement element : reviews) {
            JsonObject review = element.getAsJsonObject();
            
            // Only use published reviews with high ratings
            if (review.has("status") && "published".equals(review.get("status").getAsString()) && 
                review.has("rating") && review.get("rating").getAsDouble() >= 4.5) {
                
                Map<String, Object> reviewMap = new HashMap<>();
                reviewMap.put("userName", review.get("userName").getAsString());
                
                // Get comment (ensure it's not too long for display)
                String comment = review.get("comment").getAsString();
                if (comment.length() > 300) {
                    comment = comment.substring(0, 297) + "...";
                }
                reviewMap.put("comment", comment);
                
                // Get review date - format as Month Year
                String reviewDate = review.get("reviewDate").getAsString();
                if (reviewDate.length() >= 7) {
                    String year = reviewDate.substring(0, 4);
                    String month = reviewDate.substring(5, 7);
                    
                    // Convert month number to name
                    String[] months = {"", "January", "February", "March", "April", "May", "June", 
                                     "July", "August", "September", "October", "November", "December"};
                    int monthNum = Integer.parseInt(month);
                    if (monthNum >= 1 && monthNum <= 12) {
                        month = months[monthNum];
                    }
                    
                    reviewMap.put("formattedDate", month + " " + year);
                } else {
                    reviewMap.put("formattedDate", "2024");
                }
                
                // For image, we'll use a placeholder
                reviewMap.put("image", "https://images.unsplash.com/photo-1524623252636-db510bfb4128?ixlib=rb-1.2.1&auto=format&fit=crop&w=128&q=80");
                
                testimonials.add(reviewMap);
                
                // Limit to 3 testimonials
                if (testimonials.size() >= 3) break;
            }
        }
        
        reviewReader.close();
    } catch (Exception e) {
        // If no testimonials could be loaded, we'll add defaults in the JSP
    }
    
    // Read service categories
    try {
        // Hard-coded file path as requested
        String categoriesFilePath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\service-categories.json";
        BufferedReader categoriesReader = new BufferedReader(new FileReader(categoriesFilePath));
        Gson gson = new Gson();
        JsonArray categoriesData = gson.fromJson(categoriesReader, JsonArray.class);
        
        for (JsonElement element : categoriesData) {
            JsonObject category = element.getAsJsonObject();
            
            // Only use active categories
            if (category.has("active") && category.get("active").getAsBoolean()) {
                Map<String, Object> categoryMap = new HashMap<>();
                categoryMap.put("name", category.get("name").getAsString());
                
                // Set appropriate icon for category
                String icon = "th-large"; // default icon
                String categoryName = category.get("name").getAsString();
                
                if (categoryName.equals("photography")) icon = "camera";
                else if (categoryName.equals("videography")) icon = "video";
                else if (categoryName.equals("catering")) icon = "utensils";
                else if (categoryName.equals("venues")) icon = "landmark";
                else if (categoryName.equals("decoration")) icon = "paint-brush";
                else if (categoryName.equals("entertainment")) icon = "guitar";
                else if (categoryName.equals("planning")) icon = "clipboard-list";
                else if (categoryName.equals("beauty")) icon = "spa";
                else if (categoryName.equals("transportation")) icon = "car";
                else if (categoryName.equals("attire")) icon = "tshirt";
                else if (categoryName.equals("jewelry")) icon = "gem";
                else if (categoryName.equals("invitations")) icon = "envelope";
                else if (categoryName.equals("gifts")) icon = "gift";
                else if (categoryName.equals("flowers")) icon = "seedling";
                else if (categoryName.equals("rental")) icon = "chair";
                else if (categoryName.equals("cake")) icon = "birthday-cake";
                else if (categoryName.equals("honeymoon")) icon = "plane";
                
                categoryMap.put("icon", icon);
                categoryMap.put("serviceCount", category.get("serviceCount").getAsInt());
                categories.add(categoryMap);
            }
        }
        
        categoriesReader.close();
    } catch (Exception e) {
        // If error, we'll use default categories in the JSP
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Marry Mate - Your complete wedding planning and vendor booking platform">
    <title>Marry Mate | Wedding Planning Made Simple</title>
    
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
    
    <!-- Swiper CSS for Carousels -->
    <link rel="stylesheet" href="https://unpkg.com/swiper/swiper-bundle.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/VendorServicesServlet">Vendors</a>
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

    <!-- Hero Section -->
    <section class="hero">
        <div class="overlay"></div>
        <div class="container">
            <div class="row align-items-center min-vh-100">
                <div class="col-lg-6" data-aos="fade-right" data-aos-delay="200">
                    <h1>Your Dream Wedding Starts Here</h1>
                    <p class="lead">Find perfect vendors, plan your special day, and create memories that last a lifetime with Marry Mate.</p>
                    <div class="hero-buttons">
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet" class="btn btn-primary btn-lg">Find Vendors</a>
                        <a href="${pageContext.request.contextPath}/signup.jsp" class="btn btn-outline-light btn-lg">Start Planning</a>
                    </div>
                </div>
                <div class="col-lg-6 position-relative d-none d-lg-block" data-aos="fade-left" data-aos-delay="400">
                    <div class="floating-card card-1">
                        <img src="https://images.unsplash.com/photo-1519225421980-715cb0215aed?ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80" alt="Wedding Venue">
                        <div class="card-content">
                            <h4>Perfect Venues</h4>
                            <p>Find your dream location</p>
                        </div>
                    </div>
                    <div class="floating-card card-2">
                        <img src="https://images.unsplash.com/photo-1502301197179-65228ab57f78?ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80" alt="Wedding Photographer">
                        <div class="card-content">
                            <h4>Talented Photographers</h4>
                            <p>Capture timeless moments</p>
                        </div>
                    </div>
                    <div class="floating-card card-3">
                        <img src="https://images.unsplash.com/photo-1464979681340-bdd28a61699e?ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80" alt="Wedding Catering">
                        <div class="card-content">
                            <h4>Exquisite Catering</h4>
                            <p>Delight your guests</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Key Features Section -->
    <section class="features section-padding">
        <div class="container">
            <div class="section-header text-center" data-aos="fade-up">
                <h2>Everything You Need for Your Special Day</h2>
                <p>Plan your perfect wedding with our comprehensive features</p>
            </div>
            
            <div class="row g-4 mt-4">
                <div class="col-md-4" data-aos="fade-up" data-aos-delay="100">
                    <div class="feature-card">
                        <div class="icon">
                            <i class="fas fa-search"></i>
                        </div>
                        <h3>Find Trusted Vendors</h3>
                        <p>Discover and book pre-screened local wedding professionals for every aspect of your celebration.</p>
                    </div>
                </div>
                
                <div class="col-md-4" data-aos="fade-up" data-aos-delay="200">
                    <div class="feature-card">
                        <div class="icon">
                            <i class="fas fa-tasks"></i>
                        </div>
                        <h3>Planning Tools</h3>
                        <p>Stay organized with customizable checklists, budgeting tools, and timelines for a stress-free experience.</p>
                    </div>
                </div>
                
                <div class="col-md-4" data-aos="fade-up" data-aos-delay="300">
                    <div class="feature-card">
                        <div class="icon">
                            <i class="fas fa-calendar-check"></i>
                        </div>
                        <h3>Easy Booking</h3>
                        <p>Compare availability, prices, and reviews before booking your vendors with just a few clicks.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Vendor Categories Section -->
    <section class="vendor-categories section-padding bg-light">
        <div class="container">
            <div class="section-header text-center" data-aos="fade-up">
                <h2>Find Your Perfect Wedding Vendors</h2>
                <p>Explore our curated selection of top wedding professionals</p>
            </div>
            
            <div class="category-cards row g-4 mt-4">
                <% if (categories.size() > 0) { %>
                    <% int delay = 100; %>
                    <% for (int i = 0; i < Math.min(categories.size(), 7); i++) { %>
                        <% Map<String, Object> category = categories.get(i); %>
                        <div class="col-6 col-md-4 col-lg-3" data-aos="fade-up" data-aos-delay="<%= delay %>">
                            <a href="${pageContext.request.contextPath}/VendorServicesServlet?category=<%= category.get("name") %>" class="category-card">
                                <div class="icon">
                                    <i class="fas fa-<%= category.get("icon") %>"></i>
                                </div>
                                <h3><%= ((String)category.get("name")).substring(0, 1).toUpperCase() + ((String)category.get("name")).substring(1) %></h3>
                                <span>View All <i class="fas fa-arrow-right"></i></span>
                            </a>
                        </div>
                        <% delay += 100; %>
                    <% } %>
                <% } else { %>
                    <!-- Default categories if none loaded from JSON -->
                    <div class="col-6 col-md-4 col-lg-3" data-aos="fade-up" data-aos-delay="100">
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet?category=venues" class="category-card">
                            <div class="icon">
                                <i class="fas fa-landmark"></i>
                            </div>
                            <h3>Venues</h3>
                            <span>View All <i class="fas fa-arrow-right"></i></span>
                        </a>
                    </div>
                    
                    <div class="col-6 col-md-4 col-lg-3" data-aos="fade-up" data-aos-delay="200">
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet?category=photography" class="category-card">
                            <div class="icon">
                                <i class="fas fa-camera"></i>
                            </div>
                            <h3>Photographers</h3>
                            <span>View All <i class="fas fa-arrow-right"></i></span>
                        </a>
                    </div>
                    
                    <div class="col-6 col-md-4 col-lg-3" data-aos="fade-up" data-aos-delay="300">
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet?category=catering" class="category-card">
                            <div class="icon">
                                <i class="fas fa-utensils"></i>
                            </div>
                            <h3>Catering</h3>
                            <span>View All <i class="fas fa-arrow-right"></i></span>
                        </a>
                    </div>
                    
                    <div class="col-6 col-md-4 col-lg-3" data-aos="fade-up" data-aos-delay="400">
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet?category=flowers" class="category-card">
                            <div class="icon">
                                <i class="fas fa-seedling"></i>
                            </div>
                            <h3>Florists</h3>
                            <span>View All <i class="fas fa-arrow-right"></i></span>
                        </a>
                    </div>
                    
                    <div class="col-6 col-md-4 col-lg-3" data-aos="fade-up" data-aos-delay="500">
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet?category=music" class="category-card">
                            <div class="icon">
                                <i class="fas fa-music"></i>
                            </div>
                            <h3>Musicians & DJs</h3>
                            <span>View All <i class="fas fa-arrow-right"></i></span>
                        </a>
                    </div>
                    
                    <div class="col-6 col-md-4 col-lg-3" data-aos="fade-up" data-aos-delay="600">
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet?category=cake" class="category-card">
                            <div class="icon">
                                <i class="fas fa-birthday-cake"></i>
                            </div>
                            <h3>Cake Designers</h3>
                            <span>View All <i class="fas fa-arrow-right"></i></span>
                        </a>
                    </div>
                    
                    <div class="col-6 col-md-4 col-lg-3" data-aos="fade-up" data-aos-delay="700">
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet?category=attire" class="category-card">
                            <div class="icon">
                                <i class="fas fa-female"></i>
                            </div>
                            <h3>Bridal Wear</h3>
                            <span>View All <i class="fas fa-arrow-right"></i></span>
                        </a>
                    </div>
                <% } %>
                
                <!-- All Categories card (always show this one) -->
                <div class="col-6 col-md-4 col-lg-3" data-aos="fade-up" data-aos-delay="800">
                    <a href="${pageContext.request.contextPath}/VendorServicesServlet" class="category-card view-all">
                        <div class="icon">
                            <i class="fas fa-th-large"></i>
                        </div>
                        <h3>All Categories</h3>
                        <span>Browse All <i class="fas fa-arrow-right"></i></span>
                    </a>
                </div>
            </div>
        </div>
    </section>

    <!-- Featured Vendors Section -->
    <section class="featured-vendors section-padding">
        <div class="container">
            <div class="section-header text-center" data-aos="fade-up">
                <h2>Top-Rated Wedding Vendors</h2>
                <p>Discover our most loved wedding professionals</p>
            </div>
            
            <div class="swiper vendor-swiper mt-5">
                <div class="swiper-wrapper">
                    <% if (featuredVendors.size() > 0) { %>
                        <% int delay = 100; %>
                        <% for (Map<String, Object> vendor : featuredVendors) { %>
                            <div class="swiper-slide" data-aos="fade-up" data-aos-delay="<%= delay %>">
                                <div class="vendor-card">
                                    <div class="vendor-img">
                                        <img src="<%= vendor.get("image") %>" alt="<%= vendor.get("name") %>">
                                        <div class="vendor-category"><%= ((String)vendor.get("category")).substring(0, 1).toUpperCase() + ((String)vendor.get("category")).substring(1) %></div>
                                    </div>
                                    <div class="vendor-info">
                                        <div class="vendor-rating">
                                            <% double rating = (Double)vendor.get("rating"); %>
                                            <% for (int i = 1; i <= 5; i++) { %>
                                                <% if (i <= Math.floor(rating)) { %>
                                                    <i class="fas fa-star"></i>
                                                <% } else if (i - rating > 0 && i - rating < 1) { %>
                                                    <i class="fas fa-star-half-alt"></i>
                                                <% } else { %>
                                                    <i class="far fa-star"></i>
                                                <% } %>
                                            <% } %>
                                            <span>(<%= vendor.get("reviewCount") %>)</span>
                                        </div>
                                        <h3><%= vendor.get("name") %></h3>
                                        <p class="location"><i class="fas fa-map-marker-alt"></i> <%= vendor.get("location") %></p>
                                        <p class="price">Starting from $<%= vendor.get("priceRange") %></p>
                                        <a href="${pageContext.request.contextPath}/VendorDetailsServlet?id=<%= vendor.get("id") %>" class="btn btn-outline-primary">View Details</a>
                                    </div>
                                </div>
                            </div>
                            <% delay += 100; %>
                        <% } %>
                    <% } else { %>
                        <!-- Default vendor cards if none loaded from JSON -->
                        <div class="swiper-slide" data-aos="fade-up" data-aos-delay="100">
                            <div class="vendor-card">
                                <div class="vendor-img">
                                    <img src="https://images.unsplash.com/photo-1519167758481-83f550bb49b3?ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80" alt="Enchanted Gardens Venue">
                                    <div class="vendor-category">Venue</div>
                                </div>
                                <div class="vendor-info">
                                    <div class="vendor-rating">
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <span>(48)</span>
                                    </div>
                                    <h3>Enchanted Gardens</h3>
                                    <p class="location"><i class="fas fa-map-marker-alt"></i> New York, NY</p>
                                    <p class="price">Starting from $5,000</p>
                                    <a href="${pageContext.request.contextPath}/VendorDetailsServlet?id=V1003" class="btn btn-outline-primary">View Details</a>
                                </div>
                            </div>
                        </div>
                        
                        <div class="swiper-slide" data-aos="fade-up" data-aos-delay="200">
                            <div class="vendor-card">
                                <div class="vendor-img">
                                    <img src="https://images.unsplash.com/photo-1527529482837-4698179dc6ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80" alt="Artistic Moments Photography">
                                    <div class="vendor-category">Photography</div>
                                </div>
                                <div class="vendor-info">
                                    <div class="vendor-rating">
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star-half-alt"></i>
                                        <span>(36)</span>
                                    </div>
                                    <h3>Artistic Moments</h3>
                                    <p class="location"><i class="fas fa-map-marker-alt"></i> Los Angeles, CA</p>
                                    <p class="price">Starting from $2,500</p>
                                    <a href="${pageContext.request.contextPath}/VendorDetailsServlet?id=V1001" class="btn btn-outline-primary">View Details</a>
                                </div>
                            </div>
                        </div>
                        
                        <div class="swiper-slide" data-aos="fade-up" data-aos-delay="300">
                            <div class="vendor-card">
                                <div class="vendor-img">
                                    <img src="https://images.unsplash.com/photo-1414235077428-338989a2e8c0?ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80" alt="Divine Catering Services">
                                    <div class="vendor-category">Catering</div>
                                </div>
                                <div class="vendor-info">
                                    <div class="vendor-rating">
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="far fa-star"></i>
                                        <span>(27)</span>
                                    </div>
                                    <h3>Divine Catering</h3>
                                    <p class="location"><i class="fas fa-map-marker-alt"></i> Chicago, IL</p>
                                    <p class="price">Starting from $75 per person</p>
                                    <a href="${pageContext.request.contextPath}/VendorDetailsServlet?id=V1002" class="btn btn-outline-primary">View Details</a>
                                </div>
                            </div>
                        </div>
                        
                        <div class="swiper-slide" data-aos="fade-up" data-aos-delay="400">
                            <div class="vendor-card">
                                <div class="vendor-img">
                                    <img src="https://images.unsplash.com/photo-1470225620780-dba8ba36b745?ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80" alt="Melody Makers Band">
                                    <div class="vendor-category">Music</div>
                                </div>
                                <div class="vendor-info">
                                    <div class="vendor-rating">
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <i class="fas fa-star"></i>
                                        <span>(52)</span>
                                    </div>
                                    <h3>Melody Makers</h3>
                                    <p class="location"><i class="fas fa-map-marker-alt"></i> Miami, FL</p>
                                    <p class="price">Starting from $1,800</p>
                                    <a href="${pageContext.request.contextPath}/VendorDetailsServlet?id=V1005" class="btn btn-outline-primary">View Details</a>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
                <!-- Swiper Navigation -->
                <div class="swiper-button-next"></div>
                <div class="swiper-button-prev"></div>
                <!-- Swiper Pagination -->
                <div class="swiper-pagination"></div>
            </div>
            
            <div class="text-center mt-4" data-aos="fade-up">
                <a href="${pageContext.request.contextPath}/VendorServicesServlet" class="btn btn-primary">View All Vendors</a>
            </div>
        </div>
    </section>

    <!-- Testimonials Section -->
    <section class="testimonials section-padding bg-light">
        <div class="container">
            <div class="section-header text-center" data-aos="fade-up">
                <h2>What Happy Couples Say</h2>
                <p>Hear from couples who planned their perfect wedding with us</p>
            </div>
            
            <div class="swiper testimonial-swiper mt-5">
                <div class="swiper-wrapper">
                    <% if (testimonials.size() > 0) { %>
                        <% int delay = 100; %>
                        <% for (Map<String, Object> testimonial : testimonials) { %>
                            <div class="swiper-slide" data-aos="fade-up" data-aos-delay="<%= delay %>">
                                <div class="testimonial-card">
                                    <div class="quote"><i class="fas fa-quote-left"></i></div>
                                    <div class="testimonial-content">
                                        <p>"<%= testimonial.get("comment") %>"</p>
                                    </div>
                                    <div class="testimonial-author">
                                        <img src="<%= testimonial.get("image") %>" alt="<%= testimonial.get("userName") %>">
                                        <div class="author-info">
                                            <h4><%= testimonial.get("userName") %></h4>
                                            <p>Married <%= testimonial.get("formattedDate") %></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <% delay += 100; %>
                        <% } %>
                    <% } else { %>
                        <!-- Default testimonials if none loaded from JSON -->
                        <div class="swiper-slide" data-aos="fade-up" data-aos-delay="100">
                            <div class="testimonial-card">
                                <div class="quote"><i class="fas fa-quote-left"></i></div>
                                <div class="testimonial-content">
                                    <p>"Marry Mate made our wedding planning so much easier! We found amazing vendors that fit our budget and style. The planning tools kept us organized throughout the whole process. Highly recommend to any couple planning their special day!"</p>
                                </div>
                                <div class="testimonial-author">
                                    <img src="https://images.unsplash.com/photo-1543610892-0b1f7e6d8ac1?ixlib=rb-1.2.1&auto=format&fit=crop&w=128&q=80" alt="Sarah and Michael">
                                    <div class="author-info">
                                        <h4>Sarah & Michael</h4>
                                        <p>Married June 2024</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="swiper-slide" data-aos="fade-up" data-aos-delay="200">
                            <div class="testimonial-card">
                                <div class="quote"><i class="fas fa-quote-left"></i></div>
                                <div class="testimonial-content">
                                    <p>"As a busy couple with full-time jobs, we didn't have much time for planning. Marry Mate connected us with vendors who understood our vision and made our dream wedding come true. The budgeting tools were especially helpful!"</p>
                                </div>
                                <div class="testimonial-author">
                                    <img src="https://images.unsplash.com/photo-1535295972055-1c762f4483e5?ixlib=rb-1.2.1&auto=format&fit=crop&w=128&q=80" alt="Jessica and David">
                                    <div class="author-info">
                                        <h4>Jessica & David</h4>
                                        <p>Married August 2024</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="swiper-slide" data-aos="fade-up" data-aos-delay="300">
                            <div class="testimonial-card">
                                <div class="quote"><i class="fas fa-quote-left"></i></div>
                                <div class="testimonial-content">
                                    <p>"The vendor reviews were spot-on! We booked our photographer and caterer through Marry Mate, and they exceeded our expectations. Our wedding day was absolutely perfect, and we can't thank Marry Mate enough for their help!"</p>
                                </div>
                                <div class="testimonial-author">
                                    <img src="https://images.unsplash.com/photo-1524623252636-db510bfb4128?ixlib=rb-1.2.1&auto=format&fit=crop&w=128&q=80" alt="Emma and James">
                                    <div class="author-info">
                                        <h4>Emma & James</h4>
                                        <p>Married May 2024</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    <% } %>
                </div>
                <!-- Swiper Pagination -->
                <div class="swiper-pagination"></div>
            </div>
        </div>
    </section>

    <!-- How It Works Section -->
    <section class="how-it-works section-padding">
        <div class="container">
            <div class="section-header text-center" data-aos="fade-up">
                <h2>How Marry Mate Works</h2>
                <p>Your wedding planning journey made simple</p>
            </div>
            
            <div class="timeline mt-5">
                <div class="row">
                    <div class="col-md-3" data-aos="fade-up" data-aos-delay="100">
                        <div class="step">
                            <div class="step-number">1</div>
                            <div class="step-icon"><i class="fas fa-user-plus"></i></div>
                            <h3>Create Account</h3>
                            <p>Sign up for free and tell us about your wedding vision and preferences.</p>
                        </div>
                    </div>
                    
                    <div class="col-md-3" data-aos="fade-up" data-aos-delay="200">
                        <div class="step">
                            <div class="step-number">2</div>
                            <div class="step-icon"><i class="fas fa-search"></i></div>
                            <h3>Discover Vendors</h3>
                            <p>Browse pre-screened vendors and filter by location, price, and availability.</p>
                        </div>
                    </div>
                    
                    <div class="col-md-3" data-aos="fade-up" data-aos-delay="300">
                        <div class="step">
                            <div class="step-number">3</div>
                            <div class="step-icon"><i class="fas fa-calendar-check"></i></div>
                            <h3>Book Services</h3>
                            <p>Compare options, read reviews, and book your favorite vendors securely.</p>
                        </div>
                    </div>
                    
                    <div class="col-md-3" data-aos="fade-up" data-aos-delay="400">
                        <div class="step">
                            <div class="step-number">4</div>
                            <div class="step-icon"><i class="fas fa-glass-cheers"></i></div>
                            <h3>Enjoy Your Day</h3>
                            <p>Relax and celebrate while your carefully selected vendors do what they do best.</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="text-center mt-5" data-aos="fade-up">
                <a href="${pageContext.request.contextPath}/signup.jsp" class="btn btn-primary btn-lg">Start Planning Today</a>
            </div>
        </div>
    </section>

    <!-- Join Banner Section -->
    <section class="join-banner">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-7" data-aos="fade-right">
                    <h2>Are You a Wedding Vendor?</h2>
                    <p>Join our platform to showcase your services to thousands of engaged couples. Expand your business and book more weddings.</p>
                </div>
                <div class="col-lg-5 text-lg-end" data-aos="fade-left">
                    <a href="${pageContext.request.contextPath}/signup.jsp?role=vendor" class="btn btn-light btn-lg">Join as Vendor</a>
                    <a href="${pageContext.request.contextPath}/VendorServicesServlet" class="btn btn-outline-light btn-lg ms-2">Learn More</a>
                </div>
            </div>
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
                        <p>Your complete wedding planning and vendor booking platform. Making dream weddings come true since 2020.</p>
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
                            <li><a href="${pageContext.request.contextPath}/VendorServicesServlet">Find Vendors</a></li>
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
    
    <!-- Swiper JS -->
    <script src="https://unpkg.com/swiper/swiper-bundle.min.js"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/index.js"></script>
</body>
</html>