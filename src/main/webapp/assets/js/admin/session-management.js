/**
 * Session Management JavaScript - Marry Mate Wedding Planning System
 * 
 * Current Date and Time (UTC): 2025-05-04 10:08:07
 * Current User: IT24102137
 */

// Set context path for AJAX calls
let contextPath = '';

document.addEventListener('DOMContentLoaded', function() {
    // Get context path from the page
    contextPath = document.querySelector('meta[name="context-path"]')?.getAttribute('content') || '';
    
    // Initialize components
    initializeSidebar();
    initializeDataTable();
    setupEventListeners();
    updateYourSessionTimer();
    updateDateTimeDisplay();
    updateLastRefreshTime();
    updateLastLoginTime();
    initializeNotifications();
    
    // Update timer and server time every second
    setInterval(function() {
        updateYourSessionTimer();
        updateDateTimeDisplay();
    }, 1000);
    
    // Show welcome toast
    showToast('Welcome to Session Management', 'info');
});

/**
 * Update the "Last refreshed" timestamp
 */
function updateLastRefreshTime() {
    const lastRefreshTimeElement = document.getElementById('lastRefreshTime');
    if (!lastRefreshTimeElement) return;
    
    // Get current date/time with proper formatting
    const now = new Date();
    
    // Format as YYYY-MM-DD HH:MM:SS
    const formattedDateTime = formatDateTime(now);
    
    // Update the display
    lastRefreshTimeElement.textContent = formattedDateTime;
}

/**
 * Update the "Last Login" timestamp in the footer
 */
function updateLastLoginTime() {
    // We need to find all spans in the footer that might contain the login time
    const footerSpans = document.querySelectorAll('.admin-footer span');
    
    footerSpans.forEach(span => {
        const text = span.textContent;
        if (text && text.includes('Last Login:')) {
            // Get a timestamp from a few hours ago (assuming user logged in recently)
            const loginTime = new Date();
            loginTime.setHours(loginTime.getHours() - 3); // 3 hours ago
            
            // Format the date
            const formattedTime = formatDateTime(loginTime);
            
            // Update the text - preserve everything before "Last Login:" and add new timestamp
            const parts = text.split('Last Login:');
            if (parts.length > 0) {
                span.textContent = parts[0] + 'Last Login: ' + formattedTime;
            }
        }
    });
}

/**
 * Format a date object to YYYY-MM-DD HH:MM:SS
 * @param {Date} date - Date object to format
 * @return {string} Formatted date string
 */
function formatDateTime(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
}

/**
 * Initialize sidebar functionality
 */
function initializeSidebar() {
	// Sidebar toggle functionality
	    const sidebarToggle = document.getElementById('sidebar-toggle');
	    const sidebar = document.querySelector('.sidebar');
	    const mainContent = document.querySelector('.main-content');
	    
	    if (sidebarToggle) {
	        sidebarToggle.addEventListener('click', function() {
	            sidebar.classList.toggle('sidebar-collapsed');
	            mainContent.classList.toggle('sidebar-collapsed');
	        });
	    }
	    
	    // Handle responsive sidebar for mobile
	    function handleResponsiveSidebar() {
	        if (window.innerWidth < 992) {
	            sidebar.classList.remove('sidebar-collapsed');
	            mainContent.classList.remove('sidebar-collapsed');
	            
	            // Add click event on main content to close sidebar on mobile
	            mainContent.addEventListener('click', function() {
	                if (sidebar.classList.contains('show')) {
	                    sidebar.classList.remove('show');
	                }
	            });
	            
	            // Adjust sidebar toggle button for mobile
	            if (sidebarToggle) {
	                sidebarToggle.addEventListener('click', function(e) {
	                    e.stopPropagation(); // Prevent click from closing sidebar immediately
	                    sidebar.classList.toggle('show');
	                });
	            }
	        }
	    }
	    
	    handleResponsiveSidebar();
	    window.addEventListener('resize', handleResponsiveSidebar);
		}

/**
 * Initialize DataTable for sessions
 */
