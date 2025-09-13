/**
 * Vendor Reviews JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-07 09:21:29
 * Current User: IT24102137
 */

document.addEventListener('DOMContentLoaded', function() {
    // Global variables
    let reviewsData = [];
    let currentSort = 'date-desc';
    let currentFilter = 'all';
    const vendorId = 'V1004'; // Default for testing, this would come from session/backend
    
    // Initialize reviews
    loadReviews();
    
    // Event listeners for filter and sort options
    document.querySelectorAll('.sort-option').forEach(option => {
        option.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Update active state
            document.querySelectorAll('.sort-option').forEach(opt => opt.classList.remove('active'));
            this.classList.add('active');
            
            // Update sort and refresh
            currentSort = this.dataset.sort;
            sortReviews();
            renderReviews();
        });
    });
    
    document.querySelectorAll('.filter-option').forEach(option => {
        option.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Update active state
            document.querySelectorAll('.filter-option').forEach(opt => opt.classList.remove('active'));
            this.classList.add('active');
            
            // Update text in dropdown button
            const filterText = this.textContent;
            document.getElementById('filterOptions').innerHTML = `<i class="fas fa-filter me-2"></i>${filterText}`;
            
            // Update filter and refresh
            currentFilter = this.dataset.filter;
            filterReviews();
        });
    });
    
    // Search functionality
    document.getElementById('reviewSearch').addEventListener('input', function() {
        const searchTerm = this.value.toLowerCase().trim();
        searchReviews(searchTerm);
    });
    
    // Handle review reply button clicks
    document.addEventListener('click', function(e) {
        // Reply button
        if (e.target.closest('.reply-btn')) {
            const reviewId = e.target.closest('.reply-btn').dataset.reviewId;
            showReplyModal(reviewId);
        }
        
        // Flag button
        if (e.target.closest('.flag-btn')) {
            const reviewId = e.target.closest('.flag-btn').dataset.reviewId;
            showFlagModal(reviewId);
        }
    });
    
    // Handle reply form submission
    document.getElementById('submitReplyBtn').addEventListener('click', function() {
        submitReply();
    });
    
    // Handle flag form submission
    document.getElementById('submitFlagBtn').addEventListener('click', function() {
        submitFlag();
    });
    
    /**
     * Function to load reviews
     */
    function loadReviews() {
        const reviewsContainer = document.getElementById('reviewsContainer');
        const noReviewsMessage = document.getElementById('noReviewsMessage');
        
        // Show loading state
        reviewsContainer.innerHTML = `
            <div class="reviews-loading text-center py-5">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
                <p class="mt-2">Loading reviews...</p>
            </div>
        `;
        
        // In a real implementation, this would be an API call to get reviews
        // For now, we'll simulate loading from the JSON file with a delay
        setTimeout(function() {
            reviewsData = getMockReviews(vendorId);
            
            if (reviewsData.length === 0) {
                // No reviews to display
                reviewsContainer.innerHTML = '';
                noReviewsMessage.style.display = 'block';
                return;
            }
            
            // Hide no reviews message
            noReviewsMessage.style.display = 'none';
            
            // Process and display reviews
            calculateReviewStats();
            initializeRatingChart();
            sortReviews();
            renderReviews();
            
        }, 1000);
    }
    
    /**
     * Function to calculate review statistics
     */
    function calculateReviewStats() {
        if (!reviewsData || reviewsData.length === 0) return;
        
        // Count stars
        let totalStars = 0;
        let starCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
        
        reviewsData.forEach(review => {
            const stars = Math.floor(review.rating);
            totalStars += review.rating;
            
            // Increment the appropriate star count
            if (stars >= 1 && stars <= 5) {
                starCounts[stars]++;
            }
        });
        
        // Calculate average
        const avgRating = totalStars / reviewsData.length;
        
        // Update UI
        document.getElementById('averageRating').textContent = avgRating.toFixed(1);
        document.getElementById('totalReviews').textContent = reviewsData.length;
        
        // Update star counts and progress bars
        const total = reviewsData.length;
        for (let i = 1; i <= 5; i++) {
            const count = starCounts[i];
            const percentage = total > 0 ? Math.round((count / total) * 100) : 0;
            
            document.getElementById(`${getStarName(i)}StarCount`).textContent = count;
            document.getElementById(`${getStarName(i)}StarBar`).style.width = `${percentage}%`;
            document.getElementById(`${getStarName(i)}StarBar`).setAttribute('aria-valuenow', percentage);
        }
        
        // Update average rating stars
        document.getElementById('averageRatingStars').innerHTML = getStarsHTML(avgRating);
    }
    
    /**
     * Function to initialize the rating trend chart
     */
    function initializeRatingChart() {
        // Check if Chart.js is available
        if (!window.Chart) return;
        
        // Process data for chart
        const months = [];
        const ratings = [];
        const reviewCounts = [];
        
        // Group reviews by month (last 6 months)
        const reviewsByMonth = {};
        const today = new Date();
        
        // Initialize last 6 months
        for (let i = 5; i >= 0; i--) {
            const month = new Date(today.getFullYear(), today.getMonth() - i, 1);
            const monthName = month.toLocaleDateString('en-US', { month: 'short' });
            const key = `${month.getFullYear()}-${month.getMonth()}`;
            
            reviewsByMonth[key] = {
                total: 0,
                count: 0,
                month: monthName
            };
            
            months.push(monthName);
        }
        
        // Aggregate review data by month
        reviewsData.forEach(review => {
            try {
                const reviewDate = new Date(review.date);
                const key = `${reviewDate.getFullYear()}-${reviewDate.getMonth()}`;
                
                if (reviewsByMonth[key]) {
                    reviewsByMonth[key].total += review.rating;
                    reviewsByMonth[key].count++;
                }
            } catch (e) {
                console.error('Error parsing review date:', e);
            }
        });
        
        // Calculate monthly averages
        Object.keys(reviewsByMonth).forEach(key => {
            const monthData = reviewsByMonth[key];
            const avgRating = monthData.count > 0 ? monthData.total / monthData.count : 0;
            
            ratings.push(avgRating);
            reviewCounts.push(monthData.count);
        });
        
        // Get the chart canvas and create the chart
        const ctx = document.getElementById('ratingsChart').getContext('2d');
        
        const ratingsChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: months,
                datasets: [{
                    label: 'Average Rating',
                    data: ratings,
                    borderColor: '#4a6741',
                    backgroundColor: 'rgba(74, 103, 65, 0.1)',
                    tension: 0.3,
                    yAxisID: 'y',
                    fill: true
                }, {
                    label: 'Number of Reviews',
                    data: reviewCounts,
                    borderColor: '#c8b273',
                    backgroundColor: 'rgba(200, 178, 115, 0.1)',
                    tension: 0.3,
                    borderDash: [5, 5],
                    yAxisID: 'y1',
                    fill: false
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    tooltip: {
                        mode: 'index',
                        intersect: false
                    },
                    legend: {
                        position: 'top'
                    }
                },
                scales: {
                    y: {
                        type: 'linear',
                        display: true,
                        position: 'left',
                        title: {
                            display: true,
                            text: 'Average Rating',
                            color: '#4a6741'
                        },
                        min: 0,
                        max: 5
                    },
                    y1: {
                        type: 'linear',
                        display: true,
                        position: 'right',
                        title: {
                            display: true,
                            text: 'Number of Reviews',
                            color: '#c8b273'
                        },
                        grid: {
                            drawOnChartArea: false
                        },
                        min: 0
                    }
                }
            }
        });
    }
    
    /**
     * Function to sort reviews based on current sort setting
     */
    function sortReviews() {
        if (!reviewsData || reviewsData.length === 0) return;
        
        switch (currentSort) {
            case 'date-desc':
                reviewsData.sort((a, b) => new Date(b.date) - new Date(a.date));
                break;
                
            case 'date-asc':
                reviewsData.sort((a, b) => new Date(a.date) - new Date(b.date));
                break;
                
            case 'rating-desc':
                reviewsData.sort((a, b) => b.rating - a.rating);
                break;
                
            case 'rating-asc':
                reviewsData.sort((a, b) => a.rating - b.rating);
                break;
                
            default:
                reviewsData.sort((a, b) => new Date(b.date) - new Date(a.date));
                break;
        }
    }
    
    /**
     * Function to filter reviews based on current filter setting
     */
    function filterReviews() {
        if (!reviewsData || reviewsData.length === 0) return;
        
        let filteredReviews = [];
        
        switch (currentFilter) {
            case 'all':
                filteredReviews = reviewsData;
                break;
                
            case '5':
            case '4':
            case '3':
            case '2':
            case '1':
                const starFilter = parseInt(currentFilter);
                filteredReviews = reviewsData.filter(review => {
                    const stars = Math.floor(review.rating);
                    return stars === starFilter;
                });
                break;
                
            case 'responded':
                filteredReviews = reviewsData.filter(review => review.vendorResponse);
                break;
                
            case 'not-responded':
                filteredReviews = reviewsData.filter(review => !review.vendorResponse);
                break;
                
            default:
                filteredReviews = reviewsData;
                break;
        }
        
        renderReviews(filteredReviews);
    }
    
    /**
     * Function to search reviews
     */
    function searchReviews(term) {
        if (!term) {
            filterReviews(); // Reset to current filter
            return;
        }
        
        const filteredReviews = reviewsData.filter(review => {
            return review.comment.toLowerCase().includes(term) || 
                   review.userId.toLowerCase().includes(term);
        });
        
        renderReviews(filteredReviews);
    }
    
    /**
     * Function to render reviews in the UI
     */
    function renderReviews(reviews = null) {
        const reviewsToRender = reviews || reviewsData;
        const reviewsContainer = document.getElementById('reviewsContainer');
        
        // Clear container
        reviewsContainer.innerHTML = '';
        
        if (reviewsToRender.length === 0) {
            reviewsContainer.innerHTML = `
                <div class="text-center py-5">
                    <i class="fas fa-search fa-3x text-muted mb-3"></i>
                    <h5>No Reviews Found</h5>
                    <p>No reviews match your current filter criteria.</p>
                    <button class="btn btn-outline-primary reset-filter-btn">
                        <i class="fas fa-undo me-2"></i> Reset Filters
                    </button>
                </div>
            `;
            
            // Add event listener to the reset button
            const resetBtn = reviewsContainer.querySelector('.reset-filter-btn');
            if (resetBtn) {
                resetBtn.addEventListener('click', function() {
                    document.querySelector('.filter-option[data-filter="all"]').click();
                    document.getElementById('reviewSearch').value = '';
                });
            }
            
            return;
        }
        
        // Create review items
        let reviewsHTML = '';
        
        reviewsToRender.forEach(review => {
            const formattedDate = formatDate(review.date);
            const hasResponse = review.vendorResponse && review.vendorResponse.text;
            
            reviewsHTML += `
                <div class="review-item" data-review-id="${review.id || review.userId}">
                    <div class="review-header">
                        <div class="reviewer-info">
                            <div class="reviewer-avatar">
                                <img src="${review.userPhotoUrl || '${pageContext.request.contextPath}/assets/images/profiles/default-user.jpg'}" alt="Reviewer">
                            </div>
                            <div class="reviewer-details">
                                <h6>${review.userName || `User ID: ${review.userId}`}</h6>
                                <div class="reviewer-meta">
                                    <div class="review-stars">
                                        ${getStarsHTML(review.rating)}
                                    </div>
                                    <span class="review-service">${review.serviceName || 'General Review'}</span>
                                    <span class="review-date"><i class="far fa-calendar-alt me-1"></i> ${formattedDate}</span>
                                </div>
                            </div>
                        </div>
                        <div class="review-meta">
                            <span class="badge ${getReviewBadgeClass(review.rating)}">${review.rating.toFixed(1)}</span>
                        </div>
                    </div>
                    <div class="review-content">
                        <p>${review.comment}</p>
                    </div>
                    <div class="review-footer">
                        ${hasResponse ? `
                            <div class="vendor-response">
                                <div class="response-header">
                                    <span class="response-title"><i class="fas fa-reply me-2"></i> Your Response</span>
                                    <span class="response-date">${formatDate(review.vendorResponse.date)}</span>
                                </div>
                                <div class="response-content">
                                    <p>${review.vendorResponse.text}</p>
                                </div>
                            </div>
                        ` : `
                            <div class="review-actions">
                                <button class="btn btn-sm btn-outline-primary reply-btn" data-review-id="${review.id || review.userId}">
                                    <i class="fas fa-reply me-1"></i> Respond
                                </button>
                                <button class="btn btn-sm btn-outline-secondary flag-btn" data-review-id="${review.id || review.userId}">
                                    <i class="fas fa-flag me-1"></i> Flag
                                </button>
                            </div>
                        `}
                    </div>
                </div>
            `;
        });
        
        reviewsContainer.innerHTML = reviewsHTML;
    }
    
    /**
     * Function to show reply modal
     */
    function showReplyModal(reviewId) {
        const review = findReviewById(reviewId);
        if (!review) return;
        
        // Set review details
        document.getElementById('reviewId').value = reviewId;
        document.getElementById('reviewModalRating').innerHTML = getStarsHTML(review.rating);
        document.getElementById('reviewModalDate').textContent = formatDate(review.date);
        document.getElementById('reviewModalContent').textContent = review.comment;
        document.getElementById('replyText').value = '';
        
        // Show modal
        const replyModal = new bootstrap.Modal(document.getElementById('replyModal'));
        replyModal.show();
    }
    
    /**
     * Function to show flag modal
     */
    function showFlagModal(reviewId) {
        // Set review ID
        document.getElementById('flaggedReviewId').value = reviewId;
        document.getElementById('flagReason').value = '';
        document.getElementById('flagDescription').value = '';
        
        // Show modal
        const flagModal = new bootstrap.Modal(document.getElementById('flagReviewModal'));
        flagModal.show();
    }
    
    /**
     * Function to submit reply to review
     */
    function submitReply() {
        // Get form data
        const reviewId = document.getElementById('reviewId').value;
        const replyText = document.getElementById('replyText').value;
        
        // Validation
        if (!replyText.trim()) {
            alert('Please enter your response.');
            return;
        }
        
        // Show loading
        const submitBtn = document.getElementById('submitReplyBtn');
        const originalText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Submitting...';
        submitBtn.disabled = true;
        
        // In a real implementation, this would be an AJAX call to save the response
        // For now, we'll simulate a successful save
        setTimeout(function() {
            // Find and update the review
            const review = findReviewById(reviewId);
            if (review) {
                review.vendorResponse = {
                    text: replyText,
                    date: new Date().toISOString().split('T')[0] // Today's date
                };
            }
            
            // Reset button
            submitBtn.innerHTML = originalText;
            submitBtn.disabled = false;
            
            // Close modal
            bootstrap.Modal.getInstance(document.getElementById('replyModal')).hide();
            
            // Re-render reviews
            renderReviews();
            
            // Show success message
            showAlert('Your response has been submitted successfully!', 'success');
        }, 1500);
    }
    
    /**
     * Function to submit flag for review
     */
    function submitFlag() {
        // Get form data
        const reviewId = document.getElementById('flaggedReviewId').value;
        const flagReason = document.getElementById('flagReason').value;
        const flagDescription = document.getElementById('flagDescription').value;
        
        // Validation
        if (!flagReason) {
            alert('Please select a reason for flagging this review.');
            return;
        }
        
        // Show loading
        const submitBtn = document.getElementById('submitFlagBtn');
        const originalText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Submitting...';
        submitBtn.disabled = true;
        
        // In a real implementation, this would be an AJAX call to flag the review
        // For now, we'll simulate a successful save
        setTimeout(function() {
            // Reset button
            submitBtn.innerHTML = originalText;
            submitBtn.disabled = false;
            
            // Close modal
            bootstrap.Modal.getInstance(document.getElementById('flagReviewModal')).hide();
            
            // Show success message
            showAlert('This review has been flagged for moderation.', 'info');
        }, 1500);
    }
    
    /**
     * Helper function to find a review by ID
     */
    function findReviewById(reviewId) {
        return reviewsData.find(review => (review.id === reviewId || review.userId === reviewId));
    }
    
    /**
     * Helper function to get stars HTML
     */
    function getStarsHTML(rating) {
        let starsHTML = '';
        
        // Full stars
        for (let i = 1; i <= Math.floor(rating); i++) {
            starsHTML += '<i class="fas fa-star"></i>';
        }
        
        // Half star
        if (rating % 1 >= 0.5) {
            starsHTML += '<i class="fas fa-star-half-alt"></i>';
            
            // Empty stars
            for (let i = Math.ceil(rating); i < 5; i++) {
                starsHTML += '<i class="far fa-star"></i>';
            }
        } else {
            // Empty stars
            for (let i = Math.ceil(rating); i < 5; i++) {
                starsHTML += '<i class="far fa-star"></i>';
            }
        }
        
        return starsHTML;
    }
    
    /**
     * Helper function to get review badge class
     */
    function getReviewBadgeClass(rating) {
        if (rating >= 4.5) return 'bg-success';
        if (rating >= 3.5) return 'bg-primary';
        if (rating >= 2.5) return 'bg-warning';
        return 'bg-danger';
    }
    
    /**
     * Helper function to get star name
     */
    function getStarName(stars) {
        switch (stars) {
            case 1: return 'one';
            case 2: return 'two';
            case 3: return 'three';
            case 4: return 'four';
            case 5: return 'five';
            default: return '';
        }
    }
    
    /**
     * Helper function to format date
     */
    function formatDate(dateStr) {
        try {
            const date = new Date(dateStr);
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric'
            });
        } catch (e) {
            return dateStr || 'Unknown Date';
        }
    }
    
    /**
     * Function to show alert message
     */
    function showAlert(message, type = 'success') {
        const alertHTML = `
            <div class="alert alert-${type} alert-dismissible fade show" role="alert">
                ${message}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        `;
        
        // Create a container for the alert if it doesn't exist
        let alertContainer = document.querySelector('.alert-container');
        if (!alertContainer) {
            alertContainer = document.createElement('div');
            alertContainer.className = 'alert-container position-fixed top-0 end-0 p-3';
            alertContainer.style.zIndex = '9999';
            document.body.appendChild(alertContainer);
        }
        
        // Add the alert to the container
        const alertElement = document.createElement('div');
        alertElement.innerHTML = alertHTML;
        alertContainer.appendChild(alertElement.firstChild);
        
        // Remove the alert after 5 seconds
        setTimeout(() => {
            const alerts = alertContainer.querySelectorAll('.alert');
            if (alerts.length > 0) {
                const alert = alerts[0];
                alert.classList.remove('show');
                setTimeout(() => {
                    alertContainer.removeChild(alert);
                    if (alertContainer.childNodes.length === 0) {
                        document.body.removeChild(alertContainer);
                    }
                }, 300);
            }
        }, 5000);
    }
    
    /**
     * Mock function to get reviews data
     * In a real implementation, this would be an API call to get reviews from vendors.json
     */
    function getMockReviews(vendorId) {
        // In a real implementation, this would return reviews for the specific vendor
        // For now, we'll return mock data
        return [
            {
                id: 'rev1',
                userId: 'U1001',
                userName: 'Sarah Johnson',
                rating: 5.0,
                comment: 'David captured our special day perfectly! The photos are absolutely stunning. He was professional, creative, and made everyone feel comfortable. We couldn't be happier with the results and would recommend his services to anyone looking for a wedding photographer.',
                date: '2025-04-15',
                serviceName: 'Wedding Photography',
                vendorResponse: {
                    text: 'Thank you so much for your kind words, Sarah! It was an absolute pleasure to photograph your beautiful wedding. I'm thrilled that you're happy with the photos and appreciate you taking the time to leave this wonderful review.',
                    date: '2025-04-16'
                }
            },
            {
                id: 'rev2',
                userId: 'U1005',
                userName: 'Michael Davis',
                rating: 4.8,
                comment: 'Professional and creative photography. David has a great eye for detail and captured moments we didn't even realize were happening. The engagement shoot was also included in our package and those photos were amazing as well. Only reason for not giving 5 stars is that we would have liked a few more family portraits.',
                date: '2025-03-22',
                serviceName: 'Wedding Photography'
            },
            {
                id: 'rev3',
                userId: 'U1003',
                userName: 'Jennifer Wilson',
                rating: 4.2,
                comment: 'Great photos but took longer than expected to deliver the final album. Quality of the work was excellent, and we love our photos, but we had to follow up several times about the timeline. David was very apologetic and professional about the delay.',
                date: '2025-02-18',
                serviceName: 'Wedding Photography',
                vendorResponse: {
                    text: 'Thank you for your honest feedback, Jennifer. I sincerely apologize for the delay in delivering your album. Your feedback has helped us improve our process, and we've now implemented a better tracking system to ensure timely delivery for all clients. I'm glad you're happy with the final photos, and I appreciate your understanding.',
                    date: '2025-02-19'
                }
            },
            {
                id: 'rev4',
                userId: 'U1010',
                userName: 'Robert Taylor',
                rating: 5.0,
                comment: 'Absolutely phenomenal! David went above and beyond for our engagement photos. He suggested a beautiful location that perfectly matched what we were looking for, and was patient as we changed outfits multiple times. The photos captured our relationship perfectly.',
                date: '2025-01-05',
                serviceName: 'Engagement Photography'
            },
            {
                id: 'rev5',
                userId: 'U1015',
                userName: 'Emily Chen',
                rating: 4.5,
                comment: 'David was wonderful to work with for my bridal portraits. He had creative ideas while also listening to what I wanted. The studio lighting was excellent and the outdoor shots were gorgeous. My only small critique is that I wish we had more time for the session.',
                date: '2024-12-10',
                serviceName: 'Bridal Portraits'
            },
            {
                id: 'rev6',
                userId: 'U1020',
                userName: 'James Miller',
                rating: 3.8,
                comment: 'The photos themselves were very good quality and captured the day well. However, there was some confusion about the timeline and package inclusions which led to a bit of stress on our wedding day. David did his best to accommodate our requests though.',
                date: '2024-11-22',
                serviceName: 'Wedding Photography'
            },
            {
                id: 'rev7',
                userId: 'U1025',
                userName: 'Sophia Martinez',
                rating: 5.0,
                comment: 'Working with David was the best decision we made for our wedding! He captured every special moment and more. His calm presence was so appreciated on a chaotic day. We've received countless compliments on our photos, and the album design is beautiful.',
                date: '2024-10-30',
                serviceName: 'Wedding Photography',
                vendorResponse: {
                    text: 'Thank you so much for your wonderful review, Sophia! It was truly a privilege to be part of your special day. I'm delighted that you're happy with the photos and album. Wishing you both all the happiness in your marriage!',
                    date: '2024-11-02'
                }
            }
        ];
    }
});