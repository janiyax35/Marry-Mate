/**
 * Vendor Services JavaScript - Marry Mate
 * Current Date and Time: 2025-05-16 04:17:06
 * Current User: IT24102137
 * 
 * This file contains all client-side functionality for the vendor services page,
 * including filtering, sorting, view changing, modal interactions, and booking flows.
 * 
 * UPDATES:
 * - Added auto-population of form fields from existing booking data
 * - Implemented per-guest pricing calculations
 * - Added service compatibility checking
 * - Enhanced UI feedback for populated fields
 */

// Initialize on document ready
document.addEventListener('DOMContentLoaded', function() {
    // Set context path globally
    window.contextPath = contextPath || '';
    
    // Initialize components
    initPriceRangeSlider();
    initViewControls();
    initFilterForm();
    initSorting();
    initServiceDetailsModal();
    initBookingProcess();
    initScrollToTop();
    
    // Initialize AOS for animations
    AOS.init({
        duration: 800,
        easing: 'ease-out',
        once: true,
        offset: 50
    });
});

/**
 * Initialize noUiSlider for price range filtering
 */
function initPriceRangeSlider() {
    const priceRangeElement = document.getElementById('price-range');
    
    if (!priceRangeElement) return;
    
    // Create the price range slider
    noUiSlider.create(priceRangeElement, {
        start: [0, 20000],
        connect: true,
        step: 100,
        range: {
            'min': 0,
            'max': 20000
        },
        format: {
            to: function(value) {
                return Math.round(value);
            },
            from: function(value) {
                return Math.round(value);
            }
        }
    });
    
    // Set initial values for inputs
    const minPriceInput = document.getElementById('price-min');
    const maxPriceInput = document.getElementById('price-max');
    const hiddenPriceRangeInput = document.getElementById('price-range-hidden');
    
    // Check if elements exist
    if (!minPriceInput || !maxPriceInput || !hiddenPriceRangeInput) return;
    
    // Get initial value from hidden input
    if (hiddenPriceRangeInput.value) {
        const initialValues = hiddenPriceRangeInput.value.split('-');
        if (initialValues.length === 2) {
            minPriceInput.value = initialValues[0];
            maxPriceInput.value = initialValues[1];
            priceRangeElement.noUiSlider.set([initialValues[0], initialValues[1]]);
        }
    }
    
    // Update inputs when slider changes
    priceRangeElement.noUiSlider.on('update', function(values, handle) {
        if (handle === 0) {
            minPriceInput.value = values[0];
        } else {
            maxPriceInput.value = values[1];
        }
        
        // Update the hidden input with the range
        hiddenPriceRangeInput.value = values[0] + '-' + values[1];
    });
    
    // Update slider when inputs change
    minPriceInput.addEventListener('change', function() {
        priceRangeElement.noUiSlider.set([this.value, null]);
    });
    
    maxPriceInput.addEventListener('change', function() {
        priceRangeElement.noUiSlider.set([null, this.value]);
    });
}

/**
 * Initialize view toggling (grid/list)
 */
function initViewControls() {
    const viewButtons = document.querySelectorAll('.view-control button');
    
    viewButtons.forEach(button => {
        button.addEventListener('click', function() {
            const view = this.getAttribute('data-view');
            
            // Remove active class from all buttons
            viewButtons.forEach(btn => btn.classList.remove('active'));
            
            // Add active class to clicked button
            this.classList.add('active');
            
            // Get the services container
            const servicesGrid = document.getElementById('services-grid');
            
            // Update services container class
            if (view === 'list') {
                servicesGrid.classList.remove('row', 'g-4');
                servicesGrid.classList.add('list-view');
            } else {
                servicesGrid.classList.add('row', 'g-4');
                servicesGrid.classList.remove('list-view');
            }
            
            // Store current view
            localStorage.setItem('preferred-view', view);
        });
    });
    
    // Check if there's a stored preference
    const storedView = localStorage.getItem('preferred-view');
    if (storedView) {
        const button = document.querySelector(`.view-control button[data-view="${storedView}"]`);
        if (button) button.click();
    }
}

/**
 * Initialize filter form handling
 */
function initFilterForm() {
    const filterForm = document.getElementById('filterForm');
    const resetFilters = document.getElementById('resetFilters');
    
    if (filterForm) {
        // Ensure form doesn't have an action attribute to prevent direct submission
        if (filterForm.getAttribute('action')) {
            // Store the action URL but remove it from the form to prevent default submission
            filterForm.dataset.actionUrl = filterForm.getAttribute('action');
            filterForm.removeAttribute('action');
        }
        
        // Handle filter form submission
        filterForm.addEventListener('submit', function(e) {
            e.preventDefault(); // Stop form from submitting normally
            
            // Show loading state
            showLoading();
            
            // Serialize form data
            const formData = new FormData(this);
            const params = new URLSearchParams(formData);
            
            // Get the action URL either from the form or from the dataset
            const actionUrl = this.getAttribute('action') || this.dataset.actionUrl || `${contextPath}/FilterServicesServlet`;
            
            // Make AJAX request using fetch
            fetch(actionUrl, {
                method: 'POST',
                body: params
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update services container with new results
                    updateServicesDisplay(data.services);
                    
                    // Update results count
                    const resultsCount = document.querySelector('.results-count');
                    if (resultsCount) {
                        resultsCount.textContent = data.services.length + ' services found';
                    }
                    
                    // Hide loading
                    hideLoading();
                } else {
                    // Show error
                    showToast('Error filtering services. Please try again.', 'error');
                    hideLoading();
                }
            })
            .catch(error => {
                console.error('Error:', error);
                showToast('Error connecting to server. Please try again.', 'error');
                hideLoading();
            });
        });
        
        // Handle auto-submit for filters
        const categoryFilters = document.querySelectorAll('.category-filter');
        const ratingFilters = document.querySelectorAll('.rating-filter');
        
        // Setup change listeners for category filters
        categoryFilters.forEach(filter => {
            filter.addEventListener('change', function() {
                filterForm.dispatchEvent(new Event('submit'));
            });
        });
        
        // Setup change listeners for rating filters
        ratingFilters.forEach(filter => {
            filter.addEventListener('change', function() {
                filterForm.dispatchEvent(new Event('submit'));
            });
        });
    }
    
    if (resetFilters) {
        // Handle reset filters button
        resetFilters.addEventListener('click', function() {
            // Reset category filters
            const allCategory = document.querySelector('input[name="category"][value="all"]');
            if (allCategory) allCategory.checked = true;
            
            // Reset price range
            const priceRange = document.getElementById('price-range');
            if (priceRange && priceRange.noUiSlider) {
                priceRange.noUiSlider.set([0, 20000]);
            }
            
            // Reset rating filters
            const anyRating = document.querySelector('input[name="minRating"][value="0"]');
            if (anyRating) anyRating.checked = true;
            
            // Submit the form to apply reset filters
            if (filterForm) filterForm.dispatchEvent(new Event('submit'));
        });
    }
}

/**
 * Initialize sorting functionality
 */
