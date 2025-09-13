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
    
    // Updated current date and user
    String currentDateTime = "2025-05-11 21:05:49";
    String currentUser = "IT24102083";
    
    // Sample business info - will be replaced with actual data from backend
    String businessName = "Elegant Photography";
    String vendorId = "V1004";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Services | Vendor Dashboard</title>
    
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
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/vendor/dashboard.css">
    
    <style>
        .price-model-field {
            display: none;
        }
        
        .option-item {
            background-color: #f8f9fa;
            border-radius: 8px;
            margin-bottom: 12px;
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
                    <li  class="active">
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

            <!-- Services Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>Manage Services</h1>
                        <p class="subtitle">Create and manage the services you offer to clients</p>
                    </div>
                    <div class="page-actions">
                        <div class="btn-group me-2">
                            <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="sortOptions" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-sort me-2"></i>Sort By
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="sortOptions">
                                <li><a class="dropdown-item sort-option" href="#" data-sort="name-asc">Name (A-Z)</a></li>
                                <li><a class="dropdown-item sort-option" href="#" data-sort="name-desc">Name (Z-A)</a></li>
                                <li><a class="dropdown-item sort-option" href="#" data-sort="price-asc">Price (Low to High)</a></li>
                                <li><a class="dropdown-item sort-option" href="#" data-sort="price-desc">Price (High to Low)</a></li>
                                <li><a class="dropdown-item sort-option" href="#" data-sort="date-desc">Newest First</a></li>
                                <li><a class="dropdown-item sort-option" href="#" data-sort="date-asc">Oldest First</a></li>
                            </ul>
                        </div>
                        <div class="btn-group me-2">
                            <button class="btn btn-outline-secondary" id="cardViewBtn">
                                <i class="fas fa-th-large"></i>
                            </button>
                            <button class="btn btn-outline-secondary active" id="tableViewBtn">
                                <i class="fas fa-list"></i>
                            </button>
                        </div>
                        <button class="btn btn-primary" id="addNewServiceBtn" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                            <i class="fas fa-plus me-2"></i>
                            Add New Service
                        </button>
                    </div>
                </div>
                
                <!-- Services Table View (Default) -->
                <div class="card mb-4" id="tableView">
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover services-table" id="servicesTable">
                                <thead>
                                    <tr>
                                        <th>Image</th>
                                        <th>Service Name</th>
                                        <th>Category</th>
                                        <th>Description</th>
                                        <th>Price</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="servicesTableBody">
                                    <!-- Data will be loaded dynamically via AJAX -->
                                    <tr class="service-loading">
                                        <td colspan="7" class="text-center py-5">
                                            <div class="spinner-border text-primary" role="status">
                                                <span class="visually-hidden">Loading...</span>
                                            </div>
                                            <p class="mt-2">Loading services...</p>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- Services Card View (Alternative) -->
                <div class="row g-4" id="cardView" style="display: none;">
                    <!-- Data will be loaded dynamically via AJAX -->
                    <div class="col-12 text-center py-5 service-loading">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Loading services...</p>
                    </div>
                </div>
                
                <!-- No Services Message -->
                <div class="card mb-4" id="noServicesMessage" style="display: none;">
                    <div class="card-body text-center py-5">
                        <div class="empty-state">
                            <i class="fas fa-clipboard-list fa-4x text-muted mb-4"></i>
                            <h3>No Services Added Yet</h3>
                            <p class="text-muted mb-4">You haven't created any services yet. Add your first service to start receiving bookings.</p>
                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                                <i class="fas fa-plus me-2"></i>
                                Add Your First Service
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Footer -->
                <footer class="vendor-footer">
                    <div>
                        <span>© 2025 Marry Mate Wedding Planning System.</span>
                    </div>
                    <div>
                        <span>Version 2.4.1 | Current User: <%= currentUser %> | Last Login: <%= currentDateTime %></span>
                    </div>
                </footer>
            </div>
        </div>
    </div>

    <!-- Add/Edit Service Modal -->
    <div class="modal fade" id="addServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="serviceModalTitle">Add New Service</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="serviceForm" enctype="multipart/form-data">
                        <input type="hidden" id="serviceId" name="serviceId">
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <label for="serviceName" class="form-label">Service Name <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="serviceName" name="serviceName" required>
                            </div>
                            <div class="col-md-6">
                                <label for="serviceCategory" class="form-label">Category <span class="text-danger">*</span></label>
                                <select class="form-select" id="serviceCategory" name="serviceCategory" required>
                                    <option value="">Select a category</option>
                                    <option value="photography">Photography</option>
                                    <option value="videography">Videography</option>
                                    <option value="venue">Venue</option>
                                    <option value="catering">Catering</option>
                                    <option value="music">Music</option>
                                    <option value="decoration">Decoration</option>
                                    <option value="attire">Attire</option>
                                    <option value="beauty">Beauty</option>
                                    <option value="planning">Planning</option>
                                    <option value="transportation">Transportation</option>
                                    <option value="cake">Cake</option>
                                    <option value="invitation">Invitation</option>
                                    <option value="other">Other</option>
                                </select>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="serviceDescription" class="form-label">Description <span class="text-danger">*</span></label>
                            <textarea class="form-control" id="serviceDescription" name="serviceDescription" rows="4" required></textarea>
                            <div class="form-text">Provide detailed information about what's included in this service.</div>
                        </div>
                        
                        <!-- Updated Pricing Section with Conditional Fields -->
                        <div class="card mb-4">
                            <div class="card-header">
                                <h5 class="mb-0">Pricing Details</h5>
                            </div>
                            <div class="card-body">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label for="serviceBasePrice" class="form-label">Base Price ($) <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" id="serviceBasePrice" name="serviceBasePrice" min="0" step="0.01" required>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <label for="servicePriceModel" class="form-label">Price Model</label>
                                        <select class="form-select" id="servicePriceModel" name="servicePriceModel">
                                            <option value="fixed">Fixed Price</option>
                                            <option value="hourly">Hourly Rate</option>
                                            <option value="per_guest">Per Guest</option>
                                        </select>
                                    </div>
                                    
                                    <!-- Hourly Rate Field - Only shown in hourly model -->
                                    <div class="col-md-6 price-model-field hourly-rate-field">
                                        <label for="serviceHourlyRate" class="form-label">Hourly Rate ($)</label>
                                        <input type="number" class="form-control" id="serviceHourlyRate" name="serviceHourlyRate" min="0" step="0.01" value="0">
                                    </div>
                                    
                                    <!-- Per Guest Rate Field - Only shown in per_guest model -->
                                    <div class="col-md-6 price-model-field per-guest-rate-field">
                                        <label for="servicePerGuestRate" class="form-label">Per Guest Rate ($)</label>
                                        <input type="number" class="form-control" id="servicePerGuestRate" name="servicePerGuestRate" min="0" step="0.01" value="0">
                                    </div>
                                    
                                    <!-- Base Duration Field - Only shown in hourly model -->
                                    <div class="col-md-6 price-model-field hourly-rate-field">
                                        <label for="serviceDuration" class="form-label">Base Duration (hours)</label>
                                        <input type="number" class="form-control" id="serviceDuration" name="serviceDuration" min="0" step="0.5" value="0">
                                    </div>
                                    
                                    <!-- Base Guest Count Field - Only shown in per_guest model -->
                                    <div class="col-md-6 price-model-field per-guest-rate-field">
                                        <label for="serviceGuestCount" class="form-label">Base Guest Count</label>
                                        <input type="number" class="form-control" id="serviceGuestCount" name="serviceGuestCount" min="0" value="0">
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Enhanced Customization Options Section -->
                        <div class="card mb-4">
                            <div class="card-header d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">Customization Options</h5>
                                <button type="button" class="btn btn-sm btn-primary" id="addOptionBtn">
                                    <i class="fas fa-plus me-1"></i> Add Option
                                </button>
                            </div>
                            <div class="card-body">
                                <div id="customizationOptions">
                                    <!-- Options will be added here dynamically -->
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="serviceIconImage" class="form-label">Service Icon</label>
                                <input type="file" class="form-control" id="serviceIconImage" name="serviceIconImage" accept="image/*">
                                <div class="form-text">Small icon representing your service. Recommended size: 128x128px.</div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="serviceBackgroundImage" class="form-label">Background Image</label>
                                <input type="file" class="form-control" id="serviceBackgroundImage" name="serviceBackgroundImage" accept="image/*">
                                <div class="form-text">Large banner image. Recommended size: 1200x600px.</div>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-md-6">
                                <div id="iconPreviewContainer" class="image-preview text-center p-2" style="display: none;">
                                    <img id="iconPreview" src="" alt="Icon Preview" class="img-thumbnail" style="max-height: 100px;">
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div id="backgroundPreviewContainer" class="image-preview text-center p-2" style="display: none;">
                                    <img id="backgroundPreview" src="" alt="Background Preview" class="img-thumbnail" style="max-height: 100px;">
                                </div>
                            </div>
                        </div>
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="serviceStatus" class="form-label">Status</label>
                                <select class="form-select" id="serviceStatus" name="serviceStatus">
                                    <option value="active">Active</option>
                                    <option value="inactive">Inactive</option>
                                </select>
                                <div class="form-text">Inactive services won't be displayed to clients.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="serviceSeoKeywords" class="form-label">SEO Keywords</label>
                                <input type="text" class="form-control" id="serviceSeoKeywords" name="serviceSeoKeywords" placeholder="wedding, photography, professional">
                                <div class="form-text">Comma-separated keywords to help clients find your service.</div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="serviceFeatured" name="serviceFeatured">
                                <label class="form-check-label" for="serviceFeatured">
                                    Feature this service (displayed prominently)
                                </label>
                            </div>
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
    
    <!-- Confirm Delete Modal -->
    <div class="modal fade" id="deleteServiceModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Confirm Delete</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this service? This action cannot be undone.</p>
                    <input type="hidden" id="deleteServiceId">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete</button>
                </div>
            </div>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- DataTables -->
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    
    <!-- Common Dashboard JS -->
    <script src="${pageContext.request.contextPath}/assets/js/vendor/dashboard.js"></script>
    
    <script src="${pageContext.request.contextPath}/assets/js/vendor/services.js"></script>
    
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
        
        // Function to add a customization option with description and price
        function addCustomizationOption() {
            const optionsContainer = document.getElementById('customizationOptions');
            const optionHtml = `
                <div class="option-item card mb-3 p-3">
                    <div class="row g-2">
                        <div class="col-md-12 mb-2">
                            <label class="form-label">Option Name</label>
                            <input type="text" class="form-control" name="customizationOptionsName[]" placeholder="Enter option name">
                        </div>
                        <div class="col-md-12 mb-2">
                            <label class="form-label">Description</label>
                            <textarea class="form-control" name="customizationOptionsDesc[]" placeholder="Enter description" rows="2"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Price ($)</label>
                            <input type="number" class="form-control" name="customizationOptionsPrice[]" placeholder="0.00" step="0.01" min="0">
                        </div>
                        <div class="col-md-6 d-flex align-items-end justify-content-end">
                            <button type="button" class="btn btn-outline-danger remove-option">
                                <i class="fas fa-trash-alt me-1"></i> Remove
                            </button>
                        </div>
                    </div>
                </div>
            `;
            
            // Insert the HTML directly without using a temporary element
            optionsContainer.insertAdjacentHTML('beforeend', optionHtml);
        }
        
        // Initialize when document is ready
        document.addEventListener('DOMContentLoaded', function() {
            console.log("Document ready - initializing service form handlers");
            
            // Remove any existing event listeners from the Add Option button by cloning and replacing
            const addOptionBtn = document.getElementById('addOptionBtn');
            if (addOptionBtn) {
                const newAddOptionBtn = addOptionBtn.cloneNode(true);
                addOptionBtn.parentNode.replaceChild(newAddOptionBtn, addOptionBtn);
                
                // Add a new event listener to the fresh button
                newAddOptionBtn.addEventListener('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    console.log("Add option button clicked");
                    addCustomizationOption();
                });
            }
            
            // Add one empty option to start if none exist
            if (document.querySelectorAll('.option-item').length === 0) {
                console.log("Adding initial option");
                addCustomizationOption();
            }
            
            // Handle the remove option button clicks through event delegation
            document.querySelector('#customizationOptions').addEventListener('click', function(e) {
                if (e.target.closest('.remove-option')) {
                    e.preventDefault();
                    const optionItem = e.target.closest('.option-item');
                    // Only remove if there's more than one option
                    const optionCount = document.querySelectorAll('.option-item').length;
                    if (optionCount > 1) {
                        optionItem.remove();
                    } else {
                        // Clear inputs instead of removing
                        optionItem.querySelectorAll('input, textarea').forEach(input => {
                            input.value = '';
                        });
                    }
                }
            });
            
            // Handle price model changes
            const servicePriceModel = document.getElementById('servicePriceModel');
            if (servicePriceModel) {
                // Initial setup based on currently selected value
                updatePriceFields(servicePriceModel.value);
                
                // Add change listener
                servicePriceModel.addEventListener('change', function() {
                    updatePriceFields(this.value);
                });
            }
            
            // Function to update price fields visibility based on price model
            function updatePriceFields(priceModel) {
                console.log("Updating price fields for model:", priceModel);
                
                // Hide all price model specific fields first
                document.querySelectorAll('.price-model-field').forEach(el => {
                    el.style.display = 'none';
                });
                
                // Show relevant fields based on price model
                if (priceModel === 'hourly') {
                    document.querySelectorAll('.hourly-rate-field').forEach(el => {
                        el.style.display = 'block';
                    });
                } else if (priceModel === 'per_guest') {
                    document.querySelectorAll('.per-guest-rate-field').forEach(el => {
                        el.style.display = 'block';
                    });
                }
                // Fixed price model doesn't show additional fields
            }
            
            // Preview images on file selection
            document.getElementById('serviceIconImage').addEventListener('change', function() {
                previewServiceImage(this, 'iconPreview', 'iconPreviewContainer');
            });
            
            document.getElementById('serviceBackgroundImage').addEventListener('change', function() {
                previewServiceImage(this, 'backgroundPreview', 'backgroundPreviewContainer');
            });
            
            // Function to preview service image
            function previewServiceImage(input, previewId, containerId) {
                if (input.files && input.files[0]) {
                    const reader = new FileReader();
                    
                    reader.onload = function(e) {
                        document.getElementById(previewId).src = e.target.result;
                        document.getElementById(containerId).style.display = 'block';
                    };
                    
                    reader.readAsDataURL(input.files[0]);
                }
            }
        });
    </script>
</body>
</html>