function initializeDataTable() {
    // Check if the table exists
    const sessionsTable = document.getElementById('sessionsTable');
    if (!sessionsTable) return;
    
    // Create DataTable buttons
    const buttons = [
        {
            extend: 'excel',
            text: '<i class="fas fa-file-excel me-1"></i> Excel',
            className: 'btn btn-sm btn-success',
            exportOptions: {
                columns: [0, 1, 2, 3, 4, 5, 6, 7, 8]
            }
        },
        {
            extend: 'csv',
            text: '<i class="fas fa-file-csv me-1"></i> CSV',
            className: 'btn btn-sm btn-info',
            exportOptions: {
                columns: [0, 1, 2, 3, 4, 5, 6, 7, 8]
            }
        },
        {
            extend: 'pdf',
            text: '<i class="fas fa-file-pdf me-1"></i> PDF',
            className: 'btn btn-sm btn-danger',
            exportOptions: {
                columns: [0, 1, 2, 3, 4, 5, 6, 7, 8]
            }
        },
        {
            extend: 'print',
            text: '<i class="fas fa-print me-1"></i> Print',
            className: 'btn btn-sm btn-secondary',
            exportOptions: {
                columns: [0, 1, 2, 3, 4, 5, 6, 7, 8]
            }
        }
    ];
    
    // Initialize DataTable with options
    window.dataTable = $('#sessionsTable').DataTable({
        responsive: true,
        ordering: true,
        order: [[0, 'asc']],
        searching: true,
        pageLength: 10,
        lengthMenu: [5, 10, 25, 50],
        dom: 'Bfrtip',
        buttons: buttons,
        language: {
            info: "Showing _START_ to _END_ of _TOTAL_ sessions",
            lengthMenu: "Show _MENU_ sessions per page",
            search: "", // Hide the search label
            searchPlaceholder: "Search sessions...",
            paginate: {
                first: '<i class="fas fa-angle-double-left"></i>',
                previous: '<i class="fas fa-angle-left"></i>',
                next: '<i class="fas fa-angle-right"></i>',
                last: '<i class="fas fa-angle-double-right"></i>'
            }
        }
    });
    
    // Hide the default buttons and use our custom buttons
    $('.dt-buttons').hide();
    
    // Hide the default search box
    $('.dataTables_filter').hide();
    
    // Connect custom export buttons to DataTables functions
    document.getElementById('exportExcel').addEventListener('click', function(e) {
        e.preventDefault();
        window.dataTable.button('.buttons-excel').trigger();
    });
    
    document.getElementById('exportCSV').addEventListener('click', function(e) {
        e.preventDefault();
        window.dataTable.button('.buttons-csv').trigger();
    });
    
    document.getElementById('exportPDF').addEventListener('click', function(e) {
        e.preventDefault();
        window.dataTable.button('.buttons-pdf').trigger();
    });
}

/**
 * Initialize notifications system
 */
