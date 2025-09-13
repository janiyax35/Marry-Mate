/**
 * Vendor Dashboard JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-07 07:50:54
 * Current User: IT24102137
 */

document.addEventListener('DOMContentLoaded', function() {
    // Sidebar Toggle
    const sidebarToggle = document.getElementById('sidebar-toggle');
    const sidebar = document.querySelector('.sidebar');
    const mainContent = document.querySelector('.main-content');
    
    if (sidebarToggle) {
        sidebarToggle.addEventListener('click', function() {
            sidebar.classList.toggle('sidebar-collapsed');
            mainContent.classList.toggle('sidebar-collapsed');
        });
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
    if (Chart) {
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
    if (FullCalendar && document.getElementById('vendor-calendar')) {
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
                },
                {
                    title: 'Portrait Session',
                    start: '2025-06-03',
                    end: '2025-06-03',
                    backgroundColor: '#3498db',
                    borderColor: '#3498db'
                },
                {
                    title: 'Full Day Wedding',
                    start: '2025-06-15',
                    end: '2025-06-15',
                    backgroundColor: '#e74c3c',
                    borderColor: '#e74c3c'
                }
            ],
            eventClick: function(info) {
                alert('Event: ' + info.event.title + '\nDate: ' + info.event.start.toLocaleDateString());
                // In a real implementation, you would show event details in a modal
            }
        });
        calendar.render();
    }
    
    // Add Service Modal
    const addNewServiceBtn = document.getElementById('addNewServiceBtn');
    const addServiceModal = document.getElementById('addServiceModal');
    const addOptionBtn = document.getElementById('addOptionBtn');
    const saveServiceBtn = document.getElementById('saveServiceBtn');
    
    if (addNewServiceBtn && addServiceModal) {
        addNewServiceBtn.addEventListener('click', function() {
            const modalInstance = new bootstrap.Modal(addServiceModal);
            modalInstance.show();
        });
    }
    
    // Add new customization option
    if (addOptionBtn) {
        addOptionBtn.addEventListener('click', function() {
            const optionsContainer = document.querySelector('.customization-options');
            if (optionsContainer) {
                const newOption = document.createElement('div');
                newOption.className = 'option-item d-flex mb-2';
                newOption.innerHTML = `
                    <input type="text" class="form-control me-2" placeholder="Enter option">
                    <button type="button" class="btn btn-outline-danger remove-option">
                        <i class="fas fa-times"></i>
                    </button>
                `;
                optionsContainer.insertBefore(newOption, addOptionBtn.parentNode);
                
                // Add event listener to the new remove button
                newOption.querySelector('.remove-option').addEventListener('click', function() {
                    optionsContainer.removeChild(newOption);
                });
            }
        });
    }
    
    // Remove customization option
    document.addEventListener('click', function(e) {
        if (e.target.closest('.remove-option')) {
            const optionItem = e.target.closest('.option-item');
            if (optionItem && optionItem.parentNode) {
                optionItem.parentNode.removeChild(optionItem);
            }
        }
    });
    
    // Save Service (mock implementation)
    if (saveServiceBtn) {
        saveServiceBtn.addEventListener('click', function() {
            alert('Service saved! Backend implementation will be added later.');
            // In real implementation, you would collect form data and send to backend
            const modalInstance = bootstrap.Modal.getInstance(addServiceModal);
            modalInstance.hide();
        });
    }
    
    // Handle booking approvals (mock implementation)
    document.addEventListener('click', function(e) {
        const approveBtn = e.target.closest('.dropdown-item.text-success');
        const rejectBtn = e.target.closest('.dropdown-item.text-danger');
        
        if (approveBtn) {
            const bookingId = approveBtn.getAttribute('data-booking-id');
            alert(`Booking ${bookingId} approved! Backend implementation will be added later.`);
        } else if (rejectBtn) {
            const bookingId = rejectBtn.getAttribute('data-booking-id');
            alert(`Booking ${bookingId} rejected! Backend implementation will be added later.`);
        }
    });
    
    // AJAX Setup for future implementations
    $.ajaxSetup({
        beforeSend: function() {
            // Show loading indicator
            console.log('Loading...');
        },
        complete: function() {
            // Hide loading indicator
            console.log('Loaded.');
        },
        error: function(xhr, status, error) {
            // Handle errors
            console.error('An error occurred: ' + error);
            alert('An error occurred while processing your request. Please try again.');
        }
    });
    
    // Mock function for future AJAX implementation
    function loadVendorData() {
        // This would be replaced with actual AJAX call
        $.ajax({
            url: '/api/vendor/dashboard-data',
            type: 'GET',
            dataType: 'json',
            success: function(data) {
                // Update dashboard with data
                console.log('Data loaded successfully.');
            }
        });
    }
    
    // Initialize tooltips
    if (bootstrap && bootstrap.Tooltip) {
        const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
        tooltipTriggerList.map(function(tooltipTriggerEl) {
            return new bootstrap.Tooltip(tooltipTriggerEl);
        });
    }
    
    // Initialize popovers
    if (bootstrap && bootstrap.Popover) {
        const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
        popoverTriggerList.map(function(popoverTriggerEl) {
            return new bootstrap.Popover(popoverTriggerEl);
        });
    }
    
    // Mock implementation for linked list and bubble sort (to be replaced with actual backend)
    class ServiceNode {
        constructor(service) {
            this.service = service;
            this.next = null;
        }
    }
    
    class ServiceLinkedList {
        constructor() {
            this.head = null;
            this.size = 0;
        }
        
        add(service) {
            const newNode = new ServiceNode(service);
            if (!this.head) {
                this.head = newNode;
            } else {
                let current = this.head;
                while (current.next) {
                    current = current.next;
                }
                current.next = newNode;
            }
            this.size++;
        }
        
        bubbleSortByPrice() {
            if (!this.head || !this.head.next) return;
            
            let sorted = false;
            while (!sorted) {
                sorted = true;
                let current = this.head;
                let prev = null;
                
                while (current && current.next) {
                    if (current.service.price > current.next.service.price) {
                        sorted = false;
                        // Swap nodes
                        const temp = current.next;
                        current.next = temp.next;
                        temp.next = current;
                        
                        if (prev) {
                            prev.next = temp;
                        } else {
                            this.head = temp;
                        }
                        
                        prev = temp;
                    } else {
                        prev = current;
                        current = current.next;
                    }
                }
            }
        }
        
        toArray() {
            const result = [];
            let current = this.head;
            while (current) {
                result.push(current.service);
                current = current.next;
            }
            return result;
        }
    }
    
    // Console log for development
    console.log('Vendor Dashboard JS loaded successfully.');
	
	
	
});