<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Check if vendor is logged in
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    // Redirect if not vendor - Uncomment when backend is ready
    /*if (username == null || !"vendor".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }*/
    
    // For demonstration - this will be replaced with actual data from backend
    String currentDateTime = "2025-05-07 07:57:39";
    String currentUser = "IT24102137";
    
    // Sample data - will be replaced with actual vendor data from backend
    String businessName = "Elegant Photography";
    String vendorId = "V1004";
    double averageRating = 4.7;
    
    // Sample stats - will be replaced with actual stats from backend
    int totalServices = 3;
    int activeBookings = 5;
    int pendingBookings = 2;
    double totalRevenue = 12500;
    int totalReviews = 8;
    
    // Sample recent bookings - will be replaced with data from bookings.json
    String[][] recentBookings = {
        {"B1001", "U1001", "Photography Package", "2025-06-15", "Confirmed", "$3,500"},
        {"B1006", "U1005", "Premium Photography", "2025-08-12", "Pending", "$3,200"},
        {"B1008", "U1002", "Basic Photography", "2025-07-10", "Confirmed", "$2,200"},
        {"B1015", "U1007", "Wedding Day Coverage", "2025-09-05", "Pending", "$2,800"}
    };
    
    // Sample services - will be replaced with data from vendorServices.json
    String[][] vendorServices = {
        {"S1001", "Wedding Photography", "Full day coverage with 2 photographers", "$3,500", "Active"},
        {"S1004", "Engagement Photography", "2-hour session with 50 edited photos", "$800", "Active"},
        {"S1007", "Bridal Portraits", "Studio session with hair and makeup artist", "$1,200", "Inactive"}
    };
    
    // Sample recent reviews - will be replaced with data from vendors.json
    String[][] recentReviews = {
        {"U1001", "The photos were absolutely stunning! Captured every moment perfectly.", "5.0", "2025-04-15"},
        {"U1003", "Professional service, great attention to detail.", "4.8", "2025-04-02"},
        {"U1004", "Good photos but took longer than promised to deliver.", "4.2", "2025-03-22"}
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vendor Dashboard | Marry Mate</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Chart.js -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.css">
    
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/vendor/dashboard.css">
</head>
<body>
    <div class="vendor-container">
        <!-- Sidebar Navigation -->
        <nav class="sidebar">
            <div class="sidebar-header">
                <div class="logo-container">
                    <i class="fas fa-heart"></i>
                    <i class="fas fa-camera"></i>
                </div>
                <h3>Marry Mate</h3>
                <span>Vendor Panel</span>
            </div>
            
            <div class="sidebar-menu">
                <ul>
                    <li class="active">
                        <a href="${pageContext.request.contextPath}/vendor/dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/vendor/services.jsp">
                            <i class="fas fa-list-alt"></i>
                            <span>My Services</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/vendor/bookings.jsp">
                            <i class="fas fa-calendar-check"></i>
                            <span>Bookings</span>
                            <span class="badge bg-danger">2</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/vendor/reviews.jsp">
                            <i class="fas fa-star"></i>
                            <span>Reviews & Ratings</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/VendorProfileServlet">
                            <i class="fas fa-user-cog"></i>
                            <span>Profile Settings</span>
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
                <button id="sidebar-toggle">
                    <i class="fas fa-bars"></i>
                </button>
                
                <div class="vendor-info">
                    <h4><%= businessName %></h4>
                    <span class="vendor-rating">
                        <i class="fas fa-star"></i> <%= averageRating %>
                    </span>
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
                                            <p><strong>New booking request</strong> - Wedding Photography on 2025-06-15</p>
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
                                            <p><strong>New review</strong> - You received a 5-star rating!</p>
                                            <span class="notification-time">1 hour ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-info">
                                            <i class="fas fa-comment"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>New message</strong> - Sarah asked about your availability</p>
                                            <span class="notification-time">2 hours ago</span>
                                        </div>
                                    </a>
                                </li>
                            </ul>
                            <div class="notification-footer">
                                <a href="${pageContext.request.contextPath}/vendor/notifications.jsp">View All Notifications</a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="vendor-profile">
                        <button class="profile-btn">
                            <img src="<c:out value='${sessionScope.user.profilePictureURL}' default='${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg'/>" alt="Vendor" class="user-avatar">
                            <span class="vendor-name">Vendor</span>
                            <i class="fas fa-chevron-down"></i>
                        </button>
                        <div class="profile-dropdown">
                            <ul>
                                <li><a href="${pageContext.request.contextPath}/VendorProfileServlet"><i class="fas fa-user-circle"></i> My Profile</a></li>
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
                        <h1>Vendor Dashboard</h1>
                        <p class="subtitle">Welcome back to your business control panel. Here's your overview.</p>
                    </div>
                    <div class="page-actions">
                        <span class="current-date">
                            <i class="far fa-calendar-alt"></i>
                            <%= currentDateTime %>
                        </span>
                        <button class="btn btn-primary" id="addNewServiceBtn">
                            <i class="fas fa-plus me-2"></i>
                            Add New Service
                        </button>
                    </div>
                </div>
                
                <!-- Stats Overview -->
                <div class="row">
                    <div class="col-xl-3 col-lg-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value"><%= activeBookings %></div>
                                <div class="stat-card-title">Active Bookings</div>
                            </div>
                            <div class="stat-card-icon bg-primary">
                                <i class="fas fa-calendar-check"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change increase">
                                    <i class="fas fa-arrow-up"></i> 12.5%
                                </div>
                                <div class="stat-time">Since last month</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-lg-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value"><%= pendingBookings %></div>
                                <div class="stat-card-title">Pending Bookings</div>
                            </div>
                            <div class="stat-card-icon bg-warning">
                                <i class="fas fa-hourglass-half"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change decrease">
                                    <i class="fas fa-arrow-down"></i> 5.2%
                                </div>
                                <div class="stat-time">Since last month</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-lg-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value">$<%= String.format("%,d", (int)totalRevenue) %></div>
                                <div class="stat-card-title">Total Revenue</div>
                            </div>
                            <div class="stat-card-icon bg-success">
                                <i class="fas fa-dollar-sign"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change increase">
                                    <i class="fas fa-arrow-up"></i> 8.7%
                                </div>
                                <div class="stat-time">Since last month</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-lg-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value"><%= averageRating %></div>
                                <div class="stat-card-title">Average Rating</div>
                            </div>
                            <div class="stat-card-icon bg-info">
                                <i class="fas fa-star"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change increase">
                                    <i class="fas fa-arrow-up"></i> 0.2
                                </div>
                                <div class="stat-time">Since last month</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Charts Section -->
                <div class="row mt-4">
                    <!-- Booking Trends Chart -->
                    <div class="col-lg-8 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Booking Trends</h5>
                                <div class="card-actions">
                                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" id="bookingOptions">
                                        Last 6 Months
                                    </button>
                                </div>
                            </div>
                            <div class="card-body">
                                <canvas id="bookingTrendsChart" height="300"></canvas>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Revenue by Service -->
                    <div class="col-lg-4 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Revenue by Service</h5>
                                <div class="card-actions">
                                    <button class="btn btn-sm btn-outline-secondary" type="button">
                                        <i class="fas fa-sync-alt"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="card-body">
                                <canvas id="revenueByServiceChart" height="300"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Services and Bookings -->
                <div class="row">
                    <!-- My Services -->
                    <div class="col-lg-6 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>My Services</h5>
                                <div class="card-actions">
                                    <a href="${pageContext.request.contextPath}/vendor/services.jsp" class="btn btn-link btn-sm">Manage All</a>
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table mb-0">
                                        <thead>
                                            <tr>
                                                <th>Service Name</th>
                                                <th>Description</th>
                                                <th>Price</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (String[] service : vendorServices) { %>
                                            <tr>
                                                <td><%= service[1] %></td>
                                                <td><%= service[2] %></td>
                                                <td><%= service[3] %></td>
                                                <td>
                                                    <span class="badge rounded-pill <%= "Active".equals(service[4]) ? "bg-success" : "bg-secondary" %>">
                                                        <%= service[4] %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <div class="dropdown">
                                                        <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown">
                                                            <i class="fas fa-ellipsis-v"></i>
                                                        </button>
                                                        <div class="dropdown-menu dropdown-menu-end">
                                                            <a class="dropdown-item" href="#" data-service-id="<%= service[0] %>">
                                                                <i class="fas fa-edit me-2"></i> Edit
                                                            </a>
                                                            <a class="dropdown-item" href="#" data-service-id="<%= service[0] %>">
                                                                <i class="fas fa-toggle-on me-2"></i> Toggle Status
                                                            </a>
                                                            <div class="dropdown-divider"></div>
                                                            <a class="dropdown-item text-danger" href="#" data-service-id="<%= service[0] %>">
                                                                <i class="fas fa-trash-alt me-2"></i> Delete
                                                            </a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Recent Bookings -->
                    <div class="col-lg-6 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Recent Bookings</h5>
                                <div class="card-actions">
                                    <a href="${pageContext.request.contextPath}/vendor/bookings.jsp" class="btn btn-link btn-sm">View All</a>
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table mb-0">
                                        <thead>
                                            <tr>
                                                <th>Service</th>
                                                <th>Date</th>
                                                <th>Status</th>
                                                <th>Amount</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (String[] booking : recentBookings) { %>
                                            <tr>
                                                <td><%= booking[2] %></td>
                                                <td><%= booking[3] %></td>
                                                <td>
                                                    <span class="badge rounded-pill <%= "Confirmed".equals(booking[4]) ? "bg-success" : "bg-warning" %>">
                                                        <%= booking[4] %>
                                                    </span>
                                                </td>
                                                <td><%= booking[5] %></td>
                                                <td>
                                                    <div class="dropdown">
                                                        <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown">
                                                            <i class="fas fa-ellipsis-v"></i>
                                                        </button>
                                                        <div class="dropdown-menu dropdown-menu-end">
                                                            <a class="dropdown-item" href="#" data-booking-id="<%= booking[0] %>">
                                                                <i class="fas fa-eye me-2"></i> View Details
                                                            </a>
                                                            <% if ("Pending".equals(booking[4])) { %>
                                                            <a class="dropdown-item text-success" href="#" data-booking-id="<%= booking[0] %>">
                                                                <i class="fas fa-check-circle me-2"></i> Approve
                                                            </a>
                                                            <a class="dropdown-item text-danger" href="#" data-booking-id="<%= booking[0] %>">
                                                                <i class="fas fa-times-circle me-2"></i> Reject
                                                            </a>
                                                            <% } %>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Reviews and Calendar -->
                <div class="row">
                    <!-- Recent Reviews -->
                    <div class="col-lg-6 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Recent Reviews</h5>
                                <div class="card-actions">
                                    <a href="${pageContext.request.contextPath}/vendor/reviews.jsp" class="btn btn-link btn-sm">View All</a>
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <div class="review-list">
                                    <% for (String[] review : recentReviews) { %>
                                    <div class="review-item">
                                        <div class="review-header">
                                            <div class="reviewer">
                                                <div class="avatar avatar-sm">
                                                    <img src="https://ui-avatars.com/api/?name=User&background=6c757d&color=fff" alt="User">
                                                </div>
                                                <div>
                                                    <p class="reviewer-name mb-0">User ID: <%= review[0] %></p>
                                                    <div class="rating">
                                                        <% 
                                                            double rating = Double.parseDouble(review[2]);
                                                            for (int i = 1; i <= 5; i++) {
                                                                if (i <= rating) {
                                                        %>
                                                        <i class="fas fa-star"></i>
                                                        <% } else if (i - 0.5 <= rating) { %>
                                                        <i class="fas fa-star-half-alt"></i>
                                                        <% } else { %>
                                                        <i class="far fa-star"></i>
                                                        <% } } %>
                                                        <span class="rating-value"><%= review[2] %></span>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="review-date">
                                                <%= review[3] %>
                                            </div>
                                        </div>
                                        <div class="review-content">
                                            <p><%= review[1] %></p>
                                        </div>
                                        <div class="review-actions">
                                            <button class="btn btn-sm btn-outline-primary">
                                                <i class="fas fa-reply"></i> Respond
                                            </button>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Upcoming Calendar -->
                    <div class="col-lg-6 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Upcoming Events</h5>
                                <div class="card-actions">
                                    <a href="${pageContext.request.contextPath}/vendor/availability.jsp" class="btn btn-link btn-sm">Manage Calendar</a>
                                </div>
                            </div>
                            <div class="card-body">
                                <div id="vendor-calendar"></div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Quick Actions -->
                <div class="row">
                    <div class="col-12 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Quick Actions</h5>
                            </div>
                            <div class="card-body">
                                <div class="quick-actions">
                                    <a href="${pageContext.request.contextPath}/vendor/services.jsp?action=new" class="quick-action-btn">
                                        <i class="fas fa-plus-circle"></i>
                                        <span>Add Service</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/vendor/bookings.jsp?filter=pending" class="quick-action-btn">
                                        <i class="fas fa-tasks"></i>
                                        <span>Pending Bookings</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/vendor/portfolio.jsp" class="quick-action-btn">
                                        <i class="fas fa-image"></i>
                                        <span>Update Portfolio</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/vendor/availability.jsp" class="quick-action-btn">
                                        <i class="fas fa-calendar-alt"></i>
                                        <span>Set Availability</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/vendor/profile.jsp" class="quick-action-btn">
                                        <i class="fas fa-user-edit"></i>
                                        <span>Edit Profile</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/vendor/reports.jsp" class="quick-action-btn">
                                        <i class="fas fa-chart-bar"></i>
                                        <span>View Reports</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Footer -->
                <footer class="vendor-footer">
                    <div>
                        <span>© 2025 Marry Mate Wedding Planning System.</span>
                    </div>
                    <div>
                        <span>Version 2.4.1 | Current User: <%= currentUser %> | Last Login: 2025-05-07 06:42:15</span>
                    </div>
                </footer>
            </div>
        </div>
    </div>

    <!-- Add Service Modal -->
    <div class="modal fade" id="addServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add New Service</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="addServiceForm">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="serviceName" class="form-label">Service Name</label>
                                <input type="text" class="form-control" id="serviceName" required>
                            </div>
                            <div class="col-md-6">
                                <label for="serviceCategory" class="form-label">Category</label>
                                <select class="form-select" id="serviceCategory" required>
                                    <option value="">Select a category</option>
                                    <option value="photography">Photography</option>
                                    <option value="videography">Videography</option>
                                    <option value="venue">Venue</option>
                                    <option value="catering">Catering</option>
                                    <option value="music">Music</option>
                                    <option value="decoration">Decoration</option>
                                    <option value="attire">Attire</option>
                                    <option value="beauty">Beauty</option>
                                </select>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="serviceDescription" class="form-label">Description</label>
                            <textarea class="form-control" id="serviceDescription" rows="3" required></textarea>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="servicePrice" class="form-label">Price ($)</label>
                                <input type="number" class="form-control" id="servicePrice" min="0" step="0.01" required>
                            </div>
                            <div class="col-md-6">
                                <label for="serviceStatus" class="form-label">Status</label>
                                <select class="form-select" id="serviceStatus" required>
                                    <option value="active">Active</option>
                                    <option value="inactive">Inactive</option>
                                </select>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Customization Options</label>
                            <div class="customization-options">
                                <div class="option-item d-flex mb-2">
                                    <input type="text" class="form-control me-2" placeholder="Enter option">
                                    <button type="button" class="btn btn-outline-danger remove-option">
                                        <i class="fas fa-times"></i>
                                    </button>
                                </div>
                                <button type="button" class="btn btn-outline-primary btn-sm mt-2" id="addOptionBtn">
                                    <i class="fas fa-plus me-2"></i> Add Option
                                </button>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="serviceImage" class="form-label">Service Image</label>
                            <input type="file" class="form-control" id="serviceImage" accept="image/*">
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveServiceBtn">Save Service</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Profile Image Upload Modal -->
    <div class="modal fade" id="profileImageModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Update Profile Photo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="profileImageForm" action="${pageContext.request.contextPath}/VendorProfileServlet" method="post" enctype="multipart/form-data">
                        <div class="text-center mb-4">
                            <div class="profile-preview">
                                <img src="<c:out value='${sessionScope.user.profilePictureURL}' default='${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg'/>" 
                                     alt="Profile Preview" id="profilePreview" class="img-fluid rounded-circle" style="width: 150px; height: 150px; object-fit: cover;">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="profileImageInput" class="form-label">Select a new profile photo</label>
                            <input type="file" class="form-control" id="profileImageInput" name="profileImage" accept="image/*" required onchange="previewImage(this);">
                            <div class="form-text text-muted">Supported formats: JPG, PNG, GIF. Max file size: 5MB.</div>
                        </div>
                        <input type="hidden" name="action" value="updateProfileImage">
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveProfileImageBtn" onclick="document.getElementById('profileImageForm').submit();">
                        <i class="fas fa-save me-2"></i> Save Photo
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.7.1/dist/chart.min.js"></script>
    
    <!-- FullCalendar -->
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.min.css" rel="stylesheet">
    
    <!-- DataTables -->
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/vendor/dashboard.js"></script>
    
    <script>
        // Function to preview image before upload
        function previewImage(input) {
            if (input.files && input.files[0]) {
                var reader = new FileReader();
                
                reader.onload = function(e) {
                    document.getElementById('profilePreview').src = e.target.result;
                }
                
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
</body>
</html>