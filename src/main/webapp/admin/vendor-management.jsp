<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%
    // Check if user is logged in and has admin role
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    // Redirect if not admin
	if (username != null && !"admin".equals(role) && !"super_admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/error/access-denied.jsp");
        return;
    }
    
    // For demonstration purposes - in a real app these would come from a database
    String currentDateTime = "2025-05-18 16:36:09";
    String currentUser = "IT24102137";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vendor Management | Marry Mate</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.11.5/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.2.2/css/buttons.bootstrap5.min.css">
    
    <!-- Date Range Picker -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.css">
    
    <!-- Dashboard CSS (shared styles) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/dashboard.css">
    
    <!-- Vendor Management CSS (specific styles) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/vendor-management.css">
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
                    <li class="active">
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
                    
	                <li>
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
                <p>Created by Janith Deshan</p>
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
                
                <div class="search-container">
                    <form action="#">
                        <input type="text" placeholder="Search..." class="form-control">
                        <button type="submit"><i class="fas fa-search"></i></button>
                    </form>
                </div>
                
                <div class="topbar-right">
                    <div class="notifications">
                        <button class="notification-btn">
                            <i class="fas fa-bell"></i>
                            <span class="badge bg-danger">4</span>
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
                                            <p><strong>New vendor registration</strong> - Royal Catering</p>
                                            <span class="notification-time">10 minutes ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-warning">
                                            <i class="fas fa-flag"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>Account suspended</strong> - Bloom Floral Designs</p>
                                            <span class="notification-time">1 hour ago</span>
                                        </div>
                                    </a>
                                </li>
                            </ul>
                            <div class="notification-footer">
                                <a href="${pageContext.request.contextPath}/admin/notifications.jsp">View All Notifications</a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="admin-profile">
                        <button class="profile-btn">
                            <img src="https://ui-avatars.com/api/?name=Admin&background=1a365d&color=fff" alt="Admin">
                            <span class="admin-name">Administrator</span>
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

            <!-- Vendor Management Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>Vendor Management</h1>
                        <p class="subtitle">View, create, edit and manage vendor accounts.</p>
                    </div>
                    <div class="page-actions">
                        <span class="current-date">
                            <i class="far fa-calendar-alt"></i>
                            <%= currentDateTime %>
                        </span>
                        <button class="btn btn-success" id="add-vendor-btn">
                            <i class="fas fa-store-alt me-2"></i>
                            Add New Vendor
                        </button>
                        <div class="dropdown ms-2">
                            <button class="btn btn-primary dropdown-toggle" type="button" id="exportDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-download me-2"></i>
                                Export
                            </button>
                            <ul class="dropdown-menu" aria-labelledby="exportDropdown">
                                <li><a class="dropdown-item export-option" data-format="excel" href="#"><i class="far fa-file-excel me-2"></i> Excel</a></li>
                                <li><a class="dropdown-item export-option" data-format="csv" href="#"><i class="fas fa-file-csv me-2"></i> CSV</a></li>
                                <li><a class="dropdown-item export-option" data-format="pdf" href="#"><i class="far fa-file-pdf me-2"></i> PDF</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
                
                <!-- Filters Section -->
                <div class="card mb-4">
                    <div class="card-header">
                        <h5>Filters</h5>
                        <div class="card-actions">
                            <button class="btn btn-sm btn-outline-secondary" id="reset-filters">
                                <i class="fas fa-undo me-1"></i> Reset
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <form id="vendor-filters-form" class="row g-3">
                            <div class="col-md-3">
                                <label for="status-filter" class="form-label">Account Status</label>
                                <select class="form-select" id="status-filter">
                                    <option value="">All Statuses</option>
                                    <option value="active">Active</option>
                                    <option value="inactive">Inactive</option>
                                    <option value="suspended">Suspended</option>
                                    <option value="pending">Pending</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="category-filter" class="form-label">Category</label>
                                <select class="form-select" id="category-filter">
                                    <option value="">All Categories</option>
                                    <option value="photography">Photography</option>
                                    <option value="videography">Videography</option>
                                    <option value="catering">Catering</option>
                                    <option value="venue">Venue</option>
                                    <option value="florist">Florist</option>
                                    <option value="music">Music</option>
                                    <option value="entertainment">Entertainment</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="date-range" class="form-label">Registration Date</label>
                                <input type="text" class="form-control" id="date-range" placeholder="All Time">
                            </div>
                            <div class="col-md-3">
                                <label for="search-vendors" class="form-label">Search Vendors</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" id="search-vendors" placeholder="Name, email, business...">
                                    <button class="btn btn-primary" type="button" id="search-btn">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Vendors Table -->
                <div class="card">
                    <div class="card-header">
                        <h5>Registered Vendors</h5>
                        <div class="card-actions">
                            <button class="btn btn-sm btn-outline-secondary" id="refresh-vendors">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="table-responsive">
                            <table class="table table-hover" id="vendors-table">
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Vendor</th>
                                        <th>Business Name</th>
                                        <th>Email</th>
                                        <th>Category</th>
                                        <th>Rating</th>
                                        <th>Status</th>
                                        <th>Since</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- Table data will be loaded via AJAX -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- Footer -->
                <footer class="admin-footer">
                    <div>
                        <span>© 2025 Marry Mate Wedding Planning System.</span>
                    </div>
                    <div>
                        <span>Version 2.4.1 | Current User: <%= currentUser %> | Last Login: 2025-05-18 10:42:15</span>
                    </div>
                </footer>
            </div>
        </div>
    </div>

    <!-- View Vendor Modal -->
    <div class="modal fade" id="viewVendorModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Vendor Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="vendor-profile-header">
                        <div class="vendor-avatar">
                            <img id="view-profile-picture" src="" alt="Vendor Profile Picture">
                        </div>
                        <div class="vendor-basic-info">
                            <h4 id="view-business-name"></h4>
                            <p id="view-vendor-id" class="text-muted"></p>
                            <span id="view-status-badge" class="badge rounded-pill"></span>
                            <div class="vendor-rating mt-2">
                                <div class="stars" id="view-rating-stars"></div>
                                <span id="view-rating-text"></span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row mt-4">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="fw-bold">Contact Name:</label>
                                <p id="view-contact-name"></p>
                            </div>
                            <div class="mb-3">
                                <label class="fw-bold">Username:</label>
                                <p id="view-username"></p>
                            </div>
                            <div class="mb-3">
                                <label class="fw-bold">Email:</label>
                                <p id="view-email"></p>
                            </div>
                            <div class="mb-3">
                                <label class="fw-bold">Phone Number:</label>
                                <p id="view-phone-number"></p>
                            </div>
                            <div class="mb-3">
                                <label class="fw-bold">Address:</label>
                                <p id="view-address"></p>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label class="fw-bold">Website:</label>
                                <p id="view-website"></p>
                            </div>
                            <div class="mb-3">
                                <label class="fw-bold">Categories:</label>
                                <p id="view-categories"></p>
                            </div>
                            <div class="mb-3">
                                <label class="fw-bold">Services Offered:</label>
                                <p id="view-services-offered"></p>
                            </div>
                            <div class="mb-3">
                                <label class="fw-bold">Price Range:</label>
                                <p id="view-price-range"></p>
                            </div>
                            <div class="mb-3">
                                <label class="fw-bold">Member Since:</label>
                                <p id="view-member-since"></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="vendor-description mt-3">
                        <h5>Business Description</h5>
                        <p id="view-description"></p>
                    </div>
                    
                    <div class="vendor-services mt-3">
                        <h5>Services</h5>
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Service ID</th>
                                        <th>Service Name</th>
                                        <th>Status</th>
                                    </tr>
                                </thead>
                                <tbody id="view-services-list">
                                    <!-- Services will be loaded here -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="edit-from-view-btn">Edit Vendor</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Vendor Modal -->
    <div class="modal fade" id="editVendorModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editVendorModalTitle">Edit Vendor</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="edit-vendor-form" class="needs-validation" novalidate>
                        <input type="hidden" id="edit-vendor-id" name="vendorId">
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="edit-username" class="form-label">Username</label>
                                <input type="text" class="form-control" id="edit-username" name="username" required>
                                <div class="invalid-feedback">Please provide a username.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="edit-email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="edit-email" name="email" required>
                                <div class="invalid-feedback">Please provide a valid email.</div>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="edit-business-name" class="form-label">Business Name</label>
                                <input type="text" class="form-control" id="edit-business-name" name="businessName" required>
                                <div class="invalid-feedback">Please provide the business name.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="edit-contact-name" class="form-label">Contact Name</label>
                                <input type="text" class="form-control" id="edit-contact-name" name="contactName" required>
                                <div class="invalid-feedback">Please provide a contact name.</div>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="edit-phone-number" class="form-label">Phone Number</label>
                                <input type="text" class="form-control" id="edit-phone-number" name="phone">
                            </div>
                            <div class="col-md-6">
                                <label for="edit-website" class="form-label">Website URL</label>
                                <input type="text" class="form-control" id="edit-website" name="websiteUrl">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="edit-address" class="form-label">Address</label>
                            <textarea class="form-control" id="edit-address" name="address" rows="2"></textarea>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="edit-categories" class="form-label">Categories</label>
                                <select class="form-select" id="edit-categories" name="categories" multiple>
                                    <option value="photography">Photography</option>
                                    <option value="videography">Videography</option>
                                    <option value="catering">Catering</option>
                                    <option value="food">Food</option>
                                    <option value="beverages">Beverages</option>
                                    <option value="venue">Venue</option>
                                    <option value="garden">Garden</option>
                                    <option value="florist">Florist</option>
                                    <option value="decor">Decor</option>
                                    <option value="music">Music</option>
                                    <option value="entertainment">Entertainment</option>
                                    <option value="dj">DJ</option>
                                </select>
                                <div class="form-text">Hold Ctrl (or Cmd) to select multiple categories.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="edit-price-range" class="form-label">Price Range</label>
                                <input type="text" class="form-control" id="edit-price-range" name="priceRange" placeholder="E.g., 500-2000">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="edit-services-offered" class="form-label">Services Offered</label>
                            <textarea class="form-control" id="edit-services-offered" name="servicesOffered" rows="2"></textarea>
                        </div>
                        
                        <div class="mb-3">
                            <label for="edit-description" class="form-label">Business Description</label>
                            <textarea class="form-control" id="edit-description" name="description" rows="3"></textarea>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="edit-profile-picture" class="form-label">Profile Picture URL</label>
                                <input type="text" class="form-control" id="edit-profile-picture" name="profilePictureUrl">
                            </div>
                            <div class="col-md-6">
                                <label for="edit-cover-photo" class="form-label">Cover Photo URL</label>
                                <input type="text" class="form-control" id="edit-cover-photo" name="coverPhotoUrl">
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="edit-rating" class="form-label">Rating (0-5)</label>
                                <input type="number" class="form-control" id="edit-rating" name="rating" min="0" max="5" step="0.1">
                            </div>
                            <div class="col-md-6">
                                <label for="edit-status" class="form-label">Account Status</label>
                                <select class="form-select" id="edit-status" name="status" required>
                                    <option value="active">Active</option>
                                    <option value="inactive">Inactive</option>
                                    <option value="suspended">Suspended</option>
                                    <option value="pending">Pending</option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="edit-featured">
                            <label class="form-check-label" for="edit-featured">Featured Vendor</label>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="reset-password">
                            <label class="form-check-label" for="reset-password">Reset Password</label>
                        </div>
                        
                        <div id="password-reset-fields" class="d-none">
                            <div class="row mb-3">
                                <div class="col-md-6">
                                    <label for="new-password" class="form-label">New Password</label>
                                    <input type="password" class="form-control" id="new-password" name="newPassword">
                                </div>
                                <div class="col-md-6">
                                    <label for="confirm-password" class="form-label">Confirm Password</label>
                                    <input type="password" class="form-control" id="confirm-password">
                                    <div class="invalid-feedback">Passwords do not match.</div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="save-vendor-btn">Save Changes</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Vendor Modal -->
    <div class="modal fade" id="addVendorModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add New Vendor</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="add-vendor-form" class="needs-validation" novalidate>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="add-username" class="form-label">Username</label>
                                <input type="text" class="form-control" id="add-username" name="username" required>
                                <div class="invalid-feedback">Please provide a username.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="add-email" class="form-label">Email</label>
                                <input type="email" class="form-control" id="add-email" name="email" required>
                                <div class="invalid-feedback">Please provide a valid email.</div>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="add-password" class="form-label">Password</label>
                                <input type="password" class="form-control" id="add-password" name="password" required>
                                <div class="invalid-feedback">Please provide a password.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="add-confirm-password" class="form-label">Confirm Password</label>
                                <input type="password" class="form-control" id="add-confirm-password" required>
                                <div class="invalid-feedback">Passwords do not match.</div>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="add-business-name" class="form-label">Business Name</label>
                                <input type="text" class="form-control" id="add-business-name" name="businessName" required>
                                <div class="invalid-feedback">Please provide the business name.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="add-contact-name" class="form-label">Contact Name</label>
                                <input type="text" class="form-control" id="add-contact-name" name="contactName" required>
                                <div class="invalid-feedback">Please provide a contact name.</div>
                            </div>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="add-phone-number" class="form-label">Phone Number</label>
                                <input type="text" class="form-control" id="add-phone-number" name="phone">
                            </div>
                            <div class="col-md-6">
                                <label for="add-website" class="form-label">Website URL</label>
                                <input type="text" class="form-control" id="add-website" name="websiteUrl">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="add-address" class="form-label">Address</label>
                            <textarea class="form-control" id="add-address" name="address" rows="2"></textarea>
                        </div>
                        
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="add-categories" class="form-label">Categories</label>
                                <select class="form-select" id="add-categories" name="categories" multiple>
                                    <option value="photography">Photography</option>
                                    <option value="videography">Videography</option>
                                    <option value="catering">Catering</option>
                                    <option value="food">Food</option>
                                    <option value="beverages">Beverages</option>
                                    <option value="venue">Venue</option>
                                    <option value="garden">Garden</option>
                                    <option value="florist">Florist</option>
                                    <option value="decor">Decor</option>
                                    <option value="music">Music</option>
                                    <option value="entertainment">Entertainment</option>
                                    <option value="dj">DJ</option>
                                </select>
                                <div class="form-text">Hold Ctrl (or Cmd) to select multiple categories.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="add-price-range" class="form-label">Price Range</label>
                                <input type="text" class="form-control" id="add-price-range" name="priceRange" placeholder="E.g., 500-2000">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label for="add-services-offered" class="form-label">Services Offered</label>
                            <textarea class="form-control" id="add-services-offered" name="servicesOffered" rows="2"></textarea>
                        </div>
                        
                        <div class="mb-3">
                            <label for="add-description" class="form-label">Business Description</label>
                            <textarea class="form-control" id="add-description" name="description" rows="3"></textarea>
                        </div>
                        
                        <div class="mb-3">
                            <label for="add-status" class="form-label">Account Status</label>
                            <select class="form-select" id="add-status" name="status" required>
                                <option value="active" selected>Active</option>
                                <option value="inactive">Inactive</option>
                                <option value="suspended">Suspended</option>
                                <option value="pending">Pending</option>
                            </select>
                        </div>
                        
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="add-featured">
                            <label class="form-check-label" for="add-featured">Featured Vendor</label>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-success" id="create-vendor-btn">Create Vendor</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Vendor Confirmation Modal -->
    <div class="modal fade" id="deleteVendorModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Confirm Delete</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="delete-vendor-id">
                    <p>Are you sure you want to delete this vendor?</p>
                    <p class="mb-2">Vendor: <strong id="delete-vendor-name"></strong></p>
                    <p class="text-danger"><i class="fas fa-exclamation-triangle me-2"></i>This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirm-delete-btn">Delete Vendor</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Overlay -->
    <div class="modal-overlay"></div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- DataTables -->
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.2/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.2.2/js/buttons.bootstrap5.min.js"></script>
    
    <!-- Date Range Picker -->
    <script src="https://cdn.jsdelivr.net/momentjs/latest/moment.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/daterangepicker/daterangepicker.min.js"></script>
    
    <!-- Sweet Alert -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <!-- Vendor Management JS -->
    <script src="${pageContext.request.contextPath}/assets/js/admin/vendor-management.js"></script>
    // Add this script block to your vendor-management.jsp file right before including this JavaScript file:
    
    <script>
$(document).ready(function() {
    // Initialize everything
    console.log("Document ready, testing vendor loading");
    
    // Test direct Ajax call with full path
    $.ajax({
        url: '${pageContext.request.contextPath}/VendorManagementServlet',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            console.log("Vendors loaded successfully:", data);
            alert("Vendors loaded: " + data.length + " records");
        },
        error: function(xhr, status, error) {
            console.error("Error loading vendors:", xhr.responseText);
            alert("Error loading vendors: " + error);
        }
    });
});
</script>

 <script>
    const contextPath = '${pageContext.request.contextPath}';
 </script>
</body>
</html>