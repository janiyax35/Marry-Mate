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
    String currentDateTime = "2025-05-07 09:12:26";
    String currentUser = "IT24102137";
    
    // Sample business info - will be replaced with actual data from backend
    String businessName = "Elegant Photography";
    String vendorId = "V1004";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reviews & Ratings | Vendor Dashboard</title>
    
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/vendor/reviews.css">
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
                    <li  class="active">
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

            <!-- Reviews Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>Reviews & Ratings</h1>
                        <p class="subtitle">Monitor and respond to customer feedback about your services</p>
                    </div>
                    <div class="page-actions">
                        <div class="btn-group me-2">
                            <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="sortOptions" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-sort me-2"></i>Sort By
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="sortOptions">
                                <li><a class="dropdown-item sort-option active" href="#" data-sort="date-desc">Newest First</a></li>
                                <li><a class="dropdown-item sort-option" href="#" data-sort="date-asc">Oldest First</a></li>
                                <li><a class="dropdown-item sort-option" href="#" data-sort="rating-desc">Highest Rating</a></li>
                                <li><a class="dropdown-item sort-option" href="#" data-sort="rating-asc">Lowest Rating</a></li>
                            </ul>
                        </div>
                        <div class="btn-group">
                            <button class="btn btn-outline-secondary dropdown-toggle" type="button" id="filterOptions" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-filter me-2"></i>Filter
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="filterOptions">
                                <li><a class="dropdown-item filter-option active" href="#" data-filter="all">All Ratings</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="5">5 Stars</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="4">4 Stars</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="3">3 Stars</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="2">2 Stars</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="1">1 Star</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="responded">Responded</a></li>
                                <li><a class="dropdown-item filter-option" href="#" data-filter="not-responded">Not Responded</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
                
                <!-- Reviews Overview -->
                <div class="row">
                    <div class="col-lg-4 mb-4">
                        <div class="card">
                            <div class="card-body">
                                <div class="reviews-summary text-center">
                                    <h2 id="averageRating">0.0</h2>
                                    <div class="rating-stars mb-3" id="averageRatingStars">
                                        <i class="far fa-star"></i>
                                        <i class="far fa-star"></i>
                                        <i class="far fa-star"></i>
                                        <i class="far fa-star"></i>
                                        <i class="far fa-star"></i>
                                    </div>
                                    <p class="text-muted mb-4"><span id="totalReviews">0</span> reviews</p>
                                    
                                    <div class="rating-bars">
                                        <div class="rating-bar-item">
                                            <div class="rating-label">
                                                <span>5 Stars</span>
                                            </div>
                                            <div class="rating-bar">
                                                <div class="progress">
                                                    <div class="progress-bar bg-success" id="fiveStarBar" role="progressbar" style="width: 0%" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                                                </div>
                                            </div>
                                            <div class="rating-count">
                                                <span id="fiveStarCount">0</span>
                                            </div>
                                        </div>
                                        <div class="rating-bar-item">
                                            <div class="rating-label">
                                                <span>4 Stars</span>
                                            </div>
                                            <div class="rating-bar">
                                                <div class="progress">
                                                    <div class="progress-bar bg-success-light" id="fourStarBar" role="progressbar" style="width: 0%" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                                                </div>
                                            </div>
                                            <div class="rating-count">
                                                <span id="fourStarCount">0</span>
                                            </div>
                                        </div>
                                        <div class="rating-bar-item">
                                            <div class="rating-label">
                                                <span>3 Stars</span>
                                            </div>
                                            <div class="rating-bar">
                                                <div class="progress">
                                                    <div class="progress-bar bg-warning" id="threeStarBar" role="progressbar" style="width: 0%" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                                                </div>
                                            </div>
                                            <div class="rating-count">
                                                <span id="threeStarCount">0</span>
                                            </div>
                                        </div>
                                        <div class="rating-bar-item">
                                            <div class="rating-label">
                                                <span>2 Stars</span>
                                            </div>
                                            <div class="rating-bar">
                                                <div class="progress">
                                                    <div class="progress-bar bg-warning-light" id="twoStarBar" role="progressbar" style="width: 0%" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                                                </div>
                                            </div>
                                            <div class="rating-count">
                                                <span id="twoStarCount">0</span>
                                            </div>
                                        </div>
                                        <div class="rating-bar-item">
                                            <div class="rating-label">
                                                <span>1 Star</span>
                                            </div>
                                            <div class="rating-bar">
                                                <div class="progress">
                                                    <div class="progress-bar bg-danger" id="oneStarBar" role="progressbar" style="width: 0%" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"></div>
                                                </div>
                                            </div>
                                            <div class="rating-count">
                                                <span id="oneStarCount">0</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-lg-8 mb-4">
                        <div class="card">
                            <div class="card-body">
                                <h5 class="card-title mb-3">Rating Trends</h5>
                                <canvas id="ratingsChart" height="230"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Reviews List -->
                <div class="card mb-4">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5 class="mb-0">Customer Reviews</h5>
                        <div class="search-container">
                            <input type="text" id="reviewSearch" class="form-control form-control-sm" placeholder="Search reviews...">
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div id="reviewsContainer" class="reviews-list">
                            <!-- Reviews will be loaded here -->
                            <div class="reviews-loading text-center py-5">
                                <div class="spinner-border text-primary" role="status">
                                    <span class="visually-hidden">Loading...</span>
                                </div>
                                <p class="mt-2">Loading reviews...</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- No Reviews Message -->
                <div class="card mb-4" id="noReviewsMessage" style="display: none;">
                    <div class="card-body text-center py-5">
                        <div class="empty-state">
                            <i class="fas fa-star fa-4x text-muted mb-4"></i>
                            <h3>No Reviews Yet</h3>
                            <p class="text-muted mb-4">You haven't received any customer reviews yet.</p>
                            <p>When clients leave reviews for your services, they'll appear here.</p>
                        </div>
                    </div>
                </div>
                
                <!-- Review Tips -->
                <div class="card mb-4" id="reviewTips">
                    <div class="card-header">
                        <h5 class="mb-0">Tips for Great Reviews</h5>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="tip-item">
                                    <div class="tip-icon">
                                        <i class="fas fa-comments"></i>
                                    </div>
                                    <div class="tip-content">
                                        <h6>Respond Promptly</h6>
                                        <p>Always respond to reviews within 24-48 hours to show clients that you value their feedback.</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="tip-item">
                                    <div class="tip-icon">
                                        <i class="fas fa-heart"></i>
                                    </div>
                                    <div class="tip-content">
                                        <h6>Show Appreciation</h6>
                                        <p>Thank clients for positive feedback and for taking the time to share their experience.</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="tip-item">
                                    <div class="tip-icon">
                                        <i class="fas fa-lightbulb"></i>
                                    </div>
                                    <div class="tip-content">
                                        <h6>Address Concerns</h6>
                                        <p>For critical reviews, acknowledge the client's concerns and explain how you'll address the issue.</p>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="tip-item">
                                    <div class="tip-icon">
                                        <i class="fas fa-envelope"></i>
                                    </div>
                                    <div class="tip-content">
                                        <h6>Encourage Reviews</h6>
                                        <p>Send follow-up emails after services are rendered to encourage clients to leave feedback.</p>
                                    </div>
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
    
    <!-- Reply Modal -->
    <div class="modal fade" id="replyModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Respond to Review</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="original-review mb-4">
                        <h6>Original Review</h6>
                        <div class="review-content p-3 bg-light rounded">
                            <div class="d-flex align-items-center mb-2">
                                <div class="review-stars me-2" id="reviewModalRating">
                                    <!-- Stars will be added dynamically -->
                                </div>
                                <span class="date-text text-muted" id="reviewModalDate">Date</span>
                            </div>
                            <p id="reviewModalContent" class="mb-0">Review content will appear here</p>
                        </div>
                    </div>
                    <form id="reviewReplyForm">
                        <input type="hidden" id="reviewId" name="reviewId">
                        <div class="mb-3">
                            <label for="replyText" class="form-label">Your Response</label>
                            <textarea class="form-control" id="replyText" rows="4" placeholder="Write your response to this review..." required></textarea>
                            <div class="form-text">Be professional and courteous in your response. This will be visible to all potential clients.</div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="submitReplyBtn">
                        <i class="fas fa-paper-plane me-2"></i> Submit Response
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Flag Review Modal -->
    <div class="modal fade" id="flagReviewModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Flag Review</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="alert alert-info">
                        <i class="fas fa-info-circle me-2"></i> Flagged reviews will be sent to our team for review. Reviews that violate our policies may be removed.
                    </div>
                    <form id="flagReviewForm">
                        <input type="hidden" id="flaggedReviewId" name="flaggedReviewId">
                        <div class="mb-3">
                            <label for="flagReason" class="form-label">Reason for Flagging</label>
                            <select class="form-select" id="flagReason" required>
                                <option value="">Select a reason</option>
                                <option value="inappropriate">Inappropriate content</option>
                                <option value="fake">Fake or fraudulent review</option>
                                <option value="spam">Spam or advertising</option>
                                <option value="noservice">Client did not use our service</option>
                                <option value="other">Other</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="flagDescription" class="form-label">Additional Details</label>
                            <textarea class="form-control" id="flagDescription" rows="3" placeholder="Please provide any additional details about why you're flagging this review..."></textarea>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="submitFlagBtn">
                        <i class="fas fa-flag me-2"></i> Submit Flag
                    </button>
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
    
    <!-- DataTables -->
    <script src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.11.5/js/dataTables.bootstrap5.min.js"></script>
    
    <!-- Common Dashboard JS -->
    <script src="${pageContext.request.contextPath}/assets/js/vendor/dashboard.js"></script>
    
    <!-- Reviews Page JS -->
    <script src="${pageContext.request.contextPath}/assets/js/vendor/reviews.js"></script>
    
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