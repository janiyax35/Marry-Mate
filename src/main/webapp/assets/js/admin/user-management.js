/**
 * User Management JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-05 12:32:46
 * Current User: IT24102137
 */

// Main execution when document is ready
$(document).ready(function() {
    // Initialize components
    initializeSidebar();
    initializeDropdowns();
    initializeModals();
    initializeDataTable();
    initializeDateRangePicker();
    initializeFormValidation();
    
    // Set up button event handlers
    setupButtonHandlers();
    
    // Load user data initially
    loadUsers();
});

/**
 * Initialize sidebar toggle functionality
 */
function initializeSidebar() {
    $('#sidebar-toggle').on('click', function() {
        $('.sidebar').toggleClass('sidebar-collapsed');
        $('.main-content').toggleClass('sidebar-collapsed');
    });
}

/**
 * Initialize dropdown menus
 */
function initializeDropdowns() {
    // Notification dropdown
    $('.notification-btn').on('click', function(e) {
        e.stopPropagation();
        $('.notification-dropdown').toggleClass('show');
        $('.profile-dropdown').removeClass('show');
    });
    
    // Profile dropdown
    $('.profile-btn').on('click', function(e) {
        e.stopPropagation();
        $('.profile-dropdown').toggleClass('show');
        $('.notification-dropdown').removeClass('show');
    });
    
    // Close dropdowns when clicking outside
    $(document).on('click', function() {
        $('.notification-dropdown, .profile-dropdown').removeClass('show');
    });
    
    // Prevent dropdown from closing when clicked inside
    $('.notification-dropdown, .profile-dropdown').on('click', function(e) {
        e.stopPropagation();
    });
}

/**
 * Initialize modal handling
 */
function initializeModals() {
    // Show modal overlay when any modal is shown
    $('.modal').on('show.bs.modal', function() {
        $('.modal-overlay').addClass('show');
    });
    
    // Hide modal overlay when all modals are hidden
    $('.modal').on('hidden.bs.modal', function() {
        if (!$('.modal.show').length) {
            $('.modal-overlay').removeClass('show');
        }
    });
    
    // Password reset checkbox toggles password fields
    $('#reset-password').on('change', function() {
        $('#password-reset-fields').toggleClass('d-none', !this.checked);
    });
    
    // Edit from view button
    $('#edit-from-view-btn').on('click', function() {
        $('#viewUserModal').modal('hide');
        const userId = $('#view-user-id').text().substr(4); // Remove "ID: " prefix
        populateEditUserForm(userId);
        $('#editUserModal').modal('show');
    });
}

/**
 * Initialize DataTables
 */
function initializeDataTable() {
    window.usersTable = $('#users-table').DataTable({
        columnDefs: [
            { targets: [0], width: "60px" },
            { targets: [7], width: "100px", orderable: false }
        ],
        order: [[5, 'desc']], // Sort by registration date by default
        language: {
            search: "",
            searchPlaceholder: "Search users...",
            paginate: {
                previous: "<i class='fas fa-chevron-left'></i>",
                next: "<i class='fas fa-chevron-right'></i>"
            }
        },
        dom: "<'row'<'col-md-6'l><'col-md-6'f>>" +
             "<'row'<'col-sm-12'tr>>" +
             "<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7'p>>",
        pageLength: 10,
        responsive: true,
        lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
        initComplete: function() {
            // Add custom class to DataTables elements
            $('.dataTables_filter input').addClass('form-control');
        }
    });
}

/**
 * Initialize date range picker
 */
