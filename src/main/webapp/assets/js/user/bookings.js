/**
 * User Bookings JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time (UTC - YYYY-MM-DD HH:MM:SS formatted): 2025-05-18 08:33:03
 * Current User's Login: IT24102137
 */

document.addEventListener('DOMContentLoaded', function() {
    // Global variables
    let bookingsData = [];
    let currentFilter = 'all'; // default filter
    let bookingsTable; // DataTable instance
    let currentBookingId = null; // For tracking which booking is viewed in detail
    let currentServiceId = null; // For tracking which service is viewed in detail
    
    // Get context path for proper URL construction
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/user"));
    console.log("Context path determined as:", contextPath);
    
    // Initialize DataTable - with check for existing instance
    if ($.fn.DataTable.isDataTable('#bookingsTable')) {
        // If table is already initialized, get the existing instance
        bookingsTable = $('#bookingsTable').DataTable();
    } else {
        // Initialize new DataTable
        bookingsTable = $('#bookingsTable').DataTable({
            responsive: true,
            order: [[3, 'asc']], // Sort by date ascending by default
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
    
    // Booking Search with highlighting
    $('#bookingSearch').on('keyup', function() {
        const searchTerm = $(this).val().toLowerCase();
        
        if (searchTerm.length > 0) {
            // Custom search with highlighting
            bookingsTable.rows().every(function() {
                const rowData = this.data();
                let match = false;
                
                // Check each cell for match
                for (let i = 0; i < rowData.length - 1; i++) { // Skip actions column
                    const cellText = $(rowData[i]).text().toLowerCase();
                    if (cellText.includes(searchTerm)) {
                        match = true;
                        
                        // Add highlighting to match
                        const highlighted = rowData[i].replace(
                            new RegExp("(" + searchTerm + ")", "gi"), 
                            '<mark>$1</mark>'
                        );
                        $(this.node()).find(`td:eq(${i})`).html(highlighted);
                    } else {
                        // Remove highlighting if no match
                        const originalText = $(rowData[i]).text();
                        $(this.node()).find(`td:eq(${i})`).text(originalText);
                    }
                }
                
                // Show/hide row based on match
                if (match) {
                    $(this.node()).show();
                } else {
                    $(this.node()).hide();
                }
            });
        } else {
            // Reset search and restore original display
            bookingsTable.search('').draw();
            
            // Restore proper filter if active
            if (currentFilter !== 'all') {
                filterBookings(currentFilter);
            }
        }
    });
    
    // Refresh button
    $('#refreshBookingsBtn').on('click', function() {
        const btn = $(this).find('i');
        btn.addClass('btn-refresh-animate');
        loadBookings();
        setTimeout(() => btn.removeClass('btn-refresh-animate'), 1000);
    });
    
    // Export bookings
    $('#exportBookingsBtn').on('click', function() {
        exportBookings();
    });
    
    // Export single booking
    $('#exportSingleBookingBtn').on('click', function() {
        if (currentBookingId) {
            exportSingleBooking(currentBookingId);
        }
    });
    
    // View booking details
    $(document).on('click', '.view-booking-btn', function() {
        const bookingId = $(this).data('booking-id');
        currentBookingId = bookingId;
        showBookingDetails(bookingId);
    });
    
    // View service options
    $(document).on('click', '.view-service-options-btn', function() {
        const bookingId = $(this).data('booking-id');
        const serviceId = $(this).data('service-id');
        currentBookingId = bookingId;
        currentServiceId = serviceId;
        showServiceOptions(bookingId, serviceId);
    });
    
    // Update cancel button inside service options modal
    $(document).on('shown.bs.modal', '#serviceOptionsModal', function() {
        if (currentBookingId && currentServiceId) {
            const cancelBtn = $('#optionsCancelServiceBtn');
            cancelBtn.data('booking-id', currentBookingId);
            cancelBtn.data('service-id', currentServiceId);
            
            // Hide cancel button if service is not pending
            const booking = bookingsData.find(b => b.bookingId === currentBookingId);
            if (booking && booking.bookedServices) {
                const service = booking.bookedServices.find(s => s.serviceBookingId === currentServiceId);
                if (service && service.status !== 'pending') {
                    cancelBtn.hide();
                } else {
                    cancelBtn.show();
                }
            }
        }
    });
    
    // Cancel booking / service
    $(document).on('click', '.cancel-booking-btn', function() {
        const bookingId = $(this).data('booking-id');
        const serviceId = $(this).data('service-id');
        
        $('#cancelBookingId').val(bookingId);
        $('#cancelServiceId').val(serviceId);
        
        if (serviceId) {
            $('#confirmCancelMessage').text('Are you sure you want to cancel this service? This action cannot be undone.');
        } else {
            $('#confirmCancelMessage').text('Are you sure you want to cancel this entire booking? This action cannot be undone.');
        }
        
        // Show modal
        const confirmModal = new bootstrap.Modal(document.getElementById('confirmCancelModal'));
        confirmModal.show();
    });
    
    // Confirm cancel action
    $('#confirmCancelBtn').on('click', function() {
        const bookingId = $('#cancelBookingId').val();
        const serviceId = $('#cancelServiceId').val();
        
        // Display loading indicator
        const actionBtn = $(this);
        const originalText = actionBtn.html();
        actionBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Processing...');
        actionBtn.prop('disabled', true);
        
        // UPDATED: Proper URL construction for the servlet
        let requestUrl = contextPath ? contextPath + '/user/bookingservlet' : '/user/bookingservlet';
        
        // Send cancellation request
        $.ajax({
            url: requestUrl,
            method: 'POST',
            data: {
                action: 'cancel',
                bookingId: bookingId,
                serviceBookingId: serviceId
            },
            success: function(response) {
                if (response.status === 'success') {
                    actionBtn.html('<i class="fas fa-check me-2"></i> Done!');
                    
                    setTimeout(function() {
                        actionBtn.html(originalText);
                        actionBtn.prop('disabled', false);
                        
                        // Close the modal
                        const modalInstance = bootstrap.Modal.getInstance(document.getElementById('confirmCancelModal'));
                        modalInstance.hide();
                        
                        // Close the details modal if open
                        const detailsModal = bootstrap.Modal.getInstance(document.getElementById('bookingDetailsModal'));
                        if (detailsModal) {
                            detailsModal.hide();
                        }
                        
                        // Close the service options modal if open
                        const serviceOptionsModal = bootstrap.Modal.getInstance(document.getElementById('serviceOptionsModal'));
                        if (serviceOptionsModal) {
                            serviceOptionsModal.hide();
                        }
                        
                        // Reload bookings
                        loadBookings();
                        
                        // Show success message
                        showAlert(serviceId ? 'Service successfully cancelled!' : 'Booking successfully cancelled!', 'success');
                    }, 1000);
                } else {
                    actionBtn.html(originalText);
                    actionBtn.prop('disabled', false);
                    showAlert('Error: ' + (response.message || 'Failed to process cancellation'), 'danger');
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
     */
    function loadBookings() {
        $('.booking-loading').show();
        $('#noBookingsMessage').hide();
        
        // UPDATED: Proper URL construction for the servlet
        let requestUrl = contextPath ? contextPath + '/user/bookingservlet' : '/user/bookingservlet';
        
        console.log('Loading bookings from: ' + requestUrl);
        
        // Get bookings from the servlet with timeout
        $.ajax({
            url: requestUrl,
            method: 'GET',
            dataType: 'json',
            timeout: 15000, // 15 second timeout
            success: function(data) {
                console.log('Bookings loaded:', data);
                
                // Handle empty or invalid response
                if (!data || (Array.isArray(data) && data.length === 0)) {
                    // Show empty state for no bookings
                    $('#bookingListView').hide();
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
                    $('#noBookingsMessage').show();
                    $('.booking-loading').hide();
                    return;
                }
                
                // Hide empty state
                $('#noBookingsMessage').hide();
                $('#bookingListView').show();
                
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
                console.error('Status:', status);
                console.error('Response:', xhr.responseText);
                
                // Display error message in the loading cell
                $('#bookingsTableBody').html(`
                    <tr>
                        <td colspan="8" class="text-center py-5">
                            <div class="text-danger">
                                <i class="fas fa-exclamation-circle fa-3x mb-3"></i>
                                <p>Error loading bookings: ${error}</p>
                                <p>Status: ${xhr.status} ${xhr.statusText}</p>
                                <button class="btn btn-primary mt-3" onclick="window.location.reload()">
                                    <i class="fas fa-sync-alt me-2"></i>Reload Page
                                </button>
                            </div>
                        </td>
                    </tr>
                `);
                
                if (xhr.status === 401) {
                    showAlert('Session expired. Please log in again.', 'warning');
                } else {
                    showAlert('Error loading bookings: ' + error, 'danger');
                }
                
                // Update stats with zeros on error
                updateBookingStats([]);
            }
        });
    }
    
    /**
     * Function to render bookings in table view
     */
    function renderBookings(bookings) {
        bookingsTable.clear();
        
        // Create flattened view of each service booking
        let flattenedBookings = [];
        
        bookings.forEach(booking => {
            // For each booking, get all services
            if (booking.bookedServices && booking.bookedServices.length > 0) {
                booking.bookedServices.forEach(service => {
                    flattenedBookings.push({
                        bookingId: booking.bookingId,
                        booking: booking,
                        service: service,
                        weddingDate: booking.weddingDate,
                        eventStartTime: booking.eventStartTime,
                        paymentStatus: booking.paymentStatus
                    });
                });
            } else {
                // If no services, still show the booking
                flattenedBookings.push({
                    bookingId: booking.bookingId,
                    booking: booking,
                    service: null,
                    weddingDate: booking.weddingDate,
                    eventStartTime: booking.eventStartTime,
                    paymentStatus: booking.paymentStatus
                });
            }
        });
        
        // Now add each flattened booking to the table
        flattenedBookings.forEach(item => {
            // Service column with name and selected options
            let serviceHtml = '';
            let servicePrice = 0;
            
            if (item.service) {
                // Service name
                serviceHtml = `<div class="fw-bold">${item.service.serviceName}</div>`;
                
                // Add duration if available
                if (item.service.hours) {
                    serviceHtml += `<div class="small text-muted">${item.service.hours} hours</div>`;
                }
                
                // Add selected options (truncated for main table)
                if (item.service.selectedOptions && item.service.selectedOptions.length > 0) {
                    serviceHtml += `<div class="small mt-1">Options: ${item.service.selectedOptions.length} selected</div>`;
                }
                
                // Calculate service price correctly
                servicePrice = calculateServicePrice(item.service);
            } else {
                serviceHtml = 'No service details';
                // Use booking total price if no service
                servicePrice = parseFloat(item.booking.totalBookingPrice || 0);
            }

            bookingsTable.row.add([
                item.bookingId,
                serviceHtml,
                item.service ? (item.service.vendorName || 'Vendor #' + item.service.vendorId) : 'N/A',
                formatEventDate(item.weddingDate, item.eventStartTime),
                item.service ? getStatusBadge(item.service.status || "pending") : getStatusBadge(item.booking.status || "pending"),
                getPaymentBadge(item.paymentStatus),
                formatCurrency(servicePrice),
                getActionButtons(item.bookingId, item.service)
            ]);
        });
        
        bookingsTable.draw();
    }
    
    /**
     * Function to show service options details
     */
    function showServiceOptions(bookingId, serviceId) {
        // Reset modal content
        $('#serviceOptionsLoader').show();
        $('#serviceOptionsContent').hide();
        
        // Show modal
        const serviceOptionsModal = new bootstrap.Modal(document.getElementById('serviceOptionsModal'));
        serviceOptionsModal.show();
        
        // Find booking and service in data
        const booking = bookingsData.find(b => b.bookingId === bookingId);
        
        if (!booking || !booking.bookedServices) {
            // Handle booking not found
            $('#serviceOptionsLoader').html(`
                <div class="text-center py-5">
                    <i class="fas fa-exclamation-circle fa-3x text-danger mb-3"></i>
                    <p>Booking not found. Please try again.</p>
                </div>
            `);
            return;
        }
        
        const service = booking.bookedServices.find(s => s.serviceBookingId === serviceId);
        
        if (!service) {
            // Handle service not found
            $('#serviceOptionsLoader').html(`
                <div class="text-center py-5">
                    <i class="fas fa-exclamation-circle fa-3x text-danger mb-3"></i>
                    <p>Service not found. Please try again.</p>
                </div>
            `);
            return;
        }
        
        // Fill in service details
        $('#optionsServiceName').text(service.serviceName);
        $('#optionsServiceId').text(serviceId);
        $('#optionsBookingId').text(bookingId);
        $('#optionsStatus').text(capitalizeFirstLetter(service.status || 'pending'));
        $('#optionsStatus').removeClass().addClass(`badge rounded-pill status-badge-${service.status || 'pending'}`);
        
        // Fill in service base info
        $('#optionsBasePrice').text(formatCurrency(service.basePrice || 0));
        $('#optionsHours').text(service.hours || 'N/A');
        $('#optionsPriceModel').text(capitalizeFirstLetter(service.priceModel || 'standard'));
        
        // Additional hours/guests section
        let additionalInfoHtml = '';
        
        if (service.additionalHours > 0) {
            additionalInfoHtml += `
                <div class="mb-2">
                    <span class="fw-bold">Additional Hours:</span> ${service.additionalHours} 
                    (${formatCurrency(service.additionalHoursPrice)})
                </div>
            `;
        }
        
        if (service.additionalGuests > 0) {
            additionalInfoHtml += `
                <div class="mb-2">
                    <span class="fw-bold">Additional Guests:</span> ${service.additionalGuests} 
                    (${formatCurrency(service.additionalGuestsPrice)})
                </div>
            `;
        }
        
        if (additionalInfoHtml) {
            $('#optionsAdditionalInfo').html(additionalInfoHtml);
            $('#optionsAdditionalInfoSection').show();
        } else {
            $('#optionsAdditionalInfoSection').hide();
        }
        
        // Selected options list
        if (service.selectedOptions && service.selectedOptions.length > 0) {
            $('#selectedOptionsList').empty();
            
            service.selectedOptions.forEach((option, index) => {
                $('#selectedOptionsList').append(`
                    <tr>
                        <td>${index + 1}</td>
                        <td>${option.name}</td>
                        <td class="text-end">${formatCurrency(option.price || 0)}</td>
                    </tr>
                `);
            });
            
            // Add total row
            const optionsTotal = service.selectedOptions.reduce((sum, option) => sum + parseFloat(option.price || 0), 0);
            $('#selectedOptionsList').append(`
                <tr class="table-light fw-bold">
                    <td colspan="2">Options Subtotal</td>
                    <td class="text-end">${formatCurrency(optionsTotal)}</td>
                </tr>
            `);
            
            $('#selectedOptionsSection').show();
        } else {
            $('#selectedOptionsSection').hide();
            $('#selectedOptionsList').html(`
                <tr>
                    <td colspan="3" class="text-center py-3">No options selected for this service.</td>
                </tr>
            `);
        }
        
        // Special notes
        if (service.specialNotes) {
            $('#optionsSpecialNotes').text(service.specialNotes);
            $('#optionsSpecialNotesSection').show();
        } else {
            $('#optionsSpecialNotesSection').hide();
        }
        
        // Total price
        $('#optionsTotalPrice').text(formatCurrency(service.serviceTotal || calculateServicePrice(service)));
        
        // Update cancel button
        $('#optionsCancelServiceBtn').data('booking-id', bookingId);
        $('#optionsCancelServiceBtn').data('service-id', serviceId);
        
        // Hide cancel button if service is not pending
        if (service.status !== 'pending') {
            $('#optionsCancelServiceBtn').hide();
        } else {
            $('#optionsCancelServiceBtn').show();
        }
        
        // Show content, hide loader
        $('#serviceOptionsLoader').hide();
        $('#serviceOptionsContent').show();
    }
    
    /**
     * Function to calculate service price from all components
     */
    function calculateServicePrice(service) {
        if (!service) return 0;
        
        // If serviceTotal is available and valid, use it
        if (service.serviceTotal && !isNaN(parseFloat(service.serviceTotal))) {
            return parseFloat(service.serviceTotal);
        }
        
        // Otherwise calculate from components
        let total = 0;
        
        // Base price
        if (service.basePrice && !isNaN(parseFloat(service.basePrice))) {
            total += parseFloat(service.basePrice);
        }
        
        // Additional hours price
        if (service.additionalHoursPrice && !isNaN(parseFloat(service.additionalHoursPrice))) {
            total += service.additionalHours*(parseFloat(service.additionalHoursPrice));
        }
        
        // Selected options
        if (service.selectedOptions && Array.isArray(service.selectedOptions)) {
            service.selectedOptions.forEach(option => {
                if (option.price && !isNaN(parseFloat(option.price))) {
                    total += parseFloat(option.price);
                }
            });
        }
        
        return total;
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
     * Function to update booking stats
     */
    function updateBookingStats(bookings) {
        let totalServices = 0;
        let pendingServices = 0;
        let confirmedServices = 0;
        let totalCost = 0;
        
        // Count services across all bookings
        bookings.forEach(booking => {
            if (booking.bookedServices && booking.bookedServices.length > 0) {
                booking.bookedServices.forEach(service => {
                    totalServices++;
                    if (service.status === 'pending') pendingServices++;
                    if (service.status === 'confirmed') confirmedServices++;
                    
                    // Calculate service total price correctly
                    const servicePrice = calculateServicePrice(service);
                    totalCost += servicePrice;
                });
            } else {
                // Add the booking's total price to the total cost if no services
                totalCost += parseFloat(booking.totalBookingPrice || 0);
            }
        });
        
        $('#totalBookings').text(totalServices);
        $('#pendingBookings').text(pendingServices);
        $('#confirmedBookings').text(confirmedServices);
        $('#totalCost').text(formatCurrency(totalCost));
    }
    
    /**
     * Function to show booking details
     */
    function showBookingDetails(bookingId) {
        // Reset modal content
        $('#bookingDetailsLoader').show();
        $('#bookingDetailsContent').hide();
        
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
        
        // Location
        $('#detailEventLocation').text(booking.eventLocation || 'Location not specified');
        
        // Financial details
        $('#detailTotalPrice').text(formatCurrency(booking.totalBookingPrice || 0));
        $('#detailPaymentStatus').text(capitalizeFirstLetter(booking.paymentStatus));
        $('#detailDepositPaid').text(booking.depositPaid ? `Yes (${formatCurrency(booking.depositAmount)})` : 'No');
        $('#detailContractSigned').text(booking.contractSigned ? 'Signed' : 'Not signed');
        
        // Special requirements
        $('#detailSpecialRequirements').text(booking.specialRequirements || 'No special requirements specified.');
        
        // Services list
        if (booking.bookedServices && booking.bookedServices.length > 0) {
            $('#servicesList').empty();
            
            // Calculate total services cost to compare with booking total
            let totalServicesPrice = 0;
            
            booking.bookedServices.forEach(service => {
                const row = $('<tr></tr>');
                
                // Calculate service price correctly
                const servicePrice = calculateServicePrice(service);
                totalServicesPrice += servicePrice;
                
                // Service column with details and selected options
                let serviceHtml = `
                    <div class="fw-bold">${service.serviceName}</div>
                `;
                
                // Basic details section
                let detailsHtml = `
                    <div class="mt-2">
                        <div><small class="text-muted">Base Price:</small> ${formatCurrency(service.basePrice || 0)}</div>
                `;
                
                if (service.hours) {
                    detailsHtml += `
                        <div><small class="text-muted">Duration:</small> ${service.hours} hours 
                        (${service.baseHours || 0} base + ${service.additionalHours || 0} additional)</div>
                    `;
                    
                    if (service.additionalHoursPrice > 0) {
                        detailsHtml += `
                            <div><small class="text-muted">Additional Hours Cost:</small> ${formatCurrency(service.additionalHoursPrice)}</div>
                        `;
                    }
                }
                
                detailsHtml += `</div>`;
                serviceHtml += detailsHtml;
                
                // Add selected options preview with count
                if (service.selectedOptions && service.selectedOptions.length > 0) {
                    serviceHtml += `
                        <div class="mt-2">
                            <div class="d-flex align-items-center">
                                <span class="small fw-bold text-primary">${service.selectedOptions.length} Option${service.selectedOptions.length > 1 ? 's' : ''} Selected</span>
                                <button class="btn btn-sm btn-link text-primary ms-2 view-service-options-btn p-0" 
                                    data-booking-id="${booking.bookingId}" 
                                    data-service-id="${service.serviceBookingId}">
                                    <i class="fas fa-list me-1"></i> View Options
                                </button>
                            </div>
                        </div>
                    `;
                }
                
                // Special notes if available (show limited)
                if (service.specialNotes) {
                    const maxLength = 50;
                    const truncatedNotes = service.specialNotes.length > maxLength ? 
                        service.specialNotes.substring(0, maxLength) + '...' : service.specialNotes;
                    
                    serviceHtml += `
                        <div class="mt-2 small">
                            <div class="fw-bold">Notes:</div>
                            <div>${truncatedNotes}</div>
                        </div>
                    `;
                }
                
                row.append(`<td>${serviceHtml}</td>`);
                
                // Vendor column
                row.append(`
                    <td>${service.vendorName || service.vendorId}</td>
                `);
                
                // Price column with breakdown tooltip
                row.append(`
                    <td>
                        <span class="fw-bold" data-bs-toggle="tooltip" data-bs-placement="top" 
                              title="Base: ${formatCurrency(service.basePrice || 0)} + Options: ${formatCurrency(optionsTotalFor(service))}">
                            ${formatCurrency(servicePrice)}
                        </span>
                    </td>
                `);
                
                // Status column
                row.append(`
                    <td>${getStatusBadge(service.status || 'pending')}</td>
                `);
                
                // Actions column
                row.append(`
                    <td>
                        <div class="dropdown">
                            <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown">
                                <i class="fas fa-ellipsis-v"></i>
                            </button>
                            <div class="dropdown-menu dropdown-menu-end">
                                <button class="dropdown-item view-service-options-btn" type="button"
                                    data-booking-id="${booking.bookingId}" 
                                    data-service-id="${service.serviceBookingId}">
                                    <i class="fas fa-list me-2"></i> View Options
                                </button>
                                <a href="${contextPath}/user/user-reviews.jsp?action=newReview&serviceId=${service.serviceId}&vendorId=${service.vendorId}&bookingId=${booking.bookingId}" 
                                   class="dropdown-item" type="button">
                                    <i class="fas fa-star me-2"></i> Make Review
                                </a>
                                ${service.status === 'pending' ? `
                                    <button class="dropdown-item text-danger cancel-booking-btn" type="button"
                                        data-booking-id="${booking.bookingId}" 
                                        data-service-id="${service.serviceBookingId}">
                                        <i class="fas fa-times-circle me-2"></i> Cancel Service
                                    </button>
                                ` : ''}
                            </div>
                        </div>
                    </td>
                `);
                
                $('#servicesList').append(row);
            });
            
            // Initialize tooltips
            $('[data-bs-toggle="tooltip"]').tooltip();
            
            // Show warning if total services price doesn't match booking total price
            const bookingTotalPrice = parseFloat(booking.totalBookingPrice || 0);
            if (Math.abs(totalServicesPrice - bookingTotalPrice) > 0.01) {
                $('#servicesList').after(`
                    <div class="alert alert-warning mt-3 small" role="alert">
                        <i class="fas fa-exclamation-triangle me-2"></i>
                        Note: The sum of individual service prices (${formatCurrency(totalServicesPrice)}) 
                        differs from the total booking price (${formatCurrency(bookingTotalPrice)}).
                    </div>
                `);
            }
            
        } else {
            $('#servicesList').html(`
                <tr>
                    <td colspan="5" class="text-center">No services found for this booking.</td>
                </tr>
            `);
        }
        
        // Show content, hide loader
        $('#bookingDetailsLoader').hide();
        $('#bookingDetailsContent').show();
    }
    
    /**
     * Function to calculate total price of options for a service
     */
    function optionsTotalFor(service) {
        if (!service.selectedOptions || !Array.isArray(service.selectedOptions)) {
            return 0;
        }
        
        let total = 0;
        service.selectedOptions.forEach(option => {
            if (option.price && !isNaN(parseFloat(option.price))) {
                total += parseFloat(option.price);
            }
        });
        return total;
    }
    
    /**
     * Helper function to get action buttons HTML
     */
    function getActionButtons(bookingId, service) {
        if (!service) {
            // If no service, just return view details button
            return `
                <button class="btn btn-sm btn-outline-primary view-booking-btn" 
                    data-booking-id="${bookingId}" title="View Details">
                    <i class="fas fa-eye"></i>
                </button>
            `;
        }
        
        // Create action buttons with icons
        let buttons = `
            <div class="btn-group">
                <button class="btn btn-sm btn-outline-primary view-booking-btn" 
                    data-booking-id="${bookingId}" title="View Details">
                    <i class="fas fa-eye"></i>
                </button>`;
                
        // Add service options button if service has options
        if (service.selectedOptions && service.selectedOptions.length > 0) {
            buttons += `
                <button class="btn btn-sm btn-outline-info view-service-options-btn" 
                   data-booking-id="${bookingId}" 
                   data-service-id="${service.serviceBookingId}"
                   title="View Options">
                    <i class="fas fa-cog"></i>
                </button>`;
        }
        
        // Add Make Review button (new addition)
        buttons += `
            <a href="${contextPath}/user/user-reviews.jsp?action=newReview&serviceId=${service.serviceId}&vendorId=${service.vendorId}&bookingId=${bookingId}" 
               class="btn btn-sm btn-outline-warning" title="Write Review">
                <i class="fas fa-star"></i>
            </a>`;
        
        // Only add cancel option if service is pending (NOT confirmed or cancelled)
        if (service.status === 'pending') {
            buttons += `
                <button class="btn btn-sm btn-outline-danger cancel-booking-btn" 
                   data-booking-id="${bookingId}" 
                   data-service-id="${service.serviceBookingId}"
                   title="Cancel Service">
                    <i class="fas fa-times"></i>
                </button>`;
        }
        
        buttons += `</div>`;
        
        return buttons;
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
     * Helper function to format currency
     */
    function formatCurrency(amount) {
        return '$' + parseFloat(amount).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
    }
    
    /**
     * Helper function to format date/time
     */
    function formatEventDate(date, time) {
        if (!date) return 'Date not set';
        
        const options = { year: 'numeric', month: 'short', day: 'numeric' };
        let formattedDate = new Date(date).toLocaleDateString('en-US', options);
        
        if (time) {
            formattedDate += ' at ' + formatTime(time);
        }
        
        return formattedDate;
    }
    
    /**
     * Helper function to format time
     */
    function formatTime(time) {
        if (!time) return '';
        
        // Convert 24h format to 12h
        const timeParts = time.split(':');
        let hours = parseInt(timeParts[0]);
        const minutes = timeParts[1];
        const ampm = hours >= 12 ? 'PM' : 'AM';
        
        hours = hours % 12;
        hours = hours ? hours : 12; // Convert '0' to '12'
        
        return `${hours}:${minutes} ${ampm}`;
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
        
        // UPDATED: Proper URL construction for the servlet
        let requestUrl = contextPath ? contextPath + '/user/ExportBookingServlet' : '/user/ExportBookingServlet';
        
        // Prepare data to export
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const filename = `marry-mate-bookings-export-${timestamp}.csv`;
        
        // Redirect to export servlet
        const exportUrl = requestUrl + '?format=csv&all=true';
        window.location.href = exportUrl;
        
        // Reset button after a delay
        setTimeout(function() {
            exportBtn.html('<i class="fas fa-check me-2"></i> Exported!');
            
            setTimeout(function() {
                exportBtn.html(originalText);
                exportBtn.prop('disabled', false);
                
                // Show success message
                showAlert('Bookings exported successfully!', 'success');
            }, 1000);
        }, 2000);
    }
    
    /**
     * Function to export a single booking
     */
    function exportSingleBooking(bookingId) {
        // Display loading indicator
        const exportBtn = $('#exportSingleBookingBtn');
        const originalText = exportBtn.html();
        exportBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Exporting...');
        exportBtn.prop('disabled', true);
        
        // UPDATED: Proper URL construction for the servlet
        let requestUrl = contextPath ? contextPath + '/user/ExportBookingServlet' : '/user/ExportBookingServlet';
        
        // Redirect to export servlet
        const exportUrl = requestUrl + '?format=pdf&bookingId=' + bookingId;
        window.location.href = exportUrl;
        
        // Reset button after a delay
        setTimeout(function() {
            exportBtn.html('<i class="fas fa-check me-2"></i> Exported!');
            
            setTimeout(function() {
                exportBtn.html(originalText);
                exportBtn.prop('disabled', false);
                
                // Show success message
                showAlert('Booking details exported successfully!', 'success');
            }, 1000);
        }, 2000);
    }
});