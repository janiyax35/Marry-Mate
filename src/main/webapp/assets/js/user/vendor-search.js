/**
 * Vendor Search JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-01 06:36:44
 * Current User: IT24102137
 */

document.addEventListener('DOMContentLoaded', function() {
    'use strict';
    
    // Initialize price range slider
    initPriceRangeSlider();
    
    // Initialize view toggle
    initViewToggle();
    
    // Handle search form submission
    initSearchForm();
    
    // Handle favorite buttons
    initFavoriteButtons();
    
    // Handle vendor detail view
    initVendorDetailView();
    
    // Handle quote request
    initQuoteRequest();
    
    // Initialize filters
    initFilters();
});

/**
 * Initialize Price Range Slider
 */
function initPriceRangeSlider() {
    const priceRangeSlider = document.getElementById('priceRangeSlider');
    if (!priceRangeSlider) return;
    
    const minPrice = document.getElementById('minPrice');
    const maxPrice = document.getElementById('maxPrice');
    
    // Create the slider
    noUiSlider.create(priceRangeSlider, {
        start: [0, 20000],
        connect: true,
        step: 500,
        range: {
            'min': 0,
            'max': 30000
        },
        format: {
            to: function (value) {
                return Math.round(value);
            },
            from: function (value) {
                return Number(value);
            }
        }
    });
    
    // Update input values when slider is moved
    priceRangeSlider.noUiSlider.on('update', function(values, handle) {
        const value = values[handle];
        
        if (handle === 0) {
            minPrice.value = value;
        } else {
            maxPrice.value = value;
        }
    });
    
    // Update slider when input values change
    minPrice.addEventListener('change', function() {
        priceRangeSlider.noUiSlider.set([this.value, null]);
    });
    
    maxPrice.addEventListener('change', function() {
        priceRangeSlider.noUiSlider.set([null, this.value]);
    });
}

/**
 * Initialize View Toggle (Grid/List view)
 */
function initViewToggle() {
    const gridViewBtn = document.getElementById('gridViewBtn');
    const listViewBtn = document.getElementById('listViewBtn');
    const gridView = document.getElementById('gridView');
    const listView = document.getElementById('listView');
    
    if (!gridViewBtn || !listViewBtn || !gridView || !listView) return;
    
    // Switch to grid view
    gridViewBtn.addEventListener('click', function() {
        gridView.style.display = 'block';
        listView.style.display = 'none';
        gridViewBtn.classList.add('active');
        listViewBtn.classList.remove('active');
        
        // Store preference in localStorage
        localStorage.setItem('vendorViewPreference', 'grid');
    });
    
    // Switch to list view
    listViewBtn.addEventListener('click', function() {
        gridView.style.display = 'none';
        listView.style.display = 'block';
        listViewBtn.classList.add('active');
        gridViewBtn.classList.remove('active');
        
        // Store preference in localStorage
        localStorage.setItem('vendorViewPreference', 'list');
    });
    
    // Load user's preference if available
    const viewPreference = localStorage.getItem('vendorViewPreference');
    if (viewPreference === 'list') {
        listViewBtn.click();
    }
}

/**
 * Initialize Search Form
 */
function initSearchForm() {
    const searchForm = document.getElementById('vendorSearchForm');
    if (!searchForm) return;
    
    searchForm.addEventListener('submit', function(e) {
        e.preventDefault();
        
        const category = document.getElementById('categorySelect').value;
        const location = document.getElementById('locationInput').value;
        
        // Update UI to show search criteria
        updateSearchCriteria(category, location);
        
        // Apply filters
        applyFilters();
        
        // Show loading state for a moment
        showLoading();
    });
    
    // Initialize location autocomplete
    const locationInput = document.getElementById('locationInput');
    if (locationInput) {
        // In a real app, this would be a proper autocomplete implementation
        // For demonstration, we'll just add a basic focus/blur effect
        locationInput.addEventListener('focus', function() {
            this.classList.add('focus');
        });
        
        locationInput.addEventListener('blur', function() {
            this.classList.remove('focus');
        });
    }
}

