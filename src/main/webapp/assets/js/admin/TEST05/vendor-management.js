/**
 * Vendor Management JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-06 07:24:47
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
    initializeAOS();
    
    // Set up button event handlers
    setupButtonHandlers();
    
    // Initialize view toggle
    initializeViewToggle();
    
    // Initialize image upload handlers
    initializeImageHandlers();
    
    // Load vendor data initially
    loadVendors();
    
    // Load pending approvals initially
    loadPendingApprovals();
    
    // Load available services for service selection
    loadAvailableServices();
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
        const vendorId = $('#view-vendor-id').text().replace('ID: ', '').trim();
        populateEditVendorForm(vendorId);
        $('#editVendorModal').modal('show');
    });
}

/**
 * Initialize DataTables
 */
function initializeDataTable() {
    window.vendorsTable = $('#vendors-table').DataTable({
        columnDefs: [
            { targets: [0], width: "40px", orderable: false },
            { targets: [1], width: "60px" },
            { targets: [9], width: "100px", orderable: false }
        ],
        order: [[8, 'desc']], // Sort by registration date by default
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
        select: {
            style: 'multi',
            selector: 'td:first-child input[type="checkbox"]'
        },
        initComplete: function() {
            // Add custom class to DataTables elements
            $('.dataTables_filter input').addClass('form-control');
        }
    });

    // Handle table selection events
    $('#vendors-table tbody').on('change', 'input[type="checkbox"]', function() {
        updateBulkActionVisibility();
    });

    // "Select All" checkbox functionality
    $('#select-all-vendors').on('change', function() {
        const isChecked = $(this).prop('checked');
        $('#vendors-table tbody input[type="checkbox"]').prop('checked', isChecked);
        updateBulkActionVisibility();
    });
}

/**
 * Update bulk action visibility based on selected items
 */
function updateBulkActionVisibility() {
    const selectedCount = $('#vendors-table tbody input[type="checkbox"]:checked').length;
    $('#selected-count').text(selectedCount);
    
    if (selectedCount > 0) {
        $('#bulk-actions-card').slideDown(300);
    } else {
        $('#bulk-actions-card').slideUp(300);
    }
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
        filterVendors();
    });

    $('#date-range').on('cancel.daterangepicker', function() {
        $(this).val('');
        filterVendors();
    });
}

/**
 * Initialize AOS animations
 */
function initializeAOS() {
    AOS.init({
        duration: 800,
        easing: 'ease-in-out',
        once: true
    });
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
 * Initialize view toggle between table and card views
 */
function initializeViewToggle() {
    $('.toggle-view-btn').on('click', function() {
        const view = $(this).data('view');
        
        // Update active state
        $('.toggle-view-btn').removeClass('active');
        $(this).addClass('active');
        
        // Toggle views
        if (view === 'table') {
            $('.table-view').show();
            $('.cards-view').hide();
        } else {
            $('.table-view').hide();
            $('.cards-view').show();
        }
    });
    
    // Trigger card view by default
    $('.toggle-view-btn[data-view="cards"]').click();
}

/**
 * Initialize image upload handlers
 */
function initializeImageHandlers() {
    // Toggle between URL and upload for profile picture in add form
    $('input[name="add-profile-image-type"]').on('change', function() {
        const option = $('input[name="add-profile-image-type"]:checked').attr('id');
        
        if (option === 'add-profile-url-option') {
            $('#add-profile-url-input').show();
            $('#add-profile-upload-input').hide();
        } else {
            $('#add-profile-url-input').hide();
            $('#add-profile-upload-input').show();
        }
    });
    
    // Toggle between URL and upload for profile picture in edit form
    $('input[name="profile-image-type"]').on('change', function() {
        const option = $('input[name="profile-image-type"]:checked').attr('id');
        
        if (option === 'profile-url-option') {
            $('#profile-url-input').show();
            $('#profile-upload-input').hide();
        } else {
            $('#profile-url-input').hide();
            $('#profile-upload-input').show();
        }
    });
    
    // Toggle between URL and upload for portfolio in add form
    $('input[name="add-portfolio-image-type"]').on('change', function() {
        const option = $('input[name="add-portfolio-image-type"]:checked').attr('id');
        
        if (option === 'add-portfolio-url-option') {
            $('#add-portfolio-url-input').show();
            $('#add-portfolio-upload-input').hide();
        } else {
            $('#add-portfolio-url-input').hide();
            $('#add-portfolio-upload-input').show();
        }
    });
    
    // Toggle between URL and upload for portfolio in edit form
    $('input[name="portfolio-image-type"]').on('change', function() {
        const option = $('input[name="portfolio-image-type"]:checked').attr('id');
        
        if (option === 'portfolio-url-option') {
            $('#portfolio-url-input').show();
            $('#portfolio-upload-input').hide();
        } else {
            $('#portfolio-url-input').hide();
            $('#portfolio-upload-input').show();
        }
    });
    
    // Preview profile image in add form
    $('#add-profile-picture').on('input', function() {
        $('#add-profile-preview').attr('src', $(this).val() || '${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg');
    });
    
    $('#add-profile-upload').on('change', function() {
        previewUploadedImage(this, '#add-profile-preview');
    });
    
    // Preview profile image in edit form
    $('#edit-profile-picture').on('input', function() {
        $('#edit-profile-preview').attr('src', $(this).val() || '${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg');
    });
    
    $('#edit-profile-upload').on('change', function() {
        previewUploadedImage(this, '#edit-profile-preview');
    });
    
    // Add portfolio image via URL in add form
    $('#add-add-portfolio-url').on('click', function() {
        const imageUrl = $('#add-portfolio-image-url').val().trim();
        if (imageUrl) {
            addPortfolioImage(imageUrl, 'add-portfolio-container');
            $('#add-portfolio-image-url').val('');
        } else {
            showToast('Error', 'Please enter a valid image URL', 'error');
        }
    });
    
    // Add portfolio image via upload in add form
    $('#add-add-portfolio-upload').on('click', function() {
        const fileInput = $('#add-portfolio-image-upload')[0];
        
        if (fileInput.files && fileInput.files[0]) {
            const reader = new FileReader();
            
            reader.onload = function(e) {
                addPortfolioImage(e.target.result, 'add-portfolio-container');
                $('#add-portfolio-image-upload').val('');
            }
            
            reader.readAsDataURL(fileInput.files[0]);
        } else {
            showToast('Error', 'Please select an image to upload', 'error');
        }
    });
    
    // Add portfolio image via URL in edit form
    $('#add-portfolio-url').on('click', function() {
        const imageUrl = $('#portfolio-image-url').val().trim();
        if (imageUrl) {
            addPortfolioImage(imageUrl, 'edit-portfolio-container');
            $('#portfolio-image-url').val('');
        } else {
            showToast('Error', 'Please enter a valid image URL', 'error');
        }
    });
    
    // Add portfolio image via upload in edit form
    $('#add-portfolio-upload').on('click', function() {
        const fileInput = $('#portfolio-image-upload')[0];
        
        if (fileInput.files && fileInput.files[0]) {
            const reader = new FileReader();
            
            reader.onload = function(e) {
                addPortfolioImage(e.target.result, 'edit-portfolio-container');
                $('#portfolio-image-upload').val('');
            }
            
            reader.readAsDataURL(fileInput.files[0]);
        } else {
            showToast('Error', 'Please select an image to upload', 'error');
        }
    });
}

/**
 * Preview uploaded image file
 * @param {HTMLInputElement} input - The file input element
 * @param {String} previewSelector - Selector for the preview image element
 */
function previewUploadedImage(input, previewSelector) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            $(previewSelector).attr('src', e.target.result);
        }
        
        reader.readAsDataURL(input.files[0]);
    }
}

