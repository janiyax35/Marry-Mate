<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter, com.google.gson.JsonObject" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Make sure UserId is set in the session
    String userId = (String) session.getAttribute("userId");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String fullName = (String) session.getAttribute("fullName");
    
    // Redirect if not logged in as user
    if (userId == null || !"user".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Check if we have a userProfile attribute (should be set by servlet)
    JsonObject userProfile = (JsonObject) request.getAttribute("userProfile");
    boolean editMode = (request.getAttribute("editMode") != null) && (boolean) request.getAttribute("editMode");
    
    if (userProfile == null) {
        // Redirect to the servlet to load user data
        response.sendRedirect(request.getContextPath() + "/UserProfileServlet");
        return;
    }
    
    // Updated timestamp and information
    String currentDateTime = "2025-05-18 13:23:08";
    String currentUser = "IT24102083";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | Marry Mate</title>
    
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
    
    <!-- Inline CSS for Profile Page -->
    <style>
        /* Profile Header */
        .profile-header {
            background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
            color: white;
            padding: 40px 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        
        .profile-header::before {
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
        
        .profile-avatar {
            position: relative;
            width: 150px;
            height: 150px;
            border-radius: 50%;
            border: 5px solid rgba(255,255,255,0.3);
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            margin-bottom: 20px;
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
        
        .profile-info-card {
            transition: all 0.3s ease;
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
        }
        
        .profile-info-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }
        
        .profile-tabs .nav-link {
            color: #495057;
            border: none;
            border-bottom: 3px solid transparent;
            font-weight: 600;
            padding: 12px 20px;
        }
        
        .profile-tabs .nav-link.active {
            color: #6a11cb;
            border-bottom-color: #6a11cb;
            background: transparent;
        }
        
        .form-label {
            font-weight: 500;
        }
        
        .edit-info-btn {
            position: absolute;
            top: 20px;
            right: 20px;
            z-index: 2;
        }
        
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
        
        .activity-item {
            padding: 15px;
            border-left: 3px solid #6a11cb;
            background-color: #f9f9f9;
            margin-bottom: 15px;
            border-radius: 0 8px 8px 0;
        }
        
        .profile-stats {
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
        
        /* Image preview container */
        .image-preview-container {
            width: 100%;
            text-align: center;
            margin-bottom: 15px;
        }
        
        .image-preview-container img {
            max-width: 100%;
            height: auto;
            max-height: 300px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .profile-header {
                padding: 30px 15px;
            }
            
            .profile-avatar {
                width: 120px;
                height: 120px;
            }
        }
    </style>
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
                    <li>
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
                    <li   class="active">
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
                <button id="sidebar-toggle">
                    <i class="fas fa-bars"></i>
                </button>
                
                <div class="user-info">
                    <h4>My Profile</h4>
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
                                            <p><strong>Booking confirmed</strong> - Your wedding photography booking has been approved!</p>
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
                                            <p><strong>New message</strong> - You've received a message from Elegant Photography.</p>
                                            <span class="notification-time">2 hours ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li>
                                    <a href="#">
                                        <div class="notification-icon bg-success">
                                            <i class="fas fa-check-circle"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>Payment received</strong> - Thank you for your catering deposit payment.</p>
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
                            <img src="<%= userProfile.get("profilePictureURL").getAsString() %>" alt="User" class="profile-img">
                            <span class="user-name"><%= userProfile.get("fullName").getAsString() %></span>
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

            <!-- Profile Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>My Profile</h1>
                        <p class="subtitle">View and update your personal information</p>
                    </div>
                    <div class="page-actions">
                        <% if (!editMode) { %>
                            <a href="${pageContext.request.contextPath}/UserProfileServlet?action=editProfile" class="btn btn-primary">
                                <i class="fas fa-edit me-2"></i>
                                Edit Profile
                            </a>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/UserProfileServlet" class="btn btn-outline-secondary">
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
                
                <c:if test="${not empty imageMessage}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <i class="fas fa-check-circle me-2"></i> ${imageMessage}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                
                <c:if test="${not empty imageError}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i> ${imageError}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                
                <!-- Profile Header -->
                <div class="profile-header">
                    <div class="text-center">
                        <div class="profile-avatar mx-auto">
                            <img src="<%= userProfile.get("profilePictureURL").getAsString() %>" alt="Profile Picture" id="currentProfileImage">
                            <div class="change-photo-btn" data-bs-toggle="modal" data-bs-target="#profileImageModal">
                                <i class="fas fa-camera"></i>
                            </div>
                        </div>
                        <h3 class="mb-1"><%= userProfile.get("fullName").getAsString() %></h3>
                        <p class="text-light mb-3">@<%= userProfile.get("username").getAsString() %></p>
                        <p class="mb-0">
                            <span class="badge bg-light text-dark me-2">
                                <i class="fas fa-user me-1"></i> <%= userProfile.get("role").getAsString() %>
                            </span>
                            <span class="badge bg-light text-dark me-2">
                                <i class="fas fa-circle me-1 <%= userProfile.get("accountStatus").getAsString().equals("active") ? "text-success" : 
                                      (userProfile.get("accountStatus").getAsString().equals("pending") ? "text-warning" : "text-danger") %>"></i> 
                                <%= userProfile.get("accountStatus").getAsString() %>
                            </span>
                            <span class="badge bg-light text-dark">
                                <i class="fas fa-calendar me-1"></i> Joined <%= userProfile.get("registrationDate").getAsString().split(" ")[0] %>
                            </span>
                        </p>
                    </div>
                </div>
                
                <!-- Profile Content -->
                <div class="row">
                    <!-- Left Column - User Information -->
                    <div class="col-lg-8 mb-4">
                        <% if (!editMode) { %>
                            <!-- View Profile Information -->
                            <div class="card profile-info-card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0">Personal Information</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row mb-3">
                                        <div class="col-md-4">
                                            <p class="text-muted mb-1">Full Name</p>
                                            <p class="fw-bold mb-0"><%= userProfile.get("fullName").getAsString() %></p>
                                        </div>
                                        <div class="col-md-4">
                                            <p class="text-muted mb-1">Username</p>
                                            <p class="fw-bold mb-0"><%= userProfile.get("username").getAsString() %></p>
                                        </div>
                                        <div class="col-md-4">
                                            <p class="text-muted mb-1">User ID</p>
                                            <p class="fw-bold mb-0"><%= userProfile.get("userId").getAsString() %></p>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Email Address</p>
                                            <p class="fw-bold mb-0"><%= userProfile.get("email").getAsString() %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Phone Number</p>
                                            <p class="fw-bold mb-0">
                                                <% if (userProfile.has("phoneNumber") && !userProfile.get("phoneNumber").getAsString().isEmpty()) { %>
                                                    <%= userProfile.get("phoneNumber").getAsString() %>
                                                <% } else { %>
                                                    <span class="text-muted fst-italic">Not provided</span>
                                                <% } %>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <p class="text-muted mb-1">Address</p>
                                            <p class="fw-bold mb-0">
                                                <% if (userProfile.has("address") && !userProfile.get("address").getAsString().isEmpty()) { %>
                                                    <%= userProfile.get("address").getAsString() %>
                                                <% } else { %>
                                                    <span class="text-muted fst-italic">No address provided</span>
                                                <% } %>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Account Security -->
                            <div class="card profile-info-card mb-4">
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
                                            <p class="mb-0"><%= userProfile.get("lastLogin").getAsString() %></p>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Account Status</p>
                                            <p class="mb-0">
                                                <span class="badge <%= userProfile.get("accountStatus").getAsString().equals("active") ? "bg-success" : 
                                                      (userProfile.get("accountStatus").getAsString().equals("pending") ? "bg-warning" : "bg-danger") %>">
                                                    <i class="fas fa-circle me-1"></i> <%= userProfile.get("accountStatus").getAsString() %>
                                                </span>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Failed Login Attempts</p>
                                            <p class="mb-0"><%= userProfile.get("failedLoginAttempts").getAsInt() %></p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                        <% } else { %>
                            <!-- Edit Profile Form -->
                            <div class="card profile-info-card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0">Edit Personal Information</h5>
                                </div>
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/UserProfileServlet" method="post">
                                        <input type="hidden" name="action" value="updateProfile">
                                        
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="fullName" class="form-label">Full Name <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                                    value="<%= userProfile.get("fullName").getAsString() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="username" class="form-label">Username <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="username" name="username" 
                                                    value="<%= userProfile.get("username").getAsString() %>" required>
                                            </div>
                                        </div>
                                        
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="email" class="form-label">Email Address <span class="text-danger">*</span></label>
                                                <input type="email" class="form-control" id="email" name="email" 
                                                    value="<%= userProfile.get("email").getAsString() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="phoneNumber" class="form-label">Phone Number</label>
                                                <input type="text" class="form-control" id="phoneNumber" name="phoneNumber" 
                                                    value="<%= userProfile.has("phoneNumber") ? userProfile.get("phoneNumber").getAsString() : "" %>" 
                                                    placeholder="Enter your phone number">
                                            </div>
                                        </div>
                                        
                                        <div class="mb-3">
                                            <label for="address" class="form-label">Address</label>
                                            <textarea class="form-control" id="address" name="address" rows="3" 
                                                placeholder="Enter your address"><%= userProfile.has("address") ? userProfile.get("address").getAsString() : "" %></textarea>
                                        </div>
                                        
                                        <div class="mb-4">
                                            <label for="profilePictureURL" class="form-label">Profile Picture URL</label>
                                            <input type="url" class="form-control" id="profilePictureURL" name="profilePictureURL" 
                                                value="<%= userProfile.get("profilePictureURL").getAsString() %>" 
                                                placeholder="Enter image URL" onchange="previewProfileImage(this.value)">
                                            <div class="form-text">Enter a direct URL to an image (.jpg, .png, etc.)</div>
                                            
                                            <div class="image-preview-container mt-3">
                                                <img src="<%= userProfile.get("profilePictureURL").getAsString() %>" alt="Profile Preview" id="profilePreview">
                                            </div>
                                        </div>
                                        
                                        <div class="d-flex justify-content-end">
                                            <a href="${pageContext.request.contextPath}/UserProfileServlet" class="btn btn-outline-secondary me-2">
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
                        
                        <!-- Account Activity -->
                        <div class="card profile-info-card mb-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Recent Account Activity</h5>
                            </div>
                            <div class="card-body">
                                <div class="activity-item">
                                    <div class="d-flex justify-content-between mb-2">
                                        <strong>Profile Updated</strong>
                                        <span class="text-muted"><%= userProfile.get("updatedAt").getAsString() %></span>
                                    </div>
                                    <p class="mb-0">Your profile information was updated by <%= userProfile.get("updatedBy").getAsString() %></p>
                                </div>
                                
                                <div class="activity-item">
                                    <div class="d-flex justify-content-between mb-2">
                                        <strong>Successful Login</strong>
                                        <span class="text-muted"><%= userProfile.get("lastLogin").getAsString() %></span>
                                    </div>
                                    <p class="mb-0">You successfully logged in to your account</p>
                                </div>
                                
                                <div class="activity-item">
                                    <div class="d-flex justify-content-between mb-2">
                                        <strong>Account Created</strong>
                                        <span class="text-muted"><%= userProfile.get("registrationDate").getAsString() %></span>
                                    </div>
                                    <p class="mb-0">Your account was created successfully</p>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Right Column - Stats and Additional Info -->
                    <div class="col-lg-4">
                        <!-- User Stats -->
                        <div class="card profile-info-card mb-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Account Overview</h5>
                            </div>
                            <div class="card-body">
                                <div class="profile-stats">
                                    <div class="stat-item">
                                        <p class="stat-value">5</p>
                                        <p class="stat-label">Bookings</p>
                                    </div>
                                    <div class="stat-item">
                                        <p class="stat-value">3</p>
                                        <p class="stat-label">Reviews</p>
                                    </div>
                                    <div class="stat-item">
                                        <p class="stat-value">7</p>
                                        <p class="stat-label">Favorites</p>
                                    </div>
                                </div>
                                
                                <div class="d-grid gap-2">
                                    <a href="${pageContext.request.contextPath}/user/user-bookings.jsp" class="btn btn-outline-primary">
                                        <i class="fas fa-calendar-check me-2"></i> View My Bookings
                                    </a>
                                    <a href="${pageContext.request.contextPath}/user/user-reviews.jsp" class="btn btn-outline-primary">
                                        <i class="fas fa-star me-2"></i> View My Reviews
                                    </a>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Account Information -->
                        <div class="card profile-info-card mb-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Account Information</h5>
                            </div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <p class="text-muted mb-1">Member Since</p>
                                    <p class="fw-bold"><%= userProfile.get("registrationDate").getAsString().split(" ")[0] %></p>
                                </div>
                                <div class="mb-3">
                                    <p class="text-muted mb-1">Account Type</p>
                                    <p class="fw-bold text-capitalize"><%= userProfile.get("role").getAsString() %></p>
                                </div>
                                <div>
                                    <p class="text-muted mb-1">Last Updated</p>
                                    <p class="fw-bold"><%= userProfile.get("updatedAt").getAsString() %></p>
                                </div>
                                <div class="divider-text">
                                    <span>Account Options</span>
                                </div>
                                <div class="d-grid gap-2 mt-3">
                                    <a href="#" data-bs-toggle="modal" data-bs-target="#deactivateAccountModal" class="btn btn-outline-danger btn-sm">
                                        <i class="fas fa-user-slash me-2"></i> Deactivate Account
                                    </a>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Need Help? -->
                        <div class="card profile-info-card">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Need Help?</h5>
                            </div>
                            <div class="card-body">
                                <p>If you have any questions about your account or need assistance, our support team is here to help.</p>
                                <div class="d-grid">
                                    <a href="${pageContext.request.contextPath}/views/contact.jsp" class="btn btn-primary">
                                        <i class="fas fa-headset me-2"></i> Contact Support
                                    </a>
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

    <!-- Change Password Modal -->
    <div class="modal fade" id="changePasswordModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-key me-2"></i> Change Password</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <form action="${pageContext.request.contextPath}/UserProfileServlet" method="post">
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
                <form action="${pageContext.request.contextPath}/UserProfileServlet" method="post">
                    <input type="hidden" name="action" value="updateProfileImage">
                    <div class="modal-body">
                        <div class="text-center mb-4">
                            <div class="profile-avatar mx-auto">
                                <img src="<%= userProfile.get("profilePictureURL").getAsString() %>" 
                                     alt="Profile Preview" id="modalProfilePreview" class="img-fluid rounded-circle" style="width: 150px; height: 150px; object-fit: cover;">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="profileImageUrl" class="form-label">Enter Profile Image URL</label>
                            <input type="url" class="form-control" id="profileImageUrl" name="profileImageUrl" 
                                   value="<%= userProfile.get("profilePictureURL").getAsString() %>"
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
    
    <!-- Deactivate Account Modal -->
    <div class="modal fade" id="deactivateAccountModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title text-danger"><i class="fas fa-exclamation-triangle me-2"></i> Deactivate Account</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to deactivate your account?</p>
                    <p>If you deactivate your account:</p>
                    <ul>
                        <li>Your profile will no longer be visible</li>
                        <li>Your bookings will be cancelled</li>
                        <li>You can reactivate it by contacting support</li>
                    </ul>
                    <div class="mb-3">
                        <label for="deactivateReason" class="form-label">Please tell us why you're leaving:</label>
                        <textarea class="form-control" id="deactivateReason" rows="3"></textarea>
                    </div>
                    <div class="mb-3 form-check">
                        <input type="checkbox" class="form-check-input" id="deactivateConfirm">
                        <label class="form-check-label" for="deactivateConfirm">I understand that deactivating my account will cancel all my bookings.</label>
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
    <script src="${pageContext.request.contextPath}/assets/js/user/dashboard.js"></script>
    
    <script>
        // Function to preview profile image in the edit form
        function previewProfileImage(imageUrl) {
            if (imageUrl && imageUrl.trim() !== '') {
                document.getElementById('profilePreview').src = imageUrl;
            }
        }
        
        // Function to preview image in the modal
        function previewModalImage(imageUrl) {
            if (imageUrl && imageUrl.trim() !== '') {
                document.getElementById('modalProfilePreview').src = imageUrl;
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
                    this.src = '${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg';
                };
            });
        });
    </script>
</body>
</html>