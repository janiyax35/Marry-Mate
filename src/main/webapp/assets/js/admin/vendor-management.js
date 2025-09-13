/**
 * Vendor Management JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-18 18:08:31
 * Current User: IT24102137
 */

// Main execution when document is ready
$(document).ready(function() {
    console.log("Document ready - initializing vendor management");
    
    // Ensure contextPath is defined
    if (typeof contextPath === 'undefined') {
        // Try to determine contextPath from URL if not defined
        window.contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/admin'));
        console.log("Context path auto-detected:", contextPath);
    }
    
    try {
        // Initialize components
        initializeSidebar();
        initializeDropdowns();
        initializeModals();
        initializeDataTable();
        initializeDateRangePicker();
        initializeFormValidation();
        initializeCategoryMultiSelect();
        
        // Set up button event handlers
        setupButtonHandlers();
        
        // Load vendor data initially
        loadVendors();
    } catch (error) {
        console.error("Error during initialization:", error);
        alert("Error initializing the page: " + error.message);
    }
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
        $('#viewVendorModal').modal('hide');
        const vendorId = $('#view-vendor-id').text().substr(4); // Remove "ID: " prefix
        populateEditVendorForm(vendorId);
        $('#editVendorModal').modal('show');
    });
}

/**
 * Initialize DataTables
 */
