/**
 * Dashboard JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-18 18:30:15
 * Current User: IT24102137
 */

$(document).ready(function() {
    // Initialize dashboard components
    initSidebar();
    loadDashboardData();
    initCharts();
    
    // Set up event listeners
    setupEventListeners();
});

/**
 * Initialize sidebar and mobile responsive behavior
 */
function initSidebar() {
    // Sidebar toggle for mobile and desktop
    $('#sidebar-toggle').on('click', function() {
        $('.sidebar').toggleClass('show');
        $('body').toggleClass('sidebar-mobile-open');
        
        // Only toggle main content if not in mobile view
        if ($(window).width() > 991) {
            $('.main-content').toggleClass('sidebar-collapsed');
            $('.sidebar').toggleClass('sidebar-collapsed');
        }
    });
    
    // Close sidebar when clicking outside on mobile
    $(document).on('click', function(event) {
        if ($(window).width() <= 991) {
            if (!$(event.target).closest('.sidebar').length && 
                !$(event.target).closest('#sidebar-toggle').length && 
                $('.sidebar').hasClass('show')) {
                $('.sidebar').removeClass('show');
                $('body').removeClass('sidebar-mobile-open');
            }
        }
    });
    
    // Handle dropdown menu in notification and profile areas
    $('.notification-btn, .profile-btn').on('click', function(e) {
        e.stopPropagation();
        const dropdown = $(this).next('.notification-dropdown, .profile-dropdown');
        $('.notification-dropdown, .profile-dropdown').not(dropdown).removeClass('show');
        dropdown.toggleClass('show');
    });
    
    // Close dropdowns on click outside
    $(document).on('click', function() {
        $('.notification-dropdown, .profile-dropdown').removeClass('show');
    });
}

/**
 * Load all dashboard data from server
 */
function loadDashboardData() {
    loadUserBookings();
    loadUserReviews();
    loadActivityFeed();
    loadTasks();
    loadPendingServices();
}

/**
 * Load user bookings data for dashboard widgets
 */
function loadUserBookings() {
    $.ajax({
        url: '/MarryMate/user/bookingservlet',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            updateBookingStats(data);
            updateWeddingCountdown(data);
            updateLatestServices(data);
        },
        error: function(xhr, status, error) {
            console.error('Error loading bookings:', error);
            showAlert('Failed to load booking data. Please refresh the page.', 'error');
        }
    });
}

/**
 * Load user reviews data for dashboard widgets
 */
function loadUserReviews() {
    $.ajax({
        url: '/MarryMate/user/reviewservlet',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            updateReviewStats(data);
            displayRecentReviews(data);
        },
        error: function(xhr, status, error) {
            console.error('Error loading reviews:', error);
            $('#reviewsLoading').html('<p class="text-danger">Failed to load reviews</p>');
        }
    });
}

/**
 * Load services eligible for review
 */
function loadPendingServices() {
    $.ajax({
        url: '/MarryMate/user/reviewservlet',
        type: 'GET',
        data: { action: 'pendingServices' },
        dataType: 'json',
        success: function(data) {
            displayPendingServices(data);
        },
        error: function(xhr, status, error) {
            console.error('Error loading pending services:', error);
            $('#pendingReviewsLoading').html('<p class="text-danger">Failed to load services</p>');
        }
    });
}

/**
 * Load user activity feed
 */
