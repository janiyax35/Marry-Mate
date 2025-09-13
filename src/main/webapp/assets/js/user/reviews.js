/**
 * User Reviews JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time (UTC): 2025-05-18 08:39:12
 * Current User: IT24102137
 */

document.addEventListener('DOMContentLoaded', function() {
    // Global variables
    let reviewsData = [];
    let pendingServicesData = [];
    let currentView = 'list'; // 'list' or 'grid'
    let currentFilter = 'all'; // default filter
    let reviewsTable; // DataTable instance
    
    // Get context path for proper URL construction
    const contextPath = window.location.pathname.substring(0, window.location.pathname.indexOf("/user") || window.location.pathname.length);
    
    // Initialize DataTable - with check for existing instance
    if ($.fn.DataTable.isDataTable('#reviewsTable')) {
        // If table is already initialized, get the existing instance
        reviewsTable = $('#reviewsTable').DataTable();
    } else {
        // Initialize new DataTable
        reviewsTable = $('#reviewsTable').DataTable({
            responsive: true,
            order: [[3, 'desc']], // Sort by date by default
            lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "All"]],
            language: {
                search: "",
                searchPlaceholder: "Search reviews..."
            },
            dom: 't<"row align-items-center"<"col-sm-12 col-md-5"i><"col-sm-12 col-md-7"p>>',
            columnDefs: [
                { orderable: false, targets: [7] } // Disable sorting for actions column
            ]
        });
    }
    
    // Toggle between list and grid view
    $('#listViewBtn').on('click', function() {
        $('#reviewGridView').hide();
        $('#reviewListView').show();
        $('#listViewBtn').addClass('active');
        $('#gridViewBtn').removeClass('active');
        currentView = 'list';
        
        // Adjust DataTable columns
        reviewsTable.columns.adjust().responsive.recalc();
    });
    
    $('#gridViewBtn').on('click', function() {
        $('#reviewListView').hide();
        $('#reviewGridView').show();
        $('#gridViewBtn').addClass('active');
        $('#listViewBtn').removeClass('active');
        currentView = 'grid';
    });
    
    // Filter options
    $('.filter-option').on('click', function(e) {
        e.preventDefault();
        
        // Update active class
        $('.filter-option').removeClass('active');
        $(this).addClass('active');
        
        currentFilter = $(this).data('filter');
        $('#filterOptions').html(`<i class="fas fa-filter me-2"></i>${$(this).text()}`);
        
        // Apply filter
        filterReviews(currentFilter);
    });
    
    // Review Search
    $('#reviewSearch').on('keyup', function() {
        reviewsTable.search($(this).val()).draw();
    });
    
    // Refresh button functionality
    $('#refreshReviewsBtn').on('click', function() {
        // Show spinning animation
        const btnIcon = $(this).find('i');
        btnIcon.addClass('fa-spin');
        $(this).prop('disabled', true);
        
        // Reload data using AJAX
        loadReviews();
        loadPendingServices();
        
        // After a short delay, stop the spinning
        setTimeout(function() {
            btnIcon.removeClass('fa-spin');
            $('#refreshReviewsBtn').prop('disabled', false);
            
            // Show success message
            showAlert('Reviews refreshed successfully!', 'success');
        }, 1000);
    });
    
    // Export reviews as CSV
    $('#exportCSVBtn').on('click', function() {
        exportReviews('csv');
    });
    
    // Export reviews as PDF
    $('#exportPDFBtn').on('click', function() {
        exportReviews('pdf');
    });
    
    // View review details
    $(document).on('click', '.view-review-btn', function() {
        const reviewId = $(this).data('review-id');
        showReviewDetails(reviewId);
    });
    
    // Edit review
    $(document).on('click', '.edit-review-btn, #editReviewBtn', function() {
        const reviewId = $(this).data('review-id') || $('#detailReviewId').text();
        prepareReviewForm(reviewId);
    });
    
    // Delete review
    $(document).on('click', '.delete-review-btn', function() {
        const reviewId = $(this).data('review-id');
        $('#deleteReviewId').val(reviewId);
        
        // Show confirmation modal
        const confirmDeleteModal = new bootstrap.Modal(document.getElementById('deleteReviewModal'));
        confirmDeleteModal.show();
    });
    
    // Confirm delete
    $('#confirmDeleteBtn').on('click', function() {
        deleteReview($('#deleteReviewId').val());
    });
    
    // Create new review
    $(document).on('click', '.write-review-btn', function() {
        const serviceId = $(this).data('service-id');
        const vendorId = $(this).data('vendor-id');
        const bookingId = $(this).data('booking-id');
        
        prepareReviewForm(null, serviceId, vendorId, bookingId);
    });
    
    // Rating stars functionality
    $(document).on('click', '.rating-star', function() {
        const value = $(this).data('value');
        $('#overallRating').val(value);
        
        // Update star appearance
        $('.rating-star').each(function(index) {
            if (index < value) {
                $(this).removeClass('far').addClass('fas active');
            } else {
                $(this).removeClass('fas active').addClass('far');
            }
        });
        
        // Update rating text
        updateRatingText(value);
    });
    
    // Detailed rating sliders
    $('#qualityRating, #valueRating, #responsivenessRating, #professionalismRating').on('input', function() {
        const value = $(this).val();
        const id = $(this).attr('id').replace('Rating', 'Value');
        $(`#${id}`).text(value);
    });
    
    // Photo upload functionality
    $('#photoUpload').on('change', function() {
        handlePhotoUpload(this.files);
    });
    
    // Remove photo
    $(document).on('click', '.remove-photo', function() {
        $(this).closest('.photo-preview').remove();
    });
    
    // Submit review
    $('#submitReviewBtn').on('click', function() {
        submitReview('published');
    });
    
    // Save as draft
    $('#saveAsDraftBtn').on('click', function() {
        submitReview('draft');
    });
    
    // Check for URL parameters to automatically open review form
    function getUrlParameter(name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search);
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    }
    
    // Load reviews on page load
    loadReviews();
    loadPendingServices();
    
    // If we have action=newReview in URL, prepare the review form
    const action = getUrlParameter('action');
    if (action === 'newReview') {
        const serviceId = getUrlParameter('serviceId');
        const vendorId = getUrlParameter('vendorId');
        const bookingId = getUrlParameter('bookingId');
        
        if (serviceId && vendorId && bookingId) {
            // Slight delay to ensure page is fully loaded
            setTimeout(function() {
                prepareReviewForm(null, serviceId, vendorId, bookingId);
            }, 1000);
        }
    }
    
    /**
     * Function to load reviews from backend
     */
    function loadReviews() {
        $('.review-loading').show();
        $('#noReviewsMessage').hide();
        
        // Prepare request URL - userId will be retrieved from session by servlet
        let requestUrl = contextPath + '/user/reviewservlet';
        
        console.log('Loading reviews from: ' + requestUrl);
        
        // Get reviews from the servlet with timeout
        $.ajax({
            url: requestUrl,
            method: 'GET',
            dataType: 'json',
            timeout: 15000, // 15 second timeout
            success: function(data) {
                console.log('Reviews loaded:', Array.isArray(data) ? data.length : 'Not an array');
                
                // Handle empty or invalid response
                if (!data || (Array.isArray(data) && data.length === 0)) {
                    // Show empty state for no reviews
                    $('#reviewListView').hide();
                    $('#reviewGridView').hide();
                    $('#noReviewsMessage').show();
                    $('.review-loading').hide();
                    
                    // Update stats with zeros
                    updateReviewStats([]);
                    return;
                }
                
                // Store the reviews data
                reviewsData = Array.isArray(data) ? data : [];
                
                // Update stats
                updateReviewStats(reviewsData);
                
                // Clear existing data
                reviewsTable.clear();
                
                if (reviewsData.length === 0) {
                    // Show empty state
                    $('#reviewListView').hide();
                    $('#reviewGridView').hide();
                    $('#noReviewsMessage').show();
                    $('.review-loading').hide();
                    return;
                }
                
                // Hide empty state
                $('#noReviewsMessage').hide();
                
                // Show the appropriate view based on current selection
                if (currentView === 'list') {
                    $('#reviewListView').show();
                    $('#reviewGridView').hide();
                } else {
                    $('#reviewListView').hide();
                    $('#reviewGridView').show();
                }
                
                // Filter reviews if filter is set
                if (currentFilter !== 'all') {
                    filterReviews(currentFilter);
                } else {
                    // Render all reviews
                    renderReviews(reviewsData);
                }
                
                $('.review-loading').hide();
            },
            error: function(xhr, status, error) {
                console.error('Error loading reviews:', error);
                $('.review-loading').hide();
                
                if (xhr.status === 401) {
                    showAlert('Session expired. Please log in again.', 'warning');
                } else {
                    showAlert('Error loading reviews: ' + error, 'danger');
                }
                
                // Show empty state on error
                $('#reviewListView').hide();
                $('#reviewGridView').hide();
                $('#noReviewsMessage').show();
                
                // Update stats with zeros on error
                updateReviewStats([]);
            }
        });
    }
    
    /**
     * Function to load services that need reviews
     */
    function loadPendingServices() {
        // Prepare request URL
        let requestUrl = contextPath + '/user/reviewservlet?action=pendingServices';
        
        $.ajax({
            url: requestUrl,
            method: 'GET',
            dataType: 'json',
            success: function(data) {
                // Store pending services data
                pendingServicesData = Array.isArray(data) ? data : [];
                
                if (pendingServicesData.length === 0) {
                    $('#pendingReviewsSection').hide();
                    return;
                }
                
                // Show pending services section
                $('#pendingReviewsSection').show();
                
                // Clear container
                $('#pendingReviewsList').empty();
                
                // Render pending services
                pendingServicesData.forEach(service => {
                    const serviceHtml = `
                        <div class="col-lg-6 col-xl-4">
                            <div class="pending-review-item">
                                <div class="pending-review-header">
                                    <img src="${service.vendorPhotoUrl || contextPath + '/assets/images/vendors/default-vendor.jpg'}" 
                                         alt="${service.vendorName}" class="vendor-preview">
                                    <div class="pending-review-info">
                                        <h6>${service.serviceName}</h6>
                                        <div class="text-muted small">${service.vendorName}</div>
                                        <div class="pending-review-date">
                                            <i class="fas fa-calendar-alt"></i>
                                            ${service.serviceDate}
                                        </div>
                                    </div>
                                </div>
                                <div class="pending-review-actions">
                                    <button class="btn btn-primary btn-sm w-100 write-review-btn" 
                                        data-service-id="${service.serviceId}" 
                                        data-vendor-id="${service.vendorId}"
                                        data-booking-id="${service.bookingId}">
                                        <i class="fas fa-star me-2"></i>Write Review
                                    </button>
                                </div>
                            </div>
                        </div>
                    `;
                    $('#pendingReviewsList').append(serviceHtml);
                });
            },
            error: function(xhr, status, error) {
                console.error('Error loading pending services:', error);
                $('#pendingReviewsSection').hide();
            }
        });
    }
    
    /**
     * Function to render reviews in table and grid view
     */
    function renderReviews(reviews) {
        reviewsTable.clear();
        $('#reviewsGrid').empty();
        
        reviews.forEach(review => {
            // Add to table
            reviewsTable.row.add([
                review.reviewId,
                review.vendorName,
                review.serviceName,
                review.reviewDate,
                getRatingStars(review.rating),
                getStatusBadge(review.status),
                review.helpfulCount,
                getActionButtons(review)
            ]);
            
            // Add to grid
            const photoHtml = review.photoUrls && review.photoUrls.length > 0 ? 
                `<div class="review-card-photos">
                    ${review.photoUrls.map(url => `<img src="${url}" alt="Review Photo" class="review-card-photo">`).join('')}
                </div>` : '';
            
            const gridHtml = `
                <div class="col-md-6 col-lg-4">
                    <div class="card review-card">
                        <div class="card-body">
                            <div class="review-card-header">
                                <img src="${review.vendorPhotoUrl || contextPath + '/assets/images/vendors/default-vendor.jpg'}" 
                                     alt="${review.vendorName}" class="vendor-preview">
                                <div class="review-card-vendor">
                                    <h6>${review.vendorName}</h6>
                                    <div class="text-muted small">${review.serviceName}</div>
                                </div>
                            </div>
                            <div class="mb-2">
                                ${getRatingStars(review.rating)}
                            </div>
                            <div class="review-card-content">
                                <p>${review.comment}</p>
                            </div>
                            ${photoHtml}
                            <div class="review-card-date">
                                <i class="far fa-calendar-alt me-1"></i> ${review.reviewDate}
                            </div>
                            <div class="review-card-footer">
                                <div>${getStatusBadge(review.status)}</div>
                                <div class="card-actions">
                                    <button class="btn btn-sm btn-outline-primary view-review-btn" data-review-id="${review.reviewId}" title="View Details">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-secondary edit-review-btn" data-review-id="${review.reviewId}" title="Edit Review">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-danger delete-review-btn" data-review-id="${review.reviewId}" title="Delete">
                                        <i class="fas fa-trash-alt"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            `;
            
            $('#reviewsGrid').append(gridHtml);
        });
        
        reviewsTable.draw();
    }
    
    /**
     * Function to filter reviews based on status
     */
    function filterReviews(filter) {
        if (filter === 'all') {
            renderReviews(reviewsData);
            return;
        }
        
        // Filter reviews with matching status
        const filteredReviews = reviewsData.filter(review => review.status === filter);
        renderReviews(filteredReviews);
        
        // Show no reviews message if filtered list is empty
        if (filteredReviews.length === 0) {
            reviewsTable.clear().draw();
            
            reviewsTable.row.add([
                '',
                '',
                '',
                `<div class="text-center py-3">
                    <i class="fas fa-filter fa-2x text-muted mb-2"></i>
                    <p class="mb-0">No reviews with '${filter}' status found.</p>
                </div>`,
                '',
                '',
                '',
                ''
            ]).draw();
            
            $('#reviewsGrid').html(`
                <div class="col-12">
                    <div class="text-center py-5">
                        <i class="fas fa-filter fa-3x text-muted mb-3"></i>
                        <h5>No Reviews Found</h5>
                        <p class="text-muted">No reviews with '${filter}' status were found.</p>
                    </div>
                </div>
            `);
        }
    }
    
    /**
     * Function to update review stats
     */
    function updateReviewStats(reviews) {
        let totalReviews = reviews.length;
        let pendingCount = 0;
        let totalRating = 0;
        let totalHelpful = 0;
        
        reviews.forEach(review => {
            if (review.status === 'pending') pendingCount++;
            totalRating += parseFloat(review.rating || 0);
            totalHelpful += parseInt(review.helpfulCount || 0);
        });
        
        const avgRating = totalReviews > 0 ? (totalRating / totalReviews).toFixed(1) : '0.0';
        
        $('#totalReviews').text(totalReviews);
        $('#pendingReviews').text(pendingCount);
        $('#averageRating').text(avgRating);
        $('#totalHelpful').text(totalHelpful);
    }
    
    /**
     * Function to show review details
     */
    function showReviewDetails(reviewId) {
        // Reset modal content
        $('#reviewDetailsLoader').show();
        $('#reviewDetailsContent').hide();
        
        // Show modal
        const detailsModal = new bootstrap.Modal(document.getElementById('reviewDetailsModal'));
        detailsModal.show();
        
        // Find review in data
        const review = reviewsData.find(r => r.reviewId === reviewId);
        
        if (!review) {
            // Handle review not found
            $('#reviewDetailsLoader').html(`
                <div class="text-center py-5">
                    <i class="fas fa-exclamation-circle fa-3x text-danger mb-3"></i>
                    <p>Review not found. Please try again.</p>
                </div>
            `);
            return;
        }
        
        // Fill in review details
        $('#detailReviewId').text(review.reviewId);
        $('#detailStatus').text(capitalizeFirstLetter(review.status));
        $('#detailStatus').removeClass().addClass(`badge rounded-pill status-badge-${review.status}`);
        $('#detailReviewDate').text(review.reviewDate);
        
        // Vendor & service details
        $('#detailVendorName').text(review.vendorName);
        $('#detailServiceName').text(review.serviceName);
        $('#detailBookingId').text(review.bookingId);
        
        // Ratings
        $('#detailOverallRating').html(getRatingStars(review.rating));
        
        if (review.detailedRatings) {
            $('#detailQualityRating').html(getRatingStars(review.detailedRatings.quality));
            $('#detailQualityValue').text(review.detailedRatings.quality);
            
            $('#detailValueRating').html(getRatingStars(review.detailedRatings.value));
            $('#detailValueValue').text(review.detailedRatings.value);
            
            $('#detailResponseRating').html(getRatingStars(review.detailedRatings.responsiveness));
            $('#detailResponseValue').text(review.detailedRatings.responsiveness);
            
            $('#detailProfessionalismRating').html(getRatingStars(review.detailedRatings.professionalism));
            $('#detailProfessionalismValue').text(review.detailedRatings.professionalism);
        }
        
        // Review content
        $('#detailComment').text(review.comment);
        
        // Photos
        if (review.photoUrls && review.photoUrls.length > 0) {
            $('#detailPhotosSection').show();
            $('#detailPhotos').empty();
            
            review.photoUrls.forEach(url => {
                $('#detailPhotos').append(`<img src="${url}" alt="Review Photo" class="review-photo">`);
            });
        } else {
            $('#detailPhotosSection').hide();
        }
        
        // Vendor response
        if (review.vendorResponse && review.vendorResponse.text) {
            $('#vendorResponseSection').show();
            $('#detailVendorResponse').text(review.vendorResponse.text);
            $('#detailResponseDate').text(review.vendorResponse.responseDate);
        } else {
            $('#vendorResponseSection').hide();
        }
        
        // Metrics
        $('#detailHelpfulCount').text(review.helpfulCount || 0);
        $('#detailLastUpdated').text(review.lastUpdated || review.reviewDate);
        
        // Show/hide edit button based on status - make it more prominent
        $('#editReviewBtn').attr('data-review-id', review.reviewId);
        $('#editReviewBtn').show();
        
        // Show content, hide loader
        $('#reviewDetailsLoader').hide();
        $('#reviewDetailsContent').show();
    }
    
    /**
     * Function to prepare review form for create or edit
     */
    function prepareReviewForm(reviewId, serviceId, vendorId, bookingId) {
        // Reset form
        $('#reviewForm')[0].reset();
        $('#photoPreviewsContainer').html(`
            <div class="photo-upload-placeholder">
                <input type="file" id="photoUpload" name="reviewPhotos" accept="image/*" multiple class="photo-upload-input">
                <i class="fas fa-camera"></i>
                <span>Add Photos</span>
            </div>
        `);
        
        // Reset rating stars
        $('.rating-star').removeClass('fas active').addClass('far');
        $('#ratingText').text('Click to rate');
        $('#overallRating').val(0);
        
        // Reset sliders
        $('#qualityRating, #valueRating, #responsivenessRating, #professionalismRating').val(3);
        $('#qualityValue, #valueValue, #responsivenessValue, #professionalismValue').text('3');
        
        if (reviewId) {
            // Edit existing review - fetch from server
            $('#reviewModalTitle').text('Edit Review');
            $('#editReviewId').val(reviewId);
            
            // Show loading state
            const formContent = $('#createReviewModal .modal-body').html();
            $('#createReviewModal .modal-body').html(`
                <div class="text-center py-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Loading review data...</p>
                </div>
            `);
            
            // Show modal while loading
            const createReviewModal = new bootstrap.Modal(document.getElementById('createReviewModal'));
            createReviewModal.show();
            
            // Fetch review from server
            $.ajax({
                url: contextPath + '/user/reviewservlet',
                method: 'GET',
                data: {
                    action: 'getReview',
                    reviewId: reviewId
                },
                dataType: 'json',
                success: function(response) {
                    // Restore form content
                    $('#createReviewModal .modal-body').html(formContent);
                    
                    if (response.status === 'success') {
                        const review = response.review;
                        
                        // Set form fields
                        $('#editReviewId').val(review.reviewId);
                        $('#serviceId').val(review.serviceId);
                        $('#vendorId').val(review.vendorId);
                        $('#bookingId').val(review.bookingId);
                        
                        // Set vendor and service info
                        $('#reviewVendorName').text(review.vendorName || 'Unknown Vendor');
                        $('#reviewServiceName').text(review.serviceName || 'Unknown Service');
                        $('#vendorImage').attr('src', review.vendorPhotoUrl || contextPath + '/assets/images/vendors/default-vendor.jpg');
                        
                        // Set rating
                        if (review.rating) {
                            setStarRating(review.rating);
                        }
                        
                        // Set comment
                        $('#reviewComment').val(review.comment);
                        
                        // Set detailed ratings
                        if (review.detailedRatings) {
                            $('#qualityRating').val(review.detailedRatings.quality);
                            $('#qualityValue').text(review.detailedRatings.quality);
                            
                            $('#valueRating').val(review.detailedRatings.value);
                            $('#valueValue').text(review.detailedRatings.value);
                            
                            $('#responsivenessRating').val(review.detailedRatings.responsiveness);
                            $('#responsivenessValue').text(review.detailedRatings.responsiveness);
                            
                            $('#professionalismRating').val(review.detailedRatings.professionalism);
                            $('#professionalismValue').text(review.detailedRatings.professionalism);
                        }
                        
                        // Display existing photos
                        if (review.photoUrls && review.photoUrls.length > 0) {
                            review.photoUrls.forEach(url => {
                                const photoHtml = `
                                    <div class="photo-preview">
                                        <img src="${url}" alt="Review Photo">
                                        <div class="remove-photo">
                                            <i class="fas fa-times"></i>
                                        </div>
                                        <input type="hidden" name="existingPhotos[]" value="${url}">
                                    </div>
                                `;
                                $(photoHtml).insertBefore('.photo-upload-placeholder');
                            });
                        }
                    } else {
                        // Handle error
                        showAlert('Error: ' + response.message, 'danger');
                        
                        // Close modal
                        const modalInstance = bootstrap.Modal.getInstance(document.getElementById('createReviewModal'));
                        modalInstance.hide();
                    }
                },
                error: function(xhr, status, error) {
                    // Restore form content
                    $('#createReviewModal .modal-body').html(formContent);
                    
                    // Show error
                    showAlert('Error loading review: ' + error, 'danger');
                    
                    // Close modal
                    const modalInstance = bootstrap.Modal.getInstance(document.getElementById('createReviewModal'));
                    modalInstance.hide();
                }
            });
        } else {
            // Create new review
            $('#reviewModalTitle').text('Write a Review');
            $('#editReviewId').val('');
            $('#serviceId').val(serviceId);
            $('#vendorId').val(vendorId);
            $('#bookingId').val(bookingId);
            
            if (serviceId && vendorId) {
                // Fetch service and vendor details
                $.ajax({
                    url: contextPath + '/user/reviewservlet',
                    method: 'GET',
                    data: {
                        action: 'getServiceDetails',
                        serviceId: serviceId,
                        vendorId: vendorId
                    },
                    dataType: 'json',
                    success: function(response) {
                        if (response.status === 'success') {
                            $('#reviewVendorName').text(response.vendorName);
                            $('#reviewServiceName').text(response.serviceName);
                            $('#vendorImage').attr('src', response.vendorPhotoUrl || contextPath + '/assets/images/vendors/default-vendor.jpg');
                        } else {
                            $('#reviewVendorName').text('Vendor');
                            $('#reviewServiceName').text('Service');
                            $('#vendorImage').attr('src', contextPath + '/assets/images/vendors/default-vendor.jpg');
                        }
                    },
                    error: function() {
                        $('#reviewVendorName').text('Vendor');
                        $('#reviewServiceName').text('Service');
                        $('#vendorImage').attr('src', contextPath + '/assets/images/vendors/default-vendor.jpg');
                    }
                });
            } else {
                // Find service and vendor info from pendingServices
                const service = pendingServicesData.find(s => 
                    s.serviceId === serviceId && 
                    s.vendorId === vendorId && 
                    s.bookingId === bookingId
                );
                
                if (service) {
                    $('#reviewVendorName').text(service.vendorName);
                    $('#reviewServiceName').text(service.serviceName);
                    $('#vendorImage').attr('src', service.vendorPhotoUrl || contextPath + '/assets/images/vendors/default-vendor.jpg');
                } else {
                    // If service not found, show placeholder
                    $('#reviewVendorName').text('Vendor');
                    $('#reviewServiceName').text('Service');
                    $('#vendorImage').attr('src', contextPath + '/assets/images/vendors/default-vendor.jpg');
                }
            }
            
            // Show modal
            const createReviewModal = new bootstrap.Modal(document.getElementById('createReviewModal'));
            createReviewModal.show();
        }
    }
    
    /**
     * Function to submit a review
     */
    function submitReview(status) {
        // Validate form
        if (!validateReviewForm()) {
            return;
        }
        
        // Gather form data
        const formData = new FormData($('#reviewForm')[0]);
        formData.append('status', status);
        
        // Check if it's an edit or create operation
        const reviewId = $('#editReviewId').val();
        const isEdit = reviewId && reviewId.trim() !== '';
        
        // Add action if it's an edit
        if (isEdit) {
            formData.append('action', 'edit');
        }
        
        // Add existing photos if any
        const existingPhotos = [];
        $('input[name="existingPhotos[]"]').each(function() {
            existingPhotos.push($(this).val());
        });
        
        if (existingPhotos.length > 0) {
            formData.append('existingPhotos', JSON.stringify(existingPhotos));
        }
        
        // Disable buttons and show loading
        const submitBtn = $('#submitReviewBtn');
        const draftBtn = $('#saveAsDraftBtn');
        const originalSubmitText = submitBtn.html();
        const originalDraftText = draftBtn.html();
        
        submitBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Submitting...');
        submitBtn.prop('disabled', true);
        draftBtn.prop('disabled', true);
        
        // Send review to server
        $.ajax({
            url: contextPath + '/user/reviewservlet',
            method: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function(response) {
                if (response.status === 'success') {
                    // Close modal
                    const modal = bootstrap.Modal.getInstance(document.getElementById('createReviewModal'));
                    modal.hide();
                    
                    // Show success message
                    if (isEdit) {
                        showAlert('Your review has been updated successfully!', 'success');
                    } else {
                        showAlert(status === 'published' ? 
                            'Your review has been submitted successfully!' : 
                            'Your review has been saved as a draft.', 'success');
                    }
                    
                    // Reload reviews and pending services
                    loadReviews();
                    loadPendingServices();
                    
                    // Clear URL parameters if they exist
                    if (window.history.replaceState) {
                        window.history.replaceState({}, document.title, window.location.pathname);
                    }
                } else {
                    showAlert('Error: ' + (response.message || 'Failed to submit review'), 'danger');
                }
                
                // Reset buttons
                submitBtn.html(originalSubmitText);
                submitBtn.prop('disabled', false);
                draftBtn.html(originalDraftText);
                draftBtn.prop('disabled', false);
            },
            error: function(xhr, status, error) {
                showAlert('Error submitting review: ' + error, 'danger');
                
                // Reset buttons
                submitBtn.html(originalSubmitText);
                submitBtn.prop('disabled', false);
                draftBtn.html(originalDraftText);
                draftBtn.prop('disabled', false);
            }
        });
    }
    
    /**
     * Function to validate review form
     */
    function validateReviewForm() {
        // Check rating
        const rating = $('#overallRating').val();
        if (rating <= 0) {
            showAlert('Please provide an overall rating.', 'warning');
            return false;
        }
        
        // Check comment
        const comment = $('#reviewComment').val().trim();
        if (comment.length < 50) {
            showAlert('Please provide a detailed review (minimum 50 characters).', 'warning');
            return false;
        }
        
        // Check photo count
        const photoCount = $('.photo-preview').length + $('#photoUpload')[0].files.length;
        if (photoCount > 5) {
            showAlert('Maximum 5 photos allowed.', 'warning');
            return false;
        }
        
        return true;
    }
    
    /**
     * Function to delete a review
     */
    function deleteReview(reviewId) {
        // Display loading indicator
        const deleteBtn = $('#confirmDeleteBtn');
        const originalText = deleteBtn.html();
        deleteBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Deleting...');
        deleteBtn.prop('disabled', true);
        
        // Send delete request
        $.ajax({
            url: contextPath + '/user/reviewservlet',
            method: 'POST',
            data: {
                action: 'delete',
                reviewId: reviewId
            },
            success: function(response) {
                if (response.status === 'success') {
                    // Close modal
                    const modal = bootstrap.Modal.getInstance(document.getElementById('deleteReviewModal'));
                    modal.hide();
                    
                    // Show success message
                    showAlert('Review deleted successfully.', 'success');
                    
                    // Reload reviews
                    loadReviews();
                } else {
                    showAlert('Error: ' + (response.message || 'Failed to delete review'), 'danger');
                }
                
                // Reset button
                deleteBtn.html(originalText);
                deleteBtn.prop('disabled', false);
            },
            error: function(xhr, status, error) {
                showAlert('Error deleting review: ' + error, 'danger');
                
                // Reset button
                deleteBtn.html(originalText);
                deleteBtn.prop('disabled', false);
            }
        });
    }
    
    /**
     * Function to handle photo uploads and preview
     */
    function handlePhotoUpload(files) {
        // Check file count
        const existingCount = $('.photo-preview').length;
        const totalCount = existingCount + files.length;
        
        if (totalCount > 5) {
            showAlert('You can upload a maximum of 5 photos.', 'warning');
            return;
        }
        
        // Process each file
        for (let i = 0; i < files.length; i++) {
            const file = files[i];
            
            // Validate file format
            if (!file.type.match('image.*')) {
                showAlert('Only image files are allowed.', 'warning');
                continue;
            }
            
            // Validate file size (max 5MB)
            if (file.size > 5 * 1024 * 1024) {
                showAlert('Maximum file size is 5MB.', 'warning');
                continue;
            }
            
            // Create preview
            const reader = new FileReader();
            reader.onload = function(e) {
                const photoHtml = `
                    <div class="photo-preview">
                        <img src="${e.target.result}" alt="Review Photo">
                        <div class="remove-photo">
                            <i class="fas fa-times"></i>
                        </div>
                    </div>
                `;
                $(photoHtml).insertBefore('.photo-upload-placeholder');
            }
            reader.readAsDataURL(file);
        }
        
        // Reset file input to allow selecting the same files again
        $('#photoUpload').val('');
    }
    
    /**
     * Function to export reviews
     */
    function exportReviews(format = 'csv') {
        // Display loading indicator
        const exportBtn = format === 'csv' ? $('#exportCSVBtn') : $('#exportPDFBtn');
        const originalText = exportBtn.html();
        exportBtn.html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Exporting...');
        exportBtn.prop('disabled', true);
        
        // Get reviews to export based on current filter
        const reviewsToExport = currentFilter === 'all' ? reviewsData : reviewsData.filter(r => r.status === currentFilter);
        
        if (format === 'csv') {
            // Generate CSV data
            let csvContent = "data:text/csv;charset=utf-8,";
            csvContent += "Review ID,Vendor,Service,Date,Rating,Status,Helpful Count,Comment\n";
            
            // Add reviews to CSV
            reviewsToExport.forEach(review => {
                // Clean comment for CSV (remove commas, quotes, newlines)
                const cleanComment = review.comment ? review.comment
                    .replace(/"/g, '""') // Escape quotes
                    .replace(/\r?\n/g, ' ') // Replace newlines
                    : '';
                
                const row = [
                    review.reviewId,
                    review.vendorName,
                    review.serviceName,
                    review.reviewDate,
                    review.rating,
                    review.status,
                    review.helpfulCount,
                    `"${cleanComment}"`
                ].join(',');
                
                csvContent += row + "\n";
            });
            
            // Create download link
            const encodedUri = encodeURI(csvContent);
            const link = document.createElement("a");
            link.setAttribute("href", encodedUri);
            link.setAttribute("download", "reviews_export.csv");
            document.body.appendChild(link);
            
            // Trigger download
            setTimeout(function() {
                link.click();
                document.body.removeChild(link);
                
                exportBtn.html('<i class="fas fa-check me-2"></i> Exported!');
                
                setTimeout(function() {
                    exportBtn.html(originalText);
                    exportBtn.prop('disabled', false);
                    
                    // Show success message
                    showAlert('Reviews exported as CSV successfully!', 'success');
                }, 1000);
            }, 500);
        } else if (format === 'pdf') {
            // Generate PDF using jsPDF
            setTimeout(function() {
                try {
                    // Initialize jsPDF
                    const { jsPDF } = window.jspdf;
                    const doc = new jsPDF();
                    
                    // Add title
                    doc.setFontSize(16);
                    doc.text('Marry Mate - Reviews Export', 14, 15);
                    
                    // Add export info
                    doc.setFontSize(10);
                    doc.text(`Generated on: ${new Date().toLocaleString()}`, 14, 22);
                    doc.text(`Filter: ${capitalizeFirstLetter(currentFilter)}`, 14, 27);
                    doc.text(`Total Reviews: ${reviewsToExport.length}`, 14, 32);
                    
                    // Add table
                    doc.autoTable({
                        startY: 35,
                        head: [['Vendor', 'Service', 'Date', 'Rating', 'Status', 'Helpful']],
                        body: reviewsToExport.map(review => [
                            review.vendorName,
                            review.serviceName,
                            review.reviewDate,
                            review.rating,
                            capitalizeFirstLetter(review.status),
                            review.helpfulCount
                        ]),
                        styles: { fontSize: 9 },
                        headStyles: { fillColor: [26, 54, 93] }
                    });
                    
                    // Add details for each review
                    let yPos = doc.lastAutoTable.finalY + 10;
                    
                    doc.setFontSize(12);
                    doc.text('Review Details', 14, yPos);
                    yPos += 7;
                    
                    reviewsToExport.forEach((review, index) => {
                        // Check if we need a new page
                        if (yPos > 280) {
                            doc.addPage();
                            yPos = 15;
                        }
                        
                        doc.setFontSize(11);
                        doc.text(`${index + 1}. ${review.vendorName} - ${review.serviceName}`, 14, yPos);
                        yPos += 5;
                        
                        doc.setFontSize(9);
                        doc.text(`Rating: ${review.rating}/5 | Date: ${review.reviewDate} | Status: ${capitalizeFirstLetter(review.status)}`, 14, yPos);
                        yPos += 5;
                        
                        // Add comment with word wrap
                        const splitComment = doc.splitTextToSize(`Comment: ${review.comment}`, 180);
                        doc.text(splitComment, 14, yPos);
                        yPos += splitComment.length * 5 + 5;
                    });
                    
                    // Generate PDF name with timestamp
                    const filename = `marry_mate_reviews_${new Date().toISOString().slice(0, 10)}.pdf`;
                    
                    // Save PDF
                    doc.save(filename);
                    
                    exportBtn.html('<i class="fas fa-check me-2"></i> Exported!');
                    
                    setTimeout(function() {
                        exportBtn.html(originalText);
                        exportBtn.prop('disabled', false);
                        
                        // Show success message
                        showAlert('Reviews exported as PDF successfully!', 'success');
                    }, 1000);
                } catch (error) {
                    console.error("PDF generation error:", error);
                    exportBtn.html(originalText);
                    exportBtn.prop('disabled', false);
                    showAlert('Error generating PDF. Please make sure jsPDF is loaded properly.', 'danger');
                }
            }, 500);
        }
    }
    
    /**
     * Helper function to get rating stars HTML
     */
    function getRatingStars(rating) {
        rating = parseFloat(rating) || 0;
        let starsHtml = '';
        
        for (let i = 1; i <= 5; i++) {
            if (i <= rating) {
                starsHtml += '<i class="fas fa-star"></i>';
            } else if (i <= rating + 0.5) {
                starsHtml += '<i class="fas fa-star-half-alt"></i>';
            } else {
                starsHtml += '<i class="far fa-star"></i>';
            }
        }
        
        return `<span class="rating">${starsHtml} <span class="rating-value">${rating}</span></span>`;
    }
    
    /**
     * Helper function to set star rating
     */
    function setStarRating(rating) {
        rating = parseInt(rating);
        $('#overallRating').val(rating);
        
        $('.rating-star').each(function(index) {
            if (index < rating) {
                $(this).removeClass('far').addClass('fas active');
            } else {
                $(this).removeClass('fas active').addClass('far');
            }
        });
        
        updateRatingText(rating);
    }
    
    /**
     * Helper function to update rating text
     */
    function updateRatingText(rating) {
        const ratingTexts = {
            1: 'Poor - Significant issues with service',
            2: 'Fair - Below expectations',
            3: 'Good - Met expectations',
            4: 'Very Good - Exceeded expectations',
            5: 'Excellent - Outstanding service'
        };
        
        $('#ratingText').text(ratingTexts[rating] || 'Click to rate');
    }
    
    /**
     * Helper function to get status badge HTML
     */
    function getStatusBadge(status) {
        const statusLabels = {
            'published': 'Published',
            'pending': 'Pending',
            'draft': 'Draft',
            'flagged': 'Flagged'
        };
        
        return `<span class="badge rounded-pill status-badge-${status}">${statusLabels[status] || status}</span>`;
    }
    
    /**
     * Helper function to get action buttons HTML
     */
    function getActionButtons(review) {
        let buttons = `
            <div class="action-buttons">
                <button class="btn btn-sm btn-outline-primary view-review-btn" title="View Details" data-review-id="${review.reviewId}">
                    <i class="fas fa-eye"></i>
                </button>
                <button class="btn btn-sm btn-outline-secondary ms-1 edit-review-btn" title="Edit Review" data-review-id="${review.reviewId}">
                    <i class="fas fa-edit"></i>
                </button>
                <button class="btn btn-sm btn-outline-danger ms-1 delete-review-btn" title="Delete Review" data-review-id="${review.reviewId}">
                    <i class="fas fa-trash-alt"></i>
                </button>
            </div>`;
        
        return buttons;
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
});