function initializeNotifications() {
    // Sample notifications data - in a real application this would come from an API
    const notifications = [
        {
            id: 1,
            title: 'New user registered',
            message: 'John Smith has registered as a new user',
            icon: 'fas fa-user-plus',
            iconBg: 'primary',
            time: '10 minutes ago',
            unread: true
        },
        {
            id: 2,
            title: 'Session activity',
            message: '10 new sessions today',
            icon: 'fas fa-user-clock',
            iconBg: 'warning',
            time: '1 hour ago',
            unread: true
        },
        {
            id: 3,
            title: 'Security alert',
            message: 'Multiple login attempts detected',
            icon: 'fas fa-shield-alt',
            iconBg: 'info',
            time: '2 hours ago',
            unread: true
        },
        {
            id: 4,
            title: 'System update',
            message: 'Session management module updated',
            icon: 'fas fa-sync',
            iconBg: 'success',
            time: '1 day ago',
            unread: false
        }
    ];
    
    // Update notification count badge
    const unreadCount = notifications.filter(n => n.unread).length;
    const notificationCountElement = document.querySelector('.notification-count');
    if (notificationCountElement) {
        notificationCountElement.textContent = unreadCount.toString();
    }
    
    // Clear existing notifications
    const notificationList = document.getElementById('notificationList');
    if (!notificationList) return;
    
    notificationList.innerHTML = '';
    
    // Add notifications to the list
    notifications.forEach(notification => {
        const listItem = document.createElement('li');
        if (notification.unread) {
            listItem.classList.add('unread');
        }
        
        listItem.innerHTML = `
            <a href="#" data-id="${notification.id}">
                <div class="notification-icon bg-${notification.iconBg}">
                    <i class="${notification.icon}"></i>
                </div>
                <div class="notification-content">
                    <p><strong>${notification.title}</strong> - ${notification.message}</p>
                    <span class="notification-time">${notification.time}</span>
                </div>
            </a>
        `;
        
        notificationList.appendChild(listItem);
    });
    
    // Mark all read functionality
    const markAllReadBtn = document.querySelector('.mark-all-read');
    if (markAllReadBtn) {
        markAllReadBtn.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Mark all notifications as read
            document.querySelectorAll('#notificationList li.unread').forEach(item => {
                item.classList.remove('unread');
            });
            
            // Update badge
            const notificationCountElement = document.querySelector('.notification-count');
            if (notificationCountElement) {
                notificationCountElement.textContent = '0';
            }
            
            // Show toast
            showToast('All notifications marked as read', 'success');
        });
    }
    
    // Individual notification click
    document.querySelectorAll('#notificationList li a').forEach(item => {
        item.addEventListener('click', function(e) {
            e.preventDefault();
            const id = this.getAttribute('data-id');
            const parent = this.parentElement;
            
            // Mark as read
            if (parent.classList.contains('unread')) {
                parent.classList.remove('unread');
                
                // Update count
                const notificationCountElement = document.querySelector('.notification-count');
                if (notificationCountElement) {
                    const currentCount = parseInt(notificationCountElement.textContent);
                    notificationCountElement.textContent = (currentCount - 1).toString();
                }
            }
            
            // Show toast
            showToast(`Notification #${id} viewed`, 'info');
        });
    });
}

/**
 * Set up all event listeners for interaction
 */
function setupEventListeners() {
    // Refresh buttons
    const refreshButtons = document.querySelectorAll('#refreshSessions, #refreshSessionsBtn');
    refreshButtons.forEach(button => {
        if (button) {
            button.addEventListener('click', function() {
                refreshSessionData();
            });
        }
    });
    
    // Search input
    const searchInput = document.getElementById('searchInput');
    if (searchInput) {
        searchInput.addEventListener('keyup', function() {
            const searchText = this.value;
            if (window.dataTable) {
                window.dataTable.search(searchText).draw();
                
                // Highlight search terms if search value is present and longer than 2 chars
                if (searchText.length > 2) {
                    highlightSearchTerms(searchText);
                } else {
                    // Remove any existing highlights
                    $('#sessionsTable').find('span.search-highlight').each(function() {
                        $(this).replaceWith($(this).text());
                    });
                }
            }
        });
    }
    
    // Role filter
    const roleFilter = document.getElementById('roleFilter');
    if (roleFilter) {
        roleFilter.addEventListener('change', function() {
            applyFilters();
        });
    }
    
    // Status filter
    const statusFilter = document.getElementById('statusFilter');
    if (statusFilter) {
        statusFilter.addEventListener('change', function() {
            applyFilters();
        });
    }
    
    // Reset filters
    const resetFilters = document.getElementById('resetFilters');
    if (resetFilters) {
        resetFilters.addEventListener('click', function() {
            if (document.getElementById('searchInput')) {
                document.getElementById('searchInput').value = '';
            }
            if (document.getElementById('roleFilter')) {
                document.getElementById('roleFilter').value = '';
            }
            if (document.getElementById('statusFilter')) {
                document.getElementById('statusFilter').value = '';
            }
            
            // Remove custom filtering
            if (window.dataTable) {
                window.dataTable.search('').draw();
            }
            
            // Remove any existing highlights
            $('#sessionsTable').find('span.search-highlight').each(function() {
                $(this).replaceWith($(this).text());
            });
            
            showToast('Filters reset', 'info');
        });
    }
    
    // View session details
    document.querySelectorAll('.view-session').forEach(button => {
        button.addEventListener('click', function() {
            const sessionId = this.getAttribute('data-id');
            viewSessionDetails(sessionId);
        });
    });
    
    // Invalidate session
    document.querySelectorAll('.invalidate-session').forEach(button => {
        button.addEventListener('click', function() {
            const sessionId = this.getAttribute('data-id');
            showInvalidateConfirmation(sessionId);
        });
    });
    
    // Modal invalidate button
    const modalInvalidateBtn = document.getElementById('modalInvalidateBtn');
    if (modalInvalidateBtn) {
        modalInvalidateBtn.addEventListener('click', function() {
            const sessionId = this.getAttribute('data-id');
            invalidateSession(sessionId);
        });
    }
    
    // Confirm invalidate button
    const confirmInvalidateBtn = document.getElementById('confirmInvalidateBtn');
    if (confirmInvalidateBtn) {
        confirmInvalidateBtn.addEventListener('click', function() {
            const sessionId = this.getAttribute('data-id');
            invalidateSession(sessionId);
        });
    }
    
    // Invalidate all sessions button
    const invalidateAllBtn = document.getElementById('invalidateAllBtn');
    if (invalidateAllBtn) {
        invalidateAllBtn.addEventListener('click', function() {
            showInvalidateAllConfirmation();
        });
    }
    
    // Confirm invalidate all button
    const confirmInvalidateAllBtn = document.getElementById('confirmInvalidateAllBtn');
    if (confirmInvalidateAllBtn) {
        confirmInvalidateAllBtn.addEventListener('click', function() {
            invalidateAllSessions();
        });
    }
    
    // Invalidate all other sessions button
    const invalidateAllOtherBtn = document.getElementById('invalidateAllOtherBtn');
    if (invalidateAllOtherBtn) {
        invalidateAllOtherBtn.addEventListener('click', function() {
            showInvalidateAllOthersConfirmation();
        });
    }
    
    // Confirm invalidate all others button
    const confirmInvalidateAllOthersBtn = document.getElementById('confirmInvalidateAllOthersBtn');
    if (confirmInvalidateAllOthersBtn) {
        confirmInvalidateAllOthersBtn.addEventListener('click', function() {
            invalidateAllOtherSessions();
        });
    }
}

