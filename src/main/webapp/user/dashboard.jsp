<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter, java.io.*, com.google.gson.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Current date and time information
    String currentDateTime = "2025-05-18 19:43:00";
    String currentUser = "IT24100905";
    
    // Make sure UserId is set in the session
    String userId = "U1005"; // For testing purposes
    session.setAttribute("UserId", userId);
    
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    // Sample user data - will be replaced with actual data from JSON
    String userName = "Jennifer Smith";
    String weddingDate = "2025-12-15";
    
    // GSON Implementation to read user and review data
    Gson gson = new Gson();
    JsonObject userJsonObject = null;
    JsonObject reviewJsonObject = null;
    
    try {
        // Path to JSON files
        String userJsonPath = application.getRealPath("/WEB-INF/data/users.json");
        String reviewJsonPath = application.getRealPath("/WEB-INF/data/reviews.json");
        
        // Read users.json
        Reader userReader = new FileReader(userJsonPath);
        userJsonObject = gson.fromJson(userReader, JsonObject.class);
        userReader.close();
        
        // Read reviews.json
        Reader reviewReader = new FileReader(reviewJsonPath);
        reviewJsonObject = gson.fromJson(reviewReader, JsonObject.class);
        reviewReader.close();
        
        // Find current user data
        JsonArray users = userJsonObject.getAsJsonArray("users");
        for (JsonElement userElement : users) {
            JsonObject user = userElement.getAsJsonObject();
            if (user.get("userId").getAsString().equals(userId)) {
                userName = user.get("fullName").getAsString();
                // You could set more user properties here
                break;
            }
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        // Handle error gracefully
        out.println("<!-- Error loading JSON data: " + e.getMessage() + " -->");
    }
    
    // Calculate review statistics
    int totalReviews = 0;
    double avgRating = 0;
    int pendingReviews = 0;
    int helpfulCount = 0;
    
    if (reviewJsonObject != null) {
        try {
            JsonArray reviews = reviewJsonObject.getAsJsonArray("reviews");
            double ratingSum = 0;
            int userReviewCount = 0;
            
            for (JsonElement reviewElement : reviews) {
                JsonObject review = reviewElement.getAsJsonObject();
                if (review.get("userId").getAsString().equals(userId)) {
                    userReviewCount++;
                    ratingSum += review.get("rating").getAsDouble();
                    helpfulCount += review.get("helpfulCount").getAsInt();
                    
                    if (review.get("status").getAsString().equals("pending")) {
                        pendingReviews++;
                    }
                }
            }
            
            totalReviews = userReviewCount;
            if (userReviewCount > 0) {
                avgRating = ratingSum / userReviewCount;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<!-- Error calculating review statistics: " + e.getMessage() + " -->");
        }
    }
    
    // Calculate days until wedding - for countdown
    java.time.LocalDate today = java.time.LocalDate.now();
    java.time.LocalDate wedding = java.time.LocalDate.parse(weddingDate);
    long daysUntilWedding = java.time.temporal.ChronoUnit.DAYS.between(today, wedding);
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Marry Mate</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user/user-dashboard.css">
</head>
<body>
    <div class="user-container">
        <!-- Sidebar Navigation -->
        <nav class="sidebar">
            <div class="sidebar-header">
                <div class="logo-container">
                    <i class="fas fa-heart"></i>
                    <i class="fas fa-ring"></i>
                </div>
                <h3>Marry Mate</h3>
                <span>User Dashboard</span>
            </div>
            
            <div class="sidebar-menu">
                <ul>
                    <li class="active">
                        <a href="${pageContext.request.contextPath}/user/dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/user/user-bookings.jsp">
                            <i class="fas fa-calendar-check"></i>
                            <span>My Bookings</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/user/user-reviews.jsp">
                            <i class="fas fa-star"></i>
                            <span>My Reviews</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/UserProfileServlet">
                            <i class="fas fa-user-cog"></i>
                            <span>My Profile</span>
                        </a>
                    </li>
                    <li class="divider"></li>
                    <li>
                        <a href="${pageContext.request.contextPath}/index.jsp">
                            <i class="fas fa-home"></i>
                            <span>Main Website</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/LogoutServlet">
                            <i class="fas fa-sign-out-alt"></i>
                            <span>Logout</span>
                        </a>
                    </li>
                </ul>
            </div>
            
            <div class="sidebar-footer">
                <p>© 2025 Marry Mate</p>
                <p>Ver. 2.4.1</p>
            </div>
        </nav>

        <!-- Main Content Area -->
        <div class="main-content">
            <!-- Top Navigation Bar -->
            <header class="topbar">
                <button id="sidebar-toggle" class="btn-reset">
                    <i class="fas fa-bars"></i>
                </button>
                
                <div class="user-info">
                    <h4>Dashboard</h4>
                </div>
                
                <div class="topbar-right">
                    <div class="notifications">
                        <button class="notification-btn">
                            <i class="fas fa-bell"></i>
                            <span class="badge bg-danger">3</span>
                        </button>
                        <div class="notification-dropdown">
                            <div class="notification-header">
                                <h5>Notifications</h5>
                                <a href="#" class="mark-all-read">Mark all as read</a>
                            </div>
                            <ul class="notification-list">
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-primary">
                                            <i class="fas fa-calendar-check"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>Booking confirmed</strong> - Your photography booking has been confirmed</p>
                                            <span class="notification-time">10 minutes ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-warning">
                                            <i class="fas fa-star"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>Review reminder</strong> - Please review your recent vendor service</p>
                                            <span class="notification-time">1 hour ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li>
                                    <a href="#">
                                        <div class="notification-icon bg-success">
                                            <i class="fas fa-check-circle"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>Venue booking</strong> - Your venue booking is confirmed</p>
                                            <span class="notification-time">Yesterday</span>
                                        </div>
                                    </a>
                                </li>
                            </ul>
                            <div class="notification-footer">
                                <a href="${pageContext.request.contextPath}/user/notifications.jsp">View All Notifications</a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="user-profile">
                        <button class="profile-btn">
                            <img src="<c:out value='${sessionScope.user.profilePictureURL}' default='${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg'/>" alt="User" class="profile-image">
                            <span class="user-name"><%= userName %></span>
                            <i class="fas fa-chevron-down"></i>
                        </button>
                        <div class="profile-dropdown">
                            <ul>
                                <li><a href="${pageContext.request.contextPath}/user/profile.jsp"><i class="fas fa-user-circle"></i> My Profile</a></li>
                                <li><a href="${pageContext.request.contextPath}/index.jsp"><i class="fas fa-home"></i> Main Website</a></li>
                                <li class="divider"></li>
                                <li><a href="${pageContext.request.contextPath}/LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </header>

            <!-- Dashboard Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>Welcome, <%= userName %></h1>
                        <p class="subtitle">Here's an overview of your wedding planning journey</p>
                    </div>
                    <div class="current-date">
                        <i class="far fa-calendar-alt"></i>
                        <span id="currentDate">Today: <%= currentDateTime.substring(0, 10) %></span>
                    </div>
                </div>
                
                <!-- Wedding Countdown -->
                <div class="wedding-countdown">
                    <div class="countdown-header">
                        <h3 class="countdown-title">Your Big Day</h3>
                        <div class="countdown-date"><%= weddingDate %></div>
                    </div>
                    <div class="countdown-units">
                        <div class="countdown-unit">
                            <div class="countdown-value" id="countdown-days"><%= daysUntilWedding %></div>
                            <div class="countdown-label">Days</div>
                        </div>
                        <div class="countdown-unit">
                            <div class="countdown-value" id="countdown-hours">0</div>
                            <div class="countdown-label">Hours</div>
                        </div>
                        <div class="countdown-unit">
                            <div class="countdown-value" id="countdown-minutes">0</div>
                            <div class="countdown-label">Minutes</div>
                        </div>
                        <div class="countdown-unit">
                            <div class="countdown-value" id="countdown-seconds">0</div>
                            <div class="countdown-label">Seconds</div>
                        </div>
                    </div>
                </div>
                
                <!-- Quick Stats -->
                <div class="row">
                    <!-- Bookings Card -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <div class="stat-icon mx-auto mb-3 bg-primary">
                                    <i class="fas fa-calendar-check"></i>
                                </div>
                                <h5>Upcoming Services</h5>
                                <h2 class="stat-value">5</h2>
                                <p class="text-muted mb-0">Confirmed bookings</p>
                                <a href="${pageContext.request.contextPath}/user/user-bookings.jsp" class="btn btn-sm btn-outline-primary mt-3">View Bookings</a>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Vendors Card -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <div class="stat-icon mx-auto mb-3 bg-success">
                                    <i class="fas fa-handshake"></i>
                                </div>
                                <h5>Hired Vendors</h5>
                                <h2 class="stat-value">3</h2>
                                <p class="text-muted mb-0">Working with you</p>
                                <a href="${pageContext.request.contextPath}/VendorServicesServlet" class="btn btn-sm btn-outline-success mt-3">Find More</a>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Budget Card -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <div class="stat-icon mx-auto mb-3 bg-info">
                                    <i class="fas fa-dollar-sign"></i>
                                </div>
                                <h5>Budget Used</h5>
                                <h2 class="stat-value">$4,500</h2>
                                <p class="text-muted mb-0">Out of $15,000</p>
                                <a href="${pageContext.request.contextPath}/user/budget.jsp" class="btn btn-sm btn-outline-info mt-3">Budget Details</a>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Tasks Card -->
                    <div class="col-md-6 col-lg-3 mb-4">
                        <div class="card h-100">
                            <div class="card-body text-center">
                                <div class="stat-icon mx-auto mb-3 bg-warning">
                                    <i class="fas fa-tasks"></i>
                                </div>
                                <h5>Tasks Remaining</h5>
                                <h2 class="stat-value">12</h2>
                                <p class="text-muted mb-0">48% completed</p>
                                <a href="${pageContext.request.contextPath}/user/checklist.jsp" class="btn btn-sm btn-outline-warning mt-3">View Checklist</a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Reviews Summary -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0">My Reviews</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-3 col-sm-6 mb-3 mb-md-0">
                                <div class="text-center">
                                    <h2 class="mb-0 display-4"><%= totalReviews %></h2>
                                    <p class="text-muted">Total Reviews</p>
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6 mb-3 mb-md-0">
                                <div class="text-center">
                                    <h2 class="mb-0 display-4"><%= String.format("%.1f", avgRating) %></h2>
                                    <p class="text-muted">Average Rating</p>
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6 mb-3 mb-md-0">
                                <div class="text-center">
                                    <h2 class="mb-0 display-4"><%= pendingReviews %></h2>
                                    <p class="text-muted">Pending Reviews</p>
                                </div>
                            </div>
                            <div class="col-md-3 col-sm-6">
                                <div class="text-center">
                                    <h2 class="mb-0 display-4"><%= helpfulCount %></h2>
                                    <p class="text-muted">Helpful Votes</p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="text-center mt-4">
                            <a href="${pageContext.request.contextPath}/user/user-reviews.jsp" class="btn btn-primary">Manage Reviews</a>
                        </div>
                    </div>
                </div>
                
                <!-- Recent Bookings -->
                <div class="card mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Recent Bookings</h5>
                        <a href="${pageContext.request.contextPath}/user/user-bookings.jsp" class="btn btn-sm btn-outline-primary">View All</a>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover mb-0">
                                <thead>
                                    <tr>
                                        <th>Service</th>
                                        <th>Vendor</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Price</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>Wedding Photography</td>
                                        <td>Elegant Photography</td>
                                        <td>2025-12-15</td>
                                        <td><span class="badge rounded-pill status-badge-confirmed">Confirmed</span></td>
                                        <td>$1,800</td>
                                    </tr>
                                    <tr>
                                        <td>Catering Service</td>
                                        <td>Gourmet Delights</td>
                                        <td>2025-12-15</td>
                                        <td><span class="badge rounded-pill status-badge-confirmed">Confirmed</span></td>
                                        <td>$2,200</td>
                                    </tr>
                                    <tr>
                                        <td>Floral Arrangements</td>
                                        <td>Bloom Floral Designs</td>
                                        <td>2025-12-15</td>
                                        <td><span class="badge rounded-pill status-badge-pending">Pending</span></td>
                                        <td>$800</td>
                                    </tr>
                                    <tr>
                                        <td>DJ Services</td>
                                        <td>Rhythm Makers</td>
                                        <td>2025-12-15</td>
                                        <td><span class="badge rounded-pill status-badge-pending">Pending</span></td>
                                        <td>$500</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- Wedding Planning Progress -->
                <div class="card mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Wedding Planning Progress</h5>
                        <a href="${pageContext.request.contextPath}/user/checklist.jsp" class="btn btn-sm btn-outline-primary">View Checklist</a>
                    </div>
                    <div class="card-body">
                        <!-- Planning Categories Progress -->
                        <div class="row">
                            <!-- Venue & Catering -->
                            <div class="col-md-6 col-lg-4 mb-4">
                                <h6>Venue & Catering</h6>
                                <div class="progress mb-2" style="height: 10px;">
                                    <div class="progress-bar bg-success" role="progressbar" style="width: 75%;" aria-valuenow="75" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted small">75% Complete</span>
                                    <span class="text-muted small">3/4 Tasks</span>
                                </div>
                            </div>
                            
                            <!-- Photography & Video -->
                            <div class="col-md-6 col-lg-4 mb-4">
                                <h6>Photography & Video</h6>
                                <div class="progress mb-2" style="height: 10px;">
                                    <div class="progress-bar bg-success" role="progressbar" style="width: 100%;" aria-valuenow="100" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted small">100% Complete</span>
                                    <span class="text-muted small">2/2 Tasks</span>
                                </div>
                            </div>
                            
                            <!-- Attire & Beauty -->
                            <div class="col-md-6 col-lg-4 mb-4">
                                <h6>Attire & Beauty</h6>
                                <div class="progress mb-2" style="height: 10px;">
                                    <div class="progress-bar bg-warning" role="progressbar" style="width: 50%;" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted small">50% Complete</span>
                                    <span class="text-muted small">2/4 Tasks</span>
                                </div>
                            </div>
                            
                            <!-- Music & Entertainment -->
                            <div class="col-md-6 col-lg-4 mb-4">
                                <h6>Music & Entertainment</h6>
                                <div class="progress mb-2" style="height: 10px;">
                                    <div class="progress-bar bg-warning" role="progressbar" style="width: 50%;" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted small">50% Complete</span>
                                    <span class="text-muted small">1/2 Tasks</span>
                                </div>
                            </div>
                            
                            <!-- Flowers & Decor -->
                            <div class="col-md-6 col-lg-4 mb-4">
                                <h6>Flowers & Decor</h6>
                                <div class="progress mb-2" style="height: 10px;">
                                    <div class="progress-bar bg-warning" role="progressbar" style="width: 33%;" aria-valuenow="33" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted small">33% Complete</span>
                                    <span class="text-muted small">1/3 Tasks</span>
                                </div>
                            </div>
                            
                            <!-- Stationery & Gifts -->
                            <div class="col-md-6 col-lg-4 mb-4">
                                <h6>Stationery & Gifts</h6>
                                <div class="progress mb-2" style="height: 10px;">
                                    <div class="progress-bar bg-danger" role="progressbar" style="width: 20%;" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100"></div>
                                </div>
                                <div class="d-flex justify-content-between">
                                    <span class="text-muted small">20% Complete</span>
                                    <span class="text-muted small">1/5 Tasks</span>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Overall Progress -->
                        <h6 class="mt-3">Overall Planning Progress</h6>
                        <div class="progress mb-2" style="height: 15px;">
                            <div class="progress-bar bg-primary" role="progressbar" style="width: 48%;" aria-valuenow="48" aria-valuemin="0" aria-valuemax="100">48%</div>
                        </div>
                    </div>
                </div>
                
                <!-- Vendor Recommendations -->
                <div class="card mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Recommended Vendors</h5>
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet" class="btn btn-sm btn-outline-primary">View All</a>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <!-- Vendor 1 -->
                            <div class="col-md-6 col-lg-4 mb-4">
                                <div class="vendor-card">
                                    <div class="vendor-img">
                                        <img src="${pageContext.request.contextPath}/assets/images/vendors/vendor-1.jpg" alt="Sweet Delights Bakery">
                                        <div class="vendor-category">Cake</div>
                                    </div>
                                    <div class="vendor-info p-3">
                                        <h5>Sweet Delights Bakery</h5>
                                        <div class="vendor-rating">
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star-half-alt"></i>
                                            <span>(4.5)</span>
                                        </div>
                                        <p class="text-muted small mt-2">Custom wedding cakes and desserts for your special day. Specializing in elegant designs and delicious flavors.</p>
                                        <a href="${pageContext.request.contextPath}/vendor/details.jsp?id=v1010" class="btn btn-sm btn-outline-primary w-100 mt-2">View Details</a>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Vendor 2 -->
                            <div class="col-md-6 col-lg-4 mb-4">
                                <div class="vendor-card">
                                    <div class="vendor-img">
                                        <img src="${pageContext.request.contextPath}/assets/images/vendors/vendor-2.jpg" alt="Elegant Limo Services">
                                        <div class="vendor-category">Transportation</div>
                                    </div>
                                    <div class="vendor-info p-3">
                                        <h5>Elegant Limo Services</h5>
                                        <div class="vendor-rating">
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="far fa-star"></i>
                                            <span>(4.0)</span>
                                        </div>
                                        <p class="text-muted small mt-2">Luxury transportation for the bride, groom, and wedding party. Stylish vehicles and professional chauffeurs.</p>
                                        <a href="${pageContext.request.contextPath}/vendor/details.jsp?id=v1011" class="btn btn-sm btn-outline-primary w-100 mt-2">View Details</a>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Vendor 3 -->
                            <div class="col-md-6 col-lg-4 mb-4">
                                <div class="vendor-card">
                                    <div class="vendor-img">
                                        <img src="${pageContext.request.contextPath}/assets/images/vendors/vendor-3.jpg" alt="Dazzling Jewels">
                                        <div class="vendor-category">Jewelry</div>
                                    </div>
                                    <div class="vendor-info p-3">
                                        <h5>Dazzling Jewels</h5>
                                        <div class="vendor-rating">
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <i class="fas fa-star"></i>
                                            <span>(5.0)</span>
                                        </div>
                                        <p class="text-muted small mt-2">Custom wedding rings and bridal jewelry. Personalized designs to match your style and budget.</p>
                                        <a href="${pageContext.request.contextPath}/vendor/details.jsp?id=v1012" class="btn btn-sm btn-outline-primary w-100 mt-2">View Details</a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Footer -->
                <footer class="user-footer">
                    <div>
                        <span>© 2025 Marry Mate Wedding Planning System.</span>
                    </div>
                    <div>
                        <span>Current User: <%= currentUser %> | Last Updated: <%= currentDateTime %></span>
                    </div>
                </footer>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Chart.js for dashboard charts if needed -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/user/dashboard.js"></script>
    
    <!-- Wedding Countdown Script -->
    <script>
        // Set the wedding date
        const weddingDate = new Date('<%= weddingDate %>').getTime();
        
        // Update the countdown every second
        const countdown = setInterval(function() {
            // Get current date and time
            const now = new Date().getTime();
            
            // Calculate the remaining time
            const distance = weddingDate - now;
            
            // Calculate days, hours, minutes, and seconds
            const days = Math.floor(distance / (1000 * 60 * 60 * 24));
            const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            // Update the HTML elements
            document.getElementById('countdown-days').innerHTML = days;
            document.getElementById('countdown-hours').innerHTML = hours;
            document.getElementById('countdown-minutes').innerHTML = minutes;
            document.getElementById('countdown-seconds').innerHTML = seconds;
            
            // If the countdown is over, display a message
            if (distance < 0) {
                clearInterval(countdown);
                document.getElementById('countdown-days').innerHTML = "0";
                document.getElementById('countdown-hours').innerHTML = "0";
                document.getElementById('countdown-minutes').innerHTML = "0";
                document.getElementById('countdown-seconds').innerHTML = "0";
            }
        }, 1000);
    </script>
</body>
</html>