function loadActivityFeed() {
    // In a real system, you would have a dedicated endpoint for activity logs
    // For now, we'll simulate by collecting data from bookings and reviews
    
    // Hide loading after a delay (simulating data fetch)
    setTimeout(() => {
        $('#activityLoading').hide();
        
        // Sample activity data - replace with real data in production
        const activities = [
            {
                type: 'booking',
                icon: 'calendar-check',
                iconColor: 'bg-primary',
                title: 'Photography Booking Confirmed',
                description: 'Your booking with Elegant Photography has been confirmed.',
                date: '2025-05-18 16:30:22',
                link: '/user/user-bookings.jsp'
            },
            {
                type: 'review',
                icon: 'star',
                iconColor: 'bg-warning',
                title: 'Review Submitted',
                description: 'You gave Premium Photography a 5-star review.',
                date: '2025-05-18 15:57:06',
                link: '/user/user-reviews.jsp'
            },
            {
                type: 'payment',
                icon: 'credit-card',
                iconColor: 'bg-success',
                title: 'Payment Processed',
                description: 'Your payment of $2,550 for HAVINDU Catering was successful.',
                date: '2025-05-16 10:15:30',
                link: '#'
            },
            {
                type: 'booking',
                icon: 'calendar-plus',
                iconColor: 'bg-info',
                title: 'New Booking Created',
                description: 'You created a booking for No Edited Photo Session.',
                date: '2025-05-15 10:08:17',
                link: '/user/user-bookings.jsp'
            }
        ];
        
        // Render activities
        let activityHTML = '';
        activities.forEach(activity => {
            activityHTML += `
                <div class="activity-item">
                    <div class="activity-icon ${activity.iconColor}">
                        <i class="fas fa-${activity.icon}"></i>
                    </div>
                    <div class="activity-content">
                        <h6>${activity.title}</h6>
                        <p>${activity.description}</p>
                        <span class="activity-time">${formatTimeAgo(activity.date)}</span>
                    </div>
                </div>
            `;
        });
        
        $('#activityFeed').html(activityHTML);
    }, 800);
}

/**
 * Load user tasks
 */
function loadTasks() {
    // In a real system, you would have a dedicated endpoint for tasks
    // For now, we'll use sample data
    
    // Hide loading after a delay (simulating data fetch)
    setTimeout(() => {
        $('#taskLoading').hide();
        
        // Sample task data - replace with real data in production
        const tasks = [
            {
                id: 't1001',
                title: 'Contact videographer',
                description: 'Confirm final details and schedule',
                dueDate: '2025-06-01',
                priority: 'high',
                completed: false
            },
            {
                id: 't1002',
                title: 'Finalize menu selection',
                description: 'Choose appetizers and main courses',
                dueDate: '2025-06-15',
                priority: 'medium',
                completed: false
            },
            {
                id: 't1003',
                title: 'Send invitations',
                description: 'Mail physical invitations to guests',
                dueDate: '2025-05-30',
                priority: 'high',
                completed: true
            },
            {
                id: 't1004',
                title: 'Book transportation',
                description: 'Arrange transportation for wedding party',
                dueDate: '2025-06-10',
                priority: 'medium',
                completed: false
            }
        ];
        
        // Render tasks
        renderTasks(tasks);
    }, 1000);
}

/**
 * Render tasks list
 */