function initializeDataTable() {
    try {
        console.log("Initializing DataTable");
        
        if ($.fn.DataTable.isDataTable('#vendors-table')) {
            console.log("DataTable already initialized, destroying previous instance");
            $('#vendors-table').DataTable().destroy();
        }
        
        window.vendorsTable = $('#vendors-table').DataTable({
            columnDefs: [
                { targets: [0], width: "60px" },
                { targets: [8], width: "100px", orderable: false }
            ],
            order: [[7, 'desc']], // Sort by member since date by default
            language: {
                search: "",
                searchPlaceholder: "Search vendors...",
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
        
        console.log("DataTable initialization complete");
    } catch (error) {
        console.error("Error initializing DataTable:", error);
        // Fallback to basic table
        alert("Error setting up the vendors table. Will use basic functionality.");
    }
}

/**
 * Initialize date range picker
 */
function initializeDateRangePicker() {
    try {
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
            filterVendors();
        });
    
        $('#date-range').on('cancel.daterangepicker', function() {
            $(this).val('');
            filterVendors();
        });
    } catch (error) {
        console.error("Error initializing date range picker:", error);
    }
}

/**
 * Initialize category multi-select handling
 */
function initializeCategoryMultiSelect() {
    try {
        // Add Bootstrap classes to multi-select
        $('#edit-categories, #add-categories').addClass('form-select');
    } catch (error) {
        console.error("Error initializing category multi-select:", error);
    }
}

/**
 * Initialize form validation
 */
function initializeFormValidation() {
    // Add Vendor Form Validation
    $('#add-vendor-form').on('submit', function(event) {
        event.preventDefault();
        
        const form = $(this)[0];
        if (!form.checkValidity()) {
            event.stopPropagation();
        } else if ($('#add-password').val() !== $('#add-confirm-password').val()) {
            $('#add-confirm-password').addClass('is-invalid');
            event.stopPropagation();
        } else {
            createVendor();
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
    
    // Edit Vendor Form Validation
    $('#edit-vendor-form').on('submit', function(event) {
        event.preventDefault();
        
        const form = $(this)[0];
        if (!form.checkValidity()) {
            event.stopPropagation();
        } else if ($('#reset-password').is(':checked') && $('#new-password').val() !== $('#confirm-password').val()) {
            $('#confirm-password').addClass('is-invalid');
            event.stopPropagation();
        } else {
            updateVendor();
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
        filterVendors();
    });
    
    // Reset filters button click
    $('#reset-filters').on('click', function() {
        $('#status-filter').val('');
        $('#category-filter').val('');
        $('#date-range').val('');
        $('#search-vendors').val('');
        filterVendors();
    });
    
    // Refresh vendors button click
    $('#refresh-vendors').on('click', function() {
        loadVendors();
    });
    
    // Add vendor button click
    $('#add-vendor-btn').on('click', function() {
        $('#addVendorModal').modal('show');
    });
    
    // Create vendor button click
    $('#create-vendor-btn').on('click', function() {
        $('#add-vendor-form').submit();
    });
    
    // Save vendor changes button click
    $('#save-vendor-btn').on('click', function() {
        $('#edit-vendor-form').submit();
    });
    
    // Delete vendor confirmation button click
    $('#confirm-delete-btn').on('click', function() {
        deleteVendor($('#delete-vendor-id').val());
    });
    
    // Export button clicks
    $('.export-option').on('click', function(e) {
        e.preventDefault();
        exportVendors($(this).data('format'));
    });
}

/**
 * Load vendor data from the server
 */
function loadVendors() {
    console.log("Loading vendors from server, using context path:", contextPath);
    
    // Show loading indicator
    const spinner = '<div class="text-center p-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div><p class="mt-3">Loading vendors...</p></div>';
    $('#vendors-table tbody').html('<tr><td colspan="9">' + spinner + '</td></tr>');
    
    // Make AJAX request
    $.ajax({
        url: contextPath + '/VendorManagementServlet',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            console.log("Vendors loaded successfully:", data);
            populateVendorsTable(data);
        },
        error: function(xhr, status, error) {
            console.error("Error loading vendors:", error);
            console.error("Server response:", xhr.responseText);
            handleAjaxError(xhr, 'Failed to load vendors');
            
            // Emergency fallback - show the raw response if possible
            try {
                let errorContent = '<tr><td colspan="9" class="text-danger">';
                errorContent += '<p><strong>Error loading vendors:</strong> ' + error + '</p>';
                if (xhr.responseText) {
                    errorContent += '<p>Server response:</p>';
                    errorContent += '<pre style="max-height: 200px; overflow: auto;">' + xhr.responseText + '</pre>';
                }
                errorContent += '</td></tr>';
                $('#vendors-table tbody').html(errorContent);
            } catch (e) {
                console.error("Error displaying error message:", e);
            }
        }
    });
}

/**
 * Populate the vendors table with data
 * @param {Array} vendors - The array of vendor objects
 */
function populateVendorsTable(vendors) {
    console.log("Populating table with vendors:", vendors);
    
    try {
        // Use the global reference to the DataTable
        if (!window.vendorsTable) {
            console.error("DataTable not initialized!");
            initializeDataTable(); // Try to initialize again
        }
        
        const table = window.vendorsTable;
        
        // Clear existing data
        table.clear();
        
        if (!vendors || vendors.length === 0) {
            console.log("No vendors to display");
            table.draw();
            return;
        }
        
        // Add rows
        for (let i = 0; i < vendors.length; i++) {
            const vendor = vendors[i];
            console.log("Processing vendor:", vendor.userId);
            
            try {
                table.row.add([
                    vendor.userId || 'N/A',
                    getVendorNameCell(vendor),
                    vendor.businessName || 'N/A',
                    vendor.email || 'N/A',
                    getCategoriesBadges(vendor.categories),
                    getRatingStars(vendor.rating, vendor.reviewCount),
                    getStatusBadge(vendor.status),
                    formatDate(vendor.memberSince),
                    getActionButtons(vendor.userId)
                ]);
            } catch (rowError) {
                console.error("Error adding row for vendor:", vendor.userId, rowError);
            }
        }
        
        // Draw the table
        table.draw();
        
        // Set up action button handlers
        setupActionButtons();
        
        console.log("Table population complete");
    } catch (error) {
        console.error("Error populating vendors table:", error);
        
        // Fallback to basic table rendering
        try {
            console.log("Using fallback table rendering");
            let tableHtml = '';
            
            vendors.forEach(vendor => {
                tableHtml += '<tr>';
                tableHtml += '<td>' + (vendor.userId || 'N/A') + '</td>';
                tableHtml += '<td>' + (vendor.contactName || 'N/A') + '</td>';
                tableHtml += '<td>' + (vendor.businessName || 'N/A') + '</td>';
                tableHtml += '<td>' + (vendor.email || 'N/A') + '</td>';
                tableHtml += '<td>' + (vendor.categories ? vendor.categories.join(', ') : 'N/A') + '</td>';
                tableHtml += '<td>' + (vendor.rating || '0') + '</td>';
                tableHtml += '<td>' + (vendor.status || 'N/A') + '</td>';
                tableHtml += '<td>' + (vendor.memberSince || 'N/A') + '</td>';
                tableHtml += '<td><button class="btn btn-sm btn-primary view-vendor" data-vendor-id="' + vendor.userId + '">View</button></td>';
                tableHtml += '</tr>';
            });
            
            $('#vendors-table tbody').html(tableHtml);
            setupActionButtons();
        } catch (fallbackError) {
            console.error("Fallback rendering failed:", fallbackError);
            $('#vendors-table tbody').html('<tr><td colspan="9" class="text-danger">Error displaying vendor data. Please try refreshing the page.</td></tr>');
        }
    }
}

/**
 * Create HTML for vendor name cell with avatar
 * @param {Object} vendor - Vendor object
 * @return {String} - HTML for the vendor name cell
 */
function getVendorNameCell(vendor) {
    try {
        const avatarUrl = vendor.profilePictureUrl || '/assets/images/vendors/default-vendor.jpg';
        const contactName = vendor.contactName || 'Unknown';
        const username = vendor.username || 'N/A';
        
        return `<div class="d-flex align-items-center">
                    <div class="avatar avatar-sm me-3">
                        <img src="${avatarUrl}" alt="${contactName}" onerror="this.src='/assets/images/vendors/default-vendor.jpg';">
                    </div>
                    <div>
                        <p class="mb-0 fw-medium">${contactName}</p>
                        <small class="text-muted">@${username}</small>
                    </div>
                </div>`;
    } catch (error) {
        console.error("Error creating vendor name cell:", error);
        return `<div>Error: Could not display vendor</div>`;
    }
}

/**
 * Create HTML for category badges
 * @param {Array} categories - List of categories
 * @return {String} - HTML for the category badges
 */
function getCategoriesBadges(categories) {
    try {
        if (!categories || categories.length === 0) {
            return '<span class="text-muted">—</span>';
        }
        
        const badges = categories.slice(0, 2).map(category => {
            const displayName = category.charAt(0).toUpperCase() + category.slice(1);
            return `<span class="category-tag">${displayName}</span>`;
        }).join('');
        
        // Add count badge if there are more categories
        const more = categories.length > 2 ? `<span class="category-tag">+${categories.length - 2}</span>` : '';
        
        return `<div class="category-tags">${badges}${more}</div>`;
    } catch (error) {
        console.error("Error creating category badges:", error);
        return '<span class="text-muted">—</span>';
    }
}

/**
 * Create HTML for rating stars
 * @param {Number} rating - Rating value (0-5)
 * @param {Number} reviewCount - Number of reviews
 * @return {String} - HTML for the rating stars
 */
function getRatingStars(rating, reviewCount) {
    try {
        if (!rating) {
            return '<span class="text-muted">No ratings</span>';
        }
        
        rating = parseFloat(rating) || 0;
        reviewCount = parseInt(reviewCount) || 0;
        
        const roundedRating = Math.round(rating * 2) / 2; // Round to nearest 0.5
        let stars = '';
        
        // Create full and half stars
        for (let i = 1; i <= 5; i++) {
            if (i <= roundedRating) {
                stars += '<i class="fas fa-star star"></i>';
            } else if (i - 0.5 === roundedRating) {
                stars += '<i class="fas fa-star-half-alt star"></i>';
            } else {
                stars += '<i class="far fa-star star"></i>';
            }
        }
        
        return `<div class="vendor-rating">
                    <div class="stars">${stars}</div>
                    <span class="ms-1">${rating.toFixed(1)} (${reviewCount})</span>
                </div>`;
    } catch (error) {
        console.error("Error creating rating stars:", error);
        return '<span class="text-muted">—</span>';
    }
}

/**
 * Create status badge HTML
 * @param {String} status - Vendor account status
 * @return {String} - HTML for the status badge
 */
function getStatusBadge(status) {
    try {
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
                status = 'Unknown';
        }
        
        return `<span class="status-badge ${badgeClass}"><i class="fas fa-${icon}"></i> ${status.charAt(0).toUpperCase() + status.slice(1)}</span>`;
    } catch (error) {
        console.error("Error creating status badge:", error);
        return '<span class="text-muted">—</span>';
    }
}

/**
 * Create action buttons HTML
 * @param {String} vendorId - Vendor ID
 * @return {String} - HTML for action buttons
 */
function getActionButtons(vendorId) {
    try {
        return `<div class="vendor-actions">
                    <div class="dropdown">
                        <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            <i class="fas fa-ellipsis-v"></i>
                        </button>
                        <div class="dropdown-menu dropdown-menu-end">
                            <a class="dropdown-item view-vendor" href="#" data-vendor-id="${vendorId}">
                                <i class="fas fa-eye"></i> View
                            </a>
                            <a class="dropdown-item edit-vendor" href="#" data-vendor-id="${vendorId}">
                                <i class="fas fa-edit"></i> Edit
                            </a>
                            <div class="dropdown-divider"></div>
                            <a class="dropdown-item text-danger delete-vendor" href="#" data-vendor-id="${vendorId}">
                                <i class="fas fa-trash-alt"></i> Delete
                            </a>
                        </div>
                    </div>
                </div>`;
    } catch (error) {
        console.error("Error creating action buttons:", error);
        return `<button class="btn btn-sm btn-primary view-vendor" data-vendor-id="${vendorId}">View</button>`;
    }
}

/**
 * Format date for display
 * @param {String} dateString - Date string
 * @return {String} - Formatted date
 */
function formatDate(dateString) {
    if (!dateString) return '—';
    
    try {
        // If date contains time part, extract just the date
        if (dateString.includes(' ')) {
            dateString = dateString.split(' ')[0];
        }
        
        return dateString;
    } catch (error) {
        console.error("Error formatting date:", error);
        return dateString || '—';
    }
}

/**
 * Set up action button event handlers
 */
function setupActionButtons() {
    try {
        // View vendor button click
        $('.view-vendor').on('click', function(e) {
            e.preventDefault();
            const vendorId = $(this).data('vendor-id');
            viewVendor(vendorId);
        });
        
        // Edit vendor button click
        $('.edit-vendor').on('click', function(e) {
            e.preventDefault();
            const vendorId = $(this).data('vendor-id');
            populateEditVendorForm(vendorId);
        });
        
        // Delete vendor button click
        $('.delete-vendor').on('click', function(e) {
            e.preventDefault();
            const vendorId = $(this).data('vendor-id');
            confirmDeleteVendor(vendorId);
        });
    } catch (error) {
        console.error("Error setting up action buttons:", error);
    }
}

/**
 * View vendor details
 * @param {String} vendorId - Vendor ID
 */
function viewVendor(vendorId) {
    console.log("Viewing vendor details for:", vendorId);
    
    // Get vendor data
    $.ajax({
        url: contextPath + '/VendorManagementServlet?vendorId=' + vendorId,
        type: 'GET',
        dataType: 'json',
        success: function(vendor) {
            console.log("Vendor details loaded:", vendor);
            
            try {
                // Populate vendor details in the view modal
                $('#view-profile-picture').attr('src', vendor.profilePictureUrl || '/assets/images/vendors/default-vendor.jpg');
                $('#view-business-name').text(vendor.businessName || '—');
                $('#view-vendor-id').text('ID: ' + vendor.userId);
                $('#view-contact-name').text(vendor.contactName || '—');
                $('#view-username').text(vendor.username || '—');
                $('#view-email').text(vendor.email || '—');
                $('#view-phone-number').text(vendor.phone || '—');
                $('#view-address').text(vendor.address || '—');
                $('#view-website').html(vendor.websiteUrl ? `<a href="${vendor.websiteUrl}" target="_blank">${vendor.websiteUrl}</a>` : '—');
                
                // Set categories
                if (vendor.categories && vendor.categories.length > 0) {
                    const categoryTags = vendor.categories.map(cat => 
                        `<span class="category-tag">${cat.charAt(0).toUpperCase() + cat.slice(1)}</span>`
                    ).join(' ');
                    $('#view-categories').html(categoryTags);
                } else {
                    $('#view-categories').text('—');
                }
                
                $('#view-services-offered').text(vendor.servicesOffered || '—');
                $('#view-price-range').text(vendor.priceRange || '—');
                $('#view-description').text(vendor.description || '—');
                $('#view-member-since').text(vendor.memberSince || '—');
                
                // Set rating stars
                const stars = getRatingStarsHTML(vendor.rating);
                $('#view-rating-stars').html(stars);
                $('#view-rating-text').text(`${vendor.rating.toFixed(1)} (${vendor.reviewCount} reviews)`);
                
                // Set status badge
                $('#view-status-badge').removeClass().addClass('badge rounded-pill');
                switch(vendor.status) {
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
                    default:
                        $('#view-status-badge').addClass('bg-secondary').html('<i class="fas fa-question-circle me-1"></i> Unknown');
                }
                
                // Services list
                if (vendor.serviceIds && vendor.serviceIds.length > 0) {
                    let servicesHtml = '';
                    vendor.serviceIds.forEach(serviceId => {
                        const serviceNameMap = {
                            'S1001': 'Wedding Photography',
                            'S1002': 'Engagement Sessions',
                            'S1004': 'Photo Booth Rental',
                            'S1005': 'Destination Wedding Coverage',
                            'S2001': 'Full Catering Service',
                            'S2002': 'Cocktail Hour Service',
                            'S2003': 'Dessert Station',
                            'S3001': 'Ceremony Venue',
                            'S3002': 'Reception Hall',
                            'S4001': 'Bridal Bouquets',
                            'S4002': 'Ceremony Flowers',
                            'S4003': 'Reception Centerpieces',
                            'S5001': 'DJ Services',
                            'S5002': 'Live Band'
                        };
                        
                        const serviceName = serviceNameMap[serviceId] || 'Service ' + serviceId;
                        
                        servicesHtml += `
                            <tr>
                                <td>${serviceId}</td>
                                <td>${serviceName}</td>
                                <td><span class="badge bg-success">Active</span></td>
                            </tr>
                        `;
                    });
                    $('#view-services-list').html(servicesHtml);
                } else {
                    $('#view-services-list').html('<tr><td colspan="3" class="text-center">No services found</td></tr>');
                }
                
                // Show the modal
                $('#viewVendorModal').modal('show');
            } catch (error) {
                console.error("Error populating vendor details in modal:", error);
                showToast('Error', 'Could not display vendor details', 'error');
            }
        },
        error: function(xhr, status, error) {
            console.error("Error loading vendor details:", error);
            handleAjaxError(xhr, 'Failed to load vendor details');
        }
    });
}

/**
 * Generate HTML for rating stars
 * @param {Number} rating - Rating value (0-5)
 * @return {String} - HTML for stars
 */
function getRatingStarsHTML(rating) {
    try {
        if (!rating) return '—';
        
        rating = parseFloat(rating) || 0;
        const roundedRating = Math.round(rating * 2) / 2; // Round to nearest 0.5
        let stars = '';
        
        for (let i = 1; i <= 5; i++) {
            if (i <= roundedRating) {
                stars += '<i class="fas fa-star star"></i>';
            } else if (i - 0.5 === roundedRating) {
                stars += '<i class="fas fa-star-half-alt star"></i>';
            } else {
                stars += '<i class="far fa-star star"></i>';
            }
        }
        
        return stars;
    } catch (error) {
        console.error("Error generating rating stars HTML:", error);
        return '—';
    }
}

/**
 * Populate the edit vendor form
 * @param {String} vendorId - Vendor ID
 */
function populateEditVendorForm(vendorId) {
    console.log("Populating edit form for vendor:", vendorId);
    
    // Get vendor data
    $.ajax({
        url: contextPath + '/VendorManagementServlet?vendorId=' + vendorId,
        type: 'GET',
        dataType: 'json',
        success: function(vendor) {
            console.log("Vendor details for edit loaded:", vendor);
            
            try {
                // Populate form fields
                $('#edit-vendor-id').val(vendor.userId);
                $('#edit-username').val(vendor.username || '');
                $('#edit-email').val(vendor.email || '');
                $('#edit-business-name').val(vendor.businessName || '');
                $('#edit-contact-name').val(vendor.contactName || '');
                $('#edit-phone-number').val(vendor.phone || '');
                $('#edit-website').val(vendor.websiteUrl || '');
                $('#edit-address').val(vendor.address || '');
                $('#edit-services-offered').val(vendor.servicesOffered || '');
                $('#edit-price-range').val(vendor.priceRange || '');
                $('#edit-description').val(vendor.description || '');
                $('#edit-profile-picture').val(vendor.profilePictureUrl || '');
                $('#edit-cover-photo').val(vendor.coverPhotoUrl || '');
                $('#edit-rating').val(vendor.rating || 0);
                $('#edit-status').val(vendor.status || 'active');
                $('#edit-featured').prop('checked', vendor.featured || false);
                
                // Select categories
                $('#edit-categories').val(vendor.categories || []);
                
                // Reset password fields
                $('#reset-password').prop('checked', false);
                $('#password-reset-fields').addClass('d-none');
                $('#new-password').val('');
                $('#confirm-password').val('');
                
                // Update modal title and show
                $('#editVendorModalTitle').text('Edit Vendor: ' + vendor.businessName);
                $('#editVendorModal').modal('show');
            } catch (error) {
                console.error("Error populating edit form:", error);
                showToast('Error', 'Could not load vendor data for editing', 'error');
            }
        },
        error: function(xhr, status, error) {
            console.error("Error loading vendor for edit:", error);
            handleAjaxError(xhr, 'Failed to load vendor data for editing');
        }
    });
}

/**
 * Confirm vendor deletion
 * @param {String} vendorId - Vendor ID
 */
function confirmDeleteVendor(vendorId) {
    console.log("Confirming deletion for vendor:", vendorId);
    
    // Get vendor name
    $.ajax({
        url: contextPath + '/VendorManagementServlet?vendorId=' + vendorId,
        type: 'GET',
        dataType: 'json',
        success: function(vendor) {
            try {
                $('#delete-vendor-id').val(vendorId);
                $('#delete-vendor-name').text(`${vendor.businessName || 'Unknown'} (${vendor.username || 'Unknown'})`);
                $('#deleteVendorModal').modal('show');
            } catch (error) {
                console.error("Error setting up delete confirmation:", error);
                
                // Fallback
                if (confirm(`Are you sure you want to delete vendor ${vendorId}? This action cannot be undone.`)) {
                    deleteVendor(vendorId);
                }
            }
        },
        error: function(xhr, status, error) {
            console.error("Error loading vendor for deletion:", error);
            
            // Fallback
            if (confirm(`Are you sure you want to delete vendor ${vendorId}? This action cannot be undone.`)) {
                deleteVendor(vendorId);
            }
        }
    });
}

/**
 * Create a new vendor
 */
function createVendor() {
    console.log("Creating new vendor");
    
    try {
        // Build vendor data object
        const vendorData = {
            username: $('#add-username').val(),
            password: $('#add-password').val(),
            email: $('#add-email').val(),
            businessName: $('#add-business-name').val(),
            contactName: $('#add-contact-name').val(),
            phone: $('#add-phone-number').val(),
            address: $('#add-address').val(),
            servicesOffered: $('#add-services-offered').val(),
            description: $('#add-description').val(),
            priceRange: $('#add-price-range').val(),
            websiteUrl: $('#add-website').val(),
            status: $('#add-status').val(),
            featured: $('#add-featured').is(':checked'),
            // Get selected categories as array
            categories: $('#add-categories').val() || []
        };
        
        console.log("Vendor data to submit:", vendorData);
        
        $.ajax({
            url: contextPath + '/VendorManagementServlet',
            type: 'POST',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(vendorData),
            success: function(response) {
                console.log("Vendor created successfully:", response);
                $('#addVendorModal').modal('hide');
                showToast('Success', 'Vendor created successfully', 'success');
                loadVendors();
                resetAddVendorForm();
            },
            error: function(xhr, status, error) {
                console.error("Error creating vendor:", error);
                console.error("Server response:", xhr.responseText);
                handleAjaxError(xhr, 'Failed to create vendor');
            }
        });
    } catch (error) {
        console.error("Error preparing vendor data for creation:", error);
        showToast('Error', 'Could not create vendor: ' + error.message, 'error');
    }
}

/**
 * Update an existing vendor
 */
function updateVendor() {
    const vendorId = $('#edit-vendor-id').val();
    console.log("Updating vendor:", vendorId);
    
    try {
        // Build vendor data object
        const vendorData = {
            vendorId: vendorId,
            username: $('#edit-username').val(),
            email: $('#edit-email').val(),
            businessName: $('#edit-business-name').val(),
            contactName: $('#edit-contact-name').val(),
            phone: $('#edit-phone-number').val(),
            address: $('#edit-address').val(),
            servicesOffered: $('#edit-services-offered').val(),
            description: $('#edit-description').val(),
            priceRange: $('#edit-price-range').val(),
            websiteUrl: $('#edit-website').val(),
            profilePictureUrl: $('#edit-profile-picture').val(),
            coverPhotoUrl: $('#edit-cover-photo').val(),
            rating: parseFloat($('#edit-rating').val()) || 0,
            status: $('#edit-status').val(),
            featured: $('#edit-featured').is(':checked'),
            // Get selected categories as array
            categories: $('#edit-categories').val() || []
        };
        
        // Add password if being reset
        if ($('#reset-password').is(':checked')) {
            vendorData.password = $('#new-password').val();
        }
        
        console.log("Vendor data to update:", vendorData);
        
        $.ajax({
            url: contextPath + '/VendorManagementServlet',
            type: 'PUT',
            contentType: 'application/json',
            dataType: 'json',
            data: JSON.stringify(vendorData),
            success: function(response) {
                console.log("Vendor updated successfully:", response);
                $('#editVendorModal').modal('hide');
                showToast('Success', 'Vendor updated successfully', 'success');
                loadVendors();
            },
            error: function(xhr, status, error) {
                console.error("Error updating vendor:", error);
                console.error("Server response:", xhr.responseText);
                handleAjaxError(xhr, 'Failed to update vendor');
            }
        });
    } catch (error) {
        console.error("Error preparing vendor data for update:", error);
        showToast('Error', 'Could not update vendor: ' + error.message, 'error');
    }
}

/**
 * Delete a vendor
 * @param {String} vendorId - Vendor ID
 */
function deleteVendor(vendorId) {
    console.log("Deleting vendor:", vendorId);
    
    $.ajax({
        url: contextPath + '/VendorManagementServlet?vendorId=' + vendorId,
        type: 'DELETE',
        success: function(response) {
            console.log("Vendor deleted successfully:", response);
            $('#deleteVendorModal').modal('hide');
            showToast('Success', 'Vendor deleted successfully', 'success');
            loadVendors();
        },
        error: function(xhr, status, error) {
            console.error("Error deleting vendor:", error);
            console.error("Server response:", xhr.responseText);
            handleAjaxError(xhr, 'Failed to delete vendor');
        }
    });
}

/**
 * Filter vendors based on search criteria
 */
function filterVendors() {
    const status = $('#status-filter').val();
    const category = $('#category-filter').val();
    const dateRange = $('#date-range').val();
    const searchTerm = $('#search-vendors').val();
    
    console.log("Filtering vendors with criteria:", {
        status: status,
        category: category,
        dateRange: dateRange,
        search: searchTerm
    });
    
    // Prepare filter parameters
    let params = {};
    if (status) params.status = status;
    if (category) params.category = category;
    if (dateRange) params.dateRange = dateRange;
    if (searchTerm) params.search = searchTerm;
    
    // Convert params object to query string
    const queryString = Object.keys(params)
        .map(key => key + '=' + encodeURIComponent(params[key]))
        .join('&');
    
    // Make AJAX request with filters
    $.ajax({
        url: contextPath + '/VendorManagementServlet' + (queryString ? '?' + queryString : ''),
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            console.log("Filtered vendors loaded:", data);
            populateVendorsTable(data);
        },
        error: function(xhr, status, error) {
            console.error("Error filtering vendors:", error);
            console.error("Server response:", xhr.responseText);
            handleAjaxError(xhr, 'Failed to filter vendors');
        }
    });
}

/**
 * Export vendors in the selected format
 * @param {String} format - Export format (excel, csv, pdf)
 */
function exportVendors(format) {
    console.log("Exporting vendors in format:", format);
    
    // Get current filters
    const status = $('#status-filter').val();
    const category = $('#category-filter').val();
    const dateRange = $('#date-range').val();
    const searchTerm = $('#search-vendors').val();
    
    // Prepare export parameters
    let params = { format: format };
    if (status) params.status = status;
    if (category) params.category = category;
    if (dateRange) params.dateRange = dateRange;
    if (searchTerm) params.search = searchTerm;
    
    // Convert params object to query string
    const queryString = Object.keys(params)
        .map(key => key + '=' + encodeURIComponent(params[key]))
        .join('&');
    
    // Redirect to export URL (will trigger file download)
    const exportUrl = contextPath + '/VendorManagementServlet/export?' + queryString;
    console.log("Export URL:", exportUrl);
    window.location.href = exportUrl;
}

/**
 * Reset the add vendor form
 */
function resetAddVendorForm() {
    $('#add-vendor-form')[0].reset();
    $('#add-vendor-form').removeClass('was-validated');
    $('#add-categories').val([]);
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
        console.error("Error parsing error response:", e);
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
    try {
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
    } catch (error) {
        // Fallback if SweetAlert2 fails
        console.error("Toast notification error:", error);
        alert(`${title}: ${message}`);
    }
}

// Ensure the contextPath is available globally
if (typeof contextPath === 'undefined') {
    window.contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf('/admin'));
    console.log("Context path set globally:", contextPath);
}