/**
 * Add portfolio image to container
 * @param {String} imageUrl - URL of the image
 * @param {String} containerId - ID of the container element
 */
function addPortfolioImage(imageUrl, containerId) {
    const portfolioItem = `
        <div class="portfolio-item">
            <img src="${imageUrl}" alt="Portfolio Image">
            <div class="portfolio-item-actions">
                <button type="button" class="remove-portfolio-item" title="Remove">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <input type="hidden" name="portfolioImages[]" value="${imageUrl}">
        </div>
    `;
    
    // Check if the container has the placeholder text and remove it
    const $container = $(`#${containerId}`);
    if ($container.find('.text-muted').length > 0) {
        $container.empty();
    }
    
    // Add the new portfolio item
    $container.append(portfolioItem);
    
    // Add event handler for remove button
    $('.remove-portfolio-item').off('click').on('click', function() {
        $(this).closest('.portfolio-item').fadeOut(300, function() {
            $(this).remove();
            
            // If no more items, show placeholder text
            if ($(`#${containerId}`).children().length === 0) {
                $(`#${containerId}`).html('<p class="text-muted">No portfolio images added yet.</p>');
            }
        });
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
        $('#featured-filter').val('');
        $('#search-vendors').val('');
        filterVendors();
    });
    
    // Refresh vendors button click
    $('#refresh-vendors').on('click', function() {
        loadVendors();
    });
    
    // Refresh pending approvals button click
    $('#refresh-pending-approvals').on('click', function() {
        loadPendingApprovals();
    });
    
    // Add vendor button click
    $('#add-vendor-btn').on('click', function() {
        resetAddVendorForm();
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
    
    // Bulk action buttons
    $('.bulk-action-btn').on('click', function() {
        const action = $(this).data('action');
        executeBulkAction(action);
    });
    
    // Approve vendor button click
    $('#approve-vendor-btn').on('click', function() {
        approveVendor($('#approval-vendor-id').val());
    });
    
    // Reject vendor button click
    $('#reject-vendor-btn').on('click', function() {
        rejectVendor($('#approval-vendor-id').val());
    });
    
    // Confirm bulk delete button click
    $('#confirm-bulk-delete-btn').on('click', function() {
        executeBulkDelete();
    });
}

/**
 * Load vendor data from the server
 */
function loadVendors() {
    // Show loading indicator
    $('#vendors-cards').html('<div class="col-12 text-center p-5" id="vendors-loader"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Loading...</span></div><p class="mt-3">Loading vendors...</p></div>');
    
    // Make AJAX request
    $.ajax({
        url: contextPath + '/VendorManagementServlet',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            populateVendorsTable(data);
            populateVendorsCards(data);
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load vendors');
        }
    });
}

/**
 * Load pending vendor approvals
 */
function loadPendingApprovals() {
    // Show loading indicator
    $('#pending-approvals-list').hide();
    $('#pending-approvals-loader').show();
    $('#no-pending-approvals').addClass('d-none');
    
    // Make AJAX request
    $.ajax({
        url: contextPath + '/VendorManagementServlet',
        type: 'GET',
        data: {
            status: 'pending'
        },
        dataType: 'json',
        success: function(data) {
            populatePendingApprovals(data);
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load pending approvals');
            $('#pending-approvals-loader').hide();
            $('#no-pending-approvals').removeClass('d-none');
        }
    });
}

/**
 * Load available services for selection in forms
 */
function loadAvailableServices() {
    $.ajax({
        url: contextPath + '/ServiceManagementServlet',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            populateServicesCheckboxes(data);
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load services');
            
            // Show placeholder
            const servicesPlaceholder = `
                <div class="alert alert-warning">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    Could not load services. Please try again later.
                </div>
            `;
            $('#add-services-selection, #edit-services-selection').html(servicesPlaceholder);
        }
    });
}

/**
 * Populate services checkboxes in forms
 * @param {Array} services - List of service objects
 */
function populateServicesCheckboxes(services) {
    if (!services || services.length === 0) {
        const emptyMessage = `
            <div class="alert alert-info">
                <i class="fas fa-info-circle me-2"></i>
                No services available. Please add services first.
            </div>
        `;
        $('#add-services-selection, #edit-services-selection').html(emptyMessage);
        return;
    }
    
    // Group services by category
    const categorizedServices = {};
    services.forEach(service => {
        if (!categorizedServices[service.category]) {
            categorizedServices[service.category] = [];
        }
        categorizedServices[service.category].push(service);
    });
    
    // Generate checkboxes for add form
    let addCheckboxesHtml = '';
    
    for (const category in categorizedServices) {
        addCheckboxesHtml += `<h6 class="text-uppercase text-muted small mt-3 mb-2">${formatCategory(category)}</h6>`;
        
        categorizedServices[category].forEach(service => {
            addCheckboxesHtml += `
                <div class="service-checkbox">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="serviceIds[]" id="add-service-${service.serviceId}" value="${service.serviceId}">
                        <label class="form-check-label service-checkbox-header" for="add-service-${service.serviceId}">
                            <div class="service-checkbox-icon">
                                <i class="${getServiceIcon(service.category)}"></i>
                            </div>
                            ${service.serviceName}
                        </label>
                    </div>
                </div>
            `;
        });
    }
    
    // Generate checkboxes for edit form
    let editCheckboxesHtml = '';
    
    for (const category in categorizedServices) {
        editCheckboxesHtml += `<h6 class="text-uppercase text-muted small mt-3 mb-2">${formatCategory(category)}</h6>`;
        
        categorizedServices[category].forEach(service => {
            editCheckboxesHtml += `
                <div class="service-checkbox">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" name="serviceIds[]" id="edit-service-${service.serviceId}" value="${service.serviceId}">
                        <label class="form-check-label service-checkbox-header" for="edit-service-${service.serviceId}">
                            <div class="service-checkbox-icon">
                                <i class="${getServiceIcon(service.category)}"></i>
                            </div>
                            ${service.serviceName}
                        </label>
                    </div>
                </div>
            `;
        });
    }
    
    // Update containers
    $('#add-services-selection').html(addCheckboxesHtml);
    $('#edit-services-selection').html(editCheckboxesHtml);
}