function initializeDateRangePicker() {
    $('#date-range').daterangepicker({
        autoUpdateInput: false,
        locale: {
            cancelLabel: 'Clear',
            format: 'YYYY-MM-DD'
        },
        ranges: {
           'Today': [moment(), moment()],
           'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
           'Last 7 Days': [moment().subtract(6, 'days'), moment()],
           'Last 30 Days': [moment().subtract(29, 'days'), moment()],
           'This Month': [moment().startOf('month'), moment().endOf('month')],
           'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        }
    });

    $('#date-range').on('apply.daterangepicker', function(ev, picker) {
        $(this).val(picker.startDate.format('YYYY-MM-DD') + ' to ' + picker.endDate.format('YYYY-MM-DD'));
        filterUsers();
    });

    $('#date-range').on('cancel.daterangepicker', function() {
        $(this).val('');
        filterUsers();
    });
}

/**
 * Initialize form validation
 */
function initializeFormValidation() {
    // Add User Form Validation
    $('#add-user-form').on('submit', function(event) {
        event.preventDefault();
        
        const form = $(this)[0];
        if (!form.checkValidity()) {
            event.stopPropagation();
        } else if ($('#add-password').val() !== $('#add-confirm-password').val()) {
            $('#add-confirm-password').addClass('is-invalid');
            event.stopPropagation();
        } else {
            createUser();
        }
        
        $(this).addClass('was-validated');
    });
    
    // Password confirmation validation
    $('#add-confirm-password').on('keyup', function() {
        if ($('#add-password').val() === $(this).val()) {
            $(this).removeClass('is-invalid');
        } else {
            $(this).addClass('is-invalid');
        }
    });
    
    // Edit User Form Validation
    $('#edit-user-form').on('submit', function(event) {
        event.preventDefault();
        
        const form = $(this)[0];
        if (!form.checkValidity()) {
            event.stopPropagation();
        } else if ($('#reset-password').is(':checked') && $('#new-password').val() !== $('#confirm-password').val()) {
            $('#confirm-password').addClass('is-invalid');
            event.stopPropagation();
        } else {
            updateUser();
        }
        
        $(this).addClass('was-validated');
    });
    
    // Password confirmation validation for edit form
    $('#confirm-password').on('keyup', function() {
        if ($('#new-password').val() === $(this).val()) {
            $(this).removeClass('is-invalid');
        } else {
            $(this).addClass('is-invalid');
        }
    });
}

/**
 * Set up button event handlers
 */
function setupButtonHandlers() {
    // Filter button click
    $('#search-btn').on('click', function() {
        filterUsers();
    });
    
    // Reset filters button click
    $('#reset-filters').on('click', function() {
        $('#status-filter').val('');
        $('#date-range').val('');
        $('#search-users').val('');
        filterUsers();
    });
    
    // Refresh users button click
    $('#refresh-users').on('click', function() {
        loadUsers();
    });
    
    // Add user button click
    $('#add-user-btn').on('click', function() {
        $('#addUserModal').modal('show');
    });
    
    // Create user button click
    $('#create-user-btn').on('click', function() {
        $('#add-user-form').submit();
    });
    
    // Save user changes button click
    $('#save-user-btn').on('click', function() {
        $('#edit-user-form').submit();
    });
    
    // Delete user confirmation button click
    $('#confirm-delete-btn').on('click', function() {
        deleteUser($('#delete-user-id').val());
    });
    
    // Export button clicks
    $('.export-option').on('click', function(e) {
        e.preventDefault();
        exportUsers($(this).data('format'));
    });
}

/**
 * Load user data from the server
 */
function loadUsers() {
    // Show loading indicator
    const spinner = '<div class="text-center p-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div><p class="mt-3">Loading users...</p></div>';
    $('#users-table tbody').html('<tr><td colspan="8">' + spinner + '</td></tr>');
    
    // Make AJAX request
    $.ajax({
        url: contextPath + '/UserManagementServlet',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            populateUsersTable(data);
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load users');
        }
    });
}

/**
 * Populate the users table with data
 * @param {Array} users - The array of user objects
 */
function populateUsersTable(users) {
    const table = window.usersTable;
    
    // Clear existing data
    table.clear();
    
    // Add rows
    users.forEach(user => {
        table.row.add([
            user.userId,
            getUserNameCell(user),
            user.email,
            formatRole(user.role),
            getStatusBadge(user.accountStatus),
            formatDate(user.registrationDate),
            formatDate(user.lastLogin),
            getActionButtons(user.userId)
        ]);
    });
    
    // Draw the table
    table.draw();
    
    // Set up action button handlers
    setupActionButtons();
}

/**
 * Create HTML for user name cell with avatar
 * @param {Object} user - User object
 * @return {String} - HTML for the user name cell
 */
function getUserNameCell(user) {
    const avatarUrl = user.profilePictureURL || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(user.fullName) + '&background=random&color=fff';
    
    return `<div class="d-flex align-items-center">
                <div class="avatar avatar-sm me-3">
                    <img src="${avatarUrl}" alt="${user.fullName}">
                </div>
                <div>
                    <p class="mb-0 fw-medium">${user.fullName}</p>
                    <small class="text-muted">@${user.username}</small>
                </div>
            </div>`;
}

