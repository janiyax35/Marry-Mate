/**
 * Admin Dashboard JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-04-30 19:22:18
 * Current User: IT24102137
 */

// Wait for document to be fully loaded
document.addEventListener('DOMContentLoaded', function() {
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
    
    // Dropdown functionality
    function setupDropdowns() {
        const dropdownToggles = document.querySelectorAll('[data-dropdown]');
        
        dropdownToggles.forEach(toggle => {
            toggle.addEventListener('click', function(e) {
                e.stopPropagation();
                const target = this.getAttribute('data-dropdown');
                const dropdown = document.getElementById(target);
                
                // Close all other dropdowns
                document.querySelectorAll('.dropdown-menu.show').forEach(menu => {
                    if (menu.id !== target) {
                        menu.classList.remove('show');
                    }
                });
                
                dropdown.classList.toggle('show');
            });
        });
        
        // Close dropdowns when clicking outside
        document.addEventListener('click', function() {
            document.querySelectorAll('.dropdown-menu.show').forEach(menu => {
                menu.classList.remove('show');
            });
        });
    }
    
    // Notification dropdown toggle
    const notificationBtn = document.querySelector('.notification-btn');
    const notificationDropdown = document.querySelector('.notification-dropdown');
    
    if (notificationBtn && notificationDropdown) {
        notificationBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            notificationDropdown.classList.toggle('show');
            
            // Close profile dropdown if open
            const profileDropdown = document.querySelector('.profile-dropdown');
            if (profileDropdown && profileDropdown.classList.contains('show')) {
                profileDropdown.classList.remove('show');
            }
        });
    }
    
    // Profile dropdown toggle
    const profileBtn = document.querySelector('.profile-btn');
    const profileDropdown = document.querySelector('.profile-dropdown');
    
    if (profileBtn && profileDropdown) {
        profileBtn.addEventListener('click', function(e) {
            e.stopPropagation();
            profileDropdown.classList.toggle('show');
            
            // Close notification dropdown if open
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
    
    // Initialize charts
    initializeCharts();
    
    // Initialize DataTables if available
    if ($.fn.DataTable) {
        $('.datatable').DataTable({
            responsive: true,
            pageLength: 10,
            lengthMenu: [[5, 10, 25, 50, -1], [5, 10, 25, 50, "All"]],
            language: {
                search: "",
                searchPlaceholder: "Search...",
                lengthMenu: "Show _MENU_ entries",
                info: "Showing _START_ to _END_ of _TOTAL_ entries",
                infoEmpty: "Showing 0 to 0 of 0 entries",
                infoFiltered: "(filtered from _MAX_ total entries)",
                zeroRecords: "No matching records found"
            }
        });
    }
    
    // Handle report generation
    const generateReportBtn = document.getElementById('generateReportBtn');
    if (generateReportBtn) {
        generateReportBtn.addEventListener('click', function() {
            const reportType = document.getElementById('reportType').value;
            const dateRange = document.getElementById('dateRange').value;
            const reportFormat = document.querySelector('input[name="reportFormat"]:checked').value;
            
            if (!reportType) {
                showToast('Please select a report type', 'warning');
                return;
            }
            
            // Show loading state
            const originalText = this.innerHTML;
            this.innerHTML = '<i class="fas fa-spinner fa-spin me-1"></i> Generating...';
            this.disabled = true;
            
            // Simulate report generation (would be AJAX in production)
            setTimeout(() => {
                // Reset button
                this.innerHTML = originalText;
                this.disabled = false;
                
                // Show success message
                showToast(`Your ${reportType} report has been generated successfully`, 'success');
                
                // Close modal
                const modal = bootstrap.Modal.getInstance(document.getElementById('generateReportModal'));
                modal.hide();
                
                // In production, trigger download
                simulateFileDownload(reportType, dateRange, reportFormat);
            }, 1500);
        });
    }
    
    // Simulate file download
    function simulateFileDownload(reportType, dateRange, format) {
        const reportTypes = {
            users: 'User Growth Report',
            vendors: 'Vendor Performance Report',
            bookings: 'Booking Analytics Report',
            revenue: 'Revenue Report',
            system: 'System Health Report'
        };
        
        const fileName = `${reportTypes[reportType]}_${dateRange}.${format}`;
        
        // Create a temporary link and trigger download
        const link = document.createElement('a');
        link.href = '#';
        link.download = fileName;
        link.click();
        
        console.log(`Downloaded: ${fileName}`);
    }
    
    // Toast notification function
    function showToast(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `admin-toast toast-${type}`;
        toast.innerHTML = `
            <div class="toast-content">
                <i class="fas ${getToastIcon(type)} me-2"></i>
                <span>${message}</span>
            </div>
        `;
        
        // Add toast to container (create if not exists)
        let toastContainer = document.querySelector('.toast-container');
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.className = 'toast-container';
            document.body.appendChild(toastContainer);
        }
        
        toastContainer.appendChild(toast);
        
        // Animate toast in
        setTimeout(() => {
            toast.classList.add('show');
        }, 10);
        
        // Remove toast after delay
        setTimeout(() => {
            toast.classList.remove('show');
            setTimeout(() => {
                toast.remove();
            }, 300);
        }, 5000);
    }
    
    // Get appropriate icon for toast type
    function getToastIcon(type) {
        switch (type) {
            case 'success':
                return 'fa-check-circle';
            case 'warning':
                return 'fa-exclamation-triangle';
            case 'error':
                return 'fa-exclamation-circle';
            default:
                return 'fa-info-circle';
        }
    }
    
    // Initialize charts
    function initializeCharts() {
        // User Growth Chart
        const userGrowthChart = document.getElementById('userGrowthChart');
        if (userGrowthChart) {
            const ctx = userGrowthChart.getContext('2d');
            
            const gradient1 = ctx.createLinearGradient(0, 0, 0, 300);
            gradient1.addColorStop(0, 'rgba(26, 54, 93, 0.6)');
            gradient1.addColorStop(1, 'rgba(26, 54, 93, 0.1)');
            
            const gradient2 = ctx.createLinearGradient(0, 0, 0, 300);
            gradient2.addColorStop(0, 'rgba(200, 178, 115, 0.6)');
            gradient2.addColorStop(1, 'rgba(200, 178, 115, 0.1)');
            
            const months = ['November', 'December', 'January', 'February', 'March', 'April'];
            
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: months,
                    datasets: [
                        {
                            label: 'New Users',
                            data: [120, 145, 180, 210, 245, 280],
                            borderColor: '#1a365d',
                            backgroundColor: gradient1,
                            borderWidth: 2,
                            pointBackgroundColor: '#ffffff',
                            pointBorderColor: '#1a365d',
                            pointBorderWidth: 2,
                            pointRadius: 4,
                            pointHoverRadius: 6,
                            tension: 0.4,
                            fill: true
                        },
                        {
                            label: 'New Vendors',
                            data: [45, 58, 65, 70, 82, 95],
                            borderColor: '#c8b273',
                            backgroundColor: gradient2,
                            borderWidth: 2,
                            pointBackgroundColor: '#ffffff',
                            pointBorderColor: '#c8b273',
                            pointBorderWidth: 2,
                            pointRadius: 4,
                            pointHoverRadius: 6,
                            tension: 0.4,
                            fill: true
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        intersect: false,
                        mode: 'index'
                    },
                    plugins: {
                        legend: {
                            position: 'top',
                            labels: {
                                usePointStyle: true,
                                boxWidth: 6,
                                font: {
                                    family: "'Montserrat', sans-serif",
                                    size: 12
                                }
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(255, 255, 255, 0.95)',
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
                            borderColor: 'rgba(26, 54, 93, 0.1)',
                            borderWidth: 1,
                            padding: 10,
                            boxPadding: 5,
                            usePointStyle: true,
                            callbacks: {
                                label: function(context) {
                                    return ` ${context.dataset.label}: ${context.raw}`;
                                }
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: {
                                display: false
                            },
                            ticks: {
                                font: {
                                    family: "'Montserrat', sans-serif",
                                    size: 12
                                }
                            }
                        },
                        y: {
                            grid: {
                                borderDash: [5, 5],
                                drawBorder: false
                            },
                            ticks: {
                                font: {
                                    family: "'Montserrat', sans-serif",
                                    size: 12
                                }
                            }
                        }
                    }
                }
            });
        }
        
        // Vendor Categories Chart
        const vendorCategoriesChart = document.getElementById('vendorCategoriesChart');
        if (vendorCategoriesChart) {
            const ctx = vendorCategoriesChart.getContext('2d');
            
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Venues', 'Photography', 'Catering', 'Music', 'Flowers', 'Others'],
                    datasets: [
                        {
                            data: [30, 22, 18, 12, 10, 8],
                            backgroundColor: [
                                '#1a365d',
                                '#c8b273',
                                '#2d5a92',
                                '#e0d4a9',
                                '#27ae60',
                                '#95a5a6'
                            ],
                            borderWidth: 0,
                            hoverOffset: 10
                        }
                    ]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                usePointStyle: true,
                                padding: 15,
                                font: {
                                    family: "'Montserrat', sans-serif",
                                    size: 11
                                }
                            }
                        },
                        tooltip: {
                            backgroundColor: 'rgba(255, 255, 255, 0.95)',
                            titleColor: '#1a365d',
                            bodyColor: '#1a365d',
                            titleFont: {
                                family: "'Playfair Display', serif",
                                size: 14
                            },
                            bodyFont: {
                                family: "'Montserrat', sans-serif",
                                size: 12
                            },
                            borderColor: 'rgba(26, 54, 93, 0.1)',
                            borderWidth: 1,
                            padding: 10,
                            callbacks: {
                                label: function(context) {
                                    const label = context.label || '';
                                    const value = context.raw;
                                    const total = context.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                                    const percentage = Math.round((value / total) * 100);
                                    return ` ${label}: ${percentage}% (${value})`;
                                }
                            }
                        }
                    },
                    cutout: '65%',
                    animation: {
                        animateScale: true,
                        animateRotate: true
                    }
                }
            });
        }
    }
    
    // Mark all notifications as read
    const markAllReadBtn = document.querySelector('.mark-all-read');
    if (markAllReadBtn) {
        markAllReadBtn.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Find and remove 'unread' class from all notification items
            const unreadItems = document.querySelectorAll('.notification-list li.unread');
            unreadItems.forEach(item => {
                item.classList.remove('unread');
            });
            
            // Clear notification badge count
            const notificationBadge = document.querySelector('.notification-btn .badge');
            if (notificationBadge) {
                notificationBadge.textContent = '0';
                notificationBadge.style.display = 'none';
            }
            
            // Show success toast
            showToast('All notifications marked as read', 'success');
        });
    }
    
    // Add system event listeners
    document.addEventListener('keydown', function(e) {
        // Close sidebar on ESC key
        if (e.key === 'Escape' && sidebar.classList.contains('show')) {
            sidebar.classList.remove('show');
        }
    });
    
    // Track admin activities for the activity log
    function trackActivity(action) {
        // In production, this would send data to the server
        const activityData = {
            user: 'Administrator',
            action: action,
            timestamp: new Date().toISOString(),
            ip: '192.168.1.1', // This would be retrieved from the server
            userAgent: navigator.userAgent
        };
        
        console.log('Activity tracked:', activityData);
        // Send to server via AJAX in production
    }
    
    // Track page view
    trackActivity('Viewed Admin Dashboard');
    
    // For system refresh button
    const refreshSystemBtn = document.querySelector('.card-actions .btn-outline-secondary');
    if (refreshSystemBtn) {
        refreshSystemBtn.addEventListener('click', function() {
            const spinIcon = this.querySelector('i');
            spinIcon.classList.add('fa-spin');
            
            // Simulate refresh
            setTimeout(() => {
                spinIcon.classList.remove('fa-spin');
                showToast('System status refreshed', 'success');
                // In production, this would update the status data
            }, 1000);
            
            trackActivity('Refreshed System Status');
        });
    }
});