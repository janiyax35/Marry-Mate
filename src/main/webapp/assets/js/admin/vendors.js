/**
 * Admin Vendor Management JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-01 05:03:29
 * Current User: IT24102137
 */

document.addEventListener('DOMContentLoaded', function() {
    'use strict';
    
    // Initialize DataTable
    const vendorsTable = $('#vendorsTable').DataTable({
        responsive: true,
        language: {
            search: "",
            searchPlaceholder: "Search vendors...",
            lengthMenu: "Show _MENU_ vendors",
            info: "Showing _START_ to _END_ of _TOTAL_ vendors",
            infoEmpty: "Showing 0 to 0 of 0 vendors",
            infoFiltered: "(filtered from _MAX_ total vendors)",
            zeroRecords: "No matching vendors found"
        },
        dom: 'rtip', // Removes default search and shows processing, table, info and pagination
        pageLength: 10,
        lengthChange: false,
        columnDefs: [
            { orderable: false, targets: [0, 9] }, // Disable sorting for checkbox and actions columns
            { width: "40px", targets: 0 },
            { width: "50px", targets: 1 },
            { width: "200px", targets: 2 },
            { width: "100px", targets: 3 },
            { width: "90px", targets: 5 },
            { width: "80px", targets: 6 },
            { width: "110px", targets: 8 },
            { width: "120px", targets: 9 }
        ],
        order: [[1, 'asc']] // Default sort by ID column
    });
    
    // Custom search functionality
    $('#vendorSearchInput').on('keyup', function() {
        vendorsTable.search($(this).val()).draw();
        updateBatchActionButtons();
    });
    
    // Category filter
    $('#categoryFilter').on('change', function() {
        const category = $(this).val();
        
        if (category === '') {
            vendorsTable
                .column(3)
                .search('')
                .draw();
        } else {
            vendorsTable
                .column(3)
                .search(category)
                .draw();
        }
        
        updateBatchActionButtons();
    });
    
    // Status filter
    $('#statusFilter').on('change', function() {
        const status = $(this).val();
        
        if (status === '') {
            vendorsTable
                .column(8)
                .search('')
                .draw();
        } else {
            vendorsTable
                .column(8)
                .search(status)
                .draw();
        }
        
        updateBatchActionButtons();
    });
    
    // Reset filters
    $('#resetFiltersBtn').on('click', function() {
        $('#vendorSearchInput').val('');
        $('#categoryFilter').val('');
        $('#statusFilter').val('');
        
        vendorsTable
            .search('')
            .columns().search('')
            .draw();
            
        updateBatchActionButtons();
    });
    
    // Select all vendors checkbox
    $('#selectAllVendors').on('change', function() {
        const isChecked = $(this).prop('checked');
        $('.vendor-select-checkbox').prop('checked', isChecked);
        updateBatchActionButtons();
    });
    
    // Individual vendor checkbox
    $(document).on('change', '.vendor-select-checkbox', function() {
        updateBatchActionButtons();
        updateSelectAllCheckbox();
    });
    
    // Update "Select All" checkbox state based on individual checkboxes
    function updateSelectAllCheckbox() {
        const totalCheckboxes = $('.vendor-select-checkbox').length;
        const totalChecked = $('.vendor-select-checkbox:checked').length;
        
        $('#selectAllVendors').prop('checked', totalChecked > 0 && totalChecked === totalCheckboxes);
        $('#selectAllVendors').prop('indeterminate', totalChecked > 0 && totalChecked < totalCheckboxes);
    }
    
    // Update batch action buttons state
    function updateBatchActionButtons() {
        const selectedCount = $('.vendor-select-checkbox:checked').length;
        
        if (selectedCount > 0) {
            $('#batchApproveBtn, #batchRejectBtn, #batchActiveBtn, #batchInactiveBtn, #batchDeleteBtn').prop('disabled', false);
            $('.selected-count').text(`${selectedCount} vendor${selectedCount > 1 ? 's' : ''} selected`).removeClass('d-none');
        } else {
            $('#batchApproveBtn, #batchRejectBtn, #batchActiveBtn, #batchInactiveBtn, #batchDeleteBtn').prop('disabled', true);
            $('.selected-count').addClass('d-none');
        }
    }
    
    // Add Service Area functionality
    $('#addServiceAreaBtn').on('click', function() {
        const serviceAreaContainer = $('.service-areas-container');
        const serviceAreaItem = serviceAreaContainer.find('.service-area-item:first').clone();
        
        serviceAreaItem.find('input').val('');
        serviceAreaItem.find('.remove-service-area').prop('disabled', false);
        
        serviceAreaContainer.append(serviceAreaItem);
    });
    
    // Remove Service Area functionality
    $(document).on('click', '.remove-service-area', function() {
        $(this).closest('.service-area-item').remove();
    });
    
    // Form validation for add vendor
    $('#addVendorForm').on('submit', function(event) {
        event.preventDefault();
        
        const form = $(this)[0];
        if (form.checkValidity() === false) {
            event.stopPropagation();
        } else {
            // Form is valid, simulate submission
            saveVendor();
        }
        
        $(this).addClass('was-validated');
    });
    
    // Save vendor function (simulate AJAX request)
    $('#saveVendorBtn').on('click', function() {
        const form = $('#addVendorForm')[0];
        if (form.checkValidity() === false) {
            $('#addVendorForm').addClass('was-validated');
            return;
        }
        
        // Show loading state
        const btn = $(this);
        const originalText = btn.html();
        btn.html('<i class="fas fa-spinner fa-spin me-1"></i> Adding...');
        btn.prop('disabled', true);
        
        // Simulate AJAX request with delay
        setTimeout(() => {
            // Reset button state
            btn.html(originalText);
            btn.prop('disabled', false);
            
            // Close modal
            $('#addVendorModal').modal('hide');
            
            // Show success message
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: 'Vendor has been created successfully.',
                confirmButtonColor: '#1a365d'
            }).then(() => {
                // Reset form
                $('#addVendorForm')[0].reset();
                $('#addVendorForm').removeClass('was-validated');
                
                // In a real system, you would refresh the data or add the new vendor to the table
            });
        }, 1500);
    });
    
    // View vendor details
    $(document).on('click', '.view-vendor', function() {
        const vendorId = $(this).data('vendor-id');
        
        // Here you would normally fetch vendor details via AJAX
        // For demonstration, we'll use the data from the table row
        const row = $(this).closest('tr');
        const vendorName = row.find('.vendor-name').text();
        const vendorCategory = row.find('td:eq(3) .category-badge').text();
        const vendorEmail = row.find('td:eq(4)').text();
        const vendorRating = row.find('td:eq(5) .vendor-rating span').text();
        const vendorBookings = row.find('td:eq(6)').text();
        const vendorRegDate = row.find('td:eq(7)').text();
        const vendorStatus = row.find('td:eq(8) .status-badge').text();
        
        // Populate vendor details in the modal
        $('#vendorViewName').text(vendorName);
        $('#vendorViewBusinessName').text(vendorName);
        $('#vendorViewId').text(vendorId);
        $('#vendorViewCategory, #vendorViewCategoryDetail').text(vendorCategory);
        $('#vendorViewEmail').text(vendorEmail);
        $('#vendorViewRegDate').text(vendorRegDate);
        $('#vendorViewStatus').text(vendorStatus);
        $('#vendorViewStatusDetail').text(vendorStatus);
        $('#vendorViewRating').text(vendorRating);
        $('#vendorViewTotalBookings').text(vendorBookings);
        $('#vendorViewLogo').attr('src', `https://ui-avatars.com/api/?name=${encodeURIComponent(vendorName)}&background=random`);
        
        // Set appropriate status badge class
        $('#vendorViewStatus').removeClass('bg-success bg-warning bg-danger bg-secondary');
        if (vendorStatus === 'Active') {
            $('#vendorViewStatus').addClass('bg-success');
        } else if (vendorStatus === 'Pending') {
            $('#vendorViewStatus').addClass('bg-warning');
        } else if (vendorStatus === 'Inactive') {
            $('#vendorViewStatus').addClass('bg-secondary');
        } else {
            $('#vendorViewStatus').addClass('bg-danger');
        }
        
        // Set demo data for display
        $('#vendorViewPhone').text('+1 (555) 123-4567');
        $('#vendorViewAddress').text('123 Main Street, Anytown, USA');
        $('#vendorViewWebsite').html('<a href="https://example.com" target="_blank">https://example.com</a>');
        $('#vendorViewDescription').text('This is a sample vendor specializing in wedding venues. We provide beautiful indoor and outdoor spaces for your special day, with comprehensive services including catering, decoration, and coordination.');
        $('#vendorViewReviews').text(`(${vendorBookings} reviews)`);
        $('#vendorViewActiveBookings').text(Math.floor(vendorBookings * 0.4));
        $('#vendorViewRatingCount').text(vendorBookings);
        $('#vendorViewProfileViews').text(Math.floor(vendorBookings * 20));
        
        // Generate star rating
        generateStarRating(parseFloat(vendorRating.split('/')[0]));
        
        // Open the modal
        $('#viewVendorModal').modal('show');
    });
    
    // Generate star rating display
    function generateStarRating(rating) {
        const starsContainer = $('#viewVendorModal .vendor-rating .stars');
        starsContainer.empty();
        
        // Generate full stars
        const fullStars = Math.floor(rating);
        for (let i = 0; i < fullStars; i++) {
            starsContainer.append('<i class="fas fa-star"></i>');
        }
        
        // Add half star if needed
        if (rating % 1 >= 0.5) {
            starsContainer.append('<i class="fas fa-star-half-alt"></i>');
        }
        
        // Add empty stars to reach 5 stars total
        const emptyStars = 5 - Math.ceil(rating);
        for (let i = 0; i < emptyStars; i++) {
            starsContainer.append('<i class="far fa-star"></i>');
        }
    }
    
    // Edit vendor from view modal
    $('.edit-vendor-from-view').on('click', function() {
        // Close view modal and open edit modal
        $('#viewVendorModal').modal('hide');
        
        // Here you would populate the edit form and show the edit modal
        // For demonstration, we'll just show an alert
        setTimeout(() => {
            Swal.fire({
                icon: 'info',
                title: 'Edit Vendor',
                text: 'In a real system, this would open the edit vendor form.',
                confirmButtonColor: '#1a365d'
            });
        }, 500);
    });
    
    // Edit vendor
    $(document).on('click', '.edit-vendor', function() {
        const vendorId = $(this).data('vendor-id');
        
        // Here you would fetch vendor data and populate a form
        Swal.fire({
            icon: 'info',
            title: 'Edit Vendor',
            text: `Editing vendor ID: ${vendorId}. In a real system, this would open the edit vendor form.`,
            confirmButtonColor: '#1a365d'
        });
    });
    
    // Approve vendor
    $(document).on('click', '.approve-vendor', function() {
        const vendorId = $(this).data('vendor-id');
        const row = $(this).closest('tr');
        
        Swal.fire({
            title: 'Approve Vendor?',
            text: "This vendor account will be activated and visible to users.",
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#27ae60',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, approve it!'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Approving...',
                    text: 'Please wait while we approve this vendor.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Update UI
                    row.find('.status-badge')
                        .removeClass('bg-warning bg-danger bg-secondary')
                        .addClass('bg-success')
                        .text('Active');
                    
                    // Replace the action buttons
                    const actionsCell = row.find('.action-buttons');
                    const newButtons = `
                        <button class="btn btn-sm btn-icon view-vendor" data-vendor-id="${vendorId}" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-icon edit-vendor" data-vendor-id="${vendorId}" title="Edit Vendor">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-icon deactivate-vendor" data-vendor-id="${vendorId}" title="Deactivate Vendor">
                            <i class="fas fa-toggle-off"></i>
                        </button>
                        <button class="btn btn-sm btn-icon delete-vendor" data-vendor-id="${vendorId}" title="Delete Vendor">
                            <i class="fas fa-trash"></i>
                        </button>
                    `;
                    actionsCell.html(newButtons);
                    
                    // Remove from pending approval section if it exists
                    $(`#pendingApprovalSection [data-vendor-id="${vendorId}"]`).remove();
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendor Approved!',
                        text: 'The vendor account has been approved successfully.',
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Reject vendor
    $(document).on('click', '.reject-vendor', function() {
        const vendorId = $(this).data('vendor-id');
        const row = $(this).closest('tr');
        
        Swal.fire({
            title: 'Reject Vendor?',
            text: "This vendor account will be rejected and not visible to users.",
            input: 'textarea',
            inputLabel: 'Reason for rejection (will be sent to vendor)',
            inputPlaceholder: 'Enter the reason for rejection...',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#e74c3c',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, reject it!',
            inputValidator: (value) => {
                if (!value) {
                    return 'Please provide a reason for rejection';
                }
            }
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Rejecting...',
                    text: 'Please wait while we process your request.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Update UI
                    row.find('.status-badge')
                        .removeClass('bg-warning bg-success bg-secondary')
                        .addClass('bg-danger')
                        .text('Rejected');
                    
                    // Replace the action buttons
                    const actionsCell = row.find('.action-buttons');
                    const newButtons = `
                        <button class="btn btn-sm btn-icon view-vendor" data-vendor-id="${vendorId}" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-icon edit-vendor" data-vendor-id="${vendorId}" title="Edit Vendor">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-icon activate-vendor" data-vendor-id="${vendorId}" title="Activate Vendor">
                            <i class="fas fa-toggle-on"></i>
                        </button>
                        <button class="btn btn-sm btn-icon delete-vendor" data-vendor-id="${vendorId}" title="Delete Vendor">
                            <i class="fas fa-trash"></i>
                        </button>
                    `;
                    actionsCell.html(newButtons);
                    
                    // Remove from pending approval section if it exists
                    $(`#pendingApprovalSection [data-vendor-id="${vendorId}"]`).remove();
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendor Rejected',
                        text: 'An email has been sent to notify the vendor of the rejection.',
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Activate vendor
    $(document).on('click', '.activate-vendor', function() {
        const vendorId = $(this).data('vendor-id');
        const row = $(this).closest('tr');
        
        Swal.fire({
            title: 'Activate Vendor?',
            text: "This vendor account will be activated and visible to users.",
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#27ae60',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, activate it!'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Activating...',
                    text: 'Please wait while we activate this vendor.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Update UI
                    row.find('.status-badge')
                        .removeClass('bg-warning bg-danger bg-secondary')
                        .addClass('bg-success')
                        .text('Active');
                    
                    // Replace the action buttons
                    const actionsCell = row.find('.action-buttons');
                    const newButtons = `
                        <button class="btn btn-sm btn-icon view-vendor" data-vendor-id="${vendorId}" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-icon edit-vendor" data-vendor-id="${vendorId}" title="Edit Vendor">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-icon deactivate-vendor" data-vendor-id="${vendorId}" title="Deactivate Vendor">
                            <i class="fas fa-toggle-off"></i>
                        </button>
                        <button class="btn btn-sm btn-icon delete-vendor" data-vendor-id="${vendorId}" title="Delete Vendor">
                            <i class="fas fa-trash"></i>
                        </button>
                    `;
                    actionsCell.html(newButtons);
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendor Activated!',
                        text: 'The vendor account has been activated successfully.',
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Deactivate vendor
    $(document).on('click', '.deactivate-vendor', function() {
        const vendorId = $(this).data('vendor-id');
        const row = $(this).closest('tr');
        
        Swal.fire({
            title: 'Deactivate Vendor?',
            text: "This vendor account will be temporarily deactivated and hidden from users.",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#f39c12',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, deactivate it!'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Deactivating...',
                    text: 'Please wait while we deactivate this vendor.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Update UI
                    row.find('.status-badge')
                        .removeClass('bg-warning bg-danger bg-success')
                        .addClass('bg-secondary')
                        .text('Inactive');
                    
                    // Replace the action buttons
                    const actionsCell = row.find('.action-buttons');
                    const newButtons = `
                        <button class="btn btn-sm btn-icon view-vendor" data-vendor-id="${vendorId}" title="View Details">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-icon edit-vendor" data-vendor-id="${vendorId}" title="Edit Vendor">
                            <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-sm btn-icon activate-vendor" data-vendor-id="${vendorId}" title="Activate Vendor">
                            <i class="fas fa-toggle-on"></i>
                        </button>
                        <button class="btn btn-sm btn-icon delete-vendor" data-vendor-id="${vendorId}" title="Delete Vendor">
                            <i class="fas fa-trash"></i>
                        </button>
                    `;
                    actionsCell.html(newButtons);
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendor Deactivated',
                        text: 'The vendor account has been deactivated successfully.',
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Delete vendor
    $(document).on('click', '.delete-vendor', function() {
        const vendorId = $(this).data('vendor-id');
        const row = $(this).closest('tr');
        
        Swal.fire({
            title: 'Delete Vendor?',
            text: "This action cannot be undone. All vendor data will be permanently deleted.",
            icon: 'error',
            showCancelButton: true,
            confirmButtonColor: '#e74c3c',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, delete it!'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Deleting...',
                    text: 'Please wait while we delete this vendor account.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Remove row from table
                    vendorsTable.row(row).remove().draw();
                    
                    // Update check state
                    updateBatchActionButtons();
                    updateSelectAllCheckbox();
                    
                    // Remove from pending approval section if it exists
                    $(`#pendingApprovalSection [data-vendor-id="${vendorId}"]`).remove();
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendor Deleted!',
                        text: 'The vendor account has been deleted successfully.',
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Batch Actions - Approve Vendors
    $('#batchApproveBtn').on('click', function() {
        const selectedIds = [];
        const selectedRows = [];
        
        $('.vendor-select-checkbox:checked').each(function() {
            selectedIds.push($(this).val());
            selectedRows.push($(this).closest('tr'));
        });
        
        if (selectedIds.length === 0) return;
        
        Swal.fire({
            title: 'Approve Selected Vendors?',
            text: `You are about to approve ${selectedIds.length} vendor accounts.`,
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#27ae60',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, approve them!'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Approving Vendors...',
                    text: 'Please wait while we process your request.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Update UI for each selected vendor
                    selectedRows.forEach((row) => {
                        const vendorId = $(row).data('vendor-id');
                        
                        // Update status badge
                        $(row).find('.status-badge')
                            .removeClass('bg-warning bg-danger bg-secondary')
                            .addClass('bg-success')
                            .text('Active');
                        
                        // Replace approve/reject buttons with deactivate if they exist
                        const actionsCell = $(row).find('.action-buttons');
                        if (actionsCell.find('.approve-vendor, .reject-vendor').length > 0) {
                            const newButtons = `
                                <button class="btn btn-sm btn-icon view-vendor" data-vendor-id="${vendorId}" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button class="btn btn-sm btn-icon edit-vendor" data-vendor-id="${vendorId}" title="Edit Vendor">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-sm btn-icon deactivate-vendor" data-vendor-id="${vendorId}" title="Deactivate Vendor">
                                    <i class="fas fa-toggle-off"></i>
                                </button>
                                <button class="btn btn-sm btn-icon delete-vendor" data-vendor-id="${vendorId}" title="Delete Vendor">
                                    <i class="fas fa-trash"></i>
                                </button>
                            `;
                            actionsCell.html(newButtons);
                        }
                    });
                    
                    // Uncheck all checkboxes
                    $('.vendor-select-checkbox, #selectAllVendors').prop('checked', false);
                    updateBatchActionButtons();
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendors Approved!',
                        text: `${selectedIds.length} vendor accounts have been approved successfully.`,
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Batch Actions - Reject Vendors
    $('#batchRejectBtn').on('click', function() {
        const selectedIds = [];
        const selectedRows = [];
        
        $('.vendor-select-checkbox:checked').each(function() {
            selectedIds.push($(this).val());
            selectedRows.push($(this).closest('tr'));
        });
        
        if (selectedIds.length === 0) return;
        
        Swal.fire({
            title: 'Reject Selected Vendors?',
            text: `You are about to reject ${selectedIds.length} vendor accounts.`,
            input: 'textarea',
            inputLabel: 'Reason for rejection (will be sent to vendors)',
            inputPlaceholder: 'Enter the reason for rejection...',
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#e74c3c',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, reject them!',
            inputValidator: (value) => {
                if (!value) {
                    return 'Please provide a reason for rejection';
                }
            }
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Rejecting Vendors...',
                    text: 'Please wait while we process your request.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Update UI for each selected vendor
                    selectedRows.forEach((row) => {
                        const vendorId = $(row).data('vendor-id');
                        
                        // Update status badge
                        $(row).find('.status-badge')
                            .removeClass('bg-warning bg-success bg-secondary')
                            .addClass('bg-danger')
                            .text('Rejected');
                        
                        // Replace approve/deactivate buttons with activate if they exist
                        const actionsCell = $(row).find('.action-buttons');
                        if (actionsCell.find('.approve-vendor, .reject-vendor, .deactivate-vendor').length > 0) {
                            const newButtons = `
                                <button class="btn btn-sm btn-icon view-vendor" data-vendor-id="${vendorId}" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button class="btn btn-sm btn-icon edit-vendor" data-vendor-id="${vendorId}" title="Edit Vendor">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-sm btn-icon activate-vendor" data-vendor-id="${vendorId}" title="Activate Vendor">
                                    <i class="fas fa-toggle-on"></i>
                                </button>
                                <button class="btn btn-sm btn-icon delete-vendor" data-vendor-id="${vendorId}" title="Delete Vendor">
                                    <i class="fas fa-trash"></i>
                                </button>
                            `;
                            actionsCell.html(newButtons);
                        }
                    });
                    
                    // Uncheck all checkboxes
                    $('.vendor-select-checkbox, #selectAllVendors').prop('checked', false);
                    updateBatchActionButtons();
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendors Rejected!',
                        text: `${selectedIds.length} vendor accounts have been rejected successfully.`,
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Batch Actions - Set Active
    $('#batchActiveBtn').on('click', function() {
        const selectedIds = [];
        const selectedRows = [];
        
        $('.vendor-select-checkbox:checked').each(function() {
            selectedIds.push($(this).val());
            selectedRows.push($(this).closest('tr'));
        });
        
        if (selectedIds.length === 0) return;
        
        Swal.fire({
            title: 'Activate Selected Vendors?',
            text: `You are about to activate ${selectedIds.length} vendor accounts.`,
            icon: 'question',
            showCancelButton: true,
            confirmButtonColor: '#27ae60',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, activate them!'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Activating Vendors...',
                    text: 'Please wait while we process your request.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Update UI for each selected vendor
                    selectedRows.forEach((row) => {
                        const vendorId = $(row).data('vendor-id');
                        
                        // Update status badge
                        $(row).find('.status-badge')
                            .removeClass('bg-warning bg-danger bg-secondary')
                            .addClass('bg-success')
                            .text('Active');
                        
                        // Replace activate button with deactivate if it exists
                        const actionsCell = $(row).find('.action-buttons');
                        if (actionsCell.find('.activate-vendor').length > 0) {
                            const newButtons = `
                                <button class="btn btn-sm btn-icon view-vendor" data-vendor-id="${vendorId}" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button class="btn btn-sm btn-icon edit-vendor" data-vendor-id="${vendorId}" title="Edit Vendor">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-sm btn-icon deactivate-vendor" data-vendor-id="${vendorId}" title="Deactivate Vendor">
                                    <i class="fas fa-toggle-off"></i>
                                </button>
                                <button class="btn btn-sm btn-icon delete-vendor" data-vendor-id="${vendorId}" title="Delete Vendor">
                                    <i class="fas fa-trash"></i>
                                </button>
                            `;
                            actionsCell.html(newButtons);
                        }
                    });
                    
                    // Uncheck all checkboxes
                    $('.vendor-select-checkbox, #selectAllVendors').prop('checked', false);
                    updateBatchActionButtons();
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendors Activated!',
                        text: `${selectedIds.length} vendor accounts have been activated successfully.`,
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Batch Actions - Set Inactive
    $('#batchInactiveBtn').on('click', function() {
        const selectedIds = [];
        const selectedRows = [];
        
        $('.vendor-select-checkbox:checked').each(function() {
            selectedIds.push($(this).val());
            selectedRows.push($(this).closest('tr'));
        });
        
        if (selectedIds.length === 0) return;
        
        Swal.fire({
            title: 'Deactivate Selected Vendors?',
            text: `You are about to deactivate ${selectedIds.length} vendor accounts.`,
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#f39c12',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, deactivate them!'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Deactivating Vendors...',
                    text: 'Please wait while we process your request.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Update UI for each selected vendor
                    selectedRows.forEach((row) => {
                        const vendorId = $(row).data('vendor-id');
                        
                        // Update status badge
                        $(row).find('.status-badge')
                            .removeClass('bg-warning bg-danger bg-success')
                            .addClass('bg-secondary')
                            .text('Inactive');
                        
                        // Replace deactivate button with activate if it exists
                        const actionsCell = $(row).find('.action-buttons');
                        if (actionsCell.find('.deactivate-vendor').length > 0) {
                            const newButtons = `
                                <button class="btn btn-sm btn-icon view-vendor" data-vendor-id="${vendorId}" title="View Details">
                                    <i class="fas fa-eye"></i>
                                </button>
                                <button class="btn btn-sm btn-icon edit-vendor" data-vendor-id="${vendorId}" title="Edit Vendor">
                                    <i class="fas fa-edit"></i>
                                </button>
                                <button class="btn btn-sm btn-icon activate-vendor" data-vendor-id="${vendorId}" title="Activate Vendor">
                                    <i class="fas fa-toggle-on"></i>
                                </button>
                                <button class="btn btn-sm btn-icon delete-vendor" data-vendor-id="${vendorId}" title="Delete Vendor">
                                    <i class="fas fa-trash"></i>
                                </button>
                            `;
                            actionsCell.html(newButtons);
                        }
                    });
                    
                    // Uncheck all checkboxes
                    $('.vendor-select-checkbox, #selectAllVendors').prop('checked', false);
                    updateBatchActionButtons();
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendors Deactivated!',
                        text: `${selectedIds.length} vendor accounts have been deactivated successfully.`,
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Batch Actions - Delete
    $('#batchDeleteBtn').on('click', function() {
        const selectedIds = [];
        const selectedRows = [];
        
        $('.vendor-select-checkbox:checked').each(function() {
            selectedIds.push($(this).val());
            selectedRows.push($(this).closest('tr'));
        });
        
        if (selectedIds.length === 0) return;
        
        Swal.fire({
            title: 'Delete Selected Vendors?',
            text: `You are about to permanently delete ${selectedIds.length} vendor accounts. This action cannot be undone.`,
            icon: 'error',
            showCancelButton: true,
            confirmButtonColor: '#e74c3c',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Yes, delete them!'
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Deleting Vendors...',
                    text: 'Please wait while we process your request.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate AJAX request with delay
                setTimeout(() => {
                    // Remove rows from table
                    vendorsTable.rows(selectedRows).remove().draw();
                    
                    // Update check state
                    $('#selectAllVendors').prop('checked', false);
                    updateBatchActionButtons();
                    
                    // Update the counts (this would normally be updated from the server)
                    updateDashboardCounts();
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Vendors Deleted!',
                        text: `${selectedIds.length} vendor accounts have been deleted successfully.`,
                        confirmButtonColor: '#1a365d'
                    });
                }, 1500);
            }
        });
    });
    
    // Export vendors
    $('#exportVendorsBtn').on('click', function() {
        Swal.fire({
            title: 'Export Vendors',
            text: 'Select your preferred format:',
            imageUrl: 'https://img.icons8.com/color/96/export-excel.png',
            imageWidth: 80,
            imageHeight: 80,
            showCancelButton: true,
            confirmButtonColor: '#1a365d',
            cancelButtonColor: '#95a5a6',
            confirmButtonText: 'Export',
            input: 'radio',
            inputOptions: {
                'excel': 'Excel (.xlsx)',
                'csv': 'CSV (.csv)',
                'pdf': 'PDF (.pdf)'
            },
            inputValue: 'excel',
            customClass: {
                input: 'form-check-input'
            }
        }).then((result) => {
            if (result.isConfirmed) {
                // Show loading state
                Swal.fire({
                    title: 'Generating Export...',
                    text: 'Please wait while we prepare your file.',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
                
                // Simulate export with delay
                setTimeout(() => {
                    const format = result.value;
                    let message = '';
                    
                    switch(format) {
                        case 'excel':
                            message = 'The vendor data has been exported as an Excel file.';
                            break;
                        case 'csv':
                            message = 'The vendor data has been exported as a CSV file.';
                            break;
                        case 'pdf':
                            message = 'The vendor data has been exported as a PDF file.';
                            break;
                    }
                    
                    Swal.fire({
                        icon: 'success',
                        title: 'Export Complete!',
                        text: message,
                        confirmButtonColor: '#1a365d'
                    });
                    
                    // In a real system, you would trigger a file download here
                }, 2000);
            }
        });
    });
    
    // Initialize Charts
    initVendorCharts();
    
    // Function to update dashboard counts
    function updateDashboardCounts() {
        // This function would normally make an AJAX call to get updated counts
        // For demonstration purposes, we'll just recalculate based on the table data
        
        let active = 0;
        let pending = 0;
        let inactive = 0;
        let rejected = 0;
        
        $('#vendorsTable tbody tr').each(function() {
            const status = $(this).find('.status-badge').text();
            
            if (status === 'Active') {
                active++;
            } else if (status === 'Pending') {
                pending++;
            } else if (status === 'Inactive') {
                inactive++;
            } else if (status === 'Rejected') {
                rejected++;
            }
        });
        
        // Update stats at the top of the page
        const total = active + pending + inactive + rejected;
        const totalVendorStat = $('.stat-card.vendor-total-stat .stat-card-value');
        const activeVendorStat = $('.stat-card.vendor-active-stat .stat-card-value');
        const pendingVendorStat = $('.stat-card.vendor-pending-stat .stat-card-value');
        const otherVendorStat = $('.stat-card.vendor-other-stat .stat-card-value');
        
        if (totalVendorStat.length) totalVendorStat.text(total);
        if (activeVendorStat.length) activeVendorStat.text(active);
        if (pendingVendorStat.length) pendingVendorStat.text(pending);
        if (otherVendorStat.length) otherVendorStat.text(inactive + rejected);
        
        // Update alert badge on pending stat card
        if (pending > 0) {
            $('.vendor-pending-stat .stat-alert').removeClass('d-none');
        } else {
            $('.vendor-pending-stat .stat-alert').addClass('d-none');
        }
        
        // Update charts to reflect new data
        updateCategoryChart();
    }
    
    // Function to initialize vendor charts
    function initVendorCharts() {
        // Category Distribution Chart
        initCategoryChart();
    }
    
    // Initialize Category Chart
    function initCategoryChart() {
        const categoryChartCtx = document.getElementById('categoryChart');
        if (!categoryChartCtx) return;
        
        // Count vendors by category
        const categoryData = {};
        $('#vendorsTable tbody tr').each(function() {
            const category = $(this).find('td:eq(3) .category-badge').text();
            if (category) {
                categoryData[category] = (categoryData[category] || 0) + 1;
            }
        });
        
        // Prepare chart data
        const categories = Object.keys(categoryData);
        const counts = Object.values(categoryData);
        const colors = [
            '#1a365d', '#c8b273', '#2d5a92', '#e0d4a9', 
            '#27ae60', '#3498db', '#e74c3c', '#9b59b6',
            '#f1c40f', '#34495e', '#e67e22', '#16a085'
        ];
        
        // Create chart
        window.categoryChart = new Chart(categoryChartCtx, {
            type: 'pie',
            data: {
                labels: categories,
                datasets: [{
                    data: counts,
                    backgroundColor: colors.slice(0, categories.length),
                    borderWidth: 2,
                    borderColor: '#ffffff'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            font: {
                                family: "'Montserrat', sans-serif",
                                size: 12
                            },
                            padding: 15,
                            usePointStyle: true
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(255, 255, 255, 0.9)',
                        titleColor: '#1a365d',
                        bodyColor: '#1a365d',
                        titleFont: {
                            family: "'Playfair Display', serif",
                            size: 14,
                            weight: 'bold'
                        },
                        bodyFont: {
                            family: "'Montserrat', sans-serif",
                            size: 12
                        },
                        padding: 12,
                        boxPadding: 5,
                        borderColor: 'rgba(0, 0, 0, 0.1)',
                        borderWidth: 1,
                        callbacks: {
                            label: function(context) {
                                const value = context.raw;
                                const total = context.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                                const percentage = Math.round((value / total) * 100);
                                return ` ${context.label}: ${percentage}% (${value})`;
                            }
                        }
                    }
                }
            }
        });
    }
    
    // Update Category Chart
    function updateCategoryChart() {
        if (!window.categoryChart) return;
        
        // Count vendors by category
        const categoryData = {};
        $('#vendorsTable tbody tr').each(function() {
            const category = $(this).find('td:eq(3) .category-badge').text();
            if (category) {
                categoryData[category] = (categoryData[category] || 0) + 1;
            }
        });
        
        // Update chart data
        window.categoryChart.data.labels = Object.keys(categoryData);
        window.categoryChart.data.datasets[0].data = Object.values(categoryData);
        
        // Update colors if needed
        const colors = [
            '#1a365d', '#c8b273', '#2d5a92', '#e0d4a9', 
            '#27ae60', '#3498db', '#e74c3c', '#9b59b6',
            '#f1c40f', '#34495e', '#e67e22', '#16a085'
        ];
        window.categoryChart.data.datasets[0].backgroundColor = colors.slice(0, Object.keys(categoryData).length);
        
        // Update chart
        window.categoryChart.update();
    }
});