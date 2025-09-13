<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter, com.google.gson.JsonObject, com.google.gson.JsonArray" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Make sure UserId is set in the session
    String userId = (String) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    
    // Redirect if not logged in as admin
    if (userId == null || !(role.equals("admin") || role.equals("super_admin"))) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Check if we have a adminProfile attribute (should be set by servlet)
    JsonObject adminProfile = (JsonObject) request.getAttribute("adminProfile");
    boolean editMode = (request.getAttribute("editMode") != null) && (boolean) request.getAttribute("editMode");
    
    if (adminProfile == null) {
        // Redirect to the servlet to load admin data
        response.sendRedirect(request.getContextPath() + "/AdminProfileServlet");
        return;
    }
    
    // Check if admin is super admin
    boolean isSuperAdmin = adminProfile.has("isSuperAdmin") && adminProfile.get("isSuperAdmin").getAsBoolean();
    
    // Get permissions as a list
    List<String> adminPermissions = new ArrayList<>();
    if (adminProfile.has("permissions") && adminProfile.get("permissions").isJsonArray()) {
        JsonArray permissionsArray = adminProfile.getAsJsonArray("permissions");
        for (int i = 0; i < permissionsArray.size(); i++) {
            adminPermissions.add(permissionsArray.get(i).getAsString());
        }
    }
    
    // Updated timestamp and information
    String currentDateTime = "2025-05-18 14:23:18";
    String currentUser = "IT24102083";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Profile | Marry Mate</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/dashboard.css">
    
    <!-- Inline Styles for Admin Profile -->
    <style>
        /* Admin Profile Header */
        .admin-profile-header {
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: white;
            padding: 40px 20px;
            border-radius: 8px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        
        .admin-profile-header::before {
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
        
        /* Profile Avatar */
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
        
        /* Admin Info Card */
        .admin-info-card {
            transition: all 0.3s ease;
            border: none;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            margin-bottom: 25px;
        }
        
        .admin-info-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
        }
        
        /* Permission Badges */
        .permission-badge {
            display: inline-block;
            background-color: #f8f9fa;
            color: #2a5298;
            border: 1px solid #e9ecef;
            border-radius: 30px;
            padding: 5px 15px;
            margin: 0 5px 10px 0;
            font-size: 0.85rem;
            font-weight: 500;
            transition: all 0.2s;
        }
        
        .permission-badge:hover {
            background-color: #2a5298;
            color: white;
        }
        
        /* Permission Checkboxes */
        .permission-check {
            margin-bottom: 10px;
        }
        
        .permission-check label {
            margin-left: 8px;
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
        
        /* Admin Statistics */
        .admin-stats {
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
            color: #2a5298;
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
        
        /* Super admin badge */
        .super-admin-badge {
            background-color: #fd7e14;
            color: white;
            font-weight: 500;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        
        /* Activity feed */
        .activity-item {
            padding: 15px;
            border-left: 3px solid #2a5298;
            background-color: #f9f9f9;
            margin-bottom: 15px;
            border-radius: 0 8px 8px 0;
        }
        
        /* Responsive adjustments */
        @media (max-width: 768px) {
            .profile-avatar {
                width: 120px;
                height: 120px;
            }
        }
    </style>
</head>
<body>
<div class="admin-container">
        <!-- Sidebar Navigation -->
        <nav class="sidebar">
            <div class="sidebar-header">
                <div class="logo-container">
                    <i class="fas fa-heart"></i>
                    <i class="fas fa-ring"></i>
                </div>
                <h3>Marry Mate</h3>
                <span>Admin Panel</span>
            </div>
            
            <div class="sidebar-menu">
                <ul>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp">
                            <i class="fas fa-tachometer-alt"></i>
                            <span>Dashboard</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/user-management.jsp">
                            <i class="fas fa-users"></i>
                            <span>User Management</span>
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/vendor-management.jsp">
                            <i class="fas fa-store"></i>
                            <span>Vendor Management</span>
                        </a>
                    </li>
                    
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/service-management.jsp">
                            <i class="fas fa-concierge-bell"></i>
                            <span>Service Management</span>
                        </a>
                    </li>
                    
	                <li class="active">
                        <a href="${pageContext.request.contextPath}/AdminProfileServlet">
                            <i class="fas fa-user-cog"></i>
                            <span>My Profile</span>
                        </a>
                    </li>
                    <li>
	                <a href="${pageContext.request.contextPath}/admin/sessions.jsp">
	                    <i class="fas fa-user-clock"></i>
	                    <span>Session Management</span>
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
                    <h4>Admin Profile</h4>
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
                                            <i class="fas fa-user-plus"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>New user registration</strong> - A new user has registered.</p>
                                            <span class="notification-time">30 minutes ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-info">
                                            <i class="fas fa-store"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>New vendor application</strong> - A new vendor has applied.</p>
                                            <span class="notification-time">2 hours ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li>
                                    <a href="#">
                                        <div class="notification-icon bg-warning">
                                            <i class="fas fa-exclamation-triangle"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>System alert</strong> - Database backup completed.</p>
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
                            <img src="<%= adminProfile.has("profilePictureURL") && !adminProfile.get("profilePictureURL").getAsString().isEmpty() ? 
                                adminProfile.get("profilePictureURL").getAsString() : "${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg" %>" 
                                alt="User" class="profile-img">
                            <span class="user-name"><%= adminProfile.get("fullName").getAsString() %></span>
                            <i class="fas fa-chevron-down"></i>
                        </button>
                        <div class="profile-dropdown">
                            <ul>
                                <li><a href="${pageContext.request.contextPath}/AdminProfileServlet"><i class="fas fa-user-circle"></i> My Profile</a></li>
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
                        <h1>Admin Profile</h1>
                        <p class="subtitle">View and update your administrator information</p>
                    </div>
                    <div class="page-actions">
                        <% if (!editMode) { %>
                            <a href="${pageContext.request.contextPath}/AdminProfileServlet?action=editProfile" class="btn btn-primary">
                                <i class="fas fa-edit me-2"></i>
                                Edit Profile
                            </a>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/AdminProfileServlet" class="btn btn-outline-secondary">
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
                
                <!-- Admin Profile Header -->
                <div class="admin-profile-header">
                    <div class="text-center">
                        <div class="profile-avatar mx-auto">
                            <img src="<%= adminProfile.has("profilePictureURL") && !adminProfile.get("profilePictureURL").getAsString().isEmpty() ? 
                                adminProfile.get("profilePictureURL").getAsString() : "${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg" %>" 
                                alt="Profile Picture" id="currentProfileImage">
                            <div class="change-photo-btn" data-bs-toggle="modal" data-bs-target="#profileImageModal">
                                <i class="fas fa-camera"></i>
                            </div>
                        </div>
                        <h3 class="mb-1"><%= adminProfile.get("fullName").getAsString() %></h3>
                        <p class="text-light mb-2">@<%= adminProfile.get("username").getAsString() %></p>
                        
                        <div class="mb-3">
                            <% if (isSuperAdmin) { %>
                                <span class="super-admin-badge">
                                    <i class="fas fa-shield-alt me-1"></i> Super Admin
                                </span>
                            <% } else { %>
                                <span class="badge bg-light text-dark">
                                    <i class="fas fa-user-cog me-1"></i> Administrator
                                </span>
                            <% } %>
                        </div>
                        
                        <p class="mb-0">
                            <span class="badge bg-light text-dark me-2">
                                <i class="fas fa-id-badge me-1"></i> ID: <%= adminProfile.get("userId").getAsString() %>
                            </span>
                            
                            <% if (adminProfile.has("department") && !adminProfile.get("department").getAsString().isEmpty()) { %>
                                <span class="badge bg-light text-dark me-2">
                                    <i class="fas fa-building me-1"></i> <%= adminProfile.get("department").getAsString() %>
                                </span>
                            <% } %>
                            
                            <span class="badge bg-light text-dark">
                                <i class="fas fa-calendar me-1"></i> Since <%= adminProfile.has("createdDate") ? 
                                    adminProfile.get("createdDate").getAsString().split(" ")[0] : 
                                    adminProfile.has("registrationDate") ? 
                                    adminProfile.get("registrationDate").getAsString().split(" ")[0] : "N/A" %>
                            </span>
                        </p>
                    </div>
                </div>
                
                <!-- Profile Content -->
                <div class="row">
                    <!-- Left Column - Admin Information -->
                    <div class="col-lg-8 mb-4">
                        <% if (!editMode) { %>
                            <!-- View Admin Information -->
                            <div class="card admin-info-card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0">Personal Information</h5>
                                </div>
                                <div class="card-body">
                                    <div class="row mb-3">
                                        <div class="col-md-4">
                                            <p class="text-muted mb-1">Full Name</p>
                                            <p class="fw-bold mb-0"><%= adminProfile.get("fullName").getAsString() %></p>
                                        </div>
                                        <div class="col-md-4">
                                            <p class="text-muted mb-1">Username</p>
                                            <p class="fw-bold mb-0"><%= adminProfile.get("username").getAsString() %></p>
                                        </div>
                                        <div class="col-md-4">
                                            <p class="text-muted mb-1">Admin ID</p>
                                            <p class="fw-bold mb-0"><%= adminProfile.get("userId").getAsString() %></p>
                                        </div>
                                    </div>
                                    <div class="row mb-3">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Email Address</p>
                                            <p class="fw-bold mb-0"><%= adminProfile.get("email").getAsString() %></p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Phone Number</p>
                                            <p class="fw-bold mb-0">
                                                <% if (adminProfile.has("phoneNumber") && !adminProfile.get("phoneNumber").getAsString().isEmpty()) { %>
                                                    <%= adminProfile.get("phoneNumber").getAsString() %>
                                                <% } else { %>
                                                    <span class="text-muted fst-italic">Not provided</span>
                                                <% } %>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Department</p>
                                            <p class="fw-bold mb-0">
                                                <% if (adminProfile.has("department") && !adminProfile.get("department").getAsString().isEmpty()) { %>
                                                    <%= adminProfile.get("department").getAsString() %>
                                                <% } else { %>
                                                    <span class="text-muted fst-italic">Not specified</span>
                                                <% } %>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Position</p>
                                            <p class="fw-bold mb-0">
                                                <% if (adminProfile.has("position") && !adminProfile.get("position").getAsString().isEmpty()) { %>
                                                    <%= adminProfile.get("position").getAsString() %>
                                                <% } else { %>
                                                    <span class="text-muted fst-italic">Not specified</span>
                                                <% } %>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Permissions Information -->
                            <div class="card admin-info-card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0">Account Permissions</h5>
                                </div>
                                <div class="card-body">
                                    <div class="mb-3">
                                        <p class="text-muted mb-2">Current Permissions</p>
                                        <div>
                                            <% if (adminPermissions.isEmpty()) { %>
                                                <p class="text-muted fst-italic">No specific permissions assigned</p>
                                            <% } else { 
                                                for (String permission : adminPermissions) { %>
                                                    <span class="permission-badge"><%= permission %></span>
                                                <% }
                                            } %>
                                        </div>
                                    </div>
                                    
                                    <div>
                                        <p class="text-muted mb-2">Account Role</p>
                                        <p class="mb-0">
                                            <% if (isSuperAdmin) { %>
                                                <span class="badge bg-warning text-dark">
                                                    <i class="fas fa-shield-alt me-1"></i> Super Administrator
                                                </span>
                                                <small class="d-block mt-2 text-muted">
                                                    Super administrators have full access to all system features and can manage other admin accounts.
                                                </small>
                                            <% } else { %>
                                                <span class="badge bg-primary">
                                                    <i class="fas fa-user-cog me-1"></i> Administrator
                                                </span>
                                                <small class="d-block mt-2 text-muted">
                                                    Regular administrators have limited access based on their assigned permissions.
                                                </small>
                                            <% } %>
                                        </p>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Account Security -->
                            <div class="card admin-info-card mb-4">
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
                                            <p class="mb-0"><%= adminProfile.get("lastLogin").getAsString() %></p>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Account Status</p>
                                            <p class="mb-0">
                                                <span class="badge bg-success">
                                                    <i class="fas fa-circle me-1"></i> Active
                                                </span>
                                            </p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="text-muted mb-1">Failed Login Attempts</p>
                                            <p class="mb-0">
                                                <%= adminProfile.has("failedLoginAttempts") ? 
                                                    adminProfile.get("failedLoginAttempts").getAsInt() : 0 %>
                                            </p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                        <% } else { %>
                            <!-- Edit Admin Profile Form -->
                            <div class="card admin-info-card mb-4">
                                <div class="card-header bg-white">
                                    <h5 class="mb-0">Edit Personal Information</h5>
                                </div>
                                <div class="card-body">
                                    <form action="${pageContext.request.contextPath}/AdminProfileServlet" method="post">
                                        <input type="hidden" name="action" value="updateProfile">
                                        
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="fullName" class="form-label">Full Name <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="fullName" name="fullName" 
                                                    value="<%= adminProfile.get("fullName").getAsString() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="username" class="form-label">Username <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control" id="username" name="username" 
                                                    value="<%= adminProfile.get("username").getAsString() %>" required>
                                            </div>
                                        </div>
                                        
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="email" class="form-label">Email Address <span class="text-danger">*</span></label>
                                                <input type="email" class="form-control" id="email" name="email" 
                                                    value="<%= adminProfile.get("email").getAsString() %>" required>
                                            </div>
                                            <div class="col-md-6">
                                                <label for="phoneNumber" class="form-label">Phone Number</label>
                                                <input type="text" class="form-control" id="phoneNumber" name="phoneNumber" 
                                                    value="<%= adminProfile.has("phoneNumber") ? adminProfile.get("phoneNumber").getAsString() : "" %>" 
                                                    placeholder="Enter your phone number">
                                            </div>
                                        </div>
                                        
                                        <div class="row mb-3">
                                            <div class="col-md-6">
                                                <label for="department" class="form-label">Department</label>
                                                <input type="text" class="form-control" id="department" name="department" 
                                                    value="<%= adminProfile.has("department") ? adminProfile.get("department").getAsString() : "" %>" 
                                                    placeholder="Enter your department">
                                            </div>
                                            <div class="col-md-6">
                                                <label for="position" class="form-label">Position</label>
                                                <input type="text" class="form-control" id="position" name="position" 
                                                    value="<%= adminProfile.has("position") ? adminProfile.get("position").getAsString() : "" %>" 
                                                    placeholder="Enter your position">
                                            </div>
                                        </div>
                                        
                                        <% if (isSuperAdmin) { %>
                                        <div class="mb-4">
                                            <label class="form-label">Permissions</label>
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="permission-check">
                                                        <input type="checkbox" class="form-check-input" id="manage_users" name="permissions" value="manage_users"
                                                            <%= adminPermissions.contains("manage_users") ? "checked" : "" %>>
                                                        <label for="manage_users">Manage Users</label>
                                                    </div>
                                                    <div class="permission-check">
                                                        <input type="checkbox" class="form-check-input" id="manage_vendors" name="permissions" value="manage_vendors"
                                                            <%= adminPermissions.contains("manage_vendors") ? "checked" : "" %>>
                                                        <label for="manage_vendors">Manage Vendors</label>
                                                    </div>
                                                    <div class="permission-check">
                                                        <input type="checkbox" class="form-check-input" id="manage_bookings" name="permissions" value="manage_bookings"
                                                            <%= adminPermissions.contains("manage_bookings") ? "checked" : "" %>>
                                                        <label for="manage_bookings">Manage Bookings</label>
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="permission-check">
                                                        <input type="checkbox" class="form-check-input" id="manage_services" name="permissions" value="manage_services"
                                                            <%= adminPermissions.contains("manage_services") ? "checked" : "" %>>
                                                        <label for="manage_services">Manage Services</label>
                                                    </div>
                                                    <div class="permission-check">
                                                        <input type="checkbox" class="form-check-input" id="manage_admins" name="permissions" value="manage_admins"
                                                            <%= adminPermissions.contains("manage_admins") ? "checked" : "" %>>
                                                        <label for="manage_admins">Manage Admins</label>
                                                    </div>
                                                    <div class="permission-check">
                                                        <input type="checkbox" class="form-check-input" id="view_reports" name="permissions" value="view_reports"
                                                            <%= adminPermissions.contains("view_reports") ? "checked" : "" %>>
                                                        <label for="view_reports">View Reports</label>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <% } %>
                                        
                                        <div class="mb-4">
                                            <label for="profilePictureURL" class="form-label">Profile Picture URL</label>
                                            <input type="url" class="form-control" id="profilePictureURL" name="profilePictureURL" 
                                                value="<%= adminProfile.has("profilePictureURL") ? adminProfile.get("profilePictureURL").getAsString() : "" %>" 
                                                placeholder="Enter image URL" onchange="previewProfileImage(this.value)">
                                            <div class="form-text">Enter a direct URL to an image (.jpg, .png, etc.)</div>
                                            
                                            <div class="image-preview-container mt-3">
                                                <img src="<%= adminProfile.has("profilePictureURL") && !adminProfile.get("profilePictureURL").getAsString().isEmpty() ? 
                                                    adminProfile.get("profilePictureURL").getAsString() : "${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg" %>" 
                                                    alt="Profile Preview" id="profilePreview">
                                            </div>
                                        </div>
                                        
                                        <div class="d-flex justify-content-end">
                                            <a href="${pageContext.request.contextPath}/AdminProfileServlet" class="btn btn-outline-secondary me-2">
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
                        <div class="card admin-info-card">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Recent Account Activity</h5>
                            </div>
                            <div class="card-body">
                                <div class="activity-item">
                                    <div class="d-flex justify-content-between mb-2">
                                        <strong>Profile Login</strong>
                                        <span class="text-muted"><%= adminProfile.get("lastLogin").getAsString() %></span>
                                    </div>
                                    <p class="mb-0">Successful login to admin panel</p>
                                </div>
                                
                                <div class="activity-item">
                                    <div class="d-flex justify-content-between mb-2">
                                        <strong>Profile Updated</strong>
                                        <span class="text-muted"><%= adminProfile.has("updatedAt") ? adminProfile.get("updatedAt").getAsString() : currentDateTime %></span>
                                    </div>
                                    <p class="mb-0">Admin profile information was updated</p>
                                </div>
                                
                                <div class="activity-item">
                                    <div class="d-flex justify-content-between mb-2">
                                        <strong>Account Created</strong>
                                        <span class="text-muted"><%= adminProfile.has("createdDate") ? 
                                            adminProfile.get("createdDate").getAsString() : 
                                            adminProfile.has("registrationDate") ? 
                                            adminProfile.get("registrationDate").getAsString() : "N/A" %></span>
                                    </div>
                                    <p class="mb-0">Admin account was created by 
                                        <%= adminProfile.has("createdBy") && !adminProfile.get("createdBy").isJsonNull() ? 
                                            adminProfile.get("createdBy").getAsString() : "System" %>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Right Column - Stats and Additional Info -->
                    <div class="col-lg-4">
                        <!-- Admin Stats -->
                        <div class="card admin-info-card mb-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Administration Overview</h5>
                            </div>
                            <div class="card-body">
                                <div class="admin-stats">
                                    <div class="stat-item">
                                        <p class="stat-value">24</p>
                                        <p class="stat-label">Users Managed</p>
                                    </div>
                                    <div class="stat-item">
                                        <p class="stat-value">12</p>
                                        <p class="stat-label">Vendors Managed</p>
                                    </div>
                                    <div class="stat-item">
                                        <p class="stat-value">35</p>
                                        <p class="stat-label">Actions Today</p>
                                    </div>
                                </div>
                                
                                <div class="d-grid gap-2">
                                    <a href="${pageContext.request.contextPath}/admin/user-management.jsp" class="btn btn-outline-primary">
                                        <i class="fas fa-users me-2"></i> Manage Users
                                    </a>

                                </div>
                            </div>
                        </div>
                        
                        <!-- Account Information -->
                        <div class="card admin-info-card mb-4">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">Account Information</h5>
                            </div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <p class="text-muted mb-1">Admin Since</p>
                                    <p class="fw-bold">
                                        <%= adminProfile.has("createdDate") ? 
                                            adminProfile.get("createdDate").getAsString().split(" ")[0] : 
                                            adminProfile.has("registrationDate") ? 
                                            adminProfile.get("registrationDate").getAsString().split(" ")[0] : "N/A" %>
                                    </p>
                                </div>
                                <div class="mb-3">
                                    <p class="text-muted mb-1">Account Type</p>
                                    <p class="fw-bold text-capitalize">
                                        <%= isSuperAdmin ? "Super Administrator" : "Administrator" %>
                                    </p>
                                </div>
                                <div>
                                    <p class="text-muted mb-1">Last Updated</p>
                                    <p class="fw-bold">
                                        <%= adminProfile.has("updatedAt") ? adminProfile.get("updatedAt").getAsString() : currentDateTime %>
                                    </p>
                                </div>
                                <div class="divider-text">
                                    <span>Account Options</span>
                                </div>
                                <div class="d-grid gap-2 mt-3">
                                    <a href="${pageContext.request.contextPath}/admin/settings.jsp" class="btn btn-outline-secondary btn-sm">
                                        <i class="fas fa-cog me-2"></i> Account Settings
                                    </a>
                                    <button class="btn btn-outline-danger btn-sm" data-bs-toggle="modal" data-bs-target="#twoFactorModal">
                                        <i class="fas fa-shield-alt me-2"></i> Setup Two-Factor Auth
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- System Status -->
                        <div class="card admin-info-card">
                            <div class="card-header bg-white">
                                <h5 class="mb-0">System Status</h5>
                            </div>
                            <div class="card-body">
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span>Server Health</span>
                                        <span class="text-success">Excellent</span>
                                    </div>
                                    <div class="progress" style="height: 8px;">
                                        <div class="progress-bar bg-success" role="progressbar" style="width: 95%;" aria-valuenow="95" aria-valuemin="0" aria-valuemax="100"></div>
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span>Database Usage</span>
                                        <span class="text-info">Moderate</span>
                                    </div>
                                    <div class="progress" style="height: 8px;">
                                        <div class="progress-bar bg-info" role="progressbar" style="width: 65%;" aria-valuenow="65" aria-valuemin="0" aria-valuemax="100"></div>
                                    </div>
                                </div>
                                
                                <div class="mb-4">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span>Memory Usage</span>
                                        <span class="text-warning">High</span>
                                    </div>
                                    <div class="progress" style="height: 8px;">
                                        <div class="progress-bar bg-warning" role="progressbar" style="width: 80%;" aria-valuenow="80" aria-valuemin="0" aria-valuemax="100"></div>
                                    </div>
                                </div>
                                
                                <div class="d-grid">
                                    <a href="${pageContext.request.contextPath}/admin/system-status.jsp" class="btn btn-primary">
                                        <i class="fas fa-server me-2"></i> View System Status
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Footer -->
                <footer class="admin-footer">
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
                <form action="${pageContext.request.contextPath}/AdminProfileServlet" method="post">
                    <input type="hidden" name="action" value="changePassword">
                    <div class="modal-body">
                        <div class="mb-3">
                            <label for="currentPassword" class="form-label">Current Password</label>
                            <input type="password" class="form-control" id="currentPassword" name="currentPassword" required>
                        </div>
                        <div class="mb-3">
                            <label for="newPassword" class="form-label">New Password</label>
                            <input type="password" class="form-control" id="newPassword" name="newPassword" required>
                            <div class="form-text">Password must be at least 8 characters with numbers and special characters.</div>
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
                <form action="${pageContext.request.contextPath}/AdminProfileServlet" method="post">
                    <input type="hidden" name="action" value="updateProfileImage">
                    <div class="modal-body">
                        <div class="text-center mb-4">
                            <div class="profile-avatar mx-auto">
                                <img src="<%= adminProfile.has("profilePictureURL") && !adminProfile.get("profilePictureURL").getAsString().isEmpty() ? 
                                    adminProfile.get("profilePictureURL").getAsString() : "${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg" %>" 
                                     alt="Profile Preview" id="modalProfilePreview" class="img-fluid rounded-circle" style="width: 150px; height: 150px; object-fit: cover;">
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="profileImageUrl" class="form-label">Enter Profile Image URL</label>
                            <input type="url" class="form-control" id="profileImageUrl" name="profileImageUrl" 
                                   value="<%= adminProfile.has("profilePictureURL") ? adminProfile.get("profilePictureURL").getAsString() : "" %>"
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
    
    <!-- Two-Factor Authentication Modal -->
    <div class="modal fade" id="twoFactorModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-shield-alt me-2"></i> Two-Factor Authentication</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="text-center mb-4">
                        <img src="${pageContext.request.contextPath}/assets/images/admin/qr-placeholder.png" alt="QR Code" class="img-fluid" style="max-width: 200px;">
                        <p class="mt-3 mb-0 text-muted">Scan this QR code with your authenticator app</p>
                    </div>
                    
                    <div class="mb-4">
                        <label for="setupCode" class="form-label">Setup Code:</label>
                        <div class="input-group">
                            <input type="text" class="form-control font-monospace" id="setupCode" value="ABCD-EFGH-IJKL-MNOP" readonly>
                            <button class="btn btn-outline-secondary" type="button" id="copyCodeBtn" onclick="copySetupCode()">
                                <i class="fas fa-copy"></i>
                            </button>
                        </div>
                        <div class="form-text">If you can't scan the QR code, enter this setup code into your app.</div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="verificationCode" class="form-label">Verification Code</label>
                        <input type="text" class="form-control" id="verificationCode" placeholder="Enter the 6-digit code from your app">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary">Verify & Enable</button>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Common Dashboard JS -->
    <script src="${pageContext.request.contextPath}/assets/js/admin/dashboard.js"></script>
    
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
        
        // Function to copy 2FA setup code
        function copySetupCode() {
            var setupCodeInput = document.getElementById('setupCode');
            setupCodeInput.select();
            document.execCommand('copy');
            
            // Show tooltip or notification
            var copyBtn = document.getElementById('copyCodeBtn');
            var originalHTML = copyBtn.innerHTML;
            copyBtn.innerHTML = '<i class="fas fa-check"></i>';
            
            setTimeout(function() {
                copyBtn.innerHTML = originalHTML;
            }, 2000);
        }
        
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