/**
 * Update Search Criteria Display
 */
function updateSearchCriteria(category, location) {
    // Update filter checkboxes based on search
    if (category) {
        // Check the corresponding category checkbox
        const categoryCheckbox = document.querySelector(`.category-filter[value="${category}"]`);
        if (categoryCheckbox) {
            categoryCheckbox.checked = true;
        }
    }
    
    if (location) {
        // Check the corresponding location checkbox
        const locationCheckbox = document.querySelector(`.location-filter[value="${location}"]`);
        if (locationCheckbox) {
            locationCheckbox.checked = true;
        }
    }
}

/**
 * Show Loading Indicator
 */
function showLoading() {
    const resultsGrid = document.getElementById('gridView');
    const resultsList = document.getElementById('listView');
    
    if (resultsGrid && resultsList) {
        // Add loading class (CSS would handle the visual feedback)
        resultsGrid.classList.add('loading');
        resultsList.classList.add('loading');
        
        // Remove loading class after a short delay
        setTimeout(() => {
            resultsGrid.classList.remove('loading');
            resultsList.classList.remove('loading');
            
            // Update results count
            updateResultsCount();
            
            // Show a success message
            showToast('Search Results Updated', 'Found vendors matching your criteria.', 'success');
        }, 800);
    }
}

/**
 * Initialize Favorite Buttons
 */
function initFavoriteButtons() {
    const favoriteButtons = document.querySelectorAll('.favorite-btn');
    
    favoriteButtons.forEach(button => {
        button.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const vendorId = this.getAttribute('data-vendor-id');
            const icon = this.querySelector('i');
            
            // Toggle favorite state
            if (icon.classList.contains('far')) {
                // Add to favorites
                icon.classList.remove('far');
                icon.classList.add('fas');
                
                // Show success message
                showToast('Added to Favorites', 'Vendor has been added to your favorites.', 'success');
                
                // In a real app, this would make an AJAX request to save the favorite
                saveFavorite(vendorId, true);
            } else {
                // Remove from favorites
                icon.classList.remove('fas');
                icon.classList.add('far');
                
                // Show message
                showToast('Removed from Favorites', 'Vendor has been removed from your favorites.', 'info');
                
                // In a real app, this would make an AJAX request to remove the favorite
                saveFavorite(vendorId, false);
            }
        });
    });
}

/**
 * Save Favorite (simulated AJAX request)
 */
function saveFavorite(vendorId, isFavorite) {
    // In a real app, this would be an AJAX request to the server
    console.log(`Vendor ${vendorId} favorite status: ${isFavorite}`);
    
    // Store in localStorage for demo purposes
    let favorites = JSON.parse(localStorage.getItem('favoriteVendors')) || [];
    
    if (isFavorite) {
        if (!favorites.includes(vendorId)) {
            favorites.push(vendorId);
        }
    } else {
        favorites = favorites.filter(id => id !== vendorId);
    }
    
    localStorage.setItem('favoriteVendors', JSON.stringify(favorites));
}

/**
 * Initialize Vendor Detail View
 */
function initVendorDetailView() {
    const viewButtons = document.querySelectorAll('.view-vendor');
    const modal = document.getElementById('vendorDetailsModal');
    
    if (!modal) return;
    
    const modalInstance = new bootstrap.Modal(modal);
    const modalContent = modal.querySelector('.vendor-details-content');
    
    viewButtons.forEach(button => {
        button.addEventListener('click', function() {
            const vendorId = this.getAttribute('data-vendor-id');
            
            // Show loading state
            modalContent.innerHTML = `
                <div class="text-center py-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Loading vendor details...</p>
                </div>
            `;
            
            // Show the modal
            modalInstance.show();
            
            // Simulate fetching vendor details
            setTimeout(() => {
                loadVendorDetails(vendorId, modalContent);
            }, 1000);
        });
    });
    
    // Set current vendor ID for the request quote button in the modal
    const requestQuoteFromModalBtn = document.getElementById('requestQuoteFromModal');
    if (requestQuoteFromModalBtn) {
        requestQuoteFromModalBtn.addEventListener('click', function() {
            // Hide the details modal
            modalInstance.hide();
            
            // Get the current vendor ID from the modal
            const vendorId = this.getAttribute('data-vendor-id');
            
            // Show the quote request modal for this vendor
            showQuoteRequestModal(vendorId);
        });
    }
}

