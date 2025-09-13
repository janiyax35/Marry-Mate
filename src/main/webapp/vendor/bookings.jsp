<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Make sure UserId is set in the session
    String vendorId = "V1007";
    session.setAttribute("UserId", vendorId);
    
    // Updated timestamp and user information
    String currentDateTime = "2025-05-13 12:53:17";
    String currentUser = "IT24102083";
    
    // Check if vendor is logged in
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    // Redirect if not vendor - Uncomment when backend is ready
    /*if (username == null || !"vendor".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }*/
    
    // Sample business info - will be replaced with actual data from backend
    String businessName = "Elegant Photography";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Bookings | Vendor Dashboard</title>
    
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
    
    <!-- FullCalendar CSS -->
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.min.css" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/vendor/dashboard.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/vendor/bookings.css">
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
                    <li class="active">
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

            <!-- Bookings Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>Manage Bookings</h1>
                        <p class="subtitle">View and manage all your client bookings</p>
                    </div>
                    <div class="page-actions">
                        <div class="btn-group me-2">
                            <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="filterOptions" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-filter me-2"></i>All Bookings
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="filterOptions">
                                <li><a class="dropdown-item filter-option active" href="#" data-filter="all">All Bookings</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="pending">Pending Approval</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="confirmed">Confirmed</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="cancelled">Cancelled</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="completed">Completed</a></li>
                            </ul>
                        </div>
                        <div class="btn-group me-2">
                            <button class="btn btn-outline-secondary" id="listViewBtn">
                                <i class="fas fa-list"></i>
                            </button>
                            <button class="btn btn-outline-secondary" id="calendarViewBtn">
                                <i class="fas fa-calendar-alt"></i>
                            </button>
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
                                        <h6 class="stat-title">Total Revenue</h6>
                                        <h3 class="stat-value" id="totalRevenue">$0</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- List View -->
                <div class="card mb-4" id="bookingListView">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Booking Requests</h5>
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
                                        <th>Client</th>
                                        <th>Service</th>
                                        <th>Date</th>
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
                                            <p class="mt-2">Loading bookings...</p>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- Calendar View -->
                <div class="card mb-4" id="bookingCalendarView" style="display: none;">
                    <div class="card-header">
                        <h5 class="mb-0">Booking Calendar</h5>
                    </div>
                    <div class="card-body">
                        <div id="bookingsCalendar"></div>
                    </div>
                </div>
                
                <!-- No Bookings Message -->
                <div class="card mb-4" id="noBookingsMessage" style="display: none;">
                    <div class="card-body text-center py-5">
                        <div class="empty-state">
                            <i class="fas fa-calendar-times fa-4x text-muted mb-4"></i>
                            <h3>No Bookings Found</h3>
                            <p class="text-muted mb-4">You don't have any bookings yet. When clients book your services, they'll appear here.</p>
                            <a href="${pageContext.request.contextPath}/vendor/services.jsp" class="btn btn-primary">
                                <i class="fas fa-list-alt me-2"></i>
                                Manage Your Services
                            </a>
                        </div>
                    </div>
                </div>
                
                <!-- Footer -->
                <footer class="vendor-footer">
                    <div>
                        <span>© 2025 Marry Mate Wedding Planning System.</span>
                    </div>
                    <div>
                        <span>Version 2.4.1 | Current User: <%= currentUser %> | Last Updated: <%= currentDateTime %></span>
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
                                        <span class="fw-bold d-block">Created On:</span>
                                        <span id="detailBookingDate">--</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="text-uppercase text-muted mb-2">Event Details</h6>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Event Date:</span>
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
                        
                        <!-- Client Info Section -->
                        <div class="client-info-section mb-4">
                            <h6 class="text-uppercase text-muted mb-2">Client Information</h6>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Client ID:</span>
                                        <span id="detailClientId">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Name:</span>
                                        <span id="detailClientName">--</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Email:</span>
                                        <span id="detailClientEmail">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Phone:</span>
                                        <span id="detailClientPhone">--</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Services Section (NEW) -->
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
                <div class="modal-footer" id="bookingActionFooter" style="display: none;">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-danger" id="rejectBookingBtn">Reject</button>
                    <button type="button" class="btn btn-success" id="approveBookingBtn">Approve</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Confirm Action Modal -->
    <div class="modal fade" id="confirmActionModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="confirmActionTitle">Confirm Action</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p id="confirmActionMessage">Are you sure you want to proceed with this action?</p>
                    <input type="hidden" id="actionBookingId">
                    <input type="hidden" id="actionServiceId">
                    <input type="hidden" id="actionType">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmActionBtn">Confirm</button>
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
    
    <!-- DataTables -->
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    
    <!-- FullCalendar -->
    <script src="https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.min.js"></script>
    
    <!-- Common Dashboard JS -->
    <script src="${pageContext.request.contextPath}/assets/js/vendor/dashboard.js"></script>
    
    <!-- Bookings Page JS -->
    <script src="${pageContext.request.contextPath}/assets/js/vendor/bookings.js"></script>
    
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