/**
 * Update your session timer display
 */
function updateYourSessionTimer() {
    // Get login time from the session
    const loginTimeElement = document.getElementById('yourSessionTime');
    if (!loginTimeElement) return;
    
    // Try to get login time from data attribute
    const loginTimeStr = loginTimeElement.getAttribute('data-login-time');
    if (!loginTimeStr) return;
    
    // Parse login time
    const loginTime = parseInt(loginTimeStr);
    if (isNaN(loginTime)) return;
    
    const now = Date.now();
    const diffMs = now - loginTime;
    
    // Calculate hours, minutes, seconds
    const hours = Math.floor(diffMs / (1000 * 60 * 60));
    const minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diffMs % (1000 * 60)) / 1000);
    
    // Format time string with leading zeros
    const timeString = 
        String(hours).padStart(2, '0') + ':' + 
        String(minutes).padStart(2, '0') + ':' + 
        String(seconds).padStart(2, '0');
    
    // Update the display
    loginTimeElement.textContent = timeString;
}

/**
 * Update date and time displays
 */
function updateDateTimeDisplay() {
    // Get the current date and time element
    const currentDateTimeElement = document.getElementById('current-datetime');
    const serverTimeElement = document.getElementById('serverTime');
    
    if (!currentDateTimeElement && !serverTimeElement) return;
    
    // Get current date/time with proper formatting
    const formattedDateTime = formatDateTime(new Date());
    
    // Update the displays
    if (currentDateTimeElement) {
        currentDateTimeElement.innerHTML = `<i class="far fa-calendar-alt"></i> ${formattedDateTime}`;
    }
    
    if (serverTimeElement) {
        serverTimeElement.textContent = formattedDateTime;
    }
}

/**
 * Apply filters to the DataTable
 */