/**
 * Load Vendor Details
 */
function loadVendorDetails(vendorId, container) {
    // In a real app, this would fetch data from the server
    // For demo, we'll create mock data based on the vendor ID
    
    // Find the vendor data from the page (this is a simplified approach)
    const vendorCard = document.querySelector(`.vendor-card:has([data-vendor-id="${vendorId}"]), .vendor-list-item:has([data-vendor-id="${vendorId}"])`);
    if (!vendorCard) return;
    
    const vendorName = vendorCard.querySelector('.vendor-name').textContent;
    const vendorCategory = vendorCard.querySelector('.vendor-category').textContent;
    const vendorLocation = vendorCard.querySelector('.vendor-location').textContent.trim().replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
    const vendorImage = vendorCard.querySelector('img').getAttribute('src');
    const vendorRating = vendorCard.querySelector('.vendor-rating .stars').parentElement.textContent.trim().split('(')[0];
    const vendorPrice = vendorCard.querySelector('.vendor-price').textContent;
    
    // Create description based on category
    let description, services, packages;
    switch(vendorCategory) {
        case 'Venues':
            description = "This stunning venue offers elegant spaces for both ceremonies and receptions. With beautiful grounds, modern facilities and excellent service, it's a perfect choice for couples looking for a memorable wedding location.";
            services = [
                { name: "Ceremony Space", price: "Included in venue rental" },
                { name: "Reception Hall", price: "Included in venue rental" },
                { name: "Bridal Suite", price: "Included in venue rental" },
                { name: "Tables & Chairs", price: "Included in venue rental" },
                { name: "Basic Linens", price: "Included in venue rental" },
                { name: "Setup & Cleanup", price: "+$500" }
            ];
            packages = [
                { name: "Weekend Package", price: vendorPrice.split('-')[1].trim(), description: "Full weekend access to the venue, including rehearsal dinner space, ceremony and reception areas, and cleanup Sunday." },
                { name: "Basic Package", price: vendorPrice.split('-')[0].trim(), description: "8-hour rental of ceremony and reception spaces, includes tables, chairs, and basic setup." }
            ];
            break;
            
        case 'Catering':
            description = "A premier catering service offering delicious cuisine for your special day. Their talented chefs create custom menus featuring locally-sourced ingredients and artistic presentation.";
            services = [
                { name: "Plated Dinner Service", price: "$75-125 per person" },
                { name: "Buffet Service", price: "$65-95 per person" },
                { name: "Family Style Service", price: "$70-110 per person" },
                { name: "Cocktail Hour Appetizers", price: "$15-25 per person" },
                { name: "Dessert Station", price: "$12 per person" },
                { name: "Bartending Services", price: "$40 per hour per bartender" }
            ];
            packages = [
                { name: "Deluxe Package", price: "$150 per person", description: "Full service catering including cocktail hour with passed appetizers, plated 4-course meal, dessert, and coffee service." },
                { name: "Essential Package", price: "$95 per person", description: "Buffet style dinner with 2 entrées, 3 sides, salad, and rolls." }
            ];
            break;
            
        default:
            description = "This vendor offers high-quality services for your wedding day. With years of experience, they're committed to making your wedding special and memorable.";
            services = [
                { name: "Standard Service", price: vendorPrice },
                { name: "Premium Service", price: vendorPrice.split('-')[1] || vendorPrice },
                { name: "Custom Package", price: "Call for pricing" }
            ];
            packages = [
                { name: "Complete Package", price: vendorPrice.split('-')[1].trim() || vendorPrice, description: "Full service package with all premium options and extras." },
                { name: "Basic Package", price: vendorPrice.split('-')[0].trim() || vendorPrice, description: "Essential services at an affordable price." }
            ];
    }
    
    // Create gallery images
    const galleryImages = [
        vendorImage,
        'https://images.unsplash.com/photo-1519225421980-715cb0215aed?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1509927083803-4bd519298ac4?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1519741497674-611481863552?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80',
        'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80'
    ];
    
    // Create HTML for the vendor details
    container.innerHTML = `
        <div class="vendor-details-banner">
            <img src="${vendorImage}" alt="${vendorName}">
        </div>
        
        <div class="vendor-details-logo">
            <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(vendorName)}&background=1a365d&color=fff&bold=true&size=80" alt="${vendorName} Logo">
        </div>
        
        <div class="vendor-details-header">
            <h3 class="vendor-details-name">${vendorName}</h3>
            <div class="vendor-details-rating">
                <div class="stars">
                    ${generateStarRating(parseFloat(vendorRating))}
                </div>
                <span class="ms-2">${vendorRating} (${Math.floor(Math.random() * 50) + 20} reviews)</span>
            </div>
            <div class="vendor-details-info">
                <span class="badge bg-primary">${vendorCategory}</span>
                <span><i class="fas fa-map-marker-alt me-1"></i>${vendorLocation}</span>
                <span><i class="fas fa-dollar-sign me-1"></i>${vendorPrice}</span>
            </div>
        </div>
        
        <nav>
            <div class="nav nav-tabs vendor-details-tabs" role="tablist">
                <button class="nav-link active" id="overview-tab" data-bs-toggle="tab" data-bs-target="#overview" type="button" role="tab" aria-controls="overview" aria-selected="true">Overview</button>
                <button class="nav-link" id="services-tab" data-bs-toggle="tab" data-bs-target="#services" type="button" role="tab" aria-controls="services" aria-selected="false">Services</button>
                <button class="nav-link" id="gallery-tab" data-bs-toggle="tab" data-bs-target="#gallery" type="button" role="tab" aria-controls="gallery" aria-selected="false">Gallery</button>
                <button class="nav-link" id="reviews-tab" data-bs-toggle="tab" data-bs-target="#reviews" type="button" role="tab" aria-controls="reviews" aria-selected="false">Reviews</button>
            </div>
        </nav>
        
        <div class="tab-content">
            <!-- Overview Tab -->
            <div class="tab-pane fade show active" id="overview" role="tabpanel" aria-labelledby="overview-tab">
                <h4>About ${vendorName}</h4>
                <p>${description}</p>
                
                <h4>Featured Packages</h4>
                ${packages.map(pkg => `
                    <div class="service-item">
                        <div class="service-title">${pkg.name}</div>
                        <div class="service-price mb-2">${pkg.price}</div>
                        <div class="service-description">${pkg.description}</div>
                    </div>
                `).join('')}
                
                <h4>Availability</h4>
                <p>This vendor is currently available on your selected date (check their calendar for the most up-to-date availability).</p>
                
                <button class="btn btn-outline-primary mt-3 view-calendar-btn">
                    <i class="fas fa-calendar-alt me-2"></i> View Availability Calendar
                </button>
            </div>
            
            <!-- Services Tab -->
            <div class="tab-pane fade" id="services" role="tabpanel" aria-labelledby="services-tab">
                <h4>Services & Pricing</h4>
                <p>Below are the services offered by ${vendorName}. Prices may vary based on specific requirements and dates.</p>
                
                <div class="table-responsive mt-3">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Service</th>
                                <th>Price</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${services.map(service => `
                                <tr>
                                    <td>${service.name}</td>
                                    <td>${service.price}</td>
                                </tr>
                            `).join('')}
                        </tbody>
                    </table>
                </div>
                
                <div class="alert alert-info mt-4">
                    <i class="fas fa-info-circle me-2"></i> 
                    Contact this vendor for a custom quote tailored to your specific needs.
                </div>
            </div>
            
            <!-- Gallery Tab -->
            <div class="tab-pane fade" id="gallery" role="tabpanel" aria-labelledby="gallery-tab">
                <h4>Photo Gallery</h4>
                <div class="vendor-details-gallery">
                    ${galleryImages.map(img => `
                        <div class="gallery-item">
                            <img src="${img}" alt="${vendorName}">
                        </div>
                    `).join('')}
                </div>
            </div>
            
            <!-- Reviews Tab -->
            <div class="tab-pane fade" id="reviews" role="tabpanel" aria-labelledby="reviews-tab">
                <h4>Customer Reviews</h4>
                
                <div class="review-summary mb-4">
                    <div class="row align-items-center">
                        <div class="col-md-4 text-center">
                            <div class="display-4 fw-bold">${vendorRating}</div>
                            <div class="stars">
                                ${generateStarRating(parseFloat(vendorRating))}
                            </div>
                            <div class="mt-1">${Math.floor(Math.random() * 50) + 20} reviews</div>
                        </div>
                        <div class="col-md-8">
                            <div class="progress mb-2" style="height: 8px">
                                <div class="progress-bar bg-success" role="progressbar" style="width: ${Math.round((Math.random() * 30) + 60)}%" aria-valuenow="70" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                            <div class="progress mb-2" style="height: 8px">
                                <div class="progress-bar bg-success" role="progressbar" style="width: ${Math.round((Math.random() * 20) + 20)}%" aria-valuenow="20" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                            <div class="progress mb-2" style="height: 8px">
                                <div class="progress-bar bg-warning" role="progressbar" style="width: ${Math.round(Math.random() * 15)}%" aria-valuenow="8" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                            <div class="progress mb-2" style="height: 8px">
                                <div class="progress-bar bg-danger" role="progressbar" style="width: ${Math.round(Math.random() * 5)}%" aria-valuenow="2" aria-valuemin="0" aria-valuemax="100"></div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Sample Reviews -->
                <div class="review-list">
                    <div class="review-item">
                        <div class="review-header">
                            <div class="review-author">
                                <img src="https://ui-avatars.com/api/?name=Sarah+T&background=c8b273&color=fff" alt="Sarah T.">
                                <div>
                                    <div class="review-author-name">Sarah T.</div>
                                    <div class="stars">
                                        ${generateStarRating(5)}
                                    </div>
                                </div>
                            </div>
                            <div class="review-date">March 15, 2025</div>
                        </div>
                        <div class="review-content">
                            "Our experience with ${vendorName} was absolutely perfect. They exceeded all of our expectations and helped make our wedding day truly special. The service was impeccable from start to finish. Highly recommended!"
                        </div>
                    </div>
                    
                    <div class="review-item">
                        <div class="review-header">
                            <div class="review-author">
                                <img src="https://ui-avatars.com/api/?name=Michael+R&background=1a365d&color=fff" alt="Michael R.">
                                <div>
                                    <div class="review-author-name">Michael R.</div>
                                    <div class="stars">
                                        ${generateStarRating(4)}
                                    </div>
                                </div>
                            </div>
                            <div class="review-date">February 28, 2025</div>
                        </div>
                        <div class="review-content">
                            "We had a great experience working with ${vendorName}. The quality of service was excellent and the staff was very professional. The only minor issue was some delay in response times during the planning process, but overall we were very satisfied."
                        </div>
                    </div>
                    
                    <div class="review-item">
                        <div class="review-header">
                            <div class="review-author">
                                <img src="https://ui-avatars.com/api/?name=Jennifer+L&background=e74c3c&color=fff" alt="Jennifer L.">
                                <div>
                                    <div class="review-author-name">Jennifer L.</div>
                                    <div class="stars">
                                        ${generateStarRating(5)}
                                    </div>
                                </div>
                            </div>
                            <div class="review-date">January 12, 2025</div>
                        </div>
                        <div class="review-content">
                            "If you're considering ${vendorName}, look no further! They were incredible to work with and made our day so special. Their attention to detail and willingness to accommodate our requests was outstanding. Worth every penny!"
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `;
    
    // Set the vendor ID on the request quote button
    const requestQuoteBtn = document.getElementById('requestQuoteFromModal');
    if (requestQuoteBtn) {
        requestQuoteBtn.setAttribute('data-vendor-id', vendorId);
    }
    
    // Initialize the calendar view button
    const calendarBtn = container.querySelector('.view-calendar-btn');
    if (calendarBtn) {
        calendarBtn.addEventListener('click', function() {
            Swal.fire({
                title: 'Availability Calendar',
                html: `
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle me-2"></i>
                        This vendor is available on your wedding date: <strong>September 15, 2025</strong>
                    </div>
                    <div class="calendar-placeholder p-4 bg-light text-center">
                        <i class="far fa-calendar-alt fa-3x mb-3 text-primary"></i>
                        <p>Full availability calendar would be displayed here.</p>
                    </div>
                `,
                showCancelButton: true,
                confirmButtonText: 'Request Quote',
                cancelButtonText: 'Close',
                confirmButtonColor: '#1a365d',
            }).then((result) => {
                if (result.isConfirmed) {
                    // Close the details modal first
                    const detailsModal = bootstrap.Modal.getInstance(document.getElementById('vendorDetailsModal'));
                    detailsModal.hide();
                    
                    // Show quote request modal
                    setTimeout(() => {
                        showQuoteRequestModal(vendorId);
                    }, 500);
                }
            });
        });
    }
}

