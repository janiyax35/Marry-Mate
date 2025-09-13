/**
 * JavaScript for Wedding Guides Page - Marry Mate Wedding Planning System
 * 
 * Current Date and Time: 2025-05-18 13:16:36
 * Current User: IT24100905
 */

// Wait for document to be fully loaded before running scripts
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Animation On Scroll (AOS)
    AOS.init({
        duration: 800,
        easing: 'ease-out',
        once: true,
        offset: 100
    });
    
    // Navbar scroll effect (imported from index.js but included here for completeness)
    const navbar = document.querySelector('.navbar');
    
    function handleScroll() {
        if (window.scrollY > 100) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
        
        // Back to top button visibility
        const backToTopBtn = document.getElementById('back-to-top');
        if (backToTopBtn) {
            if (window.scrollY > 300) {
                backToTopBtn.classList.add('active');
            } else {
                backToTopBtn.classList.remove('active');
            }
        }
    }
    
    // Throttle scroll events for better performance
    let scrollTimeout;
    window.addEventListener('scroll', function() {
        if (!scrollTimeout) {
            scrollTimeout = setTimeout(function() {
                handleScroll();
                scrollTimeout = null;
            }, 50);
        }
    });
    
    // Initial call in case page is refreshed when already scrolled down
    handleScroll();
    
    // Back to top button functionality
    const backToTopBtn = document.getElementById('back-to-top');
    if (backToTopBtn) {
        backToTopBtn.addEventListener('click', function() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
    
    // Guide search form functionality
    const guideSearchForm = document.querySelector('.guide-search-form');
    if (guideSearchForm) {
        guideSearchForm.addEventListener('submit', function(e) {
            const searchInput = this.querySelector('input[name="search"]');
            const searchTerm = searchInput.value.trim();
            
            // Only submit if search term is not empty
            if (searchTerm === '') {
                e.preventDefault();
                searchInput.focus();
                
                // Show a toast message
                showToast('Please enter a search term', 'info');
            }
        });
    }
    
    // Expert question form functionality
    const expertQuestionForm = document.getElementById('expertQuestionForm');
    if (expertQuestionForm) {
        expertQuestionForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Get form data
            const formData = new FormData(this);
            
            // Simulate form submission
            const submitBtn = this.querySelector('button[type="submit"]');
            const originalBtnText = submitBtn.innerHTML;
            
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Sending...';
            
            // Simulate AJAX request
            setTimeout(() => {
                this.reset();
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalBtnText;
                
                // Show success message
                showToast('Thank you! Your question has been submitted. Our experts will get back to you soon.', 'success');
            }, 1500);
        });
    }
    
    // Newsletter subscription form
    const subscribeForm = document.querySelector('.subscribe-form');
    if (subscribeForm) {
        subscribeForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Get email
            const emailInput = this.querySelector('input[type="email"]');
            const email = emailInput.value.trim();
            
            // Validate email
            if (email === '' || !isValidEmail(email)) {
                showToast('Please enter a valid email address', 'error');
                emailInput.focus();
                return;
            }
            
            // Check privacy checkbox
            const privacyCheck = document.getElementById('privacyCheck');
            if (!privacyCheck.checked) {
                showToast('Please agree to our privacy policy', 'error');
                return;
            }
            
            // Simulate form submission
            const submitBtn = this.querySelector('button[type="submit"]');
            const originalBtnText = submitBtn.innerHTML;
            
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Subscribing...';
            
            // Simulate AJAX request
            setTimeout(() => {
                this.reset();
                submitBtn.disabled = false;
                submitBtn.innerHTML = originalBtnText;
                
                // Show success message
                showToast('Thank you for subscribing! Check your email for a confirmation.', 'success');
            }, 1500);
        });
    }
    
    // Email validation helper
    function isValidEmail(email) {
        const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailPattern.test(email);
    }
    
    // Toast notification function
    function showToast(message, type = 'info') {
        // Create toast container if it doesn't exist
        let toastContainer = document.querySelector('.toast-container');
        
        if (!toastContainer) {
            toastContainer = document.createElement('div');
            toastContainer.className = 'toast-container';
            document.body.appendChild(toastContainer);
        }
        
        // Create toast element
        const toast = document.createElement('div');
        toast.className = `toast toast-${type} show`;
        
        let icon = 'info-circle';
        if (type === 'success') icon = 'check-circle';
        if (type === 'error') icon = 'exclamation-circle';
        
        toast.innerHTML = `
            <div class="toast-content">
                <i class="fas fa-${icon}"></i>
                <span>${message}</span>
            </div>
        `;
        
        // Add to container
        toastContainer.appendChild(toast);
        
        // Remove after delay
        setTimeout(() => {
            toast.classList.add('hide');
            setTimeout(() => {
                toast.remove();
            }, 300);
        }, 3000);
    }
    
    // Handle guide category filter clicks with smooth transitions
    document.querySelectorAll('.category-filter-btn').forEach(button => {
        button.addEventListener('click', function(e) {
            // Already on this page - prevent default and just scroll to top
            if (this.classList.contains('active')) {
                e.preventDefault();
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            }
        });
    });
    
    // Handle pagination click for demo purposes
    document.querySelectorAll('.pagination .page-link').forEach(link => {
        link.addEventListener('click', function(e) {
            // Prevent default action
            e.preventDefault();
            
            // If not already active, simulate page change
            if (!this.parentElement.classList.contains('active') && 
                !this.parentElement.classList.contains('disabled')) {
                
                // Update active state
                document.querySelectorAll('.pagination .page-item').forEach(item => {
                    item.classList.remove('active');
                });
                
                this.parentElement.classList.add('active');
                
                // Scroll to top of guides section
                const guidesSection = document.querySelector('.guide-categories');
                if (guidesSection) {
                    guidesSection.scrollIntoView({ behavior: 'smooth' });
                }
                
                // Show loading effect
                document.querySelectorAll('.guide-card').forEach(card => {
                    card.style.opacity = '0.5';
                });
                
                // Simulate page content change
                setTimeout(() => {
                