function applyFilters() {
    if (!window.dataTable) return;
    
    const roleFilter = document.getElementById('roleFilter');
    const statusFilter = document.getElementById('statusFilter');
    
    if (!roleFilter || !statusFilter) return;
    
    const roleValue = roleFilter.value.toLowerCase();
    const statusValue = statusFilter.value.toLowerCase();
    
    // Custom filtering function
    $.fn.dataTable.ext.search.push(function(settings, data, dataIndex) {
        const row = window.dataTable.row(dataIndex).node();
        let passFilter = true;
        
        // Role filter
        if (roleValue && row.getAttribute('data-role') !== roleValue) {
            passFilter = false;
        }
        
        // Status filter
        if (statusValue && row.getAttribute('data-status') !== statusValue) {
            passFilter = false;
        }
        
        return passFilter;
    });
    
    // Apply filters
    window.dataTable.draw();
    
    // Remove the filter function to avoid affecting future searches
    $.fn.dataTable.ext.search.pop();
}

/**
 * Highlight search terms in the table
 * @param {string} searchTerm - The term to highlight
 */
function highlightSearchTerms(searchTerm) {
    // First remove any existing highlights
    $('#sessionsTable').find('span.search-highlight').each(function() {
        $(this).replaceWith($(this).text());
    });
    
    // Add new highlights - only apply to text content, not elements with children
    $('#sessionsTable tbody td').each(function() {
        const cell = $(this);
        if (cell.children().length === 0) { // Only highlight text cells
            const text = cell.text();
            const index = text.toLowerCase().indexOf(searchTerm.toLowerCase());
            if (index >= 0) {
                const before = text.substring(0, index);
                const highlight = text.substring(index, index + searchTerm.length);
                const after = text.substring(index + searchTerm.length);
                cell.html(before + '<span class="search-highlight">' + highlight + '</span>' + after);
            }
        }
    });
}

/**
 * Refresh session data from server
 */
function refreshSessionData() {
    // Show loading indicator
    showToast('Refreshing session data...', 'info');
    
    // Update last refresh time before reload
    updateLastRefreshTime();
    
    // Reload the current page to get fresh session data
    window.location.reload();
}

/**
 * View session details in modal
 * @param {string} sessionId - The ID of the session to view
 */
function viewSessionDetails(sessionId) {
    // Show the modal with loading indicator
    const sessionDetailsModal = document.getElementById('sessionDetailsModal');
    if (!sessionDetailsModal) return;
    
    const modal = new bootstrap.Modal(sessionDetailsModal);
    modal.show();
    
    // Set the modal invalidate button session ID
    const modalInvalidateBtn = document.getElementById('modalInvalidateBtn');
    if (modalInvalidateBtn) {
        modalInvalidateBtn.setAttribute('data-id', sessionId);
    }
    
    // Get current session ID to compare
    const currentSessionRow = document.querySelector('.current-user-session');
    const currentSessionId = currentSessionRow ? currentSessionRow.getAttribute('data-session-id') : '';
    const isCurrentSession = sessionId === currentSessionId;
    
    // Disable invalidate button if it's the current session
    if (modalInvalidateBtn) {
        modalInvalidateBtn.disabled = isCurrentSession;
    }
    
    // Try to fetch session details via AJAX
    try {
        fetch(`${contextPath}/ViewSessionDetailsServlet?sessionId=${sessionId}`)
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    displaySessionDetails(data.sessionInfo, isCurrentSession);
                } else {
                    const errorMessage = data.message || 'Failed to load session details';
                    const sessionDetailsBody = document.getElementById('sessionDetailsBody');
                    if (sessionDetailsBody) {
                        sessionDetailsBody.innerHTML = `
                            <div class="alert alert-warning">
                                <i class="fas fa-exclamation-triangle me-2"></i>
                                ${errorMessage}
                            </div>
                        `;
                    }
                    
                    // Try fallback method
                    fallbackSessionDetails(sessionId, isCurrentSession);
                }
            })
            .catch(error => {
                console.error('Error fetching session details:', error);
                
                // Try to extract from table as fallback
                fallbackSessionDetails(sessionId, isCurrentSession);
            });
    } catch (error) {
        console.error('Error in fetch operation:', error);
        fallbackSessionDetails(sessionId, isCurrentSession);
    }
}

/**
 * Display session details in the modal
 * @param {Object} session - Session information object
 * @param {boolean} isCurrentSession - Whether this is the current user's session
 */
