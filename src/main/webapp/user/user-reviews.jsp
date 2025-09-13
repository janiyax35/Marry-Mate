<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    // Make sure UserId is set in the session
    String userId = "U1005";
    session.setAttribute("UserId", userId);
    
    // Updated timestamp and user information
    String currentDateTime = "2025-05-18 09:09:47"; // Updated timestamp
    String currentUser = "IT24102137"; // Updated username
    
    // Check if user is logged in
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    // Redirect if not user - Uncomment when backend is ready
    if (username == null || !"user".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Sample user info - will be replaced with actual data from backend
    String userName = "Jennifer Smith";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Reviews | User Dashboard</title>
    
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user/reviewpart2.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/user/reviews.css">
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
                    <li  class="active">
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
                    <h4><%= userName %></h4>
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
                            </ul>
                            <div class="notification-footer">
                                <a href="${pageContext.request.contextPath}/user/notifications.jsp">View All Notifications</a>
                            </div>
                        </div>
                    </div>
                    
                    <div class="user-profile">
                        <button class="profile-btn">
                            <img src="<c:out value='${sessionScope.user.profilePictureURL}' default='${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg'/>" alt="User" class="avatar-sm">
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

            <!-- Reviews Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>My Reviews</h1>
                        <p class="subtitle">Manage and submit reviews for services you've used</p>
                    </div>
                    <div class="page-actions">
                        <div class="btn-group me-2">
                            <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="filterOptions" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-filter me-2"></i>All Reviews
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="filterOptions">
                                <li><a class="dropdown-item filter-option active" href="#" data-filter="all">All Reviews</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="published">Published</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="pending">Pending</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="draft">Draft</a></li>
                            </ul>
                        </div>
                        <div class="btn-group me-2">
                            <button class="btn btn-outline-secondary" id="listViewBtn">
                                <i class="fas fa-list"></i>
                            </button>
                            <button class="btn btn-outline-secondary" id="gridViewBtn">
                                <i class="fas fa-th-large"></i>
                            </button>
                        </div>
                        <!-- Added refresh button -->
                        <button class="btn btn-outline-secondary me-2" id="refreshReviewsBtn" title="Refresh Data">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                        <!-- Changed to export dropdown -->
                        <div class="btn-group">
                            <button class="btn btn-primary dropdown-toggle" type="button" id="exportDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-download me-2"></i>Export
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="exportDropdown">
                                <li><a class="dropdown-item" href="#" id="exportCSVBtn"><i class="fas fa-file-csv me-2"></i>Export as CSV</a></li>
                                <li><a class="dropdown-item" href="#" id="exportPDFBtn"><i class="fas fa-file-pdf me-2"></i>Export as PDF</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
                
                <!-- Reviews Stats -->
                <div class="row mb-4">
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card review-stat-card h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="stat-icon bg-primary">
                                        <i class="fas fa-comment-dots"></i>
                                    </div>
                                    <div>
                                        <h6 class="stat-title">Total Reviews</h6>
                                        <h3 class="stat-value" id="totalReviews">0</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card review-stat-card h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="stat-icon bg-warning">
                                        <i class="fas fa-star-half-alt"></i>
                                    </div>
                                    <div>
                                        <h6 class="stat-title">Pending</h6>
                                        <h3 class="stat-value" id="pendingReviews">0</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card review-stat-card h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="stat-icon bg-success">
                                        <i class="fas fa-star"></i>
                                    </div>
                                    <div>
                                        <h6 class="stat-title">Average Rating</h6>
                                        <h3 class="stat-value" id="averageRating">0.0</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6 mb-4">
                        <div class="card review-stat-card h-100">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="stat-icon bg-info">
                                        <i class="fas fa-thumbs-up"></i>
                                    </div>
                                    <div>
                                        <h6 class="stat-title">Helpful Count</h6>
                                        <h3 class="stat-value" id="totalHelpful">0</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- List View -->
                <div class="card mb-4" id="reviewListView">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">My Reviews</h5>
                        <div class="search-container">
                            <input type="text" id="reviewSearch" class="form-control form-control-sm" placeholder="Search reviews...">
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-hover" id="reviewsTable">
                                <thead>
                                    <tr>
                                        <th>Review ID</th>
                                        <th>Vendor</th>
                                        <th>Service</th>
                                        <th>Date</th>
                                        <th>Rating</th>
                                        <th>Status</th>
                                        <th>Helpful</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="reviewsTableBody">
                                    <!-- Data will be loaded dynamically via AJAX -->
                                    <tr class="review-loading">
                                        <td colspan="8" class="text-center py-5">
                                            <div class="spinner-border text-primary" role="status">
                                                <span class="visually-hidden">Loading...</span>
                                            </div>
                                            <p class="mt-2">Loading reviews...</p>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                
                <!-- Grid View -->
                <div class="card mb-4" id="reviewGridView" style="display: none;">
                    <div class="card-header">
                        <h5 class="mb-0">Reviews Gallery</h5>
                    </div>
                    <div class="card-body">
                        <div id="reviewsGrid" class="row g-4">
                            <!-- Review cards will be added dynamically via JS -->
                        </div>
                    </div>
                </div>
                
                <!-- No Reviews Message -->
                <div class="card mb-4" id="noReviewsMessage" style="display: none;">
                    <div class="card-body text-center py-5">
                        <div class="empty-state">
                            <i class="fas fa-star fa-4x text-muted mb-4"></i>
                            <h3>No Reviews Found</h3>
                            <p class="text-muted mb-4">You haven't submitted any reviews yet. Share your experiences with vendors you've worked with.</p>
                            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createReviewModal">
                                <i class="fas fa-plus me-2"></i>
                                Write a Review
                            </button>
                        </div>
                    </div>
                </div>
                
                <!-- Pending Reviews Section -->
                <div class="card mb-4" id="pendingReviewsSection">
                    <div class="card-header">
                        <h5 class="mb-0">Services to Review</h5>
                    </div>
                    <div class="card-body">
                        <div class="alert alert-info">
                            <i class="fas fa-info-circle me-2"></i>
                            You have services that are waiting for your review. Share your experience to help other couples!
                        </div>
                        
                        <div class="row g-4" id="pendingReviewsList">
                            <!-- Pending review items will be added dynamically via JS -->
                        </div>
                    </div>
                </div>
                
                <!-- Footer -->
                <footer class="user-footer">
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

    <!-- Review Details Modal -->
    <div class="modal fade" id="reviewDetailsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Review Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="reviewDetailsLoader" class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-2">Loading review details...</p>
                    </div>
                    
                    <div id="reviewDetailsContent" style="display: none;">
                        <!-- Review Info Section -->
                        <div class="review-info-section mb-4">
                            <div class="row">
                                <div class="col-md-6">
                                    <h6 class="text-uppercase text-muted mb-2">Review Information</h6>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Review ID:</span>
                                        <span id="detailReviewId">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Status:</span>
                                        <span id="detailStatus" class="badge rounded-pill"></span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Submitted On:</span>
                                        <span id="detailReviewDate">--</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <h6 class="text-uppercase text-muted mb-2">Service Details</h6>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Vendor:</span>
                                        <span id="detailVendorName">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Service:</span>
                                        <span id="detailServiceName">--</span>
                                    </div>
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Booking ID:</span>
                                        <span id="detailBookingId">--</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Rating Section -->
                        <div class="rating-section mb-4">
                            <h6 class="text-uppercase text-muted mb-2">Rating</h6>
                            <div class="overall-rating mb-3">
                                <span class="fw-bold d-block">Overall:</span>
                                <div id="detailOverallRating"></div>
                            </div>
                            <div class="detailed-ratings">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="mb-2">
                                            <span class="rating-label">Quality:</span>
                                            <div id="detailQualityRating" class="d-inline-block"></div>
                                            <span id="detailQualityValue" class="rating-value">--</span>
                                        </div>
                                        <div class="mb-2">
                                            <span class="rating-label">Value:</span>
                                            <div id="detailValueRating" class="d-inline-block"></div>
                                            <span id="detailValueValue" class="rating-value">--</span>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="mb-2">
                                            <span class="rating-label">Responsiveness:</span>
                                            <div id="detailResponseRating" class="d-inline-block"></div>
                                            <span id="detailResponseValue" class="rating-value">--</span>
                                        </div>
                                        <div class="mb-2">
                                            <span class="rating-label">Professionalism:</span>
                                            <div id="detailProfessionalismRating" class="d-inline-block"></div>
                                            <span id="detailProfessionalismValue" class="rating-value">--</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Review Content Section -->
                        <div class="review-content-section mb-4">
                            <h6 class="text-uppercase text-muted mb-2">Review Comment</h6>
                            <div class="p-3 bg-light rounded">
                                <p id="detailComment" class="mb-0">--</p>
                            </div>
                        </div>
                        
                        <!-- Photos Section -->
                        <div class="photos-section mb-4" id="detailPhotosSection">
                            <h6 class="text-uppercase text-muted mb-2">Photos</h6>
                            <div class="review-photos" id="detailPhotos">
                                <!-- Photos will be added dynamically via JS -->
                            </div>
                        </div>
                        
                        <!-- Vendor Response Section -->
                        <div class="vendor-response-section mb-4" id="vendorResponseSection">
                            <h6 class="text-uppercase text-muted mb-2">Vendor Response</h6>
                            <div class="p-3 bg-light rounded">
                                <p id="detailVendorResponse" class="mb-0">--</p>
                                <div class="text-end mt-2">
                                    <small id="detailResponseDate" class="text-muted">--</small>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Metrics Section -->
                        <div class="metrics-section mb-4">
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Helpful Votes:</span>
                                        <span id="detailHelpfulCount">--</span>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <span class="fw-bold d-block">Last Updated:</span>
                                        <span id="detailLastUpdated">--</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="editReviewBtn">
                        <i class="fas fa-edit me-2"></i>Edit Review
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Create/Edit Review Modal -->
    <div class="modal fade" id="createReviewModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="reviewModalTitle">Write a Review</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="reviewForm">
                        <input type="hidden" id="editReviewId" name="reviewId">
                        <input type="hidden" id="serviceId" name="serviceId">
                        <input type="hidden" id="vendorId" name="vendorId">
                        <input type="hidden" id="bookingId" name="bookingId">
                        
                        <div class="mb-4">
                            <label class="form-label">Service Information</label>
                            <div class="p-3 bg-light rounded mb-3">
                                <div class="d-flex align-items-center">
                                    <div class="flex-shrink-0">
                                        <img src="" id="vendorImage" class="vendor-preview" alt="Vendor">
                                    </div>
                                    <div class="flex-grow-1 ms-3">
                                        <h5 id="reviewVendorName">--</h5>
                                        <p id="reviewServiceName" class="mb-0 text-muted">--</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="form-label">Overall Rating</label>
                            <div class="rating-input mb-2">
                                <i class="far fa-star rating-star" data-value="1"></i>
                                <i class="far fa-star rating-star" data-value="2"></i>
                                <i class="far fa-star rating-star" data-value="3"></i>
                                <i class="far fa-star rating-star" data-value="4"></i>
                                <i class="far fa-star rating-star" data-value="5"></i>
                                <input type="hidden" id="overallRating" name="rating" value="0">
                            </div>
                            <div class="rating-text" id="ratingText">Click to rate</div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="form-label">Detailed Ratings</label>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <label class="form-label mb-0">Quality</label>
                                            <span id="qualityValue">0</span>
                                        </div>
                                        <input type="range" class="form-range" min="1" max="5" step="0.1" id="qualityRating" name="qualityRating">
                                    </div>
                                    <div class="mb-3">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <label class="form-label mb-0">Value</label>
                                            <span id="valueValue">0</span>
                                        </div>
                                        <input type="range" class="form-range" min="1" max="5" step="0.1" id="valueRating" name="valueRating">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="mb-3">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <label class="form-label mb-0">Responsiveness</label>
                                            <span id="responsivenessValue">0</span>
                                        </div>
                                        <input type="range" class="form-range" min="1" max="5" step="0.1" id="responsivenessRating" name="responsivenessRating">
                                    </div>
                                    <div class="mb-3">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <label class="form-label mb-0">Professionalism</label>
                                            <span id="professionalismValue">0</span>
                                        </div>
                                        <input type="range" class="form-range" min="1" max="5" step="0.1" id="professionalismRating" name="professionalismRating">
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="mb-4">
                            <label for="reviewComment" class="form-label">Your Review</label>
                            <textarea class="form-control" id="reviewComment" name="comment" rows="5" placeholder="Share your experience with this vendor..."></textarea>
                            <div class="form-text">Min 50 characters. Be specific and help others make informed decisions.</div>
                        </div>
                        
                        <div class="mb-4">
                            <label class="form-label">Upload Photos</label>
                            <div class="photo-upload-container">
                                <div class="review-photo-previews" id="photoPreviewsContainer">
                                    <div class="photo-upload-placeholder">
                                        <input type="file" id="photoUpload" name="reviewPhotos" accept="image/*" multiple class="photo-upload-input">
                                        <i class="fas fa-camera"></i>
                                        <span>Add Photos</span>
                                    </div>
                                </div>
                            </div>
                            <div class="form-text">You can upload up to 5 photos. Max size: 5MB per photo.</div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" id="saveAsDraftBtn">Save as Draft</button>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="submitReviewBtn">Submit Review</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Delete Review Confirmation Modal -->
    <div class="modal fade" id="deleteReviewModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-sm">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Delete Review</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this review? This action cannot be undone.</p>
                    <input type="hidden" id="deleteReviewId">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete</button>
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
                    <form id="profileImageForm" action="${pageContext.request.contextPath}/UserProfileServlet" method="post" enctype="multipart/form-data">
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
    
    <!-- PDF Generation Library -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.28/jspdf.plugin.autotable.min.js"></script>
    
    <!-- Common Dashboard JS -->
    <script src="${pageContext.request.contextPath}/assets/js/user/reviewssecond.js"></script>
    
    <!-- Reviews Page JS -->
    <script src="${pageContext.request.contextPath}/assets/js/user/reviews.js"></script>
    
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