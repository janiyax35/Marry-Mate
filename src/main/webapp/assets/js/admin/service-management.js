/**
 * Service Management JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-06 08:11:36
 * Current User: IT24102137
 */

// Main execution when document is ready
$(document).ready(function() {
    // Initialize components
    initializeSidebar();
    initializeDropdowns();
    initializeModals();
    initializeDataTable();
    initializeAOS();
    initializeColorPicker();
    
    // Set up button event handlers
    setupButtonHandlers();
    
    // Initialize view toggle
    initializeViewToggle();
    
    // Initialize image upload handlers
    initializeImageHandlers();
    
    // Initialize customization options
    initializeCustomizationOptions();
    
    // Load service data initially
    loadServices();
    
    // Load categories
    loadCategories();
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
}

/**
 * Initialize DataTables
 */
function initializeDataTable() {
    window.servicesTable = $('#services-table').DataTable({
        columnDefs: [
            { targets: [0], width: "40px", orderable: false },
            { targets: [1], width: "60px" },
            { targets: [7], width: "100px", orderable: false }
        ],
        order: [[6, 'asc']], // Sort by display order by default
        language: {
            search: "",
            searchPlaceholder: "Search services...",
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
    $('#services-table tbody').on('change', 'input[type="checkbox"]', function() {
        updateBulkActionVisibility();
    });

    // "Select All" checkbox functionality
    $('#select-all-services').on('change', function() {
        const isChecked = $(this).prop('checked');
        $('#services-table tbody input[type="checkbox"]').prop('checked', isChecked);
        updateBulkActionVisibility();
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
 * Initialize color picker
 */
function initializeColorPicker() {
    // Initialize Pickr color picker
    if (typeof Pickr !== 'undefined') {
        const pickr = Pickr.create({
            el: '#color-picker-container',
            theme: 'classic',
            default: '#1a365d',
            swatches: [
                '#1a365d', // Navy blue (primary)
                '#e63946', // Red
                '#f1faee', // Off-white
                '#a8dadc', // Light blue
                '#457b9d', // Medium blue
                '#2a9d8f', // Teal
                '#e9c46a', // Gold
                '#f4a261', // Light orange
                '#264653', // Dark teal
                '#bc6c25', // Brown
                '#283618', // Dark green
                '#606c38', // Olive green
                '#723c70', // Purple
                '#5f0f40', // Burgundy
                '#9a031e', // Dark red
                '#0f4c5c'  // Dark blue
            ],
            components: {
                preview: true,
                opacity: true,
                hue: true,
                interaction: {
                    hex: true,
                    rgba: true,
                    input: true,
                    save: true
                }
            }
        });

        // Initial color
        pickr.on('init', instance => {
            const color = $('#service-color').val() || '#1a365d';
            instance.setColor(color);
        });

        // When color is changed
        pickr.on('change', (color, instance) => {
            const hexColor = color.toHEXA().toString();
            $('#service-color').val(hexColor);
        });

        // When color is saved
        pickr.on('save', (color, instance) => {
            if (color) {
                const hexColor = color.toHEXA().toString();
                $('#service-color').val(hexColor);
            }
            instance.hide();
        });

        // Update color picker when input changes
        $('#service-color').on('input', function() {
            const color = $(this).val();
            if (color && color.startsWith('#')) {
                pickr.setColor(color);
            }
        });
    }
}

/**
 * Initialize view toggle between grid, list, and compact views
 */
function initializeViewToggle() {
    // Listen for changes on view option radio buttons
    $('input[name="view-option"]').on('change', function() {
        const view = $(this).attr('id').replace('view-', '');
        toggleView(view);
    });
}

/**
 * Toggle between different views (grid, list, compact)
 * @param {String} view - View type (grid, list, compact)
 */
function toggleView(view) {
    // Hide all views first
    $('#services-grid-view, #services-list-view, #services-compact-view').hide();
    
    // Show the selected view
    $(`#services-${view}-view`).show();
    
    // If list view, redraw DataTable to fix column widths
    if (view === 'list') {
        if (window.servicesTable) {
            window.servicesTable.columns.adjust().draw();
        }
    }
    
    // Store user preference (could be saved in localStorage or cookies)
    localStorage.setItem('serviceViewPreference', view);
}

/**
 * Initialize image upload handlers
 */
function initializeImageHandlers() {
    // Service icon
    $('input[name="icon-type"]').on('change', function() {
        const option = $('input[name="icon-type"]:checked').attr('id');
        
        $('#icon-url-input, #icon-upload-input, #icon-fa-input').hide();
        
        if (option === 'icon-url-option') {
            $('#icon-url-input').show();
        } else if (option === 'icon-upload-option') {
            $('#icon-upload-input').show();
        } else if (option === 'icon-fa-option') {
            $('#icon-fa-input').show();
        }
    });
    
    // Background image
    $('input[name="bg-type"]').on('change', function() {
        const option = $('input[name="bg-type"]:checked').attr('id');
        
        $('#bg-url-input, #bg-upload-input').hide();
        
        if (option === 'bg-url-option') {
            $('#bg-url-input').show();
        } else if (option === 'bg-upload-option') {
            $('#bg-upload-input').show();
        }
    });
    
    // Preview icon image URL
    $('#service-icon-path').on('input', function() {
        updateIconPreview($(this).val());
    });
    
    // Preview icon upload
    $('#service-icon-upload').on('change', function() {
        const file = this.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                updateIconPreview(e.target.result);
            };
            reader.readAsDataURL(file);
        }
    });
    
    // Preview Font Awesome icon
    $('#service-icon-fa').on('input', function() {
        const iconClass = $(this).val();
        if (iconClass) {
            $('#icon-preview').html(`<i class="fas ${iconClass}"></i>`);
        } else {
            $('#icon-preview').html('<i class="fas fa-image"></i>');
        }
    });
    
    // Preview background image URL
    $('#service-bg-path').on('input', function() {
        updateBgPreview($(this).val());
    });
    
    // Preview background upload
    $('#service-bg-upload').on('change', function() {
        const file = this.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                updateBgPreview(e.target.result);
            };
            reader.readAsDataURL(file);
        }
    });
}

/**
 * Update icon preview
 * @param {String} url - Icon image URL
 */
function updateIconPreview(url) {
    if (url) {
        $('#icon-preview').html(`<img src="${url}" alt="Icon Preview">`);
    } else {
        $('#icon-preview').html('<i class="fas fa-image"></i>');
    }
}

/**
 * Update background preview
 * @param {String} url - Background image URL
 */
function updateBgPreview(url) {
    if (url) {
        $('#bg-preview').attr('src', url);
    } else {
        $('#bg-preview').attr('src', '/assets/images/placeholder-bg.jpg');
    }
}

/**
 * Initialize customization options
 */
function initializeCustomizationOptions() {
    // Add new option
    $('#add-option-btn').on('click', function() {
        const optionText = $('#new-option').val().trim();
        if (optionText) {
            addCustomizationOption(optionText);
            $('#new-option').val('').focus();
        } else {
            showToast('Warning', 'Please enter an option text', 'warning');
        }
    });
    
    // Allow Enter key to add option
    $('#new-option').on('keypress', function(e) {
        if (e.which === 13) {
            e.preventDefault();
            $('#add-option-btn').click();
        }
    });
    
    // Initialize Sortable for drag and drop
    if (typeof Sortable !== 'undefined') {
        new Sortable(document.getElementById('customization-options-list'), {
            handle: '.option-handle',
            animation: 150,
            ghostClass: 'dragging'
        });
    }
}

/**
 * Add a customization option to the list
 * @param {String} optionText - Option text to add
 * @param {Boolean} isEdit - Whether this is done during edit (to avoid animations)
 */
function addCustomizationOption(optionText, isEdit = false) {
    // Create option item HTML
    const optionId = 'option-' + Date.now();
    const optionItem = `
        <div class="option-item ${!isEdit ? 'animate__animated animate__fadeIn' : ''}">
            <div class="option-text">${optionText}</div>
            <div class="option-actions">
                <button type="button" class="option-handle" title="Drag to Reorder">
                    <i class="fas fa-grip-vertical"></i>
                </button>
                <button type="button" class="option-edit" title="Edit Option" data-option-id="${optionId}">
                    <i class="fas fa-pencil-alt"></i>
                </button>
                <button type="button" class="option-delete" title="Remove Option" data-option-id="${optionId}">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <input type="hidden" name="customizationOptions[]" value="${optionText}">
        </div>
    `;
    
    // Add to list
    $('#customization-options-list').append(optionItem);
    
    // Bind event handlers
    $(`[data-option-id="${optionId}"]`).each(function() {
        const $button = $(this);
        
        if ($button.hasClass('option-edit')) {
            $button.on('click', function() {
                editOption($(this).closest('.option-item'));
            });
        } else if ($button.hasClass('option-delete')) {
            $button.on('click', function() {
                deleteOption($(this).closest('.option-item'));
            });
        }
    });
}

/**
 * Edit an option
 * @param {JQuery} $optionItem - Option item jQuery element
 */
function editOption($optionItem) {
    const currentText = $optionItem.find('.option-text').text();
    
    Swal.fire({
        title: 'Edit Option',
        input: 'text',
        inputValue: currentText,
        inputAttributes: {
            autocapitalize: 'off'
        },
        showCancelButton: true,
        confirmButtonText: 'Save',
        showLoaderOnConfirm: true,
        preConfirm: (newText) => {
            if (!newText.trim()) {
                Swal.showValidationMessage('Option text cannot be empty');
                return false;
            }
            return newText;
        },
        allowOutsideClick: () => !Swal.isLoading()
    }).then((result) => {
        if (result.isConfirmed) {
            $optionItem.find('.option-text').text(result.value);
            $optionItem.find('input[name="customizationOptions[]"]').val(result.value);
        }
    });
}

/**
 * Delete an option
 * @param {JQuery} $optionItem - Option item jQuery element
 */
function deleteOption($optionItem) {
    $optionItem.addClass('animate__animated animate__fadeOut');
    setTimeout(() => {
        $optionItem.remove();
    }, 500);
}

/**
 * Update bulk action visibility based on selected items
 */
function updateBulkActionVisibility() {
    const selectedCount = $('#services-table tbody input[type="checkbox"]:checked').length;
    $('#selected-count').text(selectedCount);
    
    if (selectedCount > 0) {
        $('#bulk-actions-card').slideDown(300);
    } else {
        $('#bulk-actions-card').slideUp(300);
    }
}

/**
 * Set up button event handlers
 */
function setupButtonHandlers() {
    // Filter button click
    $('#search-btn').on('click', function() {
        filterServices();
    });
    
    // Reset filters button click
    $('#reset-filters').on('click', function() {
        $('#category-filter').val('');
        $('#status-filter').val('');
        $('#price-range').val('');
        $('#search-services').val('');
        filterServices();
    });
    
    // Refresh services button click
    $('#refresh-services').on('click', function() {
        loadServices();
		loadServices();
    });
    
    // Add service button click
    $('#add-service-btn, #no-services-add-btn').on('click', function() {
        resetServiceForm();
        $('#serviceModalTitle').text('Add New Service');
        $('#save-service-btn').text('Create Service');
        $('#serviceModal').modal('show');
    });
    
    // Save service button click
    $('#save-service-btn').on('click', function() {
        saveService();
    });
    
    // Edit service button click
    $('#edit-service-btn').on('click', function() {
        const serviceId = $('#view-service-id').text();
        $('#viewServiceModal').modal('hide');
        editService(serviceId);
    });
    
    // Delete service confirmation button click
    $('#confirm-delete-btn').on('click', function() {
        deleteService($('#delete-service-id').val());
    });
    
    // Manage categories button click
    $('#manage-categories-btn').on('click', function() {
        $('#manageCategoriesModal').modal('show');
    });
    
    // Add category button click
    $('#add-category-btn').on('click', function() {
        const categoryName = $('#new-category-name').val().trim();
        if (categoryName) {
            addCategory(categoryName);
            $('#new-category-name').val('').focus();
        } else {
            showToast('Warning', 'Please enter a category name', 'warning');
        }
    });
    
    // Save categories button click
    $('#save-categories-btn').on('click', function() {
        saveCategories();
    });
    
    // Confirm bulk delete button click
    $('#confirm-bulk-delete-btn').on('click', function() {
        executeBulkDelete();
    });
    
    // Bulk action buttons
    $('.bulk-action-btn').on('click', function() {
        const action = $(this).data('action');
        executeBulkAction(action);
    });
    
    // Sort by change
    $('#sort-by').on('change', function() {
        sortServices($(this).val());
    });
    
    // Allow pressing Enter on search field
    $('#search-services').on('keypress', function(e) {
        if (e.which === 13) {
            e.preventDefault();
            $('#search-btn').click();
        }
    });
}

/**
 * Load service data from the server
 */
function loadServices() {
    // Show loading indicator
    $('#services-grid').html('');
    $('#services-loader').show();
    
    // Make AJAX request
    $.ajax({
        url: contextPath + '/ServiceManagementServlet',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            $('#services-loader').hide();
            
            if (data && data.length > 0) {
                populateServicesGrid(data);
                populateServicesTable(data);
                populateServicesCompact(data);
                updateServiceCounts(data);
            } else {
                showNoServicesMessage();
            }
        },
        error: function(xhr, status, error) {
            $('#services-loader').hide();
            handleAjaxError(xhr, 'Failed to load services');
            showNoServicesMessage();
        }
    });
}

/**
 * Load categories from the server
 */
function loadCategories() {
    $.ajax({
        url: contextPath + '/ServiceManagementServlet/categories',
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            populateCategories(data);
            populateCategoryManagement(data);
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load categories');
        }
    });
}

/**
 * Populate services in grid view
 * @param {Array} services - The array of service objects
 */
function populateServicesGrid(services) {
    let gridHtml = '';
    
    services.forEach((service, index) => {
        const isActive = service.active;
        const iconHtml = getServiceIconHtml(service);
        
        gridHtml += `
            <div class="col-md-6 col-lg-4 col-xl-3 mb-4" data-aos="fade-up" data-aos-delay="${(index % 12) * 50}">
                <div class="service-card">
                    <div class="service-card-header">
                        <img src="${service.backgroundImagePath || '/assets/images/placeholder-bg.jpg'}" alt="${service.serviceName}">
                        <div class="overlay"></div>
                        <div class="service-card-status">
                            ${isActive ? 
                                '<span class="badge badge-active"><i class="fas fa-check-circle"></i> Active</span>' : 
                                '<span class="badge badge-inactive"><i class="fas fa-times-circle"></i> Inactive</span>'}
                        </div>
                    </div>
                    <div class="service-card-body">
                        <div class="service-card-icon">
                            ${iconHtml}
                        </div>
                        <h4 class="service-card-title">${service.serviceName}</h4>
                        <div class="service-card-category">
                            <i class="fas fa-tag"></i> ${formatCategoryName(service.category)}
                        </div>
                        <div class="service-card-price">$${parseFloat(service.basePrice).toFixed(2)}</div>
                    </div>
                    <div class="service-card-footer">
                        <div class="service-card-order">
                            Display Order: ${service.displayOrder}
                        </div>
                        <div class="service-card-actions">
                            <button class="btn btn-sm btn-outline-primary view-service" data-service-id="${service.serviceId}">
                                <i class="fas fa-eye"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-secondary edit-service" data-service-id="${service.serviceId}">
                                <i class="fas fa-edit"></i>
                            </button>
                            <button class="btn btn-sm btn-outline-danger delete-service" data-service-id="${service.serviceId}">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;
    });
    
    $('#services-grid').html(gridHtml);
    
    // Set up action button handlers
    setupServiceActionHandlers();
}

/**
 * Populate services in table view
 * @param {Array} services - The array of service objects
 */
function populateServicesTable(services) {
    const table = window.servicesTable;
    
    // Clear existing data
    table.clear();
    
    // Add rows
    services.forEach(service => {
        table.row.add([
            `<div class="form-check">
                <input class="form-check-input" type="checkbox" value="${service.serviceId}">
            </div>`,
            service.serviceId,
            getServiceNameCell(service),
            formatCategoryName(service.category),
            `$${parseFloat(service.basePrice).toFixed(2)}`,
            service.active ? 
                '<span class="badge badge-active"><i class="fas fa-check-circle"></i> Active</span>' : 
                '<span class="badge badge-inactive"><i class="fas fa-times-circle"></i> Inactive</span>',
            service.displayOrder,
            getServiceActionButtons(service.serviceId)
        ]);
    });
    
    // Draw the table
    table.draw();
    
    // Set up action button handlers
    setupTableActionHandlers();
}

/**
 * Populate services in compact view
 * @param {Array} services - The array of service objects
 */
function populateServicesCompact(services) {
    // Group services by category
    const categoryGroups = {};
    services.forEach(service => {
        const category = service.category;
        if (!categoryGroups[category]) {
            categoryGroups[category] = [];
        }
        categoryGroups[category].push(service);
    });
    
    let compactHtml = '';
    
    // Create category groups
    for (const category in categoryGroups) {
        const categoryServices = categoryGroups[category];
        const categoryIcon = getCategoryIcon(category);
        
        compactHtml += `
            <div class="category-group">
                <div class="category-header">
                    <div class="category-icon">
                        <i class="${categoryIcon}"></i>
                    </div>
                    <h5>${formatCategoryName(category)}</h5>
                </div>
                <div class="compact-services-list">
        `;
        
        // Add services for this category
        categoryServices.forEach(service => {
            const iconHtml = getServiceIconHtml(service);
            
            compactHtml += `
                <div class="compact-service-card">
                    <div class="compact-service-icon">
                        ${iconHtml}
                    </div>
                    <div class="compact-service-info">
                        <div class="compact-service-name">${service.serviceName}</div>
                        <div class="compact-service-meta">
                            <span class="compact-service-price">$${parseFloat(service.basePrice).toFixed(2)}</span>
                            ${service.active ? 
                                '<span class="badge badge-active"><i class="fas fa-check-circle me-1"></i>Active</span>' : 
                                '<span class="badge badge-inactive"><i class="fas fa-times-circle me-1"></i>Inactive</span>'}
                        </div>
                    </div>
                    <div class="compact-service-actions">
                        <button class="btn btn-sm btn-outline-primary view-service" data-service-id="${service.serviceId}">
                            <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-sm btn-outline-secondary edit-service" data-service-id="${service.serviceId}">
                            <i class="fas fa-edit"></i>
                        </button>
                    </div>
                </div>
            `;
        });
        
        compactHtml += '</div></div>';
    }
    
    $('.services-category-groups').html(compactHtml);
    
    // Set up action button handlers
    setupCompactViewActionHandlers();
}

/**
 * Update service counts
 * @param {Array} services - The array of service objects
 */
function updateServiceCounts(services) {
    const activeCount = services.filter(service => service.active).length;
    const inactiveCount = services.length - activeCount;
    
    $('#active-services-count').text(activeCount);
    $('#inactive-services-count').text(inactiveCount);
}

/**
 * Show "no services found" message
 */
function showNoServicesMessage() {
    $('#services-grid').html('');
    $('#no-services-message').show();
}

/**
 * Populate categories in the category management modal
 * @param {Array} categories - The array of category objects
 */
function populateCategories(categories) {
    let categoriesHtml = '';
    
    categories.forEach(category => {
        const count = category.serviceCount || 0;
        const icon = getCategoryIcon(category.name);
        
        categoriesHtml += `
            <div class="col-md-3 col-sm-4 col-6 text-center" data-aos="fade-up">
                <div class="category-pill${category.active ? ' active' : ''}" data-category="${category.name}">
                    <i class="${icon}"></i> ${formatCategoryName(category.name)}
                    <span class="badge bg-light text-dark category-count">${count}</span>
                </div>
            </div>
        `;
    });
    
    $('#categories-list').html(categoriesHtml);
    
    // Category click handler
    $('.category-pill').on('click', function() {
        const category = $(this).data('category');
        $('#category-filter').val(category);
        filterServices();
        
        // Scroll to services section
        $('html, body').animate({
            scrollTop: $('#services-grid-view').offset().top - 100
        }, 300);
    });
}

/**
 * Populate categories in the category management modal
 * @param {Array} categories - The array of category objects
 */
function populateCategoryManagement(categories) {
    let categoriesHtml = '';
    
    categories.forEach(category => {
        const count = category.serviceCount || 0;
        
        categoriesHtml += `
            <div class="category-item">
                <div class="category-name">${formatCategoryName(category.name)}</div>
                <div class="category-item-actions">
                    <span class="badge bg-light text-dark">${count}</span>
                    ${count === 0 ? `
                        <button type="button" class="category-delete" data-category="${category.name}">
                            <i class="fas fa-trash-alt"></i>
                        </button>
                    ` : ''}
                </div>
            </div>
        `;
    });
    
    $('#manage-categories-list').html(categoriesHtml);
    
    // Category delete handler
    $('.category-delete').on('click', function() {
        const category = $(this).data('category');
        deleteCategory(category);
    });
}

/**
 * Get HTML for service icon
 * @param {Object} service - Service object
 * @return {String} - HTML for icon
 */
function getServiceIconHtml(service) {
    if (service.iconPath && service.iconPath.startsWith('fa-')) {
        // Font Awesome icon
        return `<i class="fas ${service.iconPath}"></i>`;
    } else if (service.iconPath) {
        // Image icon
        return `<img src="${service.iconPath}" alt="${service.serviceName} icon">`;
    } else {
        // Default icon based on category
        const categoryIcon = getCategoryIcon(service.category);
        return `<i class="${categoryIcon}"></i>`;
    }
}

/**
 * Get icon class for a category
 * @param {String} category - Category name
 * @return {String} - FontAwesome icon class
 */
function getCategoryIcon(category) {
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
 * @param {String} category - Category name
 * @return {String} - Formatted category name
 */
function formatCategoryName(category) {
    if (!category) return '';
    return category.charAt(0).toUpperCase() + category.slice(1);
}

/**
 * Create HTML for service name cell in table view
 * @param {Object} service - Service object
 * @return {String} - HTML for service name cell
 */
function getServiceNameCell(service) {
    return `
        <div class="service-name-cell">
            <div class="service-list-image">
                <img src="${service.backgroundImagePath || '/assets/images/placeholder-bg.jpg'}" alt="${service.serviceName}">
            </div>
            <div class="service-details">
                <p class="service-name">${service.serviceName}</p>
                <p class="service-description">${service.description}</p>
            </div>
        </div>
    `;
}

/**
 * Create action buttons HTML for table view
 * @param {String} serviceId - Service ID
 * @return {String} - HTML for action buttons
 */
function getServiceActionButtons(serviceId) {
    return `
        <div class="d-flex gap-1">
            <button class="btn btn-sm btn-outline-primary view-service-table" data-service-id="${serviceId}">
                <i class="fas fa-eye"></i>
            </button>
            <button class="btn btn-sm btn-outline-secondary edit-service-table" data-service-id="${serviceId}">
                <i class="fas fa-edit"></i>
            </button>
            <button class="btn btn-sm btn-outline-danger delete-service-table" data-service-id="${serviceId}">
                <i class="fas fa-trash-alt"></i>
            </button>
        </div>
    `;
}

/**
 * Set up action button handlers for grid view
 */
function setupServiceActionHandlers() {
    // View service button
    $('.view-service').on('click', function() {
        const serviceId = $(this).data('service-id');
        viewService(serviceId);
    });
    
    // Edit service button
    $('.edit-service').on('click', function() {
        const serviceId = $(this).data('service-id');
        editService(serviceId);
    });
    
    // Delete service button
    $('.delete-service').on('click', function() {
        const serviceId = $(this).data('service-id');
        confirmDeleteService(serviceId);
    });
}

/**
 * Set up action button handlers for table view
 */
function setupTableActionHandlers() {
    // View service button
    $('.view-service-table').on('click', function() {
        const serviceId = $(this).data('service-id');
        viewService(serviceId);
    });
    
    // Edit service button
    $('.edit-service-table').on('click', function() {
        const serviceId = $(this).data('service-id');
        editService(serviceId);
    });
    
    // Delete service button
    $('.delete-service-table').on('click', function() {
        const serviceId = $(this).data('service-id');
        confirmDeleteService(serviceId);
    });
}

/**
 * Set up action button handlers for compact view
 */
function setupCompactViewActionHandlers() {
    // View service button
    $('.compact-service-actions .view-service').on('click', function() {
        const serviceId = $(this).data('service-id');
        viewService(serviceId);
    });
    
    // Edit service button
    $('.compact-service-actions .edit-service').on('click', function() {
        const serviceId = $(this).data('service-id');
        editService(serviceId);
    });
}

/**
 * View service details
 * @param {String} serviceId - Service ID
 */
function viewService(serviceId) {
    // Get service data
    $.ajax({
        url: contextPath + '/ServiceManagementServlet',
        type: 'GET',
        data: {
            serviceId: serviceId
        },
        dataType: 'json',
        success: function(service) {
            // Populate service details in view modal
            $('#view-service-name').text(service.serviceName);
            $('#view-service-id').text(service.serviceId);
            $('#view-service-category').text(formatCategoryName(service.category));
            $('#view-service-price').text(`$${parseFloat(service.basePrice).toFixed(2)}`);
            $('#view-service-description').text(service.description || 'No description available.');
            $('#view-display-order').text(service.displayOrder);
            
            // Set background image
            if (service.backgroundImagePath) {
                $('#view-bg-image').css('background-image', `url('${service.backgroundImagePath}')`);
            } else {
                $('#view-bg-image').css('background-image', `url('/assets/images/placeholder-bg.jpg')`);
            }
            
            // Set icon
            if (service.iconPath && service.iconPath.startsWith('fa-')) {
                $('#view-service-icon').html(`<i class="fas ${service.iconPath}"></i>`);
            } else if (service.iconPath) {
                $('#view-service-icon').html(`<img src="${service.iconPath}" alt="${service.serviceName} icon">`);
            } else {
                const categoryIcon = getCategoryIcon(service.category);
                $('#view-service-icon').html(`<i class="${categoryIcon}"></i>`);
            }
            
            // Set status
            $('#view-service-status').removeClass('bg-success bg-secondary');
            if (service.active) {
                $('#view-service-status').addClass('bg-success').html('Active');
            } else {
                $('#view-service-status').addClass('bg-secondary').html('Inactive');
            }
            
            // Set customization options
            if (service.customizationOptions && service.customizationOptions.length > 0) {
                let optionsHtml = '<div class="d-flex flex-wrap">';
                service.customizationOptions.forEach(option => {
                    optionsHtml += `<span class="option-chip">${option}</span>`;
                });
                optionsHtml += '</div>';
                $('#view-customization-options').html(optionsHtml);
            } else {
                $('#view-customization-options').html('<p class="text-muted">No customization options defined.</p>');
            }
            
            // Show the modal
            $('#viewServiceModal').modal('show');
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load service details');
        }
    });
}

/**
 * Edit service
 * @param {String} serviceId - Service ID
 */
function editService(serviceId) {
    // Get service data
    $.ajax({
        url: contextPath + '/ServiceManagementServlet',
        type: 'GET',
        data: {
            serviceId: serviceId
        },
        dataType: 'json',
        success: function(service) {
            // Reset form first
            resetServiceForm();
            
            // Set service ID
            $('#service-id').val(service.serviceId);
            
            // Populate form fields
            $('#service-name').val(service.serviceName);
            $('#service-category').val(service.category);
            $('#service-description').val(service.description);
            $('#service-base-price').val(service.basePrice);
            $('#service-display-order').val(service.displayOrder);
            
            // Set active status
            if (service.active) {
                $('#status-active').prop('checked', true);
            } else {
                $('#status-inactive').prop('checked', true);
            }
            
            // Set icon
            if (service.iconPath) {
                if (service.iconPath.startsWith('fa-')) {
                    $('#icon-fa-option').prop('checked', true);
                    $('#icon-fa-input').show();
                    $('#icon-url-input').hide();
                    $('#icon-upload-input').hide();
                    $('#service-icon-fa').val(service.iconPath);
                    $('#icon-preview').html(`<i class="fas ${service.iconPath}"></i>`);
                } else {
                    $('#icon-url-option').prop('checked', true);
                    $('#icon-url-input').show();
                    $('#icon-fa-input').hide();
                    $('#icon-upload-input').hide();
                    $('#service-icon-path').val(service.iconPath);
                    updateIconPreview(service.iconPath);
                }
            }
            
            // Set background image
            if (service.backgroundImagePath) {
                $('#bg-url-option').prop('checked', true);
                $('#bg-url-input').show();
                $('#bg-upload-input').hide();
                $('#service-bg-path').val(service.backgroundImagePath);
                updateBgPreview(service.backgroundImagePath);
            }
            
            // Set color if available
            if (service.themeColor) {
                $('#service-color').val(service.themeColor);
                if (window.pickr) {
                    window.pickr.setColor(service.themeColor);
                }
            }
            
            // Set display options if available
            if (service.featured) {
                $('#featured-service').prop('checked', true);
            }
            if (service.popular) {
                $('#popular-service').prop('checked', true);
            }
            if (service.new) {
                $('#new-service').prop('checked', true);
            }
            
            // Set SEO keywords if available
            if (service.seoKeywords) {
                $('#service-seo-keywords').val(service.seoKeywords);
            }
            
            // Populate customization options
            $('#customization-options-list').empty();
            if (service.customizationOptions && service.customizationOptions.length > 0) {
                service.customizationOptions.forEach(option => {
                    addCustomizationOption(option, true);
                });
            }
            
            // Update modal title and button text
            $('#serviceModalTitle').text('Edit Service');
            $('#save-service-btn').text('Save Changes');
            
            // Show the modal
            $('#serviceModal').modal('show');
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load service details');
        }
    });
}

/**
 * Reset the service form
 */
function resetServiceForm() {
    $('#service-form')[0].reset();
    $('#service-form').removeClass('was-validated');
    $('#service-id').val('');
    
    // Reset icon preview
    $('#icon-preview').html('<i class="fas fa-image"></i>');
    $('#bg-preview').attr('src', '/assets/images/placeholder-bg.jpg');
    
    // Reset icon/image input visibility
    $('#icon-url-input').show();
    $('#icon-upload-input, #icon-fa-input').hide();
    $('#bg-url-input').show();
    $('#bg-upload-input').hide();
    
    // Reset customization options
    $('#customization-options-list').empty();
    $('#new-option').val('');
    
    // Reset tab
    $('#serviceTabs .nav-link:first').tab('show');
    
    // Reset color picker if available
    if (window.pickr) {
        window.pickr.setColor('#1a365d');
    }
    $('#service-color').val('#1a365d');
}

/**
 * Save service (create or update)
 */
function saveService() {
    // Validate form
    const form = $('#service-form')[0];
    if (!form.checkValidity()) {
        $('#service-form').addClass('was-validated');
        return;
    }
    
    // Get service data
    const serviceId = $('#service-id').val();
    const isUpdate = serviceId !== '';
    
    // Collect customization options
    const customizationOptions = [];
    $('#customization-options-list input[name="customizationOptions[]"]').each(function() {
        customizationOptions.push($(this).val());
    });
    
    // Prepare service data
    const serviceData = {
        serviceId: serviceId,
        serviceName: $('#service-name').val(),
        category: $('#service-category').val(),
        description: $('#service-description').val(),
        basePrice: $('#service-base-price').val(),
        active: $('input[name="active"]:checked').val() === 'true',
        displayOrder: $('#service-display-order').val() || 1,
        customizationOptions: customizationOptions,
        themeColor: $('#service-color').val(),
        featured: $('#featured-service').is(':checked'),
        popular: $('#popular-service').is(':checked'),
        new: $('#new-service').is(':checked'),
        seoKeywords: $('#service-seo-keywords').val()
    };
    
    // Handle icon based on selected option
    if ($('#icon-url-option').is(':checked')) {
        serviceData.iconPath = $('#service-icon-path').val();
    } else if ($('#icon-fa-option').is(':checked')) {
        serviceData.iconPath = $('#service-icon-fa').val();
    } else if ($('#icon-upload-option').is(':checked') && $('#service-icon-upload').get(0).files.length > 0) {
        // In a real application, you would upload the file to server first
        // For this example, we'll use a placeholder
        serviceData.iconPath = '/assets/images/services/icons/' + $('#service-icon-upload').get(0).files[0].name;
        // We'd need to implement file upload handling separately
    }
    
    // Handle background image based on selected option
    if ($('#bg-url-option').is(':checked')) {
        serviceData.backgroundImagePath = $('#service-bg-path').val();
    } else if ($('#bg-upload-option').is(':checked') && $('#service-bg-upload').get(0).files.length > 0) {
        // In a real application, you would upload the file to server first
        // For this example, we'll use a placeholder
        serviceData.backgroundImagePath = '/assets/images/services/backgrounds/' + $('#service-bg-upload').get(0).files[0].name;
        // We'd need to implement file upload handling separately
    }
    
    // Send AJAX request
    $.ajax({
        url: contextPath + '/ServiceManagementServlet',
        type: isUpdate ? 'PUT' : 'POST',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify(serviceData),
        success: function(response) {
            // Hide modal
            $('#serviceModal').modal('hide');
            
            // Show success message
            showToast('Success', isUpdate ? 'Service updated successfully' : 'Service created successfully', 'success');
            
            // Reload services

            loadServices();
			

            
            // Reload categories (in case a new category was added)
            if (!isUpdate) {
                loadCategories();
            }
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, isUpdate ? 'Failed to update service' : 'Failed to create service');
        }
    });
}

/**
 * Confirm service deletion
 * @param {String} serviceId - Service ID
 */
function confirmDeleteService(serviceId) {
    // Get service name
    $.ajax({
        url: contextPath + '/ServiceManagementServlet',
        type: 'GET',
        data: {
            serviceId: serviceId
        },
        dataType: 'json',
        success: function(service) {
            $('#delete-service-id').val(serviceId);
            $('#delete-service-name').text(service.serviceName);
            $('#deleteServiceModal').modal('show');
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to load service details');
        }
    });
}

/**
 * Delete a service
 * @param {String} serviceId - Service ID
 */
function deleteService(serviceId) {
    $.ajax({
        url: contextPath + '/ServiceManagementServlet',
        type: 'DELETE',
        data: {
            serviceId: serviceId
        },
        success: function(response) {
            $('#deleteServiceModal').modal('hide');
            showToast('Success', 'Service deleted successfully', 'success');
            loadServices();
            loadCategories();
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to delete service');
        }
    });
}

/**
 * Add a new category
 * @param {String} categoryName - Category name
 */
function addCategory(categoryName) {
    // Format category name (lowercase for consistency)
    const formattedName = categoryName.toLowerCase();
    
    // Check if category already exists
    const existingCategory = $('#manage-categories-list .category-name').filter(function() {
        return $(this).text().toLowerCase() === formatCategoryName(formattedName).toLowerCase();
    }).length > 0;
    
    if (existingCategory) {
        showToast('Warning', 'This category already exists', 'warning');
        return;
    }
    
    // Add category to list
    const categoryItem = `
        <div class="category-item animate__animated animate__fadeIn">
            <div class="category-name">${formatCategoryName(formattedName)}</div>
            <div class="category-item-actions">
                <span class="badge bg-light text-dark">0</span>
                <button type="button" class="category-delete" data-category="${formattedName}">
                    <i class="fas fa-trash-alt"></i>
                </button>
            </div>
        </div>
    `;
    
    $('#manage-categories-list').append(categoryItem);
    
    // Add delete handler for new category
    $('.category-delete').off('click').on('click', function() {
        const category = $(this).data('category');
        deleteCategory(category);
    });
}

/**
 * Delete a category from the UI (will be saved on form submission)
 * @param {String} categoryName - Category name
 */
function deleteCategory(categoryName) {
    const $categoryItem = $(`.category-delete[data-category="${categoryName}"]`).closest('.category-item');
    
    $categoryItem.addClass('animate__animated animate__fadeOut');
    setTimeout(() => {
        $categoryItem.remove();
    }, 500);
}

/**
 * Save categories
 */
function saveCategories() {
    // Collect all categories
    const categories = [];
    $('#manage-categories-list .category-name').each(function() {
        categories.push({
            name: $(this).text().toLowerCase(),
            active: true
        });
    });
    
    // Send AJAX request
    $.ajax({
        url: contextPath + '/ServiceManagementServlet/categories',
        type: 'POST',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify(categories),
        success: function(response) {
            $('#manageCategoriesModal').modal('hide');
            showToast('Success', 'Categories updated successfully', 'success');
            loadCategories();
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to update categories');
        }
    });
}

/**
 * Execute bulk action on selected services
 * @param {String} action - Action to perform (activate, deactivate, delete, export)
 */
function executeBulkAction(action) {
    const selectedIds = [];
    
    // Get selected service IDs
    $('#services-table tbody input[type="checkbox"]:checked').each(function() {
        selectedIds.push($(this).val());
    });
    
    if (selectedIds.length === 0) {
        showToast('Warning', 'No services selected', 'warning');
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
        url: contextPath + '/ServiceManagementServlet/bulk',
        type: 'POST',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify({
            action: action,
            serviceIds: selectedIds
        }),
        success: function(response) {
            showToast('Success', `Bulk action "${action}" completed successfully`, 'success');
            loadServices();
            
            // Hide bulk actions card
            $('#bulk-actions-card').slideUp(300);
            
            // Uncheck "Select All" checkbox
            $('#select-all-services').prop('checked', false);
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
    
    // Get selected service IDs
    $('#services-table tbody input[type="checkbox"]:checked').each(function() {
        selectedIds.push($(this).val());
    });
    
    $.ajax({
        url: contextPath + '/ServiceManagementServlet/bulk',
        type: 'POST',
        contentType: 'application/json',
        dataType: 'json',
        data: JSON.stringify({
            action: 'delete',
            serviceIds: selectedIds
        }),
        success: function(response) {
            $('#bulkDeleteModal').modal('hide');
            showToast('Success', 'Selected services deleted successfully', 'success');
            loadServices();
            loadCategories();
            
            // Hide bulk actions card
            $('#bulk-actions-card').slideUp(300);
            
            // Uncheck "Select All" checkbox
            $('#select-all-services').prop('checked', false);
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to delete services');
        }
    });
}

/**
 * Filter services based on search criteria
 */
function filterServices() {
    const category = $('#category-filter').val();
    const status = $('#status-filter').val();
    const priceRange = $('#price-range').val();
    const searchTerm = $('#search-services').val();
    
    // Prepare filter parameters
    let params = {};
    if (category) params.category = category;
    if (status) params.status = status;
    if (priceRange) params.priceRange = priceRange;
    if (searchTerm) params.search = searchTerm;
    
    // Convert params object to query string
    const queryString = Object.keys(params).map(key => key + '=' + encodeURIComponent(params[key])).join('&');
    
    // Make AJAX request with filters
    $.ajax({
        url: contextPath + '/ServiceManagementServlet' + (queryString ? '?' + queryString : ''),
        type: 'GET',
        dataType: 'json',
        success: function(data) {
            if (data && data.length > 0) {
                $('#no-services-message').hide();
                populateServicesGrid(data);
                populateServicesTable(data);
                populateServicesCompact(data);
                updateServiceCounts(data);
            } else {
                showNoServicesMessage();
            }
        },
        error: function(xhr, status, error) {
            handleAjaxError(xhr, 'Failed to filter services');
        }
    });
}

/**
 * Sort services
 * @param {String} sortOption - Sort option
 */
function sortServices(sortOption) {
    const [field, direction] = sortOption.split('-');
    
    // Sort services in each view
    sortGridServices(field, direction);
    sortTableServices(field, direction);
    sortCompactServices(field, direction);
}

/**
 * Sort services in grid view
 * @param {String} field - Field to sort by
 * @param {String} direction - Sort direction (asc/desc)
 */
function sortGridServices(field, direction) {
    const $grid = $('#services-grid');
    const $items = $grid.children('.col-md-6');
    
    $items.sort(function(a, b) {
        let aVal, bVal;
        
        if (field === 'name') {
            aVal = $(a).find('.service-card-title').text();
            bVal = $(b).find('.service-card-title').text();
        } else if (field === 'price') {
            aVal = parseFloat($(a).find('.service-card-price').text().replace('$', ''));
            bVal = parseFloat($(b).find('.service-card-price').text().replace('$', ''));
        } else if (field === 'display') {
            aVal = parseInt($(a).find('.service-card-order').text().replace('Display Order: ', ''));
            bVal = parseInt($(b).find('.service-card-order').text().replace('Display Order: ', ''));
        }
        
        if (direction === 'asc') {
            return aVal > bVal ? 1 : -1;
        } else {
            return aVal < bVal ? 1 : -1;
        }
    });
    
    $grid.append($items);
}

/**
 * Sort services in table view
 * @param {String} field - Field to sort by
 * @param {String} direction - Sort direction (asc/desc)
 */
function sortTableServices(field, direction) {
    const columnMap = {
        'name': 2,
        'price': 4,
        'display': 6
    };
    
    const column = columnMap[field] || 2;
    const dir = direction === 'asc' ? 'asc' : 'desc';
    
    if (window.servicesTable) {
        window.servicesTable.order([column, dir]).draw();
    }
}

/**
 * Sort services in compact view
 * @param {String} field - Field to sort by
 * @param {String} direction - Sort direction (asc/desc)
 */
function sortCompactServices(field, direction) {
    // For each category group
    $('.compact-services-list').each(function() {
        const $list = $(this);
        const $items = $list.children('.compact-service-card');
        
        $items.sort(function(a, b) {
            let aVal, bVal;
            
            if (field === 'name') {
                aVal = $(a).find('.compact-service-name').text();
                bVal = $(b).find('.compact-service-name').text();
            } else if (field === 'price') {
                aVal = parseFloat($(a).find('.compact-service-price').text().replace('$', ''));
                bVal = parseFloat($(b).find('.compact-service-price').text().replace('$', ''));
            }
            
            if (direction === 'asc') {
                return aVal > bVal ? 1 : -1;
            } else {
                return aVal < bVal ? 1 : -1;
            }
        });
        
        $list.append($items);
    });
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