function initSorting() {
    const sortSelect = document.getElementById('sort-by');
    
    if (sortSelect) {
        sortSelect.addEventListener('change', function() {
            const sortValue = this.value;
            const [sortBy, sortOrder] = sortValue.split('-');
            
            const filterForm = document.getElementById('filterForm');
            if (!filterForm) return;
            
            // Remove existing sort inputs if any
            const existingSortByInput = filterForm.querySelector('input[name="sortBy"]');
            const existingSortOrderInput = filterForm.querySelector('input[name="sortOrder"]');
            if (existingSortByInput) existingSortByInput.remove();
            if (existingSortOrderInput) existingSortOrderInput.remove();
            
            // Add hidden inputs for sort parameters
            const sortByInput = document.createElement('input');
            sortByInput.type = 'hidden';
            sortByInput.name = 'sortBy';
            sortByInput.value = sortBy;
            filterForm.appendChild(sortByInput);
            
            const sortOrderInput = document.createElement('input');
            sortOrderInput.type = 'hidden';
            sortOrderInput.name = 'sortOrder';
            sortOrderInput.value = sortOrder;
            filterForm.appendChild(sortOrderInput);
            
            // Submit the form
            filterForm.dispatchEvent(new Event('submit'));
        });
    }
}

/**
 * Update services display with new filtered/sorted results
 */
function updateServicesDisplay(services) {
    const servicesContainer = document.getElementById('services-grid');
    if (!servicesContainer) return;
    
    // Clear current services
    servicesContainer.innerHTML = '';
    
    // Check if we have any services
    if (!services || services.length === 0) {
        servicesContainer.innerHTML = `
            <div class="col-12 text-center py-5">
                <div class="no-results">
                    <i class="fas fa-search fa-3x mb-3"></i>
                    <h3>No services found</h3>
                    <p>Try adjusting your filters or searching for different terms.</p>
                </div>
            </div>
        `;
        return;
    }
    
    // Add each service
    services.forEach(service => {
        const serviceCard = createServiceCard(service);
        servicesContainer.innerHTML += serviceCard;
    });
    
    // Re-initialize click handlers for the new elements
    initServiceDetailsModal();
    initBookingProcess();
    
    // Apply current view
    const currentView = localStorage.getItem('preferred-view') || 'grid';
    if (currentView === 'list') {
        servicesContainer.classList.remove('row', 'g-4');
        servicesContainer.classList.add('list-view');
    } else {
        servicesContainer.classList.add('row', 'g-4');
        servicesContainer.classList.remove('list-view');
    }
    
    // Initialize animations for new elements
    if (typeof AOS !== 'undefined') {
        AOS.refresh();
    }
}

/**
 * Create a service card HTML string
 */
function createServiceCard(service) {
    // Extract service data
    const serviceId = service.serviceId || '';
    const name = service.name || 'Unnamed Service';
    const description = service.description || '';
    const basePrice = service.basePrice || 0;
    const category = service.category || '';
    const vendorName = service.vendorName || 'Unknown Vendor';
    const vendorRating = service.vendorRating || 0;
    
    // Get image URL
    let imageUrl = '/resources/vendor/serviceImages/default.jpg';
    if (service.images && service.images.icon) {
        imageUrl = service.images.icon;
    }
    
    // Limit description length
    let shortDescription = description;
    if (shortDescription.length > 100) {
        shortDescription = shortDescription.substring(0, 100) + '...';
    }
    
    // Generate stars for vendor rating
    let starsHtml = '';
    for (let i = 1; i <= 5; i++) {
        starsHtml += `<i class="${i <= Math.round(vendorRating) ? 'fas' : 'far'} fa-star"></i>`;
    }
    
    // Create card HTML
    return `
        <div class="col-md-6 col-lg-4 service-card-container">
            <div class="service-card">
                <div class="service-image">
                    <img src="${contextPath}${imageUrl}" alt="${name}">
                    <span class="service-category">${category}</span>
                </div>
                <div class="service-info">
                    <div class="vendor-info">
                        <span class="vendor-name">${vendorName}</span>
                        <div class="vendor-rating">
                            ${starsHtml}
                            <span>${vendorRating.toFixed(1)}</span>
                        </div>
                    </div>
                    <h3>${name}</h3>
                    <p class="service-description">${shortDescription}</p>
                    <div class="service-price">
                        <span>Starting from</span>
                        <div class="price">$${basePrice.toFixed(2)}</div>
                    </div>
                    <div class="service-actions">
                        <button class="btn btn-outline-primary view-details" data-service-id="${serviceId}">View Details</button>
                        <button class="btn btn-primary book-now" data-service-id="${serviceId}">Book Now</button>
                    </div>
                </div>
            </div>
        </div>
    `;
}

/**
 * Initialize service detail modal functionality
 */
function initServiceDetailsModal() {
    document.querySelectorAll('.view-details').forEach(button => {
        button.addEventListener('click', function() {
            const serviceId = this.getAttribute('data-service-id');
            const serviceDetailsModal = document.getElementById('serviceDetailsModal');
            const modalContent = serviceDetailsModal.querySelector('.modal-content');
            const serviceDetailsContent = document.getElementById('serviceDetailsContent');
            const loadingSpinner = serviceDetailsModal.querySelector('.loading-spinner');
            
            // Show Bootstrap modal with loading spinner
            const modal = new bootstrap.Modal(serviceDetailsModal);
            modal.show();
            
            if (serviceDetailsContent) serviceDetailsContent.classList.add('d-none');
            if (loadingSpinner) loadingSpinner.classList.remove('d-none');
            
            // Load service details via fetch
            fetch(`${contextPath}/ServiceDetailsServlet?serviceId=${serviceId}`)
                .then(response => response.json())
                .then(data => {
                    // Hide loading spinner
                    if (loadingSpinner) loadingSpinner.classList.add('d-none');
                    
                    // Store service details for future use (especially for booking form)
                    window.currentServiceDetails = data;
                    
                    // Build service details content
                    if (serviceDetailsContent) {
                        const detailsHtml = buildServiceDetailsHtml(data);
                        serviceDetailsContent.innerHTML = detailsHtml;
                        serviceDetailsContent.classList.remove('d-none');
                        
                        // Initialize any JS functionality needed in the modal
                        initServiceDetailsTabs(serviceId);
                    }
                })
                .catch(error => {
                    console.error('Error fetching service details:', error);
                    
                    // Hide loading spinner and show error
                    if (loadingSpinner) loadingSpinner.classList.add('d-none');
                    if (serviceDetailsContent) {
                        serviceDetailsContent.innerHTML = '<div class="alert alert-danger">Error loading service details. Please try again.</div>';
                        serviceDetailsContent.classList.remove('d-none');
                    }
                });
        });
    });
}

/**
 * Function to build service details HTML
 */
