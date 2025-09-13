<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.SimpleDateFormat, java.time.Duration, java.time.Instant" %>
<%@ page import="javax.servlet.http.HttpSession" %>
<%@ page import="com.MarryMate.services.SessionManager" %>
<%@ page import="com.MarryMate.services.SessionManager.SessionInfo" %>

<%
// Security check - only admin users can access this page
String userRole = (String) session.getAttribute("role");

boolean isAdmin = userRole != null && (userRole.contains("admin") || userRole.equals("super_admin"));
boolean isSuperAdmin = userRole != null && userRole.equals("super_admin");

if (!isAdmin) {
    response.sendRedirect(request.getContextPath() + "/error/access-denied.jsp");
    return;
}else if (isSuperAdmin) {
    session.setAttribute("isSuperAdmin", true);
}
// Format for displaying dates
SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));

// Current time for calculating session durations
long currentTime = System.currentTimeMillis();

// Get active sessions data - fixed to use SessionInfo objects
Map<String, SessionManager.SessionInfo> activeSessions = SessionManager.getActiveSessions();

// Action handling for session invalidation
String action = request.getParameter("action");
String targetSessionId = request.getParameter("sessionId");

if (action != null && targetSessionId != null) {
    if (action.equals("invalidate") && !targetSessionId.equals(session.getId())) {
        // Call the SessionManager to invalidate by ID
        SessionManager.invalidateSession(targetSessionId);
        response.sendRedirect(request.getRequestURI() + "?message=Session+invalidated+successfully");
        return;
    }
}

// Calculate stats
int adminSessions = 0;
int superAdminSessions = 0;
int userSessions = 0;
int vendorSessions = 0;

for (SessionManager.SessionInfo info : activeSessions.values()) {
    String role = info.role;
    if (role != null) {
        if (role.equals("super_admin")) {
            superAdminSessions++;
        } else if (role.equals("admin")) {
            adminSessions++;
        } else if (role.equals("vendor")) {
            vendorSessions++;
        } else {
            userSessions++;
        }
    }
}

// Current DateTime for display
String currentDateTime = dateFormat.format(new Date());
String currentUser = (String) session.getAttribute("username");

