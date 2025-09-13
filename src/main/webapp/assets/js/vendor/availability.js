/**
 * Vendor Availability JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-07 10:27:31
 * Current User: IT24102137
 */

document.addEventListener('DOMContentLoaded', function() {
    // Global variables
    let calendar;
    let vendorAvailability = null;
    let bookingsData = [];
    const vendorId = document.body.dataset.vendorId || 'V1004'; // Default for testing
    
    // Initialize page components
    initCalendar();
    initDatePickers();
    initWorkingHours();
    loadVendorData();
    
    // Event listeners
    document.getElementById('blockDatesBtn').addEventListener('click', blockSelectedDates);
    document.getElementById('saveChangesBtn').addEventListener('click', saveAllChanges);
    document.getElementById('applyHoursBtn').addEventListener('click', applyWorkingHours);
    
    // View options (month/week)
    document.querySelectorAll('.view-option').forEach(button => {
        button.addEventListener('click', function() {
            const view = this.dataset.view;
            changeCalendarView(view);
            
            // Update active state
            document.querySelectorAll('.view-option').forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
        });
    });
    
    // Working hours checkbox events
    document.querySelectorAll('.day-available').forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            const dayElement = this.closest('.day-hours');
            const startTime = dayElement.querySelector('.start-time');
            const endTime = dayElement.querySelector('.end-time');
            
            startTime.disabled = !this.checked;
            endTime.disabled = !this.checked;
            
            if (this.checked) {
                // Set default times
                startTime._flatpickr.setDate('09:00', true);
                endTime._flatpickr.setDate('17:00', true);
            } else {
                // Clear times
                startTime._flatpickr.clear();
                endTime._flatpickr.clear();
            }
        });
    });
    
    // Standard hours toggle
    document.getElementById('useStandardHours').addEventListener('change', function() {
        if (this.checked) {
            // Set standard working hours (9-5 weekdays, 10-4 Saturday, off Sunday)
            setStandardWorkingHours();
        }
    });
    
    /**
     * Initialize the calendar component
     */
    function initCalendar() {
        const calendarEl = document.getElementById('calendar');
        
        calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: ''
            },
            selectable: true,
            selectMirror: true,
            dayMaxEvents: true,
            height: 'auto',
            weekNumbers: false,
            navLinks: true,
            businessHours: {
                // Business hours will be set dynamically
                daysOfWeek: [1, 2, 3, 4, 5], // Monday to Friday
                startTime: '09:00',
                endTime: '17:00'
            },
            select: function(info) {
                handleDateSelection(info.startStr, info.endStr);
            },
            eventClick: function(info) {
                handleEventClick(info.event);
            },
            events: [] // Events will be populated dynamically
        });
        
        calendar.render();
    }
    
    /**
     * Initialize date picker components
     */
    function initDatePickers() {
        // For blocking individual dates
        flatpickr("#unavailableDatePicker", {
            mode: "multiple",
            dateFormat: "Y-m-d",
            minDate: "today",
            disable: [], // Will be populated with existing unavailable dates
            locale: {
                firstDayOfWeek: 1 // Monday
            }
        });
        
        // For date range modal
        flatpickr("#dateRangeStart", {
            dateFormat: "Y-m-d",
            minDate: "today",
            locale: {
                firstDayOfWeek: 1 // Monday
            }
        });
        
        flatpickr("#dateRangeEnd", {
            dateFormat: "Y-m-d",
            minDate: "today",
            locale: {
                firstDayOfWeek: 1 // Monday
            }
        });
    }
    
    /**
     * Initialize working hours time pickers
     */
    function initWorkingHours() {
        // Initialize time pickers
        document.querySelectorAll('.time-picker').forEach(input => {
            flatpickr(input, {
                enableTime: true,
                noCalendar: true,
                dateFormat: "H:i",
                time_24hr: true,
                minuteIncrement: 30
            });
        });
    }
    
    /**
     * Load vendor data including availability and bookings
     */
    function loadVendorData() {
        // Show loading states
        document.getElementById('workingHoursLoading').style.display = 'block';
        document.getElementById('workingHoursForm').style.display = 'none';
        document.getElementById('upcomingBookingsLoading').style.display = 'block';
        document.getElementById('upcomingBookingsList').style.display = 'none';
        
        // In a real implementation, this would be an API call to get vendor data
        // For now, we'll simulate loading from the JSON files
        setTimeout(() => {
            // Get availability data
            vendorAvailability = getMockAvailabilityData(vendorId);
            
            // Get bookings data
            bookingsData = getMockBookingsData(vendorId);
            
            // Populate UI
            populateAvailabilityData();
            populateBookingsData();
            updateCalendarEvents();
            
            // Hide loading states
            document.getElementById('workingHoursLoading').style.display = 'none';
            document.getElementById('workingHoursForm').style.display = 'block';
            document.getElementById('upcomingBookingsLoading').style.display = 'none';
            
            // Update business name
            document.getElementById('businessNameHeader').textContent = 'Elegant Photography';
            
        }, 1200);
    }
    
    /**
     * Populate availability data in the UI
     */
    function populateAvailabilityData() {
        if (!vendorAvailability) return;
        
        // Populate unavailable dates
        const unavailableDatesList = document.getElementById('unavailableDatesList');
        const noUnavailableDatesMessage = document.getElementById('noUnavailableDatesMessage');
        
        if (vendorAvailability.unavailableDates && vendorAvailability.unavailableDates.length > 0) {
            let html = '';
            
            vendorAvailability.unavailableDates.forEach(date => {
                const formattedDate = formatDate(date);
                html += `
                    <div class="unavailable-date-item" data-date="${date}">
                        <span class="unavailable-date-text">${formattedDate}</span>
                        <div class="unavailable-date-actions">
                            <button class="btn btn-sm btn-outline-danger remove-date-btn" data-date="${date}">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                `;
            });
            
            unavailableDatesList.innerHTML = html;
            noUnavailableDatesMessage.style.display = 'none';
            
            // Add event listeners for remove buttons
            unavailableDatesList.querySelectorAll('.remove-date-btn').forEach(button => {
                button.addEventListener('click', function() {
                    const dateToRemove = this.dataset.date;
                    removeUnavailableDate(dateToRemove);
                });
            });
            
            // Update date picker with current unavailable dates
            const datePicker = document.getElementById('unavailableDatePicker')._flatpickr;
            datePicker.set('disable', vendorAvailability.unavailableDates);
        } else {
            unavailableDatesList.innerHTML = '';
            noUnavailableDatesMessage.style.display = 'block';
        }
        
        // Populate working hours
        if (vendorAvailability.workingHours) {
            Object.entries(vendorAvailability.workingHours).forEach(([day, hours]) => {
                const dayElement = document.querySelector(`.day-hours[data-day="${day}"]`);
                if (!dayElement) return;
                
                const availableCheckbox = dayElement.querySelector('.day-available');
                const startTimeInput = dayElement.querySelector('.start-time');
                const endTimeInput = dayElement.querySelector('.end-time');
                
                // Set availability and hours
                if (hours.start && hours.end) {
                    availableCheckbox.checked = true;
                    startTimeInput.disabled = false;
                    endTimeInput.disabled = false;
                    
                    // Set times
                    startTimeInput._flatpickr.setDate(hours.start);
                    endTimeInput._flatpickr.setDate(hours.end);
                } else {
                    availableCheckbox.checked = false;
                    startTimeInput.disabled = true;
                    endTimeInput.disabled = true;
                    
                    // Clear times
                    startTimeInput._flatpickr.clear();
                    endTimeInput._flatpickr.clear();
                }
            });
        }
    }
    
    /**
     * Populate upcoming bookings in the UI
     */
    function populateBookingsData() {
        const upcomingBookingsList = document.getElementById('upcomingBookingsList');
        const noBookingsMessage = document.getElementById('noBookingsMessage');
        
        if (bookingsData && bookingsData.length > 0) {
            // Filter for upcoming bookings only
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            const upcomingBookings = bookingsData.filter(booking => {
                const bookingDate = new Date(booking.weddingDate);
                return bookingDate >= today;
            }).sort((a, b) => new Date(a.weddingDate) - new Date(b.weddingDate)).slice(0, 5); // Get next 5 bookings
            
            if (upcomingBookings.length > 0) {
                let html = '';
                
                upcomingBookings.forEach(booking => {
                    const bookingDate = new Date(booking.weddingDate);
                    const month = bookingDate.toLocaleString('default', { month: 'short' });
                    const day = bookingDate.getDate();
                    
                    let statusClass = '';
                    switch (booking.status) {
                        case 'confirmed': statusClass = 'confirmed'; break;
                        case 'pending': statusClass = 'pending'; break;
                        default: statusClass = 'pending';
                    }
                    
                    html += `
                        <div class="booking-item" data-booking-id="${booking.bookingId}">
                            <div class="booking-date-badge">
                                <span class="booking-date-month">${month}</span>
                                <span class="booking-date-day">${day}</span>
                            </div>
                            <div class="booking-details">
                                <div class="booking-title">Booking #${booking.bookingId}</div>
                                <div class="booking-subtitle">
                                    <i class="fas fa-map-marker-alt"></i> ${truncateText(booking.eventLocation, 30)}
                                </div>
                                <div class="booking-subtitle">
                                    <i class="fas fa-clock"></i> ${booking.eventStartTime} - ${booking.eventEndTime}
                                </div>
                            </div>
                            <span class="booking-status ${statusClass}">${booking.status}</span>
                        </div>
                    `;
                });
                
                upcomingBookingsList.innerHTML = html;
                upcomingBookingsList.style.display = 'block';
                noBookingsMessage.style.display = 'none';
                
                // Add event listeners to booking items
                upcomingBookingsList.querySelectorAll('.booking-item').forEach(item => {
                    item.addEventListener('click', function() {
                        const bookingId = this.dataset.bookingId;
                        showBookingDetails(bookingId);
                    });
                });
            } else {
                upcomingBookingsList.style.display = 'none';
                noBookingsMessage.style.display = 'block';
            }
        } else {
            upcomingBookingsList.style.display = 'none';
            noBookingsMessage.style.display = 'block';
        }
    }
    
    /**
     * Update calendar events based on availability and bookings
     */
    function updateCalendarEvents() {
        if (!calendar) return;
        
        // Clear existing events
        calendar.removeAllEvents();
        
        // Add unavailable dates
        if (vendorAvailability && vendorAvailability.unavailableDates) {
            vendorAvailability.unavailableDates.forEach(date => {
                calendar.addEvent({
                    title: 'Unavailable',
                    start: date,
                    allDay: true,
                    classNames: ['unavailable'],
                    extendedProps: {
                        type: 'unavailable'
                    }
                });
            });
        }
        
        // Add booked slots
        if (vendorAvailability && vendorAvailability.bookedSlots) {
            vendorAvailability.bookedSlots.forEach(slot => {
                const bookingInfo = bookingsData.find(b => b.bookingId === slot.bookingId);
                let title = 'Booked';
                
                if (bookingInfo) {
                    title = `Booked: ${truncateText(bookingInfo.eventLocation, 20)}`;
                }
                
                calendar.addEvent({
                    title: title,
                    start: `${slot.date}T${slot.startTime}`,
                    end: `${slot.date}T${slot.endTime}`,
                    classNames: ['booked'],
                    extendedProps: {
                        type: 'booked',
                        bookingId: slot.bookingId
                    }
                });
            });
        }
        
        // Update business hours
        updateCalendarBusinessHours();
    }
    
    /**
     * Update calendar business hours based on working hours settings
     */
    function updateCalendarBusinessHours() {
        if (!calendar || !vendorAvailability || !vendorAvailability.workingHours) return;
        
        const businessHours = [];
        const daysMap = {
            'Sunday': 0,
            'Monday': 1,
            'Tuesday': 2,
            'Wednesday': 3,
            'Thursday': 4,
            'Friday': 5,
            'Saturday': 6
        };
        
        Object.entries(vendorAvailability.workingHours).forEach(([day, hours]) => {
            if (hours.start && hours.end) {
                businessHours.push({
                    daysOfWeek: [daysMap[day]],
                    startTime: hours.start,
                    endTime: hours.end
                });
            }
        });
        
        calendar.setOption('businessHours', businessHours);
    }
    
    /**
     * Handle date selection on the calendar
     */
    function handleDateSelection(startStr, endStr) {
        // Check if it's a range or single date
        const start = new Date(startStr);
        const end = new Date(endStr);
        end.setDate(end.getDate() - 1); // FullCalendar's end date is exclusive
        
        if (start.toDateString() === end.toDateString()) {
            // Single date selection
            const dateStr = startStr.substr(0, 10); // YYYY-MM-DD
            toggleUnavailableDate(dateStr);
        } else {
            // Date range selection
            showDateRangeModal(startStr, endStr);
        }
        
        // Unselect the selection
        calendar.unselect();
    }
    
    /**
     * Handle click on an event in the calendar
     */
    function handleEventClick(event) {
        const eventType = event.extendedProps.type;
        
        if (eventType === 'unavailable') {
            const dateStr = event.startStr.substr(0, 10); // YYYY-MM-DD
            toggleUnavailableDate(dateStr);
        } else if (eventType === 'booked') {
            const bookingId = event.extendedProps.bookingId;
            showBookingDetails(bookingId);
        }
    }
    
    /**
     * Toggle a date between available and unavailable
     */
    function toggleUnavailableDate(dateStr) {
        if (!vendorAvailability) return;
        
        if (!vendorAvailability.unavailableDates) {
            vendorAvailability.unavailableDates = [];
        }
        
        // Check if date is already in unavailable dates
        const index = vendorAvailability.unavailableDates.indexOf(dateStr);
        
        if (index > -1) {
            // Date is already unavailable, make it available
            removeUnavailableDate(dateStr);
        } else {
            // Date is available, make it unavailable
            vendorAvailability.unavailableDates.push(dateStr);
            updateUnavailableDatesList();
            updateCalendarEvents();
        }
    }
    
    /**
     * Block selected dates from the date picker
     */
    function blockSelectedDates() {
        const datePicker = document.getElementById('unavailableDatePicker')._flatpickr;
        const selectedDates = datePicker.selectedDates;
        
        if (!selectedDates || selectedDates.length === 0) {
            showAlert('Please select dates to block', 'warning');
            return;
        }
        
        if (!vendorAvailability.unavailableDates) {
            vendorAvailability.unavailableDates = [];
        }
        
        // Add each selected date to unavailable dates
        selectedDates.forEach(date => {
            const dateStr = date.toISOString().substr(0, 10); // YYYY-MM-DD
            
            if (!vendorAvailability.unavailableDates.includes(dateStr)) {
                vendorAvailability.unavailableDates.push(dateStr);
            }
        });
        
        // Update UI and clear selections
        updateUnavailableDatesList();
        updateCalendarEvents();
        datePicker.clear();
        
        showAlert(`${selectedDates.length} date(s) blocked successfully`, 'success');
    }
    
    /**
     * Remove a date from unavailable dates
     */
    function removeUnavailableDate(dateStr) {
        if (!vendorAvailability || !vendorAvailability.unavailableDates) return;
        
        const index = vendorAvailability.unavailableDates.indexOf(dateStr);
        
        if (index > -1) {
            vendorAvailability.unavailableDates.splice(index, 1);
            updateUnavailableDatesList();
            updateCalendarEvents();
        }
    }
    
    /**
     * Update the unavailable dates list in the UI
     */
    function updateUnavailableDatesList() {
        const unavailableDatesList = document.getElementById('unavailableDatesList');
        const noUnavailableDatesMessage = document.getElementById('noUnavailableDatesMessage');
        
        if (vendorAvailability.unavailableDates && vendorAvailability.unavailableDates.length > 0) {
            let html = '';
            
            vendorAvailability.unavailableDates.sort().forEach(date => {
                const formattedDate = formatDate(date);
                html += `
                    <div class="unavailable-date-item" data-date="${date}">
                        <span class="unavailable-date-text">${formattedDate}</span>
                        <div class="unavailable-date-actions">
                            <button class="btn btn-sm btn-outline-danger remove-date-btn" data-date="${date}">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                `;
            });
            
            unavailableDatesList.innerHTML = html;
            noUnavailableDatesMessage.style.display = 'none';
            
            // Add event listeners for remove buttons
            unavailableDatesList.querySelectorAll('.remove-date-btn').forEach(button => {
                button.addEventListener('click', function() {
                    const dateToRemove = this.dataset.date;
                    removeUnavailableDate(dateToRemove);
                });
            });
            
            // Update date picker with current unavailable dates
            const datePicker = document.getElementById('unavailableDatePicker')._flatpickr;
            datePicker.set('disable', vendorAvailability.unavailableDates);
        } else {
            unavailableDatesList.innerHTML = '';
            noUnavailableDatesMessage.style.display = 'block';
        }
    }
    
    /**
     * Show date range modal for blocking multiple dates
     */
    function showDateRangeModal(startStr, endStr) {
        // Set the start and end dates in the modal
        const startDate = startStr.substr(0, 10); // YYYY-MM-DD
        
        // FullCalendar's end date is exclusive, subtract 1 day
        const endDateObj = new Date(endStr);
        endDateObj.setDate(endDateObj.getDate() - 1);
        const endDate = endDateObj.toISOString().substr(0, 10); // YYYY-MM-DD
        
        document.getElementById('dateRangeStart')._flatpickr.setDate(startDate);
        document.getElementById('dateRangeEnd')._flatpickr.setDate(endDate);
        
        // Clear the reason field
        document.getElementById('dateRangeReason').value = '';
        
        // Show the modal
        const dateRangeModal = new bootstrap.Modal(document.getElementById('dateRangeModal'));
        dateRangeModal.show();
        
        // Set up confirmation button
        document.getElementById('confirmBlockRangeBtn').onclick = function() {
            blockDateRange();
        };
    }
    
    /**
     * Block a range of dates
     */
    function blockDateRange() {
        const startDateStr = document.getElementById('dateRangeStart').value;
        const endDateStr = document.getElementById('dateRangeEnd').value;
        
        if (!startDateStr || !endDateStr) {
            showAlert('Please select both start and end dates', 'warning');
            return;
        }
        
        const startDate = new Date(startDateStr);
        const endDate = new Date(endDateStr);
        
        if (startDate > endDate) {
            showAlert('End date must be after start date', 'warning');
            return;
        }
        
        // Add all dates in the range to unavailable dates
        const dates = getDatesInRange(startDate, endDate);
        
        if (!vendorAvailability.unavailableDates) {
            vendorAvailability.unavailableDates = [];
        }
        
        // Add each date if not already unavailable
        dates.forEach(dateStr => {
            if (!vendorAvailability.unavailableDates.includes(dateStr)) {
                vendorAvailability.unavailableDates.push(dateStr);
            }
        });
        
        // Update UI
        updateUnavailableDatesList();
        updateCalendarEvents();
        
        // Close the modal
        const dateRangeModal = bootstrap.Modal.getInstance(document.getElementById('dateRangeModal'));
        dateRangeModal.hide();
        
        showAlert(`${dates.length} date(s) blocked successfully`, 'success');
    }
    
    /**
     * Change calendar view (month/week)
     */
    function changeCalendarView(viewName) {
        calendar.changeView(viewName);
    }
    
    /**
     * Apply working hours from form to vendorAvailability object
     */
    function applyWorkingHours() {
        if (!vendorAvailability) return;
        
        if (!vendorAvailability.workingHours) {
            vendorAvailability.workingHours = {};
        }
        
        // Get all day elements
        const dayElements = document.querySelectorAll('.day-hours');
        
        // Process each day
        dayElements.forEach(dayElement => {
            const day = dayElement.dataset.day;
            const availableCheckbox = dayElement.querySelector('.day-available');
            const startTimeInput = dayElement.querySelector('.start-time');
            const endTimeInput = dayElement.querySelector('.end-time');
            
            if (availableCheckbox.checked) {
                // Day is available, get the times
                const startTime = startTimeInput.value;
                const endTime = endTimeInput.value;
                
                if (startTime && endTime) {
                    // Update working hours for this day
                    vendorAvailability.workingHours[day] = {
                        start: startTime,
                        end: endTime
                    };
                }
            } else {
                // Day is not available
                vendorAvailability.workingHours[day] = {
                    start: null,
                    end: null
                };
            }
        });
        
        // Update calendar business hours
        updateCalendarBusinessHours();
        
        showAlert('Working hours updated successfully', 'success');
    }
    
    /**
     * Set standard working hours (9-5 weekdays, 10-4 Saturday, off Sunday)
     */
    function setStandardWorkingHours() {
        // For each day element, set standard hours
        const dayElements = document.querySelectorAll('.day-hours');
        
        // Process each day
        dayElements.forEach(dayElement => {
            const day = dayElement.dataset.day;
            const availableCheckbox = dayElement.querySelector('.day-available');
            const startTimeInput = dayElement.querySelector('.start-time');
            const endTimeInput = dayElement.querySelector('.end-time');
            
            switch (day) {
                case 'Monday':
                case 'Tuesday':
                case 'Wednesday':
                case 'Thursday':
                case 'Friday':
                    availableCheckbox.checked = true;
                    startTimeInput.disabled = false;
                    endTimeInput.disabled = false;
                    startTimeInput._flatpickr.setDate('09:00');
                    endTimeInput._flatpickr.setDate('17:00');
                    break;
                    
                case 'Saturday':
                    availableCheckbox.checked = true;
                    startTimeInput.disabled = false;
                    endTimeInput.disabled = false;
                    startTimeInput._flatpickr.setDate('10:00');
                    endTimeInput._flatpickr.setDate('16:00');
                    break;
                    
                case 'Sunday':
                    availableCheckbox.checked = false;
                    startTimeInput.disabled = true;
                    endTimeInput.disabled = true;
                    startTimeInput._flatpickr.clear();
                    endTimeInput._flatpickr.clear();
                    break;
            }
        });
    }
    
    /**
     * Save all changes to server
     */
    function saveAllChanges() {
        // Apply working hours first
        applyWorkingHours();
        
        // Set updated date
        vendorAvailability.lastUpdated = getCurrentDateTime();
        
        // In a real implementation, this would save to the server via AJAX
        // For now, just show a success message
        
        // Show loading on the save button
        const saveButton = document.getElementById('saveChangesBtn');
        const originalSaveText = saveButton.innerHTML;
        saveButton.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Saving...';
        saveButton.disabled = true;
        
        // Simulate saving to server
        setTimeout(() => {
            saveButton.innerHTML = originalSaveText;
            saveButton.disabled = false;
            showAlert('All availability changes saved successfully', 'success');
            
            // Log the data that would be sent to the server
            console.log('Availability data to be saved:', vendorAvailability);
        }, 1500);
    }
    
    /**
     * Show booking details in a modal
     */
    function showBookingDetails(bookingId) {
        const booking = bookingsData.find(b => b.bookingId === bookingId);
        if (!booking) return;
        
        // Show loading
        document.getElementById('bookingDetailsLoading').style.display = 'block';
        document.getElementById('bookingDetailsContent').style.display = 'none';
        
        // Show the modal
        const bookingModal = new bootstrap.Modal(document.getElementById('bookingDetailsModal'));
        bookingModal.show();
        
        // Set up view full details button
        document.getElementById('viewFullBookingBtn').href = `${window.location.origin}/vendor/bookings.jsp?id=${bookingId}`;
        
        // Simulate loading details
        setTimeout(() => {
            // Hide loading, show content
            document.getElementById('bookingDetailsLoading').style.display = 'none';
            
            // Build booking details HTML
            const detailsContent = document.getElementById('bookingDetailsContent');
            detailsContent.innerHTML = `
                <div class="booking-detail-header">
                    <h6>Booking #${booking.bookingId}</h6>
                    <span class="badge ${getStatusBadgeClass(booking.status)}">${booking.status}</span>
                </div>
                
                <div class="booking-detail-item">
                    <div class="detail-label"><i class="far fa-calendar-alt"></i> Wedding Date</div>
                    <div class="detail-value">${formatDate(booking.weddingDate)}</div>
                </div>
                
                <div class="booking-detail-item">
                    <div class="detail-label"><i class="far fa-clock"></i> Time</div>
                    <div class="detail-value">${booking.eventStartTime} - ${booking.eventEndTime}</div>
                </div>
                
                <div class="booking-detail-item">
                    <div class="detail-label"><i class="fas fa-map-marker-alt"></i> Location</div>
                    <div class="detail-value">${booking.eventLocation}</div>
                </div>
                
                <div class="booking-detail-item">
                    <div class="detail-label"><i class="fas fa-users"></i> Guest Count</div>
                    <div class="detail-value">${booking.guestCount} guests</div>
                </div>
                
                <div class="booking-detail-item">
                    <div class="detail-label"><i class="fas fa-dollar-sign"></i> Total Price</div>
                    <div class="detail-value">$${booking.totalPrice.toFixed(2)}</div>
                </div>
                
                <div class="booking-detail-item">
                    <div class="detail-label"><i class="fas fa-info-circle"></i> Special Requirements</div>
                    <div class="detail-value">${booking.specialRequirements || 'None specified'}</div>
                </div>
            `;
            
            detailsContent.style.display = 'block';
        }, 800);
    }
    
    /**
     * Helper function to get CSS class for status badges
     */
    function getStatusBadgeClass(status) {
        switch (status) {
            case 'confirmed': return 'bg-success';
            case 'pending': return 'bg-warning';
            case 'cancelled': return 'bg-danger';
            case 'completed': return 'bg-info';
            default: return 'bg-secondary';
        }
    }
    
    /**
     * Get all dates in a date range
     * @param {Date} startDate - Start date object
     * @param {Date} endDate - End date object
     * @returns {Array} - Array of date strings in YYYY-MM-DD format
     */
    function getDatesInRange(startDate, endDate) {
        const dates = [];
        const currentDate = new Date(startDate);
        
        // Loop through the date range
        while (currentDate <= endDate) {
            dates.push(currentDate.toISOString().substr(0, 10));
            currentDate.setDate(currentDate.getDate() + 1);
        }
        
        return dates;
    }
    
    /**
     * Format a date string for display
     * @param {string} dateStr - Date string in YYYY-MM-DD format
     * @returns {string} - Formatted date string (e.g., "May 7, 2025")
     */
    function formatDate(dateStr) {
        if (!dateStr) return 'N/A';
        
        const date = new Date(dateStr);
        return date.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric'
        });
    }
    
    /**
     * Get the current date and time as a formatted string
     */
    function getCurrentDateTime() {
        const now = new Date();
        
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        
        return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
    }
    
    /**
     * Helper function to truncate text with ellipsis
     */
    function truncateText(text, maxLength) {
        if (!text) return '';
        return text.length > maxLength ? text.substring(0, maxLength) + '...' : text;
    }
    
    /**
     * Show an alert message
     */
    function showAlert(message, type = 'success') {
        // Create alert element
        const alertEl = document.createElement('div');
        alertEl.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
        alertEl.style.top = '20px';
        alertEl.style.right = '20px';
        alertEl.style.zIndex = '1050';
        alertEl.style.maxWidth = '400px';
        
        alertEl.innerHTML = `
            ${message}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        `;
        
        // Add to document
        document.body.appendChild(alertEl);
        
        // Remove after 5 seconds
        setTimeout(() => {
            alertEl.classList.remove('show');
            setTimeout(() => {
                if (document.body.contains(alertEl)) {
                    document.body.removeChild(alertEl);
                }
            }, 300);
        }, 5000);
    }
    
    /**
     * Mock function to get vendor availability data
     * In a real implementation, this would get data from the server
     */
    function getMockAvailabilityData(vendorId) {
        return {
            "vendorId": vendorId,
            "unavailableDates": [
                "2025-05-15",
                "2025-05-16",
                "2025-05-30",
                "2025-06-01",
                "2025-06-06",
                "2025-06-07"
            ],
            "workingHours": {
                "Monday": {"start": "09:00", "end": "17:00"},
                "Tuesday": {"start": "09:00", "end": "17:00"},
                "Wednesday": {"start": "09:00", "end": "17:00"},
                "Thursday": {"start": "09:00", "end": "17:00"},
                "Friday": {"start": "09:00", "end": "18:00"},
                "Saturday": {"start": "10:00", "end": "16:00"},
                "Sunday": {"start": null, "end": null}
            },
            "bookedSlots": [
                {
                    "date": "2025-06-15",
                    "startTime": "14:00",
                    "endTime": "22:00",
                    "bookingId": "B1001"
                },
                {
                    "date": "2025-07-22",
                    "startTime": "10:00",
                    "endTime": "18:00",
                    "bookingId": "B1004"
                }
            ],
            "lastUpdated": "2025-05-06 16:30:00"
        };
    }
    
    /**
     * Mock function to get bookings data
     * In a real implementation, this would get data from the server
     */
    function getMockBookingsData(vendorId) {
        return [
            {
                "bookingId": "B1001",
                "userId": "U1001",
                "vendorId": vendorId,
                "serviceId": "S1001",
                "weddingDate": "2025-06-15",
                "bookingDate": "2025-02-10 14:30:00",
                "eventLocation": "The Grand Ballroom, 555 Harbor Drive, Miami, FL",
                "eventStartTime": "14:00",
                "eventEndTime": "22:00",
                "guestCount": 150,
                "specialRequirements": "Need extra coverage for pre-ceremony preparations starting at noon.",
                "status": "confirmed",
                "totalPrice": 3500,
                "depositPaid": true,
                "paymentStatus": "partial",
                "contractSigned": true,
                "lastUpdated": "2025-03-01 09:15:22"
            },
            {
                "bookingId": "B1004",
                "userId": "U1003",
                "vendorId": vendorId,
                "serviceId": "S1001",
                "weddingDate": "2025-07-22",
                "bookingDate": "2025-03-10 13:15:00",
                "eventLocation": "Botanical Gardens, 800 Plant Road, Seattle, WA",
                "eventStartTime": "10:00",
                "eventEndTime": "18:00",
                "guestCount": 80,
                "specialRequirements": "Requesting photos with specific garden backdrops. Need wedding party shots before the ceremony.",
                "status": "pending",
                "totalPrice": 2700,
                "depositPaid": true,
                "paymentStatus": "partial",
                "contractSigned": true,
                "lastUpdated": "2025-04-01 10:05:45"
            },
            {
                "bookingId": "B1009",
                "userId": "U1008",
                "vendorId": vendorId,
                "serviceId": "S1001",
                "weddingDate": "2025-08-18",
                "bookingDate": "2025-05-02 09:20:00",
                "eventLocation": "Lakeside Resort, 325 Lakeview Road, Orlando, FL",
                "eventStartTime": "14:00",
                "eventEndTime": "20:00",
                "guestCount": 120,
                "specialRequirements": "Drone photography requested. Sunset photos by the lake are a priority.",
                "status": "pending",
                "totalPrice": 3200,
                "depositPaid": false,
                "paymentStatus": "pending",
                "contractSigned": false,
                "lastUpdated": "2025-05-02 09:20:00"
            }
        ];
    }
});