/**
 * Format role text
 * @param {String} role - User role
 * @return {String} - Formatted role
 */
function formatRole(role) {
    if (role === 'admin') return '<span class="badge bg-danger">Admin</span>';
    if (role === 'vendor') return '<span class="badge bg-primary">Vendor</span>';
    return '<span class="badge bg-info">User</span>';
}

/**
 * Create status badge HTML
 * @param {String} status - User account status
 * @return {String} - HTML for the status badge
 */
function getStatusBadge(status) {
    let badgeClass, icon;
    
    switch(status) {
        case 'active':
            badgeClass = 'status-active';
            icon = 'check-circle';
            break;
        case 'inactive':
            badgeClass = 'status-inactive';
            icon = 'circle';
            break;
        case 'suspended':
            badgeClass = 'status-suspended';
            icon = 'ban';
            break;
        case 'pending':
            badgeClass = 'status-pending';
            icon = 'clock';
            break;
        default:
            badgeClass = 'status-inactive';
            icon = 'question-circle';
    }
    
    return `<span class="status-badge ${badgeClass}"><i class="fas fa-${icon}"></i> ${status.charAt(0).toUpperCase() + status.slice(1)}</span>`;
}

/**
 * Create action buttons HTML
 * @param {String} userId - User ID
 * @return {String} - HTML for action buttons
 */
function getActionButtons(userId) {
    return `<div class="user-actions">
                <div class="dropdown">
                    <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <div class="dropdown-menu dropdown-menu-end">
                        <a class="dropdown-item view-user" href="#" data-user-id="${userId}">
                            <i class="fas fa-eye"></i> View
                        </a>
                        <a class="dropdown-item edit-user" href="#" data-user-id="${userId}">
                            <i class="fas fa-edit"></i> Edit
                        </a>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item text-danger delete-user" href="#" data-user-id="${userId}">
                            <i class="fas fa-trash-alt"></i> Delete
                        </a>
                    </div>
                </div>
            </div>`;
}

/**
 * Format date for display
 * @param {String} dateString - Date string
 * @return {String} - Formatted date
 */
function formatDate(dateString) {
    if (!dateString) return '—';
    
    // Replace with your date formatting logic
    return dateString;
}

/**
 * Set up action button event handlers
 */
function setupActionButtons() {
    // View user button click
    $('.view-user').on('click', function(e) {
        e.preventDefault();
        const userId = $(this).data('user-id');
        viewUser(userId);
    });
    
    // Edit user button click
    $('.edit-user').on('click', function(e) {
        e.preventDefault();
        const userId = $(this).data('user-id');
        populateEditUserForm(userId);
    });
    
    // Delete user button click
    $('.delete-user').on('click', function(e) {
        e.preventDefault();
        const userId = $(this).data('user-id');
        confirmDeleteUser(userId);
    });
}

/**
 * View user details
 * @param {String} userId - User ID
 */
function viewUser(userId) {
    // Get user data
    $.ajax({
        url: contextPath + '/UserManagementServlet?userId=' + userId,
        type: 'GET',
        dataType: 'json',
        success: function(user) {
            // Populate user details in the view modal
            $('#view-profile-picture').attr('src', user.profilePictureURL || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(user.fullName) + '&background=random&color=fff');
            $('#view-full-name').text(user.fullName);
            $('#view-user-id').text('ID: ' + user.userId);
            $('#view-username').text(user.username);
            $('#view-email').text(user.email);
            $('#view-phone-number').text(user.phoneNumber || '—');
            $('#view-address').text(user.address || '—');
            $('#view-role').text(user.role.charAt(0).toUpperCase() + user.role.slice(1));
            $('#view-registration-date').text(formatDate(user.registrationDate));
            $('#view-last-login').text(formatDate(user.lastLogin));
            $('#view-failed-login-attempts').text(user.failedLoginAttempts);
            
            // Set status badge
            $('#view-status-badge').removeClass().addClass('badge rounded-pill');
            switch(user.accountStatus) {
                case 'active':
                    $('#view-status-badge').addClass('bg-success').html('<i class="fas fa-check-circle me-1"></i> Active');
                    break;
                case 'inactive':
                    $('#view-status-badge').addClass('bg-secondary').html('<i class="fas fa-circle me-1"></i> Inactive');
                    break;
                case 'suspended':
                    $('#view-status-badge').addClass('bg-danger').html('<i class="fas fa-ban me-1"></i> Suspended');
                    break;
                case 'pending':
                    $('#view-status-badge').addClass('bg-warning text-dark').html('<i class="fas fa-clock me-1"></i> Pending');
                    break;
            }
            
            // Sample activity log (would be replaced by real data in a production app)
            const activityLog = `
                <tr>
                    <td>2025-05-05 10:30:15</td>
                    <td>Login</td>
                    <td>Successful login from 192.168.1.105</td>
                </tr>
                <tr>
                    <td>2025-05-04 14:22:36</td>
                    <td>Profile Update</td>
                    <td>Updated profile information</td>
                </tr>
                <tr>
                    <td>2025-05-03 09:15:42</td>
                    <td>Login</td>
                    <td>Successful login from 192.168.1.105</td>
                </tr>
            `;
            
            $('#view-activity-log').html(activityLog);
            
            // Show the modal
            $('#viewUserModal').modal('show');
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load user details');
        }
    });
}