function buildServiceDetailsHtml(data) {
    // Get vendor name safely
    let vendorName = "Unknown Vendor";
    if (data.vendor && data.vendor.businessName) {
        vendorName = data.vendor.businessName;
    }
    
    // Calculate average rating safely
    let averageRating = 0;
    if (data.averageRating) {
        averageRating = data.averageRating;
    } else if (data.vendor && data.vendor.rating) {
        averageRating = data.vendor.rating;
    }
    
    // Get image URL safely
    let imageUrl = '/resources/vendor/serviceImages/default.jpg';
    if (data.images && data.images.icon) {
        imageUrl = data.images.icon;
    }
    
    // Get pricing info
    const pricingInfo = data.pricingInfo || {};
    const priceDescription = pricingInfo.description || '';
    
    let html = `
        <div class="service-details-container">
            <div class="service-details-header">
                <h2>${data.name || 'Unnamed Service'}</h2>
                <div class="vendor-badge">
                    By: ${vendorName}
                    <div class="rating">
                        ${generateStarRating(averageRating)}
                        <span>${averageRating.toFixed(1)}</span>
                    </div>
                </div>
            </div>
            
            <ul class="nav nav-tabs" id="serviceDetailsTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="details-tab" data-bs-toggle="tab" data-bs-target="#details" type="button">Details</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="reviews-tab" data-bs-toggle="tab" data-bs-target="#reviews" type="button">Reviews</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="vendor-tab" data-bs-toggle="tab" data-bs-target="#vendor" type="button">Vendor</button>
                </li>
            </ul>
            
            <div class="tab-content p-4" id="serviceDetailsTabsContent">
                <!-- Details Tab -->
                <div class="tab-pane fade show active" id="details" role="tabpanel">
                    <div class="row">
                        <div class="col-md-8">
                            <div class="service-image-large">
                                <img src="${contextPath}${imageUrl}" alt="${data.name || 'Service Image'}">
                            </div>
                            <div class="service-description mt-4">
                                <h4>Service Description</h4>
                                <p>${data.description || 'No description available.'}</p>
                            </div>
                        </div>
                        <div class="col-md-4">
                            <div class="service-info-card">
                                <div class="price-info">
                                    <span class="price-label">Starting from</span>
                                    <div class="price">$${(data.basePrice || 0).toFixed(2)}</div>
                                    <span class="price-model">${getPriceModelText(data.priceModel || 'fixed')}</span>
                                    ${priceDescription ? `<p class="price-description mt-2">${priceDescription}</p>` : ''}
                                </div>
                                
                                <div class="service-meta mt-3">
                                    <div class="meta-item">
                                        <i class="fas fa-tag"></i>
                                        <span>Category: ${data.category || 'General'}</span>
                                    </div>
                                    ${data.baseDuration ? `
                                    <div class="meta-item">
                                        <i class="fas fa-clock"></i>
                                        <span>Duration: ${data.baseDuration} ${data.baseDuration > 1 ? 'hours' : 'hour'}</span>
                                    </div>
                                    ` : ''}
                                </div>
                                
                                ${buildAdditionalOptionsHtml(data.additionalOptions || [])}
                                
                                <button class="btn btn-primary btn-lg w-100 mt-4 book-now-details" data-service-id="${data.serviceId || ''}">
                                    Book This Service
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Reviews Tab -->
                <div class="tab-pane fade" id="reviews" role="tabpanel">
                    ${buildReviewsHtml(data.reviews || [])}
                </div>
                
                <!-- Vendor Tab -->
                <div class="tab-pane fade" id="vendor" role="tabpanel">
                    ${buildVendorInfoHtml(data.vendor || {})}
                </div>
            </div>
        </div>
    `;
    return html;
}

/**
 * Generate star rating HTML
 */
function generateStarRating(rating) {
    let stars = '';
    for (let i = 1; i <= 5; i++) {
        if (i <= Math.floor(rating)) {
            stars += '<i class="fas fa-star"></i>';
        } else if (i - 0.5 <= rating) {
            stars += '<i class="fas fa-star-half-alt"></i>';
        } else {
            stars += '<i class="far fa-star"></i>';
        }
    }
    return stars;
}

/**
 * Get price model text
 */
function getPriceModelText(priceModel) {
    switch (priceModel) {
        case 'hourly': return 'per hour';
        case 'per_guest': return 'per guest';
        case 'package': return 'package price';
        case 'fixed': return 'fixed price';
        default: return '';
    }
}

/**
 * Build additional options HTML
 */
function buildAdditionalOptionsHtml(options) {
    if (!options || options.length === 0) {
        return '<div class="additional-options mt-4"><h5>Additional Options</h5><p>No additional options available.</p></div>';
    }
    
    let html = `
        <div class="additional-options mt-4">
            <h5>Additional Options</h5>
            <ul class="options-list">
    `;
    
    options.forEach(option => {
        html += `
            <li>
                <div class="option-name">${option.name || 'Option'}</div>
                <div class="option-price">$${(option.price || 0).toFixed(2)}</div>
            </li>
        `;
    });
    
    html += `
            </ul>
        </div>
    `;
    
    return html;
}

/**
 * Build reviews HTML
 */
function buildReviewsHtml(reviews) {
    if (!reviews || reviews.length === 0) {
        return '<div class="no-reviews text-center py-4"><i class="far fa-comment-alt fa-3x mb-3"></i><h4>No Reviews Yet</h4><p>Be the first to review this service after your booking.</p></div>';
    }
    
    // Calculate average rating
    const averageRating = calculateAverageRating(reviews);
    const reviewText = reviews.length === 1 ? 'review' : 'reviews';
    
    let html = `
        <div class="reviews-summary mb-4">
            <div class="average-rating">
                <div class="rating-number">${averageRating.toFixed(1)}</div>
                <div class="stars">
                    ${generateStarRating(averageRating)}
                </div>
                <div class="review-count">${reviews.length} ${reviewText}</div>
            </div>
        </div>
        
        <div class="reviews-list">
    `;
    
    reviews.forEach(review => {
        // Build photos HTML
        const photosHtml = buildReviewPhotosHtml(review.photoUrls || []);
        
        // Build vendor response HTML
        const responseHtml = buildVendorResponseHtml(review.vendorResponse || null);
        
        html += `
            <div class="review-item">
                <div class="review-header">
                    <div class="reviewer-info">
                        <img src="${contextPath}${review.userPhotoUrl || '/assets/images/default-avatar.jpg'}" alt="${review.userName || 'Anonymous'}">
                        <div>
                            <h5>${review.userName || 'Anonymous'}</h5>
                            <div class="review-date">${review.reviewDate || ''}</div>
                        </div>
                    </div>
                    <div class="review-rating">
                        ${generateStarRating(review.rating || 0)}
                        <span>${(review.rating || 0).toFixed(1)}</span>
                    </div>
                </div>
                
                <div class="review-content">
                    <p>${review.comment || 'No comment provided.'}</p>
                    
                    ${photosHtml}
                    ${responseHtml}
                    
                    <div class="review-footer">
                        <div class="helpful-count">
                            <i class="far fa-thumbs-up"></i>
                            <span>${review.helpfulCount || 0} found helpful</span>
                        </div>
                    </div>
                </div>
            </div>
        `;
    });
    
    html += '</div>';
    return html;
}

/**
 * Calculate average rating from reviews
 */
function calculateAverageRating(reviews) {
    if (!reviews || reviews.length === 0) {
        return 0;
    }
    
    const sum = reviews.reduce((total, review) => total + (review.rating || 0), 0);
    return sum / reviews.length;
}

/**
 * Build review photos HTML
 */
function buildReviewPhotosHtml(photoUrls) {
    if (!photoUrls || photoUrls.length === 0) return '';
    
    let html = '<div class="review-photos">';
    photoUrls.forEach(url => {
        html += `<img src="${contextPath}${url}" alt="Review photo">`;
    });
    html += '</div>';
    
    return html;
}

/**
 * Build vendor response HTML
 */
function buildVendorResponseHtml(response) {
    if (!response) return '';
    
    return `
        <div class="vendor-response">
            <h6><i class="fas fa-reply"></i> Vendor Response</h6>
            <p>${response.text || ''}</p>
            <div class="response-date">${response.responseDate || ''}</div>
        </div>
    `;
}

/**
 * Build vendor info HTML
 */