function renderTasks(tasks) {
    if (!tasks || tasks.length === 0) {
        $('#taskList').html('<li class="list-group-item text-center py-4">No tasks found</li>');
        $('#taskStats').text('0 completed / 0 total');
        return;
    }
    
    let taskHTML = '';
    let completedCount = 0;
    
    tasks.forEach(task => {
        if (task.completed) completedCount++;
        
        const priorityClass = {
            'high': 'text-danger',
            'medium': 'text-warning',
            'low': 'text-success'
        }[task.priority] || '';
        
        const dueDateFormatted = formatDate(task.dueDate);
        
        taskHTML += `
            <li class="list-group-item task-item" data-id="${task.id}">
                <div class="d-flex align-items-center">
                    <div class="form-check">
                        <input class="form-check-input task-checkbox" type="checkbox" ${task.completed ? 'checked' : ''} 
                            id="task-${task.id}">
                        <label class="form-check-label ${task.completed ? 'text-decoration-line-through text-muted' : ''}" 
                            for="task-${task.id}">${task.title}</label>
                    </div>
                    <div class="ms-auto d-flex align-items-center">
                        <span class="badge ${priorityClass} me-2">${capitalizeFirstLetter(task.priority)}</span>
                        <small class="text-muted">${dueDateFormatted}</small>
                        <div class="dropdown ms-2">
                            <button class="btn btn-sm btn-link p-0 task-options" type="button" data-bs-toggle="dropdown">
                                <i class="fas fa-ellipsis-v"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="#">Edit</a></li>
                                <li><a class="dropdown-item text-danger" href="#">Delete</a></li>
                            </ul>
                        </div>
                    </div>
                </div>
                ${task.description ? `<p class="mb-0 mt-1 task-description">${task.description}</p>` : ''}
            </li>
        `;
    });
    
    $('#taskList').html(taskHTML);
    $('#taskStats').text(`${completedCount} completed / ${tasks.length} total`);
    
    // Handle task checkbox changes
    $('.task-checkbox').on('change', function() {
        const taskId = $(this).closest('.task-item').data('id');
        const isCompleted = $(this).is(':checked');
        
        // Toggle strikethrough styling
        if (isCompleted) {
            $(this).next('label').addClass('text-decoration-line-through text-muted');
        } else {
            $(this).next('label').removeClass('text-decoration-line-through text-muted');
        }
        
        // Update task in server (to be implemented)
        console.log(`Task ${taskId} marked as ${isCompleted ? 'completed' : 'incomplete'}`);
    });
}

/**
 * Update booking statistics on dashboard
 */
function updateBookingStats(bookings) {
    if (!bookings || !Array.isArray(bookings)) {
        console.error('Invalid bookings data');
        return;
    }
    
    // Calculate booking statistics
    let totalBookingsCount = bookings.length;
    let confirmedCount = 0;
    let pendingCount = 0;
    let totalCost = 0;
    
    bookings.forEach(booking => {
        if (booking.status === 'confirmed') confirmedCount++;
        else if (booking.status === 'pending') pendingCount++;
        
        // Calculate total cost from all bookings
        if (booking.totalBookingPrice) {
            totalCost += parseFloat(booking.totalBookingPrice);
        }
    });
    
    // Update dashboard elements
    $('#totalBookings').text(totalBookingsCount);
    $('#confirmedBookings').text(confirmedCount);
    $('#pendingBookings').text(pendingCount);
    $('#totalCost').text(formatCurrency(totalCost));
    
    // Update budget progress (assuming total budget is 1.5x the current spent amount for demo)
    const totalBudget = Math.max(10000, totalCost * 1.5);
    const budgetPercentage = Math.min(100, Math.round((totalCost / totalBudget) * 100));
    
    $('#spentAmount').text(formatCurrency(totalCost));
    $('#totalBudget').text(formatCurrency(totalBudget));
    $('#budgetPercentage').text(budgetPercentage + '%');
    $('#budgetProgressBar').css('width', budgetPercentage + '%');
    
    // Add appropriate color class based on percentage
    $('#budgetProgressBar').removeClass('bg-success bg-warning bg-danger');
    if (budgetPercentage < 50) {
        $('#budgetProgressBar').addClass('bg-success');
    } else if (budgetPercentage < 85) {
        $('#budgetProgressBar').addClass('bg-warning');
    } else {
        $('#budgetProgressBar').addClass('bg-danger');
    }
}

/**
 * Update wedding countdown based on booking date
 */