/**
 * Get icon class for a service category
 * @param {String} category - Service category
 * @return {String} - FontAwesome icon class
 */
function getServiceIcon(category) {
    const icons = {
        'photography': 'fas fa-camera',
        'videography': 'fas fa-video',
        'catering': 'fas fa-utensils',
        'venues': 'fas fa-building',
        'decoration': 'fas fa-holly-berry',
        'entertainment': 'fas fa-music',
        'planning': 'fas fa-clipboard-check',
        'beauty': 'fas fa-spa',
        'transportation': 'fas fa-car',
        'attire': 'fas fa-tshirt',
        'jewelry': 'fas fa-gem',
        'invitations': 'fas fa-envelope',
        'gifts': 'fas fa-gift',
        'flowers': 'fas fa-seedling',
        'rental': 'fas fa-chair',
        'cake': 'fas fa-birthday-cake',
        'honeymoon': 'fas fa-umbrella-beach'
    };
    
    return icons[category.toLowerCase()] || 'fas fa-concierge-bell';
}

/**
 * Format category name for display
 * @param {String} category - Service category
 * @return {String} - Formatted category name
 */
function formatCategory(category) {
    return category.charAt(0).toUpperCase() + category.slice(1);
}

/**
 * Populate the vendors table with data
 * @param {Array} vendors - The array of vendor objects
 */
function populateVendorsTable(vendors) {
    const table = window.vendorsTable;
    
    // Clear existing data
    table.clear();
    
    // Add rows
    vendors.forEach(vendor => {
        table.row.add([
            `<div class="form-check">
                <input class="form-check-input" type="checkbox" value="${vendor.userId}">
            </div>`,
            vendor.userId,
            getVendorNameCell(vendor),
            vendor.contactPerson,
            vendor.email,
            getVendorServicesCell(vendor),
            getVendorRatingCell(vendor),
            getStatusBadge(vendor.accountStatus),
            formatDate(vendor.registrationDate),
            getActionButtons(vendor.userId)
        ]);
    });
    
    // Draw the table
    table.draw();
    
    // Set up action button handlers
    setupActionButtons();
    
    // Reset bulk selection counter
    updateBulkActionVisibility();
}

/**
 * Populate vendors in card view
 * @param {Array} vendors - The array of vendor objects
 */
