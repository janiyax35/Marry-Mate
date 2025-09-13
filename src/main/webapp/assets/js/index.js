/**
 * Main JavaScript for Home/Index Page - Marry Mate Wedding Planning System
 * 
 * Current Date and Time: 2025-04-30 18:35:55
 * Current User: IT24102137
 */

// Wait for document to be fully loaded before running scripts
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Animation On Scroll (AOS) for smooth animations
    AOS.init({
        duration: 800,
        easing: 'ease-out',
        once: true,
        offset: 100
    });
    
    // Initialize Swiper for vendor carousel
    const vendorSwiper = new Swiper('.vendor-swiper', {
        slidesPerView: 1,
        spaceBetween: 20,
        pagination: {
            el: '.vendor-swiper .swiper-pagination',
            clickable: true
        },
        navigation: {
            nextEl: '.vendor-swiper .swiper-button-next',
            prevEl: '.vendor-swiper .swiper-button-prev',
        },
        breakpoints: {
            640: {
                slidesPerView: 2,
            },
            992: {
                slidesPerView: 3,
            },
            1200: {
                slidesPerView: 4,
                spaceBetween: 30,
            },
        }
    });
    
    // Initialize Swiper for testimonials
    const testimonialSwiper = new Swiper('.testimonial-swiper', {
        slidesPerView: 1,
        spaceBetween: 20,
        pagination: {
            el: '.testimonial-swiper .swiper-pagination',
            clickable: true
        },
        breakpoints: {
            768: {
                slidesPerView: 2,
                spaceBetween: 30,
            },
            1024: {
                slidesPerView: 3,
                spaceBetween: 40,
            },
        }
    });
    
    // Navbar scroll effect
    const navbar = document.querySelector('.navbar');
    
    function handleScroll() {
        if (window.scrollY > 100) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
        
        // Back to top button visibility
        const backToTopBtn = document.getElementById('back-to-top');
        if (window.scrollY > 300) {
            backToTopBtn.classList.add('active');
        } else {
            backToTopBtn.classList.remove('active');
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
    
    // Add subtle parallax effect to floating cards in hero section
    const floatingCards = document.querySelectorAll('.floating-card');
    if (floatingCards.length > 0) {
        window.addEventListener('mousemove', function(e) {
            const mouseX = e.clientX / window.innerWidth;
            const mouseY = e.clientY / window.innerHeight;
            
            floatingCards.forEach(card => {
                const cardRect = card.getBoundingClientRect();
                const cardCenterX = cardRect.left + cardRect.width / 2;
                const cardCenterY = cardRect.top + cardRect.height / 2;
                
                const moveX = (mouseX - 0.5) * 15;
                const moveY = (mouseY - 0.5) * 15;
                
                card.style.transform = `translateX(${moveX}px) translateY(${moveY}px) rotate(${card.dataset.rotate || '0deg'})`;
            });
        });
        
        // Store original rotation values for cards
        document.querySelector('.card-1').dataset.rotate = '5deg';
        document.querySelector('.card-2').dataset.rotate = '-8deg';
        document.querySelector('.card-3').dataset.rotate = '3deg';
    }
    
    // Form validation for subscription/newsletter form
    const newsForm = document.getElementById('newsletter-form');
    if (newsForm) {
        newsForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const emailInput = document.getElementById('newsletter-email');
            const email = emailInput.value.trim();
            
            if (email === '' || !isValidEmail(email)) {
                showToast('Please enter a valid email address', 'error');
                emailInput.classList.add('is-invalid');
                return;
            }
            
            // Submit form via AJAX
            const formData = new FormData(this);
            
            // Simulate AJAX request
            setTimeout(() => {
                showToast('Thank you for subscribing!', 'success');
                emailInput.value = '';
                emailInput.classList.remove('is-invalid');
            }, 1000);
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
    
    // Event handler for category cards
    document.querySelectorAll('.category-card').forEach(card => {
        card.addEventListener('mouseenter', function() {
            const icon = this.querySelector('.icon i');
            const span = this.querySelector('span i');
            
            // Apply animation classes
            if (icon) icon.classList.add('animated', 'heartBeat');
            if (span) span.classList.add('animated', 'fadeOutRight', 'fadeInRight');
            
            // Remove animation classes after animation completes
            setTimeout(() => {
                if (icon) icon.classList.remove('animated', 'heartBeat');
                if (span) span.classList.remove('animated', 'fadeOutRight', 'fadeInRight');
            }, 1000);
        });
    });
    
    // Add animated underline to active nav item
    const currentPath = window.location.pathname;
    document.querySelectorAll('.nav-link').forEach(link => {
        if (link.getAttribute('href') === currentPath || 
            (currentPath === '/' && link.classList.contains('active'))) {
            link.classList.add('active');
        }
    });
    
    // Optional: Add loading animation for page transitions
    document.querySelectorAll('a').forEach(link => {
        if (link.hostname === window.location.hostname && !link.getAttribute('href').startsWith('#')) {
            link.addEventListener('click', function(e) {
                if (!e.ctrlKey && !e.metaKey) { // Don't trigger if ctrl/cmd+click
                    // Show loading animation
                    const loadingOverlay = document.createElement('div');
                    loadingOverlay.className = 'page-transition-overlay';
                    loadingOverlay.innerHTML = `
                        <div class="loader">
                            <i class="fas fa-heart"></i>
                            <i class="fas fa-ring"></i>
                        </div>
                    `;
                    document.body.appendChild(loadingOverlay);
                    
                    // Remove overlay if navigation takes too long (fallback)
                    setTimeout(() => {
                        if (document.body.contains(loadingOverlay)) {
                            loadingOverlay.remove();
                        }
                    }, 5000);
                }
            });
        }
    });
    
    // Track page analytics (example implementation)
    function trackPageView() {
        // This would normally send data to an analytics service
        console.log('Page viewed:', {
            path: window.location.pathname,
            referrer: document.referrer,
            screenSize: `${window.innerWidth}x${window.innerHeight}`,
            timestamp: new Date().toISOString()
        });
    }
    
    // Call tracking function
    trackPageView();
});