function displaySessionDetails(session, isCurrentSession) {
    const sessionDetailsBody = document.getElementById('sessionDetailsBody');
    if (!sessionDetailsBody) return;
    
    // Format timestamps
    const loginTime = session.loginTimeFormatted || new Date(session.loginTime).toLocaleString();
    const lastActivity = session.lastActivityFormatted || new Date(session.lastActivityTime).toLocaleString();
    
    // Create HTML for the modal
    let html = `
        <div class="row session-details-row">
            <div class="col-md-6">
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-fingerprint me-2"></i>Session ID</div>
                    <div class="detail-value">${session.sessionId || 'Unknown'}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-user me-2"></i>Username</div>
                    <div class="detail-value">${session.username || 'Guest'}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-user-tag me-2"></i>Role</div>
                    <div class="detail-value">
                        <span class="badge ${getBadgeClassForRole(session.role)}">${formatRoleName(session.role) || 'Unknown'}</span>
                    </div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-id-card me-2"></i>User ID</div>
                    <div class="detail-value">${session.userId || 'N/A'}</div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-sign-in-alt me-2"></i>Login Time</div>
                    <div class="detail-value">${loginTime}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-clock me-2"></i>Last Activity</div>
                    <div class="detail-value">${lastActivity}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-hourglass-half me-2"></i>Session Duration</div>
                    <div class="detail-value">${session.duration || 'N/A'}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-network-wired me-2"></i>IP Address</div>
                    <div class="detail-value">${session.ipAddress || 'Unknown'}</div>
                </div>
            </div>
        </div>
        
        <hr>
        
        <div class="row session-details-row">
            <div class="col-md-6">
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-mobile-alt me-2"></i>Device Type</div>
                    <div class="detail-value">${session.deviceType || 'Unknown'}</div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-globe me-2"></i>Browser</div>
                    <div class="detail-value">${session.browser || 'Unknown'}</div>
                </div>
            </div>
        </div>
        
        <div class="mb-3">
            <div class="detail-label"><i class="fas fa-info-circle me-2"></i>User Agent</div>
            <div class="detail-value small text-muted">${session.userAgent || 'Unknown'}</div>
        </div>
        
        <hr>
        
        <div class="mb-3">
            <div class="detail-label"><i class="fas fa-shield-alt me-2"></i>Session Status</div>
            <div class="alert ${isCurrentSession ? 'alert-info' : 'alert-secondary'}">
                <i class="fas ${isCurrentSession ? 'fa-user-check' : 'fa-user'} me-2"></i>
                This session ${isCurrentSession ? 'is your current session' : 'belongs to another user'}.
                ${isCurrentSession ? '<div class="mt-2">You cannot invalidate your own session from here.</div>' : ''}
            </div>
        </div>
    `;
    
    // Update modal content
    sessionDetailsBody.innerHTML = html;
}

/**
 * Fallback method to extract session details from the table
 * @param {string} sessionId - The ID of the session
 * @param {boolean} isCurrentSession - Whether this is the current user's session
 */