/**
 * Generate Star Rating HTML
 */
function generateStarRating(rating) {
    let starsHtml = '';
    
    // Generate full stars
    for (let i = 1; i <= Math.floor(rating); i++) {
        starsHtml += '<i class="fas fa-star"></i>';
    }
    
    // Add a half star if needed
    if (rating % 1 >= 0.5) {
        starsHtml += '<i class="fas fa-star-half-alt"></i>';
    }
    
    // Add empty stars to reach 5
    const emptyStars = 5 - Math.ceil(rating);
    for (let i = 1; i <= emptyStars; i++) {
        starsHtml += '<i class="far fa-star"></i>';
    }
    
    return starsHtml;
}

/**
 * Initialize Quote Request Functionality
 */
function initQuoteRequest() {
    const quoteButtons = document.querySelectorAll('.request-quote');
    
    quoteButtons.forEach(button => {
        button.addEventListener('click', function() {
            const vendorId = this.getAttribute('data-vendor-id');
            showQuoteRequestModal(vendorId);
        });
    });
    
    // Handle quote form submission
    const sendQuoteRequestBtn = document.getElementById('sendQuoteRequestBtn');
    if (sendQuoteRequestBtn) {
        sendQuoteRequestBtn.addEventListener('click', function() {
            const form = document.getElementById('quoteRequestForm');
            
            // Basic validation
            const requiredFields = form.querySelectorAll('[required]');
            let isValid = true;
            
            requiredFields.forEach(field => {
                if (!field.value) {
                    field.classList.add('is-invalid');
                    isValid = false;
                } else {
                    field.classList.remove('is-invalid');
                }
            });
            
            if (!isValid) {
                showToast('Missing Information', 'Please fill in all required fields.', 'error');
                return;
            }
            
            // Show loading state
            sendQuoteRequestBtn.disabled = true;
            sendQuoteRequestBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span> Sending...';
            
            // Simulate sending request
            setTimeout(() => {
                // Hide modal
                const modal = bootstrap.Modal.getInstance(document.getElementById('requestQuoteModal'));
                modal.hide();
                
                // Reset form
                form.reset();
                
                // Reset button
                sendQuoteRequestBtn.disabled = false;
                sendQuoteRequestBtn.textContent = 'Send Request';
                
                // Show success message
                Swal.fire({
                    icon: 'success',
                    title: 'Quote Request Sent!',
                    html: 'Your request has been sent successfully.<br>The vendor will contact you shortly.',
                    confirmButtonColor: '#1a365d'
                });
            }, 1500);
        });
    }
}

