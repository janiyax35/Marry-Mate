/**
 * Vendor Profile JavaScript - Marry Mate Wedding Planning System
 * Current Date and Time: 2025-05-07 08:59:02
 * Current User: IT24102137
 */

document.addEventListener('DOMContentLoaded', function() {
    // Global variables
    let vendorData = null;
    let servicesData = [];
    const vendorId = document.body.dataset.vendorId || 'V1004'; // Default for testing
    
    // Initialize the page
    loadVendorData();
    
    // Event Handlers
    
    // Business Info Form
    document.getElementById('businessInfoForm').addEventListener('submit', function(e) {
        e.preventDefault();
        saveBusinessInfo();
    });
    
    // Reset business info form
    document.getElementById('resetBusinessInfoBtn').addEventListener('click', function() {
        populateBusinessInfoForm();
    });
    
    // Change Password Form
    document.getElementById('changePasswordForm').addEventListener('submit', function(e) {
        e.preventDefault();
        changePassword();
    });
    
    // Password strength meter
    document.getElementById('newPassword').addEventListener('input', checkPasswordStrength);
    
    // Preview public profile
    document.getElementById('previewProfileBtn').addEventListener('click', previewPublicProfile);
    
    // Confirm deactivate account
    document.getElementById('confirmDeactivateBtn').addEventListener('click', deactivateAccount);
    
    // Confirm delete account
    document.getElementById('confirmDeleteBtn').addEventListener('click', deleteAccount);
    
    // Portfolio image upload preview
    document.getElementById('portfolioImages').addEventListener('change', previewPortfolioImages);
    
    /**
     * Function to load vendor data
     */
    function loadVendorData() {
        // In a real implementation, this would be an AJAX call to get the vendor data
        // For now, we'll simulate loading from the JSON files
        
        // Show loading state
        showLoading(true);
        
        // Simulate API delay
        setTimeout(function() {
            // This would be replaced with actual API calls
            vendorData = getMockVendorData(vendorId);
            servicesData = getMockServicesData(vendorId);
            
            // Populate the UI with the loaded data
            populateVendorProfile(vendorData);
            populateBusinessInfoForm(vendorData);
            populateAccountInfo(vendorData);
            populatePortfolio(vendorData);
            populateReviews(vendorData);
            populateServices(servicesData);
            
            // Hide loading state
            showLoading(false);
        }, 1000);
    }
    
    /**
     * Function to populate vendor profile UI elements
     */
    function populateVendorProfile(vendor) {
        if (!vendor) return;
        
        // Update header and banner information
        document.getElementById('businessNameHeader').textContent = vendor.businessName;
        document.getElementById('topbarVendorName').textContent = vendor.businessName;
        document.getElementById('profileBusinessName').textContent = vendor.businessName;
        document.getElementById('profileBusinessDescription').textContent = vendor.description || 'No description available';
        
        // Set profile images
        if (vendor.profilePictureURL) {
            const profileImages = document.querySelectorAll('#topbarProfileImage, #profileAvatar');
            profileImages.forEach(img => {
                img.src = vendor.profilePictureURL;
            });
        }
        
        // Set rating
        if (vendor.rating) {
            document.getElementById('profileRating').textContent = vendor.rating.toFixed(1);
            document.getElementById('reviewsRating').textContent = vendor.rating.toFixed(1);
            updateStarRating(vendor.rating);
        }
        
        // Set review count
        const reviewCount = vendor.reviews ? vendor.reviews.length : 0;
        document.getElementById('profileReviewCount').textContent = reviewCount;
        document.getElementById('reviewsCount').textContent = reviewCount;
        
        // Set banner background if available (would normally come from vendor data)
        // This is a placeholder for now
        document.querySelector('.profile-banner-background').style.backgroundImage = 
            `url('${vendor.bannerImagePath || '${pageContext.request.contextPath}/assets/images/vendor/default-banner.jpg'}')`;
    }
    
    /**
     * Function to populate business info form
     */
    function populateBusinessInfoForm() {
        if (!vendorData) return;
        
        document.getElementById('businessName').value = vendorData.businessName || '';
        document.getElementById('contactPerson').value = vendorData.contactPerson || '';
        document.getElementById('phoneNumber').value = vendorData.phoneNumber || '';
        document.getElementById('email').value = vendorData.email || '';
        document.getElementById('businessDescription').value = vendorData.description || '';
        document.getElementById('businessLocation').value = vendorData.location || '';
        
        // Set price range if available
        if (vendorData.priceRange) {
            document.getElementById('priceRangeMin').value = vendorData.priceRange.min || '';
            document.getElementById('priceRangeMax').value = vendorData.priceRange.max || '';
        }
        
        document.getElementById('averagePrice').value = vendorData.averagePrice || '';
        document.getElementById('featuredVendor').checked = vendorData.featured || false;
    }
    
    /**
     * Function to populate account info
     */
    function populateAccountInfo(vendor) {
        if (!vendor) return;
        
        document.getElementById('username').value = vendor.username || '';
        document.getElementById('userId').value = vendor.userId || '';
        
        // Set account status with appropriate styling
        const accountStatusInput = document.getElementById('accountStatus');
        accountStatusInput.value = vendor.accountStatus || 'inactive';
        
        if (vendor.accountStatus === 'active') {
            accountStatusInput.classList.add('text-success');
            accountStatusInput.classList.remove('text-danger', 'text-warning');
        } else if (vendor.accountStatus === 'inactive') {
            accountStatusInput.classList.add('text-danger');
            accountStatusInput.classList.remove('text-success', 'text-warning');
        } else {
            accountStatusInput.classList.add('text-warning');
            accountStatusInput.classList.remove('text-success', 'text-danger');
        }
    }
    
    /**
     * Function to populate portfolio images
     */
    function populatePortfolio(vendor) {
        const portfolioContainer = document.getElementById('portfolioContainer');
        const loadingElement = portfolioContainer.querySelector('.portfolio-loading');
        const noPortfolioMessage = document.getElementById('noPortfolioMessage');
        
        if (!vendor || !vendor.portfolioImages || vendor.portfolioImages.length === 0) {
            // Show no portfolio message
            loadingElement.style.display = 'none';
            noPortfolioMessage.style.display = 'block';
            return;
        }
        
        // Hide loading and no portfolio message
        loadingElement.style.display = 'none';
        noPortfolioMessage.style.display = 'none';
        
        // Create portfolio items
        let portfolioHTML = '';
        
        vendor.portfolioImages.forEach((image, index) => {
            portfolioHTML += `
                <div class="portfolio-item" data-index="${index}">
                    <img src="${image}" alt="Portfolio Image ${index + 1}" class="portfolio-image">
                    <div class="portfolio-item-overlay">
                        <div class="portfolio-actions">
                            <button class="portfolio-action-btn view-portfolio-btn" data-image="${image}">
                                <i class="fas fa-eye"></i>
                            </button>
                            <button class="portfolio-action-btn delete-portfolio-btn" data-index="${index}">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                        </div>
                    </div>
                </div>
            `;
        });
        
        // Add the portfolio items to the container
        portfolioContainer.innerHTML = portfolioHTML + loadingElement.outerHTML;
        
        // Add event listeners for portfolio actions
        document.querySelectorAll('.view-portfolio-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const imageUrl = this.dataset.image;
                viewPortfolioImage(imageUrl);
            });
        });
        
        document.querySelectorAll('.delete-portfolio-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const index = parseInt(this.dataset.index);
                deletePortfolioImage(index);
            });
        });
    }
    
    /**
     * Function to populate reviews
     */
    function populateReviews(vendor) {
        const reviewsContainer = document.getElementById('reviewsContainer');
        const loadingElement = reviewsContainer.querySelector('.reviews-loading');
        const noReviewsMessage = document.getElementById('noReviewsMessage');
        
        if (!vendor || !vendor.reviews || vendor.reviews.length === 0) {
            // Show no reviews message
            loadingElement.style.display = 'none';
            noReviewsMessage.style.display = 'block';
            return;
        }
        
        // Hide loading and no reviews message
        loadingElement.style.display = 'none';
        noReviewsMessage.style.display = 'none';
        
        // Create reviews
        let reviewsHTML = '';
        
        vendor.reviews.forEach((review, index) => {
            reviewsHTML += `
                <div class="review-item">
                    <div class="review-header">
                        <div class="reviewer">
                            <img src="${pageContext.request.contextPath}/assets/images/profiles/default-user.jpg" alt="Reviewer" class="reviewer-avatar">
                            <div>
                                <p class="reviewer-name">User ID: ${review.userId}</p>
                                <div class="rating">
                                    ${getStarsHTML(review.rating)}
                                    <span class="rating-value">${review.rating.toFixed(1)}</span>
                                </div>
                            </div>
                        </div>
                        <div class="review-date">
                            ${review.date || 'No date available'}
                        </div>
                    </div>
                    <div class="review-content">
                        <p>${review.comment || 'No comment provided'}</p>
                    </div>
                    <div class="review-actions">
                        <button class="btn btn-sm btn-outline-primary respond-review-btn" data-review-index="${index}">
                            <i class="fas fa-reply"></i> Respond
                        </button>
                    </div>
                </div>
            `;
        });
        
        // Add the reviews to the container
        reviewsContainer.innerHTML = reviewsHTML + loadingElement.outerHTML;
        
        // Add event listeners for review actions
        document.querySelectorAll('.respond-review-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const reviewIndex = parseInt(this.dataset.reviewIndex);
                respondToReview(reviewIndex);
            });
        });
    }
    
    /**
     * Function to populate services
     */
    function populateServices(services) {
        const servicesContainer = document.getElementById('servicesContainer');
        const loadingElement = servicesContainer.querySelector('.service-loading');
        const noServicesMessage = document.getElementById('noServicesMessage');
        
        if (!services || services.length === 0) {
            // Show no services message
            loadingElement.style.display = 'none';
            noServicesMessage.style.display = 'block';
            return;
        }
        
        // Hide loading and no services message
        loadingElement.style.display = 'none';
        noServicesMessage.style.display = 'none';
        
        // Create services
        let servicesHTML = '';
        
        services.forEach((service) => {
            servicesHTML += `
                <div class="col">
                    <div class="card service-card h-100">
                        <div class="service-card-banner" style="background-image: url('${service.backgroundImagePath || '${pageContext.request.contextPath}/assets/images/vendor/service-placeholder-bg.jpg'}');">
                            <span class="badge rounded-pill ${service.active ? 'bg-success' : 'bg-secondary'} position-absolute top-0 end-0 mt-2 me-2">${service.active ? 'Active' : 'Inactive'}</span>
                        </div>
                        <div class="card-body">
                            <div class="d-flex align-items-center mb-3">
                                <img src="${service.iconPath || '${pageContext.request.contextPath}/assets/images/vendor/service-placeholder.jpg'}" alt="${service.serviceName}" class="service-card-icon me-3">
                                <h5 class="card-title mb-0">${service.serviceName}</h5>
                            </div>
                            <p class="card-text text-muted small mb-1">${service.category || 'Uncategorized'}</p>
                            <p class="card-text mb-3">${service.description ? service.description.substring(0, 100) + (service.description.length > 100 ? '...' : '') : 'No description available'}</p>
                            <div class="d-flex justify-content-between align-items-center">
                                <h5 class="service-price mb-0">$${parseFloat(service.basePrice).toFixed(2)}</h5>
                                <a href="${pageContext.request.contextPath}/vendor/services.jsp?edit=${service.serviceId}" class="btn btn-sm btn-outline-primary">
                                    <i class="fas fa-edit"></i> Edit
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            `;
        });
        
        // Add the services to the container (but keep the loading element at the end)
        servicesContainer.innerHTML = servicesHTML + loadingElement.outerHTML;
    }
    
    /**
     * Function to save business info
     */
    function saveBusinessInfo() {
        // Get form data
        const businessName = document.getElementById('businessName').value;
        const contactPerson = document.getElementById('contactPerson').value;
        const phoneNumber = document.getElementById('phoneNumber').value;
        const email = document.getElementById('email').value;
        const businessDescription = document.getElementById('businessDescription').value;
        const businessLocation = document.getElementById('businessLocation').value;
        const priceRangeMin = document.getElementById('priceRangeMin').value;
        const priceRangeMax = document.getElementById('priceRangeMax').value;
        const averagePrice = document.getElementById('averagePrice').value;
        const featuredVendor = document.getElementById('featuredVendor').checked;
        
        // Validation
        if (!businessName || !contactPerson || !email) {
            showAlert('Please fill in all required fields', 'danger');
            return;
        }
        
        // Show loading
        showLoading(true, 'saveBusinessInfoBtn');
        
        // In a real implementation, this would be an AJAX call to save the data
        // For now, we'll simulate a successful save
        setTimeout(function() {
            // Update the vendorData object
            vendorData.businessName = businessName;
            vendorData.contactPerson = contactPerson;
            vendorData.phoneNumber = phoneNumber;
            vendorData.email = email;
            vendorData.description = businessDescription;
            vendorData.location = businessLocation;
            vendorData.priceRange = {
                min: parseFloat(priceRangeMin) || 0,
                max: parseFloat(priceRangeMax) || 0
            };
            vendorData.averagePrice = parseFloat(averagePrice) || 0;
            vendorData.featured = featuredVendor;
            
            // Update UI
            populateVendorProfile(vendorData);
            
            // Hide loading
            showLoading(false, 'saveBusinessInfoBtn');
            
            // Show success message
            showAlert('Business information updated successfully', 'success');
        }, 1500);
    }
    
    /**
     * Function to change password
     */
    function changePassword() {
        // Get form data
        const currentPassword = document.getElementById('currentPassword').value;
        const newPassword = document.getElementById('newPassword').value;
        const confirmNewPassword = document.getElementById('confirmNewPassword').value;
        
        // Validation
        if (!currentPassword || !newPassword || !confirmNewPassword) {
            showAlert('Please fill in all password fields', 'danger');
            return;
        }
        
        if (newPassword !== confirmNewPassword) {
            showAlert('New passwords do not match', 'danger');
            return;
        }
        
        if (newPassword.length < 8) {
            showAlert('New password must be at least 8 characters long', 'danger');
            return;
        }
        
        // Show loading
        const submitBtn = document.querySelector('#changePasswordForm button[type="submit"]');
        const originalBtnText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Updating...';
        submitBtn.disabled = true;
        
        // In a real implementation, this would be an AJAX call to change the password
        // For now, we'll simulate a successful password change
        setTimeout(function() {
            // Reset the form
            document.getElementById('changePasswordForm').reset();
            document.getElementById('passwordStrengthBar').style.width = '0%';
            document.getElementById('passwordStrengthBar').classList.remove('bg-danger', 'bg-warning', 'bg-success');
            document.getElementById('passwordStrengthText').textContent = 'Password must be at least 8 characters long with letters, numbers, and special characters';
            
            // Update button
            submitBtn.innerHTML = originalBtnText;
            submitBtn.disabled = false;
            
            // Show success message
            showAlert('Password changed successfully', 'success');
        }, 1500);
    }
    
    /**
     * Function to check password strength
     */
    function checkPasswordStrength() {
        const password = document.getElementById('newPassword').value;
        const strengthBar = document.getElementById('passwordStrengthBar');
        const strengthText = document.getElementById('passwordStrengthText');
        
        // Password strength criteria
        const hasLength = password.length >= 8;
        const hasLetter = /[a-zA-Z]/.test(password);
        const hasNumber = /\d/.test(password);
        const hasSpecial = /[^a-zA-Z0-9]/.test(password);
        
        let strength = 0;
        if (hasLength) strength += 25;
        if (hasLetter) strength += 25;
        if (hasNumber) strength += 25;
        if (hasSpecial) strength += 25;
        
        // Update strength bar
        strengthBar.style.width = `${strength}%`;
        
        // Update strength bar color and text
        if (strength < 50) {
            strengthBar.className = 'progress-bar bg-danger';
            strengthText.textContent = 'Weak password';
        } else if (strength < 75) {
            strengthBar.className = 'progress-bar bg-warning';
            strengthText.textContent = 'Moderate password';
        } else {
            strengthBar.className = 'progress-bar bg-success';
            strengthText.textContent = 'Strong password';
        }
    }
    
    /**
     * Function to preview public profile
     */
    function previewPublicProfile() {
        // Get the preview modal
        const previewModal = new bootstrap.Modal(document.getElementById('previewModal'));
        const previewModalBody = document.getElementById('previewModalBody');
        
        // Show loading in the preview modal
        previewModalBody.innerHTML = `
            <div class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Loading preview...</span>
                </div>
                <p class="mt-2">Loading preview...</p>
            </div>
        `;
        
        // Show the modal
        previewModal.show();
        
        // In a real implementation, this would be an AJAX call to get the public profile HTML
        // For now, we'll simulate a successful load
        setTimeout(function() {
            if (!vendorData) {
                previewModalBody.innerHTML = '<div class="alert alert-danger">Error loading profile preview</div>';
                return;
            }
            
            // Generate the public profile HTML
            const publicProfileHtml = `
                <div class="public-profile-preview">
                    <div class="vendor-profile-banner">
                        <div class="profile-banner-background" style="background-image: url('${vendorData.bannerImagePath || '${pageContext.request.contextPath}/assets/images/vendor/default-banner.jpg'}');"></div>
                        <div class="profile-banner-overlay"></div>
                        <div class="profile-banner-content">
                            <div class="vendor-avatar">
                                <img src="${vendorData.profilePictureURL || '${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg'}" alt="${vendorData.businessName}">
                            </div>
                            <div class="vendor-info">
                                <h2>${vendorData.businessName}</h2>
                                <div class="vendor-meta">
                                    <span><i class="fas fa-map-marker-alt"></i> ${vendorData.location || 'No location specified'}</span>
                                    <span><i class="fas fa-star"></i> ${vendorData.rating ? vendorData.rating.toFixed(1) : 'No ratings'} (${vendorData.reviews ? vendorData.reviews.length : 0} reviews)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="vendor-profile-content p-4">
                        <div class="row mb-4">
                            <div class="col-md-8">
                                <h4>About</h4>
                                <p>${vendorData.description || 'No description available'}</p>
                                
                                <h4 class="mt-4">Services</h4>
                                ${servicesData.length > 0 ? `
                                    <ul class="list-group">
                                        ${servicesData.map(service => `
                                            <li class="list-group-item d-flex justify-content-between align-items-center">
                                                ${service.serviceName}
                                                <span class="badge bg-primary rounded-pill">$${parseFloat(service.basePrice).toFixed(2)}</span>
                                            </li>
                                        `).join('')}
                                    </ul>
                                ` : '<p>No services available</p>'}
                            </div>
                            
                            <div class="col-md-4">
                                <div class="card">
                                    <div class="card-body">
                                        <h5 class="card-title">Contact Information</h5>
                                        <p class="card-text"><i class="fas fa-user me-2"></i> ${vendorData.contactPerson || 'No contact person specified'}</p>
                                        <p class="card-text"><i class="fas fa-phone me-2"></i> ${vendorData.phoneNumber || 'No phone number specified'}</p>
                                        <p class="card-text"><i class="fas fa-envelope me-2"></i> ${vendorData.email || 'No email specified'}</p>
                                        
                                        <a href="#" class="btn btn-primary w-100 mt-3">Contact Now</a>
                                    </div>
                                </div>
                                
                                <div class="card mt-3">
                                    <div class="card-body">
                                        <h5 class="card-title">Price Range</h5>
                                        <p class="card-text">
                                            ${vendorData.priceRange ? `$${vendorData.priceRange.min} - $${vendorData.priceRange.max}` : 'No price range specified'}
                                        </p>
                                        <p class="card-text">
                                            Average: $${vendorData.averagePrice ? parseFloat(vendorData.averagePrice).toFixed(2) : 'N/A'}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        ${vendorData.portfolioImages && vendorData.portfolioImages.length > 0 ? `
                            <div class="mb-4">
                                <h4>Portfolio</h4>
                                <div class="row row-cols-2 row-cols-md-3 row-cols-lg-4 g-3">
                                    ${vendorData.portfolioImages.map(image => `
                                        <div class="col">
                                            <div class="card h-100">
                                                <img src="${image}" alt="Portfolio Image" class="card-img-top" style="height: 150px; object-fit: cover;">
                                            </div>
                                        </div>
                                    `).join('')}
                                </div>
                            </div>
                        ` : ''}
                        
                        ${vendorData.reviews && vendorData.reviews.length > 0 ? `
                            <div>
                                <h4>Reviews</h4>
                                <div class="list-group">
                                    ${vendorData.reviews.map(review => `
                                        <div class="list-group-item">
                                            <div class="d-flex justify-content-between">
                                                <h6 class="mb-1">User ID: ${review.userId}</h6>
                                                <small class="text-muted">
                                                    ${getStarsHTML(review.rating)}
                                                    ${review.rating.toFixed(1)}
                                                </small>
                                            </div>
                                            <p class="mb-1">${review.comment || 'No comment provided'}</p>
                                            <small class="text-muted">${review.date || 'No date available'}</small>
                                        </div>
                                    `).join('')}
                                </div>
                            </div>
                        ` : ''}
                    </div>
                </div>
            `;
            
            // Update the modal body with the public profile HTML
            previewModalBody.innerHTML = publicProfileHtml;
        }, 1500);
    }
    
    /**
     * Function to deactivate account
     */
    function deactivateAccount() {
        const deactivateConfirm = document.getElementById('deactivateConfirm').checked;
        const deactivateReason = document.getElementById('deactivateReason').value;
        
        if (!deactivateConfirm) {
            showAlert('Please confirm that you understand the implications of deactivating your account', 'danger');
            return;
        }
        
        // Show loading
        const deactivateBtn = document.getElementById('confirmDeactivateBtn');
        const originalBtnText = deactivateBtn.innerText;
        deactivateBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Processing...';
        deactivateBtn.disabled = true;
        
        // In a real implementation, this would be an AJAX call to deactivate the account
        // For now, we'll simulate a successful deactivation
        setTimeout(function() {
            // Close the modal
            bootstrap.Modal.getInstance(document.getElementById('deactivateAccountModal')).hide();
            
            // Reset the form
            document.getElementById('deactivateReason').value = '';
            document.getElementById('deactivateConfirm').checked = false;
            
            // Reset button
            deactivateBtn.innerHTML = originalBtnText;
            deactivateBtn.disabled = false;
            
            // Show success message
            showAlert('Your account has been deactivated', 'info');
            
            // In a real implementation, this would redirect to logout
            setTimeout(function() {
                window.location.href = `${pageContext.request.contextPath}/LogoutServlet`;
            }, 2000);
        }, 1500);
    }
    
    /**
     * Function to delete account
     */
    function deleteAccount() {
        const deleteConfirm = document.getElementById('deleteConfirm').checked;
        const deleteReason = document.getElementById('deleteReason').value;
        const deletePassword = document.getElementById('deleteConfirmPassword').value;
        
        if (!deleteConfirm) {
            showAlert('Please confirm that you understand the implications of deleting your account', 'danger');
            return;
        }
        
        if (!deletePassword) {
            showAlert('Please enter your password to confirm deletion', 'danger');
            return;
        }
        
        // Show loading
        const deleteBtn = document.getElementById('confirmDeleteBtn');
        const originalBtnText = deleteBtn.innerText;
        deleteBtn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Processing...';
        deleteBtn.disabled = true;
        
        // In a real implementation, this would be an AJAX call to delete the account
        // For now, we'll simulate a successful deletion
        setTimeout(function() {
            // Close the modal
            bootstrap.Modal.getInstance(document.getElementById('deleteAccountModal')).hide();
            
            // Reset the form
            document.getElementById('deleteReason').value = '';
            document.getElementById('deleteConfirmPassword').value = '';
            document.getElementById('deleteConfirm').checked = false;
            
            // Reset button
            deleteBtn.innerHTML = originalBtnText;
            deleteBtn.disabled = false;
            
            // Show success message
            showAlert('Your account has been deleted', 'info');
            
            // In a real implementation, this would redirect to logout
            setTimeout(function() {
                window.location.href = `${pageContext.request.contextPath}/LogoutServlet`;
            }, 2000);
        }, 1500);
    }
    
    /**
     * Function to preview portfolio images before upload
     */
    function previewPortfolioImages() {
        const input = document.getElementById('portfolioImages');
        const previewContainer = document.getElementById('portfolioPreviewContainer');
        previewContainer.innerHTML = '';
        
        if (input.files && input.files.length > 0) {
            for (let i = 0; i < input.files.length; i++) {
                const reader = new FileReader();
                
                reader.onload = function(e) {
                    const previewCol = document.createElement('div');
                    previewCol.className = 'col-lg-3 col-md-4 col-6';
                    
                    const previewCard = document.createElement('div');
                    previewCard.className = 'card';
                    
                    const previewImg = document.createElement('img');
                    previewImg.className = 'card-img-top';
                    previewImg.src = e.target.result;
                    previewImg.alt = `Portfolio Preview ${i + 1}`;
                    previewImg.style.height = '150px';
                    previewImg.style.objectFit = 'cover';
                    
                    previewCard.appendChild(previewImg);
                    previewCol.appendChild(previewCard);
                    previewContainer.appendChild(previewCol);
                };
                
                reader.readAsDataURL(input.files[i]);
            }
        }
    }
    
    /**
     * Function to view portfolio image in a modal
     */
    function viewPortfolioImage(imageUrl) {
        // Create a modal to view the image
        // We'll use a bootstrap modal for this
        const modal = document.createElement('div');
        modal.className = 'modal fade';
        modal.id = 'portfolioImageViewModal';
        modal.tabIndex = '-1';
        modal.setAttribute('aria-hidden', 'true');
        
        modal.innerHTML = `
            <div class="modal-dialog modal-lg modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Portfolio Image</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body text-center p-0">
                        <img src="${imageUrl}" alt="Portfolio Image" class="img-fluid">
                    </div>
                </div>
            </div>
        `;
        
        document.body.appendChild(modal);
        
        // Show the modal
        const portfolioImageViewModal = new bootstrap.Modal(document.getElementById('portfolioImageViewModal'));
        portfolioImageViewModal.show();
        
        // Remove the modal from the DOM when it's hidden
        document.getElementById('portfolioImageViewModal').addEventListener('hidden.bs.modal', function() {
            document.body.removeChild(modal);
        });
    }
    
    /**
     * Function to delete portfolio image
     */
    function deletePortfolioImage(index) {
        // Show confirmation dialog using native confirm
        if (!confirm('Are you sure you want to delete this portfolio image? This action cannot be undone.')) {
            return;
        }
        
        // In a real implementation, this would be an AJAX call to delete the image
        // For now, we'll simulate a successful deletion
        
        // Remove the image from the vendorData object
        if (vendorData.portfolioImages && vendorData.portfolioImages.length > index) {
            vendorData.portfolioImages.splice(index, 1);
            
            // Update UI
            populatePortfolio(vendorData);
            
            // Show success message
            showAlert('Portfolio image deleted successfully', 'success');
        }
    }
    
    /**
     * Function to respond to review
     */
    function respondToReview(reviewIndex) {
        alert(`Functionality to respond to review #${reviewIndex + 1} will be implemented in the backend.`);
    }
    
    /**
     * Function to update star rating display
     */
    function updateStarRating(rating) {
        // Find all star rating containers
        const starContainers = document.querySelectorAll('.profile-rating .stars, .rating-summary .stars');
        
        // Update each container
        starContainers.forEach(container => {
            container.innerHTML = getStarsHTML(rating);
        });
    }
    
    /**
     * Function to get HTML for star rating
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
     * Function to show loading state
     */
    function showLoading(isLoading, btnId = null) {
        if (btnId) {
            // If a button ID is provided, update the button
            const btn = document.getElementById(btnId);
            if (isLoading) {
                btn.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Loading...';
                btn.disabled = true;
            } else {
                btn.innerHTML = '<i class="fas fa-save me-2"></i>Save Changes';
                btn.disabled = false;
            }
        } else {
            // Otherwise, update the global loading state if needed
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
        
        // Create a temporary container for the alert
        const alertContainer = document.createElement('div');
        alertContainer.className = 'alert-container position-fixed bottom-0 end-0 p-3';
        alertContainer.style.zIndex = '9999';
        alertContainer.innerHTML = alertHTML;
        
        document.body.appendChild(alertContainer);
        
        // Remove the alert after 5 seconds
        setTimeout(function() {
            alertContainer.querySelector('.alert').classList.remove('show');
            setTimeout(function() {
                document.body.removeChild(alertContainer);
            }, 500);
        }, 5000);
    }
    
    /**
     * Mock function to get vendor data (simulating vendors.json)
     */
    function getMockVendorData(vendorId) {
        // This would be replaced with an actual API call to get vendor data from vendors.json
        const vendors = [
            {
                "businessName": "Elegant Photography",
                "contactPerson": "David Williams",
                "serviceIds": ["S1001"],
                "description": "Award-winning wedding photography with 15+ years of experience capturing special moments.",
                "priceRange": {
                    "min": 2000,
                    "max": 5000
                },
                "averagePrice": 3000.0,
                "location": "100 Main Street, Boston, MA",
                "availability": [
                    "2025-06-12",
                    "2025-06-19",
                    "2025-07-03"
                ],
                "rating": 4.7,
                "reviews": [
                    {
                        "userId": "U1001",
                        "comment": "David captured our special day perfectly! The photos are absolutely stunning.",
                        "rating": 5.0,
                        "date": "2025-04-15"
                    },
                    {
                        "userId": "U1005",
                        "comment": "Professional and creative. Would highly recommend!",
                        "rating": 4.8,
                        "date": "2025-03-22"
                    },
                    {
                        "userId": "U1003",
                        "comment": "Great photos but took longer than expected to deliver the final album.",
                        "rating": 4.2,
                        "date": "2025-02-18"
                    }
                ],
                "portfolioImages": [
                    "${pageContext.request.contextPath}/assets/images/vendor/elegant_photos/sample1.jpg",
                    "${pageContext.request.contextPath}/assets/images/vendor/elegant_photos/sample2.jpg",
                    "${pageContext.request.contextPath}/assets/images/vendor/elegant_photos/sample3.jpg"
                ],
                "featured": true,
                "userId": "V1004",
                "username": "elegant_photos",
                "email": "contact@elegantphotos.com",
                "phoneNumber": "+1-555-111-2222",
                "profilePictureURL": "${pageContext.request.contextPath}/assets/images/profiles/default-profile.jpg",
                "role": "vendor",
                "registrationDate": "2024-09-15 10:30:00",
                "lastLogin": "2025-05-05 14:25:30",
                "accountStatus": "active"
            }
        ];
        
        // Find the vendor with the matching ID
        return vendors.find(vendor => vendor.userId === vendorId) || null;
    }
    
    /**
     * Mock function to get service data (simulating vendorServices.json)
     */
    function getMockServicesData(vendorId) {
        // This would be replaced with an actual API call to get service data from vendorServices.json
        const allServices = [
            {
                "serviceId": "S1001",
                "serviceName": "Full Day Wedding Photography",
                "category": "photography",
                "description": "Comprehensive wedding photography from preparations to reception. Includes 2 photographers, 8-hour coverage, and digital delivery of all edited photos.",
                "iconPath": "${pageContext.request.contextPath}/assets/images/vendor/photography-icon.jpg",
                "backgroundImagePath": "${pageContext.request.contextPath}/assets/images/vendor/photography-bg.jpg",
                "active": true,
                "customizationOptions": [
                    "8-Hour Coverage",
                    "12-Hour Coverage",
                    "Second Photographer",
                    "Engagement Session"
                ],
                "basePrice": 3500.00,
                "vendorId": "V1004"
            },
            {
                "serviceId": "S1002",
                "serviceName": "Engagement Session",
                "category": "photography",
                "description": "Pre-wedding photoshoot at location of your choice. Includes 2-hour session and digital delivery of 50+ edited photos.",
                "iconPath": "${pageContext.request.contextPath}/assets/images/vendor/engagement-icon.jpg",
                "backgroundImagePath": "${pageContext.request.contextPath}/assets/images/vendor/engagement-bg.jpg",
                "active": true,
                "customizationOptions": [
                    "1-Hour Session",
                    "2-Hour Session",
                    "Multiple Locations",
                    "Outfit Changes"
                ],
                "basePrice": 800.00,
                "vendorId": "V1004"
            },
            {
                "serviceId": "S1003",
                "serviceName": "Wedding Album Design",
                "category": "photography",
                "description": "Custom designed wedding album with premium printing options. Includes 40 pages with up to 100 photos.",
                "iconPath": "${pageContext.request.contextPath}/assets/images/vendor/album-icon.jpg",
                "backgroundImagePath": "${pageContext.request.contextPath}/assets/images/vendor/album-bg.jpg",
                "active": false,
                "customizationOptions": [
                    "40-Page Album",
                    "60-Page Album",
                    "Leather Cover",
                    "Parent Copy Albums"
                ],
                "basePrice": 1200.00,
                "vendorId": "V1004"
            }
        ];
        
        // Filter services for the specific vendor
        return allServices.filter(service => service.vendorId === vendorId);
    }
});