function buildVendorInfoHtml(vendor) {
    if (!vendor || Object.keys(vendor).length === 0) {
        return '<div class="no-vendor-info text-center py-4"><i class="fas fa-store fa-3x mb-3"></i><h4>Vendor Information Unavailable</h4><p>Details about this service provider could not be loaded.</p></div>';
    }
    
    return `
        <div class="vendor-profile">
            <div class="vendor-profile-header">
                <div class="vendor-avatar">
                    <img src="${contextPath}${vendor.profilePictureUrl || '/assets/images/vendors/default-vendor.jpg'}" alt="${vendor.businessName || 'Vendor'}">
                </div>
                <div class="vendor-info">
                    <h3>${vendor.businessName || 'Unknown Vendor'}</h3>
                    <div class="vendor-meta">
                        <div class="vendor-rating">
                            ${generateStarRating(vendor.rating || 0)}
                            <span>${(vendor.rating || 0).toFixed(1)}</span>
                            <span class="review-count">(${vendor.reviewCount || 0} reviews)</span>
                        </div>
                        <div class="vendor-contact">
                            ${vendor.contactName ? `<div><i class="fas fa-user"></i> ${vendor.contactName}</div>` : ''}
                            ${vendor.phone ? `<div><i class="fas fa-phone"></i> ${vendor.phone}</div>` : ''}
                            ${vendor.email ? `<div><i class="fas fa-envelope"></i> ${vendor.email}</div>` : ''}
                            ${vendor.websiteUrl ? `<div><i class="fas fa-globe"></i> <a href="${vendor.websiteUrl}" target="_blank">Visit Website</a></div>` : ''}
                            ${vendor.userId ? `
                            <div class="mt-2">
                                <a href="${contextPath}/VendorProfileServlet?id=${vendor.userId}" class="btn btn-outline-primary btn-sm">
                                    <i class="fas fa-store me-1"></i> View Full Profile
                                </a>
                            </div>
                            ` : ''}
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="vendor-description mt-4">
                <h4>About the Vendor</h4>
                <p>${vendor.description || 'No description available.'}</p>
            </div>
        </div>
    `;
}

/**
 * Initialize event handlers for service details tabs
 */