function populateVendorsCards(vendors) {
    if (!vendors || vendors.length === 0) {
        $('#vendors-cards').html(`
            <div class="col-12 text-center p-5">
                <i class="fas fa-store-alt-slash fa-4x text-muted mb-3"></i>
                <h5>No Vendors Found</h5>
                <p class="text-muted">No vendors match your current filters or no vendors have been added yet.</p>
            </div>
        `);
        return;
    }
    
    let cardsHtml = '';
    const itemsPerPage = 12;
    const totalPages = Math.ceil(vendors.length / itemsPerPage);
    
    // Create cards
    vendors.forEach((vendor, index) => {
        const isVisible = index < itemsPerPage ? '' : 'style="display: none;"';
        const pageClass = `page-item-${Math.floor(index / itemsPerPage) + 1}`;
        
        cardsHtml += `
            <div class="col-md-6 col-lg-4 mb-4 ${pageClass}" ${isVisible} data-aos="fade-up" data-aos-delay="${(index % itemsPerPage) * 50}">
                <div class="vendor-card">
                    <div class="vendor-card-header">
                        <img src="../assets/images/vendor-backgrounds/default-bg.jpg" alt="Vendor background">
                        <div class="vendor-card-logo">
                            <img src="${vendor.profilePictureURL || '${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg'}" alt="${vendor.businessName}">
                        </div>
                        <div class="vendor-card-status">
                            ${getStatusBadge(vendor.accountStatus)}
                        </div>
                        ${vendor.featured ? '<div class="vendor-card-featured"><i class="fas fa-star me-1"></i> Featured</div>' : ''}
                    </div>
                    <div class="vendor-card-body">
                        <h5 class="vendor-card-title">${vendor.businessName}</h5>
                        <p class="vendor-card-subtitle">
                            <i class="fas fa-user me-1 text-muted"></i> ${vendor.contactPerson}
                        </p>
                        
                        <div class="vendor-card-details">
                            <div class="vendor-card-detail">
                                <i class="fas fa-envelope"></i>
                                <span>${vendor.email}</span>
                            </div>
                            ${vendor.phoneNumber ? `
                                <div class="vendor-card-detail">
                                    <i class="fas fa-phone"></i>
                                    <span>${vendor.phoneNumber}</span>
                                </div>
                            ` : ''}
                            ${vendor.location ? `
                                <div class="vendor-card-detail">
                                    <i class="fas fa-map-marker-alt"></i>
                                    <span>${vendor.location}</span>
                                </div>
                            ` : ''}
                        </div>
                        
                        <div class="vendor-card-services">
                            ${getVendorServicesBadges(vendor)}
                        </div>
                    </div>
                    <div class="vendor-card-footer">
                        <div class="vendor-card-rating">
                            <i class="fas fa-star"></i>
                            <span>${vendor.rating ? vendor.rating.toFixed(1) : 'N/A'}</span>
                        </div>
                        <div class="vendor-card-actions">
                            <button class="btn btn-sm btn-outline-primary view-vendor" data-vendor-id="${vendor.userId}">
                                <i class="fas fa-eye me-1"></i> View
                            </button>
                            <button class="btn btn-sm btn-outline-secondary edit-vendor" data-vendor-id="${vendor.userId}">
                                <i class="fas fa-edit me-1"></i> Edit
                            </button>
                            <button class="btn btn-sm btn-outline-danger delete-vendor" data-vendor-id="${vendor.userId}">
                                <i class="fas fa-trash-alt me-1"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    });
    
    // Update container
    $('#vendors-cards').html(cardsHtml);
    
    // Create pagination if needed
    if (totalPages > 1) {
        let paginationHtml = '<ul class="pagination">';
        
        // Previous button
        paginationHtml += `
            <li class="page-item" id="vendor-prev-page">
                <a class="page-link" href="#" aria-label="Previous">
                    <i class="fas fa-chevron-left"></i>
                </a>
            </li>
        `;
        
        // Page numbers
        for (let i = 1; i <= totalPages; i++) {
            paginationHtml += `
                <li class="page-item ${i === 1 ? 'active' : ''}" data-page="${i}">
                    <a class="page-link" href="#">${i}</a>
                </li>
            `;
        }
        
        // Next button
        paginationHtml += `
            <li class="page-item" id="vendor-next-page">
                <a class="page-link" href="#" aria-label="Next">
                    <i class="fas fa-chevron-right"></i>
                </a>
            </li>
        `;
        
        paginationHtml += '</ul>';
        $('#vendors-pagination').html(paginationHtml);
        
        // Set up pagination event handlers
        let currentPage = 1;
        
        // Page click
        $('.vendors-pagination .page-item[data-page]').on('click', function(e) {
            e.preventDefault();
            const page = parseInt($(this).data('page'));
            changePage(page);
        });
        
        // Previous page
        $('#vendor-prev-page').on('click', function(e) {
            e.preventDefault();
            if (currentPage > 1) {
                changePage(currentPage - 1);
            }
        });
        
        // Next page
        $('#vendor-next-page').on('click', function(e) {
            e.preventDefault();
            if (currentPage < totalPages) {
                changePage(currentPage + 1);
            }
        });
        
        function changePage(page) {
            // Hide all items
            $(`.page-item-${currentPage}`).hide();
            
            // Show items for the selected page
            $(`.page-item-${page}`).show();
            
            // Update active state
            $(`.vendors-pagination .page-item[data-page="${currentPage}"]`).removeClass('active');
            $(`.vendors-pagination .page-item[data-page="${page}"]`).addClass('active');
            
            // Update current page
            currentPage = page;
            
            // Disable/enable prev/next buttons
            $('#vendor-prev-page').toggleClass('disabled', currentPage === 1);
            $('#vendor-next-page').toggleClass('disabled', currentPage === totalPages);
            
            // Scroll to top of vendors section
            $('html, body').animate({
                scrollTop: $('#vendors-cards').offset().top - 100
            }, 300);
        }
    } else {
        $('#vendors-pagination').html('');
    }
    
    // Set up action button handlers
    setupCardActionButtons();
}

/**
 * Populate pending approvals section
 * @param {Array} vendors - List of vendors with pending status
 */
function populatePendingApprovals(vendors) {
    // Hide loader
    $('#pending-approvals-loader').hide();
    
    // Check if there are any pending approvals
    if (!vendors || vendors.length === 0) {
        $('#no-pending-approvals').removeClass('d-none');
        $('#pending-approvals-list').html('').hide();
        
        // Update sidebar badge
        $('.pending-approvals').text('0').hide();
        
        return;
    }
    
    // Update sidebar badge
    $('.pending-approvals').text(vendors.length).show();
    
    // Generate HTML for pending approvals
    let approvalsHtml = '';
    
    vendors.forEach((vendor, index) => {
        approvalsHtml += `
            <div class="col-md-6 col-xl-4" data-aos="fade-up" data-aos-delay="${index * 100}">
                <div class="pending-approval-card">
                    <div class="pending-approval-header">
                        <div class="pending-approval-avatar">
                            <img src="${vendor.profilePictureURL || '${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg'}" alt="${vendor.businessName}">
                        </div>
                        <div>
                            <h6 class="pending-approval-title">${vendor.businessName}</h6>
                            <div class="pending-approval-meta">
                                <span><i class="fas fa-user me-1"></i>${vendor.contactPerson}</span> |
                                <span><i class="fas fa-calendar me-1"></i>${formatDate(vendor.registrationDate)}</span>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <small class="text-muted"><i class="fas fa-envelope me-1"></i> ${vendor.email}</small>
                        ${vendor.phoneNumber ? `<br><small class="text-muted"><i class="fas fa-phone me-1"></i> ${vendor.phoneNumber}</small>` : ''}
                    </div>
                    
                    <div class="pending-approval-actions">
                        <button class="btn btn-sm btn-outline-primary view-approval" data-vendor-id="${vendor.userId}">
                            <i class="fas fa-eye me-1"></i> View
                        </button>
                        <button class="btn btn-sm btn-outline-danger reject-approval" data-vendor-id="${vendor.userId}" data-bs-toggle="tooltip" title="Reject">
                            <i class="fas fa-times me-1"></i> Reject
                        </button>
                        <button class="btn btn-sm btn-success approve-approval" data-vendor-id="${vendor.userId}">
                            <i class="fas fa-check me-1"></i> Approve
                        </button>
                    </div>
                </div>
            </div>
        `;
    });
    
    // Update container
    $('#pending-approvals-list').html(approvalsHtml).show();
    
    // Initialize tooltips
    $('[data-bs-toggle="tooltip"]').tooltip();
    
    // Set up approval action handlers
    $('.view-approval').on('click', function() {
        const vendorId = $(this).data('vendor-id');
        viewVendor(vendorId);
    });
    
    $('.approve-approval').on('click', function() {
        const vendorId = $(this).data('vendor-id');
        showApprovalModal(vendorId, 'approve');
    });
    
    $('.reject-approval').on('click', function() {
        const vendorId = $(this).data('vendor-id');
        showApprovalModal(vendorId, 'reject');
    });
}

/**
 * Create HTML for vendor name cell with logo
 * @param {Object} vendor - Vendor object
 * @return {String} - HTML for the vendor name cell
 */
function getVendorNameCell(vendor) {
    const avatarUrl = vendor.profilePictureURL || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(vendor.businessName) + '&background=random&color=fff';
    const featuredBadge = vendor.featured ? '<span class="badge bg-warning text-dark ms-2"><i class="fas fa-star me-1"></i> Featured</span>' : '';
    
    return `<div class="d-flex align-items-center">
                <div class="avatar avatar-sm me-3">
                    <img src="${avatarUrl}" alt="${vendor.businessName}">
                </div>
                <div>
                    <p class="mb-0 fw-medium">${vendor.businessName}</p>
                    <small class="text-muted">@${vendor.username}</small>
                    ${featuredBadge}
                </div>
            </div>`;
}

/**
 * Create HTML for vendor services cell
 * @param {Object} vendor - Vendor object
 * @return {String} - HTML for the vendor services cell
 */
function getVendorServicesCell(vendor) {
    if (!vendor.serviceIds || vendor.serviceIds.length === 0) {
        return '<span class="text-muted">No services</span>';
    }
    
    const serviceCount = vendor.serviceIds.length;
    const displayCount = Math.min(2, serviceCount);
    const moreCount = serviceCount - displayCount;
    
    let html = '';
    
    for (let i = 0; i < displayCount; i++) {
        html += `<span class="badge bg-light text-dark me-1">${getServiceName(vendor.serviceIds[i])}</span>`;
    }
    
    if (moreCount > 0) {
        html += `<span class="badge bg-secondary">+${moreCount} more</span>`;
    }
    
    return html;
}

/**
 * Create HTML for vendor rating cell
 * @param {Object} vendor - Vendor object
 * @return {String} - HTML for the vendor rating cell
 */
function getVendorRatingCell(vendor) {
    if (!vendor.rating || vendor.rating === 0) {
        return '<span class="text-muted">Not rated</span>';
    }
    
    const rating = vendor.rating;
    const stars = Math.round(rating * 2) / 2; // Round to nearest 0.5
    
    let html = '<div class="vendor-stars">';
    
    // Add full stars
    for (let i = 1; i <= Math.floor(stars); i++) {
        html += '<i class="fas fa-star text-warning"></i>';
    }
    
    // Add half star if needed
    if (stars % 1 !== 0) {
        html += '<i class="fas fa-star-half-alt text-warning"></i>';
    }
    
    // Add empty stars
    for (let i = Math.ceil(stars); i < 5; i++) {
        html += '<i class="far fa-star text-warning"></i>';
    }
    
    html += `<span class="ms-1">${rating.toFixed(1)}</span>`;
    html += '</div>';
    
    return html;
}

/**
 * Get service name from service ID
 * @param {String} serviceId - Service ID
 * @return {String} - Service name or the ID if not found
 */
function getServiceName(serviceId) {
    // This would normally look up the service from a cached list
    // For now, just return the ID since we don't have the services loaded
    return serviceId;
}

/**
 * Create vendor services badges for card view
 * @param {Object} vendor - Vendor object
 * @return {String} - HTML for service badges
 */
function getVendorServicesBadges(vendor) {
    if (!vendor.serviceIds || vendor.serviceIds.length === 0) {
        return '<span class="vendor-card-service">No services</span>';
    }
    
    let html = '';
    const maxDisplay = 3;
    const displayCount = Math.min(maxDisplay, vendor.serviceIds.length);
    const moreCount = vendor.serviceIds.length - displayCount;
    
    for (let i = 0; i < displayCount; i++) {
        html += `<span class="vendor-card-service">${getServiceName(vendor.serviceIds[i])}</span>`;
    }
    
    if (moreCount > 0) {
        html += `<span class="vendor-card-service">+${moreCount} more</span>`;
    }
    
    return html;
}

/**
 * Create status badge HTML
 * @param {String} status - Vendor account status
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
 * @param {String} vendorId - Vendor ID
 * @return {String} - HTML for action buttons
 */
function getActionButtons(vendorId) {
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
 * Set up action button event handlers for table view
 */
function setupActionButtons() {
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
}

/**
 * Set up action button event handlers for card view
 */
function setupCardActionButtons() {
    // View vendor button click
    $('.vendor-card-actions .view-vendor').on('click', function() {
        const vendorId = $(this).data('vendor-id');
        viewVendor(vendorId);
    });
    
    // Edit vendor button click
    $('.vendor-card-actions .edit-vendor').on('click', function() {
        const vendorId = $(this).data('vendor-id');
        populateEditVendorForm(vendorId);
    });
    
    // Delete vendor button click
    $('.vendor-card-actions .delete-vendor').on('click', function() {
        const vendorId = $(this).data('vendor-id');
        confirmDeleteVendor(vendorId);
    });
}

/**
 * View vendor details
 * @param {String} vendorId - Vendor ID
 */
function viewVendor(vendorId) {
    // Get vendor data
    $.ajax({
        url: contextPath + '/VendorManagementServlet',
        type: 'GET',
        data: {
            vendorId: vendorId
        },
        dataType: 'json',
        success: function(vendor) {
            // Populate vendor details in the view modal
            $('#view-profile-picture').attr('src', vendor.profilePictureURL || 'https://ui-avatars.com/api/?name=' + encodeURIComponent(vendor.businessName) + '&background=random&color=fff');
            $('#view-business-name, #view-business-name-detail').text(vendor.businessName);
            $('#view-vendor-id').text('ID: ' + vendor.userId);
            $('#view-username').text(vendor.username);
            $('#view-email').text(vendor.email);
            $('#view-contact-person').text(vendor.contactPerson);
            $('#view-phone-number').text(vendor.phoneNumber || '—');
            $('#view-address').text(vendor.address || '—');
            $('#view-location').text(vendor.location || '—');
            $('#view-average-price').text(vendor.averagePrice ? `$${vendor.averagePrice.toFixed(2)}` : '—');
            $('#view-registration-date').text(formatDate(vendor.registrationDate));
            $('#view-last-login').text(formatDate(vendor.lastLogin));
            $('#view-description').text(vendor.description || 'No description provided.');
            
            // Set status badge
            $('#view-status-badge').removeClass().addClass('badge rounded-pill');
            switch(vendor.accountStatus) {
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
                    $('#view-status-badge').addClass('bg-warning text-dark').html('<i class="fas fa-clock me-1"></i> Pending Approval');
                    break;
            }
            
            // Set featured badge
            if (vendor.featured) {
                $('#view-featured-badge').show();
            } else {
                $('#view-featured-badge').hide();
            }
            
            // Load services tab data
            loadVendorServices(vendor);
            
            // Load portfolio tab data
            loadVendorPortfolio(vendor);
            
            // Load reviews tab data
            loadVendorReviews(vendor);
            
            // Sample activity log (would be replaced by real data in a production app)
            const activityLog = `
                <tr>
                    <td>2025-05-06 07:22:15</td>
                    <td>Login</td>
                    <td>Successful login from 192.168.1.105</td>
                </tr>
                <tr>
                    <td>2025-05-05 14:22:36</td>
                    <td>Profile Update</td>
                    <td>Updated business information</td>
                </tr>
                <tr>
                    <td>2025-05-03 09:15:42</td>
                    <td>Service Added</td>
                    <td>Added Photography service</td>
                </tr>
            `;
            
            $('#view-activity-log').html(activityLog);
            
            // Show the modal
            $('#viewVendorModal').modal('show');
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load vendor details');
        }
    });
}

/**
 * Load vendor services for view modal
 * @param {Object} vendor - Vendor object
 */
function loadVendorServices(vendor) {
    if (!vendor.serviceIds || vendor.serviceIds.length === 0) {
        $('#vendor-services-container').html(`
            <div class="alert alert-info">
                <i class="fas fa-info-circle me-2"></i>
                This vendor does not offer any services yet.
            </div>
        `);
        return;
    }
    
    // Show loading indicator
    $('#vendor-services-container').html(`
        <div class="text-center p-5 services-loading">
            <div class="spinner-border text-primary" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-3">Loading services...</p>
        </div>
    `);
    
    // Make AJAX request to get service details
    $.ajax({
        url: contextPath + '/ServiceManagementServlet',
        type: 'GET',
        data: {
            serviceIds: vendor.serviceIds.join(',')
        },
        dataType: 'json',
        success: function(services) {
            if (!services || services.length === 0) {
                $('#vendor-services-container').html(`
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        Could not load service details.
                    </div>
                `);
                return;
            }
            
            // Group services by category
            const categorizedServices = {};
            services.forEach(service => {
                if (!categorizedServices[service.category]) {
                    categorizedServices[service.category] = [];
                }
                categorizedServices[service.category].push(service);
            });
            
            let servicesHtml = '';
            
            for (const category in categorizedServices) {
                servicesHtml += `
                    <div class="mb-4">
                        <h6 class="text-uppercase fw-bold mb-3">${formatCategory(category)}</h6>
                        <div class="row">
                `;
                
                categorizedServices[category].forEach(service => {
                    servicesHtml += `
                        <div class="col-md-6 mb-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <div class="d-flex align-items-center mb-2">
                                        <div class="service-checkbox-icon me-2">
                                            <i class="${getServiceIcon(service.category)}"></i>
                                        </div>
                                        <h6 class="mb-0">${service.serviceName}</h6>
                                    </div>
                                    <p class="small text-muted">${service.description || 'No description available.'}</p>
                                    ${service.basePrice ? `<p class="mb-0"><span class="badge bg-success">$${service.basePrice.toFixed(2)}</span></p>` : ''}
                                </div>
                            </div>
                        </div>
                    `;
                });
                
                servicesHtml += '</div></div>';
            }
            
            $('#vendor-services-container').html(servicesHtml);
        },
        error: function(xhr, status, error) {
            $('#vendor-services-container').html(`
                <div class="alert alert-danger">
                    <i class="fas fa-exclamation-circle me-2"></i>
                    Error loading services: ${error}
                </div>
            `);
        }
    });
}

/**
 * Load vendor portfolio for view modal
 * @param {Object} vendor - Vendor object
 */
function loadVendorPortfolio(vendor) {
    if (!vendor.portfolioImages || vendor.portfolioImages.length === 0) {
        $('#view-portfolio-images').html(`
            <div class="text-center p-4">
                <i class="fas fa-image fa-3x text-muted mb-3"></i>
                <p>No portfolio images available.</p>
            </div>
        `);
        return;
    }
    
    let portfolioHtml = '';
    
    vendor.portfolioImages.forEach(imageUrl => {
        portfolioHtml += `
            <div class="portfolio-item">
                <img src="${imageUrl}" alt="Portfolio Image">
            </div>
        `;
    });
    
    $('#view-portfolio-images').html(portfolioHtml);
}

/**
 * Load vendor reviews for view modal
 * @param {Object} vendor - Vendor object
 */
function loadVendorReviews(vendor) {
    if (!vendor.reviews || vendor.reviews.length === 0) {
        $('#view-reviews').html(`
            <div class="text-center p-4">
                <i class="fas fa-star fa-3x text-muted mb-3"></i>
                <p>No reviews available.</p>
            </div>
        `);
        return;
    }
    
    let reviewsHtml = '';
    
    vendor.reviews.forEach(review => {
        const stars = Math.round(review.rating * 2) / 2; // Round to nearest 0.5
        let starsHtml = '';
        
        // Add full stars
        for (let i = 1; i <= Math.floor(stars); i++) {
            starsHtml += '<i class="fas fa-star text-warning"></i>';
        }
        
        // Add half star if needed
        if (stars % 1 !== 0) {
            starsHtml += '<i class="fas fa-star-half-alt text-warning"></i>';
        }
        
        // Add empty stars
        for (let i = Math.ceil(stars); i < 5; i++) {
            starsHtml += '<i class="far fa-star text-warning"></i>';
        }
        
        reviewsHtml += `
            <div class="review-item">
                <div class="review-header">
                    <div class="review-avatar">
                        <img src="https://ui-avatars.com/api/?name=User&background=random&color=fff" alt="User">
                    </div>
                    <div>
                        <p class="review-user">User ${review.userId}</p>
                        <p class="review-date">${formatDate(new Date().toISOString())}</p>
                    </div>
                    <div class="review-rating">
                        ${starsHtml}
                    </div>
                </div>
                <p class="review-content">${review.comment}</p>
            </div>
        `;
    });
    
    $('#view-reviews').html(reviewsHtml);
}

/**
 * Populate the edit vendor form
 * @param {String} vendorId - Vendor ID
 */
function populateEditVendorForm(vendorId) {
    // Get vendor data
    $.ajax({
        url: contextPath + '/VendorManagementServlet',
        type: 'GET',
        data: {
            vendorId: vendorId
        },
        dataType: 'json',
        success: function(vendor) {
            // Populate form fields
            $('#edit-vendor-id').val(vendor.userId);
            $('#edit-business-name').val(vendor.businessName);
            $('#edit-contact-person').val(vendor.contactPerson);
            $('#edit-username').val(vendor.username);
            $('#edit-email').val(vendor.email);
            $('#edit-phone-number').val(vendor.phoneNumber || '');
            $('#edit-address').val(vendor.address || '');
            $('#edit-description').val(vendor.description || '');
            $('#edit-location').val(vendor.location || '');
            $('#edit-status').val(vendor.accountStatus);
            $('#edit-average-price').val(vendor.averagePrice || 0);
            $('#edit-featured').prop('checked', vendor.featured || false);
            $('#edit-profile-picture').val(vendor.profilePictureURL || '');
            $('#edit-profile-preview').attr('src', vendor.profilePictureURL || '${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg');
            
            // Reset password fields
            $('#reset-password').prop('checked', false);
            $('#password-reset-fields').addClass('d-none');
            $('#new-password').val('');
            $('#confirm-password').val('');
            
            // Clear and populate portfolio images
            $('#edit-portfolio-container').empty();
            
            if (vendor.portfolioImages && vendor.portfolioImages.length > 0) {
                vendor.portfolioImages.forEach(imageUrl => {
                    addPortfolioImage(imageUrl, 'edit-portfolio-container');
                });
            } else {
                $('#edit-portfolio-container').html('<p class="text-muted">No portfolio images added yet.</p>');
            }
            
            // Check service checkboxes if available
            if (vendor.serviceIds && vendor.serviceIds.length > 0) {
                // Uncheck all first
                $('#edit-services-selection input[type="checkbox"]').prop('checked', false);
                
                // Check selected services
                vendor.serviceIds.forEach(serviceId => {
                    $(`#edit-service-${serviceId}`).prop('checked', true);
                });
            }
            
            // Update modal title and show
            $('#editVendorModalTitle').text('Edit Vendor: ' + vendor.businessName);
            $('#editVendorModal').modal('show');
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load vendor details');
        }
    });
}

