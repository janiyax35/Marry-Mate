<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%
    // Check if user is logged in and has admin role
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    
    // Redirect if not admin
    /*if (username == null || !"admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/error/access-denied.jsp");
        return;
    }*/
    
    if (username != null && !"admin".equals(role) && !"super_admin".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/error/access-denied.jsp");
        return;
    }
    
    // For demonstration purposes - in a real app these would come from a database
    String currentDateTime = "2025-04-30 19:15:27";
    String currentUser = "IT24102137";
    
    // Sample data for dashboard statistics
    int totalUsers = 1284;
    int totalVendors = 347;
    int activeBookings = 528;
    int pendingReviews = 89;
    int totalRevenue = 245600;
    double growthRate = 12.8;
    
    // Sample recent registrations
    Map<String, String> recentUsers = new LinkedHashMap<>();
    recentUsers.put("Emily Johnson", "User");
    recentUsers.put("Sunset Catering", "Vendor");
    recentUsers.put("Alex Williams", "User");
    recentUsers.put("Dream Dresses", "Vendor");
    recentUsers.put("Michael Brown", "User");
    
    // Sample recent bookings
    String[][] recentBookings = {
        {"Sarah & David", "Enchanted Gardens", "Venue", "05-15-2025", "$5,200"},
        {"Emma & James", "Artistic Moments", "Photography", "06-22-2025", "$2,800"},
        {"Jessica & Michael", "Divine Catering", "Catering", "05-30-2025", "$3,750"},
        {"Rachel & Thomas", "Melody Makers", "Music", "07-12-2025", "$1,950"},
        {"Megan & Chris", "Blossom Florists", "Flowers", "06-05-2025", "$1,200"}
    };
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard | Marry Mate</title>
    
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/dashboard.css">
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
                    <li class="active">
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
                                            <p><strong>New vendor registration</strong> - Elegant Floral Designs</p>
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
                                            <p><strong>New report</strong> - User reported an issue with payment</p>
                                            <span class="notification-time">1 hour ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-info">
                                            <i class="fas fa-star"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>New review</strong> - 5-star rating for Enchanted Gardens</p>
                                            <span class="notification-time">2 hours ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-success">
                                            <i class="fas fa-check-circle"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>System update</strong> - Successfully deployed version 2.4.1</p>
                                            <span class="notification-time">Yesterday</span>
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

            <!-- Dashboard Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1>Admin Dashboard</h1>
                        <p class="subtitle">Welcome back, Administrator. Here's what's happening with Marry Mate today.</p>
                    </div>
                    <div class="page-actions">
                        <span class="current-date">
                            <i class="far fa-calendar-alt"></i>
                            <%= currentDateTime %>
                        </span>
                        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#generateReportModal">
                            <i class="fas fa-download me-2"></i>
                            Generate Report
                        </button>
                    </div>
                </div>
                
                <!-- Stats Overview -->
                <div class="row">
                    <div class="col-xl-3 col-lg-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value"><%= totalUsers %></div>
                                <div class="stat-card-title">Total Users</div>
                            </div>
                            <div class="stat-card-icon bg-primary">
                                <i class="fas fa-users"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change increase">
                                    <i class="fas fa-arrow-up"></i> 16.5%
                                </div>
                                <div class="stat-time">Since last month</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-lg-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value"><%= totalVendors %></div>
                                <div class="stat-card-title">Total Vendors</div>
                            </div>
                            <div class="stat-card-icon bg-success">
                                <i class="fas fa-store"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change increase">
                                    <i class="fas fa-arrow-up"></i> 8.2%
                                </div>
                                <div class="stat-time">Since last month</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-lg-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value"><%= activeBookings %></div>
                                <div class="stat-card-title">Active Bookings</div>
                            </div>
                            <div class="stat-card-icon bg-info">
                                <i class="fas fa-calendar-check"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change increase">
                                    <i class="fas fa-arrow-up"></i> 12.7%
                                </div>
                                <div class="stat-time">Since last month</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-3 col-lg-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value">$<%= String.format("%,d", totalRevenue) %></div>
                                <div class="stat-card-title">Total Revenue</div>
                            </div>
                            <div class="stat-card-icon bg-warning">
                                <i class="fas fa-dollar-sign"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change increase">
                                    <i class="fas fa-arrow-up"></i> <%= growthRate %>%
                                </div>
                                <div class="stat-time">Since last month</div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Charts Section -->
                <div class="row mt-4">
                    <!-- User Growth Chart -->
                    <div class="col-lg-8 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>User Growth & Vendor Registrations</h5>
                                <div class="card-actions">
                                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" id="growthOptions">
                                        Last 6 Months
                                    </button>
                                </div>
                            </div>
                            <div class="card-body">
                                <canvas id="userGrowthChart" height="300"></canvas>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Popular Vendor Categories -->
                    <div class="col-lg-4 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Popular Vendor Categories</h5>
                                <div class="card-actions">
                                    <button class="btn btn-sm btn-outline-secondary" type="button">
                                        <i class="fas fa-sync-alt"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="card-body">
                                <canvas id="vendorCategoriesChart" height="300"></canvas>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Recent Activity and Quick Actions -->
                <div class="row">
                    <!-- Recent Registrations -->
                    <div class="col-lg-4 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Recent Registrations</h5>
                                <div class="card-actions">
                                    <a href="${pageContext.request.contextPath}/admin/user-management.jsp" class="btn btn-link btn-sm">View All</a>
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-borderless mb-0">
                                        <tbody>
                                            <% for (Map.Entry<String, String> user : recentUsers.entrySet()) { %>
                                            <tr>
                                                <td>
                                                    <div class="d-flex align-items-center">
                                                        <div class="avatar avatar-sm me-3">
                                                            <img src="https://ui-avatars.com/api/?name=<%= user.getKey().replace(" ", "+") %>&background=random&color=fff" alt="<%= user.getKey() %>">
                                                        </div>
                                                        <div>
                                                            <p class="mb-0 fw-medium"><%= user.getKey() %></p>
                                                            <small class="text-muted"><%= user.getValue() %></small>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="text-end">
                                                    <div class="dropdown">
                                                        <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown">
                                                            <i class="fas fa-ellipsis-v"></i>
                                                        </button>
                                                        <div class="dropdown-menu dropdown-menu-end">
                                                            <a class="dropdown-item" href="#">View Details</a>
                                                            <a class="dropdown-item" href="#">Edit</a>
                                                            <div class="dropdown-divider"></div>
                                                            <a class="dropdown-item text-danger" href="#">Delete</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Recent Bookings -->
                    <div class="col-lg-8 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Recent Bookings</h5>
                                <div class="card-actions">
                                    <a href="${pageContext.request.contextPath}/admin/bookings.jsp" class="btn btn-link btn-sm">View All</a>
                                </div>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table mb-0">
                                        <thead>
                                            <tr>
                                                <th>Couple</th>
                                                <th>Vendor</th>
                                                <th>Service Type</th>
                                                <th>Date</th>
                                                <th>Amount</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (String[] booking : recentBookings) { %>
                                            <tr>
                                                <td><%= booking[0] %></td>
                                                <td><%= booking[1] %></td>
                                                <td><span class="badge rounded-pill bg-light text-dark"><%= booking[2] %></span></td>
                                                <td><%= booking[3] %></td>
                                                <td><%= booking[4] %></td>
                                                <td>
                                                    <div class="dropdown">
                                                        <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown">
                                                            <i class="fas fa-ellipsis-v"></i>
                                                        </button>
                                                        <div class="dropdown-menu dropdown-menu-end">
                                                            <a class="dropdown-item" href="#">View Details</a>
                                                            <a class="dropdown-item" href="#">Edit</a>
                                                            <div class="dropdown-divider"></div>
                                                            <a class="dropdown-item text-danger" href="#">Cancel</a>
                                                        </div>
                                                    </div>
                                                </td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Quick Actions & System Status -->
                <div class="row">
                    <!-- Quick Actions -->
                    <div class="col-lg-6 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>Quick Actions</h5>
                            </div>
                            <div class="card-body">
                                <div class="quick-actions">
                                    <a href="${pageContext.request.contextPath}/admin/user-management.jsp?action=new" class="quick-action-btn">
                                        <i class="fas fa-user-plus"></i>
                                        <span>Add User</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/vendor-management.jsp?action=new" class="quick-action-btn">
                                        <i class="fas fa-store-alt"></i>
                                        <span>Add Vendor</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/content.jsp?action=promotions" class="quick-action-btn">
                                        <i class="fas fa-ad"></i>
                                        <span>Promotions</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/reports.jsp" class="quick-action-btn">
                                        <i class="fas fa-file-alt"></i>
                                        <span>Reports</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/emails.jsp" class="quick-action-btn">
                                        <i class="fas fa-envelope"></i>
                                        <span>Send Email</span>
                                    </a>
                                    <a href="${pageContext.request.contextPath}/admin/backup.jsp" class="quick-action-btn">
                                        <i class="fas fa-database"></i>
                                        <span>Backup Data</span>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- System Status -->
                    <div class="col-lg-6 mb-4">
                        <div class="card">
                            <div class="card-header">
                                <h5>System Status</h5>
                                <div class="card-actions">
                                    <button class="btn btn-sm btn-outline-secondary" type="button">
                                        <i class="fas fa-sync-alt"></i> Refresh
                                    </button>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="system-status">
                                    <div class="status-item">
                                        <div class="status-label">Server Status</div>
                                        <div class="status-value text-success">
                                            <i class="fas fa-check-circle"></i> Online
                                        </div>
                                    </div>
                                    <div class="status-item">
                                        <div class="status-label">Database</div>
                                        <div class="status-value text-success">
                                            <i class="fas fa-check-circle"></i> Connected
                                        </div>
                                    </div>
                                    <div class="status-item">
                                        <div class="status-label">Payment Gateway</div>
                                        <div class="status-value text-success">
                                            <i class="fas fa-check-circle"></i> Operational
                                        </div>
                                    </div>
                                    <div class="status-item">
                                        <div class="status-label">Email Service</div>
                                        <div class="status-value text-success">
                                            <i class="fas fa-check-circle"></i> Working
                                        </div>
                                    </div>
                                    <div class="status-item">
                                        <div class="status-label">Server Load</div>
                                        <div class="status-value">
                                            <div class="progress" style="height: 6px; width: 100%">
                                                <div class="progress-bar bg-success" role="progressbar" style="width: 35%;" aria-valuenow="35" aria-valuemin="0" aria-valuemax="100"></div>
                                            </div>
                                            <small class="text-muted">35% - Normal</small>
                                        </div>
                                    </div>
                                    <div class="status-item">
                                        <div class="status-label">Last Backup</div>
                                        <div class="status-value">
                                            <span class="text-muted">2025-04-30 06:30:22</span>
                                            <small class="d-block text-success">Successful</small>
                                        </div>
                                    </div>
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
                        <span>Version 2.4.1 | Current User: <%= currentUser %> | Last Login: 2025-04-30 18:42:15</span>
                    </div>
                </footer>
            </div>
        </div>
    </div>

    <!-- Generate Report Modal -->
    <div class="modal fade" id="generateReportModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Generate Report</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form>
                        <div class="mb-3">
                            <label for="reportType" class="form-label">Report Type</label>
                            <select class="form-select" id="reportType" required>
                                <option value="">Select a report type</option>
                                <option value="users">User Growth Report</option>
                                <option value="vendors">Vendor Performance Report</option>
                                <option value="bookings">Booking Analytics Report</option>
                                <option value="revenue">Revenue Report</option>
                                <option value="system">System Health Report</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="dateRange" class="form-label">Date Range</label>
                            <select class="form-select" id="dateRange" required>
                                <option value="7days">Last 7 Days</option>
                                <option value="30days">Last 30 Days</option>
                                <option value="90days">Last 90 Days</option>
                                <option value="year" selected>This Year</option>
                                <option value="custom">Custom Range</option>
                            </select>
                        </div>
                        <div class="mb-3">
                            <label for="reportFormat" class="form-label">Format</label>
                            <div class="d-flex">
                                <div class="form-check me-3">
                                    <input class="form-check-input" type="radio" name="reportFormat" id="formatPDF" value="pdf" checked>
                                    <label class="form-check-label" for="formatPDF">PDF</label>
                                </div>
                                <div class="form-check me-3">
                                    <input class="form-check-input" type="radio" name="reportFormat" id="formatExcel" value="excel">
                                    <label class="form-check-label" for="formatExcel">Excel</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="reportFormat" id="formatCSV" value="csv">
                                    <label class="form-check-label" for="formatCSV">CSV</label>
                                </div>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="generateReportBtn">
                        <i class="fas fa-download me-1"></i> Generate
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
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/admin/dashboard.js"></script>
</body>
</html>