/**
 * Show Quote Request Modal
 */
function showQuoteRequestModal(vendorId) {
    const modal = document.getElementById('requestQuoteModal');
    if (!modal) return;
    
    const modalInstance = new bootstrap.Modal(modal);
    
    // Find vendor data
    const vendorCard = document.querySelector(`.vendor-card:has([data-vendor-id="${vendorId}"]), .vendor-list-item:has([data-vendor-id="${vendorId}"])`);
    if (!vendorCard) return;
    
    const vendorName = vendorCard.querySelector('.vendor-name').textContent;
    
    // Set vendor information in the form
    document.getElementById('quoteVendorId').value = vendorId;
    document.getElementById('quoteVendorName').value = vendorName;
    
    // Show the modal
    modalInstance.show();
}

/**
 * Initialize Filters
 */
function initFilters() {
    // Clear all filters button
    const clearAllBtn = document.getElementById('clearAllFilters');
    if (clearAllBtn) {
        clearAllBtn.addEventListener('click', function() {
            // Reset all checkboxes
            document.querySelectorAll('.filter-options input[type="checkbox"]').forEach(checkbox => {
                checkbox.checked = false;
            });
            
            // Reset radio buttons to any rating
            document.getElementById('ratingAny').checked = true;
            
            // Reset price range slider
            if (document.getElementById('priceRangeSlider') && document.getElementById('priceRangeSlider').noUiSlider) {
                document.getElementById('priceRangeSlider').noUiSlider.set([0, 30000]);
            }
            
            // Reset search form
            document.getElementById('categorySelect').value = '';
            
            // Apply filters
            applyFilters();
            
            // Show message
            showToast('Filters Cleared', 'All filters have been reset.', 'info');
        });
    }
    
    // Add event listeners for filter changes
    const filterInputs = document.querySelectorAll('.category-filter, .location-filter, .feature-filter, .rating-filter');
    filterInputs.forEach(input => {
        input.addEventListener('change', function() {
            applyFilters();
        });
    });
    
    // Sort options
    const sortSelect = document.getElementById('sortOptions');
    if (sortSelect) {
        sortSelect.addEventListener('change', function() {
            applyFilters();
        });
    }
}

/**
 * Apply Filters
 */
function applyFilters() {
    // In a real app, this would make an AJAX request with all filter parameters
    // For demo purposes, we'll just simulate filtering
    
    // Show loading state
    showLoading();
}

/**
 * Update Results Count
 */
function updateResultsCount() {
    const resultsCountElement = document.getElementById('resultsCount');
    if (!resultsCountElement) return;
    
    // In a real app, this would be the actual count from the server
    // For demo, we'll simulate a filtered count
    const filteredCount = Math.floor(Math.random() * 5) + 4; // Random between 4-8
    resultsCountElement.textContent = filteredCount;
}

/**
 * Show Toast Notification
 */
function showToast(title, message, icon) {
    const Toast = Swal.mixin({
        toast: true,
        position: 'top-end',
        showConfirmButton: false,
        timer: 3000,
        timerProgressBar: true,
        didOpen: (toast) => {
            toast.addEventListener('mouseenter', Swal.stopTimer);
            toast.addEventListener('mouseleave', Swal.resumeTimer);
        }
    });
    
    Toast.fire({
        icon: icon,
        title: title,
        text: message
    });
}