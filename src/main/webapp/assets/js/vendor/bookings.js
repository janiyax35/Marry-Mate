/**
 * Vendor Bookings JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time (UTC): 2025-05-13 11:31:11
 * Current User: IT24102083
 */

document.addEventListener('DOMContentLoaded', function() {
    // Global variables
    let bookingsData = [];
    let calendar;
    let currentView = 'list'; // 'list' or 'calendar'
    let currentFilter = 'all'; // default filter
    let bookingsTable; // DataTable instance
    
    // Get context path for proper URL construction
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/vendor") || window.location.pathname.length);
    
    // Initialize DataTable - with check for existing instance
    if ($.fn.DataTable.isDataTable('#bookingsTable')) {
        // If table is already initialized, get the existing instance
        bookingsTable = $('#bookingsTable').DataTable();
    } else {
        // Initialize new DataTable
        bookingsTable = $('#bookingsTable').DataTable({
            responsive: true,
            order: [[3, 'desc']], // Sort by date by default
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
            language: {
                search: "",
                searchPlaceholder: "Search bookings..."
            },
            dom: 't<"row align-items-center"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>',
            columnDefs: [
                { orderable: false, targets: [7] } // Disable sorting for actions column
            ]
        });
    }
    
    // Toggle between list and calendar view
    $('#listViewBtn').on('click', function() {
        $('#bookingCalendarView').hide();
        $('#bookingListView').show();
        $('#listViewBtn').addClass('active');
        $('#calendarViewBtn').removeClass('active');
        currentView = 'list';
        
        // Adjust DataTable columns
        bookingsTable.columns.adjust().responsive.recalc();
    });
    
    $('#calendarViewBtn').on('click', function() {
        $('#bookingListView').hide();
        $('#bookingCalendarView').show();
        $('#calendarViewBtn').addClass('active');
        $('#listViewBtn').removeClass('active');
        currentView = 'calendar';
        
        // Render calendar if not already initialized
        if (!calendar) {
            initializeCalendar();
        } else {
            calendar.render();
        }
    });
    
    // Filter options
    $('.filter-option').on('click', function(e) {
        e.preventDefault();
        
        // Update active class
        $('.filter-option').removeClass('active');
        $(this).addClass('active');
        
        currentFilter = $(this).data('filter');
        $('#filterOptions').html(`<i class="fas fa-filter me-2"></i>${$(this).text()}`);
        
        // Apply filter
        filterBookings(currentFilter);
    });
    
    // Booking Search
    $('#bookingSearch').on('keyup', function() {
        bookingsTable.search($(this).val()).draw();
    });
    
    // Export bookings
    $('#exportBookingsBtn').on('click', function() {
        exportBookings();
    });
    
    // View booking details
    $(document).on('click', '.view-booking-btn', function() {
        const bookingId = $(this).data('booking-id');
        showBookingDetails(bookingId);
    });
    
    // Service-specific approve/reject within details modal
    $(document).on('click', '.approve-service-btn', function() {
        const bookingId = $(this).data('booking-id');
        const serviceId = $(this).data('service-id');
        showConfirmAction(bookingId, serviceId, 'approve');
    });
    
    $(document).on('click', '.reject-service-btn', function() {
        const bookingId = $(this).data('booking-id');
        const serviceId = $(this).data('service-id');
        showConfirmAction(bookingId, serviceId, 'reject');
    });
    
    // Direct approve/reject from table
    $(document).on('click', '.approve-booking-btn', function() {
        const bookingId = $(this).data('booking-id');
        const serviceId = $(this).data('service-id'); // New: get serviceId
        showConfirmAction(bookingId, serviceId, 'approve');
    });
    
    $(document).on('click', '.reject-booking-btn', function() {
        const bookingId = $(this).data('booking-id');
        const serviceId = $(this).data('service-id'); // New: get serviceId
        showConfirmAction(bookingId, serviceId, 'reject');
    });
    
    // Confirm action
    $('#confirmActionBtn').on('click', function() {
        const bookingId = $('#actionBookingId').val();
        const serviceBookingId = $('#actionServiceId').val(); // New: get serviceBookingId
        const actionType = $('#actionType').val();
        
        // Display loading indicator
        const actionBtn = $(this);
        const originalText = actionBtn.html();
        actionBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Processing...');
        actionBtn.prop('disabled', true);
        
        // Send request to the servlet
        $.ajax({
            url: contextPath + '/vendor/bookingservlet',
            method: 'POST',
            data: {
                action: actionType,
                bookingId: bookingId,
                serviceBookingId: serviceBookingId // New: send serviceBookingId
            },
            success: function(response) {
                if (response.status === 'success') {
                    actionBtn.html('<i class="fas fa-check me-2"></i> Completed!');
                    
                    setTimeout(function() {
                        actionBtn.html(originalText);
                        actionBtn.prop('disabled', false);
                        
                        // Close the modal
                        const modalInstance = bootstrap.Modal.getInstance(document.getElementById('confirmActionModal'));
                        modalInstance.hide();
                        
                        // Close the details modal if open
                        const detailsModal = bootstrap.Modal.getInstance(document.getElementById('bookingDetailsModal'));
                        if (detailsModal) {
                            detailsModal.hide();
                        }
                        
                        // Reload bookings
                        loadBookings();
                        
                        // Show success message
                        showAlert(`Service successfully ${actionType === 'approve' ? 'approved' : 'rejected'}!`, 
                            actionType === 'approve' ? 'success' : 'danger');
                    }, 1000);
                } else {
                    actionBtn.html(originalText);
                    actionBtn.prop('disabled', false);
                    showAlert('Error: ' + (response.message || 'Failed to process booking'), 'danger');
                }
            },
            error: function(xhr, status, error) {
                actionBtn.html(originalText);
                actionBtn.prop('disabled', false);
                showAlert('Error: ' + error, 'danger');
            }
        });
    });
    
    // Load bookings on page load
    loadBookings();
    
    /**
     * Function to load bookings from backend
     * Gets bookings for current vendor from session
     */
    function loadBookings() {
        $('.booking-loading').show();
        $('#noBookingsMessage').hide();
        
        // Prepare request URL - vendorId will be retrieved from session by servlet
        let requestUrl = contextPath + '/vendor/bookingservlet';
        
        console.log('Loading bookings from: ' + requestUrl);
        
        // Get bookings from the servlet with timeout
        $.ajax({
            url: requestUrl,
            method: 'GET',
            dataType: 'json',
            timeout: 15000, // 15 second timeout
            success: function(data) {
                console.log('Bookings loaded:', Array.isArray(data) ? data.length : 'Not an array');
                
                // Handle empty or invalid response
                if (!data || (Array.isArray(data) && data.length === 0)) {
                    // Show empty state for no bookings
                    $('#bookingListView').hide();
                    $('#bookingCalendarView').hide();
                    $('#noBookingsMessage').show();
                    $('.booking-loading').hide();
                    
                    // Update stats with zeros
                    updateBookingStats([]);
                    return;
                }
                
                // Store the bookings data
                bookingsData = Array.isArray(data) ? data : [];
                
                // Update stats
                updateBookingStats(bookingsData);
                
                // Clear existing data
                bookingsTable.clear();
                
                if (bookingsData.length === 0) {
                    // Show empty state
                    $('#bookingListView').hide();
                    $('#bookingCalendarView').hide();
                    $('#noBookingsMessage').show();
                    $('.booking-loading').hide();
                    return;
                }
                
                // Hide empty state
                $('#noBookingsMessage').hide();
                
                // Show the appropriate view based on current selection
                if (currentView === 'list') {
                    $('#bookingListView').show();
                    $('#bookingCalendarView').hide();
                } else {
                    $('#bookingListView').hide();
                    $('#bookingCalendarView').show();
                }
                
                // Filter bookings if filter is set
                if (currentFilter !== 'all') {
                    filterBookings(currentFilter);
                } else {
                    // Render all bookings
                    renderBookings(bookingsData);
                }
                
                $('.booking-loading').hide();
            },
            error: function(xhr, status, error) {
                console.error('Error loading bookings:', error);
                $('.booking-loading').hide();
                
                if (xhr.status === 401) {
                    showAlert('Session expired. Please log in again.', 'warning');
                    // Optionally redirect to login page
                    // window.location.href = contextPath + '/login.jsp';
                } else {
                    showAlert('Error loading bookings: ' + error, 'danger');
                }
                
                // Show empty state on error
                $('#bookingListView').hide();
                $('#bookingCalendarView').hide();
                $('#noBookingsMessage').show();
                
                // Update stats with zeros on error
                updateBookingStats([]);
            }
        });
    }
    
    /**
     * Function to render bookings in table view - updated for service-specific handling
     * For this vendor, we'll show each service as its own row
     */
    function renderBookings(bookings) {
        bookingsTable.clear();
        
        // Create rows for all vendor's services across all bookings
        bookings.forEach(booking => {
            // Filter services to only include those for this vendor
            const vendorServices = booking.bookedServices.filter(service => {
                // We assume the vendorId is available through session, so we're showing all services returned by backend
                // The backend should have already filtered to only return bookings with services for this vendor
                return true;
            });
            
            // Add a row for each service this vendor provides
            vendorServices.forEach(service => {
                bookingsTable.row.add([
                    booking.bookingId,
                    booking.clientName || `User #${booking.userId}`,
                    service.serviceName,
                    booking.weddingDate,
                    getStatusBadge(service.status || "pending"), // Service status
                    getPaymentBadge(booking.paymentStatus),
                    `$${formatNumber(service.serviceTotal || 0)}`,
                    getActionButtons(booking, service)
                ]);
            });
        });
        
        bookingsTable.draw();
        
        // Update calendar if initialized
        if (calendar) {
            updateCalendar();
        }
    }
    
    /**
     * Function to filter bookings based on service status
     */
    function filterBookings(filter) {
        if (filter === 'all') {
            renderBookings(bookingsData);
            return;
        }
        
        // Filter bookings to only include those with at least one service matching the filter
        const filteredBookings = bookingsData.filter(booking => {
            // For each booking, check if it has at least one service with the matching status
            return booking.bookedServices && booking.bookedServices.some(service => {
                return service.status === filter;
            });
        });
        
        renderBookings(filteredBookings);
        
        // Show no bookings message if filtered list is empty
        if (filteredBookings.length === 0) {
            bookingsTable.clear().draw();
            
            bookingsTable.row.add([
                '',
                '',
                '',
                `<div class="text-center py-3">
                    <i class="fas fa-filter fa-2x text-muted mb-2"></i>
                    <p class="mb-0">No services with '${filter}' status found.</p>
                </div>`,
                '',
                '',
                '',
                ''
            ]).draw();
        }
    }
    
    /**
     * Function to update booking stats - now counts services
     */
    function updateBookingStats(bookings) {
        let totalServices = 0;
        let pendingServices = 0;
        let confirmedServices = 0;
        let totalRev = 0;
        
        // Count services across all bookings
        bookings.forEach(booking => {
            if (booking.bookedServices) {
                booking.bookedServices.forEach(service => {
                    totalServices++;
                    if (service.status === 'pending') pendingServices++;
                    if (service.status === 'confirmed') confirmedServices++;
                    totalRev += parseFloat(service.serviceTotal || 0);
                });
            }
        });
        
        $('#totalBookings').text(totalServices);
        $('#pendingBookings').text(pendingServices);
        $('#confirmedBookings').text(confirmedServices);
        $('#totalRevenue').text(`$${formatNumber(totalRev)}`);
    }
    
    /**
     * Function to show booking details - updated to show all services
     */
    function showBookingDetails(bookingId) {
        // Reset modal content
        $('#bookingDetailsLoader').show();
        $('#bookingDetailsContent').hide();
        $('#bookingActionFooter').hide();
        
        // Show modal
        const detailsModal = new bootstrap.Modal(document.getElementById('bookingDetailsModal'));
        detailsModal.show();
        
        // Find booking in data
        const booking = bookingsData.find(b => b.bookingId === bookingId);
        
        if (!booking) {
            // Handle booking not found
            $('#bookingDetailsLoader').html(`
                <div class="text-center py-5">
                    <i class="fas fa-exclamation-circle fa-3x text-danger mb-3"></i>
                    <p>Booking not found. Please try again.</p>
                </div>
            `);
            return;
        }
        
        // Fill in booking details
        $('#detailBookingId').text(booking.bookingId);
        $('#detailStatus').text(capitalizeFirstLetter(booking.status));
        $('#detailStatus').removeClass().addClass(`badge rounded-pill status-badge-${booking.status}`);
        $('#detailPayment').text(capitalizeFirstLetter(booking.paymentStatus));
        $('#detailPayment').removeClass().addClass(`badge rounded-pill payment-badge-${booking.paymentStatus}`);
        $('#detailBookingDate').text(booking.bookingDate);
        
        // Event details
        $('#detailEventDate').text(booking.weddingDate);
        $('#detailEventTime').text(`${booking.eventStartTime} - ${booking.eventEndTime}`);
        $('#detailGuestCount').text(booking.totalGuestCount);
        
        // Client details
        $('#detailClientId').text(booking.userId);
        $('#detailClientName').text(booking.clientName || 'Not available');
        $('#detailClientEmail').text(booking.clientEmail || 'Not available');
        $('#detailClientPhone').text(booking.clientPhone || 'Not available');
        
        // Location
        $('#detailEventLocation').text(booking.eventLocation);
        
        // Financial details
        $('#detailTotalPrice').text(`$${formatNumber(booking.totalBookingPrice || 0)}`);
        $('#detailPaymentStatus').text(capitalizeFirstLetter(booking.paymentStatus));
        $('#detailDepositPaid').text(booking.depositPaid ? 'Yes' : 'No');
        $('#detailContractSigned').text(booking.contractSigned ? 'Signed' : 'Not signed');
        
        // Special requirements
        $('#detailSpecialRequirements').text(booking.specialRequirements || 'No special requirements specified.');
        
        // NEW: Services list - show all services with their statuses
        let servicesHtml = '';
        if (booking.bookedServices && booking.bookedServices.length > 0) {
            servicesHtml = `
                <div class="services-section mb-4">
                    <h6 class="text-uppercase text-muted mb-3">Services Included</h6>
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
                            <tbody>`;
            
            booking.bookedServices.forEach(service => {
                const isCurrentVendorService = true; // Assume if we can see it, it's our service
                
                servicesHtml += `
                    <tr>
                        <td>
                            <div class="fw-bold">${service.serviceName}</div>
                            <small class="text-muted">${service.hours} hours, ${service.guestCount} guests</small>
                        </td>
                        <td>${service.vendorId}</td>
                        <td>$${formatNumber(service.serviceTotal)}</td>
                        <td>${getStatusBadge(service.status || 'pending')}</td>
                        <td>${isCurrentVendorService && (service.status === 'pending') ? `
                            <div class="btn-group btn-group-sm">
                                <button class="btn btn-outline-success approve-service-btn" 
                                    data-booking-id="${booking.bookingId}" 
                                    data-service-id="${service.serviceBookingId}">
                                    <i class="fas fa-check"></i>
                                </button>
                                <button class="btn btn-outline-danger reject-service-btn"
                                    data-booking-id="${booking.bookingId}"
                                    data-service-id="${service.serviceBookingId}">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>` : ''}
                        </td>
                    </tr>`;
            });
            
            servicesHtml += `
                        </tbody>
                    </table>
                </div>
            </div>`;
        } else {
            servicesHtml = `
                <div class="services-section mb-4">
                    <h6 class="text-uppercase text-muted mb-2">Services Included</h6>
                    <p>No services found for this booking.</p>
                </div>`;
        }
        
        // Insert services section after client info
        $('#detailServicesSection').remove(); // Remove if exists
        $('<div id="detailServicesSection">' + servicesHtml + '</div>')
            .insertAfter('.client-info-section');
        
        // Hide footer since we have individual service buttons
        $('#bookingActionFooter').hide();
        
        // Show content, hide loader
        $('#bookingDetailsLoader').hide();
        $('#bookingDetailsContent').show();
    }
    
    /**
     * Function to show confirmation dialog for service actions
     */
    function showConfirmAction(bookingId, serviceBookingId, actionType) {
        $('#actionBookingId').val(bookingId);
        $('#actionServiceId').val(serviceBookingId);
        $('#actionType').val(actionType);
        
        if (actionType === 'approve') {
            $('#confirmActionTitle').text('Confirm Service Approval');
            $('#confirmActionMessage').text('Are you sure you want to approve this service?');
            $('#confirmActionBtn').removeClass('btn-danger').addClass('btn-success');
            $('#confirmActionBtn').text('Approve');
        } else {
            $('#confirmActionTitle').text('Confirm Service Rejection');
            $('#confirmActionMessage').text('Are you sure you want to reject this service? This action cannot be undone.');
            $('#confirmActionBtn').removeClass('btn-success').addClass('btn-danger');
            $('#confirmActionBtn').text('Reject');
        }
        
        // Show modal
        const confirmModal = new bootstrap.Modal(document.getElementById('confirmActionModal'));
        confirmModal.show();
    }
    
    /**
     * Function to initialize calendar
     */
    function initializeCalendar() {
        const calendarEl = document.getElementById('bookingsCalendar');
        
        calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek,listMonth'
            },
            events: getCalendarEvents(),
            eventClick: function(info) {
                const bookingId = info.event.id;
                showBookingDetails(bookingId);
            }
        });
        
        calendar.render();
    }
    
    /**
     * Function to update calendar events
     */
    function updateCalendar() {
        if (calendar) {
            calendar.removeAllEvents();
            calendar.addEventSource(getCalendarEvents());
        }
    }
    
    /**
     * Function to get calendar events from bookings data
     */
    function getCalendarEvents() {
        let events = [];
        
        // Create an event for each service
        bookingsData.forEach(booking => {
            if (booking.bookedServices) {
                booking.bookedServices.forEach(service => {
                    events.push({
                        id: booking.bookingId,
                        title: service.serviceName,
                        start: booking.weddingDate,
                        allDay: true,
                        className: `fc-event-${service.status || 'pending'}`,
                        extendedProps: {
                            status: service.status || 'pending',
                            client: booking.clientName || `User #${booking.userId}`,
                            amount: service.serviceTotal,
                            serviceId: service.serviceBookingId
                        }
                    });
                });
            }
        });
        
        return events;
    }
    
    /**
     * Helper function to get action buttons HTML - updated for service-level actions
     */
    function getActionButtons(booking, service) {
        // Different actions based on service status
        if (service.status === 'pending') {
            return `
                <div class="dropdown">
                    <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <div class="dropdown-menu dropdown-menu-end">
                        <a class="dropdown-item view-booking-btn" href="#" data-booking-id="${booking.bookingId}">
                            <i class="fas fa-eye me-2"></i> View Details
                        </a>
                        <a class="dropdown-item approve-booking-btn" href="#" 
                           data-booking-id="${booking.bookingId}" 
                           data-service-id="${service.serviceBookingId}">
                            <i class="fas fa-check-circle me-2"></i> Approve Service
                        </a>
                        <a class="dropdown-item text-danger reject-booking-btn" href="#" 
                           data-booking-id="${booking.bookingId}" 
                           data-service-id="${service.serviceBookingId}">
                            <i class="fas fa-times-circle me-2"></i> Reject Service
                        </a>
                    </div>
                </div>
            `;
        } else {
            return `
                <div class="dropdown">
                    <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <div class="dropdown-menu dropdown-menu-end">
                        <a class="dropdown-item view-booking-btn" href="#" data-booking-id="${booking.bookingId}">
                            <i class="fas fa-eye me-2"></i> View Details
                        </a>
                        <a class="dropdown-item" href="#" onclick="window.print()">
                            <i class="fas fa-print me-2"></i> Print Details
                        </a>
                    </div>
                </div>
            `;
        }
    }
    
    /**
     * Helper function to get status badge HTML
     */
    function getStatusBadge(status) {
        const statusLabels = {
            'pending': 'Pending',
            'confirmed': 'Confirmed',
            'cancelled': 'Cancelled',
            'completed': 'Completed'
        };
        
        return `<span class="badge rounded-pill status-badge-${status}">${statusLabels[status] || status}</span>`;
    }
    
    /**
     * Helper function to get payment badge HTML
     */
    function getPaymentBadge(paymentStatus) {
        const paymentLabels = {
            'pending': 'Pending',
            'partial': 'Partial',
            'complete': 'Complete',
            'refunded': 'Refunded'
        };
        
        return `<span class="badge rounded-pill payment-badge-${paymentStatus}">${paymentLabels[paymentStatus] || paymentStatus}</span>`;
    }
    
    /**
     * Function to show alert message
     */
    function showAlert(message, type = 'success') {
        const alertHtml = `
            <div class="alert alert-${type} alert-dismissible fade show" role="alert">
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        `;
        
        // Insert after page header
        $(alertHtml).insertAfter('.page-header').delay(5000).fadeOut(500, function() {
            $(this).remove();
        });
    }
    
    /**
     * Helper function to capitalize first letter
     */
    function capitalizeFirstLetter(string) {
        if (!string) return '';
        return string.charAt(0).toUpperCase() + string.slice(1);
    }
    
    /**
     * Helper function to format numbers with commas
     */
    function formatNumber(num) {
        return parseFloat(num).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
    }
    
    /**
     * Function to export bookings
     */
    function exportBookings() {
        // Display loading indicator
        const exportBtn = $('#exportBookingsBtn');
        const originalText = exportBtn.html();
        exportBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Exporting...');
        exportBtn.prop('disabled', true);
        
        // Generate CSV data
        let csvContent = "data:text/csv;charset=utf-8,";
        csvContent += "Booking ID,Client,Service,Date,Status,Payment,Amount\n";
        
        // Add filtered bookings to CSV - now service-by-service
        const bookingsToExport = bookingsData;
        
        bookingsToExport.forEach(booking => {
            if (booking.bookedServices) {
                booking.bookedServices.forEach(service => {
                    const row = [
                        booking.bookingId,
                        booking.clientName || `User #${booking.userId}`,
                        service.serviceName,
                        booking.weddingDate,
                        service.status || 'pending',
                        booking.paymentStatus,
                        service.serviceTotal
                    ].map(value => `"${value}"`).join(',');
                    csvContent += row + "\n";
                });
            }
        });
        
        // Create download link
        const encodedUri = encodeURI(csvContent);
        const link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", "bookings_export.csv");
        document.body.appendChild(link);
        
        // Trigger download
        setTimeout(function() {
            link.click();
            document.body.removeChild(link);
            
            exportBtn.html('<i class="fas fa-check me-2"></i> Exported!');
            
            setTimeout(function() {
                exportBtn.html(originalText);
                exportBtn.prop('disabled', false);
                
                // Show success message
                showAlert('Bookings exported successfully!', 'success');
            }, 1000);
        }, 500);
    }
});