/**
 * Confirm vendor deletion
 * @param {String} vendorId - Vendor ID
 */
function confirmDeleteVendor(vendorId) {
    // Get vendor name
    $.ajax({
        url: contextPath + '/VendorManagementServlet',
        type: 'GET',
        data: {
            vendorId: vendorId
        },
        dataType: 'json',
        success: function(vendor) {
            $('#delete-vendor-id').val(vendorId);
            $('#delete-vendor-name').text(vendor.businessName);
            $('#deleteVendorModal').modal('show');
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load vendor details');
        }
    });
}

/**
 * Show vendor approval modal
 * @param {String} vendorId - Vendor ID
 * @param {String} action - 'approve' or 'reject'
 */
function showApprovalModal(vendorId, action) {
    // Get vendor details
    $.ajax({
        url: contextPath + '/VendorManagementServlet',
        type: 'GET',
        data: {
            vendorId: vendorId
        },
        dataType: 'json',
        success: function(vendor) {
            // Populate modal
            $('#approval-vendor-id').val(vendorId);
            $('#approval-business-name').text(vendor.businessName);
			            $('#approval-profile-picture').attr('src', vendor.profilePictureURL || '${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg');
			            $('#approval-contact-details').text(`${vendor.contactPerson} | ${vendor.email}`);
			            $('#approval-note').val('');
			            
			            // Show modal
			            $('#vendorApprovalModal').modal('show');
			        },
			        error: function(xhr, status, error) {
			            handleAjaxError(xhr, 'Failed to load vendor details');
			        }
			    });
			}

			/**
			 * Create a new vendor
			 */
			function createVendor() {
			    // Get form data
			    const formData = {
			        businessName: $('#add-business-name').val(),
			        contactPerson: $('#add-contact-person').val(),
			        username: $('#add-username').val(),
			        email: $('#add-email').val(),
			        password: $('#add-password').val(),
			        phoneNumber: $('#add-phone-number').val(),
			        address: $('#add-address').val(),
			        description: $('#add-description').val(),
			        location: $('#add-location').val(),
			        accountStatus: $('#add-status').val(),
			        averagePrice: $('#add-average-price').val(),
			        featured: $('#add-featured').is(':checked'),
			        serviceIds: []
			    };
			    
			    // Get selected services
			    $('#add-services-selection input[type="checkbox"]:checked').each(function() {
			        formData.serviceIds.push($(this).val());
			    });
			    
			    // Get profile picture
			    if ($('#add-profile-url-option').is(':checked')) {
			        formData.profilePictureURL = $('#add-profile-picture').val();
			    } else if ($('#add-profile-upload').get(0).files.length > 0) {
			        // Handle file upload (in a real application, you would upload the file to a server first)
			        // This is simplified for the demo
			        const file = $('#add-profile-upload').get(0).files[0];
			        const reader = new FileReader();
			        reader.onloadend = function() {
			            formData.profilePictureURL = reader.result;
			            proceedWithCreate(formData);
			        };
			        reader.readAsDataURL(file);
			        return;
			    }
			    
			    // Get portfolio images
			    formData.portfolioImages = [];
			    $('#add-portfolio-container .portfolio-item input[name="portfolioImages[]"]').each(function() {
			        formData.portfolioImages.push($(this).val());
			    });
			    
			    proceedWithCreate(formData);
			}

			/**
			 * Proceed with vendor creation after handling file uploads
			 * @param {Object} formData - Form data for the new vendor
			 */
			function proceedWithCreate(formData) {
			    $.ajax({
			        url: contextPath + '/VendorManagementServlet',
			        type: 'POST',
			        contentType: 'application/json',
			        dataType: 'json',
			        data: JSON.stringify(formData),
			        success: function(response) {
			            $('#addVendorModal').modal('hide');
			            showToast('Success', 'Vendor created successfully', 'success');
			            loadVendors();
			            loadPendingApprovals();
			            resetAddVendorForm();
			        },
			        error: function(xhr, status, error) {
			            handleAjaxError(xhr, 'Failed to create vendor');
			        }
			    });
			}

			/**
			 * Update an existing vendor
			 */
			function updateVendor() {
			    const vendorId = $('#edit-vendor-id').val();
			    
			    // Get form data
			    const formData = {
			        userId: vendorId,
			        businessName: $('#edit-business-name').val(),
			        contactPerson: $('#edit-contact-person').val(),
			        username: $('#edit-username').val(),
			        email: $('#edit-email').val(),
			        phoneNumber: $('#edit-phone-number').val(),
			        address: $('#edit-address').val(),
			        description: $('#edit-description').val(),
			        location: $('#edit-location').val(),
			        accountStatus: $('#edit-status').val(),
			        averagePrice: $('#edit-average-price').val(),
			        featured: $('#edit-featured').is(':checked'),
			        serviceIds: []
			    };
			    
			    // Get selected services
			    $('#edit-services-selection input[type="checkbox"]:checked').each(function() {
			        formData.serviceIds.push($(this).val());
			    });
			    
			    // Add password if being reset
			    if ($('#reset-password').is(':checked')) {
			        formData.password = $('#new-password').val();
			    }
			    
			    // Get profile picture
			    if ($('#profile-url-option').is(':checked')) {
			        formData.profilePictureURL = $('#edit-profile-picture').val();
			    } else if ($('#edit-profile-upload').get(0).files.length > 0) {
			        // Handle file upload (in a real application, you would upload the file to a server first)
			        // This is simplified for the demo
			        const file = $('#edit-profile-upload').get(0).files[0];
			        const reader = new FileReader();
			        reader.onloadend = function() {
			            formData.profilePictureURL = reader.result;
			            proceedWithUpdate(formData);
			        };
			        reader.readAsDataURL(file);
			        return;
			    }
			    
			    // Get portfolio images
			    formData.portfolioImages = [];
			    $('#edit-portfolio-container .portfolio-item input[name="portfolioImages[]"]').each(function() {
			        formData.portfolioImages.push($(this).val());
			    });
			    
			    proceedWithUpdate(formData);
			}

			/**
			 * Proceed with vendor update after handling file uploads
			 * @param {Object} formData - Form data for the vendor update
			 */
			function proceedWithUpdate(formData) {
			    $.ajax({
			        url: contextPath + '/VendorManagementServlet',
			        type: 'PUT',
			        contentType: 'application/json',
			        dataType: 'json',
			        data: JSON.stringify(formData),
			        success: function(response) {
			            $('#editVendorModal').modal('hide');
			            showToast('Success', 'Vendor updated successfully', 'success');
			            loadVendors();
			            loadPendingApprovals();
			        },
			        error: function(xhr, status, error) {
			            handleAjaxError(xhr, 'Failed to update vendor');
			        }
			    });
			}

			/**
			 * Delete a vendor
			 * @param {String} vendorId - Vendor ID
			 */
			function deleteVendor(vendorId) {
			    $.ajax({
			        url: contextPath + '/VendorManagementServlet',
			        type: 'DELETE',
			        data: {
			            vendorId: vendorId
			        },
			        success: function(response) {
			            $('#deleteVendorModal').modal('hide');
			            showToast('Success', 'Vendor deleted successfully', 'success');
			            loadVendors();
			            loadPendingApprovals();
			        },
			        error: function(xhr, status, error) {
			            handleAjaxError(xhr, 'Failed to delete vendor');
			        }
			    });
			}

			/**
			 * Approve a vendor account
			 * @param {String} vendorId - Vendor ID
			 */
			function approveVendor(vendorId) {
			    const note = $('#approval-note').val();
			    
			    $.ajax({
			        url: contextPath + '/VendorManagementServlet/approve',
			        type: 'POST',
			        contentType: 'application/json',
			        dataType: 'json',
			        data: JSON.stringify({
			            vendorId: vendorId,
			            note: note
			        }),
			        success: function(response) {
			            $('#vendorApprovalModal').modal('hide');
			            showToast('Success', 'Vendor approved successfully', 'success');
			            loadVendors();
			            loadPendingApprovals();
			        },
			        error: function(xhr, status, error) {
			            handleAjaxError(xhr, 'Failed to approve vendor');
			        }
			    });
			}

			/**
			 * Reject a vendor account
			 * @param {String} vendorId - Vendor ID
			 */
			function rejectVendor(vendorId) {
			    const note = $('#approval-note').val();
			    
			    $.ajax({
			        url: contextPath + '/VendorManagementServlet/reject',
			        type: 'POST',
			        contentType: 'application/json',
			        dataType: 'json',
			        data: JSON.stringify({
			            vendorId: vendorId,
			            note: note
			        }),
			        success: function(response) {
			            $('#vendorApprovalModal').modal('hide');
			            showToast('Success', 'Vendor rejected successfully', 'success');
			            loadVendors();
			            loadPendingApprovals();
			        },
			        error: function(xhr, status, error) {
			            handleAjaxError(xhr, 'Failed to reject vendor');
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
			    const featured = $('#featured-filter').val();
			    const searchTerm = $('#search-vendors').val();
			    
			    // Prepare filter parameters
			    let params = {};
			    if (status) params.status = status;
			    if (category) params.category = category;
			    if (dateRange) params.dateRange = dateRange;
			    if (featured) params.featured = featured;
			    if (searchTerm) params.search = searchTerm;
			    
			    // Convert params object to query string
			    const queryString = Object.keys(params).map(key => key + '=' + encodeURIComponent(params[key])).join('&');
			    
			    // Make AJAX request with filters
			    $.ajax({
			        url: contextPath + '/VendorManagementServlet' + (queryString ? '?' + queryString : ''),
			        type: 'GET',
			        dataType: 'json',
			        success: function(data) {
			            populateVendorsTable(data);
			            populateVendorsCards(data);
			        },
			        error: function(xhr, status, error) {
			            handleAjaxError(xhr, 'Failed to filter vendors');
			        }
			    });
			}

			/**
			 * Execute bulk action on selected vendors
			 * @param {String} action - Action to perform (activate, deactivate, delete, featured, unfeatured, export)
			 */
			function executeBulkAction(action) {
			    const selectedIds = [];
			    
			    // Get selected vendor IDs
			    $('#vendors-table tbody input[type="checkbox"]:checked').each(function() {
			        selectedIds.push($(this).val());
			    });
			    
			    if (selectedIds.length === 0) {
			        showToast('Warning', 'No vendors selected', 'warning');
			        return;
			    }
			    
			    // Confirm bulk delete
			    if (action === 'delete') {
			        $('#bulk-delete-count').text(selectedIds.length);
			        $('#bulkDeleteModal').modal('show');
			        return;
			    }
			    
			    // Execute the action
			    $.ajax({
			        url: contextPath + '/VendorManagementServlet/bulk',
			        type: 'POST',
			        contentType: 'application/json',
			        dataType: 'json',
			        data: JSON.stringify({
			            action: action,
			            vendorIds: selectedIds
			        }),
			        success: function(response) {
			            showToast('Success', `Bulk action "${action}" completed successfully`, 'success');
			            loadVendors();
			            
			            // Hide bulk actions card
			            $('#bulk-actions-card').slideUp(300);
			            
			            // Uncheck "Select All" checkbox
			            $('#select-all-vendors').prop('checked', false);
			        },
			        error: function(xhr, status, error) {
			            handleAjaxError(xhr, `Failed to perform bulk action: ${action}`);
			        }
			    });
			}

			/**
			 * Execute bulk delete after confirmation
			 */
			function executeBulkDelete() {
			    const selectedIds = [];
			    
			    // Get selected vendor IDs
			    $('#vendors-table tbody input[type="checkbox"]:checked').each(function() {
			        selectedIds.push($(this).val());
			    });
			    
			    $.ajax({
			        url: contextPath + '/VendorManagementServlet/bulk',
			        type: 'POST',
			        contentType: 'application/json',
			        dataType: 'json',
			        data: JSON.stringify({
			            action: 'delete',
			            vendorIds: selectedIds
			        }),
			        success: function(response) {
			            $('#bulkDeleteModal').modal('hide');
			            showToast('Success', 'Selected vendors deleted successfully', 'success');
			            loadVendors();
			            
			            // Hide bulk actions card
			            $('#bulk-actions-card').slideUp(300);
			            
			            // Uncheck "Select All" checkbox
			            $('#select-all-vendors').prop('checked', false);
			        },
			        error: function(xhr, status, error) {
			            handleAjaxError(xhr, 'Failed to delete vendors');
			        }
			    });
			}

			/**
			 * Export vendors in the selected format
			 * @param {String} format - Export format (excel, csv, pdf)
			 */
			function exportVendors(format) {
			    // Get current filters
			    const status = $('#status-filter').val();
			    const category = $('#category-filter').val();
			    const dateRange = $('#date-range').val();
			    const featured = $('#featured-filter').val();
			    const searchTerm = $('#search-vendors').val();
			    
			    // Prepare export parameters
			    let params = { format: format };
			    if (status) params.status = status;
			    if (category) params.category = category;
			    if (dateRange) params.dateRange = dateRange;
			    if (featured) params.featured = featured;
			    if (searchTerm) params.search = searchTerm;
			    
			    // Convert params object to query string
			    const queryString = Object.keys(params).map(key => key + '=' + encodeURIComponent(params[key])).join('&');
			    
			    // Redirect to export URL (will trigger file download)
			    window.location.href = contextPath + '/VendorManagementServlet/export?' + queryString;
			}

			/**
			 * Reset the add vendor form
			 */
			function resetAddVendorForm() {
			    $('#add-vendor-form')[0].reset();
			    $('#add-vendor-form').removeClass('was-validated');
			    $('#add-profile-preview').attr('src', '${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg');
			    $('#add-portfolio-container').html('<p class="text-muted">No portfolio images added yet.</p>');
			    
			    // Reset tabs
			    $('#addVendorTabs .nav-link:first').tab('show');
			    
			    // Uncheck all service checkboxes
			    $('#add-services-selection input[type="checkbox"]').prop('checked', false);
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