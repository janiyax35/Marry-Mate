/**
 * Vendor Services JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-13 06:21:33
 * Current User: IT24102083
 */

document.addEventListener('DOMContentLoaded', function() {
    // Global variables
    let servicesData = [];
    let currentView = 'table'; // 'table' or 'card'
    let currentSort = 'name-asc'; // default sort
    let servicesTable; // DataTable instance
    
    // Get vendor ID from the session or URL parameter
    const urlParams = new URLSearchParams(window.location.search);
    const vendorIdParam = urlParams.get('vendorId');
    
    // Get context path for proper URL construction
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/vendor") || window.location.pathname.length);
    
    // Initialize DataTable - with check for existing instance
    if ($.fn.DataTable.isDataTable('#servicesTable')) {
        // If table is already initialized, get the existing instance
        servicesTable = $('#servicesTable').DataTable();
    } else {
        // Initialize new DataTable
        servicesTable = $('#servicesTable').DataTable({
            responsive: true,
            order: [[1, 'asc']], // Sort by name by default
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
            language: {
                search: "",
                searchPlaceholder: "Search services..."
            },
            columnDefs: [
                { orderable: false, targets: [0, 6] } // Disable sorting for image and actions columns
            ]
        });
    }

    // Toggle between table and card view
    $('#tableViewBtn').on('click', function() {
        $('#cardView').hide();
        $('#tableView').show();
        $('#tableViewBtn').addClass('active');
        $('#cardViewBtn').removeClass('active');
        currentView = 'table';
        
        // Adjust DataTable columns
        servicesTable.columns.adjust().responsive.recalc();
    });
    
    $('#cardViewBtn').on('click', function() {
        $('#tableView').hide();
        $('#cardView').show();
        $('#cardViewBtn').addClass('active');
        $('#tableViewBtn').removeClass('active');
        currentView = 'card';
    });
    
    // Sort options
    $('.sort-option').on('click', function(e) {
        e.preventDefault();
        currentSort = $(this).data('sort');
        $('#sortOptions').text($(this).text());
        
        sortServices();
        renderServices();
    });
    
    // Preview images on file selection
    $('#serviceIconImage').on('change', function() {
        previewServiceImage(this, 'iconPreview', 'iconPreviewContainer');
    });
    
    $('#serviceBackgroundImage').on('change', function() {
        previewServiceImage(this, 'backgroundPreview', 'backgroundPreviewContainer');
    });
    
    // Show/hide price model fields based on selection
    $('#servicePriceModel').on('change', function() {
        updatePriceModelFields($(this).val());
    });
    
    // Function to show/hide price fields based on model
    function updatePriceModelFields(priceModel) {
        // Hide all price model specific fields first
        $('.price-model-field').hide();
        
        // Show relevant fields based on price model
        if (priceModel === 'hourly') {
            $('.hourly-rate-field').show();
        } else if (priceModel === 'per_guest') {
            $('.per-guest-rate-field').show();
        }
        // For fixed price model, only the base price is shown (default)
    }
    
    // FIX: Remove any existing click handlers by using off() before binding a new one
    $('#addOptionBtn').off('click').on('click', function(e) {
        e.preventDefault();
        e.stopPropagation();
        addCustomizationOptionToForm();
    });
    
    // Remove customization option - using event delegation
    $(document).off('click', '.remove-option').on('click', '.remove-option', function(e) {
        e.preventDefault();
        const optionItem = $(this).closest('.option-item');
        
        // Only remove if there's more than one option
        if ($('.option-item').length > 1) {
            optionItem.remove();
        } else {
            // Clear inputs instead of removing
            optionItem.find('input, textarea').val('');
        }
    });
    
    // Add/Edit Service Modal
    let serviceModal = document.getElementById('addServiceModal');
    serviceModal.addEventListener('show.bs.modal', function(event) {
        const button = event.relatedTarget;
        const serviceId = button ? button.getAttribute('data-service-id') : null;
        
        resetServiceForm();
        
        if (serviceId) {
            // Edit existing service
            $('#serviceModalTitle').text('Edit Service');
            loadServiceDetails(serviceId);
        } else {
            // Add new service
            $('#serviceModalTitle').text('Add New Service');
        }
    });
    
    // Save Service
    $('#saveServiceBtn').on('click', function() {
        if (!validateServiceForm()) {
            return;
        }
        
        const formData = new FormData(document.getElementById('serviceForm'));
        const serviceId = $('#serviceId').val();
        const isNew = !serviceId;
        
        // Add action based on whether we're creating or updating
        formData.append('action', isNew ? 'add' : 'edit');
        
        // Add vendorId from URL parameter if available
        if (vendorIdParam) {
            formData.append('vendorId', vendorIdParam);
        }
        
        // Display loading indicator
        const saveBtn = $(this);
        const originalText = saveBtn.html();
        saveBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Saving...');
        saveBtn.prop('disabled', true);
        
        // Send data to the servlet
        $.ajax({
            url: contextPath + '/vendor/servicesservlet',
            method: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function(response) {
                if (response.status === 'success') {
                    saveBtn.html('<i class="fas fa-check me-2"></i> Saved!');
                    
                    setTimeout(function() {
                        saveBtn.html(originalText);
                        saveBtn.prop('disabled', false);
                        
                        // Close the modal
                        const modalInstance = bootstrap.Modal.getInstance(serviceModal);
                        modalInstance.hide();
                        
                        // Reload services
                        loadServices();
                        
                        // Show success message
                        showAlert(isNew ? 'Service created successfully!' : 'Service updated successfully!', 'success');
                    }, 1000);
                } else {
                    // Show error message
                    saveBtn.html(originalText);
                    saveBtn.prop('disabled', false);
                    showAlert('Error: ' + (response.message || 'Failed to save service'), 'danger');
                }
            },
            error: function(xhr, status, error) {
                saveBtn.html(originalText);
                saveBtn.prop('disabled', false);
                showAlert('Error: ' + error, 'danger');
            }
        });
    });
    
    // Delete Service
    $(document).on('click', '.delete-service-btn', function() {
        const serviceId = $(this).data('service-id');
        $('#deleteServiceId').val(serviceId);
        
        // Show confirmation modal
        const deleteModal = new bootstrap.Modal(document.getElementById('deleteServiceModal'));
        deleteModal.show();
    });
    
    $('#confirmDeleteBtn').on('click', function() {
        const serviceId = $('#deleteServiceId').val();
        
        // Display loading indicator
        const deleteBtn = $(this);
        const originalText = deleteBtn.html();
        deleteBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Deleting...');
        deleteBtn.prop('disabled', true);
        
        // Prepare data for the servlet
        let data = {
            action: 'delete',
            serviceId: serviceId
        };
        
        // Add vendorId from URL parameter if available
        if (vendorIdParam) {
            data.vendorId = vendorIdParam;
        }
        
        // Send delete request to the servlet
        $.ajax({
            url: contextPath + '/vendor/servicesservlet',
            method: 'POST',
            data: data,
            success: function(response) {
                if (response.status === 'success') {
                    deleteBtn.html('<i class="fas fa-check me-2"></i> Deleted!');
                    
                    setTimeout(function() {
                        deleteBtn.html(originalText);
                        deleteBtn.prop('disabled', false);
                        
                        // Close the modal
                        const modalInstance = bootstrap.Modal.getInstance(document.getElementById('deleteServiceModal'));
                        modalInstance.hide();
                        
                        // Reload services
                        loadServices();
                        
                        // Show success message
                        showAlert('Service deleted successfully!', 'danger');
                    }, 1000);
                } else {
                    // Show error message
                    deleteBtn.html(originalText);
                    deleteBtn.prop('disabled', false);
                    showAlert('Error: ' + (response.message || 'Failed to delete service'), 'danger');
                }
            },
            error: function(xhr, status, error) {
                deleteBtn.html(originalText);
                deleteBtn.prop('disabled', false);
                showAlert('Error: ' + error, 'danger');
            }
        });
    });
    
    // Toggle service status
    $(document).on('click', '.toggle-status-btn', function() {
        const serviceId = $(this).data('service-id');
        const currentStatus = $(this).data('current-status');
        const newStatus = currentStatus === 'active' ? 'inactive' : 'active';
        
        // Find the service and update it
        const service = servicesData.find(s => s.serviceId === serviceId);
        if (service) {
            // FIX: Properly handle image data to prevent it from being lost during updates
            
            // Create FormData object to properly handle file uploads and maintain image data
            const formData = new FormData();
            
            // Add basic service information
            formData.append('action', 'edit');
            formData.append('serviceId', serviceId);
            formData.append('serviceName', service.name || '');
            formData.append('serviceCategory', service.category || '');
            formData.append('serviceDescription', service.description || '');
            formData.append('serviceBasePrice', service.basePrice || 0);
            formData.append('serviceDuration', service.baseDuration || 0);
            formData.append('serviceGuestCount', service.baseGuestCount || 0);
            formData.append('servicePriceModel', service.priceModel || 'fixed');
            formData.append('serviceHourlyRate', service.hourlyRate || 0);
            formData.append('servicePerGuestRate', service.perGuestRate || 0);
            formData.append('serviceStatus', newStatus);
            formData.append('serviceSeoKeywords', service.seoKeywords || '');
            formData.append('serviceFeatured', service.isFeatured ? 'on' : '');
            
            // Add image paths to keep existing images
            if (service.images) {
                formData.append('existingIconImage', service.images.icon || '');
                formData.append('existingBackgroundImage', service.images.background || '');
            } else {
                formData.append('existingIconImage', service.iconImage || '');
                formData.append('existingBackgroundImage', service.backgroundImage || '');
            }
            
            // Preserve additionalOptions if they exist
            if (service.additionalOptions && service.additionalOptions.length > 0) {
                service.additionalOptions.forEach((option, index) => {
                    formData.append(`customizationOptionsName[${index}]`, option.name || '');
                    formData.append(`customizationOptionsDesc[${index}]`, option.description || '');
                    formData.append(`customizationOptionsPrice[${index}]`, option.price || 0);
                });
            }
            
            // Add vendorId from URL parameter if available
            if (vendorIdParam) {
                formData.append('vendorId', vendorIdParam);
            }
            
            // Show loading indicator
            const toggleBtn = $(this);
            const originalText = toggleBtn.text();
            toggleBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>');
            toggleBtn.addClass('disabled');
            
            $.ajax({
                url: contextPath + '/vendor/servicesservlet',
                method: 'POST',
                data: formData,
                processData: false,
                contentType: false,
                success: function(response) {
                    toggleBtn.html(originalText);
                    toggleBtn.removeClass('disabled');
                    
                    if (response.status === 'success') {
                        // Reload services
                        loadServices();
                        
                        // Show success message
                        showAlert(`Service ${newStatus === 'active' ? 'activated' : 'deactivated'} successfully!`, 'info');
                    } else {
                        // Show error message
                        showAlert('Error: ' + (response.message || 'Failed to update service status'), 'danger');
                    }
                },
                error: function(xhr, status, error) {
                    toggleBtn.html(originalText);
                    toggleBtn.removeClass('disabled');
                    showAlert('Error: ' + error, 'danger');
                }
            });
        }
    });
    
    // Load services on page load with better error handling
    try {
        loadServices();
    } catch (e) {
        console.error("Error during initial service loading:", e);
        // Show no services message if data can't be loaded
        $('.service-loading').hide();
        $('#tableView').hide();
        $('#cardView').hide();
        $('#noServicesMessage').show();
        showAlert('Error loading services. Please try refreshing the page.', 'danger');
    }
    
    /**
     * Function to load services from backend with improved error handling and timeout
     */
    function loadServices() {
        $('.service-loading').show();
        $('#noServicesMessage').hide();
        
        // Prepare request URL with vendorId parameter if available
        let requestUrl = contextPath + '/vendor/servicesservlet';
        if (vendorIdParam) {
            requestUrl += '?vendorId=' + encodeURIComponent(vendorIdParam);
        }
        
        console.log('Loading services from: ' + requestUrl);
        
        // Get services from the servlet with timeout
        $.ajax({
            url: requestUrl,
            method: 'GET',
            dataType: 'json',
            timeout: 15000, // 15 second timeout
            success: function(data) {
                console.log('Services loaded:', Array.isArray(data) ? data.length : 'Not an array');
                
                // Handle empty or invalid response
                if (!data || (Array.isArray(data) && data.length === 0)) {
                    // Show empty state for no services
                    $('#tableView').hide();
                    $('#cardView').hide();
                    $('#noServicesMessage').show();
                    $('.service-loading').hide();
                    return;
                }
                
                // Ensure data is an array
                servicesData = Array.isArray(data) ? data : (data.services || []);
                
                // Sort services based on current sort option
                sortServices();
                
                // Clear existing data
                servicesTable.clear();
                $('#cardView').find('.col-md-4:not(.service-loading)').remove();
                
                if (servicesData.length === 0) {
                    // Show empty state
                    $('#tableView').hide();
                    $('#cardView').hide();
                    $('#noServicesMessage').show();
                    $('.service-loading').hide();
                    return;
                }
                
                // Hide empty state
                $('#noServicesMessage').hide();
                
                // Show the appropriate view based on current selection
                if (currentView === 'table') {
                    $('#tableView').show();
                    $('#cardView').hide();
                } else {
                    $('#tableView').hide();
                    $('#cardView').show();
                }
                
                // Render services based on current view
                renderServices();
                
                $('.service-loading').hide();
            },
            error: function(xhr, status, error) {
                console.error('Error loading services:', error);
                console.error('Status:', status);
                if (xhr.responseText) {
                    console.error('Response:', xhr.responseText.substring(0, 200) + '...');
                }
                
                // Hide loading indicator
                $('.service-loading').hide();
                
                // Show empty state with message
                $('#tableView').hide();
                $('#cardView').hide();
                $('#noServicesMessage').show();
                
                // Show error alert
                showAlert('Error loading services. Please try again. ' + error, 'danger');
                
                // Create a dummy service for debugging if in development
                if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
                    console.log('Creating dummy service for development testing');
                    servicesData = [{
                        serviceId: 'S1001',
                        name: 'Test Service',
                        category: 'photography',
                        description: 'This is a test service for development',
                        basePrice: 299.99,
                        status: 'active',
                        isFeatured: true,
                        images: {
                            icon: '/assets/images/services/icons/default-profile.jpg',
                            background: '/assets/images/services/backgrounds/default-background.jpg'
                        },
                        additionalOptions: [
                            {name: 'Option 1', description: 'Test description', price: 50}
                        ]
                    }];
                    
                    renderServices();
                }
            }
        });
    }
    
    /**
     * Function to render services in either table or card view
     */
    function renderServices() {
        // Clear existing data
        servicesTable.clear();
        $('#cardView').find('.col-md-4:not(.service-loading)').remove();
        
        // Render in table view
        servicesData.forEach(service => {
            // Get image URLs from the service data
            const iconImageUrl = service.images ? service.images.icon : 
                                (service.iconImage || '/assets/images/vendor/service-placeholder.jpg');
            
            const bgImageUrl = service.images ? service.images.background : 
                              (service.backgroundImage || '/assets/images/vendor/service-placeholder-bg.jpg');
            
            // FIX: Ensure image paths are correct by checking if they already have contextPath
            const iconFullUrl = iconImageUrl.startsWith('http') || iconImageUrl.startsWith('/') ? 
                                iconImageUrl : contextPath + iconImageUrl;
            
            const bgFullUrl = bgImageUrl.startsWith('http') || bgImageUrl.startsWith('/') ? 
                             bgImageUrl : contextPath + bgImageUrl;
            
            // Format the service object for display
            servicesTable.row.add([
                `<img src="${iconFullUrl}" alt="${service.name}" class="service-icon img-thumbnail" style="width: 50px; height: 50px; object-fit: cover;">`,
                service.name,
                service.category,
                service.description ? service.description.substring(0, 50) + (service.description.length > 50 ? '...' : '') : '',
                `$${parseFloat(service.basePrice || 0).toFixed(2)}`,
                `<span class="badge rounded-pill ${service.status === 'active' ? 'bg-success' : 'bg-secondary'}">${service.status === 'active' ? 'Active' : 'Inactive'}</span>`,
                `<div class="dropdown">
                    <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown">
                        <i class="fas fa-ellipsis-v"></i>
                    </button>
                    <div class="dropdown-menu dropdown-menu-end">
                        <a class="dropdown-item edit-service-btn" href="#" data-bs-toggle="modal" data-bs-target="#addServiceModal" data-service-id="${service.serviceId}">
                            <i class="fas fa-edit me-2"></i> Edit
                        </a>
                        <a class="dropdown-item toggle-status-btn" href="#" data-service-id="${service.serviceId}" data-current-status="${service.status}">
                            <i class="fas fa-${service.status === 'active' ? 'eye-slash' : 'eye'} me-2"></i> ${service.status === 'active' ? 'Deactivate' : 'Activate'}
                        </a>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item text-danger delete-service-btn" href="#" data-service-id="${service.serviceId}">
                            <i class="fas fa-trash-alt me-2"></i> Delete
                        </a>
                    </div>
                </div>`
            ]);
            
            // Card view
            let cardHtml = `
                <div class="col-xl-4 col-md-6">
                    <div class="card service-card">
                        <div class="service-card-banner" style="background-image: url('${bgFullUrl}');">
                            <span class="badge rounded-pill ${service.status === 'active' ? 'bg-success' : 'bg-secondary'} position-absolute top-0 end-0 mt-2 me-2">${service.status === 'active' ? 'Active' : 'Inactive'}</span>
                            ${service.isFeatured ? '<span class="badge rounded-pill bg-warning position-absolute top-0 start-0 mt-2 ms-2"><i class="fas fa-star me-1"></i> Featured</span>' : ''}
                        </div>
                        <div class="card-body">
                            <div class="d-flex align-items-center mb-3">
                                <img src="${iconFullUrl}" alt="${service.name}" class="service-card-icon me-3" style="width: 50px; height: 50px; object-fit: cover;">
                                <h5 class="card-title mb-0">${service.name}</h5>
                            </div>
                            <p class="card-text text-muted small mb-1">${service.category}</p>
                            <p class="card-text service-description">${service.description ? service.description.substring(0, 100) + (service.description.length > 100 ? '...' : '') : ''}</p>
                            <div class="service-details mb-3">
                                <div class="row g-2">
                                    <div class="col-6">
                                        <small class="text-muted">Price:</small>
                                        <div>$${parseFloat(service.basePrice || 0).toFixed(2)}</div>
                                    </div>
                                    <div class="col-6">
                                        <small class="text-muted">Duration:</small>
                                        <div>${service.baseDuration || 0} hours</div>
                                    </div>
                                    <div class="col-6">
                                        <small class="text-muted">Price Model:</small>
                                        <div>${service.priceModel || 'Fixed'}</div>
                                    </div>
                                    <div class="col-6">
                                        <small class="text-muted">Options:</small>
                                        <div>${service.additionalOptions ? service.additionalOptions.length : 0}</div>
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-icon" type="button" data-bs-toggle="dropdown">
                                        <i class="fas fa-ellipsis-v"></i>
                                    </button>
                                    <div class="dropdown-menu">
                                        <a class="dropdown-item edit-service-btn" href="#" data-bs-toggle="modal" data-bs-target="#addServiceModal" data-service-id="${service.serviceId}">
                                            <i class="fas fa-edit me-2"></i> Edit
                                        </a>
                                        <a class="dropdown-item toggle-status-btn" href="#" data-service-id="${service.serviceId}" data-current-status="${service.status}">
                                            <i class="fas fa-${service.status === 'active' ? 'eye-slash' : 'eye'} me-2"></i> ${service.status === 'active' ? 'Deactivate' : 'Activate'}
                                        </a>
                                        <div class="dropdown-divider"></div>
                                        <a class="dropdown-item text-danger delete-service-btn" href="#" data-service-id="${service.serviceId}">
                                            <i class="fas fa-trash-alt me-2"></i> Delete
                                        </a>
                                    </div>
                                </div>
                                <button class="btn btn-primary btn-sm edit-service-btn" data-bs-toggle="modal" data-bs-target="#addServiceModal" data-service-id="${service.serviceId}">
                                    <i class="fas fa-edit me-1"></i> Edit
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            $('#cardView').find('.service-loading').before(cardHtml);
        });
        
        servicesTable.draw(false); // false parameter prevents page reset
    }
    
    /**
     * Function to sort services based on selected sort option
     */
    function sortServices() {
        switch(currentSort) {
            case 'name-asc':
                servicesData.sort((a, b) => a.name.localeCompare(b.name));
                break;
            case 'name-desc':
                servicesData.sort((a, b) => b.name.localeCompare(a.name));
                break;
            case 'price-asc':
                // Use bubble sort for price sorting (low to high) as per requirements
                bubbleSortByPrice(servicesData, 'asc');
                break;
            case 'price-desc':
                // Use bubble sort for price sorting (high to low) as per requirements
                bubbleSortByPrice(servicesData, 'desc');
                break;
            case 'date-desc':
                servicesData.sort((a, b) => new Date(b.updatedAt || b.createdAt) - new Date(a.updatedAt || a.createdAt));
                break;
            case 'date-asc':
                servicesData.sort((a, b) => new Date(a.updatedAt || a.createdAt) - new Date(b.updatedAt || b.createdAt));
                break;
            default:
                servicesData.sort((a, b) => a.name.localeCompare(b.name));
        }
    }
    
    /**
     * Bubble sort implementation for sorting services by price
     * Required by project specifications
     */
    function bubbleSortByPrice(arr, direction = 'asc') {
        const n = arr.length;
        let swapped;
        
        for (let i = 0; i < n - 1; i++) {
            swapped = false;
            
            for (let j = 0; j < n - i - 1; j++) {
                const price1 = parseFloat(arr[j].basePrice || arr[j].price || 0);
                const price2 = parseFloat(arr[j + 1].basePrice || arr[j + 1].price || 0);
                
                if (direction === 'asc' ? price1 > price2 : price1 < price2) {
                    // Swap elements
                    const temp = arr[j];
                    arr[j] = arr[j + 1];
                    arr[j + 1] = temp;
                    swapped = true;
                }
            }
            
            // If no swapping occurred in this pass, array is sorted
            if (!swapped) {
                break;
            }
        }
        
        return arr;
    }
    
    /**
     * Function to load service details for editing
     */
    function loadServiceDetails(serviceId) {
        // Find service in current data
        const service = servicesData.find(s => s.serviceId === serviceId);
        
        if (!service) {
            console.error('Service not found:', serviceId);
            return;
        }
        
        // Populate form fields
        $('#serviceId').val(service.serviceId);
        $('#serviceName').val(service.name);
        $('#serviceCategory').val(service.category);
        $('#serviceDescription').val(service.description);
        $('#serviceBasePrice').val(service.basePrice || 0);
        $('#serviceDuration').val(service.baseDuration || 0);
        $('#serviceGuestCount').val(service.baseGuestCount || 0);
        $('#servicePriceModel').val(service.priceModel || 'fixed');
        $('#serviceHourlyRate').val(service.hourlyRate || 0);
        $('#servicePerGuestRate').val(service.perGuestRate || 0);
        $('#serviceStatus').val(service.status === 'active' ? 'active' : 'inactive');
        $('#serviceSeoKeywords').val(service.seoKeywords || '');
        $('#serviceFeatured').prop('checked', service.isFeatured);
        
        // Update price model fields based on selected model
        updatePriceModelFields(service.priceModel || 'fixed');
        
        // Handle customization options
        $('#customizationOptions').empty();
        
        // Check if service has additionalOptions array
        if (service.additionalOptions && service.additionalOptions.length) {
            service.additionalOptions.forEach(option => {
                addCustomizationOptionToForm(
                    option.name || '',
                    option.description || '',
                    option.price || 0
                );
            });
        } else {
            // Add one empty option field
            addCustomizationOptionToForm();
        }
        
        // Show image previews if available
        let iconSrc = '';
        let bgSrc = '';
        
        // Handle both old and new image formats
        if (service.images) {
            iconSrc = service.images.icon;
            bgSrc = service.images.background;
        } else {
            iconSrc = service.iconImage;
            bgSrc = service.backgroundImage;
        }
        
        // FIX: Ensure the image paths are properly constructed with contextPath if needed
        if (iconSrc) {
            const fullIconSrc = iconSrc.startsWith('http') || iconSrc.startsWith('/') ? 
                              iconSrc : contextPath + iconSrc;
            $('#iconPreview').attr('src', fullIconSrc);
            $('#iconPreviewContainer').show();
        }
        
        if (bgSrc) {
            const fullBgSrc = bgSrc.startsWith('http') || bgSrc.startsWith('/') ? 
                            bgSrc : contextPath + bgSrc;
            $('#backgroundPreview').attr('src', fullBgSrc);
            $('#backgroundPreviewContainer').show();
        }
    }
    
    /**
     * Helper function to add a customization option to the form
     */
    function addCustomizationOptionToForm(name = '', description = '', price = 0) {
        // FIX: Use insertAdjacentHTML instead of append to ensure only one option is added
        const optionsContainer = document.getElementById('customizationOptions');
        const optionHtml = `
            <div class="option-item card mb-3 p-3">
                <div class="row g-2">
                    <div class="col-md-12 mb-2">
                        <label class="form-label">Option Name</label>
                        <input type="text" class="form-control" name="customizationOptionsName[]" value="${name}" placeholder="Enter option name">
                    </div>
                    <div class="col-md-12 mb-2">
                        <label class="form-label">Description</label>
                        <textarea class="form-control" name="customizationOptionsDesc[]" placeholder="Enter description" rows="2">${description}</textarea>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Price ($)</label>
                        <input type="number" class="form-control" name="customizationOptionsPrice[]" placeholder="0.00" step="0.01" min="0" value="${price}">
                    </div>
                    <div class="col-md-6 d-flex align-items-end justify-content-end">
                        <button type="button" class="btn btn-outline-danger remove-option">
                            <i class="fas fa-trash-alt me-1"></i> Remove
                        </button>
                    </div>
                </div>
            </div>
        `;
        optionsContainer.insertAdjacentHTML('beforeend', optionHtml);
    }
    
    /**
     * Function to reset the service form
     */
    function resetServiceForm() {
        $('#serviceForm')[0].reset();
        $('#serviceId').val('');
        
        // Reset customization options
        $('#customizationOptions').empty();
        addCustomizationOptionToForm();
        
        // Reset price model fields
        $('#servicePriceModel').val('fixed');
        updatePriceModelFields('fixed');
        
        // Reset image previews
        $('#iconPreviewContainer').hide();
        $('#backgroundPreviewContainer').hide();
    }
    
    /**
     * Function to validate the service form
     */
    function validateServiceForm() {
        const serviceName = $('#serviceName').val().trim();
        const serviceCategory = $('#serviceCategory').val();
        const serviceDescription = $('#serviceDescription').val().trim();
        const serviceBasePrice = $('#serviceBasePrice').val();
        
        if (!serviceName) {
            showAlert('Service name is required', 'danger');
            return false;
        }
        
        if (!serviceCategory) {
            showAlert('Please select a category', 'danger');
            return false;
        }
        
        if (!serviceDescription) {
            showAlert('Service description is required', 'danger');
            return false;
        }
        
        if (!serviceBasePrice || isNaN(parseFloat(serviceBasePrice)) || parseFloat(serviceBasePrice) < 0) {
            showAlert('Please enter a valid price', 'danger');
            return false;
        }
        
        // Validate price model specific fields
        const priceModel = $('#servicePriceModel').val();
        if (priceModel === 'hourly') {
            const hourlyRate = $('#serviceHourlyRate').val();
            if (!hourlyRate || isNaN(parseFloat(hourlyRate)) || parseFloat(hourlyRate) < 0) {
                showAlert('Please enter a valid hourly rate', 'danger');
                return false;
            }
        } else if (priceModel === 'per_guest') {
            const perGuestRate = $('#servicePerGuestRate').val();
            if (!perGuestRate || isNaN(parseFloat(perGuestRate)) || parseFloat(perGuestRate) < 0) {
                showAlert('Please enter a valid per guest rate', 'danger');
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Function to preview service image
     */
    function previewServiceImage(input, previewId, containerId) {
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            
            reader.onload = function(e) {
                document.getElementById(previewId).src = e.target.result;
                document.getElementById(containerId).style.display = 'block';
            };
            
            reader.readAsDataURL(input.files[0]);
        }
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
    
    // If everything else fails, add a button to manually refresh
    setTimeout(function() {
        if ($('.service-loading').is(':visible')) {
            $('.service-loading').html(`
                <div class="text-center py-4">
                    <p class="text-muted mb-3">Taking longer than expected...</p>
                    <button id="manualRefreshBtn" class="btn btn-primary">
                        <i class="fas fa-sync-alt me-2"></i> Refresh Services
                    </button>
                </div>
            `);
            
            $('#manualRefreshBtn').on('click', function() {
                location.reload();
            });
        }
    }, 10000); // Show after 10 seconds
});