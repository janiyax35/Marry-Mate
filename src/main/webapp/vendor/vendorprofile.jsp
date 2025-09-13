<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter, com.google.gson.JsonObject, com.google.gson.JsonArray" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Make sure UserId is set in the session
    String userId = (String) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    
    // Redirect if not logged in as vendor
    if (userId == null || !"vendor".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Check if we have a vendorProfile attribute (should be set by servlet)
    JsonObject vendorProfile = (JsonObject) request.getAttribute("vendorProfile");
    boolean editMode = (request.getAttribute("editMode") != null) && (boolean) request.getAttribute("editMode");
    
    if (vendorProfile == null) {
        // Redirect to the servlet to load vendor data
        response.sendRedirect("H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\java\\com\\MarryMate\\servlets\\Vendor\\VendorProfileServlet.java");
        return;
    }
    
    // Get categories as a comma-separated list for edit mode
    String categoriesString = "";
    if (vendorProfile.has("categories") && vendorProfile.get("categories").isJsonArray()) {
        JsonArray categoriesArray = vendorProfile.getAsJsonArray("categories");
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < categoriesArray.size(); i++) {
            if (i > 0) sb.append(", ");
            sb.append(categoriesArray.get(i).getAsString());
        }
        categoriesString = sb.toString();
    }
    
    // Updated timestamp and information
    String currentDateTime = "2025-05-18 14:02:44";
    String currentUser = "IT24102083";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vendor Profile | Marry Mate</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/vendor/dashboard.css">
    
    <!-- Inline Styles for Vendor Profile -->
    <style>
        /* Vendor Profile Header */
        .vendor-profile-header {
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            color: white;
            padding: 40px 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        
        .vendor-profile-header::before {
            content: "";
            position: absolute;
            top: 0;
            right: 0;
            bottom: 0;
            left: 0;
            background-image: url('${pageContext.request.contextPath}/assets/images/patterns/pattern-overlay.png');
            opacity: 0.1;
            z-index: 0;
        }
        
        /* Cover Photo Section */
        .cover-photo-container {
            position: relative;
            height: 200px;
            overflow: hidden;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .cover-photo-container img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .change-cover-btn {
            position: absolute;
            bottom: 10px;
            right: 10px;
            background: rgba(0,0,0,0.7);
            color: white;
            border-radius: 4px;
            padding: 5px 10px;
            font-size: 0.8rem;
            display: flex;
            align-items: center;
            cursor: pointer;
            transition: all 0.3s;
            z-index: 2;
        }
        
        .change-cover-btn:hover {
            background: rgba(0,0,0,0.9);
        }
        
        /* Profile Avatar */
        .profile-avatar {
            position: relative;
            width: 150px;
            height: 150px;
            border-radius: 50%;
            border: 5px solid rgba(255,255,255,0.3);
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin: -75px auto 20px;
            z-index: 1;
        }
        
        .profile-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        
        .change-photo-btn {
            position: absolute;
            bottom: 5px;
            right: 5px;
            background: rgba(0,0,0,0.7);
            color: white;
            border-radius: 50%;
            width: 35px;
            height: 35px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s;
            z-index: 2;
        }
        
        .change-photo-btn:hover {
            background: rgba(0,0,0,0.9);
        }
        
        /* Vendor Info Card */
        .vendor-info-card {
            transition: all 0.3s ease;
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            margin-bottom: 25px;
        }
        
        .vendor-info-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }
        
        /* Category Badges */
        .category-badge {
            display: inline-block;
            background-color: #f8f9fa;
            color: #6a11cb;
            border: 1px solid #e9ecef;
            border-radius: 30px;
            padding: 5px 15px;
            margin: 0 5px 10px 0;
            font-size: 0.85rem;
            font-weight: 500;
            transition: all 0.2s;
        }
        
        .category-badge:hover {
            background-color: #6a11cb;
            color: white;
        }
        
        /* Rating Stars */
        .rating-stars {
            color: #ffc107;
            font-size: 1.2rem;
            margin-right: 10px;
        }
        
        /* Service List */
        .service-item {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 15px;
            margin-bottom: 10px;
            transition: all 0.2s;
        }
        
        .service-item:hover {
            background-color: #e9ecef;
        }
        
        /* Image preview containers */
        .image-preview-container {
            width: 100%;
            text-align: center;
            margin-bottom: 15px;
        }
        
        .image-preview-container img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        #profilePreview {
            max-height: 200px;
        }
        
        #coverPreview {
            max-height: 150px;
        }
        
        /* Business Statistics */
        .vendor-stats {
            display: flex;
            justify-content: space-around;
            flex-wrap: wrap;
            margin-bottom: 20px;
        }
        
        .stat-item {
            text-align: center;
            padding: 10px;
        }
        
        .stat-value {
            font-size: 1.8rem;
            font-weight: 700;
            color: #6a11cb;
            margin-bottom: 0;
        }
        
        .stat-label {
            font-size: 0.8rem;
            color: #777;
            text-transform: uppercase;
        }
        
        /* Divider with text */
        .divider-text {
            position: relative;
            text-align: center;
            margin: 25px 0;
        }
        
        .divider-text:before {
            content: '';
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            border-top: 1px solid #ddd;
            z-index: -1;
        }
        
        .divider-text span {
            background-color: #fff;
            padding: 0 15px;
            font-size: 0.9rem;
            color: #888;
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .profile-avatar {
                width: 120px;
                height: 120px;
                margin-top: -60px;
            }
            
            .cover-photo-container {
                height: 150px;
            }
        }
    </style>
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
                    <li>
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
                    <li  class="active">
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
                
                <div class="user-info">
                    <h4>Vendor Profile</h4>
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
                                            <p><strong>New booking</strong> - You have received a new booking request!</p>
                                            <span class="notification-time">30 minutes ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-info">
                                            <i class="fas fa-comment"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>New message</strong> - You've received a message from client.</p>
                                            <span class="notification-time">2 hours ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li>
                                    <a href="#">
                                        <div class="notification-icon bg-success">
                                            <i class="fas fa-star"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>New review</strong> - A client has left a 5-star review.</p>
                                            <span class="notification-time">Yesterday</span>
                                        </div>
                                    </a>
                                </li>
                            </ul>
                            <div class="notification-footer">
                                <a href="#">View All Notifications</a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="user-profile">
                        <button class="profile-btn">
                            <img src="<%= vendorProfile.get("profilePictureUrl").getAsString() %>" alt="User" class="profile-img">
                            <span class="user-name"><%= vendorProfile.get("businessName").getAsString() %></span>
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

            <!-- Profile Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>Vendor Profile</h1>
                        <p class="subtitle">View and update your vendor information</p>
                    </div>
                    <div class="page-actions">
                        <% if (!editMode) { %>
                            <a href="${pageContext.request.contextPath}/VendorProfileServlet?action=editProfile" class="btn btn-primary">
                                <i class="fas fa-edit me-2"></i>
                                Edit Profile
                            </a>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/VendorProfileServlet" class="btn btn-outline-secondary">
                                <i class="fas fa-times me-2"></i>
                                Cancel
                            </a>
                        <% } %>
                    </div>
                </div>
                
                <!-- Alert Messages -->
                <c:if test="${not empty message}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i> ${message}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty error}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i> ${error}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty passwordMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i> ${passwordMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty passwordError}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i> ${passwordError}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty imageMessage || not empty coverImageMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i> ${not empty imageMessage ? imageMessage : coverImageMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty imageError || not empty coverImageError}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i> ${not empty imageError ? imageError : coverImageError}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                
                <!-- Cover Photo and Profile Picture Section -->
                <div class="cover-photo-container">
                    <img src="<%= vendorProfile.has("coverPhotoUrl") && !vendorProfile.get("coverPhotoUrl").getAsString().isEmpty() ? 
                        vendorProfile.get("coverPhotoUrl").getAsString() : "/assets/images/vendors/default-cover.jpg" %>" 
                         alt="Cover Photo" id="currentCoverPhoto">
                    <div class="change-cover-btn" data-bs-toggle="modal" data-bs-target="#coverImageModal">
                        <i class="fas fa-camera me-1"></i> Change Cover
                    </div>
                </div>
                
                <!-- Profile Content -->
                <div class="row">
                    <!-- Left Column - Vendor Information -->
                    <div class="col-lg-8 mb-4">
                        <!-- Profile Header with Avatar -->
                        <div class="text-center position-relative">
                            <div class="profile-avatar">
                                <img src="<%= vendorProfile.get("profilePictureUrl").getAsString() %>" alt="Profile Picture" id="currentProfileImage">
                                <div class="change-photo-btn" data-bs-toggle="modal" data-bs-target="#profileImageModal">
                                    <i class="fas fa-camera"></i>
                                </div>
                            </div>
                            <h2 class="mb-1"><%= vendorProfile.get("businessName").getAsString() %></h2>
                            <p class="text-muted mb-2">
                                <i class="fas fa-user me-1"></i> <%= vendorProfile.get("contactName").getAsString() %>
                            </p>
                            
                            <!-- Rating Display -->
                            <div class="d-flex justify-content-center align-items-center mb-3">
                                <div class="rating-stars">
                                    <% 
                                        double rating = vendorProfile.has("rating") ? vendorProfile.get("rating").getAsDouble() : 0.0;
                                        for (int i = 1; i <= 5; i++) {
                                            if (i <= rating) {
                                    %>
                                                <i class="fas fa-star"></i>
                                    <%
                                            } else if (i - 0.5 <= rating) {
                                    %>
                                                <i class="fas fa-star-half-alt"></i>
                                    <%
                                            } else {
                                    %>
                                                <i class="far fa-star"></i>
                                    <%
                                            }
                                        }
                                    %>
                                </div>
                                <span class="fw-bold"><%= String.format("%.1f", rating) %>/5.0</span>
                                <span class="text-muted ms-2">(<%= vendorProfile.has("reviewCount") ? vendorProfile.get("reviewCount").getAsInt() : 0 %> reviews)</span>
                            </div>
                            
                            <!-- Categories -->
                            <div class="mb-3">
                                <% 
                                    if (vendorProfile.has("categories") && vendorProfile.get("categories").isJsonArray()) {
                                        JsonArray categories = vendorProfile.getAsJsonArray("categories");
                                        for (int i = 0; i < categories.size(); i++) {
                                            String category = categories.get(i).getAsString();
                                %>
                                            <span class="category-badge"><%= category %></span>
                                <%
                                        }
                                    }
                                %>
                            </div>
                            
                            <!-- Member Since / Featured Badge -->
                            <div>
                                <span class="badge bg-light text-dark me-2">
                                    <i class="fas fa-calendar me-1"></i> Member since <%= vendorProfile.get("memberSince").getAsString().split(" ")[0] %>
                                </span>
                                <% if (vendorProfile.has("featured") && vendorProfile.get("featured").getAsBoolean()) { %>
                                    <span class="badge bg-warning text-dark">
                                        <i class="fas fa-award me-1"></i> Featured Vendor
                                    </span>
                                <% } %>
                            </div>
                        </div>
                        
                        <% if (!editMode) { %>
                            <!-- View Vendor Information -->
                            <div class="card vendor-info-card mt-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0">Business Information</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row mb-4">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Business Name</p>
                                            <p class="fw-bold mb-0"><%= vendorProfile.get("businessName").getAsString() %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Contact Person</p>
                                            <p class="fw-bold mb-0"><%= vendorProfile.get("contactName").getAsString() %></p>
                                        </div>
                                    </div>
                                    <div class="row mb-4">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Email Address</p>
                                            <p class="fw-bold mb-0"><%= vendorProfile.get("email").getAsString() %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Phone Number</p>
                                            <p class="fw-bold mb-0">
                                                <% if (vendorProfile.has("phone") && !vendorProfile.get("phone").getAsString().isEmpty()) { %>
                                                    <%= vendorProfile.get("phone").getAsString() %>
                                                <% } else { %>
                                                    <span class="text-muted fst-italic">Not provided</span>
                                                <% } %>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="row mb-4">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Website</p>
                                            <p class="fw-bold mb-0">
                                                <% if (vendorProfile.has("websiteUrl") && !vendorProfile.get("websiteUrl").getAsString().isEmpty()) { %>
                                                    <a href="<%= vendorProfile.get("websiteUrl").getAsString() %>" target="_blank" class="text-primary">
                                                        <i class="fas fa-external-link-alt me-1"></i> <%= vendorProfile.get("websiteUrl").getAsString() %>
                                                    </a>
                                                <% } else { %>
                                                    <span class="text-muted fst-italic">Not provided</span>
                                                <% } %>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Price Range</p>
                                            <p class="fw-bold mb-0">
                                                <% if (vendorProfile.has("priceRange") && !vendorProfile.get("priceRange").getAsString().isEmpty()) { %>
                                                    $<%= vendorProfile.get("priceRange").getAsString() %>
                                                <% } else { %>
                                                    <span class="text-muted fst-italic">Not specified</span>
                                                <% } %>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <p class="text-muted mb-1">Business Address</p>
                                            <p class="fw-bold mb-0">
                                                <% if (vendorProfile.has("address") && !vendorProfile.get("address").getAsString().isEmpty()) { %>
                                                    <%= vendorProfile.get("address").getAsString() %>
                                                <% } else { %>
                                                    <span class="text-muted fst-italic">No address provided</span>
                                                <% } %>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Services Information -->
                            <div class="card vendor-info-card mt-4">
                                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Services Information</h5>
                                </div>
                                <div class="card-body">
                                    <div class="mb-4">
                                        <p class="text-muted mb-1">Services Offered</p>
                                        <p class="mb-0">
                                            <% if (vendorProfile.has("servicesOffered") && !vendorProfile.get("servicesOffered").getAsString().isEmpty()) { %>
                                                <%= vendorProfile.get("servicesOffered").getAsString() %>
                                            <% } else { %>
                                                <span class="text-muted fst-italic">No services information provided</span>
                                            <% } %>
                                        </p>
                                    </div>
                                    
                                    <div>
                                        <p class="text-muted mb-1">Business Description</p>
                                        <p class="mb-0">
                                            <% if (vendorProfile.has("description") && !vendorProfile.get("description").getAsString().isEmpty()) { %>
                                                <%= vendorProfile.get("description").getAsString() %>
                                            <% } else { %>
                                                <span class="text-muted fst-italic">No description provided</span>
                                            <% } %>
                                        </p>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Account Security -->
                            <div class="card vendor-info-card mt-4">
                                <div class="card-header bg-white d-flex justify-content-between align-items-center">
                                    <h5 class="mb-0">Account Security</h5>
                                    <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#changePasswordModal">
                                        <i class="fas fa-key me-1"></i> Change Password
                                    </button>
                                </div>
                                <div class="card-body">
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Password Status</p>
                                            <p class="mb-0">
                                                <span class="badge bg-success">
                                                    <i class="fas fa-check-circle me-1"></i> Set
                                                </span>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Last Login</p>
                                            <p class="mb-0"><%= vendorProfile.get("lastLogin").getAsString() %></p>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Account Status</p>
                                            <p class="mb-0">
                                                <span class="badge <%= vendorProfile.get("status").getAsString().equals("active") ? "bg-success" : 
                                                      (vendorProfile.get("status").getAsString().equals("pending") ? "bg-warning" : "bg-danger") %>">
                                                    <i class="fas fa-circle me-1"></i> <%= vendorProfile.get("status").getAsString() %>
                                                </span>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Vendor ID</p>
                                            <p class="mb-0"><%= vendorProfile.get("userId").getAsString() %></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                        <% } else { %>
                            <!-- Edit Vendor Profile Form -->
                            <div class="card vendor-info-card mt-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0">Edit Business Information</h5>
                                </div>
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/VendorProfileServlet" method="post">
                                        <input type="hidden" name="action" value="updateProfile">
                                        
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="businessName" class="form-label">Business Name <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="businessName" name="businessName" 
                                                    value="<%= vendorProfile.get("businessName").getAsString() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="contactName" class="form-label">Contact Person <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="contactName" name="contactName" 
                                                    value="<%= vendorProfile.get("contactName").getAsString() %>" required>
                                            </div>
                                        </div>
                                        
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="email" class="form-label">Email Address <span class="text-danger">*</span></label>
                                                <input type="email" class="form-control" id="email" name="email" 
                                                    value="<%= vendorProfile.get("email").getAsString() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="phone" class="form-label">Phone Number</label>
                                                <input type="text" class="form-control" id="phone" name="phone" 
                                                    value="<%= vendorProfile.has("phone") ? vendorProfile.get("phone").getAsString() : "" %>" 
                                                    placeholder="Enter your phone number">
                                            </div>
                                        </div>
                                        
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="websiteUrl" class="form-label">Website URL</label>
                                                <input type="url" class="form-control" id="websiteUrl" name="websiteUrl" 
                                                    value="<%= vendorProfile.has("websiteUrl") ? vendorProfile.get("websiteUrl").getAsString() : "" %>" 
                                                    placeholder="https://your-website.com">
                                            </div>
                                            <div class="col-md-6">
                                                <label for="priceRange" class="form-label">Price Range</label>
                                                <input type="text" class="form-control" id="priceRange" name="priceRange" 
                                                    value="<%= vendorProfile.has("priceRange") ? vendorProfile.get("priceRange").getAsString() : "" %>" 
                                                    placeholder="e.g., 500-3000">
                                            </div>
                                        </div>
                                        
                                        <div class="mb-3">
                                            <label for="address" class="form-label">Business Address</label>
                                            <textarea class="form-control" id="address" name="address" rows="2" 
                                                placeholder="Enter your business address"><%= vendorProfile.has("address") ? vendorProfile.get("address").getAsString() : "" %></textarea>
                                        </div>
                                        
                                        <div class="mb-3">
                                            <label for="categories" class="form-label">Categories (comma separated)</label>
                                            <input type="text" class="form-control" id="categories" name="categories" 
                                                value="<%= categoriesString %>" 
                                                placeholder="e.g., photography, catering, venue">
                                        </div>
                                        
                                        <div class="mb-3">
                                            <label for="servicesOffered" class="form-label">Services Offered</label>
                                            <textarea class="form-control" id="servicesOffered" name="servicesOffered" rows="2" 
                                                placeholder="List your services"><%= vendorProfile.has("servicesOffered") ? vendorProfile.get("servicesOffered").getAsString() : "" %></textarea>
                                        </div>
                                        
                                        <div class="mb-4">
                                            <label for="description" class="form-label">Business Description</label>
                                            <textarea class="form-control" id="description" name="description" rows="4" 
                                                placeholder="Describe your business"><%= vendorProfile.has("description") ? vendorProfile.get("description").getAsString() : "" %></textarea>
                                        </div>
                                        
                                        <div class="mb-3">
                                            <label for="profilePictureUrl" class="form-label">Profile Picture URL</label>
                                            <input type="url" class="form-control" id="profilePictureUrl" name="profilePictureUrl" 
                                                value="<%= vendorProfile.get("profilePictureUrl").getAsString() %>" 
                                                placeholder="Enter image URL" onchange="previewProfileImage(this.value)">
                                            <div class="form-text">Enter a direct URL to an image (.jpg, .png, etc.)</div>
                                            
                                            <div class="image-preview-container mt-3">
                                                <img src="<%= vendorProfile.get("profilePictureUrl").getAsString() %>" alt="Profile Preview" id="profilePreview">
                                            </div>
                                        </div>
                                        
                                        <div class="mb-4">
                                            <label for="coverPhotoUrl" class="form-label">Cover Photo URL</label>
                                            <input type="url" class="form-control" id="coverPhotoUrl" name="coverPhotoUrl" 
                                                value="<%= vendorProfile.has("coverPhotoUrl") ? vendorProfile.get("coverPhotoUrl").getAsString() : "" %>" 
                                                placeholder="Enter image URL" onchange="previewCoverImage(this.value)">
                                            <div class="form-text">Enter a direct URL to an image (.jpg, .png, etc.)</div>
                                            
                                            <div class="image-preview-container mt-3">
                                                <img src="<%= vendorProfile.has("coverPhotoUrl") ? vendorProfile.get("coverPhotoUrl").getAsString() : "/assets/images/vendors/default-cover.jpg" %>" 
                                                     alt="Cover Preview" id="coverPreview">
                                            </div>
                                        </div>
                                        
                                        <div class="d-flex justify-content-end">
                                            <a href="${pageContext.request.contextPath}/VendorProfileServlet" class="btn btn-outline-secondary me-2">
                                                Cancel
                                            </a>
                                            <button type="submit" class="btn btn-primary">
                                                <i class="fas fa-save me-2"></i> Save Changes
                                            </button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        <% } %>
                    </div>
                    
                    <!-- Right Column - Stats and Additional Info -->
                    <div class="col-lg-4">
                        <!-- Business Stats -->
                        <div class="card vendor-info-card">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Business Overview</h5>
                            </div>
                            <div class="card-body">
                                <div class="vendor-stats">
                                    <div class="stat-item">
                                        <p class="stat-value">
                                            <%= vendorProfile.has("serviceIds") ? vendorProfile.getAsJsonArray("serviceIds").size() : 0 %>
                                        </p>
                                        <p class="stat-label">Services</p>
                                    </div>
                                    <div class="stat-item">
                                        <p class="stat-value">
                                            <%= vendorProfile.has("reviewCount") ? vendorProfile.get("reviewCount").getAsInt() : 0 %>
                                        </p>
                                        <p class="stat-label">Reviews</p>
                                    </div>
                                    <div class="stat-item">
                                        <p class="stat-value">
                                            <%= vendorProfile.has("rating") ? String.format("%.1f", vendorProfile.get("rating").getAsDouble()) : "0.0" %>
                                        </p>
                                        <p class="stat-label">Rating</p>
                                    </div>
                                </div>
                                
                                <div class="d-grid gap-2">
                                    <a href="${pageContext.request.contextPath}/vendor/services.jsp" class="btn btn-outline-primary">
                                        <i class="fas fa-list-alt me-2"></i> Manage Services
                                    </a>
                                    <a href="${pageContext.request.contextPath}/vendor/reviews.jsp" class="btn btn-outline-primary">
                                        <i class="fas fa-star me-2"></i> View Reviews
                                    </a>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Account Information -->
                        <div class="card vendor-info-card mt-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Account Information</h5>
                            </div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <p class="text-muted mb-1">Member Since</p>
                                    <p class="fw-bold">
                                        <%= vendorProfile.get("memberSince").getAsString().split(" ")[0] %>
                                    </p>
                                </div>
                                <div class="mb-3">
                                    <p class="text-muted mb-1">Account Type</p>
                                    <p class="fw-bold text-capitalize">
                                        <%= vendorProfile.get("role").getAsString() %>
                                        <%= vendorProfile.has("featured") && vendorProfile.get("featured").getAsBoolean() ? 
                                            " <span class='badge bg-warning text-dark'>Featured</span>" : "" %>
                                    </p>
                                </div>
                                <div>
                                    <p class="text-muted mb-1">Last Updated</p>
                                    <p class="fw-bold"><%= vendorProfile.get("updatedAt").getAsString() %></p>
                                </div>
                                <div class="divider-text">
                                    <span>Account Options</span>
                                </div>
                                <div class="d-grid gap-2 mt-3">
                                    <a href="${pageContext.request.contextPath}/vendor/settings.jsp" class="btn btn-outline-secondary btn-sm">
                                        <i class="fas fa-cog me-2"></i> Account Settings
                                    </a>
                                    <a href="#" data-bs-toggle="modal" data-bs-target="#deactivateAccountModal" class="btn btn-outline-danger btn-sm">
                                        <i class="fas fa-user-slash me-2"></i> Deactivate Account
                                    </a>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Visibility Info -->
                        <div class="card vendor-info-card mt-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Business Visibility</h5>
                            </div>
                            <div class="card-body">
                                <p>Improve your visibility to potential clients by:</p>
                                <ul class="mb-4">
                                    <li>Adding high quality photos</li>
                                    <li>Maintaining a high rating</li>
                                    <li>Responding to inquiries promptly</li>
                                    <li>Keeping your services updated</li>
                                </ul>
                                <div class="d-grid">
                                    <a href="${pageContext.request.contextPath}/vendor/marketing.jsp" class="btn btn-primary">
                                        <i class="fas fa-chart-line me-2"></i> Boost Your Visibility
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
                        <span>Current User: <%= currentUser %> | Last Updated: <%= currentDateTime %></span>
                    </div>
                </footer>
            </div>
        </div>
    </div>

    <!-- Change Password Modal -->
    <div class="modal fade" id="changePasswordModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-key me-2"></i> Change Password</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/VendorProfileServlet" method="post">
                    <input type="hidden" name="action" value="changePassword">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="currentPassword" class="form-label">Current Password</label>
                            <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
                        </div>
                        <div class="mb-3">
                            <label for="newPassword" class="form-label">New Password</label>
                            <input type="password" class="form-control" id="newPassword" name="newPassword" required>
                            <div class="form-text">Password must be at least 8 characters and include numbers and letters.</div>
                        </div>
                        <div class="mb-3">
                            <label for="confirmPassword" class="form-label">Confirm New Password</label>
                            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary">Change Password</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Profile Image Modal -->
    <div class="modal fade" id="profileImageModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Update Profile Photo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/VendorProfileServlet" method="post">
                    <input type="hidden" name="action" value="updateProfileImage">
                    <div class="modal-body">
                        <div class="text-center mb-4">
                            <div class="profile-avatar mx-auto">
                                <img src="<%= vendorProfile.get("profilePictureUrl").getAsString() %>" 
                                     alt="Profile Preview" id="modalProfilePreview" class="img-fluid rounded-circle" style="width: 150px; height: 150px; object-fit: cover;">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="profileImageUrl" class="form-label">Enter Profile Image URL</label>
                            <input type="url" class="form-control" id="profileImageUrl" name="profileImageUrl" 
                                   value="<%= vendorProfile.get("profilePictureUrl").getAsString() %>"
                                   placeholder="https://example.com/image.jpg" required onchange="previewModalImage(this.value)">
                            <div class="form-text text-muted">Enter a direct URL to an image (.jpg, .png, etc.)</div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary" id="saveProfileImageBtn">
                            <i class="fas fa-save me-2"></i> Save Photo
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Cover Image Modal -->
    <div class="modal fade" id="coverImageModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Update Cover Photo</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/VendorProfileServlet" method="post">
                    <input type="hidden" name="action" value="updateCoverImage">
                    <div class="modal-body">
                        <div class="text-center mb-4">
                            <div class="image-preview-container">
                                <img src="<%= vendorProfile.has("coverPhotoUrl") && !vendorProfile.get("coverPhotoUrl").getAsString().isEmpty() ? 
                                    vendorProfile.get("coverPhotoUrl").getAsString() : "/assets/images/vendors/default-cover.jpg" %>" 
                                    alt="Cover Photo Preview" id="modalCoverPreview" class="img-fluid" style="max-height: 200px; width: 100%; object-fit: cover;">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="coverImageUrl" class="form-label">Enter Cover Image URL</label>
                            <input type="url" class="form-control" id="coverImageUrl" name="coverImageUrl" 
                                   value="<%= vendorProfile.has("coverPhotoUrl") ? vendorProfile.get("coverPhotoUrl").getAsString() : "" %>"
                                   placeholder="https://example.com/cover.jpg" required onchange="previewModalCoverImage(this.value)">
                            <div class="form-text text-muted">Enter a direct URL to an image (.jpg, .png, etc.)</div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="submit" class="btn btn-primary" id="saveCoverImageBtn">
                            <i class="fas fa-save me-2"></i> Save Cover
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Deactivate Account Modal -->
    <div class="modal fade" id="deactivateAccountModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title text-danger"><i class="fas fa-exclamation-triangle me-2"></i> Deactivate Account</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to deactivate your vendor account?</p>
                    <p>If you deactivate your account:</p>
                    <ul>
                        <li>Your services will no longer be visible to clients</li>
                        <li>Your existing bookings will be affected</li>
                        <li>You will not be able to receive new booking requests</li>
                        <li>You can reactivate it by contacting support</li>
                    </ul>
                    <div class="mb-3">
                        <label for="deactivateReason" class="form-label">Please tell us why you're leaving:</label>
                        <textarea class="form-control" id="deactivateReason" rows="3"></textarea>
                    </div>
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="deactivateConfirm">
                        <label class="form-check-label" for="deactivateConfirm">I understand that deactivating my account will affect my services and bookings.</label>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeactivateBtn" disabled>Deactivate</button>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Common Dashboard JS -->
    <script src="${pageContext.request.contextPath}/assets/js/vendor/dashboard.js"></script>
    
    <script>
        // Function to preview profile image in the edit form
        function previewProfileImage(imageUrl) {
            if (imageUrl && imageUrl.trim() !== '') {
                document.getElementById('profilePreview').src = imageUrl;
            }
        }
        
        // Function to preview cover image in the edit form
        function previewCoverImage(imageUrl) {
            if (imageUrl && imageUrl.trim() !== '') {
                document.getElementById('coverPreview').src = imageUrl;
            }
        }
        
        // Function to preview image in the profile modal
        function previewModalImage(imageUrl) {
            if (imageUrl && imageUrl.trim() !== '') {
                document.getElementById('modalProfilePreview').src = imageUrl;
            }
        }
        
        // Function to preview image in the cover modal
        function previewModalCoverImage(imageUrl) {
            if (imageUrl && imageUrl.trim() !== '') {
                document.getElementById('modalCoverPreview').src = imageUrl;
            }
        }
        
        // Checkbox validation for account deactivation
        document.getElementById('deactivateConfirm').addEventListener('change', function() {
            document.getElementById('confirmDeactivateBtn').disabled = !this.checked;
        });
        
        // Initialize Bootstrap tooltips
        var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
        var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl)
        });
        
        // Handle image errors
        document.addEventListener('DOMContentLoaded', function() {
            const images = document.querySelectorAll('img');
            images.forEach(img => {
                img.onerror = function() {
                    if (this.id === 'currentCoverPhoto' || this.id === 'modalCoverPreview' || this.id === 'coverPreview') {
                        this.src = '${pageContext.request.contextPath}/assets/images/vendors/default-cover.jpg';
                    } else {
                        this.src = '${pageContext.request.contextPath}/assets/images/vendors/default-vendor.jpg';
                    }
                };
            });
        });
    </script>
</body>
</html>