function fallbackSessionDetails(sessionId, isCurrentSession) {
    const sessionDetailsBody = document.getElementById('sessionDetailsBody');
    if (!sessionDetailsBody) return;
    
    // Find the row with the matching session ID
    const row = document.querySelector(`tr[data-session-id="${sessionId}"]`);
    
    if (!row) {
        sessionDetailsBody.innerHTML = `
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle me-2"></i>
                Session not found.
            </div>
        `;
        return;
    }
    
    // Extract data from the row
    const cells = row.cells;
    if (!cells || cells.length < 9) {
        sessionDetailsBody.innerHTML = `
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-triangle me-2"></i>
                Invalid session data structure.
            </div>
        `;
        return;
    }
    
    const username = cells[2].textContent;
    const roleElement = cells[3].querySelector('.badge');
    const role = roleElement ? roleElement.textContent : 'Unknown';
    const loginTime = cells[4].textContent;
    const lastActivity = cells[5].textContent;
    const duration = cells[6].textContent.split('\n')[0].trim();
    const ipAddress = cells[7].textContent;
    const deviceType = cells[8] ? cells[8].textContent : 'Unknown';
    
    // Create HTML with extracted data
    let html = `
        <div class="row session-details-row">
            <div class="col-md-6">
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-fingerprint me-2"></i>Session ID</div>
                    <div class="detail-value">${sessionId}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-user me-2"></i>Username</div>
                    <div class="detail-value">${username}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-user-tag me-2"></i>Role</div>
                    <div class="detail-value">${role}</div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-sign-in-alt me-2"></i>Login Time</div>
                    <div class="detail-value">${loginTime}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-clock me-2"></i>Last Activity</div>
                    <div class="detail-value">${lastActivity}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-hourglass-half me-2"></i>Session Duration</div>
                    <div class="detail-value">${duration}</div>
                </div>
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-network-wired me-2"></i>IP Address</div>
                    <div class="detail-value">${ipAddress}</div>
                </div>
            </div>
        </div>
        
        <hr>
        
        <div class="row session-details-row">
            <div class="col-md-6">
                <div class="mb-3">
                    <div class="detail-label"><i class="fas fa-mobile-alt me-2"></i>Device Type</div>
                    <div class="detail-value">${deviceType}</div>
                </div>
            </div>
        </div>
        
        <hr>
        
        <div class="mb-3">
            <div class="detail-label"><i class="fas fa-shield-alt me-2"></i>Session Status</div>
            <div class="alert ${isCurrentSession ? 'alert-info' : 'alert-secondary'}">
                <i class="fas ${isCurrentSession ? 'fa-user-check' : 'fa-user'} me-2"></i>
                This session ${isCurrentSession ? 'is your current session' : 'belongs to another user'}.
                ${isCurrentSession ? '<div class="mt-2">You cannot invalidate your own session from here.</div>' : ''}
            </div>
        </div>
    `;
    
    // Update modal content
    sessionDetailsBody.innerHTML = html;
}

/**
 * Show confirmation modal for invalidating a session
 * @param {string} sessionId - The ID of the session to invalidate
 */
function showInvalidateConfirmation(sessionId) {
    // Find the session username
    const row = document.querySelector(`tr[data-session-id="${sessionId}"]`);
    if (!row) return;
    
    const username = row.cells[2].textContent || 'Unknown user';
    
    // Update modal content
    const modalBody = document.querySelector('#confirmInvalidateModal .modal-body');
    if (!modalBody) return;
    
    modalBody.innerHTML = `
        <p>Are you sure you want to invalidate the session for <strong>${username}</strong>?</p>
        <p>This will immediately log the user out of the system.</p>
        <div class="alert alert-warning">
            <i class="fas fa-info-circle me-2"></i>
            This action cannot be undone.
        </div>
    `;
    
    // Set the session ID on the confirm button
    const confirmInvalidateBtn = document.getElementById('confirmInvalidateBtn');
    if (confirmInvalidateBtn) {
        confirmInvalidateBtn.setAttribute('data-id', sessionId);
    }
    
    // Show the confirmation modal
    const modal = new bootstrap.Modal(document.getElementById('confirmInvalidateModal'));
    modal.show();
}

/**
 * Show confirmation modal for invalidating all sessions
 */
function showInvalidateAllConfirmation() {
    // Show the confirmation modal
    const modal = new bootstrap.Modal(document.getElementById('confirmInvalidateAllModal'));
    modal.show();
}

/**
 * Show confirmation modal for invalidating all other sessions
 */
function showInvalidateAllOthersConfirmation() {
    // Show the confirmation modal
    const modal = new bootstrap.Modal(document.getElementById('confirmInvalidateAllOthersModal'));
    modal.show();
}

/**
 * Invalidate a specific session
 * @param {string} sessionId - The ID of the session to invalidate
 */
function invalidateSession(sessionId) {
    // Close any open modals
    const detailsModal = bootstrap.Modal.getInstance(document.getElementById('sessionDetailsModal'));
    if (detailsModal) detailsModal.hide();
    
    const confirmModal = bootstrap.Modal.getInstance(document.getElementById('confirmInvalidateModal'));
    if (confirmModal) confirmModal.hide();
    
    // Show loading toast
    showToast('Invalidating session...', 'info');
    
    // Redirect to current page with action parameters
    window.location.href = `?action=invalidate&sessionId=${sessionId}`;
}