/**
 * Populate the edit user form
 * @param {String} userId - User ID
 */
function populateEditUserForm(userId) {
    // Get user data
    $.ajax({
        url: contextPath + '/UserManagementServlet?userId=' + userId,
        type: 'GET',
        dataType: 'json',
        success: function(user) {
            // Populate form fields
            $('#edit-user-id').val(user.userId);
            $('#edit-username').val(user.username);
            $('#edit-email').val(user.email);
            $('#edit-full-name').val(user.fullName);
            $('#edit-phone-number').val(user.phoneNumber || '');
            $('#edit-address').val(user.address || '');
            $('#edit-role').val(user.role);
            $('#edit-status').val(user.accountStatus);
            $('#edit-profile-picture').val(user.profilePictureURL || '');
            
            // Reset password fields
            $('#reset-password').prop('checked', false);
            $('#password-reset-fields').addClass('d-none');
            $('#new-password').val('');
            $('#confirm-password').val('');
            
            // Update modal title and show
            $('#editUserModalTitle').text('Edit User: ' + user.fullName);
            $('#editUserModal').modal('show');
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load user details');
        }
    });
}

/**
 * Confirm user deletion
 * @param {String} userId - User ID
 */
function confirmDeleteUser(userId) {
    // Get user name
    $.ajax({
        url: contextPath + '/UserManagementServlet?userId=' + userId,
        type: 'GET',
        dataType: 'json',
        success: function(user) {
            $('#delete-user-id').val(userId);
            $('#delete-user-name').text(user.fullName + ' (' + user.username + ')');
            $('#deleteUserModal').modal('show');
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load user details');
        }
    });
}

/**
 * Create a new user
 */
function createUser() {
    const formData = {
        username: $('#add-username').val(),
        email: $('#add-email').val(),
        password: $('#add-password').val(),
        fullName: $('#add-full-name').val(),
        phoneNumber: $('#add-phone-number').val(),
        address: $('#add-address').val(),
        role: $('#add-role').val(),
        accountStatus: $('#add-status').val()
    };
    
    $.ajax({
        url: contextPath + '/UserManagementServlet',
        type: 'POST',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify(formData),
        success: function(response) {
            $('#addUserModal').modal('hide');
            showToast('Success', 'User created successfully', 'success');
            loadUsers();
            resetAddUserForm();
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to create user');
        }
    });
}

/**
 * Update an existing user
 */
function updateUser() {
    const userId = $('#edit-user-id').val();
    
    const formData = {
        userId: userId,
        username: $('#edit-username').val(),
        email: $('#edit-email').val(),
        fullName: $('#edit-full-name').val(),
        phoneNumber: $('#edit-phone-number').val(),
        address: $('#edit-address').val(),
        role: $('#edit-role').val(),
        accountStatus: $('#edit-status').val(),
        profilePictureURL: $('#edit-profile-picture').val()
    };
    
    // Add password if being reset
    if ($('#reset-password').is(':checked')) {
        formData.password = $('#new-password').val();
    }
    
    $.ajax({
        url: contextPath + '/UserManagementServlet',
        type: 'PUT',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify(formData),
        success: function(response) {
            $('#editUserModal').modal('hide');
            showToast('Success', 'User updated successfully', 'success');
            loadUsers();
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to update user');
        }
    });
}