function updateWeddingCountdown(bookings) {
    if (!bookings || !Array.isArray(bookings) || bookings.length === 0) {
        $('#weddingCountdown').html('<p class="text-muted">No wedding date set</p>');
        $('#weddingDate').text('Not set');
        $('#weddingLocation').text('Location not specified');
        $('#countdownStatus').text('Not scheduled');
        return;
    }
    
    // Find the earliest upcoming wedding date (assuming first one for now)
    // In a real system, you might want to filter for only confirmed and upcoming weddings
    const booking = bookings[0];
    const weddingDate = booking.weddingDate;
    const weddingLocation = booking.eventLocation || 'Location not specified';
    
    if (!weddingDate) {
        $('#weddingCountdown').html('<p class="text-muted">No wedding date set</p>');
        $('#weddingDate').text('Not set');
        $('#weddingLocation').text('Location not specified');
        $('#countdownStatus').text('Not scheduled');
        return;
    }
    
    // Display wedding date and location
    $('#weddingDate').text(formatDate(weddingDate));
    $('#weddingLocation').text(weddingLocation);
    
    // Set up countdown timer
    const weddingDateTime = new Date(weddingDate + ' 00:00:00');
    const now = new Date();
    const difference = weddingDateTime - now;
    
    if (difference < 0) {
        // Wedding day has passed
        $('#weddingCountdown').html('<h3>Congratulations!</h3><p>Your wedding day has passed.</p>');
        $('#countdownStatus').text('Completed');
        $('#countdownStatus').removeClass('bg-success bg-warning bg-danger').addClass('bg-secondary');
    } else {
        // Calculate days, hours, minutes, seconds
        const days = Math.floor(difference / (1000 * 60 * 60 * 24));
        const hours = Math.floor((difference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((difference % (1000 * 60 * 60)) / (1000 * 60));
        
        // Display countdown
        let countdownHTML = `
            <div class="countdown-timer">
                <div class="countdown-item">
                    <div class="countdown-value">${days}</div>
                    <div class="countdown-label">Days</div>
                </div>
                <div class="countdown-item">
                    <div class="countdown-value">${hours}</div>
                    <div class="countdown-label">Hours</div>
                </div>
                <div class="countdown-item">
                    <div class="countdown-value">${minutes}</div>
                    <div class="countdown-label">Minutes</div>
                </div>
            </div>
        `;
        
        $('#weddingCountdown').html(countdownHTML);
        
        // Update countdown status
        if (days <= 7) {
            $('#countdownStatus').text('Very Soon!');
            $('#countdownStatus').removeClass('bg-success bg-warning bg-secondary').addClass('bg-danger');
        } else if (days <= 30) {
            $('#countdownStatus').text('Coming Soon');
            $('#countdownStatus').removeClass('bg-success bg-danger bg-secondary').addClass('bg-warning');
        } else {
            $('#countdownStatus').text('Upcoming');
            $('#countdownStatus').removeClass('bg-warning bg-danger bg-secondary').addClass('bg-success');
        }
        
        // Update countdown every minute
        setTimeout(function() {
            updateWeddingCountdown(bookings);
        }, 60000);
    }
}

/**
 * Update review statistics on dashboard
 */
function updateReviewStats(reviews) {
    if (!reviews || !Array.isArray(reviews)) {
        console.error('Invalid reviews data');
        $('#reviewsLoading').html('<p class="text-danger">No review data available</p>');
        return;
    }
    
    // Hide loading indicator
    $('#reviewsLoading').hide();
    
    // Calculate review statistics
    const totalReviews = reviews.length;
    let totalRating = 0;
    
    reviews.forEach(review => {
        totalRating += parseFloat(review.rating);
    });
    
    const averageRating = totalReviews > 0 ? (totalRating / totalReviews).toFixed(1) : '0.0';
    
    // Update dashboard elements
    $('#totalReviews').text(totalReviews);
    $('#avgRating').text(averageRating);
    
    // Update stars display
    const stars = $('#avgStars').children('i');
    const fullStars = Math.floor(averageRating);
    const halfStar = averageRating % 1 >= 0.5;
    
    stars.removeClass('fas far fa-star fa-star-half-alt').addClass('far fa-star');
    
    for (let i = 0; i < fullStars; i++) {
        $(stars[i]).removeClass('far fa-star').addClass('fas fa-star');
    }
    
    if (halfStar && fullStars < 5) {
        $(stars[fullStars]).removeClass('far fa-star').addClass('fas fa-star-half-alt');
    }
}

/**
 * Display recent reviews on dashboard
 */
function displayRecentReviews(reviews) {
    if (!reviews || !Array.isArray(reviews) || reviews.length === 0) {
        $('#reviewsList').html('<p class="text-muted text-center py-3">No reviews found</p>');
        return;
    }
    
    // Sort reviews by date (newest first)
    reviews.sort((a, b) => {
        return new Date(b.reviewDate) - new Date(a.reviewDate);
    });
    
    // Display up to 3 most recent reviews
    const recentReviews = reviews.slice(0, 3);
    let reviewsHTML = '';
    
    recentReviews.forEach(review => {
        const vendorName = review.vendorName || 'Unknown Vendor';
        const serviceName = review.serviceName || 'Service';
        const reviewDate = formatDate(review.reviewDate);
        
        // Generate stars display
        const rating = parseFloat(review.rating);
        let starsHTML = '';
        
        for (let i = 1; i <= 5; i++) {
            if (i <= rating) {
                starsHTML += '<i class="fas fa-star"></i>';
            } else if (i - 0.5 <= rating) {
                starsHTML += '<i class="fas fa-star-half-alt"></i>';
            } else {
                starsHTML += '<i class="far fa-star"></i>';
            }
        }
        
        reviewsHTML += `
            <div class="review-item">
                <div class="d-flex justify-content-between">
                    <h6 class="mb-1">${vendorName} - ${serviceName}</h6>
                    <span class="text-warning">${starsHTML}</span>
                </div>
                <p class="review-comment">${truncateText(review.comment, 120)}</p>
                <div class="d-flex justify-content-between">
                    <small class="text-muted">${reviewDate}</small>
                    <a href="${pageContext.request.contextPath}/user/user-reviews.jsp?review=${review.reviewId}" class="btn btn-sm btn-link p-0">View Details</a>
                </div>
            </div>
        `;
    });
    
    $('#reviewsList').html(reviewsHTML);
}

/**
 * Display services eligible for review
 */
function displayPendingServices(services) {
    // Hide loading indicator
    $('#pendingReviewsLoading').hide();
    
    if (!services || !Array.isArray(services) || services.length === 0) {
        $('#pendingReviewsList').html('<p class="text-center py-3">No services to review at this time.</p>');
        return;
    }
    
    let servicesHTML = '<div class="row g-4">';
    
    services.forEach(service => {
        const vendorName = service.vendorName || 'Unknown Vendor';
        const serviceName = service.serviceName || 'Service';
        const vendorPhoto = service.vendorPhotoUrl || '/assets/images/vendors/default.jpg';
        const serviceDate = formatDate(service.serviceDate);
        
        servicesHTML += `
            <div class="col-md-6">
                <div class="pending-review-item">
                    <div class="pending-review-header">
                        <img src="${vendorPhoto}" alt="${vendorName}" class="vendor-preview">
                        <div class="pending-review-info">
                            <h6>${vendorName}</h6>
                            <p class="mb-0">${serviceName}</p>
                            <div class="pending-review-date">
                                <i class="fas fa-calendar-alt"></i>
                                <span>${serviceDate}</span>
                            </div>
                        </div>
                    </div>
                    <div class="pending-review-actions">
                        <a href="${pageContext.request.contextPath}/user/user-reviews.jsp?writeReview=true&vendorId=${service.vendorId}&serviceId=${service.serviceId}&bookingId=${service.bookingId}" class="btn btn-primary w-100">
                            <i class="fas fa-star me-2"></i>Write Review
                        </a>
                    </div>
                </div>
            </div>
        `;
    });
    
    servicesHTML += '</div>';
    $('#pendingReviewsList').html(servicesHTML);
}

/**
 * Display latest booked services
 */
function updateLatestServices(bookings) {
    if (!bookings || !Array.isArray(bookings) || bookings.length === 0) {
        $('#latestServices').html('<p class="text-muted text-center py-3">No services booked</p>');
        return;
    }
    
    // Prepare service data
    let allServices = [];
    let statusCounts = {
        confirmed: 0,
        pending: 0,
        cancelled: 0,
        completed: 0
    };
    
    bookings.forEach(booking => {
        if (booking.bookedServices && Array.isArray(booking.bookedServices)) {
            booking.bookedServices.forEach(service => {
                // Track status for chart
                const status = service.status || 'pending';
                if (statusCounts.hasOwnProperty(status)) {
                    statusCounts[status]++;
                } else {
                    statusCounts.pending++; // Default to pending if unknown status
                }
                
                // Add to services array
                allServices.push({
                    ...service,
                    bookingId: booking.bookingId,
                    weddingDate: booking.weddingDate
                });
            });
        }
    });
    
    // Hide loading and update chart
    $('#servicesLoading').hide();
    updateServiceChart(statusCounts);
    
    // Sort services by date (newest first based on lastUpdated)
    allServices.sort((a, b) => {
        return new Date(b.lastUpdated || '1970-01-01') - new Date(a.lastUpdated || '1970-01-01');
    });
    
    // Display up to 3 most recent services
    const latestServices = allServices.slice(0, 3);
    let servicesHTML = '';
    
    latestServices.forEach(service => {
        const serviceName = service.serviceName || 'Unknown Service';
        const serviceStatus = service.status || 'pending';
        const serviceDate = service.weddingDate ? formatDate(service.weddingDate) : 'Date not set';
        
        const statusBadge = getStatusBadge(serviceStatus);
        
        servicesHTML += `
            <div class="service-item">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <h6 class="mb-1">${serviceName}</h6>
                        <p class="text-muted mb-0"><small><i class="fas fa-calendar me-1"></i>${serviceDate}</small></p>
                    </div>
                    <div>${statusBadge}</div>
                </div>
                <div class="d-flex justify-content-between align-items-center mt-2">
                    <span class="text-primary">${formatCurrency(service.serviceTotal || 0)}</span>
                    <a href="${pageContext.request.contextPath}/user/user-bookings.jsp?booking=${service.bookingId}" class="btn btn-sm btn-outline-primary">Details</a>
                </div>
            </div>
        `;
    });
    
    $('#latestServices').html(servicesHTML);
}

/**
 * Initialize and update charts
 */
function initCharts() {
    // Service status chart will be initialized with dummy data and updated later
    const options = {
        series: [0, 0, 0, 0],
        chart: {
            height: 220,
            type: 'donut',
            toolbar: {
                show: false
            }
        },
        colors: ['#198754', '#ffc107', '#dc3545', '#0dcaf0'],
        labels: ['Confirmed', 'Pending', 'Cancelled', 'Completed'],
        dataLabels: {
            enabled: true,
            formatter: function(val) {
                return val.toFixed(1) + "%";
            }
        },
        plotOptions: {
            pie: {
                donut: {
                    size: '65%',
                    labels: {
                        show: true,
                        total: {
                            show: true,
                            formatter: function(w) {
                                const total = w.globals.seriesTotals.reduce((a, b) => a + b, 0);
                                return total;
                            }
                        }
                    }
                }
            }
        },
        legend: {
            position: 'bottom',
            horizontalAlign: 'center'
        },
        responsive: [{
            breakpoint: 480,
            options: {
                chart: {
                    height: 200
                },
                legend: {
                    show: false
                }
            }
        }]
    };

    window.serviceChart = new ApexCharts(document.querySelector("#serviceStatusChart"), options);
    window.serviceChart.render();
}

/**
 * Update service status chart with real data
 */
function updateServiceChart(statusCounts) {
    if (!window.serviceChart) {
        console.error('Chart not initialized');
        return;
    }
    
    const confirmed = statusCounts.confirmed || 0;
    const pending = statusCounts.pending || 0;
    const cancelled = statusCounts.cancelled || 0;
    const completed = statusCounts.completed || 0;
    
    window.serviceChart.updateSeries([confirmed, pending, cancelled, completed]);
}

/**
 * Set up event listeners for dashboard elements
 */
function setupEventListeners() {
    // Refresh dashboard
    $('#refreshDashboardBtn').on('click', function(e) {
        e.preventDefault();
        
        // Add spin animation
        $(this).find('i').addClass('fa-spin');
        
        // Reload data
        loadDashboardData();
        
        // Remove spin animation after 1 second
        setTimeout(() => {
            $(this).find('i').removeClass('fa-spin');
            showAlert('Dashboard refreshed successfully', 'success');
        }, 1000);
    });
    
    // Add task modal
    $('#addTaskBtn').on('click', function() {
        $('#addTaskModal').modal('show');
    });
    
    // Save task
    $('#saveTaskBtn').on('click', function() {
        const title = $('#taskTitle').val().trim();
        const description = $('#taskDescription').val().trim();
        const dueDate = $('#taskDueDate').val();
        const priority = $('#taskPriority').val();
        
        if (!title) {
            alert('Please enter a task title');
            return;
        }
        
        // Create new task (in production, you would send this to server)
        const newTask = {
            id: 't' + Math.floor(Math.random() * 10000),
            title: title,
            description: description,
            dueDate: dueDate,
            priority: priority,
            completed: false
        };
        
        // Get current tasks and add new one
        const currentTasks = [];
        $('.task-item').each(function() {
            const taskId = $(this).data('id');
            const taskTitle = $(this).find('label').text();
            const taskDescription = $(this).find('.task-description').text() || '';
            const taskPriority = $(this).find('.badge').text().toLowerCase();
            const dueDate = $(this).find('small').text();
            const isCompleted = $(this).find('input[type="checkbox"]').is(':checked');
            
            currentTasks.push({
                id: taskId,
                title: taskTitle,
                description: taskDescription,
                dueDate: dueDate,
                priority: taskPriority,
                completed: isCompleted
            });
        });
        
        // Add new task to the list
        currentTasks.push(newTask);
        
        // Re-render tasks
        renderTasks(currentTasks);
        
        // Close modal and reset form
        $('#addTaskModal').modal('hide');
        $('#newTaskForm')[0].reset();
        
        // Show success message
        showAlert('Task added successfully', 'success');
    });
}

/**
 * Show alert notification
 */
function showAlert(message, type = 'success') {
    // Create alert element
    const alertDiv = $('<div class="alert-toast"></div>');
    alertDiv.addClass('alert-' + type);
    alertDiv.text(message);
    
    // Add to body
    $('body').append(alertDiv);
    
    // Show with animation
    setTimeout(() => {
        alertDiv.addClass('show');
    }, 10);
    
    // Hide after 3 seconds
    setTimeout(() => {
        alertDiv.removeClass('show');
        setTimeout(() => {
            alertDiv.remove();
        }, 300);
    }, 3000);
}

/**
 * Format currency values
 */
function formatCurrency(amount) {
    return '$' + parseFloat(amount).toFixed(2).replace(/\d(?=(\d{3})+\.)/g, '$&,');
}

/**
 * Format date to readable format
 */
function formatDate(dateString) {
    if (!dateString) return '';
    
    // Check if we have a full date-time string or just a date
    let date;
    if (dateString.includes(':')) {
        date = new Date(dateString);
    } else {
        date = new Date(dateString + 'T00:00:00');
    }
    
    // Check if date is valid
    if (isNaN(date.getTime())) {
        return dateString;
    }
    
    // Format as MMM D, YYYY
    const options = { year: 'numeric', month: 'short', day: 'numeric' };
    return date.toLocaleDateString('en-US', options);
}

/**
 * Format time ago display
 */
function formatTimeAgo(dateString) {
    if (!dateString) return '';
    
    const date = new Date(dateString);
    const now = new Date();
    const diffInSeconds = Math.floor((now - date) / 1000);
    
    if (diffInSeconds < 60) {
        