// Store login time in session if not already present
if (session.getAttribute("loginTime") == null) {
    session.setAttribute("loginTime", currentTime);
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="context-path" content="${pageContext.request.contextPath}">
    <title>Session Management | Marry Mate Admin</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600;700&family=Playfair+Display:wght@400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.4/css/dataTables.bootstrap5.min.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/buttons/2.3.6/css/buttons.bootstrap5.min.css">
    
    <!-- Toastify CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">
    
    <!-- Custom CSS -->
    
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/session-management.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/admin/dashboard.css">
    <!-- If you need specific styles for session management, add them after the dashboard CSS -->
<style>
    /* Any session-specific styles you need to retain can go here */
    /* For example: */
    .sessions-table .activity-indicator {
        width: 10px;
        height: 10px;
        border-radius: 50%;
        display: inline-block;
        margin-right: 5px;
    }
    
    .sessions-table .active-indicator {
        background-color: var(--success);
        box-shadow: 0 0 5px rgba(40, 167, 69, 0.5);
        animation: pulse 2s infinite;
    }
    
    .sessions-table .inactive-indicator {
        background-color: var(--text-medium);
    }
    
    @keyframes pulse {
        0% {
            box-shadow: 0 0 0 0 rgba(40, 167, 69, 0.7);
        }
        70% {
            box-shadow: 0 0 0 5px rgba(40, 167, 69, 0);
        }
        100% {
            box-shadow: 0 0 0 0 rgba(40, 167, 69, 0);
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
                    
	                <li>
                        <a href="${pageContext.request.contextPath}/AdminProfileServlet">
                            <i class="fas fa-user-cog"></i>
                            <span>My Profile</span>
                        </a>
                    </li>
                    <li class="active">
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
                            <span class="badge bg-danger notification-count">4</span>
                        </button>
                        <div class="notification-dropdown">
                            <div class="notification-header">
                                <h5>Notifications</h5>
                                <a href="#" class="mark-all-read">Mark all as read</a>
                            </div>
                            <ul class="notification-list" id="notificationList">
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-primary">
                                            <i class="fas fa-user-plus"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>New user registered</strong> - John Smith</p>
                                            <span class="notification-time">10 minutes ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-warning">
                                            <i class="fas fa-user-clock"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>Session activity</strong> - 10 new sessions today</p>
                                            <span class="notification-time">1 hour ago</span>
                                        </div>
                                    </a>
                                </li>
                                <li class="unread">
                                    <a href="#">
                                        <div class="notification-icon bg-info">
                                            <i class="fas fa-shield-alt"></i>
                                        </div>
                                        <div class="notification-content">
                                            <p><strong>Security alert</strong> - Multiple login attempts</p>
                                            <span class="notification-time">2 hours ago</span>
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
                            <img src="https://ui-avatars.com/api/?name=<%= currentUser %>&background=1a365d&color=fff" alt="Admin">
                            <span class="admin-name"><%= currentUser %></span>
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

            <!-- Session Management Content -->
            <div class="dashboard-content">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1><i class="fas fa-user-clock"></i> Session Management</h1>
                        <p class="subtitle">Monitor and manage active user sessions across the system.</p>
                    </div>
                    <div class="page-actions">
                        <span class="current-date" id="current-datetime">
                            <i class="far fa-calendar-alt"></i>
                            <%= currentDateTime %>
                        </span>
                        <button class="btn btn-primary" id="refreshSessions">
                            <i class="fas fa-sync-alt me-2"></i>
                            Refresh Data
                        </button>
                    </div>
                </div>
                
                <!-- Status Messages -->
                <% if (request.getParameter("message") != null) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="fas fa-check-circle me-2"></i> <%= request.getParameter("message") %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
                <% } %>
                
                <!-- Stats Cards -->
                <div class="row">
                    <div class="col-xl-4 col-md-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value" id="totalSessions"><%= activeSessions.size() %></div>
                                <div class="stat-card-title">Total Active Sessions</div>
                            </div>
                            <div class="stat-card-icon bg-primary">
                                <i class="fas fa-users"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change">
                                    <span id="sessionUpdateTime">Last updated just now</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-4 col-md-6">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value">
                                    <%= superAdminSessions %> / <%= adminSessions %> / <%= userSessions %> / <%= vendorSessions %>
                                </div>
                                <div class="stat-card-title">Super / Admin / User / Vendor</div>
                            </div>
                            <div class="stat-card-icon bg-success">
                                <i class="fas fa-user-tag"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change">
                                    <span>Session distribution by role</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-xl-4 col-md-12">
                        <div class="stat-card">
                            <div class="stat-card-info">
                                <div class="stat-card-value" id="yourSessionTime" data-login-time="<%= session.getAttribute("loginTime") %>">00:00:00</div>
                                <div class="stat-card-title">Your Session Duration</div>
                            </div>
                            <div class="stat-card-icon bg-info">
                                <i class="fas fa-clock"></i>
                            </div>
                            <div class="stat-meta">
                                <div class="stat-change">
                                    <span>Updates in real-time</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Sessions Main Content -->
                <div class="card">
                    <div class="card-header d-flex justify-content-between align-items-center">
                        <h5><i class="fas fa-user-shield me-2"></i> Active Sessions</h5>
                        <div>
                            <div class="btn-group me-2">
                                <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="fas fa-download me-1"></i> Export
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li><a class="dropdown-item" id="exportExcel" href="#"><i class="fas fa-file-excel me-2"></i>Excel</a></li>
                                    <li><a class="dropdown-item" id="exportCSV" href="#"><i class="fas fa-file-csv me-2"></i>CSV</a></li>
                                    <li><a class="dropdown-item" id="exportPDF" href="#"><i class="fas fa-file-pdf me-2"></i>PDF</a></li>
                                </ul>
                            </div>
                            
                            <button class="btn btn-sm btn-outline-secondary me-2" id="refreshSessionsBtn">
                                <i class="fas fa-sync-alt"></i> Refresh
                            </button>
                            
                            <% if (isSuperAdmin) { %>
                            <div class="btn-group">
                                <button class="btn btn-sm btn-danger dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                                    <i class="fas fa-trash-alt me-1"></i> Invalidate
                                </button>
                                <ul class="dropdown-menu dropdown-menu-end">
                                    <li><a class="dropdown-item" href="#" id="invalidateAllOtherBtn"><i class="fas fa-minus-circle me-2"></i>All Other Sessions</a></li>
                                    <li><a class="dropdown-item" href="#" id="invalidateAllBtn"><i class="fas fa-radiation me-2"></i>All Sessions</a></li>
                                </ul>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    
                    <div class="card-body">
                        <!-- Filters -->
                        <div class="filters-row">
                            <div class="row">
                                <div class="col-md-4 mb-2 mb-md-0">
                                    <div class="input-group">
                                        <span class="input-group-text">
                                            <i class="fas fa-search"></i>
                                        </span>
                                        <input type="text" id="searchInput" class="form-control" placeholder="Search sessions...">
                                    </div>
                                </div>
                                <div class="col-md-3 mb-2 mb-md-0">
                                    <select id="roleFilter" class="form-select">
                                        <option value="">All Roles</option>
                                        <option value="super_admin">Super Admin</option>
                                        <option value="admin">Admin</option>
                                        <option value="vendor">Vendor</option>
                                        <option value="user">User</option>
                                    </select>
                                </div>
                                <div class="col-md-3 mb-2 mb-md-0">
                                    <select id="statusFilter" class="form-select">
                                        <option value="">All Statuses</option>
                                        <option value="active">Active (< 15 min)</option>
                                        <option value="inactive">Inactive (> 15 min)</option>
                                    </select>
                                </div>
                                <div class="col-md-2 text-md-end">
                                    <button class="btn btn-primary w-100" id="resetFilters">
                                        <i class="fas fa-filter me-1"></i> Reset
                                    </button>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Sessions Table -->
                        <div class="table-responsive">
                            <table class="table table-hover sessions-table" id="sessionsTable">
                                <thead>
                                    <tr>
                                        <th>#</th>
                                        <th>Status</th>
                                        <th>Username</th>
                                        <th>Role</th>
                                        <th>Login Time</th>
                                        <th>Last Activity</th>
                                        <th>Duration</th>
                                        <th>IP Address</th>
                                        <th>Device</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <% 
                                int counter = 1;
                                for (Map.Entry<String, SessionManager.SessionInfo> entry : activeSessions.entrySet()) {
                                    String sessionId = entry.getKey();
                                    SessionManager.SessionInfo sessionInfo = entry.getValue();
                                    
                                    // Get session attributes
                                    String userId = sessionInfo.userId;
                                    String username = sessionInfo.username;
                                    String role = sessionInfo.role;
                                    long loginTime = sessionInfo.loginTime;
                                    long lastActivity = sessionInfo.lastActivityTime;
                                    String ipAddress = sessionInfo.ipAddress;
                                    String deviceType = sessionInfo.deviceType;
                                    
                                    // Skip if required attributes are missing
                                    if (username == null) username = "Guest";
                                    if (role == null) role = "Unknown";
                                    
                                    // Calculate activity status and display classes
                                    boolean isCurrentSession = session.getId().equals(sessionId);
                                    boolean isActive = lastActivity != 0 && (currentTime - lastActivity < 15 * 60 * 1000); // 15 minutes
                                    
                                    String rowClass = isCurrentSession ? "current-user-session" : "";
                                    String statusClass = isActive ? "status-active" : "status-inactive";
                                    String statusLabel = isActive ? "Active" : "Inactive";
                                    String indicatorClass = isActive ? "active-indicator" : "inactive-indicator";
                                    
                                    // Calculate duration
                                    String durationText = "N/A";
                                    int durationPercent = 0;
                                    
                                    if (loginTime != 0) {
                                        long durationMs = currentTime - loginTime;
                                        long durationSeconds = durationMs / 1000;
                                        
                                        long hours = durationSeconds / 3600;
                                        long minutes = (durationSeconds % 3600) / 60;
                                        long seconds = durationSeconds % 60;
                                        
                                        durationText = String.format("%02d:%02d:%02d", hours, minutes, seconds);
                                        
                                        // Calculate percentage for bar (assume max 24 hours)
                                        durationPercent = (int) Math.min(100, (durationMs * 100) / (24 * 3600 * 1000));
                                    }
                                %>
                                    <tr class="<%= rowClass %>" data-session-id="<%= sessionId %>" data-role="<%= role.toLowerCase() %>" data-status="<%= isActive ? "active" : "inactive" %>">
                                        <td><%= counter++ %></td>
                                        <td>
                                            <span class="activity-indicator <%= indicatorClass %>"></span>
                                            <span class="status-label <%= statusClass %>"><%= statusLabel %></span>
                                            <% if (isCurrentSession) { %>
                                                <span class="current-user-badge">You</span>
                                            <% } %>
                                        </td>
                                        <td><%= username %></td>
                                        <td>
                                            <% if (role.equals("super_admin")) { %>
                                                <span class="badge bg-purple">Super Admin</span>
                                            <% } else if (role.equals("admin")) { %>
                                                <span class="badge bg-danger">Admin</span>
                                            <% } else if (role.equals("vendor")) { %>
                                                <span class="badge bg-warning text-dark">Vendor</span>
                                            <% } else { %>
                                                <span class="badge bg-info">User</span>
                                            <% } %>
                                        </td>
                                        <td><%= loginTime != 0 ? dateFormat.format(new Date(loginTime)) : "N/A" %></td>
                                        <td><%= lastActivity != 0 ? dateFormat.format(new Date(lastActivity)) : "N/A" %></td>
                                        <td>
                                            <%= durationText %>
                                            <div class="duration-bar">
                                                <div class="duration-bar-fill" style="width: <%= durationPercent %>%"></div>
                                            </div>
                                        </td>
                                        <td><%= ipAddress %></td>
                                        <td><%= deviceType %></td>
                                        <td>
                                            <button class="btn action-btn action-btn-view view-session" title="View Details" data-id="<%= sessionId %>">
                                                <i class="fas fa-info-circle"></i>
                                            </button>
                                            <% if (!isCurrentSession) { 
                                                // Check if admin can invalidate this session
                                                boolean canInvalidate = isSuperAdmin || !role.contains("admin");
                                                if (canInvalidate) { %>
                                                <button class="btn action-btn action-btn-delete invalidate-session" title="Invalidate Session" data-id="<%= sessionId %>">
                                                    <i class="fas fa-times-circle"></i>
                                                </button>
                                            <% } else { %>
                                                <button class="btn action-btn action-btn-lock" disabled title="Cannot invalidate admin session">
                                                    <i class="fas fa-lock"></i>
                                                </button>
                                            <% }
                                            } else { %>
                                                <button class="btn action-btn action-btn-secondary" disabled title="Current Session">
                                                    <i class="fas fa-user-check"></i>
                                                </button>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="card-footer">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <span class="text-muted">Last refreshed: </span>
                                <span id="lastRefreshTime"><%= dateFormat.format(new Date()) %></span>
                            </div>
                            <div>
                                <span class="text-muted">Current server time: </span>
                                <span id="serverTime"><%= currentDateTime %></span>
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

    <!-- Session Details Modal -->
    <div class="modal fade" id="sessionDetailsModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-user-clock me-2"></i>
                        Session Details
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="sessionDetailsBody">
                    <div class="text-center py-5">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-3">Loading session details...</p>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-danger" id="modalInvalidateBtn">
                        <i class="fas fa-times-circle me-1"></i> Invalidate Session
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Confirm Invalidate Modal -->
    <div class="modal fade" id="confirmInvalidateModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        Confirm Invalidation
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to invalidate this session?</p>
                    <p>This will immediately log the user out of the system.</p>
                    <div class="alert alert-warning">
                        <i class="fas fa-info-circle me-2"></i>
                        This action cannot be undone.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmInvalidateBtn">
                        <i class="fas fa-times-circle me-1"></i> Invalidate
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Confirm Invalidate All Modal -->
    <div class="modal fade" id="confirmInvalidateAllModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        Confirm Invalidate All
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to invalidate all sessions?</p>
                    <p>This will immediately log out <strong>ALL USERS</strong> from the system, including yourself.</p>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        <strong>WARNING:</strong> This is an extreme action that will affect all users and will also log you out!
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmInvalidateAllBtn">
                        <i class="fas fa-times-circle me-1"></i> Invalidate All Sessions
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Confirm Invalidate All Others Modal -->
    <div class="modal fade" id="confirmInvalidateAllOthersModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-warning text-dark">
                    <h5 class="modal-title">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        Confirm Invalidate All Other Sessions
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to invalidate all other sessions?</p>
                    <p>This will immediately log out all users except you from the system.</p>
                    <div class="alert alert-warning">
                        <i class="fas fa-info-circle me-2"></i>
                        This is a significant action that will affect all other users currently logged in.
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-warning" id="confirmInvalidateAllOthersBtn">
                        <i class="fas fa-times-circle me-1"></i> Invalidate All Other Sessions
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
    <script src="https://cdn.datatables.net/1.13.4/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.4/js/dataTables.bootstrap5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.3.6/js/dataTables.buttons.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.3.6/js/buttons.bootstrap5.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/pdfmake.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/vfs_fonts.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.3.6/js/buttons.html5.min.js"></script>
    <script src="https://cdn.datatables.net/buttons/2.3.6/js/buttons.print.min.js"></script>
    
    <!-- Toastify JS -->
    <script src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/admin/session-management.js"></script>
   
</body>
</html>