/**
 * Delete a user
 * @param {String} userId - User ID
 */
function deleteUser(userId) {
    $.ajax({
        url: contextPath + '/UserManagementServlet?userId=' + userId,
        type: 'DELETE',
        success: function(response) {
            $('#deleteUserModal').modal('hide');
            showToast('Success', 'User deleted successfully', 'success');
            loadUsers();
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to delete user');
        }
    });
}

/**
 * Filter users based on search criteria
 */
function filterUsers() {
    const status = $('#status-filter').val();
    const dateRange = $('#date-range').val();
    const searchTerm = $('#search-users').val();
    
    // Prepare filter parameters
    let params = {};
    if (status) params.status = status;
    if (dateRange) params.dateRange = dateRange;
    if (searchTerm) params.search = searchTerm;
    
    // Convert params object to query string
    const queryString = Object.keys(params).map(key => key + '=' + encodeURIComponent(params[key])).join('&');
    
    // Make AJAX request with filters
    $.ajax({
		        url: contextPath + '/UserManagementServlet' + (queryString ? '?' + queryString : ''),
		        type: 'GET',
		        dataType: 'json',
		        success: function(data) {
		            populateUsersTable(data);
		        },
		        error: function(xhr, status, error) {
		            handleAjaxError(xhr, 'Failed to filter users');
		        }
		    });
		}

		/**
		 * Export users in the selected format
		 * @param {String} format - Export format (excel, csv, pdf)
		 */
		function exportUsers(format) {
		    // Get current filters
		    const status = $('#status-filter').val();
		    const dateRange = $('#date-range').val();
		    const searchTerm = $('#search-users').val();
		    
		    // Prepare export parameters
		    let params = { format: format };
		    if (status) params.status = status;
		    if (dateRange) params.dateRange = dateRange;
		    if (searchTerm) params.search = searchTerm;
		    
		    // Convert params object to query string
		    const queryString = Object.keys(params).map(key => key + '=' + encodeURIComponent(params[key])).join('&');
		    
		    // Redirect to export URL (will trigger file download)
		    window.location.href = contextPath + '/UserManagementServlet/export?' + queryString;
		}

		/**
		 * Reset the add user form
		 */
		function resetAddUserForm() {
		    $('#add-user-form')[0].reset();
		    $('#add-user-form').removeClass('was-validated');
		}

		/**
		 * Handle AJAX errors
		 * @param {Object} xhr - XHR object
		 * @param {String} defaultMessage - Default error message
		 */
		function handleAjaxError(xhr, defaultMessage) {
		    let errorMessage = defaultMessage;
		    
		    try {
		        const response = JSON.parse(xhr.responseText);
		        if (response.message) {
		            errorMessage = response.message;
		        }
		    } catch (e) {
		        // Use default message if parsing fails
		    }
		    
		    showToast('Error', errorMessage, 'error');
		}

		/**
		 * Display a toast notification
		 * @param {String} title - Toast title
		 * @param {String} message - Toast message
		 * @param {String} type - Toast type (success, error, warning, info)
		 */
		function showToast(title, message, type) {
		    // Define toast icon and color based on type
		    let icon, background;
		    
		    switch (type) {
		        case 'success':
		            icon = 'success';
		            background = '#2ecc71';
		            break;
		        case 'error':
		            icon = 'error';
		            background = '#e74c3c';
		            break;
		        case 'warning':
		            icon = 'warning';
		            background = '#f39c12';
		            break;
		        case 'info':
		            icon = 'info';
		            background = '#3498db';
		            break;
		        default:
		            icon = 'info';
		            background = '#3498db';
		    }
		    
		    // Use SweetAlert2 for toast
		    Swal.mixin({
		        toast: true,
		        position: 'top-end',
		        showConfirmButton: false,
		        timer: 3000,
		        timerProgressBar: true,
		        didOpen: (toast) => {
		            toast.addEventListener('mouseenter', Swal.stopTimer);
		            toast.addEventListener('mouseleave', Swal.resumeTimer);
		        }
		    }).fire({
		        icon: icon,
		        title: title,
		        text: message,
		        background: background,
		        color: '#ffffff',
		        iconColor: '#ffffff'
		    });
		}

		/**
		 * Set the context path for AJAX requests
		 * This should be set in the JSP file before including this script
		 */
		const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/admin'));
        