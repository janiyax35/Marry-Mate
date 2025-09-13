/**
 * Vendor Dashboard JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time (UTC): 2025-05-15 09:59:33
 * Current User: IT24102137
 */

document.addEventListener('DOMContentLoaded', function() {
    // Sidebar Toggle with improved responsive behavior
    const sidebarToggle = document.getElementById('sidebar-toggle');
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');
    const body = document.querySelector('body');
    
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Add overflow-hidden to body when sidebar is open on mobile
            if (window.innerWidth < 992) {
                body.classList.toggle('sidebar-mobile-open');
                sidebar.classList.toggle('show');
            } else {
                // For desktop view - toggle sidebar collapsed state
                sidebar.classList.toggle('sidebar-collapsed');
                if (sidebar.classList.contains('sidebar-collapsed')) {
                    mainContent.style.marginLeft = '70px';
                } else {
                    mainContent.style.marginLeft = '260px';
                }
            }
            
            // Force reflow to ensure transitions work properly
            window.dispatchEvent(new Event('resize'));
        });
        
        // Close sidebar when clicking on main content on mobile
        mainContent.addEventListener('click', function() {
            if (window.innerWidth < 992 && sidebar.classList.contains('show')) {
                sidebar.classList.remove('show');
                body.classList.remove('sidebar-mobile-open');
            }
        });
        
        // Adjust layout on window resize
        window.addEventListener('resize', function() {
            if (window.innerWidth >= 992) {
                // Desktop view
                body.classList.remove('sidebar-mobile-open');
                sidebar.classList.remove('show');
                
                // Set correct margin based on sidebar state
                if (sidebar.classList.contains('sidebar-collapsed')) {
                    mainContent.style.marginLeft = '70px';
                } else {
                    mainContent.style.marginLeft = '260px';
                }
            } else {
                // Mobile view - remove inline styles to let CSS handle it
                mainContent.style.marginLeft = '';
            }
        });
        
        // Initial setup on page load
        if (window.innerWidth >= 992) {
            if (sidebar.classList.contains('sidebar-collapsed')) {
                mainContent.style.marginLeft = '70px';
            } else {
                mainContent.style.marginLeft = '260px';
            }
        }
    }
    
    // Notification Dropdown
    const notificationBtn = document.querySelector('.notification-btn');
    const notificationDropdown = document.querySelector('.notification-dropdown');
    
    if (notificationBtn && notificationDropdown) {
        notificationBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            notificationDropdown.classList.toggle('show');
            
            if (profileDropdown && profileDropdown.classList.contains('show')) {
                profileDropdown.classList.remove('show');
            }
        });
    }
    
    // Profile Dropdown
    const profileBtn = document.querySelector('.profile-btn');
    const profileDropdown = document.querySelector('.profile-dropdown');
    
    if (profileBtn && profileDropdown) {
        profileBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            profileDropdown.classList.toggle('show');
            
            if (notificationDropdown && notificationDropdown.classList.contains('show')) {
                notificationDropdown.classList.remove('show');
            }
        });
    }
    
    // Close dropdowns when clicking outside
    document.addEventListener('click', function() {
        if (notificationDropdown && notificationDropdown.classList.contains('show')) {
            notificationDropdown.classList.remove('show');
        }
        
        if (profileDropdown && profileDropdown.classList.contains('show')) {
            profileDropdown.classList.remove('show');
        }
    });
    
    // Prevent dropdown close when clicking inside
    if (notificationDropdown) {
        notificationDropdown.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }
    
    if (profileDropdown) {
        profileDropdown.addEventListener('click', function(e) {
            e.stopPropagation();
        });
    }
    
    // Initialize DataTables
    if ($.fn.DataTable) {
        $('.table').DataTable({
            responsive: true,
            paging: true,
            lengthChange: false,
            searching: true,
            ordering: true,
            info: true,
            autoWidth: false,
            pageLength: 5,
            language: {
                search: "",
                searchPlaceholder: "Search..."
            }
        });
    }
    
    // Chart Initializations
    if (typeof Chart !== 'undefined') {
        // Booking Trends Chart
        const bookingTrendsChart = document.getElementById('bookingTrendsChart');
        if (bookingTrendsChart) {
            const bookingChart = new Chart(bookingTrendsChart, {
                type: 'line',
                data: {
                    labels: ['December', 'January', 'February', 'March', 'April', 'May'],
                    datasets: [
                        {
                            label: 'Confirmed Bookings',
                            data: [5, 7, 10, 8, 12, 15],
                            borderColor: '#4a6741',
                            backgroundColor: 'rgba(74, 103, 65, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        },
                        {
                            label: 'Pending Bookings',
                            data: [3, 4, 6, 5, 7, 2],
                            borderColor: '#f39c12',
                            backgroundColor: 'rgba(243, 156, 18, 0.1)',
                            borderWidth: 2,
                            tension: 0.3,
                            fill: true
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'top',
                            labels: {
                                boxWidth: 12
                            }
                        },
                        tooltip: {
                            mode: 'index',
                            intersect: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0
                            }
                        }
                    }
                }
            });
        }
        
        // Revenue by Service Chart
        const revenueByServiceChart = document.getElementById('revenueByServiceChart');
        if (revenueByServiceChart) {
            const revenueChart = new Chart(revenueByServiceChart, {
                type: 'doughnut',
                data: {
                    labels: ['Wedding Photography', 'Engagement Photography', 'Bridal Portraits'],
                    datasets: [{
                        data: [7500, 2400, 2600],
                        backgroundColor: ['#4a6741', '#c8b273', '#3498db'],
                        borderWidth: 1
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                boxWidth: 12
                            }
                        }
                    },
                    cutout: '65%'
                }
            });
        }
    }
    
    // Initialize FullCalendar
    if (typeof FullCalendar !== 'undefined' && document.getElementById('vendor-calendar')) {
        const calendarEl = document.getElementById('vendor-calendar');
        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            headerToolbar: {
                left: 'prev,next today',
                center: 'title',
                right: 'dayGridMonth,timeGridWeek'
            },
            events: [
                {
                    title: 'Wedding Photography',
                    start: '2025-05-15',
                    end: '2025-05-15',
                    backgroundColor: '#4a6741',
                    borderColor: '#4a6741'
                },
                {
                    title: 'Engagement Session',
                    start: '2025-05-22',
                    end: '2025-05-22',
                    backgroundColor: '#c8b273',
                    borderColor: '#c8b273'
                }
            ],
            eventClick: function(info) {
                alert('Event: ' + info.event.title + '\nDate: ' + info.event.start.toLocaleDateString());
            }
        });
        calendar.render();
    }
    
    // Initialize tooltips
    if (typeof bootstrap !== 'undefined' && bootstrap.Tooltip) {
        const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]');
        [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl));
    }
    
    // Initialize popovers
    if (typeof bootstrap !== 'undefined' && bootstrap.Popover) {
        const popoverTriggerList = document.querySelectorAll('[data-bs-toggle="popover"]');
        [...popoverTriggerList].map(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl));
    }
    
    // Console log for development
    console.log('Dashboard JS loaded successfully with fixed sidebar toggle.');
});