function initServiceDetailsTabs(serviceId) {
    // Add click handler for "Book This Service" button in details tab
    document.querySelectorAll('.book-now-details').forEach(button => {
        button.addEventListener('click', function() {
            const serviceDetailsModal = document.getElementById('serviceDetailsModal');
            if (serviceDetailsModal) {
                bootstrap.Modal.getInstance(serviceDetailsModal).hide();
            }
            
            // Trigger the same booking flow as the main "Book Now" button
            setTimeout(() => {
                const bookNowBtn = document.querySelector(`.book-now[data-service-id="${serviceId}"]`);
                if (bookNowBtn) {
                    bookNowBtn.click();
                } else {
                    window.location.href = `${contextPath}/BookServiceServlet?serviceId=${serviceId}`;
                }
            }, 300);
        });
    });
    
    // Initialize lightbox for review photos
    document.querySelectorAll('.review-photos img').forEach(img => {
        img.addEventListener('click', function() {
            const imageUrl = this.getAttribute('src');
            
            // Create lightbox modal
            const modalHtml = `
                <div class="modal fade" id="lightboxModal" tabindex="-1" aria-hidden="true">
                    <div class="modal-dialog modal-lg modal-dialog-centered">
                        <div class="modal-content">
                            <div class="modal-body p-0">
                                <img src="${imageUrl}" class="img-fluid" alt="Review Photo">
                                <button type="button" class="btn-close position-absolute top-0 end-0 bg-white m-2" data-bs-dismiss="modal" aria-label="Close"></button>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            // Append to body
            document.body.insertAdjacentHTML('beforeend', modalHtml);
            
            // Show modal
            const lightboxModal = new bootstrap.Modal(document.getElementById('lightboxModal'));
            lightboxModal.show();
            
            // Remove modal from DOM when hidden
            document.getElementById('lightboxModal').addEventListener('hidden.bs.modal', function() {
                this.remove();
            });
        });
    });
}

/**
 * Initialize booking process functionality
 */
function initBookingProcess() {
    document.querySelectorAll('.book-now').forEach(button => {
        button.addEventListener('click', function() {
            // Get serviceId from the button's data attribute
            const serviceId = this.getAttribute('data-service-id');
            
            // Ensure serviceId is valid
            if (!serviceId) {
                showToast('Error: Service ID not found', 'error');
                return;
            }
            
            console.log('Booking service with ID:', serviceId); // Debug log
            
            // Check if user is logged in
            if (!isLoggedIn) {
                window.location.href = `${contextPath}/login.jsp?redirect=VendorServicesServlet`;
                return;
            }
            
            // Show loading
            showLoading();
            
            // First, get the service details if not already cached
            if (!window.currentServiceDetails || window.currentServiceDetails.serviceId !== serviceId) {
                fetch(`${contextPath}/ServiceDetailsServlet?serviceId=${serviceId}`)
                    .then(response => response.json())
                    .then(serviceData => {
                        // Store the service details globally
                        window.currentServiceDetails = serviceData;
                        // Continue with booking flow
                        checkForExistingBookings(serviceId);
                    })
                    .catch(error => {
                        console.error('Error fetching service details:', error);
                        hideLoading();
                        showToast('Error loading service details. Please try again.', 'error');
                    });
            } else {
                // If we already have the service details, continue with booking flow
                checkForExistingBookings(serviceId);
            }
        });
    });
}

/**
 * Check for existing bookings
 */
function checkForExistingBookings(serviceId) {
    // Create form data for the request
    const formData = new URLSearchParams();
    formData.append('serviceId', serviceId);
    
    // Send request to check existing bookings
    fetch(`${contextPath}/BookServiceServlet`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString()
    })
    .then(response => response.json())
    .then(data => {
        // Hide loading
        hideLoading();
        
        if (data.success) {
            if (data.hasExistingBookings) {
                // Store existing bookings data for later use
                window.existingBookings = data.existingBookings;
                
                // Show booking options modal
                showBookingOptionsModal(data.existingBookings, serviceId);
            } else {
                // Process as new booking - first show the booking form
                showBookingForm(serviceId, 'create_new');
            }
        } else {
            if (data.redirect) {
                window.location.href = `${contextPath}/${data.redirect}`;
            } else {
                showToast(data.message || 'An error occurred. Please try again.', 'error');
            }
        }
    })
    .catch(error => {
        console.error('Error:', error);
        hideLoading();
        showToast('Error checking booking status. Please try again.', 'error');
    });
}

/**
 * Show booking options modal
 */
function showBookingOptionsModal(existingBookings, serviceId) {
    const bookingOptionsModal = document.getElementById('bookingOptionsModal');
    const existingBookingsList = document.getElementById('existingBookingsList');
    
    if (!bookingOptionsModal || !existingBookingsList) return;
    
    // Build existing bookings list
    let bookingsHtml = '<div class="list-group">';
    
    // Check for booking compatibility
    const serviceDetails = window.currentServiceDetails || {};
    const serviceCategory = serviceDetails.category || '';
    
    existingBookings.forEach(booking => {
        // Check if this service is compatible with this booking
        let isCompatible = true;
        let incompatibilityReason = '';
        
        if (serviceDetails.bookingCompatibility) {
            const compatibility = serviceDetails.bookingCompatibility.find(c => 
                c.bookingId === booking.bookingId);
            
            if (compatibility && compatibility.compatible === false) {
                isCompatible = false;
                incompatibilityReason = compatibility.reason || 'This service is not compatible with this booking';
            }
        }
        
        // Build the booking item with compatibility indicators
        const compatibilityClass = isCompatible ? '' : 'incompatible-booking';
        
        bookingsHtml += `
            <label class="list-group-item ${compatibilityClass}">
                <input class="form-check-input me-2" type="radio" name="bookingId" value="${booking.bookingId || ''}" 
                       ${!isCompatible ? 'disabled' : ''}>
                <div class="booking-info">
                    <div><strong>Booking #${booking.bookingId || ''}</strong></div>
                    <div>Wedding Date: ${booking.weddingDate || 'Not set'}</div>
                    <div>Location: ${booking.eventLocation || 'Not set'}</div>
                    <div>Services: ${booking.serviceCount || 0}</div>
                    <div>Total: $${(booking.totalBookingPrice || 0).toFixed(2)}</div>
                    ${!isCompatible ? `<div class="text-danger">${incompatibilityReason}</div>` : ''}
                </div>
            </label>
        `;
    });
    
    bookingsHtml += '</div>';
    
    // Set HTML and show modal
    existingBookingsList.innerHTML = bookingsHtml;
    
    // Clear any existing event listeners
    const addToExistingBtn = document.getElementById('addToExistingBtn');
    const createNewBookingBtn = document.getElementById('createNewBookingBtn');
    
    if (addToExistingBtn) {
        const newAddToExistingBtn = addToExistingBtn.cloneNode(true);
        addToExistingBtn.parentNode.replaceChild(newAddToExistingBtn, addToExistingBtn);
        
        // Add event listener to the new button
        newAddToExistingBtn.addEventListener('click', function() {
            const selectedBookingId = document.querySelector('input[name="bookingId"]:checked')?.value;
            if (!selectedBookingId) {
                alert('Please select a booking to add this service to.');
                return;
            }
            
            // Hide the modal
            bootstrap.Modal.getInstance(bookingOptionsModal).hide();
            
            // Get the selected booking details
            const selectedBooking = window.existingBookings.find(b => b.bookingId === selectedBookingId);
            
            // Show booking form for adding to existing booking
            showBookingForm(serviceId, 'add_to_existing', selectedBookingId, selectedBooking);
        });
    }
    
    if (createNewBookingBtn) {
        const newCreateNewBookingBtn = createNewBookingBtn.cloneNode(true);
        createNewBookingBtn.parentNode.replaceChild(newCreateNewBookingBtn, createNewBookingBtn);
        
        // Add event listener to the new button
        newCreateNewBookingBtn.addEventListener('click', function() {
            // Hide the modal
            bootstrap.Modal.getInstance(bookingOptionsModal).hide();
            
            // Show booking form for new booking
            showBookingForm(serviceId, 'create_new');
        });
    }
    
    // Add CSS for incompatible bookings if not already added
    if (!document.getElementById('incompatible-booking-css')) {
        const style = document.createElement('style');
        style.id = 'incompatible-booking-css';
        style.textContent = `
            .incompatible-booking {
                background-color: #fff4f4;
                opacity: 0.75;
            }
            .incompatible-booking:hover {
                background-color: #fff4f4;
                cursor: not-allowed;
            }
            .populated-field {
                background-color: #f8f9ff;
                border-color: #d0d6f9;
            }
            .populated-field-label {
                color: #4361ee;
            }
            .populated-field-badge {
                position: absolute;
                right: 10px;
                top: 10px;
                font-size: 0.7rem;
                padding: 0.2rem 0.5rem;
                background: #e7eaff;
                color: #4361ee;
                border-radius: 3px;
                z-index: 1;
            }
        `;
        document.head.appendChild(style);
    }
    
    // Show the modal
    const modal = new bootstrap.Modal(bookingOptionsModal);
    modal.show();
}

/**
 * Show service-specific booking form
 */
function showBookingForm(serviceId, bookingAction, existingBookingId = null, existingBooking = null) {
    // Get the service details
    const serviceDetails = window.currentServiceDetails || {};
    
    // Create the modal for the booking form
    const modalId = 'bookingFormModal';
    
    // Remove existing modal if any
    const existingModal = document.getElementById(modalId);
    if (existingModal) {
        existingModal.remove();
    }
    
    // Calculate today's date and one year from now for date picker min/max
    const today = new Date();
    const oneYearFromNow = new Date();
    oneYearFromNow.setFullYear(today.getFullYear() + 1);
    
    const todayFormatted = today.toISOString().split('T')[0];
    const oneYearFromNowFormatted = oneYearFromNow.toISOString().split('T')[0];
    
    // Create the booking form HTML
    let formHtml = `
        <div class="modal fade" id="${modalId}" tabindex="-1" aria-labelledby="${modalId}Label" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="${modalId}Label">Book ${serviceDetails.name || 'Service'}</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="serviceBookingForm" class="needs-validation" novalidate>
                            <!-- Hidden fields -->
                            <input type="hidden" name="serviceId" value="${serviceId}">
                            <input type="hidden" name="bookingAction" value="${bookingAction}">
                            ${existingBookingId ? `<input type="hidden" name="existingBookingId" value="${existingBookingId}">` : ''}
                            
                            <!-- Wedding Details Section -->
                            <div class="form-section">
                                <h4 class="form-section-title">Wedding Details</h4>
    `;
    
    // Check if we have existing booking details to pre-populate
    const weddingDate = existingBooking?.weddingDate || '';
    const eventLocation = existingBooking?.eventLocation || '';
    const eventStartTime = existingBooking?.eventStartTime || '';
    const eventEndTime = existingBooking?.eventEndTime || '';
    const guestCount = existingBooking?.totalGuestCount || 50;
    
    // Wedding date field
    const weddingDateFieldClass = existingBooking ? 'populated-field' : '';
    const weddingDateLabelClass = existingBooking ? 'populated-field-label' : '';
    const weddingDateBadge = existingBooking ? `<span class="populated-field-badge">From existing booking</span>` : '';
    
    formHtml += `
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group mb-3 position-relative">
                                            <label for="weddingDate" class="form-label ${weddingDateLabelClass}">Wedding Date*</label>
                                            ${weddingDateBadge}
                                            <input type="date" class="form-control ${weddingDateFieldClass}" id="weddingDate" name="weddingDate" 
                                                   min="${todayFormatted}" max="${oneYearFromNowFormatted}" value="${weddingDate}" required
                                                   ${existingBooking ? 'readonly' : ''}>
                                            <div class="invalid-feedback">
                                                Please select your wedding date.
                                            </div>
                                        </div>
                                    </div>
    `;
    
    // Event location field
    const locationFieldClass = existingBooking?.eventLocation ? 'populated-field' : '';
    const locationLabelClass = existingBooking?.eventLocation ? 'populated-field-label' : '';
    const locationBadge = existingBooking?.eventLocation ? `<span class="populated-field-badge">From existing booking</span>` : '';
    
    formHtml += `
                                    <div class="col-md-6">
                                        <div class="form-group mb-3 position-relative">
                                            <label for="eventLocation" class="form-label ${locationLabelClass}">Event Location*</label>
                                            ${locationBadge}
                                            <input type="text" class="form-control ${locationFieldClass}" id="eventLocation" name="eventLocation" 
                                                   placeholder="Enter your venue or event location" value="${eventLocation}" required
                                                   ${existingBooking?.eventLocation ? 'readonly' : ''}>
                                            <div class="invalid-feedback">
                                                Please provide an event location.
                                            </div>
                                        </div>
                                    </div>
                                </div>
    `;
    
    // Time fields
    const timeFieldsClass = existingBooking?.eventStartTime ? 'populated-field' : '';
    const timeLabelClass = existingBooking?.eventStartTime ? 'populated-field-label' : '';
    const timeBadge = existingBooking?.eventStartTime ? `<span class="populated-field-badge">From existing booking</span>` : '';
    
    formHtml += `
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group mb-3 position-relative">
                                            <label class="form-label ${timeLabelClass}">Event Time*</label>
                                            ${timeBadge}
                                            <div class="input-group">
                                                <input type="time" class="form-control ${timeFieldsClass}" id="eventStartTime" name="eventStartTime" 
                                                       value="${eventStartTime}" required
                                                       ${existingBooking?.eventStartTime ? 'readonly' : ''}>
                                                <span class="input-group-text">to</span>
                                                <input type="time" class="form-control ${timeFieldsClass}" id="eventEndTime" name="eventEndTime" 
                                                       value="${eventEndTime}" required
                                                       ${existingBooking?.eventEndTime ? 'readonly' : ''}>
                                            </div>
                                            <div class="invalid-feedback">
                                                Please provide event start and end times.
                                            </div>
                                        </div>
                                    </div>
    `;
    
    // Guest count field
    const guestCountFieldClass = existingBooking ? 'populated-field' : '';
    const guestCountLabelClass = existingBooking ? 'populated-field-label' : '';
    const guestCountBadge = existingBooking ? `<span class="populated-field-badge">From existing booking</span>` : '';
    
    formHtml += `
                                    <div class="col-md-6">
                                        <div class="form-group mb-3 position-relative">
                                            <label for="guestCount" class="form-label ${guestCountLabelClass}">Guest Count*</label>
                                            ${guestCountBadge}
                                            <input type="number" class="form-control ${guestCountFieldClass}" id="guestCount" name="guestCount" 
                                                   min="1" value="${guestCount}" required
                                                   ${existingBooking ? 'readonly' : ''}>
                                            <div class="invalid-feedback">
                                                Please enter the number of guests.
                                            </div>
                                        </div>
                                    </div>
                                </div>
    `;
    
    // Add service-specific fields based on the category and price model
    const category = serviceDetails.category || '';
    const priceModel = serviceDetails.priceModel || 'fixed';
    
    if (priceModel === 'hourly') {
        const baseDuration = serviceDetails.baseDuration || 2;
        formHtml += `
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group mb-3">
                        <label for="hours" class="form-label">Service Hours*</label>
                        <input type="number" class="form-control" id="hours" name="hours" 
                                min="${baseDuration}" value="${baseDuration}" required>
                        <small class="text-muted">Base package includes ${baseDuration} hours. Additional hours at $${serviceDetails.hourlyRate || 0}/hour.</small>
                        <div class="invalid-feedback">
                            Please specify service hours.
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
    
    // Add special requirements field
    formHtml += `
                                <div class="form-group mb-3">
                                    <label for="specialRequirements" class="form-label">Special Requirements</label>
                                    <textarea class="form-control" id="specialRequirements" name="specialRequirements" 
                                              rows="3" placeholder="Any special requests or requirements for the vendor?"></textarea>
                                </div>
                            </div>
    `;
    
    // Add additional options section if available
    const additionalOptions = serviceDetails.additionalOptions || [];
    if (additionalOptions.length > 0) {
        formHtml += `
            <!-- Additional Options Section -->
            <div class="form-section mt-4">
                <h4 class="form-section-title">Additional Options</h4>
                <div class="options-list">
        `;
        
        additionalOptions.forEach(option => {
            formHtml += `
                <div class="form-check mb-2">
                    <input class="form-check-input" type="checkbox" name="selectedOptions" 
                           value="${option.optionId}" id="option-${option.optionId}" data-price="${option.price || 0}">
                    <label class="form-check-label" for="option-${option.optionId}">
                        <div class="d-flex justify-content-between align-items-center">
                            <span>${option.name || 'Option'}</span>
                            <span>$${(option.price || 0).toFixed(2)}</span>
                        </div>
                        <small class="text-muted d-block">${option.description || ''}</small>
                    </label>
                </div>
            `;
        });
        
        formHtml += `
                </div>
            </div>
        `;
    }
    
    // Add booking summary section with detailed price breakdown
    formHtml += `
                            <!-- Booking Summary -->
                            <div class="form-section mt-4">
                                <h4 class="form-section-title">Booking Summary</h4>
                                
                                <div class="card bg-light">
                                    <div class="card-body">
                                        <div class="d-flex justify-content-between mb-2">
                                            <div>Base Price</div>
                                            <div>$${(serviceDetails.basePrice || 0).toFixed(2)}</div>
                                        </div>
                                        
                                        <div id="additionalCosts">
                                            <!-- Additional costs will be added here dynamically -->
                                        </div>
                                        
                                        <hr>
                                        
                                        <div class="d-flex justify-content-between fw-bold">
                                            <div>Total</div>
                                            <div id="totalPrice">$${(serviceDetails.basePrice || 0).toFixed(2)}</div>
                                        </div>
                                        
                                        <input type="hidden" name="totalPrice" id="totalPriceInput" value="${serviceDetails.basePrice || 0}">
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" id="submitBookingButton">Complete Booking</button>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // Add the modal to the document
    document.body.insertAdjacentHTML('beforeend', formHtml);
    
    // Initialize the modal
    const bookingFormModal = new bootstrap.Modal(document.getElementById(modalId));
    bookingFormModal.show();
    
    // Initialize form functionality
    initBookingFormFunctionality(serviceId, bookingAction, existingBookingId);
}

/**
 * Initialize booking form functionality
 */
function initBookingFormFunctionality(serviceId, bookingAction, existingBookingId) {
    const form = document.getElementById('serviceBookingForm');
    const submitButton = document.getElementById('submitBookingButton');
    
    if (!form || !submitButton) return;
    
    const serviceDetails = window.currentServiceDetails || {};
    const basePrice = serviceDetails.basePrice || 0;
    const priceModel = serviceDetails.priceModel || 'fixed';
    const hourlyRate = serviceDetails.hourlyRate || 0;
    const baseDuration = serviceDetails.baseDuration || 0;
    const perGuestRate = serviceDetails.perGuestRate || 0;
    const baseGuestCount = serviceDetails.baseGuestCount || 0;
    
    // Function to update price calculations
    function updatePriceCalculation() {
        let totalPrice = basePrice;
        let additionalCostsHtml = '';
        
        // Calculate additional hours cost if applicable
        if (priceModel === 'hourly') {
            const hoursInput = document.getElementById('hours');
            if (hoursInput) {
                const hours = parseInt(hoursInput.value) || 0;
                if (hours > baseDuration) {
                    const additionalHours = hours - baseDuration;
                    const additionalHoursCost = additionalHours * hourlyRate;
                    totalPrice += additionalHoursCost;
                    
                    additionalCostsHtml += `
                        <div class="d-flex justify-content-between mb-2">
                            <div>Additional Hours (${additionalHours})</div>
                            <div>$${additionalHoursCost.toFixed(2)}</div>
                        </div>
                    `;
                }
            }
        }
        
        // Calculate additional guests cost if applicable
        if (priceModel === 'per_guest') {
            const guestCountInput = document.getElementById('guestCount');
            if (guestCountInput) {
                const guestCount = parseInt(guestCountInput.value) || 0;
                if (guestCount > baseGuestCount) {
                    const additionalGuests = guestCount - baseGuestCount;
                    const additionalGuestsCost = additionalGuests * perGuestRate;
                    totalPrice += additionalGuestsCost;
                    
                    additionalCostsHtml += `
                        <div class="d-flex justify-content-between mb-2">
                            <div>Base Guest Count (${baseGuestCount})</div>
                            <div>Included</div>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <div>Additional Guests (${additionalGuests} × $${perGuestRate.toFixed(2)})</div>
                            <div>$${additionalGuestsCost.toFixed(2)}</div>
                        </div>
                    `;
                } else {
                    additionalCostsHtml += `
                        <div class="d-flex justify-content-between mb-2">
                            <div>Guest Count (${guestCount})</div>
                            <div>Included in base price</div>
                        </div>
                    `;
                }
            }
        }
        
        // Calculate additional options cost
        let optionsCost = 0;
        let selectedOptionsHtml = '';
        
        document.querySelectorAll('input[name="selectedOptions"]:checked').forEach(checkbox => {
            const optionPrice = parseFloat(checkbox.getAttribute('data-price')) || 0;
            const optionName = checkbox.nextElementSibling.querySelector('div > span:first-child').textContent;
            optionsCost += optionPrice;
            
            selectedOptionsHtml += `
                <div class="d-flex justify-content-between mb-1 ps-3">
                    <div>- ${optionName}</div>
                    <div>$${optionPrice.toFixed(2)}</div>
                </div>
            `;
        });
        
        if (optionsCost > 0) {
            totalPrice += optionsCost;
            additionalCostsHtml += `
                <div class="d-flex justify-content-between mb-1">
                    <div>Additional Options:</div>
                    <div>$${optionsCost.toFixed(2)}</div>
                </div>
                ${selectedOptionsHtml}
            `;
        }
        
        // Update the display
        document.getElementById('additionalCosts').innerHTML = additionalCostsHtml;
        document.getElementById('totalPrice').textContent = '$' + totalPrice.toFixed(2);
        document.getElementById('totalPriceInput').value = totalPrice;
    }
    
    // Add event listeners for price changes
    if (priceModel === 'hourly') {
        const hoursInput = document.getElementById('hours');
        if (hoursInput) {
            hoursInput.addEventListener('input', updatePriceCalculation);
        }
    }
    
    if (priceModel === 'per_guest') {
        const guestCountInput = document.getElementById('guestCount');
        if (guestCountInput) {
            guestCountInput.addEventListener('input', updatePriceCalculation);
        }
    }
    
    document.querySelectorAll('input[name="selectedOptions"]').forEach(checkbox => {
        checkbox.addEventListener('change', updatePriceCalculation);
    });
    
    // Calculate end time based on start time and hours (for hourly services)
    if (priceModel === 'hourly') {
        const eventStartTime = document.getElementById('eventStartTime');
        const eventEndTime = document.getElementById('eventEndTime');
        const hoursInput = document.getElementById('hours');
        
        if (eventStartTime && eventEndTime && hoursInput) {
            // Only setup auto-calculation if not pre-populated
            if (!eventStartTime.readOnly) {
                eventStartTime.addEventListener('change', calculateEndTime);
                hoursInput.addEventListener('change', calculateEndTime);
            
                function calculateEndTime() {
                    const startTime = eventStartTime.value;
                    const hours = parseInt(hoursInput.value) || 0;
                    
                    if (startTime && hours > 0) {
                        const [startHours, startMinutes] = startTime.split(':').map(Number);
                        
                        // Calculate total minutes
                        let totalMinutes = startHours * 60 + startMinutes + hours * 60;
                        
                        // Extract hours and minutes
                        let endHours = Math.floor(totalMinutes / 60) % 24;
                        let endMinutes = totalMinutes % 60;
                        
                        eventEndTime.value = 
                            `${endHours.toString().padStart(2, '0')}:${endMinutes.toString().padStart(2, '0')}`;
                    }
                }
            }
        }
    }
    
    // Run price calculation on load
    updatePriceCalculation();
    
    // Submit button handler
    submitButton.addEventListener('click', function() {
        // Form validation
        if (!form.checkValidity()) {
            // Create and trigger a submit event to show validation messages
            const submitEvent = new Event('submit', {
                bubbles: true,
                cancelable: true
            });
            form.dispatchEvent(submitEvent);
            
            // Add was-validated class to show validation feedback
            form.classList.add('was-validated');
            return;
        }
        
        // Show loading state
        showLoading();
        
        // Get form data
        const formData = new FormData(form);
        const bookingData = {};
        
        // Convert FormData to a structured object
        for (const [key, value] of formData.entries()) {
            // Handle selectedOptions array
            if (key === 'selectedOptions') {
                if (!bookingData.selectedOptions) {
                    bookingData.selectedOptions = [];
                }
                
                // Add the selected option
                const optionId = value;
                
                // Find the corresponding option data from service details
                const option = (serviceDetails.additionalOptions || []).find(opt => opt.optionId === optionId);
                
                if (option) {
                    bookingData.selectedOptions.push({
                        optionId: option.optionId,
                        name: option.name,
                        price: option.price || 0
                    });
                }
            } else {
                // Regular form fields
                bookingData[key] = value;
            }
        }
        
        // Add additional service-specific data
        if (priceModel === 'hourly') {
            const hours = parseInt(formData.get('hours')) || 0;
            const baseHours = baseDuration || 0;
            const additionalHours = Math.max(0, hours - baseHours);
            const additionalHoursPrice = additionalHours * hourlyRate;
            
            bookingData.hours = hours;
            bookingData.baseHours = baseHours;
            bookingData.additionalHours = additionalHours;
            bookingData.additionalHoursPrice = additionalHoursPrice;
            bookingData.totalHours = hours;
        }
        
		        // Add per-guest pricing data
		        if (priceModel === 'per_guest') {
		            const guestCount = parseInt(formData.get('guestCount')) || 0;
		            const baseGuests = baseGuestCount || 0;
		            const additionalGuests = Math.max(0, guestCount - baseGuests);
		            const additionalGuestPrice = additionalGuests * perGuestRate;
		            
		            bookingData.guestCount = guestCount;
		            bookingData.baseGuestCount = baseGuests;
		            bookingData.additionalGuests = additionalGuests;
		            bookingData.additionalGuestPrice = additionalGuestPrice;
		        } else {
		            // Always include guest count for non-per-guest services
		            bookingData.guestCount = parseInt(formData.get('guestCount')) || 0;
		            bookingData.totalGuestCount = bookingData.guestCount;
		        }
		        
		        // Special notes
		        bookingData.specialNotes = formData.get('specialRequirements') || '';
		        
		        // Debug - log the data being sent
		        console.log('Booking data:', bookingData);
		        
		        // Convert to URLSearchParams for sending
		        const params = new URLSearchParams();
		        
		        // Add simple fields
		        for (const [key, value] of Object.entries(bookingData)) {
		            // Skip arrays and objects, we'll handle them specially
		            if (typeof value !== 'object') {
		                params.append(key, value);
		            }
		        }
		        
		        // Handle special arrays
		        if (bookingData.selectedOptions && bookingData.selectedOptions.length > 0) {
		            // Serialize the options array as JSON
		            params.append('selectedOptionsJson', JSON.stringify(bookingData.selectedOptions));
		        }
		        
		        // Send booking request
		        fetch(`${contextPath}/BookServiceServlet`, {
		            method: 'POST',
		            headers: {
		                'Content-Type': 'application/x-www-form-urlencoded',
		            },
		            body: params.toString()
		        })
		        .then(response => response.json())
		        .then(data => {
		            // Hide loading
		            hideLoading();
		            
		            // Close the modal
		            const bookingFormModal = document.getElementById('bookingFormModal');
		            if (bookingFormModal) {
		                bootstrap.Modal.getInstance(bookingFormModal).hide();
		            }
		            
		            if (data.success) {
		                // Show success toast
		                showToast(data.message || 'Booking successful!', 'success');
		                
		                // Redirect to booking details page after delay
		                setTimeout(() => {
		                    window.location.href = `${contextPath}/user/booking-details.jsp?id=${data.bookingId}`;
		                }, 1500);
		            } else {
		                showToast(data.message || 'An error occurred during booking.', 'error');
		            }
		        })
		        .catch(error => {
		            console.error('Error:', error);
		            hideLoading();
		            showToast('Error processing your booking. Please try again.', 'error');
		        });
		    });
		}

		/**
		 * Initialize back to top button
		 */
		function initScrollToTop() {
		    const backToTopButton = document.getElementById('back-to-top');
		    
		    if (backToTopButton) {
		        // Show/hide button based on scroll position
		        window.addEventListener('scroll', function() {
		            if (window.pageYOffset > 300) {
		                backToTopButton.classList.add('show');
		            } else {
		                backToTopButton.classList.remove('show');
		            }
		        });
		        
		        // Scroll to top when button clicked
		        backToTopButton.addEventListener('click', function() {
		            window.scrollTo({
		                top: 0,
		                behavior: 'smooth'
		            });
		        });
		    }
		}

		/**
		 * Get full booking details
		 */
		function getBookingDetails(bookingId) {
		    return fetch(`${contextPath}/BookServiceServlet?action=getBookingDetails&bookingId=${bookingId}`)
		        .then(response => response.json())
		        .then(data => {
		            if (data.success && data.bookingDetails) {
		                return data.bookingDetails;
		            } else {
		                throw new Error(data.message || 'Failed to load booking details');
		            }
		        });
		}

		/**
		 * Show loading overlay
		 */
		function showLoading() {
		    // Create loading overlay if it doesn't exist
		    let loadingOverlay = document.getElementById('loading-overlay');
		    
		    if (!loadingOverlay) {
		        loadingOverlay = document.createElement('div');
		        loadingOverlay.id = 'loading-overlay';
		        loadingOverlay.innerHTML = `
		            <div class="loading-spinner">
		                <div class="spinner-border text-primary" role="status">
		                    <span class="visually-hidden">Loading...</span>
		                </div>
		                <p class="mt-2">Processing...</p>
		            </div>
		        `;
		        
		        // Add CSS for loading overlay
		        const style = document.createElement('style');
		        style.textContent = `
		            #loading-overlay {
		                position: fixed;
		                top: 0;
		                left: 0;
		                width: 100%;
		                height: 100%;
		                background-color: rgba(255, 255, 255, 0.8);
		                display: flex;
		                justify-content: center;
		                align-items: center;
		                z-index: 9999;
		            }
		            #loading-overlay .loading-spinner {
		                text-align: center;
		                color: var(--primary);
		            }
		        `;
		        document.head.appendChild(style);
		        
		        document.body.appendChild(loadingOverlay);
		    }
		    
		    // Show the overlay
		    loadingOverlay.style.display = 'flex';
		}

		/**
		 * Hide loading overlay
		 */
		function hideLoading() {
		    const loadingOverlay = document.getElementById('loading-overlay');
		    if (loadingOverlay) {
		        loadingOverlay.style.display = 'none';
		    }
		}

		/**
		 * Show toast notification
		 */
		function showToast(message, type = 'info') {
		    // Create a unique ID for the toast
		    const toastId = 'toast-' + Date.now();
		    
		    // Create toast HTML
		    const toastHtml = `
		        <div id="${toastId}" class="toast-notification toast-${type}">
		            <div class="toast-icon">
		                <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'}"></i>
		            </div>
		            <div class="toast-content">
		                <p>${message}</p>
		            </div>
		            <button class="toast-close">&times;</button>
		        </div>
		    `;
		    
		    // Add CSS for toast if not already added
		    if (!document.getElementById('toast-css')) {
		        const style = document.createElement('style');
		        style.id = 'toast-css';
		        style.textContent = `
		            .toast-notification {
		                position: fixed;
		                right: 20px;
		                bottom: 20px;
		                background: white;
		                border-radius: 8px;
		                padding: 15px;
		                display: flex;
		                align-items: center;
		                min-width: 300px;
		                max-width: 450px;
		                box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
		                transform: translateY(100px);
		                opacity: 0;
		                transition: transform 0.3s ease, opacity 0.3s ease;
		                z-index: 1060;
		            }
		            .toast-notification.show {
		                transform: translateY(0);
		                opacity: 1;
		            }
		            .toast-icon {
		                display: flex;
		                align-items: center;
		                justify-content: center;
		                width: 40px;
		                height: 40px;
		                border-radius: 50%;
		                margin-right: 15px;
		                flex-shrink: 0;
		            }
		            .toast-content {
		                flex-grow: 1;
		            }
		            .toast-content p {
		                margin-bottom: 0;
		                font-size: 0.95rem;
		            }
		            .toast-close {
		                background: none;
		                border: none;
		                font-size: 1.5rem;
		                line-height: 1;
		                color: #aaa;
		                padding: 0 5px;
		                cursor: pointer;
		            }
		            .toast-success .toast-icon {
		                background-color: rgba(46, 204, 113, 0.1);
		                color: #2ecc71;
		            }
		            .toast-error .toast-icon {
		                background-color: rgba(231, 76, 60, 0.1);
		                color: #e74c3c;
		            }
		            .toast-info .toast-icon {
		                background-color: rgba(52, 152, 219, 0.1);
		                color: #3498db;
		            }
		            @media (max-width: 767px) {
		                .toast-notification {
		                    left: 20px;
		                    right: 20px;
		                    max-width: none;
		                }
		            }
		        `;
		        document.head.appendChild(style);
		    }
		    
		    // Create toast element and append to body
		    const toastElement = document.createElement('div');
		    toastElement.innerHTML = toastHtml;
		    document.body.appendChild(toastElement.firstElementChild);
		    
		    const toast = document.getElementById(toastId);
		    
		    // Show the toast after a brief delay
		    setTimeout(() => {
		        toast.classList.add('show');
		        
		        // Auto-hide after 5 seconds
		        setTimeout(() => {
		            toast.classList.remove('show');
		            
		            // Remove from DOM after hiding
		            setTimeout(() => {
		                toast.remove();
		            }, 300);
		        }, 5000);
		    }, 100);
		    
		    // Close button handler
		    const closeButton = toast.querySelector('.toast-close');
		    if (closeButton) {
		        closeButton.addEventListener('click', () => {
		            toast.classList.remove('show');
		            setTimeout(() => {
		                toast.remove();
		            }, 300);
		        });
		    }
		}