/**
 * Invalidate all sessions (including current one)
 */
function invalidateAllSessions() {
    // Close confirmation modal
    const confirmModal = bootstrap.Modal.getInstance(document.getElementById('confirmInvalidateAllModal'));
    if (confirmModal) confirmModal.hide();
    
    // Show loading toast
    showToast('Invalidating all sessions...', 'warning');
    
    // This is a severe action that will also log out the current admin
    // Confirm again
    const willProceed = confirm("WARNING: This will log you out too! Are you absolutely sure?");
    
    if (willProceed) {
        // Update last refresh time before redirect
        updateLastRefreshTime();
        
        // Redirect to a special servlet that invalidates all sessions
        window.location.href = `${contextPath}/InvalidateAllSessionsServlet?includeCurrentSession=true`;
    } else {
        showToast('Operation cancelled', 'info');
    }
}

/**
 * Invalidate all other sessions except current one
 */
function invalidateAllOtherSessions() {
    // Close confirmation modal
    const confirmModal = bootstrap.Modal.getInstance(document.getElementById('confirmInvalidateAllOthersModal'));
    if (confirmModal) confirmModal.hide();
    
    // Show loading toast
    showToast('Invalidating all other sessions...', 'warning');
    
    // Update last refresh time before redirect
    updateLastRefreshTime();
    
    // Redirect to invalidate all servlet with parameter to keep current session
    window.location.href = `${contextPath}/InvalidateAllSessionsServlet`;
}

/**
 * Display a toast notification
 * @param {string} message - The message to display
 * @param {string} type - The type of toast (success, error, warning, info)
 */
function showToast(message, type = 'info') {
    // Validate parameters
    if (!message) return;
    
    // Define colors based on type
    let backgroundColor;
    let icon;
    
    switch (type) {
        case 'success':
            backgroundColor = 'linear-gradient(to right, #28a745, #20c997)';
            icon = '<i class="fas fa-check-circle toastify-icon"></i>';
            break;
        case 'error':
            backgroundColor = 'linear-gradient(to right, #dc3545, #e74c3c)';
            icon = '<i class="fas fa-exclamation-circle toastify-icon"></i>';
            break;
        case 'warning':
            backgroundColor = 'linear-gradient(to right, #ffc107, #fd7e14)';
            icon = '<i class="fas fa-exclamation-triangle toastify-icon"></i>';
            break;
        case 'info':
        default:
            backgroundColor = 'linear-gradient(to right, #17a2b8, #138496)';
            icon = '<i class="fas fa-info-circle toastify-icon"></i>';
            break;
    }
    
    // Show the toast
    if (typeof Toastify === 'function') {
        Toastify({
            text: icon + message,
            duration: 3000,
            gravity: "top",
            position: "right",
            className: `toast-${type}`,
            style: {
                background: backgroundColor,
                boxShadow: "0 3px 10px rgba(0,0,0,0.2)",
            },
            escapeMarkup: false
        }).showToast();
    } else {
        console.log(`Toast (${type}): ${message}`);
    }
}

/**
 * Get the appropriate badge class for a role
 * @param {string} role - The user role
 * @return {string} The Bootstrap badge class
 */
function getBadgeClassForRole(role) {
    if (!role) return 'bg-secondary';
    
    role = String(role).toLowerCase();
    
    if (role === 'super_admin') return 'bg-purple';
    if (role === 'admin') return 'bg-danger';
    if (role === 'vendor') return 'bg-warning text-dark';
    if (role === 'user') return 'bg-info';
    
    return 'bg-secondary';
}

/**
 * Format a role name for display
 * @param {string} role - The user role
 * @return {string} Formatted role name
 */
function formatRoleName(role) {
    if (!role) return 'Unknown';
    
    role = String(role);
    
    if (role.toLowerCase() === 'super_admin') return 'Super Admin';
    if (role.toLowerCase() === 'admin') return 'Admin';
    
    // Capitalize first letter of each word
    return role.replace(/_/g, ' ')
        .replace(/\w\S*/g, function(txt) {
            return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
        });
}