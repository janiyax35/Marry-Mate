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
    String currentDateTime = "2025-05-06 07:42:35";
    String currentUser = "IT24102137";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Service Management | Marry Mate</title>
    
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
    <link rel="stylesheet" href="https://cdn.datatables.net/select/1.3.4/css/select.bootstrap5.min.css">
    
    <!-- AOS Animation Library -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/aos@2.3.4/dist/aos.css">
    
    <!-- ColorPicker -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@simonwep/pickr/dist/themes/classic.min.css">
    
    <!-- Dashboard CSS (shared styles) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/dashboard.css">
    
    <!-- Service Management CSS (specific styles) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/service-management.css">
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
                    
                    <li class="active">
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
                                            <p><strong>New vendor registration</strong> - Sunset Photography</p>
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
                                            <p><strong>Vendor approval requested</strong> - Gourmet Catering</p>
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

            <!-- Service Management Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>Service Management</h1>
                        <p class="subtitle">Create, manage, and organize wedding services offered to couples.</p>
                    </div>
                    <div class="page-actions">
                        <span class="current-date">
                            <i class="far fa-calendar-alt"></i>
                            <%= currentDateTime %>
                        </span>
                        <button class="btn btn-success" id="add-service-btn">
                            <i class="fas fa-plus me-2"></i>
                            Add New Service
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
                
                <!-- Filters & View Options -->
                <div class="card mb-4" data-aos="fade-up" data-aos-duration="800">
                    <div class="card-header">
                        <h5>Filters & Display Options</h5>
                        <div class="card-actions">
                            <button class="btn btn-sm btn-outline-secondary" id="reset-filters">
                                <i class="fas fa-undo me-1"></i> Reset
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <form id="service-filters-form" class="row g-3">
                            <div class="col-md-3">
                                <label for="category-filter" class="form-label">Category</label>
                                <select class="form-select" id="category-filter">
                                    <option value="">All Categories</option>
                                    <option value="photography">Photography</option>
                                    <option value="videography">Videography</option>
                                    <option value="catering">Catering</option>
                                    <option value="venues">Venues</option>
                                    <option value="decoration">Decoration</option>
                                    <option value="entertainment">Entertainment</option>
                                    <option value="planning">Planning</option>
                                    <option value="beauty">Beauty</option>
                                    <option value="transportation">Transportation</option>
                                    <option value="attire">Attire</option>
                                    <option value="jewelry">Jewelry</option>
                                    <option value="invitations">Invitations</option>
                                    <option value="gifts">Gifts</option>
                                    <option value="flowers">Flowers</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="status-filter" class="form-label">Status</label>
                                <select class="form-select" id="status-filter">
                                    <option value="">All Statuses</option>
                                    <option value="active">Active</option>
                                    <option value="inactive">Inactive</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="price-range" class="form-label">Price Range</label>
                                <select class="form-select" id="price-range">
                                    <option value="">All Prices</option>
                                    <option value="0-100">$0 - $100</option>
                                    <option value="101-500">$101 - $500</option>
                                    <option value="501-1000">$501 - $1,000</option>
                                    <option value="1001-5000">$1,001 - $5,000</option>
                                    <option value="5001+">$5,001+</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label for="search-services" class="form-label">Search Services</label>
                                <div class="input-group">
                                    <input type="text" class="form-control" id="search-services" placeholder="Search by name, keyword...">
                                    <button class="btn btn-primary" type="button" id="search-btn">
                                        <i class="fas fa-search"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="col-12">
                                <div class="view-options">
                                    <div class="view-label">View as:</div>
                                    <div class="btn-group" role="group">
                                        <input type="radio" class="btn-check" name="view-option" id="view-grid" checked>
                                        <label class="btn btn-outline-primary" for="view-grid">
                                            <i class="fas fa-th-large me-1"></i> Grid
                                        </label>
                                        
                                        <input type="radio" class="btn-check" name="view-option" id="view-list">
                                        <label class="btn btn-outline-primary" for="view-list">
                                            <i class="fas fa-list me-1"></i> List
                                        </label>
                                        
                                        <input type="radio" class="btn-check" name="view-option" id="view-compact">
                                        <label class="btn btn-outline-primary" for="view-compact">
                                            <i class="fas fa-th me-1"></i> Compact
                                        </label>
                                    </div>
                                    <div class="sort-options ms-auto">
                                        <label for="sort-by" class="me-2">Sort by:</label>
                                        <select class="form-select form-select-sm" id="sort-by">
                                            <option value="name-asc">Name (A-Z)</option>
                                            <option value="name-desc">Name (Z-A)</option>
                                            <option value="price-asc">Price (Low-High)</option>
                                            <option value="price-desc">Price (High-Low)</option>
                                            <option value="display-order">Display Order</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                </div>
                
                <!-- Bulk Actions -->
                <div class="card mb-4" id="bulk-actions-card" style="display: none;" data-aos="fade-up" data-aos-duration="800" data-aos-delay="100">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="fw-bold"><span id="selected-count">0</span> services selected</span>
                            </div>
                            <div class="bulk-action-buttons">
                                <button class="btn btn-sm btn-success bulk-action-btn" data-action="activate">
                                    <i class="fas fa-check-circle me-1"></i> Activate
                                </button>
                                <button class="btn btn-sm btn-secondary bulk-action-btn" data-action="deactivate">
                                    <i class="fas fa-times-circle me-1"></i> Deactivate
                                </button>
                                <button class="btn btn-sm btn-danger bulk-action-btn" data-action="delete">
                                    <i class="fas fa-trash-alt me-1"></i> Delete
                                </button>
                                <button class="btn btn-sm btn-info bulk-action-btn" data-action="export">
                                    <i class="fas fa-download me-1"></i> Export Selected
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Services Container -->
                <div class="card" data-aos="fade-up" data-aos-duration="800" data-aos-delay="200">
                    <div class="card-header">
                        <h5>Wedding Services</h5>
                        <div class="card-actions">
                            <button class="btn btn-sm btn-outline-secondary" id="refresh-services">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body services-container">
                        <!-- Grid View (default) -->
                        <div id="services-grid-view">
                            <div class="text-center p-5" id="services-loader">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <p class="mt-3">Loading services...</p>
                            </div>
                            
                            <div class="row" id="services-grid">
                                <!-- Services will be loaded here via AJAX -->
                            </div>
                            
                            <div id="no-services-message" class="text-center p-5" style="display: none;">
                                <div class="no-data-icon">
                                    <i class="fas fa-concierge-bell fa-4x text-muted mb-3"></i>
                                </div>
                                <h5>No Services Found</h5>
                                <p class="text-muted">No services match your search criteria or no services have been added yet.</p>
                                <button class="btn btn-primary" id="no-services-add-btn">
                                    <i class="fas fa-plus me-2"></i> Add Your First Service
                                </button>
                            </div>
                        </div>
                        
                        <!-- List View -->
                        <div id="services-list-view" style="display: none;">
                            <table class="table table-hover" id="services-table">
                                <thead>
                                    <tr>
                                        <th>
                                            <div class="form-check">
                                                <input class="form-check-input" type="checkbox" id="select-all-services">
                                            </div>
                                        </th>
                                        <th>ID</th>
                                        <th>Service</th>
                                        <th>Category</th>
                                        <th>Base Price</th>
                                        <th>Status</th>
                                        <th>Display Order</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!-- Services will be loaded here via AJAX -->
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Compact View -->
                        <div id="services-compact-view" style="display: none;">
                            <div class="services-category-groups">
                                <!-- Services organized by category will be loaded here via AJAX -->
                            </div>
                        </div>
                    </div>
                    <div class="card-footer">
                        <div class="d-flex justify-content-between align-items-center">
                            <div class="services-count">
                                <span id="active-services-count">0</span> active services, 
                                <span id="inactive-services-count">0</span> inactive services
                            </div>
                            <div class="services-pagination">
                                <!-- Pagination will be loaded here via AJAX if needed -->
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Category Management Section -->
                <div class="card mt-4" data-aos="fade-up" data-aos-duration="800" data-aos-delay="300">
                    <div class="card-header">
                        <h5>Service Categories</h5>
                        <div class="card-actions">
                            <button class="btn btn-sm btn-primary" id="manage-categories-btn">
                                <i class="fas fa-edit me-1"></i> Manage Categories
                            </button>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="categories-container">
                            <div class="row" id="categories-list">
                                <!-- Categories will be loaded here via AJAX -->
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
                        <span>Version 2.4.1 | Current User: <%= currentUser %> | Last Login: 2025-05-06 06:42:15</span>
                    </div>
                </footer>
            </div>
        </div>
    </div>

    <!-- Add/Edit Service Modal -->
    <div class="modal fade" id="serviceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="serviceModalTitle">Add New Service</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="service-form" class="needs-validation" novalidate>
                        <input type="hidden" id="service-id" name="serviceId">
                        
                        <ul class="nav nav-tabs" id="serviceTabs" role="tablist">
                            <li class="nav-item" role="presentation">
                                <button class="nav-link active" id="basic-tab" data-bs-toggle="tab" data-bs-target="#basic-info" type="button">
                                    Basic Info
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="visuals-tab" data-bs-toggle="tab" data-bs-target="#visuals" type="button">
                                    Visuals
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="options-tab" data-bs-toggle="tab" data-bs-target="#options" type="button">
                                    Customization Options
                                </button>
                            </li>
                            <li class="nav-item" role="presentation">
                                <button class="nav-link" id="display-tab" data-bs-toggle="tab" data-bs-target="#display" type="button">
                                    Display Settings
                                </button>
                            </li>
                        </ul>
                        
                        <div class="tab-content p-3 border border-top-0 rounded-bottom">
                            <!-- Basic Info Tab -->
                            <div class="tab-pane fade show active" id="basic-info" role="tabpanel" aria-labelledby="basic-tab">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="service-name" class="form-label">Service Name</label>
                                        <input type="text" class="form-control" id="service-name" name="serviceName" required>
                                        <div class="invalid-feedback">Please provide a service name.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="service-category" class="form-label">Category</label>
                                        <select class="form-select" id="service-category" name="category" required>
                                            <option value="">Select Category</option>
                                            <option value="photography">Photography</option>
                                            <option value="videography">Videography</option>
                                            <option value="catering">Catering</option>
                                            <option value="venues">Venues</option>
                                            <option value="decoration">Decoration</option>
                                            <option value="entertainment">Entertainment</option>
                                            <option value="planning">Planning</option>
                                            <option value="beauty">Beauty</option>
                                            <option value="transportation">Transportation</option>
                                            <option value="attire">Attire</option>
                                            <option value="jewelry">Jewelry</option>
                                            <option value="invitations">Invitations</option>
                                            <option value="gifts">Gifts</option>
                                            <option value="flowers">Flowers</option>
                                        </select>
                                        <div class="invalid-feedback">Please select a category.</div>
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="service-description" class="form-label">Description</label>
                                    <textarea class="form-control" id="service-description" name="description" rows="4" required></textarea>
                                    <div class="invalid-feedback">Please provide a description.</div>
                                    <div class="form-text">Describe the service in detail. This will be visible to customers.</div>
                                </div>
                                
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="service-base-price" class="form-label">Base Price ($)</label>
                                        <input type="number" class="form-control" id="service-base-price" name="basePrice" min="0" step="0.01" required>
                                        <div class="invalid-feedback">Please provide a valid base price.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label for="service-status" class="form-label">Status</label>
                                        <div class="form-control p-0 overflow-hidden">
                                            <div class="btn-group w-100" role="group">
                                                <input type="radio" class="btn-check" name="active" id="status-active" value="true" checked>
                                                <label class="btn" for="status-active">Active</label>
                                                
                                                <input type="radio" class="btn-check" name="active" id="status-inactive" value="false">
                                                <label class="btn" for="status-inactive">Inactive</label>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Visuals Tab -->
                            <div class="tab-pane fade" id="visuals" role="tabpanel" aria-labelledby="visuals-tab">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="service-icon-type" class="form-label">Service Icon</label>
                                            <div class="btn-group w-100 mb-3" role="group">
                                                <input type="radio" class="btn-check" name="icon-type" id="icon-url-option" autocomplete="off" checked>
                                                <label class="btn btn-outline-primary" for="icon-url-option">Icon URL</label>
                                                
                                                <input type="radio" class="btn-check" name="icon-type" id="icon-upload-option" autocomplete="off">
                                                <label class="btn btn-outline-primary" for="icon-upload-option">Upload Icon</label>
                                                
                                                <input type="radio" class="btn-check" name="icon-type" id="icon-fa-option" autocomplete="off">
                                                <label class="btn btn-outline-primary" for="icon-fa-option">Font Awesome</label>
                                            </div>
                                            
                                            <div id="icon-url-input">
                                                <input type="text" class="form-control" id="service-icon-path" name="iconPath" placeholder="Enter icon URL">
                                            </div>
                                            
                                            <div id="icon-upload-input" style="display:none;">
                                                <input type="file" class="form-control" id="service-icon-upload" accept="image/*">
                                            </div>
                                            
                                            <div id="icon-fa-input" style="display:none;">
                                                <div class="input-group">
                                                    <span class="input-group-text"><i class="fas fa-icons"></i></span>
                                                    <input type="text" class="form-control" id="service-icon-fa" placeholder="fa-camera">
                                                </div>
                                                <div class="form-text">Enter Font Awesome icon class name (e.g., fa-camera)</div>
                                            </div>
                                            
                                            <div class="mt-3 text-center">
                                                <div class="icon-preview-container mb-2">
                                                    <div id="icon-preview">
                                                        <i class="fas fa-image"></i>
                                                    </div>
                                                </div>
                                                <small class="text-muted">Icon Preview</small>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label for="service-bg-type" class="form-label">Background Image</label>
                                            <div class="btn-group w-100 mb-3" role="group">
                                                <input type="radio" class="btn-check" name="bg-type" id="bg-url-option" autocomplete="off" checked>
                                                <label class="btn btn-outline-primary" for="bg-url-option">Image URL</label>
                                                
                                                <input type="radio" class="btn-check" name="bg-type" id="bg-upload-option" autocomplete="off">
                                                <label class="btn btn-outline-primary" for="bg-upload-option">Upload Image</label>
                                            </div>
                                            
                                            <div id="bg-url-input">
                                                <input type="text" class="form-control" id="service-bg-path" name="backgroundImagePath" placeholder="Enter background image URL">
                                            </div>
                                            
                                            <div id="bg-upload-input" style="display:none;">
                                                <input type="file" class="form-control" id="service-bg-upload" accept="image/*">
                                            </div>
                                            
                                            <div class="mt-3">
                                                <div class="bg-preview-container mb-2">
                                                    <img id="bg-preview" src="/assets/images/placeholder-bg.jpg" alt="Background Preview">
                                                </div>
                                                <small class="text-muted">Background Preview</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-3">
                                            <label class="form-label">Theme Color</label>
                                            <div class="input-group">
                                                <span class="input-group-text color-picker-addon">
                                                    <i class="fas fa-palette"></i>
                                                </span>
                                                <input type="text" class="form-control" id="service-color" name="themeColor" placeholder="#1a365d">
                                            </div>
                                            <div id="color-picker-container"></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Customization Options Tab -->
                            <div class="tab-pane fade" id="options" role="tabpanel" aria-labelledby="options-tab">
                                <div class="mb-3">
                                    <label class="form-label">Customization Options</label>
                                    <p class="text-muted">Add options that customers can choose from when booking this service.</p>
                                    
                                    <div class="customization-options-container">
                                        <div id="customization-options-list">
                                            <!-- Options will be added here dynamically -->
                                        </div>
                                        
                                        <div class="input-group mt-3">
                                            <input type="text" class="form-control" id="new-option" placeholder="Enter new option">
                                            <button class="btn btn-primary" type="button" id="add-option-btn">
                                                <i class="fas fa-plus"></i> Add
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Display Settings Tab -->
                            <div class="tab-pane fade" id="display" role="tabpanel" aria-labelledby="display-tab">
                                <div class="row mb-3">
                                    <div class="col-md-6">
                                        <label for="service-display-order" class="form-label">Display Order</label>
                                        <input type="number" class="form-control" id="service-display-order" name="displayOrder" min="1" value="1">
                                        <div class="form-text">Lower numbers will appear first in listings.</div>
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label class="form-label d-block">Display Options</label>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="featured-service" name="featured">
                                        <label class="form-check-label" for="featured-service">Feature on Homepage</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="popular-service" name="popular">
                                        <label class="form-check-label" for="popular-service">Mark as Popular</label>
                                    </div>
                                    <div class="form-check form-check-inline">
                                        <input class="form-check-input" type="checkbox" id="new-service" name="new">
                                        <label class="form-check-label" for="new-service">Mark as New</label>
                                    </div>
                                </div>
                                
                                <div class="mb-3">
                                    <label for="service-seo-keywords" class="form-label">SEO Keywords</label>
                                    <textarea class="form-control" id="service-seo-keywords" name="seoKeywords" rows="2" placeholder="wedding, photography, professional"></textarea>
                                    <div class="form-text">Comma-separated keywords to help with search engine optimization.</div>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="save-service-btn">Save Service</button>
                </div>
            </div>
        </div>
    </div>

    <!-- View Service Modal -->
    <div class="modal fade" id="viewServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Service Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-0">
                    <div class="service-details-header">
                        <div class="service-bg-image" id="view-bg-image"></div>
                        <div class="service-details-overlay">
                            <div class="service-icon" id="view-service-icon"></div>
                            <h3 id="view-service-name"></h3>
                            <span class="badge rounded-pill" id="view-service-status"></span>
                        </div>
                    </div>
                    
                    <div class="service-details-body p-4">
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <h6 class="text-muted">Category</h6>
                                <p id="view-service-category"></p>
                            </div>
                            <div class="col-md-6">
                                <h6 class="text-muted">Base Price</h6>
                                <p id="view-service-price"></p>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <h6 class="text-muted">Description</h6>
                            <p id="view-service-description"></p>
                        </div>
                        
                        <div class="mb-4">
                            <h6 class="text-muted">Customization Options</h6>
                            <div id="view-customization-options"></div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <h6 class="text-muted">Display Order</h6>
                                <p id="view-display-order"></p>
                            </div>
                            <div class="col-md-6">
                                <h6 class="text-muted">Service ID</h6>
                                <p id="view-service-id"></p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="edit-service-btn">Edit Service</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Delete Service Confirmation Modal -->
    <div class="modal fade" id="deleteServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Confirm Delete</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="delete-service-id">
                    <p>Are you sure you want to delete this service?</p>
                    <p class="mb-2">Service: <strong id="delete-service-name"></strong></p>
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <span>This will also remove this service from all vendors that offer it.</span>
                    </div>
                    <p class="text-danger"><i class="fas fa-exclamation-triangle me-2"></i>This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirm-delete-btn">Delete Service</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Manage Categories Modal -->
    <div class="modal fade" id="manageCategoriesModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Manage Service Categories</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Current Categories</label>
                        <div class="categories-list" id="manage-categories-list">
                            <!-- Categories will be loaded here via AJAX -->
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label for="new-category" class="form-label">Add New Category</label>
                        <div class="input-group">
                            <input type="text" class="form-control" id="new-category-name" placeholder="Category name">
                            <button class="btn btn-primary" type="button" id="add-category-btn">
                                <i class="fas fa-plus"></i> Add
                            </button>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="save-categories-btn">Save Changes</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bulk Delete Confirmation Modal -->
    <div class="modal fade" id="bulkDeleteModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Confirm Bulk Delete</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete <span id="bulk-delete-count">0</span> selected services?</p>
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        <span>This will also remove these services from all vendors that offer them.</span>
                    </div>
                    <p class="text-danger"><i class="fas fa-exclamation-triangle me-2"></i>This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirm-bulk-delete-btn">Delete Services</button>
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
    <script src="https://cdn.datatables.net/select/1.3.4/js/dataTables.select.min.js"></script>
    
    <!-- SortableJS - for drag and drop sorting -->
    <script src="https://cdn.jsdelivr.net/npm/sortablejs@1.15.0/Sortable.min.js"></script>
    
    <!-- Color Picker -->
    <script src="https://cdn.jsdelivr.net/npm/@simonwep/pickr/dist/pickr.min.js"></script>
    
    <!-- Sweet Alert -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    
    <!-- AOS Animation -->
    <script src="https://cdn.jsdelivr.net/npm/aos@2.3.4/dist/aos.js"></script>
    
    <!-- Service Management JS -->
    <script src="${pageContext.request.contextPath}/assets/js/admin/service-management.js"></script>
</body>
</html>