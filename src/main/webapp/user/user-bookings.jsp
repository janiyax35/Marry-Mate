<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Make sure UserId is set in the session
    //String userId = (String) session.getAttribute("userId");
    String userId = "U1005"; // For testing purposes, replace with actual session attribute
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    String fullName = (String) session.getAttribute("fullName");
    
    // Redirect if not logged in as user
    if (userId == null || !"user".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Updated timestamp and information
    String currentDateTime = "2025-05-18 09:16:41"; // Updated timestamp
    String currentUser = "IT24102137"; // Updated username
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bookings | Marry Mate</title>
    
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user/bookings.css">
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
                    <li class="active">
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
                <button id="sidebar-toggle">
                    <i class="fas fa-bars"></i>
                </button>
                
                <div class="user-info">
                    <h4>My Bookings</h4>
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
                            <img src="<c:out value='${sessionScope.user.profilePictureURL}' default='${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg'/>" alt="User" class="profile-image">
                            <span class="user-name"><%= fullName %></span>
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

            <!-- Bookings Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>My Bookings</h1>
                        <p class="subtitle">View and manage all your wedding service bookings</p>
                    </div>
                    <div class="page-actions">
                        <button class="btn btn-outline-primary" id="refreshBookingsBtn">
                            <i class="fas fa-sync-alt me-2"></i>
                            Refresh
                        </button>
                        <div class="btn-group me-2">
                            <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="filterOptions" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-filter me-2"></i>All Bookings
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="filterOptions">
                                <li><a class="dropdown-item filter-option active" href="#" data-filter="all">All Bookings</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="pending">Pending</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="confirmed">Confirmed</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="cancelled">Cancelled</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="completed">Completed</a></li>
                            </ul>
                        </div>
                        <button class="btn btn-primary" id="exportBookingsBtn">
                            <i class="fas fa-download me-2"></i>
                            Export
                        </button>
                    </div>
                </div>
                
                <!-- Bookings Stats -->
                <div class="row mb-4">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card booking-stat-card h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="stat-icon bg-primary">
                                        <i class="fas fa-calendar-check"></i>
                                    </div>
                                    <div>
                                        <h6 class="stat-title">Total Bookings</h6>
                                        <h3 class="stat-value" id="totalBookings">0</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card booking-stat-card h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="stat-icon bg-warning">
                                        <i class="fas fa-hourglass-half"></i>
                                    </div>
                                    <div>
                                        <h6 class="stat-title">Pending</h6>
                                        <h3 class="stat-value" id="pendingBookings">0</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card booking-stat-card h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="stat-icon bg-success">
                                        <i class="fas fa-check-circle"></i>
                                    </div>
                                    <div>
                                        <h6 class="stat-title">Confirmed</h6>
                                        <h3 class="stat-value" id="confirmedBookings">0</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card booking-stat-card h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="stat-icon bg-info">
                                        <i class="fas fa-dollar-sign"></i>
                                    </div>
                                    <div>
                                        <h6 class="stat-title">Total Cost</h6>
                                        <h3 class="stat-value" id="totalCost">$0</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- List View -->
                <div class="card mb-4" id="bookingListView">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">My Service Bookings</h5>
                        <div class="search-container">
                            <input type="text" id="bookingSearch" class="form-control form-control-sm" placeholder="Search bookings...">
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover" id="bookingsTable">
                                <thead>
                                    <tr>
                                        <th>Booking ID</th>
                                        <th>Service</th>
                                        <th>Vendor</th>
                                        <th>Event Date</th>
                                        <th>Status</th>
                                        <th>Payment</th>
                                        <th>Amount</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="bookingsTableBody">
                                    <!-- Data will be loaded dynamically via AJAX -->
                                    <tr class="booking-loading">
                                        <td colspan="8" class="text-center py-5">
                                            <div class="spinner-border text-primary" role="status">
                                                <span class="visually-hidden">Loading...</span>
                                            </div>
                                            <p class="mt-2">Loading your bookings...</p>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- No Bookings Message -->
                <div class="card mb-4" id="noBookingsMessage" style="display: none;">
                    <div class="card-body text-center py-5">
                        <div class="empty-state">
                            <i class="fas fa-calendar-times fa-4x text-muted mb-4"></i>
                            <h3>No Bookings Found</h3>
                            <p class="text-muted mb-4">You haven't made any bookings yet. Start planning your wedding by booking services!</p>
                            <a href="${pageContext.request.contextPath}/vendors.jsp" class="btn btn-primary">
                                <i class="fas fa-search me-2"></i>
                                Find Services
                            </a>
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

    <!-- Booking Details Modal -->
    <div class="modal fade" id="bookingDetailsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Booking Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="bookingDetailsLoader" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Loading booking details...</p>
                    </div>
                    
                    <div id="bookingDetailsContent" style="display: none;">
                        <!-- Booking Info Section -->
                        <div class="booking-info-section mb-4">
                            <div class="row">
                                <div class="col-md-6">
                                    <h6 class="text-uppercase text-muted mb-2">Booking Information</h6>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Booking ID:</span>
                                        <span id="detailBookingId">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Status:</span>
                                        <span id="detailStatus" class="badge rounded-pill"></span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Payment Status:</span>
                                        <span id="detailPayment" class="badge rounded-pill"></span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Booked On:</span>
                                        <span id="detailBookingDate">--</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="text-uppercase text-muted mb-2">Event Details</h6>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Wedding Date:</span>
                                        <span id="detailEventDate">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Time:</span>
                                        <span id="detailEventTime">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Guests:</span>
                                        <span id="detailGuestCount">--</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Services Section -->
                        <div class="services-section mb-4" id="detailServicesSection">
                            <h6 class="text-uppercase text-muted mb-2">Services Booked</h6>
                            <div class="table-responsive">
                                <table class="table table-borderless table-hover">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Service</th>
                                            <th>Vendor</th>
                                            <th>Price</th>
                                            <th>Status</th>
                                            <th>Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="servicesList">
                                        <!-- Service items will be added dynamically via JS -->
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        
                        <!-- Location Section -->
                        <div class="location-info-section mb-4">
                            <h6 class="text-uppercase text-muted mb-2">Event Location</h6>
                            <div class="mb-3">
                                <span id="detailEventLocation">--</span>
                            </div>
                        </div>
                        
                        <!-- Financial Section -->
                        <div class="financial-info-section mb-4">
                            <h6 class="text-uppercase text-muted mb-2">Financial Details</h6>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Total Amount:</span>
                                        <span id="detailTotalPrice" class="fs-5 fw-bold text-primary">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Payment Status:</span>
                                        <span id="detailPaymentStatus">--</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Deposit Paid:</span>
                                        <span id="detailDepositPaid">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Contract:</span>
                                        <span id="detailContractSigned">--</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Special Requirements Section -->
                        <div class="requirements-section mb-4">
                            <h6 class="text-uppercase text-muted mb-2">Special Requirements</h6>
                            <div class="p-3 bg-light rounded">
                                <p id="detailSpecialRequirements" class="mb-0">--</p>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="exportSingleBookingBtn">Export</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Confirm Cancel Modal -->
    <div class="modal fade" id="confirmCancelModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Confirm Cancellation</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p id="confirmCancelMessage">Are you sure you want to cancel this booking? This action cannot be undone.</p>
                    <input type="hidden" id="cancelBookingId">
                    <input type="hidden" id="cancelServiceId">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">No, Keep It</button>
                    <button type="button" class="btn btn-danger" id="confirmCancelBtn">Yes, Cancel</button>
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
                    <form id="profileImageForm" action="${pageContext.request.contextPath}/user/profileservlet" method="post" enctype="multipart/form-data">
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
    
    <!-- Service Options Modal -->
    <div class="modal fade" id="serviceOptionsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Service Options Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="serviceOptionsLoader" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Loading service options...</p>
                    </div>
                    
                    <div id="serviceOptionsContent" style="display: none;">
                        <!-- Service Details Header -->
                        <div class="d-flex justify-content-between align-items-start mb-4">
                            <div>
                                <h4 id="optionsServiceName" class="mb-1">Service Name</h4>
                                <div class="d-flex align-items-center">
                                    <div class="me-3">
                                        <small class="text-muted">Booking ID:</small>
                                        <span id="optionsBookingId" class="ms-1">--</span>
                                    </div>
                                    <div class="me-3">
                                        <small class="text-muted">Service ID:</small>
                                        <span id="optionsServiceId" class="ms-1">--</span>
                                    </div>
                                </div>
                            </div>
                            <span id="optionsStatus" class="badge rounded-pill">Status</span>
                        </div>
                        
                        <!-- Service Basic Info -->
                        <div class="card mb-4">
                            <div class="card-header bg-light">
                                <h6 class="mb-0">Service Base Information</h6>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-4 mb-3">
                                        <div class="fw-bold">Base Price</div>
                                        <div id="optionsBasePrice">$0.00</div>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <div class="fw-bold">Service Hours</div>
                                        <div id="optionsHours">0</div>
                                    </div>
                                    <div class="col-md-4 mb-3">
                                        <div class="fw-bold">Price Model</div>
                                        <div id="optionsPriceModel">Standard</div>
                                    </div>
                                </div>
                                
                                <!-- Additional Info Section -->
                                <div id="optionsAdditionalInfoSection" class="mt-3 pt-3 border-top">
                                    <h6 class="mb-2">Additional Charges</h6>
                                    <div id="optionsAdditionalInfo"></div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Selected Options Section -->
                        <div id="selectedOptionsSection" class="card mb-4">
                            <div class="card-header bg-light">
                                <h6 class="mb-0">Selected Options</h6>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th width="50">#</th>
                                                <th>Option Name</th>
                                                <th class="text-end" width="120">Price</th>
                                            </tr>
                                        </thead>
                                        <tbody id="selectedOptionsList">
                                            <!-- Options will be added here dynamically -->
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Special Notes Section -->
                        <div id="optionsSpecialNotesSection" class="card mb-4">
                            <div class="card-header bg-light">
                                <h6 class="mb-0">Special Notes</h6>
                            </div>
                            <div class="card-body">
                                <p id="optionsSpecialNotes" class="mb-0">No special notes.</p>
                            </div>
                        </div>
                        
                        <!-- Total Price Section -->
                        <div class="card bg-light">
                            <div class="card-body d-flex justify-content-between align-items-center">
                                <h5 class="mb-0">Total Service Price</h5>
                                <h4 id="optionsTotalPrice" class="mb-0 text-primary">$0.00</h4>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <a id="makeReviewBtn" href="#" class="btn btn-warning">
                        <i class="fas fa-star me-1"></i> Make Review
                    </a>
                    <button type="button" class="btn btn-danger cancel-booking-btn" id="optionsCancelServiceBtn" 
                           data-booking-id="" data-service-id="">
                        <i class="fas fa-times-circle me-1"></i> Cancel Service
                    </button>
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
    <script src="${pageContext.request.contextPath}/assets/js/user/dashboard.js"></script>
    
    <!-- Bookings Page JS -->
    <script src="${pageContext.request.contextPath}/assets/js/user/bookings.js"></script>
    
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
        
        // Update Make Review button href when service options modal is shown
        $(document).on('shown.bs.modal', '#serviceOptionsModal', function() {
            const bookingId = $('#optionsBookingId').text();
            const serviceId = $('#optionsServiceId').text();
            
            // Find the service in the data to get vendor ID
            const service = window.currentService;
            if (service) {
                const vendorId = service.vendorId;
                const serviceId = service.serviceId;
                
                // Update the Make Review button href
                $('#makeReviewBtn').attr('href', 
                    `${window.location.pathname.substring(0, window.location.pathname.indexOf("/user"))}/user/user-reviews.jsp?action=newReview&serviceId=${serviceId}&vendorId=${vendorId}&bookingId=${bookingId}`
                );
            }
        });
    </script>
</body>
</html>